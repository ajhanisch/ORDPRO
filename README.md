# **ORDPRO.ps1**   
  
Orders Processor.  
  
Orders management automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates splitting, editing, combining, processing, and managing of orders. Includes CLI and TUI verions. 
  
# **DESCRIPTION**  
Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
    
# **FEATURES**  
Automated parsing, organization, and backup of daily orders published. Detailed verbosity of script processing during runtime. Administrative commands during run time. Detailed logging of all parameters and output. Detailed progress bar information when '-Verbose' parameter is not passed for a cleaner, smoother feel during processing. Detailed reports of failure and successes of each parameter for easier troubleshooting. Single parameter to run all required parameters. All required processes have their own parameter so user can run steps manually if needed to make troubleshooting easier.
      
# **CONSIDERATIONS**  
ORDPRO comes built in with runtime commands to make life of the script user easier. Runtime commands currently built in are as follows.

	+----------------------+--------------+
	| Keyboard Combination |    Result    |
	+----------------------+--------------+
	| CTRL + P             | Pause script |
	| CTRL + Q             | Quit script  |
	+----------------------+--------------+  
    
# **DOCUMENTATION**  
Check out the README and Wiki page for detailed information.

# **USAGE**  
Running the tool:  
.\ORDPRO.ps1 [options]
  
Typical Usage Example:  
.\ORDPRO.ps1 -a -i "\\\path\to\input" -o "\\\path\to\output"
  
Options:   
  
Check the Wiki for detailed information on all CLI parameters and switches.
  
# **WISH LIST / TO DO**  
- [ ] Assign permissions to each UIC folder as needed automatically during processing
- [ ] Implement some type of notification of when orders are processed
- [ ] Orders follow individuals as they move UICS
- [ ] Implement web front end and/or database backend to store, query, and present split, edited, parsed, and moved output to users from central controlled location
- [ ] Implement a checkpoint system
- [ ] Implement parallel processing
- [x] Extract all functions and create individual module files to be called from main script
- [ ] Implement a configuration file for settings
- [x] Implement an undo function to remove results of previously ran sessions
  
