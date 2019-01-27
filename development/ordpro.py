#!python3
# -*- coding: utf-8 -*-

from pprint import pprint
from sys import exit
from json import dumps
from time import sleep
from shutil import move
from hashlib import md5
from exceptions import *
from re import match, sub
from shutil import rmtree
from fnmatch import fnmatch
from ipaddress import ip_address
from urllib.request import urlopen
from elasticsearch import Elasticsearch
from os import walk, sep, listdir, makedirs
from os.path import isdir, exists, isfile, join
from configparser import ConfigParser, ExtendedInterpolation
from logging import basicConfig, critical, error, warning, info, debug

class AfcosMonitor:
    def __init__(self, directory_input):
        self.directory_input = directory_input
        if self.directory_input == None or self.directory_input == '':
            critical('No directory specified!')
            exit()

    def _check_orders_directory(self):
        debug('Checking if any orders exist in [{}].'.format(self.directory_input))
        if exists(self.directory_input) and isdir(self.directory_input):
            if not listdir(self.directory_input):
                warning('Orders DO NOT exist in [{}].'.format(self.directory_input))
                raise OrdersDoNotExistError
        else:
            warning('[{}] does not exist or is not a directory.'.format(self.directory_input))
            raise OrdersDoNotExistError

    def _count_current_orders(self):
        debug('Counting files in [{}].'.format(self.directory_input))
        self.count_orders = len(listdir(self.directory_input))
        if not self.count_orders > 0:
            critical('[{}] has [{}] files.'.format(self.directory_input, self.count_orders))
            raise OrdersDoNotExistError

    def _get_current_orders_number(self):
        debug('Retrieving current orders number.')
        self.current_orders_number = listdir(self.directory_input)[0].split(sep)[-1][3:9]
        if not match(r'^[0-9]{6}$', self.current_orders_number):
            critical('[{}] does not match required order number pattern.'.format(self.current_orders_number))
            raise OrdersNumberPatternError

    def _compare_orders_numbers(self, last_orders_number):
        debug('Comparing current order batch against previous order batch.')
        self.last_orders_number = last_orders_number
        if int(self.current_orders_number) == int(self.last_orders_number):
            critical('Current orders number [{}] is equal to last orders number [{}].'.format(self.current_orders_number, self.last_orders_number))
            raise OrdersNumberEqualError

    def _gather_current_orders_files(self):
        debug('Gathering current orders number [{}] (4) required files to process.'.format(self.current_orders_number))
        self.files_found = 0
        self.current_orders_files = {}
        self.current_orders_files[self.current_orders_number] = {}
        for file in listdir(self.directory_input):
            if fnmatch(file, 'ord{}m.prt'.format(self.current_orders_number)):
                self.files_found += 1
                self.current_orders_files[self.current_orders_number]['main_order_file'] = join(self.directory_input, file)
            elif fnmatch(file, 'ord{}c.prt'.format(self.current_orders_number)):
                self.files_found += 1
                self.current_orders_files[self.current_orders_number]['certificate_order_file'] = join(self.directory_input, file)
            elif fnmatch(file, 'reg{}r.reg'.format(self.current_orders_number)):
                self.files_found += 1
                self.current_orders_files[self.current_orders_number]['registry_file'] = join(self.directory_input, file)
            elif fnmatch(file, 'reg{}r.prt'.format(self.current_orders_number)):
                self.files_found += 1
                self.current_orders_files[self.current_orders_number]['registry_prt_file'] = join(self.directory_input, file)
        if self.files_found == 4:
            return self.current_orders_files
        else:
            critical('Unable to gather current orders number [{}] (4) required files to process. Found [{}/4] required files to process.'.format(self.current_orders_number, self.files_found))

class AfcosParser:
    def __init__(self, current_orders_files, config_file, config):
        self.current_orders_files = current_orders_files
        self.config_file = config_file
        self.config = config
        self.current_orders_number = list(self.current_orders_files.keys())[0]
        '''
        Data structure to store parsed information.

        self._results = {
            line_1 : [ order_info ],
        	...
        	line_N : ...
        }

    	order_info : {
    		'order_number' : ,
    		'year' : ,
    		'name' : ,
    		'fname' : ,
    		'mname' : ,
    		'lname' : ,
    		'format' : ,
    		'uic' : ,
    		'period_from' : ,
    		'period_to' : ,
    		'soldier_uid' : ,
            'document_uid' : ,
    		'main_order' : ,
    		'certificate_order' : ,
            'directory_uics' : ,
            'directory_ord_managers' : ,
            'order_file_main' : ,
            'link_uics_main' : ,
            'link_ord_managers_main' :
            'order_file_certificate' : ,
            'link_uics_certificate' : ,
            'link_ord_managers_certificate' :
    	}
        '''
        self._results = {}
        debug('Processing current orders number [{}]'.format(self.current_orders_number))
        self._parse_registry_file(self.current_orders_files[self.current_orders_number]['registry_file'])

    def _parse_registry_file(self, registry_file):
        debug('Parsing [{}].'.format(registry_file))
        self.line_number = 0
        with open(registry_file, 'r') as regfile:
            for line in regfile:
                self.line_number += 1
                self._results[self.line_number] = []
                order_info = {
                    'order_number' : '',
                    'year' : '',
                    'name' : '',
                    'mname' : '',
                    'lname' : '',
                    'format' : '',
                    'uic' : '',
                    'period_from' : '',
                    'period_to' : '',
                    'soldier_uid' : '',
                    'document_uid' : '',
                    'main_order' : '',
                    'certificate_order' : '',
                    'directory_uics' : '',
                    'directory_ord_managers' : '',
                    'order_file_main' : '',
                    'link_uics_main' : '',
                    'link_ord_managers_main' : '',
                    'order_file_certificate' : '',
                    'link_uics_certificate' : '',
                    'link_ord_managers_certificate' : ''
                }
                ''' Gather all required variables from registry file '''
                order_number = line[:6]
                year = line[6:12]
                format = line[12:15]
                uic = sub('\W', '_', line[37:42].strip())
                period_from = line[48:54]
                period_from = self._determine_period_year(period_year=period_from)
                period_to = line[54:60]
                period_to = self._determine_period_year(period_year=period_to)
                ssn = line[60:69]
                dict_variables_patterns = {
                    'order_number' : {
                        order_number : r'^[0-9]{6}$',
                    },
                    'year' : {
                        year : r'^[0-9]{6}$',
                    },
                    'format' : {
                        format : r'^[0-9]{3}$',
                    },
                    'uic' : {
                        uic : r'^[\w\d]{5}$'
                    },
                    'period_from' : {
                        period_from : r'^[0-9]{8}$'
                    },
                    'period_to' : {
                        period_to : r'^[0-9]{8}$'
                    },
                    'ssn' : {
                        ssn : r'^[0-9]{9}$'
                    }
                }
                try:
                    self._validate_variables(variables=dict_variables_patterns)
                except:
                    continue
                order_number = '{}-{}'.format(order_number[0:3], order_number[3:6])
                soldier_uid = self._generate_uid(plain_text=ssn)
                name = self._determine_names(name=sub('\W', '_', line[15:37].strip()))
                year = self._determine_year(year=year[0:2])
                document_uid = self._generate_uid(plain_text=ssn + order_number + year)
                main_order = self._parse_main_file(main_order_file=self.current_orders_files[self.current_orders_number]['main_order_file'], order_number=order_number)
                certificate_order = self._parse_certificate_file(certificate_order_file=self.current_orders_files[self.current_orders_number]['certificate_order_file'], order_number=line[:6])
                ''' Append order_info dictionary to self._results dictionary of lists '''
                order_info['order_number'] = order_number
                order_info['year'] = year
                order_info['name'] = '_'.join(str(x) for x in name.values())
                order_info['fname'] = name['fname']
                order_info['mname'] = name['mname']
                order_info['lname'] = name['lname']
                order_info['format'] = format
                order_info['uic'] = uic
                order_info['period_from'] = period_from
                order_info['period_to'] = period_to
                order_info['soldier_uid'] = soldier_uid
                order_info['document_uid'] = document_uid
                order_info['main_order'] = main_order
                order_info['certificate_order'] = certificate_order
                order_info['directory_uics'] = join(self.config['DIRECTORIES']['UICS'], uic, '{}___{}'.format(order_info['name'], soldier_uid))
                order_info['directory_ord_managers'] = join(self.config['DIRECTORIES']['ORDERS_BY_SOLDIER'], '{}___{}'.format(order_info['name'], soldier_uid))
                order_info['order_file_main'] = '{}___{}___{}___{}___{}.{}'.format(year, order_number, period_from, period_to, format, self.config['ORDERS']['EXTENSION'])
                order_info['link_uics_main'] = join(order_info['directory_uics'], order_info['order_file_main'])
                order_info['link_ord_managers_main'] = join(order_info['directory_ord_managers'], order_info['order_file_main'])
                order_info['order_file_certificate'] =  '{}___{}___{}___{}___{}.{}'.format(year, order_number, period_from, period_to, 'cert', self.config['ORDERS']['EXTENSION'])
                order_info['link_uics_certificate'] = join(order_info['directory_uics'], order_info['order_file_certificate'])
                order_info['link_ord_managers_certificate'] = join(order_info['directory_ord_managers'], order_info['order_file_certificate'])
                self._results[self.line_number].append(order_info)

    def _validate_variables(self, variables):
        for key, value in variables.items():
            for v in value.items():
                if key == 'ssn':
                    debug('Validating [{}] against pattern [{}].'.format(key, v[1]))
                else:
                    debug('Validating [{}] [{}] against pattern [{}].'.format(key, v[0], v[1]))
                if not match(v[1], v[0]):
                    critical('Line [{}] in [{}] value [{}] does not match pattern [{}] for [{}]'.format(self.line_number, self.current_orders_files[self.current_orders_number]['registry_file'], v[0], v[1], key))
                    # raise VariableValidationError

    def _generate_uid(self, plain_text):
        ''' Generated using str(uuid.uuid4()) on 2/23/2018 @ 1000 '''
        salt = 'd86d4265-842e-4a4a-b9d8-e6a6961bcfab'
        uid = (md5(salt.encode() + plain_text.encode()).hexdigest())[:10]
        return uid

    def _determine_names(self, name):
        names = {
            'lname' : '',
            'mname' : '',
            'fname' : ''
        }
        if len(name) > 0:
            if len(name.split('_')) == 3:
            	names['lname'] = name.split('_')[0]
            	names['fname'] = name.split('_')[1]
            	names['mname'] = name.split('_')[2]
            elif len(name.split('_')) == 2:
            	names['lname'] = name.split('_')[0]
            	names['fname'] = name.split('_')[1]
            	names['mname'] = '#'
        if len(names) != 3:
            critical('Line [{}] in [{}] unable to determine name from [{}].'.format(self.line_number, self.current_orders_files[self.current_orders_number]['registry_file'], name))
            # raise NameDeterminationError
        else:
            return names

    def _determine_year(self, year):
        if year.startswith('7'):
        	year = '19{}'.format(year)
        elif year.startswith('8'):
        	year = '19{}'.format(year)
        elif year.startswith('9'):
        	year = '19{}'.format(year)
        else:
        	year = '20{}'.format(year)        
        if len(year) != 4:
            critical('Line [{}] in [{}] unable to determine year from [{}].'.format(self.line_number, self.current_orders_files[self.current_orders_number]['registry_file'], year))
            # raise YearDeterminationError
        else:
            return year

    def _determine_period_year(self, period_year):
        if match(r'^[0-9]{6}$', period_year):
        	if period_year.startswith('7'):
        		period_year = '19{}'.format(period_year)
        	elif period_year.startswith('8'):
        		period_year = '19{}'.format(period_year)
        	elif period_year.startswith('9'):
        		period_year = '19{}'.format(period_year)
        	else:
        		period_year = '20{}'.format(period_year)
        if len(period_year) != 8:
            critical('Line [{}] in [{}] unable to determine period_year from [{}].'.format(self.line_number, self.current_orders_files[self.current_orders_number]['registry_file'], period_year))
            # raise PeriodYearDeterminationError
        else:
            return period_year

    def _parse_main_file(self, main_order_file, order_number):
        debug('Parsing [{}] for [{}].'.format(main_order_file, order_number))
        with open(main_order_file, 'r') as main_file:
            main_orders = main_file.read()
            ''' Create list by splitting orders with main_order_file using line break (\f) as delimiter '''
            main_orders = [ x + '\f' for x in main_orders.split('\f') ]
            ''' Look for orders containing order_number in main_orders list '''
            main_order = [ y for y in main_orders if order_number in y ]
            ''' Turn main_order list into main_order string to remove the comma between list values '''
            main_order = ''.join(main_order)
            ''' Remove last line '\f' from main_order to make printing work '''
            main_order = main_order[:main_order.rfind('\f')]
            if not main_order:
                warning('Line [{}] in [{}] unable to find valid main order for [{}] in [{}].'.format(self.line_number, self.current_orders_files[self.current_orders_number]['registry_file'], order_number, main_order_file))
            else:
                return main_order

    def _parse_certificate_file(self, certificate_order_file, order_number):
        debug('Parsing [{}] for [{}].'.format(certificate_order_file, order_number))
        with open(certificate_order_file, 'r') as certificate_file:
            certificate_orders = certificate_file.read().split('\f')
            certificate_order_regex = 'Order number: {}'.format(order_number)
            certificate_order = [ y for y in certificate_orders if certificate_order_regex in y ]
            certificate_order = ''.join(certificate_order)
            if not certificate_order:
                warning('Line [{}] in [{}] unable to find valid certificate order for [{}] from [{}].'.format(self.line_number, self.current_orders_files[self.current_orders_number]['registry_file'], order_number, certificate_order_file))
            else:
                return certificate_order

class ElasticsearchManager:
    def __init__(self, results, host, port):
        self.results = results
        self.host = host
        self.port = port

    def _validate_host(self):
        debug('Validating host [{}].'.format(self.host))
        try:
        	ip_address(self.host)
        except ValueError:
        	critical('Improper IP address [{}]. Try again with a proper IP address.'.format(self.host))
        	raise InvalidHostError

    def _validate_port(self):
        debug('Validating port [{}]'.format(self.port))
        ''' Regex to match only numeric ports 0-65535 '''
        if not match(r'^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$', self.port):
            critical('Improper port [{}]. Try again with a proper port.'.format(self.port))
            raise InvalidPortError

    def _validate_host_connection(self):
        debug('Validating connection to [{}].'.format(self.host))
        if urlopen('http://{}:{}'.format(self.host, self.port)).getcode() != 200:
            critical('Unable to reach host [{}]. Ensure host [{}] is up and accepting requests on port [{}].'.format(self.host, self.port, self.port))
            raise UnableToReachElasticsearchHostError

    def _connect_to_host(self):
        self.es = Elasticsearch([{'host' : self.host, 'port' : self.port}])

    def _validate_index_existence(self, index_name):
        self.index_name = index_name
        debug('Validating index [{}] existence in Elasticsearch.'.format(self.index_name))
        if self.es.indices.exists(index=self.index_name) == False:
            info('Index [{}] does NOT exist. Creating now.'.format(self.index_name))
            self._define_index()
            self._create_index()

    def _define_index(self):
        self.index_settings = {
        	"settings" : {
        		"number_of_shards" : 1,
        		"number_of_replicas" : 0
        	},
          "mappings": {
            "_doc": {
        	  "dynamic": "strict",
              "properties": {
        		"order_number" : { "type": "text" },
        		"year" : { "type": "keyword" },
                "name" : { "type" : "text" },
                "fname" : { "type" : "text" },
                "mname" : { "type" : "text" },
                "lname" : { "type" : "text" },
        		"format" : { "type": "keyword" },
        		"uic" : { "type" : "text" },
        		"period_from" : { "type": "date", "format": "basic_date" },
        		"period_to" : { "type": "date", "format": "basic_date" },
        		"soldier_uid" : { "type": "keyword" },
                "document_uid" : { "type": "keyword" },
        		"main_order" : { "type": "text" },
                "certificate_order" : { "type": "text" },
                "directory_uics" : { "type": "text" },
                "directory_ord_managers" : { "type": "text" },
        		"order_file_main" : { "type": "text" },
                "link_uics_main" : { "type": "text" },
                "link_ord_managers_main" : { "type": "text" },
                "order_file_certificate" : { "type": "text" },
                "link_uics_certificate" : { "type": "text" },
                "link_ord_managers_certificate" : { "type": "text" },
              }
            }
          }
        }

    def _create_index(self):
        index_creation_result = self.es.indices.create(index=self.index_name,  body=self.index_settings)
        if not index_creation_result['acknowledged'] == True:
            critical('Unexpected response during index [{}] creation. Response was [{}].'.format(self.index_name, index_creation_result['acknowledged']))
            raise UnexpectedResultCreatingIndexError

    def _add_data(self):
        for key in self.results.keys():
            for order in self.results[key]:
                json_data = order
                ''' Add individual order json data to Elasticseach index '''
                debug('Adding order number [{}] from year [{}] to index [{}].'.format(order['order_number'], order['year'], self.index_name))
                result_add_data = self.es.index(index=self.index_name, doc_type='_doc', id=order['document_uid'], body=json_data)
                if result_add_data['result'] != 'created' and result_add_data['result'] != 'updated':
                    critical('Did not receive response of created or updated when trying to add order number [{}] from [{}]. Respone was [{}]. Investigate immediately.'.format(order['order_number'], order['year'], result_add_data['result']))
                    raise FailedToAddDataToElasticsearchIndexError

class DirectoryManager:
    def __init__(self, directories):
        self.directories = directories

    def _create_directories(self):
        for directory in self.directories:
            if not exists(directory):
                debug('Creating directory [{}].'.format(directory))
                makedirs(directory)

    def _remove_directories(self):
        for directory in self.directories:
            if exists(directory):
                debug('Removing directory [{}].'.format(directory))
                rmtree(directory)

class OrderFileManager:
    def __init__(self, config_file, config):
        self.config_file = config_file
        self.config = config

    def _archive_orders(self, orders_number, orders):
        ''' This method requires a list of full path orders to archive '''
        debug('Archiving orders number [{}] files.'.format(orders_number))
        for order in orders:
            debug('Moving [{}] to [{}].'.format(order, self.config['DIRECTORIES']['ARCHIVE']))
            move(order, self.config['DIRECTORIES']['ARCHIVE'])

    def _move_mising_orders(self, orders_number, orders):
        ''' This method requires a list of full path orders to archive '''
        debug('Moving orders number [{}] files to [{}].'.format(orders_number, self.config['DIRECTORIES']['MISSING_FILES']))
        for order in orders:
            debug('Moving [{}] to [{}].'.format(order, self.config['DIRECTORIES']['MISSING_FILES']))
            move(order, self.config['DIRECTORIES']['MISSING_FILES'])

    def _create_orders_doc(self, results):
        ''' This method requires full results instead of a list '''
        ''' Gather a list of dictionaries containing the following keys with their corresponding values '''
        list_keys_to_find = [ 'main_order', 'certificate_order', 'directory_uics', 'directory_ord_managers', 'order_file_main', 'order_file_certificate' ]
        list_orders_to_create = ResultsParser(results=results, keys=list_keys_to_find)._look_for_keys()

        ''' Create word documents utilizing list of dictionaries list_orders_to_create '''
        for order in list_orders_to_create:
            if order['main_order'] != None:
                with open(join(order['directory_uics'], order['order_file_main']), 'a') as f:
                    f.write(order.get('main_order'))
                with open(join(order['directory_ord_managers'], order['order_file_main']), 'w') as f:
                    f.write(order.get('main_order'))
            if order['certificate_order'] != None:
                with open(join(order['directory_uics'], order['order_file_certificate']), 'w') as f:
                    f.write(order.get('certificate_order'))
                with open(join(order['directory_ord_managers'], order['order_file_certificate']), 'w') as f:
                    f.write(order.get('certificate_order'))

    def _combine_orders(self, results):
        list_keys_to_find = [ 'main_order' ]
        list_orders_to_combine = ResultsParser(results=results, keys=list_keys_to_find)._look_for_keys()
        pprint(list_orders_to_combine)
        exit()

class ConfigurationFileManager:
    def __init__(self, config_file, config, section, option, value):
        self.config = config
        self.config_file = config_file
        self.section = section
        self.option = option
        self.value = value

    def _update_value(self):
        debug('Updating configuration file [{}] section [{}] option [{}] to [{}].'.format(self.config_file, self.section, self.option, self.value))
        self.config['{}'.format(self.section)]['{}'.format(self.option)] = self.value
        with open(self.config_file, 'w') as file:
            self.config.write(file)

class ResultsParser:
    def __init__(self, results, keys):
        self.results = results
        self.keys = keys

    def _look_for_keys(self):
        ''' Method requires dictionary results from AfcosParser and list of keys to look for. It return a list of dictionaries. '''
        debug('Parsing results for keys {}.'.format(self.keys))
        self.list_results = []
        for key in self.results.keys():
            for order in self.results[key]:
                d = {}
                for x in self.keys:
                    d[x] = order[x]
            self.list_results.append(d)
        return self.list_results

def _watchdog(config_file, config):
    ''' Monitor configuration file input directory for any new order files. '''
    monitor = AfcosMonitor(directory_input=config['DIRECTORIES']['INPUT'])
    monitor._check_orders_directory()
    monitor._count_current_orders()
    monitor._get_current_orders_number()
    monitor._compare_orders_numbers(last_orders_number=config['LASTRUN']['NUMBER'])
    current_orders_files = monitor._gather_current_orders_files()
    if monitor.files_found == 4:
        if config['ACTIONS']['CREATE_ORDERS_IN_ELASTICSEARCH'] == 'True' or config['ACTIONS']['CREATE_ORDERS_IN_OUTPUT_DIRECTORY'] == 'True':
            ''' Parse new files in configuration file input directory when new order files are present. '''
            parser = AfcosParser(current_orders_files=current_orders_files, config_file=config_file, config=config)
        else:
            critical('Missing a required True value in [{}] under [ACTIONS] for create_orders_in_elasticsearch or create_orders_in_output_directory. At least one much be specified, both may be specified.'.format(config_file))
            raise NoConfigFileActionSpecified

        if config['ACTIONS']['CREATE_ORDERS_IN_ELASTICSEARCH'] == 'True':
            ''' API data into Elasticsearch '''
            elasticsearch = ElasticsearchManager(results=parser._results, host=config['ELASTICSEARCH']['HOST'], port=config['ELASTICSEARCH']['PORT'])
            elasticsearch._validate_host()
            elasticsearch._validate_port()
            elasticsearch._validate_host_connection()
            elasticsearch._connect_to_host()
            elasticsearch._validate_index_existence(index_name=config['ELASTICSEARCH']['INDEX_NAME'])
            elasticsearch._add_data()

        if config['ACTIONS']['CREATE_ORDERS_IN_OUTPUT_DIRECTORY'] == 'True':
            ''' Create parsed output directories in config file output directory '''
            list_keys_to_find = [ 'directory_uics', 'directory_ord_managers' ]
            list_directories_to_create = sorted(list(set([ order[x] for key in parser._results.keys() for order in parser._results[key] for x in list_keys_to_find ])))
            directorymanager = DirectoryManager(directories=list_directories_to_create)
            directorymanager._create_directories()

            if config['ORDERS']['EXTENSION'] == 'doc':
                try:
                    if len(parser._results[next(iter(parser._results))]) > 0:
                        filemanager = OrderFileManager(config_file=config_file, config=config)
                        filemanager._create_orders_doc(results=parser._results)
                    else:
                        critical('Line [{}] in [{}] does not contain enough parsed results to create proper order documents.'.format(next(iter(parser._results)), parser.current_orders_files[parser.current_orders_number]['registry_file']))
                except:
                    critical('Zero results came back from [{}]. Check to make sure this batch of order files has data.'.format(parser.current_orders_files[parser.current_orders_number]['registry_file']))
            else:
                critical('Missing a required value [doc] in [{}] under [ORDERS] for extension. At least one must be specified.'.format(config_file))
                raise NoConfigFileActionSpecified

        if config['ACTIONS']['COMBINE_ORDERS_FOR_IPERMS_INTEGRATOR'] == 'True':
            filemanager._combine_orders(results=parser._results)

        if config['ACTIONS']['ARCHIVE_ORDERS'] == 'True':
            ''' Move orders parsed from configuration file input directory to configuration file archive directory '''
            list_orders_to_archive = [v for key, value in parser.current_orders_files.items() for v in value.values()]
            filemanager = OrderFileManager(config_file=config_file, config=config)
            filemanager._archive_orders(orders_number=parser.current_orders_number, orders=list_orders_to_archive)

        ''' Update configuration file lastrun number '''
        ConfigurationFileManager(config_file=config_file, config=config, section='LASTRUN', option='NUMBER', value=parser.current_orders_number)._update_value()
    else:
        ''' Batch is missing required file(s). '''
        list_orders_to_move = [ v for key in monitor.current_orders_files.keys() for k, v in monitor.current_orders_files[key].items() ]
        OrderFileManager(config_file=config_file, config=config)._move_mising_orders(orders_number=monitor.current_orders_number, orders=list_orders_to_move)

def _sleep(config):
    ''' Wait configuration file monitoring time before checking for new orders. '''
    debug('Sleeping [{}] seconds.'.format(config['MONITORING']['SECONDS']))
    sleep(int(config['MONITORING']['SECONDS']))

def main():
    ''' Validate configuration file presence and read in configuration values. '''
    config_file = 'ordpro.conf'
    if not isfile(config_file):
        critical('Missing required configuration file [{}]. Unable to continue.'.format(config_file))
        exit()
    config = ConfigParser(interpolation=ExtendedInterpolation())
    config.read(config_file)

    ''' Perfrom sanity checks on configuration file to ensure no conflicts in settings and all settings have expected/required values '''

    ''' Create required directories. '''
    list_directories_to_create = [ 
        config['DIRECTORIES']['OUTPUT'],
        config['DIRECTORIES']['LOG'],
        config['DIRECTORIES']['UICS'],
        config['DIRECTORIES']['ORD_MANAGERS'],
        config['DIRECTORIES']['ORD_REGISTERS'],
        config['DIRECTORIES']['IPERMS_INTEGRATOR'],
        config['DIRECTORIES']['ORDERS_BY_SOLDIER'],
        config['DIRECTORIES']['ARCHIVE'],
        config['DIRECTORIES']['MISSING_FILES']
        ]
    DirectoryManager(directories=list_directories_to_create)._create_directories()

    ''' Setup logging from configuration file logging settings '''
    basicConfig(filename=config['LOGGING']['FILE'], level=config['LOGGING']['LEVEL'], format='%(asctime)s - %(levelname)s - %(message)s')

    ''' Infinite loop to monitor, process orders, sleeping N time between checks based on value in configuration file. '''
    while True:
        try:
            _watchdog(config_file=config_file, config=config)
        except OrdersDoNotExistError:
            _sleep(config)
        except OrdersNumberPatternError:
            _sleep(config)
        except OrdersNumberEqualError:
            _sleep(config)
        except MissingRequiredOrdersFilesError:
            _sleep(config)
        except VariableValidationError:
            _sleep(config)
        except NameDeterminationError:
            _sleep(config)
        except YearDeterminationError:
            _sleep(config)
        except PeriodYearDeterminationError:
            _sleep(config)
        except InvalidHostError:
            _sleep(config)
        except InvalidPortError:
            _sleep(config)
        except UnableToReachElasticsearchHostError:
            _sleep(config)
        except UnexpectedResultCreatingIndexError:
            _sleep(config)
        except FailedToAddDataToElasticsearchIndexError:
            _sleep(config)
        except NoConfigFileActionSpecified:
            _sleep(config)

if __name__ == '__main__':
	main()
