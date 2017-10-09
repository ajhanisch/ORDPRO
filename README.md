# **ORDPRO.ps1**  
Order processing.  
  
Orders management automation.  

Author: Ashton J. Hanisch < <ajhanisch@gmail.com> >  
  
Disclaimer: I do not claim to be a PowerShell expert. I do know there can be improvements made in the code itself to improve flow and functionality. I would be more than happy to hear about any constructive critiques the experts out there amongst us would have and would love to work through any proposed solutions.  
  
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
- ......... 

# **WISH LIST / TO DO**  
- [ ] 
  
