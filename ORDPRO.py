#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse, os, logging, glob, sys, fnmatch, re, time, csv, timeit
from time import gmtime, strftime
from pprint import pprint

class Order:
	'''
	Class for all orders processed
	'''		

	orders_to_combine = []
	
	def ParseArguments(self):
		'''
		CREATE ARGUMENT PARSER
		'''
		parser = argparse.ArgumentParser(description="Script to process orders from AFCOS.")
		
		'''
		POSITIONAL MANDATORY ARGUMENTS
		'''
		parser.add_argument("i", help="input directory", type=str)
		parser.add_argument("o", help="output directory", type=str)
		
		'''
		OPTIONAL ARGUMENTS
		'''
		parser.add_argument('--verbose', '-v', action="store_true", help="enable detailed script verbosity")
		parser.add_argument('--combine', '-c', action="store_true", help="combine main order files")
		
		'''
		PRINT VERSION
		'''
		parser.add_argument("--version", action="version", version='%(prog)s - Version 2.6. Check https://gitlab.com/ajhanisch/ORDPRO for the most up to date information.')
		
		args = parser.parse_args()
		
		return args
		
	def SetVariables(self):	
		args = Order().ParseArguments()
		
		self.current_directory_working = os.getcwd()
		self.log_directory_working = "{}\\LOGS".format(self.current_directory_working)
		
		self.script_name = os.path.basename(__file__)
		self.run_date = strftime("%Y-%m-%d_%H-%M-%S", gmtime())
		self.log_file = "{}\\{}_ORDPRO.log".format(self.log_directory_working, self.run_date)

		self.uics_directory_output = "{}\\UICS".format(args.o)
		self.ordmanagers_directory_output = "{}\\ORD_MANAGERS".format(args.o)
		self.ordmanagers_orders_by_soldier_output = "{}\\ORDERS_BY_SOLDIER".format(self.ordmanagers_directory_output)
		self.ordmanagers_iperms_integrator_output = "{}\\IPERMS_INTEGRATOR".format(self.ordmanagers_directory_output)

		self.directories = { 'CURRENT_DIRECTORY_WORKING': self.current_directory_working, 'LOG_DIRECTORY_WORKING': self.log_directory_working, 'UICS_DIRECTORY_OUTPUT': self.uics_directory_output, 'ORDMANAGERS_DIRECTORY_OUTPUT': self.ordmanagers_directory_output, 'ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT': self.ordmanagers_orders_by_soldier_output, 'ORDMANAGERS_IPERMS_INTEGRATOR_OUTPUT': self.ordmanagers_iperms_integrator_output }
		
		self.variables = { 'SCRIPT_NAME': self.script_name, 'RUN_DATE': self.run_date, 'LOG_FILE': self.log_file }
		
		return self.directories, self.variables
		
	def CreateDirectory(self, directory):		
		self.directory = directory	
		
		if not os.path.exists(self.directory): 
			log.debug("{} doesn't exist. Creating now.".format(self.directory))			
			os.makedirs("{}".format(self.directory))
	
	def CreateOrder(self, directory, order_file, order):
		self.directory = directory
		self.order_file = order_file
		self.order = order
		
		if not os.path.exists("{}\\{}".format(self.directory, self.order)): 
			log.debug("{}\\{} does not exist. Creating now.".format(self.directory, self.order_file))
			with open("{}\\{}".format(self.directory, self.order_file), 'w') as f:
				f.write(self.order)
				
			if 'UICS' in self.directory and '__cert.doc' not in self.order_file and self.order_file not in Order().orders_to_combine:
				Order().orders_to_combine.append("{}\\{}".format(self.directory, self.order_file))
				
	def CombineOrders(self, orders_to_combine, year):
		self.orders_to_combine = orders_to_combine
		self.year = year
		
		self.known_bad_strings = ["                          FOR OFFICIAL USE ONLY - PRIVACY ACT", "                          FOR OFFICIAL USE ONLY - PRIVACY ACT", "ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}", "`f"]
		
		log.info("Combining orders now.")
		self.order_files = self.orders_to_combine[:250]
		self.order_files_count = len(self.order_files)
		self.order_files_processed = []
		self.start = 1
		self.end = len(self.order_files)
		
		while len(self.order_files) != 0:
			self.out_file = "{}\\{}\\{}_{}-{}.doc".format(self.ordmanagers_iperms_integrator_output, self.run_date, self.year, self.start, self.end)
			
			if not os.path.exists("{}\\{}".format(self.ordmanagers_iperms_integrator_output, self.run_date)):
				os.makedirs("{}\\{}".format(self.ordmanagers_iperms_integrator_output, self.run_date))
			
			if not os.path.exists(self.out_file):
				with open(self.out_file, 'w') as f:
					f.write(self.out_file)
			
			# Combine 250 file batches
			with open("{}".format(self.out_file), 'w') as f:
				for fname in self.order_files:
					with open(fname) as infile:
						if "_cert.doc" not in fname:
							f.write(infile.read())
							self.order_files_processed.append(fname)
				
			# Edit file to remove bad strings
			for s in self.known_bad_strings:
				with open(self.out_file, 'r') as f:
					f_data = f.read()
					pattern = re.compile(s)
					f_data = pattern.sub('', f_data)
					with open(self.out_file, 'w') as f:
						f.write(f_data)
			
			# Repopultae list
			self.order_files = []
			for fname in self.orders_to_combine:
				if fname not in self.order_files_processed:
					self.order_files.append(fname)
			self.order_files = self.order_files[:250]
			self.start = self.end + 1
			self.end = self.start + len(self.order_files) - 1
		
		log.info("Finished combining orders.")
		
'''
ENTRY POINT
'''
if __name__ == '__main__':
	o = Order()
	args = o.ParseArguments()
	
	if args.i and args.o:	
		
		start = time.strftime('%m-%d-%y %H:%M:%S')
		start_time = timeit.default_timer()
		
		directories, variables = o.SetVariables() # Accessed via directories['DIRECTORY'] || variables['VARIABLE']
		
		files_processed = 0
		lines_processed = 0
		orders_main_count = 0
		orders_main_missing_count = 0
		orders_cert_count = 0
		orders_cert_missing_count = 0
		warning_count = 0
		error_count = 0
		
		orders_missing_files = {}
		orders_missing_files_csv = "{}\\{}_missing_files.csv".format(directories['LOG_DIRECTORY_WORKING'], variables['RUN_DATE'])
		
		for key, value in directories.items():
			if not os.path.exists(value):
				os.makedirs(value)
		
		'''
		ENABLE/DISABLE VERBOSITY
		More logging info here https://docs.python.org/3/library/logging.html#module-logging
		'''
		if args.verbose:
			print("Verbose flag specified. Printing output to screen AND log file.")
			# Log file requirements
			log = logging.getLogger('')
			log.setLevel(logging.DEBUG) # Access via log.LEVEL('MESSAGE') Levels include debug, info, warning, error, critical.
			format_log = logging.Formatter("[%(asctime)s] - [%(levelname)s] - %(message)s")			
			handler_file = logging.FileHandler(variables['LOG_FILE'])
			handler_file.setFormatter(format_log)			
			logger_root = logging.getLogger()
			logger_root.addHandler(handler_file)			
			# Console requirements
			handler_console = logging.StreamHandler()
			handler_console.setFormatter(format_log)
			logger_root.addHandler(handler_console)
		else:
			print("Verbose flag not specified. NOT printing to screen, ONLY log file.")
			# Log file requirements
			log = logging.getLogger('')
			log.setLevel(logging.DEBUG) # Access via log.LEVEL('MESSAGE') Levels include debug, info, warning, error, critical.
			format_log = logging.Formatter("[%(asctime)s] - [%(levelname)s] - %(message)s")
			handler_file = logging.FileHandler(variables['LOG_FILE'])
			handler_file.setFormatter(format_log)
			logger_root = logging.getLogger()
			logger_root.addHandler(handler_file)
				
		log.info("You are running {} with the following arguments: ".format(variables['SCRIPT_NAME']))
		for a in args.__dict__:
			log.info(str(a) + ": " + str(args.__dict__[a]))
				
		for f in glob.glob("{}\\*r.reg".format(args.i)):
			files_processed += 1			
			if sys.platform == 'win32': # windows
				f = f.split('\\')[-1]
			elif sys.platform == 'darwin': # os x
				f = f.split('//')[-1]
			elif sys.platform == 'linux' or sys.platform == 'linux2': # linux
				f = f.split('//')[-1]
				
			result = { 'ORDER_FILE_REG' : '', 'ORDER_FILE_MAIN' : '', 'ORDER_FILE_CERT' : '', 'ORDER_FILE_R_PRT' : ''}	
			order_n = f[3:9]
			pattern_main = "ord{}m.prt".format(order_n)
			pattern_cert = "ord{}c.prt".format(order_n)
			pattern_reg = "reg{}r.reg".format(order_n)
			pattern_reg_prt = "reg{}r.prt".format(order_n)
		
			for root, dirs, files in os.walk(args.i):
				for name in files:
					if pattern_main in name:
						result['ORDER_FILE_MAIN'] = "{}\\{}".format(root, name)
					elif pattern_cert in name:
						result['ORDER_FILE_CERT'] = "{}\\{}".format(root, name)
					elif pattern_reg_prt in name:
						result['ORDER_FILE_R_PRT'] = "{}\\{}".format(root, name)
					elif pattern_reg in name:
						result['ORDER_FILE_REG'] = "{}\\{}".format(root, name)
			
			if result['ORDER_FILE_REG'] and result['ORDER_FILE_MAIN'] and result['ORDER_FILE_CERT']:
				log.debug("Registry file found is [{}]. Main file found is [{}]. Cer file found is [{}].".format(result['ORDER_FILE_REG'], result['ORDER_FILE_MAIN'], result['ORDER_FILE_CERT']))
			else:
				error_count += 1				
				orders_missing_files[error_count] = []				
				log.error("Registry file found is [{}]. Main file found is [{}]. Cert file found is [{}].".format(result['ORDER_FILE_REG'], result['ORDER_FILE_MAIN'], result['ORDER_FILE_CERT']))				
				orders_missing_files[error_count].append(result)
				
			for key, value in result.items():
				if key == 'ORDER_FILE_REG':
					with open(value, 'r') as reg_file:
						for line in reg_file:
							lines_processed += 1							
							order_number = line[:3] + '-' + line[3:6]
							published_year = line[6:12]
							published_year = published_year[0:2]
							format = line[12:15]
							name = re.sub("\W", "_", line[15:37].strip())
							uic = line[37:42]
							period_from = line[48:54]
							period_to = line[54:60]
							ssn = line[60:63] + "-" + line[63:65] + "-" + line[64:68]
							
							if result['ORDER_FILE_MAIN']:
								order_m = ''
								with open(result['ORDER_FILE_MAIN'], 'r') as main_file:
									orders_m = main_file.read().split("\f")						
									order_regex_1 = "ORDERS {}".format(order_number)
									order_regex_2 = "ORDERS  {}".format(order_number)
									for order in orders_m:
										if order_regex_1 in order:
											order_m += order
										elif order_regex_2 in order:
											order_m += order
								if order_m:
									orders_main_count += 1								
									log.info("Found valid main order for {} {} order number {}.".format(name, ssn, order_number))
									
									uic_directory = "{}\\{}".format(directories['UICS_DIRECTORY_OUTPUT'], uic)
									soldier_directory_uics = "{}\\{}___{}".format(uic_directory, name, ssn)
									uic_soldier_order_file_name_main = "{}___{}___{}___{}___{}___{}.doc".format(published_year, ssn, order_number, period_from, period_to, format)
									ord_managers_soldier_directory = "{}\\{}___{}".format(directories['ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT'], name, ssn)
									
									o.CreateDirectory(soldier_directory_uics)
									o.CreateDirectory(ord_managers_soldier_directory)
									o.CreateOrder(soldier_directory_uics, uic_soldier_order_file_name_main, order_m)
									o.CreateOrder(ord_managers_soldier_directory, uic_soldier_order_file_name_main, order_m)
								else:
									error_count += 1
									orders_main_missing_count += 1
									log.error("Failed to find main order for {} {} order number {}.".format(name, ssn, order_number))
							else:
								error_count += 1
								log.error("Missing main order file for {} {} order number {}.".format(name, ssn, order_number))
									
							if result['ORDER_FILE_CERT']:
								order_c = ''
								with open(result['ORDER_FILE_CERT'], 'r') as cert_file:
									orders_c = cert_file.read().split("\f")						
									order_regex = "Order number: {}".format(line[0:6])
									for order in orders_c:
										if order_regex in order:
											order_c += order
								if order_c:
									orders_cert_count += 1								
									log.info("Found valid cert order for {} {} order number {}.".format(name, ssn, order_number))
									
									uic_directory = "{}\\{}".format(directories['UICS_DIRECTORY_OUTPUT'], uic)
									soldier_directory_uics = "{}\\{}___{}".format(uic_directory, name, ssn)
									uic_soldier_order_file_name_cert = "{}___{}___{}___{}___{}___cert.doc".format(published_year, ssn, order_number, period_from, period_to)
									ord_managers_soldier_directory = "{}\\{}___{}".format(directories['ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT'], name, ssn)
									
									o.CreateDirectory(soldier_directory_uics)
									o.CreateDirectory(ord_managers_soldier_directory)	
									o.CreateOrder(soldier_directory_uics, uic_soldier_order_file_name_cert, order_c)
									o.CreateOrder(ord_managers_soldier_directory, uic_soldier_order_file_name_cert, order_c)
								else:
									error_count += 1	
									orders_cert_missing_count += 1
									log.error("Failed to find cert order for {} {} order number {}.".format(name, ssn, order_number))
							else:
								error_count += 1
								orders_cert_missing_count += 1
								log.error("Missing cert order file for {} {} order number {}.".format(name, ssn, order_number))
		
	if args.combine:
		o.CombineOrders(o.orders_to_combine, published_year)
		
	if len(orders_missing_files) > 0:
		log.critical("Looks like we have some missing files. Writing missing files results to {} now. Check this file for full results.".format(orders_missing_files_csv))
		with open(orders_missing_files_csv, 'w') as out_file:
			writer = csv.writer(out_file)
			for key, value in orders_missing_files.items():
				writer.writerow([key, value])
				
	end = time.strftime('%m-%d-%y %H:%M:%S')
	end_time = timeit.default_timer()
	seconds = round(end_time - start_time)
	m, s = divmod(seconds, 60)
	h, m = divmod(m, 60)
	
	log.info('{:-^30}'.format(''))
	log.info('{:+^30}'.format('PROCESSING STATS'))
	log.info('{:-^30}'.format(''))
	log.info('{:16s} {:13d}'.format('Files processed:', files_processed))
	log.info('{:16s} {:13d}'.format('Files missing:', len(orders_missing_files)))
	log.info('{:16s} {:13d}'.format('Lines processed:', lines_processed))
	log.info('{:16s} {:13d}'.format('Main orders:', orders_main_count))
	log.info('{:16s} {:13d}'.format('Cert orders:', orders_cert_count))
	log.info('{:16s} {:13d}'.format('Missing main:', orders_main_missing_count))
	log.info('{:16s} {:13d}'.format('Missing cert:', orders_cert_missing_count))
	log.info('{:16s} {:11d}'.format('Warnings occurred:', warning_count))
	log.info('{:16s} {:13d}'.format('Errors occurred:', error_count))
	log.info('{:-^30}'.format(''))
	log.info('{:+^30}'.format('RUNNING STATS'))
	log.info('{:-^30}'.format(''))
	log.info('{:11s} {:8}'.format('Start time:', start))
	log.info('{:11s} {:10}'.format('End time:', end))
	log.info('{:11s} {:d}:{:d}:{:d}'.format('Run time: ', h, m, s))