#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse, os, logging, timeit, time, glob, sys, fnmatch, re
from time import gmtime, strftime
from datetime import datetime

'''
FUNCTIONS
'''
def SetVariables():	
	'''
	PARSE ARGUMENTS
	'''
	args = ParseArguments()
	
	'''
	DIRECTORIES WORKING
	'''
	current_directory_working = os.getcwd()
	log_directory_working = r"{}\\LOGS".format(current_directory_working)
	
	'''
	VARIABLES
	'''
	script_name = os.path.basename(__file__)
	run_date = strftime("%Y-%m-%d_%H-%M-%S", gmtime())
	log_file = "{}\\{}_ORDPRO.log".format(log_directory_working, run_date)

	'''
	DIRECTORIES OUTPUT
	'''
	uics_directory_output = "{}\\UICS".format(args.o)
	ordmanagers_directory_output = "{}\\ORD_MANAGERS".format(args.o)
	ordmanagers_orders_by_soldier_output = "{}\\ORDERS_BY_SOLDIER".format(ordmanagers_directory_output)
	ordmanagers_iperms_integrator_output = "{}\\IPERMS_INTEGRATOR".format(ordmanagers_directory_output)

	'''
	DICTIONARIES
	'''
	directories = { 'CURRENT_DIRECTORY_WORKING': current_directory_working, 'LOG_DIRECTORY_WORKING': log_directory_working, 'UICS_DIRECTORY_OUTPUT': uics_directory_output, 'ORDMANAGERS_DIRECTORY_OUTPUT': ordmanagers_directory_output, 'ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT': ordmanagers_orders_by_soldier_output, 'ORDMANAGERS_IPERMS_INTEGRATOR_OUTPUT': ordmanagers_iperms_integrator_output }
	
	variables = { 'SCRIPT_NAME': script_name, 'RUN_DATE': run_date, 'LOG_FILE': log_file }
	
	return directories, variables

def ParseArguments():
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
	
	'''
	PRINT VERSION
	'''
	parser.add_argument("--version", action="version", version='%(prog)s - Version 2.4')
	
	'''
	PARSE ARGUMENTS
	'''
	args = parser.parse_args()
	
	return args
	
def main():
	'''
	PARSE ARGUMENTS
	'''
	args = ParseArguments()
	
	if args.i and args.o:	
		'''
		GET REQUIRED VARIABLES
		'''
		directories, variables = SetVariables() # Accessed via directories['DIRECTORY'] || variables['VARIABLE']
		
		'''
		CREATE REQUIRED DIRECTORES
		'''
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
		
		'''
		PRINT ARGUMENTS
		'''
		log.info("You are running {} with the following arguments: ".format(variables['SCRIPT_NAME']))
		for a in args.__dict__:
			log.info(str(a) + ": " + str(args.__dict__[a]))

		'''
		GATHER FILES
		'''	
		for f in glob.glob("{}\\*r.reg".format(args.i)):			
			
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
				print("Registry file found is [{}]. Main file found is [{}]. Cer file found is [{}].".format(result['ORDER_FILE_REG'], result['ORDER_FILE_MAIN'], result['ORDER_FILE_CERT']))
			else:
				print("Registry file found is [{}]. Main file found is [{}]. Cert file found is [{}].".format(result['ORDER_FILE_REG'], result['ORDER_FILE_MAIN'], result['ORDER_FILE_CERT']))
				sys.exit("Missing one or more files. Try again with proper input.")
				
			for key, value in result.items():
				if key == 'ORDER_FILE_REG':
					with open(value, 'r') as reg_file:
						for line in reg_file:
							order_number = line[:3] + '-' + line[3:6]
							published_year = line[6:12]
							published_year = published_year[0:2]
							format = line[12:15]
							name = re.sub("\W", "_", line[15:37].strip())
							uic = line[37:42]
							period_from = line[48:54]
							period_to = line[54:60]
							ssn = line[60:63] + "-" + line[63:65] + "-" + line[64:68]
							
							order_m = ''
							with open(result['ORDER_FILE_MAIN'], 'r') as main_file:
								orders_m = main_file.read().split("\f")						
								order_regex_1 = "ORDERS {}".format(order_number)
								order_regex_2 = "ORDERS  {}".format(order_number)
								for order in orders_m:
									if order_regex_1 in order:
										order_m += order
									elif order_regex_2 in order:
										#order = order.replace("`f",'')
										order_m += order
							if order_m != '':
								print("Found valid main order for {} {} order number {}.".format(name, ssn, order_number))
							else:
								print("Failed to find main order for {} {} order number {}.".format(name, ssn, order_number))
									
							order_c = ''
							with open(result['ORDER_FILE_CERT'], 'r') as cert_file:
								orders_c = cert_file.read().split("\f")						
								order_regex = "Order number: {}".format(line[0:6])
								for order in orders_c:
									if order_regex in order:
										order_c += order
							if order_c != '':
								print("Found valid cert order for {} {} order number {}.".format(name, ssn, order_number))
							else:
								print("Failed to find cert order for {} {} order number {}.".format(name, ssn, order_number))
								
							uic_directory = "{}\\{}".format(directories['UICS_DIRECTORY_OUTPUT'], uic)
							soldier_directory_uics = "{}\\{}___{}".format(uic_directory, name, ssn)
							uic_soldier_order_file_name_main = "{}___{}___{}___{}___{}___{}.doc".format(published_year, ssn, order_number, period_from, period_to, format)
							uic_soldier_order_file_name_cert = "{}___{}___{}___{}___{}___cert.doc".format(published_year, ssn, order_number, period_from, period_to)
							ord_managers_soldier_directory = "{}\\{}___{}".format(directories['ORDMANAGERS_ORDERS_BY_SOLDIER_OUTPUT'], name, ssn)
							
							# UICS directory
							if not os.path.exists("{}".format(soldier_directory_uics)):
								os.makedirs("{}".format(soldier_directory_uics))
							if not os.path.exists("{}\\{}".format(soldier_directory_uics, uic_soldier_order_file_name_main)):
								with open("{}\\{}".format(soldier_directory_uics, uic_soldier_order_file_name_main), 'w') as f:
									f.write(order_m)
							if order_c:
								if not os.path.exists("{}\\{}".format(soldier_directory_uics, uic_soldier_order_file_name_cert)):
									with open("{}\\{}".format(soldier_directory_uics, uic_soldier_order_file_name_cert), 'w') as f:
										f.write(order_c)
							else:
								print("Failed to find certificate order for {} {} order number {}. Most likely certificate for this person does not exist or certificate order file as a whole does not exist. Skipping.".format(name, ssn, order_number))
								
							# ORD_MANAGERS directory
							if not os.path.exists("{}".format(ord_managers_soldier_directory)):
								os.makedirs("{}".format(ord_managers_soldier_directory))
							if not os.path.exists("{}\\{}".format(ord_managers_soldier_directory, uic_soldier_order_file_name_main)):
								with open("{}\\{}".format(ord_managers_soldier_directory, uic_soldier_order_file_name_main), 'w') as f:
									f.write(order_m)
							if order_c:
								if not os.path.exists("{}\\{}".format(ord_managers_soldier_directory, uic_soldier_order_file_name_cert)):
									with open("{}\\{}".format(ord_managers_soldier_directory, uic_soldier_order_file_name_cert), 'w') as f:
										f.write(order_c)
							else:
								print("Failed to find certificate order for {} {} order number {}. Most likely certificate for this person does not exist or certificate order file as a whole does not exist. Skipping.".format(name, ssn, order_number))
'''
ENTRY POINT
'''
if __name__ == '__main__':
	main()
