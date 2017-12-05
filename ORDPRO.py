#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import os
import logging
import glob
import sys
import fnmatch
import re
import time
import csv
import timeit
import shutil
from time import gmtime, strftime
from datetime import datetime

class Order:
	'''
	Class for all orders processed
	'''		

	orders_to_combine = []
	orders_removed = []
	inactive_removed = []
	active_not_removed = []
	auditing_empty_dirs_removed = []

	files_processed = 0
	lines_processed = 0
	orders_main_count = 0
	orders_main_missing_count = 0
	orders_cert_count = 0
	orders_cert_missing_count = 0
	warning_count = 0
	error_count = 0
	critical_count = 0
	orders_missing_files_count = 0
	orders_created_count = 0
	orders_removed_count = 0
		
	def processing_combine_orders(self, orders_to_combine, year):
		self.orders_to_combine = orders_to_combine
		self.year = year
		
		self.known_bad_strings = ["                          FOR OFFICIAL USE ONLY - PRIVACY ACT", "                          FOR OFFICIAL USE ONLY - PRIVACY ACT", "ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}", "\f"]
		
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
			
	def processing_create_order(self, directory, order_file, order):
		self.directory = directory
		self.order_file = order_file
		self.order = order
		
		if not os.path.exists("{}\\{}".format(self.directory, self.order_file)): 
			log.debug("{}\\{} does not exist. Creating now.".format(self.directory, self.order_file))
			with open("{}\\{}".format(self.directory, self.order_file), 'w') as f:
				f.write(self.order)
				
			#if 'UICS' in self.directory and '__cert.doc' not in self.order_file and self.order_file not in Order().orders_to_combine:
			if '__cert.doc' not in self.order_file and self.order_file not in Order().orders_to_combine:
				Order().orders_to_combine.append("{}\\{}".format(self.directory, self.order_file))
		else:
			log.debug("{}\\{} exists. Not creating.".format(self.directory, self.order_file))
			
	def processing_create_directory(self, directory):		
		self.directory = directory	
		
		if not os.path.exists(self.directory): 
			log.debug("{} doesn't exist. Creating now.".format(self.directory))			
			os.makedirs("{}".format(self.directory))
		else:
			log.debug("{} exists. Not creating.".format(self.directory))	
			
	def processing_remove_order(self, directory, order_file, order):
		self.directory = directory
		self.order_file = order_file
		self.order = order
		
		if os.path.exists("{}\\{}".format(self.directory, self.order_file)):
			log.debug("{}\\{} exists. Removing now.".format(self.directory, self.order_file))
			os.remove("{}\\{}".format(self.directory, self.order_file))
			if '___cert.doc' not in self.order_file and "{}\\{}".format(self.directory, self.order_file) not in Order().orders_removed:
				Order().orders_removed.append("{}\\{}".format(self.directory, self.order_file))
		else:
			Order().error_count += 1
			log.error("{}\\{} does not exist. Not removing.".format(self.directory, self.order_file))
			
	def auditing_cleanup(self, path):
		self.path = path
		
		self.auditing_directories, self.auditing_variables = Order().set_variables()
				
		self.current_year = str(datetime.now().year)[-2:]
		self.year_minus_one = str(datetime.now().year -1)[-2:]
		self.year_minus_two = str(datetime.now().year -2)[-2:]
		self.years_to_consider_active = ['{}'.format(self.current_year), '{}'.format(self.year_minus_one), '{}'.format(self.year_minus_two)]

		self.auditing_active_txt = '{}\\{}_active.txt'.format(self.auditing_directories['LOG_DIRECTORY_WORKING'], self.auditing_variables['RUN_DATE'])
		self.auditing_inactive_txt = '{}\\{}_inactive.txt'.format(self.auditing_directories['LOG_DIRECTORY_WORKING'], self.auditing_variables['RUN_DATE'])
		self.auditing_dirs_csv = '{}\\{}_directories.csv'.format(self.auditing_directories['LOG_DIRECTORY_WORKING'], self.auditing_variables['RUN_DATE'])
		self.auditing_empty_dirs_txt = '{}\\{}_empty_dirs.txt'.format(self.auditing_directories['LOG_DIRECTORY_WORKING'], self.auditing_variables['RUN_DATE'])
		
		self.directories_orders = []
		self.ssn = []
		
		if os.path.isdir(self.path):			
			# Create list of dictionaries containing directories and files of UICS directory and create list of ssn.
			for root, dirs, files, in os.walk('{}'.format(self.path)):
				for file in files:
					if file.endswith('.doc'):
						self.auditing_result = { 'SSN': root, 'ORDER': file }
						ssn = self.auditing_result['SSN'].split('\\')[-1].split('_')[-1]
						self.directories_orders.append(self.auditing_result)
						if ssn not in self.ssn:
							self.ssn.append(ssn)
				
			# Look for ssn in list within list of dictionaries. Determine active and inactive. If inactive, remove ssn directories in all UICS. If active, consolidate to most recent UIC folder.
			for ssn in self.ssn:
				self.active = [ y for y in self.directories_orders if ssn in y['SSN'] and y['ORDER'][0:2] in self.years_to_consider_active ]
						
				if len(self.active) > 0:
					log.info('{} appears to be ACTIVE.'.format(ssn))

					# Determine most recent order.
					ssn_most_recent_order = ''
					ssn_most_recent_dir = ''
					for i in self.active:
						if ssn_most_recent_order == '':
							ssn_most_recent_order = i['ORDER']
						else:					
							if i['ORDER'][0:2] >= ssn_most_recent_order[0:2] \
							or i['ORDER'][19:21] >= ssn_most_recent_order[19:21] \
							:
								ssn_most_recent_order = i['ORDER']
					
					ssn_most_recent_dir = i['SSN']
					ssn_most_recent_uic = ssn_most_recent_dir.split('\\')[4]
					log.info( 'Most recent order: {}. Most recent PATH is {}. Most recent UIC is {}.'.format(ssn_most_recent_order, ssn_most_recent_dir, ssn_most_recent_uic) )
						
					# Move self.active to the most recent SSN directory.
					source_directories = set([ z['SSN'] for z in self.directories_orders if ssn_most_recent_dir not in z['SSN'] and ssn in z['SSN'] ])
					destination_directory = ssn_most_recent_dir	

					for dir in source_directories:
						source_files = os.listdir(dir)					
						for source_file in source_files:
							log.info('Moving {} to {}.'.format(source_file, destination_directory))
							shutil.move('{}\{}'.format(dir, source_file), destination_directory)
						
					for dir in self.active:
						Order().active_not_removed.append('{}\{}'.format(dir['SSN'], dir['ORDER']))
				else:
					self.inactive = [ x for x in self.directories_orders if ssn in x['SSN'] and x['ORDER'][0:2] not in self.years_to_consider_active ]
					
					if len(self.inactive) > 0:
						log.info('{} appears to be INACTIVE. Removing {} from any/all UICS.'.format(ssn, ssn))
						for dir in self.inactive:
							Order().inactive_removed.append('{}\{}'.format(dir['SSN'], dir['ORDER']))			
							try:
								shutil.rmtree(dir['SSN'], ignore_errors=True)
							except FileNotFoundError:
								pass	

			# Remove empty directories in output directory. 
			for root, dirs, files, in os.walk('{}'.format(self.path), topdown=False):
				for dir in dirs:
					if not os.listdir('{}\{}'.format(root, dir)):
						log.info('{} is empty. Removing {}\{}.'.format(dir, root, dir))
						os.rmdir('{}\{}'.format(root, dir))
						o.auditing_empty_dirs_removed.append('{}\{}'.format(root, dir))
					else:
						log.info('{} is not empty. Leaving {}\{}.'.format(dir, root, dir))						
								
			# Write results to csv's for original directory structure, active, inactive, and directories removed.
			if len(self.directories_orders) > 0:
				log.info('Writing original directory structure to {}.'.format(self.auditing_dirs_csv))
				with open(self.auditing_dirs_csv, 'w', newline="\n", encoding='utf-8') as dirs_out_file:
					writer = csv.writer(dirs_out_file)
					for n in self.directories_orders:
						writer.writerow([n['SSN'], n['ORDER']])

			if len(Order().active_not_removed) > 0:
				log.info('Writing ACTIVE soldiers to {}.'.format(self.auditing_active_txt))
				with open(self.auditing_active_txt, 'w') as active_out_file:
					active_out_file.write('\n'.join(Order().active_not_removed))
			
			if len(Order().inactive_removed) > 0:
				log.info('Writing INACTIVE soldiers to {}.'.format(self.auditing_inactive_txt))
				with open(self.auditing_inactive_txt, 'w') as inactive_out_file:
					inactive_out_file.write('\n'.join(Order().inactive_removed))

			if len(Order().auditing_empty_dirs_removed) > 0:
				log.info('Writing EMPTY DIRECTORIES removed to {}.'.format(self.auditing_empty_dirs_txt))
				with open(self.auditing_empty_dirs_txt, 'w') as empty_dir_out_file:
					empty_dir_out_file.write('\n'.join(Order().auditing_empty_dirs_removed))
		else:
			log.critical('{} is not a directory. Try again with proper input.'.format(self.path))
			sys.exit()
	
	#def auditing_uics(self, path):
	
	#def auditing_users(self, path):
	
	#def auditing_certificate_orders(self, path):
	
	#def auditing_non_certificate_orders(self, path):
	
	#def auditing_report(self, path):
	
	#def auditing_consolidate(self, path):	

	def search_find(self, criteria, path):
		self.criteria = criteria
		self.path = path
		
		self.results = []
		for c in self.criteria:
			for p in self.path:
				print("Looking for [{}] in [{}].".format(c, p))
				
				for file in glob.glob("{}/**".format(p), recursive=True):
					if c in file:
						print("Found [{}] in [{}].".format(c, file))
						self.results.append(file)				
		
		return self.results
		
	def search_action(self, action, results): # Need to finish this functions purpose.
		self.action = action
		self.results = results
		
		if self.action == 'PRINT':
			print("Printing action specified. Printing results now.")
		if self.action == 'REMOVE':
			print("Removing action specified. Removing results now.")
		if self.action == 'COMBINE':
			print("Combining action specified. Combining results now.")	
			
	def parse_arguments(self):
		'''
		CREATE ARGUMENT PARSER
		'''
		parser = argparse.ArgumentParser(description='Script to manage orders from AFCOS.')
		
		'''
		PROCESSING ARGUMENTS
		Complete and working.
		'''
		process = parser.add_argument_group('Processing', 'Use these commands for processing orders.')
		process.add_argument('--combine', action='store_true', help='Combine orders from --input for PERMS Integrator. Orders from --input are created and combined into files containing no more than 250 per file for input into other systems.')
		process.add_argument('--create', action='store_true', help='Process orders from --input. Processed orders are placed in the created directory structure in --output.')
		process.add_argument('--input', nargs='+', metavar=r'\\SHARE\INPUT', help='Input directory or directories containing required files (*r.reg, *m.prt, *c.prt). You can pass multiple file paths at once to process multiple batches of orders.')
		process.add_argument('--output', metavar=r'\\SHARE\OUTPUT', type=str, help=r'Output directory to create orders in. Created directory structure is as follows: .\OUTPUT\UICS containing all UICS processed from --input, designed for unit administrators to retrieve orders for their soldiers quickly. As well as .\OUTPUT\ORD_MANAGERS\ORDERS_BY_SOLDIER containing all SOLDIER_SSN directories from --input only, no UICS. Designed for state level administrators and fund managers to access all unit soldiers in one location. Finally .\OUTPUT\ORD_MANAGERS\IPERMS_INTEGRATOR containing combined order files from --combine.')
		process.add_argument('--remove', action='store_true', help='Remove orders from --input within --output. Inverse of --create, used to remove orders in the case of errors or undesired orders processed.')
		
		'''
		AUDITING ON DIRECTORY STRUCTURE
		Under development.
		'''
		audit = parser.add_argument_group('Auditing', 'Use these commands for reporting and auditing the created directory structure.')
		audit.add_argument('--cleanup', metavar=r'\\SHARE\OUTPUT\UICS', type=str, help='Determine inactive (retired, no longer in, etc.) and active soldiers. Remove inactive orders and directories. Inactive is considered SOLDIER_SSN directories without orders cut from current year to current year minus two years. Automatically consolidate active soldiers orders spanning multiple years and UICS into current UIC directory.')
		audit.add_argument('--uic', metavar=r'\\SHARE\OUTPUT\UICS', type=str, help='Present number of UICs created.')
		audit.add_argument('--user', metavar=r'\\SHARE\OUTPUT\UICS', type=str, help='Present number of users created.')
		audit.add_argument('--cert', metavar=r'\\SHARE\OUTPUT\UICS', type=str, help='Present number of certificate orders created.')
		audit.add_argument('--main', metavar=r'\\SHARE\OUTPUT\UICS', type=str, help='Present number of non-certificate orders created.')
		audit.add_argument('--report', metavar=r'\\SHARE\OUTPUT\UICS', type=str, help='Present number of UICs, users, certificate, and main orders/directories created.')
		
		'''
		SEARCHING ORDERS
		Under development.
		'''
		search = parser.add_argument_group('Searching', 'Use these commands for finding and performing actions on orders.')
		search.add_argument('--action', choices=['REMOVE', 'PRINT', 'COMBINE'], help='Perform [ACTION] on results found by --search.')
		search.add_argument('--path', nargs='+', metavar='PATH', help=r'Path to search for orders in. Typically .\OUTPUT\UICS.')
		search.add_argument('--search', nargs='+', metavar='CRITERIA', help=r'Search for orders by name, ssn, etc. You can use multiple criteria search for. Typically by name LAST_FIRST_MI or ssn 123-45-6789.')
		
		'''
		OPTIONAL ARGUMENTS
		'''
		parser.add_argument('--verbose', action='store_true', help='Enable detailed script console verbosity.')
		
		'''
		VERSION
		'''
		parser.add_argument('--version', action='version', version='%(prog)s - Version 3.0. Check https://github.com/ajhanisch/ORDPRO for the most up to date information.')
		
		args = parser.parse_args()
		
		return args
			
	def set_variables(self):	
		args = Order().parse_arguments()
		
		self.current_directory_working = os.getcwd()
		self.log_directory_working = "{}\\LOGS".format(self.current_directory_working)
		
		self.script_name = os.path.basename(__file__)
		self.run_date = strftime("%Y-%m-%d_%H-%M-%S", gmtime())
		self.log_file = "{}\\{}_ORDPRO.log".format(self.log_directory_working, self.run_date)

		self.uics_directory_output = "{}\\UICS".format(args.output)
		self.ordmanagers_directory_output = "{}\\ORD_MANAGERS".format(args.output)
		self.ordmanagers_orders_by_soldier_output = "{}\\ORDERS_BY_SOLDIER".format(self.ordmanagers_directory_output)
		self.ordmanagers_iperms_integrator_output = "{}\\IPERMS_INTEGRATOR".format(self.ordmanagers_directory_output)

		self.directories = { 'CURRENT_DIRECTORY_WORKING': self.current_directory_working, 'LOG_DIRECTORY_WORKING': self.log_directory_working, 'UICS_DIRECTORY_OUTPUT': self.uics_directory_output, 'ORDMANAGERS_DIRECTORY_OUTPUT': self.ordmanagers_directory_output, 'ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT': self.ordmanagers_orders_by_soldier_output, 'ORDMANAGERS_IPERMS_INTEGRATOR_OUTPUT': self.ordmanagers_iperms_integrator_output }
		
		self.variables = { 'SCRIPT_NAME': self.script_name, 'RUN_DATE': self.run_date, 'LOG_FILE': self.log_file }
		
		return self.directories, self.variables
'''
ENTRY POINT
'''
if __name__ == '__main__':
	o = Order()
	args = o.parse_arguments()
	directories, variables = o.set_variables() # Accessed via directories['DIRECTORY'] || variables['VARIABLE']
	
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
	
	# Handling for Processing of orders.
	if args.input and args.output and args.create:
		r_process = { 'INPUT':args.input, 'OUTPUT':args.output, 'CREATE':args.create }		
	elif args.input and args.output and args.remove:
		r_process = { 'INPUT':args.input, 'OUTPUT':args.output, 'REMOVE':args.remove }
	elif args.input and args.output and not args.create or args.remove:
		print('Missing --create or --remove.')
		print('\nExample 1: Process Orders.')
		print(r'{} --input \\SHARE\INPUT --output \\SHARE\OUTPUT --create'.format(variables['SCRIPT_NAME']))
		print('\n\nExample 2: Remove Orders.')
		print(r'{} --input \\SHARE\INPUT --output \\SHARE\OUTPUT --remove'.format(variables['SCRIPT_NAME']))
		sys.exit()
		
	try:
		r_process
	except NameError:
		r_process = None
	
	if r_process != None:
		if not any((value == None for value in r_process.values())):
		
			try:
				if r_process['CREATE']:
					action = 'CREATE'
			except KeyError:
				if r_process['REMOVE']:
					action = 'REMOVE'
				
			print('INPUT is {}. OUTPUT is [{}]. PROCESS is [{}].'.format(args.input, args.output, action))
			
			start = time.strftime('%m-%d-%y %H:%M:%S')
			start_time = timeit.default_timer()
			
			directories, variables = o.set_variables() # Accessed via directories['DIRECTORY'] || variables['VARIABLE']
			
			orders_missing_files = {}
			orders_missing_files_csv = "{}\\{}_missing_files.csv".format(directories['LOG_DIRECTORY_WORKING'], variables['RUN_DATE'])
			
			orders_to_combine_txt = "{}\\{}_orders_created.txt".format(directories['LOG_DIRECTORY_WORKING'], variables['RUN_DATE'])
			orders_removed_txt = "{}\\{}_orders_removed.txt".format(directories['LOG_DIRECTORY_WORKING'], variables['RUN_DATE'])
					
			log.info("You are running {} with the following arguments: ".format(variables['SCRIPT_NAME']))
			for a in args.__dict__:
				log.info(str(a) + ": " + str(args.__dict__[a]))
					
			for path in args.input:
				for f in glob.glob("{}\\*r.reg".format(path)):
					o.files_processed += 1			
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
				
					for root, dirs, files in os.walk(path):
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
						o.critical_count += 1	
						o.orders_missing_files_count += 1
						log.error("Registry file found is [{}]. Main file found is [{}]. Cert file found is [{}].".format(result['ORDER_FILE_REG'], result['ORDER_FILE_MAIN'], result['ORDER_FILE_CERT']))	
						
						orders_missing_files[o.orders_missing_files_count] = []		
						orders_missing_files[o.orders_missing_files_count].append(result)
						
					for key, value in result.items():
						if key == 'ORDER_FILE_REG':
							with open(value, 'r') as reg_file:
								for line in reg_file:
									o.lines_processed += 1			
									order_number = line[:3] + '-' + line[3:6]
									published_year = line[6:12]
									published_year = published_year[0:2]
									format = line[12:15]
									name = re.sub("\W", "_", line[15:37].strip())
									uic = re.sub("\W", "_", line[37:42].strip())
									period_from = line[48:54]
									period_to = line[54:60]
									ssn = line[60:63] + "-" + line[63:65] + "-" + line[65:69]
									
									if result['ORDER_FILE_MAIN']:
										with open(result['ORDER_FILE_MAIN'], 'r') as main_file:
											orders_m = main_file.read()
											orders_m = [x + "\f" for x in orders_m.split("\f")]							
											order_m = [s for s in orders_m if order_number in s]
										if order_m:
											o.orders_main_count += 1
											log.info("Found valid main order for {} {} order number {}.".format(name, ssn, order_number))
											
											# Turn order_m list into order_m string to write to file
											order_m = ''.join(order_m)
											# Remove last line (\f) from the order to make printing work
											order_m = order_m[:order_m.rfind('\f')]
											
											uic_directory = "{}\\{}".format(directories['UICS_DIRECTORY_OUTPUT'], uic)
											soldier_directory_uics = "{}\\{}___{}".format(uic_directory, name, ssn)
											uic_soldier_order_file_name_main = "{}___{}___{}___{}___{}___{}.doc".format(published_year, ssn, order_number, period_from, period_to, format)
											ord_managers_soldier_directory = "{}\\{}___{}".format(directories['ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT'], name, ssn)
											
											if args.create:
												o.orders_created_count += 1
												o.processing_create_directory(soldier_directory_uics)
												o.processing_create_directory(ord_managers_soldier_directory)
												o.processing_create_order(soldier_directory_uics, uic_soldier_order_file_name_main, order_m)
												o.processing_create_order(ord_managers_soldier_directory, uic_soldier_order_file_name_main, order_m)
											elif args.remove:
												o.orders_removed_count += 1
												o.processing_remove_order(soldier_directory_uics, uic_soldier_order_file_name_main, order_m)
												o.processing_remove_order(ord_managers_soldier_directory, uic_soldier_order_file_name_main, order_m)
												
										else:
											o.error_count += 1
											o.orders_main_missing_count += 1
											log.error("Failed to find main order for {} {} order number {}.".format(name, ssn, order_number))
									else:
										o.error_count += 1
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
											o.orders_cert_count += 1								
											log.info("Found valid cert order for {} {} order number {}.".format(name, ssn, order_number))
											
											uic_directory = "{}\\{}".format(directories['UICS_DIRECTORY_OUTPUT'], uic)
											soldier_directory_uics = "{}\\{}___{}".format(uic_directory, name, ssn)
											uic_soldier_order_file_name_cert = "{}___{}___{}___{}___{}___cert.doc".format(published_year, ssn, order_number, period_from, period_to)
											ord_managers_soldier_directory = "{}\\{}___{}".format(directories['ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT'], name, ssn)
											
											if args.create:
												o.orders_created_count += 1
												o.processing_create_directory(soldier_directory_uics)
												o.processing_create_directory(ord_managers_soldier_directory)	
												o.processing_create_order(soldier_directory_uics, uic_soldier_order_file_name_cert, order_c)
												o.processing_create_order(ord_managers_soldier_directory, uic_soldier_order_file_name_cert, order_c)
											elif args.remove:
												o.orders_removed_count += 1
												o.processing_remove_order(soldier_directory_uics, uic_soldier_order_file_name_cert, order_c)
												o.processing_remove_order(ord_managers_soldier_directory, uic_soldier_order_file_name_cert, order_c)
										else:
											o.error_count += 1	
											o.orders_cert_missing_count += 1
											log.error("Failed to find cert order for {} {} order number {}.".format(name, ssn, order_number))
									else:
										o.error_count += 1
										o.orders_cert_missing_count += 1
										log.error("Missing cert order file for {} {} order number {}.".format(name, ssn, order_number))
										
				if len(orders_missing_files) > 0:
					log.critical("Looks like we have some missing files. Writing missing files results to {} now. Check this file for full results.".format(orders_missing_files_csv))
				
					with open(orders_missing_files_csv, 'w') as out_file:
						writer = csv.writer(out_file, lineterminator='\n')
						for key, value in orders_missing_files.items():
							writer.writerow([key, value])
						
				if len(o.orders_to_combine) > 0:
					log.info("Writing orders processed this round to {} now.".format(orders_to_combine_txt))
					with open(orders_to_combine_txt, 'w') as out_file:
						writer = csv.writer(out_file, lineterminator='\n')
						for order in o.orders_to_combine:
							writer.writerow([order])
					log.info("Finished writing orders processed this round to {}.".format(orders_to_combine_txt))
					
				if len(o.orders_removed) > 0:
					log.info("Writing orders removed this round to {} now.".format(orders_removed_txt))
					with open(orders_removed_txt, 'w') as out_file:
						writer = csv.writer(out_file, lineterminator='\n')
						for order in o.orders_removed:
							writer.writerow([order])
					log.info("Finished writing orders removed this round to {}.".format(orders_removed_txt))
				
			if args.combine:
				log.info("Combining orders to {} now.".format(directories['LOG_DIRECTORY_WORKING']))
				o.processing_combine_orders(o.orders_to_combine, published_year)
				log.info("Finished combining orders to {}.".format(directories['LOG_DIRECTORY_WORKING']))
				
			end = time.strftime('%m-%d-%y %H:%M:%S')
			end_time = timeit.default_timer()
			seconds = round(end_time - start_time)
			m, s = divmod(seconds, 60)
			h, m = divmod(m, 60)
			run_time = "{}:{}:{}".format(h, m, s)
			
			if args.create:
				s_action = 'CREATE'
			elif args.remove:
				s_action = 'REMOVE'
				
			log.info('{:-^30}'.format(''))
			log.info('{:+^30}'.format('PROCESSING STATS'))
			log.info('{:-^30}'.format(''))
			log.info('{:<23} {:>6}'.format('Process:               ', s_action))
			log.info('{:<23} {:>6}'.format('Created:               ', o.orders_created_count))
			log.info('{:<23} {:>6}'.format('Removed:               ', o.orders_removed_count))
			log.info('{:<23} {:>6}'.format('Files processed:       ', o.files_processed))
			log.info('{:<23} {:>6}'.format('Files missing:         ', len(orders_missing_files)))
			log.info('{:<23} {:>6}'.format('Lines processed:       ', o.lines_processed))
			log.info('{:<23} {:>6}'.format('Main orders:           ', o.orders_main_count))
			log.info('{:<23} {:>6}'.format('Cert orders:           ', o.orders_cert_count))
			log.info('{:<23} {:>6}'.format('Missing main:          ', o.orders_main_missing_count))
			log.info('{:<23} {:>6}'.format('Missing cert:          ', o.orders_cert_missing_count))
			log.info('{:<23} {:>6}'.format('Warnings:              ', o.warning_count))
			log.info('{:<23} {:>6}'.format('Errors:                ', o.error_count))
			log.info('{:<23} {:>6}'.format('Criticals:             ', o.critical_count))
			log.info('{:-^30}'.format(''))
			log.info('{:+^30}'.format('RUNNING STATS'))
			log.info('{:-^30}'.format(''))
			log.info('{:<} {:>}'.format('Start time: ', start))
			log.info('{:<} {:>}'.format('End time:   ', end))
			log.info('{:<11} {:>7}'.format('Run time:             ', run_time))
			log.info('{:-^30}'.format(''))
		else:
			empty_keys = [k for k, v in r_search.items() if v == None]
			print('Looks like we are missing {}.'.format(empty_keys))
			print('\nExample 1: Process Orders.')
			print(r'{} --input \\SHARE\INPUT --output \\SHARE\OUTPUT --create'.format(variables['SCRIPT_NAME']))
			print('\n\nExample 2: Remove Orders.')
			print(r'{} --input \\SHARE\INPUT --output \\SHARE\OUTPUT --remove'.format(variables['SCRIPT_NAME']))
			sys.exit()

	# Handling for Auditing of orders.
	if args.cleanup:
		print('Determining INACTIVE / ACTIVE soldiers. Removing INACTIVE and consolidating ACTIVE from [{}].'.format(args.cleanup))
		o.auditing_cleanup(args.cleanup)
			
	elif args.uic:
		print('Calculating number of UICs in [{}].'.format(args.uic))
		# results_uic = o.auditing_uics(args.uic)
	elif args.user:
		print('Calculating number of users in [{}].'.format(args.user))
		# results_user = o.auditing_users(args.user)
	elif args.cert:
		print('Calculating number of certificate orders in [{}].'.format(args.cert))
		# results_cert = o.auditing_certificate_orders(args.cert)
	elif args.main:
		print('Calculating number of non-certificate orders in [{}].'.format(args.main))
		# results_main = o.auditing_non_certificate_orders(args.main)
	elif args.report:
		print('Calculating number of UICs, Users, Certificate Orders, and Non-Certificate Orders in [{}].'.format(args.report))
		# results_report = o.auditing_report(args.report)
		
	# Handling for Searching of orders.
	if args.search or args.path or args.action:
		r_search = { 'SEARCH':args.search, 'PATH':args.path, 'ACTION':args.action }
		if not any((value == None for value in r_search.values())):
			results_search = o.search_find(args.search, args.path)
			o.search_action(args.action, results_search)
		else:
			empty_keys = [k for k, v in r_search.items() if v == None]
			print('Looks like we are missing {}.'.format(empty_keys))
			print(r'Example {} --search 123-45-6789 --path \\SHARE\OUTPUT\UICS --action (REMOVE, PRINT, COMBINE)'.format(variables['SCRIPT_NAME']))
