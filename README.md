# **ORDPRO.ps1**   
  
Orders Processor.  
  
Orders Management Automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
# **SYNOPSIS**  
Automates splitting, editing, combining, processing, and managing of orders.
  
# **DESCRIPTION**  
Script designed to assist in management and processing of orders given in the format of a single file or files containing numerous orders, from one to thousands of orders. Script to go from one single file containing any number of orders to organized directory structure by 'UIC\SOLDIER' to allow for a more organized look and viewing of orders processed on a daily basis or in large batches of historical orders.
    
# **FEATURES**  
Automated parsing, splitting, editing, and organizing, orders. Detailed verbosity of script processing during runtime. Detailed logging of all parameters and output. Debugging options available.
    
# **DOCUMENTATION**  
Check out the README and Wiki page for detailed information.

# **USAGE**  
Running the tool:  
.\ORDPRO.ps1 [options]
  
Typical Usage Example:  
.\ORDPRO.ps1 -i "\\\path\to\input" -o "\\\path\to\output" -Verbose
  
Options:   
  
Check the Wiki for detailed information on all CLI parameters and switches.
  
# **WISH LIST / TO DO**  
- [ ] Assign permissions to each UIC folder as needed automatically
- [ ] Implement notification of when orders are processed
- [ ] Orders follow individuals as they move
- [ ] Implement a checkpoint system
- [ ] Implement parallel processing
- [x] Extract all functions and create individual module files to be called from main script
- [ ] Implement an undo function to remove results of previously ran sessions
- [ ] Look at possibly reworking the functionality to a C# application with a true UI
- [x] Significantly simplify orders splitting, editing, and parsing to gather variable information (major update)
  
