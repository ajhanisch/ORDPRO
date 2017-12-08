# **ORDPRO**   
  
Orders Processor.  
  
Orders Management Automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates processing, auditing, searching, splitting, editing, combining, creating, removing, and overall management of orders.
  
# **DESCRIPTION**  
Script designed to assist in management and processing of orders given in the format of a single file or multiple files containing numerous orders, from one to thousands of orders to organized directory structure by 'UICS\\[UIC]\\[SOLDIER]\\ORDER_N'. This allows for a more organized look and viewing of orders processed on a daily basis or in large batches of historical orders.
    
# **FEATURES**  
Automated parsing, splitting, editing, and organizing, orders. Detailed verbosity of script processing during runtime. Detailed logging of all parameters and output.
    
# **DOCUMENTATION**  
Check out the README and Wiki page for detailed information. ++ WIKI UNDER CONSTRUCTION ++. Since translating from powershell to python, the wiki is currently out of date.

# **USAGE**  
Running the tool:  
.\ORDPRO.py [options]
  
Typical Usage Example:  
.\ORDPRO.py --input \\\path\to\input --output \\\path\to\output --create
  
Options:   
  
Check the Wiki for detailed information on all CLI parameters and switches.
  
# **WISH LIST / TO DO**  
- [ ] Implement notification of when orders are processed
