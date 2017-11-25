# **ORDPRO**   
  
Orders Processor.  
  
Orders Management Automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates splitting, editing, combining, processing, and managing of orders.
  
# **DESCRIPTION**  
Script designed to assist in management and processing of orders given in the format of a single file or multiple files containing numerous orders, from one to thousands of orders to organized directory structure by 'UICS\\[UIC]\\[SOLDIER]\\ORDER_N'. This allows for a more organized look and viewing of orders processed on a daily basis or in large batches of historical orders.
    
# **FEATURES**  
Automated parsing, splitting, editing, and organizing, orders. Detailed verbosity of script processing during runtime. Detailed logging of all parameters and output.
    
# **DOCUMENTATION**  
Check out the README and Wiki page for detailed information.

# **USAGE**  
Running the tool:  
.\ORDPRO.py [options]
  
Typical Usage Example:  
.\ORDPRO.py "\\\path\to\input" "\\\path\to\output" --verbose
  
Options:   
  
Check the Wiki for detailed information on all CLI parameters and switches.
  
# **WISH LIST / TO DO**  
- [ ] Assign permissions to each UIC folder as needed automatically
- [ ] Implement notification of when orders are processed
- [ ] Implement an undo function to remove results of previously ran sessions
- [ ] Look at possibly reworking the functionality to a C# application with a true UI
- [x] Significantly simplify orders splitting, editing, and parsing to gather variable information (major update)
- [x] rewrite from powershell to python
  
