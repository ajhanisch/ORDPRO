# **ORDPRO.ps1**  
Orders Processor.  
  
Orders management automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates splitting, editing, combining, processing, and managing of orders. Includes CLI and TUI verions.  
* CLI (Command Line Interface)  
![ ] (images/cli.PNG)  
  
* TUI (Text-based User Interface)  
![ ] (images/tui.PNG)
  
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
  
| Step # |  Parameter   | Alias |                                                                                                               Result                                                                                                               |                                                                                                     Additional Considerations                                                                                                     |
|--------|--------------|-------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|      1 | dir_create   | d     | Create required directories in working directory and output directory.                                                                                                                                                             | Requires -o "\\\path\" to be used as well                                                                                                                                                                                         |
|      2 | split_main   | sm    | Split orders in '*m.prt' file(s) in current directory into individual order files                                                                                                                                                  | Ensure to pass or already passed -d to create working directories                                                                                                                                                                 |
|      3 | edit_main    | em    | Edit the split order files from the '*m.prt' files in current directory                                                                                                                                                            | Editing includes removing unwanted FOUO lines, line breaks, spacing, etc                                                                                                                                                          |
|      4 | magic_main   | mm    | Magic function on '*m.prt' files. Parses files and extracts key information, create directory structure based on info extracted, and moves split and edited orders to final destinations within defined output directory structure | Steps 1-4 must be performed before step 7.                                                                                                                                                                                        |
|      5 | split_cert   | sc    | Split certificates in '*c.prt' file(s) in current directory into individual order files                                                                                                                                            | Ensure to pass or already passed -d to create working directories                                                                                                                                                                 |
|      6 | edit_cert    | ec    | Edit the split certificates from the '*c.prt' files in current directory                                                                                                                                                           | Editing includes removing unwanted FOUO lines, line breaks, spacing, etc                                                                                                                                                          |
|      7 | magic_cert   | -mc   | Magic function on '*c.prt' files. Parses files and extracts key information, moves split and edited certificates within defined output directory                                                                                   | This parameter relies on the results of the -mm to work properly.                                                                                                                                                                 |
|      8 | combine_main | -cm   | (Optional) Combines split and edited order files into single txt file to be used later                                                                                                                                             | Ensure to split and edit '*m.prt' files before running this command                                                                                                                                                               |
|      9 | combine_cert | -cc   | (Optional) Combines split and edited certificate files into single txt file to be used later                                                                                                                                       | Ensure to split and edit '*c.prt' files before running this command                                                                                                                                                               |
|     10 | clean_main   | -xm   | (Optional) Cleans all files and directories out of the current directory .\TMP\MOF                                                                                                                                                 | This directory contains originals of the split order files as well as edited versions                                                                                                                                             |
|     11 | clean_cert   | -xc   | (Optional) Cleans all files and directories out of the current directory .\TMP\COF                                                                                                                                                 | This directory contains originals of the split certificate files as well as edited versions                                                                                                                                       |
|     12 | clean_uics   | -xu   | (Optional) Cleans all files and directories out of the output directory .\{OUTPUT_DIR}\UICS                                                                                                                                        | This directory contains the results of the -mm and -mc parameters including edited and moved order and certificate files . Ensure to pass the -o "\\path\" with this parameter to tell script where the UICS directory is located |
|     13 | permissions  | -p    | (Optional) Gathers and outputs to .csv file the permissions of the .\{OUTPUT_DIR}\UICS directory                                                                                                                                   | Ensure to pass the -o "\\path\" with this parameter to tell the script where the UICS directory is located                                                                                                                        |
|     14 | backups      | -b    | (Optional) Performs archival backup of the original '*m.prt', '*c.prt', '*r.prt', and '*r.reg' files in the current working directory                                                                                              | This should be ran after all other desired operations have been done                                                                                                                                                              |
|     15 | all          | -a    | (Optional) Performs all required steps to be successful for you in one parameter.                                                                                                                                                  | Ensure to include the -o "\\path\" with this parameter to tell the script where you want output to go                                                                                                                             |
|     16 | -Verbose     |       | (Optional) Including this parameter with any other parameter will output detailed verbosity of script processing.                                                                                                                  | Omitting this parameter will result in a detailed progress bar presented rather than detailed verbosity in the console                                                                                                            |






  
# **WISH LIST / TO DO**  
- [ ] Assign permissions to each UIC folder as needed automatically during processing
- [ ] Implement some type of notification of when orders are processed
- [ ] Orders follow individuals as they move UICS
- [ ] Implement web front end and/or database backend to store, query, and present split, edited, parsed, and moved output to users from central controlled location
- [ ] Implement a checkpoint system
- [ ] Implement parallel processing
- [x] Extract all functions and create individual module files to be called from main script
- [ ] Implement a configuration .xml file for script settings
- [ ] Implement an undo function to remove results of previously ran sessions
  
