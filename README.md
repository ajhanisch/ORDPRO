# **ORDPRO**   

Orders Processor.  

Orders Management Automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  

# **SYNOPSIS**  
Orders Processor (Ordpro) is a script written in Python designed to automate processing orders.

# **DESCRIPTION**  
Orders Processor (Ordpro) is a program originally written in PowerShell, translated to and enhanced by Python, additionally compiled to an .exe designed to help automate the processing, handling, splitting, editing, combining, copying, moving, organizing, and archiving of orders given in the format of one or more documents containing one to many orders on a daily basis and or processing any number of historical orders originally generated and output from an orders generating system called AFCOS. Allowing state-level and unit-level administrators to access, view, print, and manage orders for their unit/state easily.

# **FEATURES**  
* Logging  

Detailed logging of any and all actions performed by Ordpro will be within the LOGS directory of the working directory Ordpro is placed. Logging information is extremely detailed within each log file including times when all actions were taken, log level of each action, what action was performed, the success or failure of each action, as well as statistics of actions performed presented throughout. The log files are detailed and designed to allow users to answer questions about what actually happened when they used Ordpro, as well as make any potential debugging and or troubleshooting that much simpler. Detailed logging takes place regardless of verbosity enabled or disabled during time of processing.  

* PERMS Automation  

 Ordpro bridges the gap of orders being processed and them quickly making it to each soldiers PERMS. When the user specifies the `--combine` option when creating orders, Ordpro will combine the created orders into files that contain no more than two-hundred and fifty (250) orders in them to be immediately input into PERMS integrator with no manual editing or user interaction. This feature does the required editing and combining of orders, previously manually done by the unit administrator for each soldier. This feature allows a soldiers orders to be put into PERMS the same day, or hour for that matter, the order was published and distributed within AFCOS. This feature has helped a state-wide amount of soldiers PERMS data to be caught up from more than two (2) years behind in initial building of Ordpro in a matter of minutes.  

* Verbosity  

Detailed verbosity of script processing, mirroring the output within the log files, can be enabled in the console to allow the user to see the actions happen in real time. This is completely optional for the user. User can change verbosity levels using `--verbose LEVEL` with options of level [debug, info, warning, error, critical] with debug including all script processing and critical including only critical errors.

# **DOCUMENTATION**  
Check out the Wiki page for all documentation.

# **INSTALLATION**  
1. **ordpro.py** -- Installation of Python 3.6.X is required on any machine running **ordpro.py**. While this is not complicated, it is simply an additional step that is needed in order to be up and running for processing orders.
2. **ordpro.exe** -- NO INSTALLATION of Python 3.6.X is required for the compiled .exe version of Ordpro. This is included for windows users to save the step of Python installation in their environment if desired. With this version, users simply need to place ordpro.exe on any machine(s) they desire to process orders on.
# **USAGE**  
Running the tool:  
`.\ordpro.py [options]`

Typical Usage Example:  
`.\ordpro.py --input \\path\to\input --output \\path\to\output --create --combine`

Options:   

Check the Wiki for detailed information on all options and initial use examples.

# **WISH LIST / TO DO**  
- [ ] Implement web application front end using virtual environment and flask
- [ ] Implement multi threading
- [ ] Implement notification of when orders are processed
- [ ] Implement individual UIC 'registry file' for admins to see who/what/when orders were cut for that UIC
- [ ] Implement ability for soldiers' directories within UIC to move more often then when orders are cut
