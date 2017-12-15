# **ORDPRO**   
  
Orders Processor.  
  
Orders Management Automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates processing, auditing, searching, splitting, editing, combining, creating, removing, and overall management of orders.
  
# **DESCRIPTION**  
Script designed to assist in management and processing of orders given in the format of a single file or multiple files containing numerous orders, from one to thousands of orders to organized directory structure. This allows for a more organized look and viewing of orders processed on a daily basis or in large batches of historical orders.
    
# **FEATURES**  
Automated parsing, splitting, editing, and organizing, orders. Detailed verbosity of script processing during runtime. Detailed logging of all parameters and output.
    
# **DOCUMENTATION**  
++ WIKI UNDER CONSTRUCTION ++. Since translating from powershell to python, the wiki is currently out of date. Working to update this.

# **INSTALLATION**  
There are two different ways to get ordpro up and running. Both are very painless, one easier than the other.  
1. [Recommended] - **ordpro.exe** -- No installation required. Simply place **ordpro.exe** on the machine you deem your orders processing machine and it is ready to run immediately.

2. **ordpro.py** -- Installation of Python 3.6 is required on any machine running **ordpro.py**. While this is not complicated, it is simply an additional step that is needed in order to be up and running for processing orders.

# **USAGE**  
Running the tool:  
.\ordpro.exe [options]
  
Typical Usage Example:  
.\ordpro.exe --input \\\path\to\input --output \\\path\to\output --create
  
Options:   
  
Check the Wiki for detailed information on all CLI parameters and switches.
  
# **WISH LIST / TO DO**  
- [ ] Implement notification of when orders are processed
- [ ] Implement individual UIC 'registry file' for admins to see who/what/when orders were cut for that UIC
- [ ] Implement ability for soldiers' directories within UIC to move more often then when orders are cut
