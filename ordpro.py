#!python3
# -*- coding: utf-8 -*-

'''
ORDPRO
Copyright (C) 2017  Ashton Hanisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import re
import os
import sys
import time
import glob
import shutil
import timeit
import getpass
import logging
import argparse
from time import strftime
from datetime import datetime

class Order:
	def __init__(self, **kwargs):
		for key, value in kwargs.items():
			setattr(self, key, value)

	def combine(self):
		self.list_known_bad_strings = [
			"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
			"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
			"ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}",
			"\f"
		]
		self.combine_order_files = self.list_orders_to_combine[:250]
		self.combine_order_files_processed = []
		self.combine_start = 1
		self.combine_end = len(self.combine_order_files)

		'''
		Create output directory for run time.
		'''
		if not os.path.exists(self.combine_out_directory):
			os.makedirs(self.combine_out_directory)

		while len(self.combine_order_files) != 0:
			self.out_file = os.path.join(self.combine_out_directory, '{}_{}-{}.doc'.format(self.combine_year, self.combine_start, self.combine_end))

			'''
			Combine the files within self.combine_order_files into batches of no more than 250 orders per file.
			'''
			with open(self.out_file, 'w') as f:
				for fname in self.combine_order_files:
					with open(fname) as infile:
						f.write(infile.read())
						self.combine_order_files_processed.append(fname)

			'''
			Remove known bad strings so self.out_file is ready to be loaded into PERMS Integrator immediately.
			'''
			for s in self.list_known_bad_strings:
				with open(self.out_file, 'r') as f:
					f_data = f.read()
					pattern = re.compile(s)
					f_data = pattern.sub('', f_data)
					with open(self.out_file, 'w') as f:
						f.write(f_data)

			'''
			Get the next potential 250 files to combine into the next file.
			'''
			self.combine_order_files = []
			for fname in self.list_orders_to_combine:
				if fname not in self.combine_order_files_processed:
					self.combine_order_files.append(fname)
			self.combine_order_files = self.combine_order_files[:250]
			self.combine_start = self.combine_end + 1
			self.combine_end = self.combine_start + len(self.combine_order_files) - 1

	def create(self):
		logging.debug('Creating Order Number: [{}]. Published Year: [{}]. Format: [{}]. Name: [{}]. UIC: [{}]. Period From: [{}]. Period To: [{}]. SSN: [{}].'.format(self.order_number, self.published_year, self.format, self.name, self.uic, self.period_from, self.period_to, self.ssn))

		if not os.path.exists(self.directory_uics):
			os.makedirs(self.directory_uics)
		if not os.path.exists(self.directory_ord_managers):
			os.makedirs(self.directory_ord_managers)
		if not os.path.exists(os.path.join(self.directory_uics, self.file_order)):
			with open(os.path.join(self.directory_uics, self.file_order), 'w') as f:
				f.write(self.order)
		if not os.path.exists(os.path.join(self.directory_ord_managers, self.file_order)):
			with open(os.path.join(self.directory_ord_managers, self.file_order), 'w') as f:
				f.write(self.order)

	def remove(self):
		if os.path.exists(os.path.join(self.directory_uics, self.file_order)):
			logging.debug('Found [{}] in [{}] Removing.'.format(self.file_order, self.directory_uics))
			os.remove(os.path.join(self.directory_uics, self.file_order))
		if os.path.exists(os.path.join(self.directory_ord_managers, self.file_order)):
			logging.debug('Found [{}] in [{}]. Removing.'.format(self.directory_ord_managers, self.directory_uics))
			os.remove(os.path.join(self.directory_ord_managers, self.file_order))

class Process:
	def __init__(self, **kwargs):
		for key, value in kwargs.items():
			setattr(self, key, value)

	def cleanup(self):
		start = time.strftime('%m-%d-%y %H:%M:%S')
		start_time = timeit.default_timer()
		'''
		Lists for statistics for cleanup.
		'''
		list_stats_active = []
		list_stats_inactive = []

		for p in self.list_cleanup_path:
			if os.path.isdir(p):
				logging.info('Working on [{}]. All input is {}.'.format(p, self.list_cleanup_path))
				'''
				Create list of dictionaries containing directories and files of UICS directory and create list of ssn.
				'''
				for root, dirs, files, in os.walk(p):
					for file in files:
						if file.endswith('.doc'):
							self.dict_auditing_result = { 'LAST_FIRST_M___SSN': root, 'ORDER': file }
							ssn = self.dict_auditing_result['LAST_FIRST_M___SSN'].split(os.sep)[-1].split('_')[-1]
							self.list_cleanup_directories_orders.append(self.dict_auditing_result)
							if ssn not in self.list_cleanup_ssn:
								self.list_cleanup_ssn.append(ssn)
				'''
				Look for ssn in list within list of dictionaries. Determine active and inactive. If inactive, remove ssn directories in all UICS. If active, consolidate to most recent UIC folder.
				'''
				for ssn in self.list_cleanup_ssn:
					self.list_cleanup_active = [ y for y in self.list_cleanup_directories_orders if p in y['LAST_FIRST_M___SSN'] and ssn in y['LAST_FIRST_M___SSN'] and y['ORDER'].split('___')[0] in self.list_cleanup_years_to_consider_active ]

					if len(self.list_cleanup_active) > 0:
						logging.info('[{}] appears to be ACTIVE. Consolidating to most recent location.'.format(ssn))
						'''
						Determine most recent order.
						'''
						active_ssn_most_recent_order = ''
						active_ssn_most_recent_dir = ''
						for i in self.list_cleanup_active:
							if i['LAST_FIRST_M___SSN'].split(os.sep)[-1] not in list_stats_active and 'UICS' in i['LAST_FIRST_M___SSN']:
								list_stats_active.append(i['LAST_FIRST_M___SSN'].split(os.sep)[-1])

							if active_ssn_most_recent_order == '':
								active_ssn_most_recent_order = i['ORDER']
								active_ssn_most_recent_dir = i['LAST_FIRST_M___SSN']
								logging.debug('[{}] is the first order for [{}] to be evaluated.'.format(active_ssn_most_recent_order, active_ssn_most_recent_dir))
								logging.debug('Most recent ORDER: [{}]. Most recent PATH is [{}].'.format(active_ssn_most_recent_order, active_ssn_most_recent_dir))

							elif i['ORDER'].split('___')[0] > active_ssn_most_recent_order.split('___')[0]:
								logging.debug('Comparing [{}] to [{}].'.format(i['ORDER'], active_ssn_most_recent_order))
								logging.debug('Year of [{}] is greater than year of [{}].'.format(i['ORDER'].split('___')[0], active_ssn_most_recent_order.split('___')[0]))
								active_ssn_most_recent_order = i['ORDER']
								active_ssn_most_recent_dir = i['LAST_FIRST_M___SSN']
								logging.debug('Most recent ORDER: [{}]. Most recent PATH is [{}].'.format(active_ssn_most_recent_order, active_ssn_most_recent_dir))

							elif i['ORDER'].split('___')[0] == active_ssn_most_recent_order.split('___')[0] \
							and i['ORDER'].split('___')[2].replace('-','') > active_ssn_most_recent_order.split('___')[2].replace('-','') \
							:
								logging.debug('Comparing [{}] to [{}].'.format(i['ORDER'], active_ssn_most_recent_order))
								logging.debug('Year of [{}] is equal to year of [{}], but order number [{}] is greater than order number [{}].'.format(i['ORDER'].split('___')[0], active_ssn_most_recent_order.split('___')[0], i['ORDER'].split('___')[2], active_ssn_most_recent_order.split('___')[2]))
								active_ssn_most_recent_order = i['ORDER']
								active_ssn_most_recent_dir = i['LAST_FIRST_M___SSN']
								logging.debug('Most recent ORDER: [{}]. Most recent PATH is [{}].'.format(active_ssn_most_recent_order, active_ssn_most_recent_dir))
						'''
						Move self.list_cleanup_active to the most recent LAST_FIRST_M___SSN directory.
						'''
						active_source_directories = set([ z['LAST_FIRST_M___SSN'] for z in self.list_cleanup_directories_orders if p in z['LAST_FIRST_M___SSN'] and active_ssn_most_recent_dir not in z['LAST_FIRST_M___SSN'] and ssn in z['LAST_FIRST_M___SSN'] ])
						destination_directory = active_ssn_most_recent_dir

						for active_directories in active_source_directories:
							source_files = os.listdir(active_directories)
							for source_file in source_files:
								try:
									logging.debug('Moving [{}] to [{}].'.format(source_file, destination_directory))
									shutil.move(os.path.join(active_directories, source_file), destination_directory)
								except:
									logging.debug('Issue while moving [{}] to [{}]. [{}] most likely already exists. Continuing.'.format(source_file, destination_directory, source_file))
					else:
						self.list_cleanup_inactive = [ x for x in self.list_cleanup_directories_orders if p in x['LAST_FIRST_M___SSN'] and ssn in x['LAST_FIRST_M___SSN'] and x['ORDER'].split('___')[0] not in self.list_cleanup_years_to_consider_active ]

						if len(self.list_cleanup_inactive) > 0 and 'ORD_MANAGERS{}ORDERS_BY_SOLDIER'.format(os.sep) in p:
							logging.debug('[{}] appears to be INACTIVE, but [{}] is for historical data for state level managers. Consolidating orders for [{}] in [{}].'.format(ssn, p, ssn, p))
							'''
							Determine most recent order.
							'''
							inactive_ssn_most_recent_order = ''
							inactive_ssn_most_recent_dir = ''
							for j in self.list_cleanup_inactive:
								if inactive_ssn_most_recent_order == '':
									inactive_ssn_most_recent_order = j['ORDER']
									inactive_ssn_most_recent_dir = j['LAST_FIRST_M___SSN']
									logging.debug('[{}] is the first order for [{}] to be evaluated.'.format(inactive_ssn_most_recent_order, inactive_ssn_most_recent_dir))
									logging.debug('Most recent ORDER: [{}]. Most recent PATH is [{}].'.format(inactive_ssn_most_recent_order, inactive_ssn_most_recent_dir))

								elif j['ORDER'].split('___')[0] > inactive_ssn_most_recent_order.split('___')[0]:
									logging.debug('Comparing [{}] to [{}].'.format(j['ORDER'], inactive_ssn_most_recent_order))
									logging.debug('Year of [{}] is greater than year of [{}].'.format(j['ORDER'].split('___')[0], inactive_ssn_most_recent_order.split('___')[0]))
									inactive_ssn_most_recent_order = j['ORDER']
									inactive_ssn_most_recent_dir = j['LAST_FIRST_M___SSN']
									logging.debug('Most recent ORDER: [{}]. Most recent PATH is [{}].'.format(inactive_ssn_most_recent_order, inactive_ssn_most_recent_dir))

								elif j['ORDER'].split('___')[0] == inactive_ssn_most_recent_order.split('___')[0] \
								and j['ORDER'].split('___')[2].replace('-','') > inactive_ssn_most_recent_order.split('___')[2].replace('-','') \
								:
									logging.debug('Comparing [{}] to [{}].'.format(j['ORDER'], inactive_ssn_most_recent_order))
									logging.debug('Year of [{}] is equal to year of [{}], but order number [{}] is greater than order number [{}].'.format(j['ORDER'].split('___')[0], inactive_ssn_most_recent_order.split('___')[0], j['ORDER'].split('___')[2], inactive_ssn_most_recent_order.split('___')[2]))
									inactive_ssn_most_recent_order = j['ORDER']
									inactive_ssn_most_recent_dir = j['LAST_FIRST_M___SSN']
									logging.debug('Most recent ORDER: [{}]. Most recent PATH is [{}].'.format(inactive_ssn_most_recent_order, inactive_ssn_most_recent_dir))
							'''
							Move self.list_cleanup_inactive to the most recent LAST_FIRST_M___SSN directory.
							'''
							inactive_source_directories = set([ z['LAST_FIRST_M___SSN'] for z in self.list_cleanup_directories_orders if p in z['LAST_FIRST_M___SSN'] and inactive_ssn_most_recent_dir not in z['LAST_FIRST_M___SSN'] and ssn in z['LAST_FIRST_M___SSN'] ])
							destination_directory = inactive_ssn_most_recent_dir

							for inactive_directory in inactive_source_directories:
								source_files = os.listdir(inactive_directory)
								for source_file in source_files:
									try:
										logging.debug('Moving [{}] to [{}].'.format(source_file, destination_directory))
										shutil.move(os.path.join(inactive_directory, source_file), destination_directory)
									except:
										logging.debug('Issue while moving [{}] to [{}]. [{}] most likely already exists. Continuing.'.format(source_file, destination_directory, source_file))

						elif len(self.list_cleanup_inactive) > 0 and 'UICS' in p:
							logging.info('[{}] appears to be INACTIVE. Removing [{}] from all locations within [{}].'.format(ssn, ssn, p))
							for inactive_directory in self.list_cleanup_inactive:
								try:
									shutil.rmtree(inactive_directory['LAST_FIRST_M___SSN'], ignore_errors=True)
									if inactive_directory['LAST_FIRST_M___SSN'].split(os.sep)[-1] not in list_stats_inactive:
										list_stats_inactive.append(inactive_directory['LAST_FIRST_M___SSN'].split(os.sep)[-1])
								except FileNotFoundError:
									pass
				# < End for each ssn in self.list_cleanup_ssn
			else:
				logging.critical('{} is not a directory. Try again with proper input.'.format(p))
				sys.exit()
		# < End for each path on self.list_cleanup_path
		'''
		Remove empty directories within self.list_cleanup_path created from removing inactive and moving active.
		'''
		dict_data = {
			'list_empty_directories' : self.list_cleanup_path
		}
		Process(**dict_data).remove_empty_directories()

		'''
		Calculate and present statistics.
		'''
		end = time.strftime('%m-%d-%y %H:%M:%S')
		end_time = timeit.default_timer()
		seconds = round(end_time - start_time)
		m, s = divmod(seconds, 60)
		h, m = divmod(m, 60)
		run_time = '{}:{}:{}'.format(h, m, s)
		dict_data = {
			'list_stats_active' : list_stats_active,
			'list_stats_inactive' : list_stats_inactive,
			'action' : 'CLEANUP',
			'setup' : Setup(),
			'args' : Setup().args,
			'start' : start,
			'end' : end,
			'start_time' : start_time,
			'end_time' : end_time,
			'run_time' : run_time
		}

		Statistics(**dict_data).output()
		Statistics(**dict_data).present()

	def gather_files(self):
		for i in self.gather_files_input:
			for root, dirs, files in os.walk(i):
				if files:
					logging.info('Adding files from [{}].'.format(root))
					self.dict_directory_files[root] = files
					logging.info('Finished adding files from [{}].'.format(root))
		return self.dict_directory_files

	def process_files(self):
		start = time.strftime('%m-%d-%y %H:%M:%S')
		start_time = timeit.default_timer()

		'''
		Lists for general statistics for both creation and removal.
		'''
		list_stats_files_processed = []
		list_stats_registry_files_processed = []
		list_stats_registry_files_missing = []
		list_stats_main_files_missing = []
		list_stats_certificate_files_missing = []
		list_stats_main_orders_missing = []
		list_stats_certificate_orders_missing = []
		list_stats_main_orders_combined = []
		stats_registry_lines_processed = 0
		stats_error_warning = 0
		stats_error_critical = 0
		'''
		List for creation statistics calculations and output results files.
		'''
		list_stats_main_orders_created_uics = []
		list_stats_certificate_orders_created_uics = []
		list_stats_main_orders_created_ord_managers = []
		list_stats_certificate_orders_created_ord_managers = []
		'''
		List for removal statistics calculations and output results files.
		'''
		list_stats_main_orders_removed_uics = []
		list_stats_certificate_orders_removed_uics = []
		list_stats_main_orders_removed_ord_managers = []
		list_stats_certificate_orders_removed_ord_managers = []

		logging.info('Processing {}.'.format(self.args.input))
		for key, value in self.process_files_input.items():
			logging.info('Processing [{}].'.format(key))
			for v in value:
				number_order_batch = v[3:9]
				list_order_batch = [ os.path.join(key, x) for x in value if not x.endswith('.glb') and os.path.join(key, x) not in self.original_list_files_processed and number_order_batch in os.path.join(key, x) ]
				if list_order_batch:
					self.original_list_files_processed.extend(list_order_batch)
					file_r_reg = [ x for x in list_order_batch if x.endswith('.reg') ]
					'''
					Add registry files processed to list_stats_registry_files_processed during processing
					'''
					list_stats_registry_files_processed.extend(file_r_reg)
					if len(file_r_reg) != 1:
						logging.critical('Missing *r.reg file for [{}].'.format(os.path.join(key, v)))
						stats_error_critical += 1
						if os.path.join(key, v) not in list_stats_registry_files_missing:
							list_stats_registry_files_missing.append(os.path.join(key, v))
					elif len(file_r_reg) == 1:
						with open(file_r_reg[0], 'r') as f:
							for line in f:
								stats_registry_lines_processed += 1
								order_number = line[:3] + '-' + line[3:6]
								published_year = line[6:12]
								published_year = published_year[0:2]
								if published_year.startswith('9'):
									published_year = '19{}'.format(published_year)
								else:
									published_year = '20{}'.format(published_year)
								format = line[12:15]
								name = re.sub('\W', '_', line[15:37].strip())
								uic = re.sub('\W', '_', line[37:42].strip())
								period_from = line[48:54]
								period_to = line[54:60]
								ssn = line[60:63] + '-' + line[63:65] + '-' + line[65:69]
								file_m_prt = [ x for x in list_order_batch if 'm.prt' in x ]
								if len(file_m_prt) == 1:
									with open(file_m_prt[0], 'r') as m:
										orders_m = m.read()
										orders_m = [x + '\f' for x in orders_m.split('\f')]
										order_m = [s for s in orders_m if order_number in s] # Look for order by order number in main file
										if order_m:
											logging.debug('Found valid main order for [{}] [{}] order number [{}].'.format(name, ssn, order_number))
											order_m = ''.join(order_m) # Turn order_m list into order_m string to write to file
											order_m = order_m[:order_m.rfind('\f')] # Remove last line (\f) from the order to make printing work
											dict_data = {
												'setup' : Setup(),
												'order_number' : order_number,
												'published_year' : published_year,
												'format' : format,
												'name' : name,
												'uic' : uic,
												'period_from' : period_from,
												'period_to' : period_to,
												'ssn' : ssn,
												'order' : order_m,
												'file_order' : '{}___{}___{}___{}___{}___{}.doc'.format(published_year, ssn, order_number, period_from, period_to, format),
												'directory_uics' : os.path.join(self.setup.directory_output_uics, uic, '{}___{}'.format(name, ssn)),
												'directory_ord_managers' : os.path.join(self.setup.directory_output_orders_by_soldier, '{}___{}'.format(name, ssn))
											}
											'''
											Perform specific function on order_m based on command line arguments.
											'''
											if self.args.create:
												'''
												Add directory_uics and file_order to list_stats_main_orders_created_uics and list_stats_main_orders_created_ord_managers or list_stats_main_orders_removed_uics and list_stats_main_orders_removed_ord_managers.
												'''
												if dict_data['directory_uics']:
													list_stats_main_orders_created_uics.append(os.path.join(dict_data['directory_uics'], dict_data['file_order']))
												if dict_data['directory_ord_managers']:
													list_stats_main_orders_created_ord_managers.append(os.path.join(dict_data['directory_ord_managers'], dict_data['file_order']))
												Order(**dict_data).create()
											elif self.args.remove:
												if dict_data['directory_uics']:
													list_stats_main_orders_removed_uics.append(os.path.join(dict_data['directory_uics'], dict_data['file_order']))
												if dict_data['directory_ord_managers']:
													list_stats_main_orders_removed_ord_managers.append(os.path.join(dict_data['directory_ord_managers'], dict_data['file_order']))
												Order(**dict_data).remove()

											if self.args.combine:
												if dict_data['file_order'] not in self.list_orders_to_combine:
													logging.debug('[{}] not in list_orders_to_combine. Adding.'.format(dict_data['file_order']))
													self.list_orders_to_combine.append(os.path.join(dict_data['directory_ord_managers'], dict_data['file_order']))
										else:
											'''
											Add missing main order to list_stats_main_orders_missing.
											'''
											stats_error_warning += 1
											file_order = '{}___{}___{}___{}___{}___{}.doc'.format(published_year, ssn, order_number, period_from, period_to, format)
											directory_uics = os.path.join(self.setup.directory_output_uics, uic, '{}___{}'.format(name, ssn))
											logging.warning('Missing valid main order for [{}].'.format(file_order))
											list_stats_main_orders_missing.append(os.path.join(directory_uics, file_order))
									# < End creating looking for order in main order file
								elif len(file_m_prt) == 0:
									logging.critical('Missing *m.prt file for [{}].'.format(os.path.join(key, v)))
									stats_error_critical += 1
									if os.path.join(key, v) not in list_stats_main_files_missing:
										list_stats_main_files_missing.append(os.path.join(key, v))

								file_c_prt = [ x for x in list_order_batch if 'c.prt' in x ]
								if len(file_c_prt) == 1:
									with open(file_c_prt[0], 'r') as c:
										orders_c = c.read().split('\f')
										order_regex = 'Order number: {}'.format(line[0:6])
										order_c = [ x for x in orders_c if order_regex in x ] # Look for order by order number in cert file
									if order_c:
										order_c = ''.join(order_c)
										logging.debug('Found valid cert order for [{}] [{}] order number [{}].'.format(name, ssn, order_number))
										dict_data = {
											'setup' : Setup(),
											'order_number' : order_number,
											'published_year' : published_year,
											'format' : 'cert',
											'name' : name,
											'uic' : uic,
											'period_from' : period_from,
											'period_to' : period_to,
											'ssn' : ssn,
											'order' : order_c,
											'file_order' : '{}___{}___{}___{}___{}___{}.doc'.format(published_year, ssn, order_number, period_from, period_to, 'cert'),
											'directory_uics' : os.path.join(self.setup.directory_output_uics, uic, '{}___{}'.format(name, ssn)),
											'directory_ord_managers' : os.path.join(self.setup.directory_output_orders_by_soldier, '{}___{}'.format(name, ssn))
										}
										'''
										Perform specific function on order_m based on command line arguments.
										'''
										if self.args.create:
											'''
											Add directory_uics and file_order to list_stats_certificate_orders_created_uics and list_stats_certificate_orders_created_ord_managers or list_stats_certificate_orders_removed_uics and list_stats_certificate_orders_removed_ord_managers.
											'''
											if dict_data['directory_uics']:
												list_stats_certificate_orders_created_uics.append(os.path.join(dict_data['directory_uics'], dict_data['file_order']))
											if dict_data['directory_ord_managers']:
												list_stats_certificate_orders_created_ord_managers.append(os.path.join(dict_data['directory_ord_managers'], dict_data['file_order']))
											Order(**dict_data).create()
										elif self.args.remove:
											if dict_data['directory_uics']:
												list_stats_certificate_orders_removed_uics.append(os.path.join(dict_data['directory_uics'], dict_data['file_order']))
											if dict_data['directory_ord_managers']:
												list_stats_certificate_orders_removed_ord_managers.append(os.path.join(dict_data['directory_ord_managers'], dict_data['file_order']))
											Order(**dict_data).remove()
									else:
										'''
										Add missing certificate order to list_stats_certificate_orders_missing.
										'''
										stats_error_warning += 1
										file_order = '{}___{}___{}___{}___{}___cert.doc'.format(published_year, ssn, order_number, period_from, period_to)
										directory_uics = os.path.join(self.setup.directory_output_uics, uic, '{}___{}'.format(name, ssn))
										logging.warning('Missing valid cert order for [{}].'.format(file_order))
										list_stats_certificate_orders_missing.append(os.path.join(directory_uics, file_order))
								elif len(file_c_prt) == 0:
									logging.critical('Missing *c.prt file for [{}].'.format(os.path.join(key, v)))
									stats_error_critical += 1
									if os.path.join(key, v) not in list_stats_certificate_files_missing:
										list_stats_certificate_files_missing.append(os.path.join(key, v))
							# < End for line in individual reg file
						# < End individual reg file
						'''
						Add files from list_order_batch to this list after they are processed
						'''
						list_stats_files_processed.extend(list_order_batch)
						'''
						Add published_year to self.list_years_processed to properly combine orders by year if self.args.combine is given.
						'''
						if dict_data['published_year']:
							if dict_data['published_year'] not in self.list_years_processed:
								logging.debug('Adding [{}] to list_years_processed'.format(dict_data['published_year']))
								self.list_years_processed.append(dict_data['published_year'])
							'''
							Make historical year folder, if it doesn't exist.
							'''
							directory_year_historical = os.path.join(self.setup.directory_output_ord_registers, '{}_orders'.format(dict_data['published_year']))
							if not os.path.exists(directory_year_historical):
								logging.debug('Creating {}.'.format(directory_year_historical))
								os.makedirs(directory_year_historical)
							'''
							Copy original m.prt, c.prt, r.reg, and r.prt files to ORD_MANAGERS\ORDERS_REGISTERS\[YR]_registers for historical backups.
							'''
							for i in list_order_batch:
								if not os.path.exists(os.path.join(directory_year_historical, i.split(os.sep)[-1])):
									logging.debug('Copying [{}] to [{}].'.format(i, directory_year_historical))
									shutil.copy(i, directory_year_historical)
						else:
							input('missing published_year from {}'.format(os.path.join(key, v))) # should never get here.
					# < End if reg file or not
				# < End if list_order_batch
			# < End for each file in year directory
			logging.info('Finished processing [{}].'.format(key))
		# < End for each input directory in self.process_files_input
		logging.info('Finished processing {}.'.format(self.args.input))
		'''
		Combine orders if self.args.combine is present.
		'''
		if self.args.combine:
			for year in self.list_years_processed:
				combine_these_orders_for_year = [ u for u in self.list_orders_to_combine if u.split(os.sep)[-1].split('___')[0] == str(year) ]
				if len(combine_these_orders_for_year) > 0:
					logging.info('Combining [{}] orders to [{}].'.format(year, os.path.join(self.setup.directory_output_iperms_integrator, self.setup.date)))
					dict_data = {
						'setup' : Setup(),
						'list_orders_to_combine' : combine_these_orders_for_year,
						'combine_year' : year,
						'combine_out_directory' : os.path.join(self.setup.directory_output_iperms_integrator, self.setup.date)
					}
					Order(**dict_data).combine()
					logging.info('Finished combining [{}] orders to [{}].'.format(year, os.path.join(self.setup.directory_output_iperms_integrator, self.setup.date)))
				else:
					logging.info('[{}] appears to have no orders to combine. Is this right?'.format(year))

		'''
		Remove empty directories if self.args.remove is given since we can leave behind empty directories after removing orders.
		'''
		if self.args.remove:
			dict_data = {
				'list_empty_directories' : [ self.setup.directory_output_orders_by_soldier, self.setup.directory_output_uics ]
			}
			Process(**dict_data).remove_empty_directories()
		'''
		Calculate and present statistics using Statistics class and methods.
		'''
		end = time.strftime('%m-%d-%y %H:%M:%S')
		end_time = timeit.default_timer()
		seconds = round(end_time - start_time)
		m, s = divmod(seconds, 60)
		h, m = divmod(m, 60)
		run_time = '{}:{}:{}'.format(h, m, s)
		dict_data_statistics = {
			'list_files_processed' : list_stats_files_processed,
			'list_registry_files_processed' : list_stats_registry_files_processed,
			'list_stats_registry_files_missing': list_stats_registry_files_missing,
			'list_stats_main_files_missing' : list_stats_main_files_missing,
			'list_stats_certificate_files_missing' : list_stats_certificate_files_missing,
			'list_main_orders_missing' : list_stats_main_orders_missing,
			'list_certificate_orders_missing' : list_stats_certificate_orders_missing,
			'list_main_orders_created_uics' : list_stats_main_orders_created_uics,
			'list_certificate_orders_created_uics' : list_stats_certificate_orders_created_uics,
			'list_main_orders_created_ord_managers' : list_stats_main_orders_created_ord_managers,
			'list_certificate_orders_created_ord_managers' : list_stats_certificate_orders_created_ord_managers,
			'list_main_orders_removed_uics' : list_stats_main_orders_removed_uics,
			'list_certificate_orders_removed_uics' : list_stats_certificate_orders_removed_uics,
			'list_main_orders_removed_ord_managers' : list_stats_main_orders_removed_ord_managers,
			'list_certificate_orders_removed_ord_managers' : list_stats_certificate_orders_removed_ord_managers,
			'list_main_orders_combined' : list_stats_main_orders_combined,
			'stats_registry_lines_processed' : stats_registry_lines_processed,
			'stats_error_warning' : stats_error_warning,
			'stats_error_critical' : stats_error_critical,
			'action' : self.action,
			'setup' : Setup(),
			'args' : Setup().args,
			'start' : start,
			'end' : end,
			'start_time' : start_time,
			'end_time' : end_time,
			'run_time' : run_time
		}

		Statistics(**dict_data_statistics).output()
		Statistics(**dict_data_statistics).present()

	def remove_empty_directories(self):
		list_directories_removed = []

		for i in self.list_empty_directories:
			logging.info('Removing empty directories from {}. Working on {} now.'.format(self.list_empty_directories, i))
			for root, dirs, files, in os.walk(i, topdown=False):
				for dir in dirs:
					if not os.listdir(os.path.join(root, dir)):
						logging.debug('{} IS empty. Removing {}.'.format(dir, os.path.join(root, dir)))
						os.rmdir(os.path.join(root, dir))
						list_directories_removed.append(os.path.join(root, dir))
					else:
						logging.debug('{} is NOT empty. Leaving {}.'.format(dir, os.path.join(root, dir)))
			logging.info('Finished working on {}.'.format(i))
		logging.info('Finished removing empty directories from {}.'.format(self.list_empty_directories))

		return list_directories_removed

	def report(self):
		list_report_uics = [ x[0] for x in os.walk(self.directory_output_uics) if len(x[0].split(os.sep)[-1]) == 5 ]
		list_report_soldiers = [ x[0] for x in os.walk(self.directory_output_uics) if len(x[0].split(os.sep)[-1]) > 5 ]
		list_report_main_orders = []
		list_report_certificate_orders = []
		for x in os.walk(self.directory_output_uics):
			if x[2]:
				for i in x[2]:
					if '__cert.doc' in i:
						logging.debug('Adding [{}] to list_report_certificate_orders.'.format(i))
						list_report_certificate_orders.append(os.path.join(x[0], i))
					else:
						logging.debug('Adding [{}] to list_report_main_orders.'.format(i))
						list_report_main_orders.append(os.path.join(x[0], i))
		if self.args.report == 'print':
			logging.debug('Print option specified. Printing statistics to screen now.')
			logging.info('{:-^60}'.format(''))
			logging.info('{:+^60}'.format('REPORTING STATS'))
			logging.info('{:-^60}'.format(''))
			logging.info('{:.<49}{:.>11}'.format('UICs:', len(list_report_uics)))
			logging.info('{:.<49}{:.>11}'.format('SOLDIERs:', len(list_report_soldiers)))
			logging.info('{:.<49}{:.>11}'.format('CERTIFICATE ORDERs:', len(list_report_certificate_orders)))
			logging.info('{:.<49}{:.>11}'.format('MAIN ORDERs:', len(list_report_main_orders)))
			logging.info('{:.<49}{:.>11}'.format('TOTAL ORDERs:', len(list_report_main_orders) + len(list_report_certificate_orders)))
			logging.info('{:-^60}'.format(''))
		elif self.args.report == 'outfile':
			logging.debug('Outfile option specificed. Outputting detailed results to files now.')
			dict_report_lists = {
				'report_uics' : list_report_uics,
				'report_soldiers' : list_report_soldiers,
				'report_main_orders' : list_report_main_orders,
				'report_certificate_orders' : list_report_certificate_orders
			}
			dict_report_files = {
				'report_uics' : os.path.join(self.setup.directory_working_log, '{}_report_uics.txt'.format(self.setup.date)),
				'report_soldiers' : os.path.join(self.setup.directory_working_log, '{}_report_soldiers.txt'.format(self.setup.date)),
				'report_certificate_orders' : os.path.join(self.setup.directory_working_log, '{}_report_orders_certificate.txt'.format(self.setup.date)),
				'report_main_orders' : os.path.join(self.setup.directory_working_log, '{}_report_orders_main.txt'.format(self.setup.date)),
				'report_results_numbers' : os.path.join(self.setup.directory_working_log, '{}_report_results_numbers.txt'.format(self.setup.date))
			}
			dict_report_statistics = {
				'uics' : len(list_report_uics),
				'soldiers' : len(list_report_soldiers),
				'certificate_orders' : len(list_report_certificate_orders),
				'main_orders' : len(list_report_main_orders),
				'total_orders' : len(list_report_main_orders) + len(list_report_certificate_orders)
			}
			for key, value in dict_report_lists.items():
				if len(value) > 0:
					file_output = dict_report_files[key]
					logging.info('Writing [{}] to [{}].'.format(key, file_output))
					with open(file_output, 'w') as f:
						f.write('\n'.join(sorted(value)))
					logging.info('Finished writing [{}] to [{}].'.format(key, file_output))
			file_output = dict_report_files['report_results_numbers']
			for key, value in dict_report_statistics.items():
				logging.info('Writing [{}] count to [{}].'.format(key, file_output))
				with open(file_output, 'a') as f:
					f.write('{}: {}\n'.format(key.upper(), (str(value))))
				logging.info('Finished writing [{}] count to [{}].'.format(key, file_output))

class Setup:
	'''
	VARIABLES
	'''
	version = '3.7'
	program = os.path.basename(__file__)
	repository = 'https://gitlab.com/ajhanisch/ORDPRO'
	wiki = 'https://gitlab.com/ajhanisch/ORDPRO/wikis/home'
	date = strftime('%Y-%m-%d_%H-%M-%S')
	user = getpass.getuser()
	platform = sys.platform
	if platform == 'win32':
		clear = 'cls'
	elif platform == 'linux' or platform == 'linux2':
		clear = 'clear'

	'''
	CREATE ARGUMENT PARSER
	'''
	parser = argparse.ArgumentParser(description='Program to automatically process, create, organize, combine, manage, and much more with orders from AFCOS.')

	'''
	PROCESSING ARGUMENTS
	Complete and working.
	'''
	process = parser.add_argument_group('Processing', 'Use these commands for processing orders.')
	process.add_argument(
						'--combine',
						action='store_true',
						help='Combine orders from --input for PERMS Integrator. Orders from --input are created and combined into files containing no more than 250 per file for input into other systems.'
	)
	process.add_argument(
						'--create',
						action='store_true',
						help='Process orders from --input. Processed orders are placed in the created directory structure in --output.'
	)
	process.add_argument(
						'--input',
						nargs='+',
						help='Input directory or directories containing required files (*r.reg, *m.prt, *c.prt). You can pass multiple file paths at once to process multiple batches of orders.'
	)
	process.add_argument(
						'--output',
						type=str,
						help=r'Output directory to create orders in. Created directory structure is as follows: .\OUTPUT\UICS containing all UICS processed from --input, designed for unit administrators to retrieve orders for their soldiers quickly. As well as .\OUTPUT\ORD_MANAGERS\ORDERS_BY_SOLDIER containing all SOLDIER_SSN directories from --input only, no UICS. Designed for state level administrators and fund managers to access all unit soldiers in one location. Finally .\OUTPUT\ORD_MANAGERS\IPERMS_INTEGRATOR containing combined order files from --combine.'
	)
	process.add_argument(
						'--remove',
						action='store_true',
						help='Remove orders from --input within --output. Inverse of --create, used to remove orders in the case of errors or undesired orders processed.'
	)

	'''
	AUDITING ON DIRECTORY STRUCTURE
	Complete and working.
	'''
	audit = parser.add_argument_group('Auditing', 'Use these commands for reporting and auditing the created directory structure.')
	audit.add_argument(
					'--cleanup',
					nargs='+',
					help='Determine inactive (retired, no longer in, etc.) and active soldiers. Remove inactive orders and directories. Inactive is considered SOLDIER_SSN directories without orders cut from current year to current year minus two years. Automatically consolidate active soldiers orders spanning multiple years and directories into most recent directory. If UICS directory is given, inactive WILL be removed and consolidation by SSN will happen. If ORD_MANAGERS\ORDERS_BY_SOLDIER is given, inactive will NOT be removed and consolidation by SSN will happen. You can pass UICS and ORDERS_BY_SOLDIER as input if desired.'
	)
	audit.add_argument(
					'--report',
					choices=['print', 'outfile'],
					help='Calculate number of UICs, soldiers, certificate, and main orders within output directory and present accordingly. Print will show you simple numbers on screen. Outfile will put detailed results to files.'
	)


	'''
	SEARCHING ORDERS
	Under development.
	'''
	search = parser.add_argument_group('Searching', 'Use these commands for finding and performing actions on orders. This section under development.')
	search.add_argument(
					'--action',
					choices=['remove', 'print', 'combine', 'move'],
					help='Perform [ACTION] on results found by --search.'
	)
	search.add_argument(
					'--path',
					nargs='+',
					help=r'Path to search for orders in. Typically .\OUTPUT\UICS.'
	)
	search.add_argument(
					'--search',
					nargs='+',
					help=r'Search for orders by name, ssn, etc. You can use multiple criteria search for. Typically by name LAST_FIRST_MI or ssn 123-45-6789.'
	)

	'''
	OPTIONAL ARGUMENTS
	'''
	parser.add_argument(
					'--verbose',
					choices=[ 'debug', 'info', 'warning', 'error', 'critical' ],
					default='info',
					help='Enable specific program verbosity. Default is info. Set to debug for complete script processing in logs and screen. Set to warning or critical for minimal script processing in logs and screen.'
	)

	'''
	VERSION
	'''
	parser.add_argument(
					'--version',
					action='version',
					version='[{}] - Version [{}]. Check [{}] for the most up to date information.'.format(program, version, repository)
	)

	args = parser.parse_args()

	'''
	DIRECTORIES
	'''
	directory_working = os.getcwd()
	directory_working_log = os.path.join(directory_working, 'LOGS', date)
	if args.output:
		directory_output_uics = os.path.join(args.output, 'UICS')
		directory_output_ord_managers = os.path.join(args.output, 'ORD_MANAGERS')
		directory_output_ord_registers = os.path.join(directory_output_ord_managers, 'ORD_REGISTERS')
		directory_output_orders_by_soldier = os.path.join(directory_output_ord_managers, 'ORDERS_BY_SOLDIER')
		directory_output_iperms_integrator = os.path.join(directory_output_ord_managers, 'IPERMS_INTEGRATOR')

	'''
	FILES
	'''
	file_working_log = os.path.join(directory_working_log, '{}_{}.log'.format(date, program))

	'''
	DICTIONARIES
	'''
	if args.output:
		dict_directories = {
			'directory_working' : directory_working,
			'directory_working_log' : directory_working_log,
			'directory_output_uics' : directory_output_uics,
			'directory_output_ord_managers' : directory_output_ord_managers,
			'directory_output_ord_registers' : directory_output_ord_registers,
			'directory_output_orders_by_soldier' : directory_output_orders_by_soldier,
			'directory_output_iperms_integrator' : directory_output_iperms_integrator
		}
	else:
		dict_directories = {
			'directory_working' : directory_working,
			'directory_working_log' : directory_working_log
		}

class Statistics:
	def __init__(self, **kwargs):
		for key, value in kwargs.items():
			setattr(self, key, value)

	def output(self):
		'''
		Use two (2) dictionaries (self.__dict__ and dict_data_statistics_output_files to detect if a list contains items, output the appropriate list if so, do not output a file if the list is empty.
		'''
		dict_data_statistics_output_files = {
			'file_list_files_processed' : os.path.join(self.setup.directory_working_log, '{}_files_processed.txt'.format(self.setup.date)),
			'file_list_registry_files_processed' : os.path.join(self.setup.directory_working_log, '{}_registry_files_processed.txt'.format(self.setup.date)),
			'file_list_stats_registry_files_missing' : os.path.join(self.setup.directory_working_log, '{}_registry_files_missing.txt'.format(self.setup.date)),
			'file_list_stats_main_files_missing' : os.path.join(self.setup.directory_working_log, '{}_main_files_missing.txt'.format(self.setup.date)),
			'file_list_stats_certificate_files_missing' : os.path.join(self.setup.directory_working_log, '{}_certificate_files_missing.txt'.format(self.setup.date)),
			'file_list_error_warning' : os.path.join(self.setup.directory_working_log, '{}_error_warning.txt'.format(self.setup.date)),
			'file_list_error_critical' : os.path.join(self.setup.directory_working_log, '{}_error_critical.txt'.format(self.setup.date)),
			'file_list_main_orders_missing' : os.path.join(self.setup.directory_working_log, '{}_main_orders_missing.txt'.format(self.setup.date)),
			'file_list_certificate_orders_missing' : os.path.join(self.setup.directory_working_log, '{}_certificate_orders_missing.txt'.format(self.setup.date)),
			'file_list_main_orders_created_uics' : os.path.join(self.setup.directory_working_log, '{}_main_orders_created_uics.txt'.format(self.setup.date)),
			'file_list_certificate_orders_created_uics' : os.path.join(self.setup.directory_working_log, '{}_certificate_orders_created_uics.txt'.format(self.setup.date)),
			'file_list_main_orders_created_ord_managers' : os.path.join(self.setup.directory_working_log, '{}_main_orders_created_ord_managers.txt'.format(self.setup.date)),
			'file_list_certificate_orders_created_ord_managers' : os.path.join(self.setup.directory_working_log, '{}_certificate_orders_created_ord_managers.txt'.format(self.setup.date)),
			'file_list_main_orders_removed_uics' : os.path.join(self.setup.directory_working_log, '{}_main_orders_removed_uics.txt'.format(self.setup.date)),
			'file_list_certificate_orders_removed_uics' : os.path.join(self.setup.directory_working_log, '{}_certificate_orders_removed_uics.txt'.format(self.setup.date)),
			'file_list_main_orders_removed_ord_managers' : os.path.join(self.setup.directory_working_log, '{}_main_orders_removed_ord_managers.txt'.format(self.setup.date)),
			'file_list_certificate_orders_removed_ord_managers': os.path.join(self.setup.directory_working_log, '{}_certificate_orders_removed_ord_managers.txt'.format(self.setup.date)),
			'file_list_main_orders_combined' : os.path.join(self.setup.directory_working_log, '{}_main_orders_combined.txt'.format(self.setup.date)),
			'file_list_stats_active' : os.path.join(self.setup.directory_working_log, '{}_cleanup_active_not_removed.txt'.format(self.setup.date)),
			'file_list_stats_inactive' : os.path.join(self.setup.directory_working_log, '{}_cleanup_inactive_removed.txt'.format(self.setup.date))
		}
		for key, value in self.__dict__.items():
			if 'list_' in key:
				if len(value) > 0:
					file_output = dict_data_statistics_output_files['file_{}'.format(key)]
					logging.info('Writing [{}] to [{}].'.format(key, file_output))
					with open(file_output, 'w') as f:
						f.write('\n'.join(sorted(value)))

	def present(self):
		if self.action == 'ERROR':
			logging.critical('None or improper parameters passed.\nLook below for most common usage examples.\nTry [{} --help] for more info.\nTry [{}] for full details.'.format(self.setup.program, self.setup.wiki))
			logging.critical('\nExample 1: Create any/all orders from INPUT directory in OUTPUT directory. Directory can contain any number of directories and/or files generated from AFCOS.')
			logging.critical('{} --input {} --output {} --create'.format(self.setup.program, os.path.join(os.getcwd(), 'INPUT', '2017_orders'), os.path.join(os.getcwd(), 'OUTPUT')))
			logging.critical('\nExample 2: Remove any/all orders from INPUT directory in OUTPUT directory. Directory can contain any number of directories and/or files generated from AFCOS.')
			logging.critical('{} --input {} --output {} --remove'.format(self.setup.program, os.path.join(os.getcwd(), 'INPUT', '2017_orders'), os.path.join(os.getcwd(), 'OUTPUT')))
			logging.critical('\nExample 3: Cleanup UICS and ORDERS_BY_SOLDIER. Do this during or after --create use of orders. Full description in Wiki and --help menu.')
			logging.critical('{} --cleanup {} {}'.format(self.setup.program, os.path.join(os.getcwd(), 'OUTPUT', 'UICS'), os.path.join(os.getcwd(), 'OUTPUT', 'ORD_MANAGERS', 'ORDERS_BY_SOLDIER')))
		elif self.action == 'CLEANUP':
			logging.info('{:-^60}'.format(''))
			logging.info('{:+^60}'.format('CLEANUP STATS'))
			logging.info('{:-^60}'.format(''))
			logging.info('{:.<49}{:.>11}'.format('Active Soldiers Not Removed:', len(self.list_stats_active)))
			logging.info('{:.<49}{:.>11}'.format('Inactive Soldiers Removed:', len(self.list_stats_inactive)))
			logging.info('{:-^60}'.format(''))
			logging.info('{:+^60}'.format('RUN TIME STATS'))
			logging.info('{:-^60}'.format(''))
			logging.info('{:.<43}{:.>}'.format('Start time:', self.start))
			logging.info('{:.<43}{:.>}'.format('End time:', self.end))
			logging.info('{:.<54}{:.>}'.format('Run time:', self.run_time))
			logging.info('{:-^60}'.format(''))
		else:
			logging.info('{:-^60}'.format(''))
			logging.info('{:+^60}'.format('{} STATS'.format(self.action)))
			logging.info('{:-^60}'.format(''))
			logging.info('{:.<49}{:.>11}'.format('Files Processed:', len(self.list_files_processed)))
			logging.info('{:.<49}{:.>11}'.format('Registry Files Processed:', len(self.list_registry_files_processed)))
			logging.info('{:.<49}{:.>11}'.format('Registry Files Missing:', len(self.list_stats_registry_files_missing)))
			logging.info('{:.<49}{:.>11}'.format('Registry Lines Processed:', self.stats_registry_lines_processed))
			logging.info('{:.<49}{:.>11}'.format('Error (WARNING):', self.stats_error_warning))
			logging.info('{:.<49}{:.>11}'.format('Error (CRITICAL):', self.stats_error_critical))
			logging.info('{:.<49}{:.>11}'.format('Error (TOTAL):', self.stats_error_warning + self.stats_error_critical))
			logging.info('{:.<49}{:.>11}'.format('Total Orders Missing:', len(self.list_main_orders_missing) + len(self.list_certificate_orders_missing)))
			if self.action == 'CREATE':
				logging.info('{:.<49}{:.>11}'.format('Main Orders Created (UICS):', len(self.list_main_orders_created_uics)))
				logging.info('{:.<49}{:.>11}'.format('Certificate Orders Created (UICS):', len(self.list_certificate_orders_created_uics)))
				logging.info('{:.<49}{:.>11}'.format('Main Orders Created (ORD_MANAGERS):', len(self.list_main_orders_created_ord_managers)))
				logging.info('{:.<49}{:.>11}'.format('Certificate Orders Created (ORD_MANAGERS):', len(self.list_certificate_orders_created_ord_managers)))
				logging.info('{:.<49}{:.>11}'.format('Main Orders Missing:', len(self.list_main_orders_missing)))
				logging.info('{:.<49}{:.>11}'.format('Certificate Orders Missing:', len(self.list_certificate_orders_missing)))
				logging.info('{:.<49}{:.>11}'.format('Orders Created (UICS):', len(self.list_main_orders_created_uics) + len(self.list_certificate_orders_created_uics)))
				logging.info('{:.<49}{:.>11}'.format('Orders Created (ORD_MANAGERS):', len(self.list_main_orders_created_ord_managers) + len(self.list_certificate_orders_created_ord_managers)))
				logging.info('{:.<49}{:.>11}'.format('Orders Created (TOTAL):', len(self.list_main_orders_created_uics) + len(self.list_certificate_orders_created_uics) + len(self.list_main_orders_created_ord_managers) + len(self.list_certificate_orders_created_ord_managers)))
			elif self.action == 'REMOVE':
				logging.info('{:.<49}{:.>11}'.format('Main Orders Removed (UICS):', len(self.list_main_orders_removed_uics)))
				logging.info('{:.<49}{:.>11}'.format('Certificate Orders Removed (UICS):', len(self.list_certificate_orders_removed_uics)))
				logging.info('{:.<49}{:.>11}'.format('Main Orders Removed (ORD_MANAGERS):', len(self.list_main_orders_removed_ord_managers)))
				logging.info('{:.<49}{:.>11}'.format('Certificate Orders Removed (ORD_MANAGERS):', len(self.list_certificate_orders_removed_ord_managers)))
				logging.info('{:.<49}{:.>11}'.format('Main Orders Missing:', len(self.list_main_orders_missing)))
				logging.info('{:.<49}{:.>11}'.format('Certificate Orders Missing:', len(self.list_certificate_orders_missing)))
				logging.info('{:.<49}{:.>11}'.format('Orders Removed (UICS):', len(self.list_main_orders_removed_uics) + len(self.list_certificate_orders_removed_uics)))
				logging.info('{:.<49}{:.>11}'.format('Orders Removed (ORD_MANAGERS):', len(self.list_main_orders_removed_ord_managers) + len(self.list_certificate_orders_removed_ord_managers)))
				logging.info('{:.<49}{:.>11}'.format('Orders Removed (TOTAL):', len(self.list_main_orders_removed_ord_managers) + len(self.list_certificate_orders_removed_ord_managers) + len(self.list_main_orders_removed_ord_managers) + len(self.list_certificate_orders_removed_ord_managers)))
			if self.args.combine:
				logging.info('{:.<49}{:.>11}'.format('Orders Combined (TOTAL):', len(self.list_main_orders_created_uics)))
			logging.info('{:-^60}'.format(''))
			logging.info('{:+^60}'.format('RUN TIME STATS'))
			logging.info('{:-^60}'.format(''))
			logging.info('{:.<43}{:.>}'.format('Start time:', self.start))
			logging.info('{:.<43}{:.>}'.format('End time:', self.end))
			logging.info('{:.<54}{:.>}'.format('Run time:', self.run_time))
			logging.info('{:-^60}'.format(''))

def main():
	'''
	Main function. Everything starts here.
	'''
	setup = Setup()
	args = setup.args

	'''
	Create required directories from setup.
	'''
	for key, value in setup.dict_directories.items():
		if not os.path.exists(value):
			os.makedirs(value)

	'''
	Setup logging.
	'''
	dict_levels = {
		'debug': logging.DEBUG,
		'info': logging.INFO,
		'warning': logging.WARNING,
		'error': logging.ERROR,
		'critical': logging.CRITICAL,
	}
	level_name = args.verbose
	level = dict_levels.get(level_name)
	format = '[%(asctime)s] - [%(levelname)s] - %(message)s'
	handlers = [logging.FileHandler(setup.file_working_log), logging.StreamHandler()]
	logging.basicConfig(
		level = level,
		format = format,
		handlers = handlers
	)

	'''
	Present what arguments and parameters are being used. Useful for developer and user of script to easily start troubleshooting by having as much info in logs as possible.
	'''
	logging.info('Hello {}! You are running [{}] with the following arguments: '.format(setup.user, setup.program))
	for a in args.__dict__:
		logging.info(str(a) + ' : ' + str(args.__dict__[a]))

	start = time.strftime('%m-%d-%y %H:%M:%S')
	start_time = timeit.default_timer()

	'''
	Argument handling.
	'''
	if args.input and args.output and args.create:
		var_statistics_action = 'CREATE'
		dict_data = {
			'setup' : setup,
			'args' : setup.args,
			'gather_files_input' : args.input,
			'dict_directory_files' : {}
		}
		dict_directory_files = Process(**dict_data).gather_files()
		dict_data = {
			'action' : var_statistics_action,
			'setup' : setup,
			'args' : setup.args,
			'process_files_input': dict_directory_files,
			'original_list_files_processed' : [],
			'list_orders_to_combine' : [],
			'list_years_processed' : []
		}
		Process(**dict_data).process_files()
		if args.cleanup:
			dict_data = {
				'list_cleanup_path' : args.cleanup,
				'list_cleanup_directories_orders' : [],
				'cleanup_current_year' : str(datetime.now().year),
				'cleanup_current_year_minus_one' : str(datetime.now().year - 1),
				'cleanup_current_year_minus_two' : str(datetime.now().year - 2),
				'file_cleanup_active_txt' : os.path.join(setup.directory_working_log, '{}_active.txt'.format(setup.user)),
				'file_cleanup_inactive_txt' : os.path.join(setup.directory_working_log, '{}_inactive.txt'.format(setup.user)),
				'file_cleanup_original_directories_csv' : os.path.join(setup.directory_working_log, '{}_directories.csv'.format(setup.user)),
				'file_cleanup_empty_directories_txt' : os.path.join(setup.directory_working_log, '{}_empty_dirs.txt'.format(setup.user)),
				'list_cleanup_ssn' : []
			}
			dict_data['list_cleanup_years_to_consider_active'] = [
				dict_data['cleanup_current_year'],
				dict_data['cleanup_current_year_minus_one'],
				dict_data['cleanup_current_year_minus_two']
			]
			Process(**dict_data).cleanup()
		sys.exit()
	if args.input and args.output and args.remove:
		var_statistics_action = 'REMOVE'
		dict_data = {
			'setup' : setup,
			'args' : setup.args,
			'gather_files_input' : args.input,
			'dict_directory_files' : {}
		}
		dict_directory_files = Process(**dict_data).gather_files()
		dict_data = {
			'action' : var_statistics_action,
			'setup' : setup,
			'args' : setup.args,
			'process_files_input': dict_directory_files,
			'original_list_files_processed' : [],
			'list_orders_to_combine' : [],
			'list_years_processed' : []
		}
		Process(**dict_data).process_files()
		if args.cleanup:
			dict_data = {
				'list_cleanup_path' : args.cleanup,
				'list_cleanup_directories_orders' : [],
				'cleanup_current_year' : str(datetime.now().year),
				'cleanup_current_year_minus_one' : str(datetime.now().year - 1),
				'cleanup_current_year_minus_two' : str(datetime.now().year - 2),
				'file_cleanup_active_txt' : os.path.join(setup.directory_working_log, '{}_active.txt'.format(setup.user)),
				'file_cleanup_inactive_txt' : os.path.join(setup.directory_working_log, '{}_inactive.txt'.format(setup.user)),
				'file_cleanup_original_directories_csv' : os.path.join(setup.directory_working_log, '{}_directories.csv'.format(setup.user)),
				'file_cleanup_empty_directories_txt' : os.path.join(setup.directory_working_log, '{}_empty_dirs.txt'.format(setup.user)),
				'list_cleanup_ssn' : []
			}
			dict_data['list_cleanup_years_to_consider_active'] = [
				dict_data['cleanup_current_year'],
				dict_data['cleanup_current_year_minus_one'],
				dict_data['cleanup_current_year_minus_two']
			]
			Process(**dict_data).cleanup()
		sys.exit()
	if args.report and args.output:
		dict_data = {
			'setup' : Setup(),
			'args' : args,
			'var_output' : args.report,
			'directory_output_uics' : setup.directory_output_uics,
			'directory_output_orders_by_soldier' : setup.directory_output_orders_by_soldier
		}
		Process(**dict_data).report()
		if args.cleanup:
			dict_data = {
				'list_cleanup_path' : args.cleanup,
				'list_cleanup_directories_orders' : [],
				'cleanup_current_year' : str(datetime.now().year),
				'cleanup_current_year_minus_one' : str(datetime.now().year - 1),
				'cleanup_current_year_minus_two' : str(datetime.now().year - 2),
				'file_cleanup_active_txt' : os.path.join(setup.directory_working_log, '{}_active.txt'.format(setup.user)),
				'file_cleanup_inactive_txt' : os.path.join(setup.directory_working_log, '{}_inactive.txt'.format(setup.user)),
				'file_cleanup_original_directories_csv' : os.path.join(setup.directory_working_log, '{}_directories.csv'.format(setup.user)),
				'file_cleanup_empty_directories_txt' : os.path.join(setup.directory_working_log, '{}_empty_dirs.txt'.format(setup.user)),
				'list_cleanup_ssn' : []
			}
			dict_data['list_cleanup_years_to_consider_active'] = [
				dict_data['cleanup_current_year'],
				dict_data['cleanup_current_year_minus_one'],
				dict_data['cleanup_current_year_minus_two']
			]
			Process(**dict_data).cleanup()
		sys.exit()
	else:
		var_statistics_action = 'ERROR'
		dict_data = {
			'action' : var_statistics_action,
			'setup' : setup
		}
		Statistics(**dict_data).present()
		sys.exit()
'''
Entry point of script.
'''
if __name__ == '__main__':
	main()
