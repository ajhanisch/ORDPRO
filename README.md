# **ORDPRO.ps1**  
Order processing.  
  
Orders management automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates splitting of orders file, creates UIC/SSN based folder structure, moves orders to SSN folders, moves orders to historical folders, backs up folder structure, assigns permissions to folders, notifies users of newly published and organized orders.
  
# **DESCRIPTION**  
Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
    
# **FEATURES**  
Automated parsing, organization, backup, permissions assignment, and notification of daily orders published.
      
# **CONSIDERATIONS**  
None currently.
    
# **DOCUMENTATION**  
Check out the Wiki for specific guidance.  

# **USAGE**  
Running the tool:  
.\ORDPRO.ps1 [options]  
  
Typical Usage Example:  
.\ORDPRO.ps1
  
Options: 
  
| Step # | Parameter |                                                                      Result                                                                      |                                                Additional Considerations                                                 |  |
|--------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|--|
|    1   |    -d     | Create required directories in working directory and output directory                                                                            | Requires -o "\\path\" to be used as well                                                                                 |  |
|    2   |    -sm    | Split orders in '*m.prt' file(s) in current directory into individual order files                                                                | Ensure to pass or already passed -d to create working directories                                                        |  |
|    3   |    -em    | Edit the split order files from the '*m.prt' files in current directory                                                                          | Editing includes removing unwanted FOUO lines, line breaks, spacing, etc                                                 |  |
|    4   |    -mm    | Magic function on '*m.prt' files. Parses files and extracts key information, create directory structure based on info extracted,                 |                                                                                                                          |  |
|        |           | and moves split and edited orders to final destinations within defined output directory structure                                                | Steps 1-4 must be performed before step 7.                                                                               |  |
|    5   |    -sc    | Split certificates in '*c.prt' file(s) in current directory into individual order files                                                          | Ensure to pass or already passed -d to create working directories and run steps 1-4 before this step                     |  |
|    6   |    -ec    | Edit the split certificates from the '*c.prt' files in current directory                                                                         | Editing includes removing unwanted FOUO lines, line breaks, spacing, etc                                                 |  |
|    7   |    -mc    | Magic function on '*c.prt' files. Parses files and extracts key information, moves split and edited certificates within defined output directory | This parameter relies on the results of the -mm to work properly.                                                        |  |
|    8   |    -cm    | (Optional). Combines split and edited order files into single txt file to be used later                                                          | Ensure to split and edit '*m.prt' files before running this command                                                      |  |
|    9   |    -cc    | (Optional). Combines split and edited certificate files into single txt file to be used later                                                    | Ensure to split and edit '*c.prt' files before running this command                                                      |  |
|   10   |    -xm    | (Optional). Cleans all files and directories out of the current directory .\TMP\MOF                                                              | This directory contains originals of the split order files as well as edited versions                                    |  |
|   11   |    -xc    | (Optional). Cleans all files and directories out of the current directory .\TMP\COF                                                              | This directory contains originals of the split certificate files as well as edited versions                              |  |
|   12   |    -xu    | (Optional). Cleans all files and directories out of the output directory .\{OUTPUT_DIR}\UICS                                                     | This directory contains the results of the -mm and -mc parameters including edited and moved order and certificate files |  |
|        |           |                                                                                                                                                  | Ensure to pass the -o "\\path\" with this parameter to tell script where the UICS directory is located                   |  |
|   13   |    -p     | (Optional). Gathers and outputs to .csv file the permissions of the .\{OUTPUT_DIR}\UICS directory                                                | Ensure to pass the -o "\\path\" with this parameter to tell the script where the UICS directory is located               |  |
|   14   |    -b     | (Optional). Performs archival backup of the original '*m.prt', '*c.prt', '*r.prt', and '*r.reg' files in the current working directory           | This should be ran after all other desired operations have been done                                                     |  |
|   15   |    -a     | (Optional). Performs all required steps to be successful for you in one parameter.                                                               | Ensure to include the -o "\\path\" with this parameter to tell the script where you want output to go                    |  |


# **WISH LIST / TO DO**  
- [ ] 
  
