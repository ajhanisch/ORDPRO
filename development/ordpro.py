#!python3
# -*- coding: utf-8 -*-

from sys import exit
from time import sleep
from shutil import move
from hashlib import md5
from re import match, sub
from fnmatch import fnmatch
from os import walk, sep, listdir, makedirs
from os.path import isdir, exists, isfile, join
from configparser import ConfigParser, ExtendedInterpolation

class Error(Exception):
    ''' Base class for other exceptions '''
    pass

class OrdersDoNotExistError(Error):
    ''' Raised when AfcosMonitor _check_orders_directory finds no order files in input directory and _count_current_orders comes back with no orders '''
    pass

class OrdersNumberPatternError(Error):
    ''' Raised when AfcosMonitor _get_current_orders_number is unable to match set order number pattern '''
    pass

class OrdersNumberEqualError(Error):
    ''' Raised when AfcosMonitor _compare_orders_numbers determines current and previous run of orders is the same '''
    pass

class MissingRequiredOrdersFilesError(Error):
    ''' Raised when AfcosMonitor _gather_current_orders_files is unable to gather all (4) required files in input directory '''
    pass

class VariableValidationError(Error):
    ''' Raised when AfcosParser _validate_variables is unable to match captured variables with required regex pattern '''
    pass

class NameDeterminationError(Error):
    ''' Raised when AfcosParser _determine_names is unable to determine first, middle, and last name  '''
    pass

class NoMainOrderFoundError(Error):
    ''' Raised when AfcosParser _parse_main_file is unable to locate a valid order within the ord*m.prt file '''
    pass

class NoCertificateOrderFoundError(Error):
    ''' Raised when AfcosParser _parse_certificate_file is unable to locate a valid order within the ord*c.prt file '''
    pass

class AfcosMonitor:
    def __init__(self, directory_input):
        self.directory_input = directory_input
        if self.directory_input == None or self.directory_input == '':
            print('[!] No directory specified!')
            exit()

    def _check_orders_directory(self):
        print('[-] Checking if any orders exist in [{}].'.format(self.directory_input))
        if exists(self.directory_input) and isdir(self.directory_input):
            if listdir(self.directory_input):
                print('\t[+] Orders exist in [{}].'.format(self.directory_input))
            else:
                print('\t[!] Orders DO NOT exist in [{}].'.format(self.directory_input))
                raise OrdersDoNotExistError
        else:
            print('\t[!] [{}] does not exist or is not a directory.'.format(self.directory_input))
            raise OrdersDoNotExistError

    def _count_current_orders(self):
        print('[-] Counting files in [{}].'.format(self.directory_input))
        self.count_orders = len(listdir(self.directory_input))
        if self.count_orders > 0:
            print('\t[+] [{}] has [{}] files.'.format(self.directory_input, self.count_orders))
        elif self.count_orders == 0:
            print('\t[!] [{}] has [{}] files.'.format(self.directory_input, self.count_orders))
            raise OrdersDoNotExistError

    def _get_current_orders_number(self):
        print('[-] Retrieving current orders number.')
        self.current_orders_number = listdir(self.directory_input)[0].split(sep)[-1][3:9]
        if match(r'^[0-9]{6}$', self.current_orders_number):
            print('\t[+] Current orders number is [{}].'.format(self.current_orders_number))
        else:
            print('\t[-] [{}] does not match required order number pattern.'.format(self.current_orders_number))
            raise OrdersNumberPatternError

    def _compare_orders_numbers(self, last_orders_number):
        print('[-] Comparing current order batch against previous order batch.')
        self.last_orders_number = last_orders_number
        if int(self.current_orders_number) == int(self.last_orders_number):
            print('\t[!] Current orders number [{}] is equal to last orders number [{}].'.format(self.current_orders_number, self.last_orders_number))
            raise OrdersNumberEqualError
        else:
            print('\t[+] Current orders number [{}] is NOT equal to last orders number [{}].'.format(self.current_orders_number, self.last_orders_number))

    def _gather_current_orders_files(self):
        print('[-] Gathering current orders number [{}] (4) required files to process.'.format(self.current_orders_number))
        files_found = 0
        self.current_orders_files = {}
        self.current_orders_files[self.current_orders_number] = {}
        for file in listdir(self.directory_input):
            if fnmatch(file, 'ord{}m.prt'.format(self.current_orders_number)):
                files_found += 1
                print('\t[+] [{}/4] Found main_order_file [{}]'.format(files_found, file))
                self.current_orders_files[self.current_orders_number]['main_order_file'] = join(self.directory_input, file)
            elif fnmatch(file, 'ord{}c.prt'.format(self.current_orders_number)):
                files_found += 1
                print('\t[+] [{}/4] Found certificate_order_file [{}]'.format(files_found, file))
                self.current_orders_files[self.current_orders_number]['certificate_order_file'] = join(self.directory_input, file)
            elif fnmatch(file, 'reg{}r.reg'.format(self.current_orders_number)):
                files_found += 1
                print('\t[+] [{}/4] Found registry_file [{}]'.format(files_found, file))
                self.current_orders_files[self.current_orders_number]['registry_file'] = join(self.directory_input, file)
            elif fnmatch(file, 'reg{}r.prt'.format(self.current_orders_number)):
                files_found += 1
                print('\t[+] [{}/4] Found registry_prt_file [{}]'.format(files_found, file))
                self.current_orders_files[self.current_orders_number]['registry_prt_file'] = join(self.directory_input, file)
        if files_found == 4:
            return self.current_orders_files
        else:
            print('[!] Unable to gather current orders number [{}] (4) required files to process.'.format(self.current_orders_number))
            print('[!] Found [{}/4] required files to process.'.format(files_found))
            raise MissingRequiredOrdersFilesError

class AfcosParser:
    def __init__(self, current_orders_files, config_file, config):
        self.current_orders_files = current_orders_files
        self.config_file = config_file
        self.config = config
        self.current_orders_number = list(self.current_orders_files.keys())[0]
        print('[-] Processing current orders number [{}]'.format(self.current_orders_number))
        ''' Dictionary to store all parsed results.'''
        self._results = {}
        ''' Process registry file. '''
        self._parse_registry_file(self.current_orders_files[self.current_orders_number]['registry_file'])

    def _parse_registry_file(self, registry_file):
        print('[-] Parsing [{}].'.format(registry_file))
        line_number = 0
        with open(registry_file, 'r') as regfile:
            for line in regfile:
                line_number += 1
                self._results[line_number] = {}
                order_number = line[:6]
                year = line[6:12]
                format = line[12:15]
                uic = sub('\W', '_', line[37:42].strip())
                period_from = line[48:54]
                period_to = line[54:60]
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
                        period_from : r'^[0-9]{6}$'
                    },
                    'period_to' : {
                        period_to : r'^[0-9]{6}$'
                    },
                    'ssn' : {
                        ssn : r'^[0-9]{9}$'
                    }
                }
                self._validate_variables(variables=dict_variables_patterns)
                order_number = '{}-{}'.format(order_number[0:3], order_number[3:6])
                uid = self._generate_uid(plain_text=ssn)
                name = self._determine_names(name=sub('\W', '_', line[15:37].strip()))
                year = self._determine_year(year=year[0:2])
                main_order = self._parse_main_file(main_order_file=self.current_orders_files[self.current_orders_number]['main_order_file'], order_number=order_number)
                certificate_order = self._parse_certificate_file(certificate_order_file=self.current_orders_files[self.current_orders_number]['certificate_order_file'], order_number=line[:6])
                self._results[line_number]['order_number'] = order_number
                self._results[line_number]['year'] = year
                self._results[line_number]['name'] = ' '.join(str(x) for x in name.values())
                self._results[line_number]['fname'] = name['fname']
                self._results[line_number]['mname'] = name['mname']
                self._results[line_number]['lname'] = name['lname']
                self._results[line_number]['format'] = format
                self._results[line_number]['uic'] = uic
                self._results[line_number]['period_from'] = period_from
                self._results[line_number]['period_to'] = period_to
                self._results[line_number]['uid'] = uid
                self._results[line_number]['main_order'] = main_order
                self._results[line_number]['certificate_order'] = certificate_order
        print('\t[+] Finished parsing [{}]'.format(registry_file))

    def _validate_variables(self, variables):
        for key, value in variables.items():
            for v in value.items():
                print('[-] Validating [{}] against pattern [{}].'.format(key, v[1]))
                if match(v[1], v[0]):
                    print('\t[+] [{}] matches pattern [{}].'.format(key, v[1]))
                else:
                    print('\t[!] [{}] does NOT match pattern [{}] for [{}].'.format(v[0], v[1], key))
                    raise VariableValidationError

    def _generate_uid(self, plain_text):
        salt = 'd86d4265-842e-4a4a-b9d8-e6a6961bcfab' # Generated using str(uuid.uuid4()) on 2/23/2018 @ 1000
        uid = (md5(salt.encode() + plain_text.encode()).hexdigest())[:10]
        return uid

    def _determine_names(self, name):
        names = {
            'fname' : '',
            'mname' : '',
            'lname' : ''
        }
        if len(name) > 0:
            if len(name.split('_')) == 3:
            	names['fname'] = name.split('_')[0]
            	names['lname'] = name.split('_')[1]
            	names['mname'] = name.split('_')[2]
            elif len(name.split('_')) == 2:
            	names['fname'] = name.split('_')[0]
            	names['lname'] = name.split('_')[1]
            	names['mname'] = '#'
            else:
                raise NameDeterminationError
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
        return year

    def _parse_main_file(self, main_order_file, order_number):
        print('[-] Parsing [{}] for [{}].'.format(main_order_file, order_number))
        with open(main_order_file, 'r') as main_file:
            main_orders = main_file.read()
            main_orders = [ x + '\f' for x in main_orders.split('\f') ]
            main_order = [ y for y in main_orders if order_number in y ]
            if main_order:
                print('\t[+] Found valid main order for [{}] in [{}].'.format(order_number, main_order_file))
                return main_order
            else:
                print('\t[!] Unable to find valid main order for [{}] in [{}].'.format(order_number, main_order_file))
                ''' raise NoMainOrderFoundError '''

    def _parse_certificate_file(self, certificate_order_file, order_number):
        print('[-] Parsing [{}] for [{}].'.format(certificate_order_file, order_number))
        with open(certificate_order_file, 'r') as certificate_file:
            certificate_orders = certificate_file.read().split('\f')
            certificate_order_regex = 'Order number: {}'.format(order_number)
            certificate_order = [ y for y in certificate_orders if certificate_order_regex in y ]
            if certificate_order:
                print('\t[+] Found valid certificate order for [{}] in [{}].'.format(order_number, certificate_order_file))
                return certificate_order
            else:
                print('\t[!] Unable to find valid certificate order for [{}] in [{}].'.format(order_number, certificate_order_file))
                ''' raise NoCertificateOrderFoundError '''

    def _archive_current_orders_files(self):
        print('[-] Archiving current orders number files [{}].'.format(self.current_orders_number))
        for key, value in self.current_orders_files.items():
            for v in value.values():
                move(v, self.config['DIRECTORIES']['ARCHIVE'])
                print('\t[+] Moved [{}] to [{}].'.format(v, self.config['DIRECTORIES']['ARCHIVE']))

    def _update_configuration_lastrun_number(self):
            print('[-] Updating configurations file LASTRUN number from: [{}] to: [{}].'.format(self.config['LASTRUN']['NUMBER'], self.current_orders_number))
            self.config['LASTRUN']['NUMBER'] = self.current_orders_number
            with open(self.config_file, 'w') as config_file:
                self.config.write(config_file)
            print('\t[+] Finished updating configurations file LASTRUN number.')

def _created_required_directories(config):
    '''
    Create required directories from setup.
    '''
    dict_directories = {
        'directories_log' : config['DIRECTORIES']['LOG'],
        'directories_output' : config['DIRECTORIES']['OUTPUT'],
        'directories_uics' : config['DIRECTORIES']['UICS'],
        'directories_ord_managers' : config['DIRECTORIES']['ORD_MANAGERS'],
        'directories_ord_registers' : config['DIRECTORIES']['ORD_REGISTERS'],
        'directories_iperms_integrator' : config['DIRECTORIES']['IPERMS_INTEGRATOR'],
        'directories_archive' : config['DIRECTORIES']['ARCHIVE']
    }
    for key, value in dict_directories.items():
    	if not exists(value):
    		makedirs(value)

def _sleep(config):
    ''' Wait configuration file monitoring time before checking for new orders. '''
    print('[-] Sleeping [{}] seconds.'.format(config['MONITORING']['SECONDS']))
    sleep(int(config['MONITORING']['SECONDS']))

def _watchdog(config_file, config):
    ''' Monitor configuration file input directory for any new order files. '''
    monitor = AfcosMonitor(config['DIRECTORIES']['INPUT'])
    monitor._check_orders_directory()
    monitor._count_current_orders()
    monitor._get_current_orders_number()
    monitor._compare_orders_numbers(last_orders_number=config['LASTRUN']['NUMBER'])
    current_orders_files = monitor._gather_current_orders_files()
    ''' Parse new files in configuration file input directory when new order files are present. '''
    parser = AfcosParser(current_orders_files=current_orders_files, config_file=config_file, config=config)
    ''' API data into Elasticsearch (Need separate class for Elasticsearch functions) '''
    ''' Put orders in output directory (Need separate class for Orders functions) '''
    ''' Move orders from configuration file input directory to configuration file archive directory '''
    parser._archive_current_orders_files()
    ''' Update configuration file lastrun number '''
    parser._update_configuration_lastrun_number()

def main():
    ''' Validate configuration file presence and read in configuration values. '''
    config_file = 'ordpro.conf'
    if not isfile(config_file):
        print('[!] Missing required configuration file [{}]. Unable to continue.'.format(config_file))
        exit()
    else:
        config = ConfigParser(interpolation=ExtendedInterpolation())
        config.read(config_file)
    ''' Create required directories. '''
    _created_required_directories(config)
    ''' Infinite loop to monitor and process orders, sleeping N time between checks based on value in configuration file. '''
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
        except NoMainOrderFoundError:
            _sleep(config)
        except NoCertificateOrderFoundError:
            _sleep(config)

if __name__ == '__main__':
	main()
