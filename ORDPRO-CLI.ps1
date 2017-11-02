<#
.Synopsis
   Script to help automate order management.
.DESCRIPTION
   Script designed to assist in management and processing of orders. Given input of any number of '*m.prt' and '*c.prt' files in the same directory as ORDPRO, it begins by splitting each order within the pared '*m.prt' and '*c.prt' files into individual order files. These files contain numerous known bad strings and spacing at this point. From there ORDPRO will edit each file to remove the known bad strings and spacing. After splitting and editing, ORDPRO will begin capturing the desired information from each order file in order to create the directory structure desired. During the data capturing phase, it will use the data captured to create the directory structure and move the split and edited orders to their appropiate locations in the structure. During this time it will also assign permissions to the structure as needed. Once all splitting, editing, data capturing, structure creation, order moving, and permissions assignment has happened it will create archival backups of the original '*m.prt' and '*c.prt' files in '.\ARCHIVE\YY_orders' directory where YY represents the last two digits of the current year.
.PARAMETER help
   Help page. Alias: 'h'. This parameter tells ORDPRO you want to learn more about it. It will display this page after running the command 'Get-Help .\ORDPRO.ps1 -Full' for you.
.PARAMETER version
   Version information. Alias: 'v'. This parameter tells ORDPRO you want to check its version number.
.PARAMETER output_dir
   Version information. Alias: 'o'. This parameter tells ORDPRO where you want the output to go. Give it the full UNC path to the directory you want output to land and it will do the rest.
.PARAMETER input_dir
   Version information. Alias: 'i'. This parameter tells ORDPRO where you want the input files to come from. Give it the full UNC path to the directory containing the '*m.prt', '*c.prt', '*r.prt', and the '*r.reg*' files and it will do the rest.
.PARAMETER dir_create
   Directory creation. Alias: 'd'. This parameter tells ORDPRO to create the required directories for ORDPRO to process in working directory and output to land given the 'o' parameter.
.PARAMETER backups
   Backup original order files. Alias: 'b'. This parameter tells ORDPRO to create backups of all files in current directory to the archive directory.
.PARAMETER split_main
   Split main order files with '*m.prt' name. Alias: 'sm'. This parameter tells ORDPRO to split the main '*m.prt' file into individual unedited order files.
.PARAMETER split_cert
   Split certificate order files with '*c.prt' name. Alias: 'sc'. This parameter tells ORDPRO to split the main '*c.prt' file into individual unedited certificate order files.
.PARAMETER edit_main
   Edit main order files. Alias: 'em'. This parameter tells ORDPRO to edit the split files created from use of the 'sm' parameter. Editing includes removing known bad strings and spacing resulting from the splitting of the original '*m.prt' file.
.PARAMETER edit_cert
   Edit certificate order files. Alias: 'ec'. This parameter tells ORDPRO to edit the split files created from use of the 'sc' parameter. Editing includes removing known bad strings and spacing resulting from the splitting of the original '*c.prt' file.
.PARAMETER combine_main
   Combine main order files. Alias: 'cm'. This parameter tells ORDPRO to combine the split and edited edited main order files into a single document to be used at a later date.
.PARAMETER combine_cert
   Combine certificate order files. Alias: 'cc'. This parameter tells ORDPRO to combine the split and edited certificate order files into a single document to be used at a later date.
.PARAMETER magic_main
   Magic work on main orders. Alias: 'mm'. This parameter tells ORDPRO to parse the split and edited main order files, create directory structure based on parsed data, and put orders in appropriate directories.
.PARAMETER magic_cert
   Magic work on certificate orders. Alias: 'mc'. This parameter tells ORDPRO to parse the split and edited certificate order files, create directory structure based on parsed data, and put orders in appropriate directories. If you are not using the 'all' parameter, make sure to run 'magic_main' or 'mm' before this parameter.
.PARAMETER clean_main
   Cleanup main order files. Alias: 'xm'. This parameter tells ORDPRO to cleanup the '.\TMP\MOF' directory of all files and directories.
.PARAMETER clean_cert
   Cleanup certificate order files. Alias: 'xc'. This parameter tells ORDPRO to cleanup the '.\TMP\COF' directory of all files and directories.
.PARAMETER clean_uics
   Cleanup UICS directory. Alias: 'xu'. This parameter tells ORDPRO to cleanup the output UICS directory of all UICS directories. This parameter is NOT used when 'all' is used. This is typically only for development and administrative use. The 'o' parameter is required for use with the parameter as it cleans up the UICS directory in the output directory.
.PARAMETER permissions
   Get permissions of the output UICS directory recursively. Alias: 'p'. This parameter tells ORDPRO to recursively get the permissions of each file and directory in the UICS directory. Output includes a .csv file, .html report, and a .txt file.
.PARAMETER set_permissions
   Set permissions of the output UICS directory recursively to 'READ' for each UIC parsed. Alias: 'sp'.
.PARAMETER undo_previous
   Remove any number of order files given as input from previously ran sessions of ORDPRO. Alias: 'u'. Place the .csv files of previously ran sessions of ORDPRO (the {time_ran}_orders_created_{main,cert}.csv) files into the '.\ORDPRO\TMP\REMOVE' directory and run this parameter. It will look for all of the files in the .csv's given and remove them from the 'UICS' and 'ORD_MANAGERS\ORDERS_BY_SOLDIER' directories.
.PARAMETER all
   All parameters. Alias: 'a'. This parameter tells ORDPRO to run all required parameters needed to be successful. Most common parameter to those new to using ORDPRO.
.INPUTS
   ORDPRO parses all '*m.prt' and '*c.prt' files in current directory. ORDPRO archives '*r.prt' and '*r.reg*' files to '.\ARCHIVE\YY_orders' directory with YY being the last 2 digits of the current year.
.OUTPUTS
   ORDPRO automatically creates required output directory structure, splits, edits, and moves orders to their appropiate location in the created structure. Output includes detailed results of success and failure of each parameter to .csv files in the '.\LOGS\<RUN_DATE>' directory to be viewed during troubleshooting and future reporting purposes as well as detailed logging of all parameter use when any parameter is combined with the 'Verbose' paramter. 
.EXAMPLE
    .\ORDPRO.ps1 -all -i "\\path\to\input" -output_dir "\\path\to\output" -Verbose

    Run all required parameters for success while including detailed verbosity output.

    Short version of command would be .\ORDPRO.ps1 -a -i "\\path\to\input" -o "\\path\to\output" -Verbose
.EXAMPLE
    .\ORDPRO.ps1 -all -i "\\path\to\input" -output_dir "\\path\to\your\desired\output\directory"

    Run all required parameters for success showing detailed progress bar information.

    Short version of command would be .\ORDPRO.ps1 -a -i "\\path\to\input" -o "\\path\to\output"
.EXAMPLE
    .\ORDPRO.ps1 [options] -Verbose
    
    View detailed output of ORDPRO processing information during ORDPRO use. 
    
    Adding the 'Verbose' parameter to any command passed to ORDPRO will result in very detailed verbosity of ORDPRO actions and processing. This is desired when wanting to learn more of ORDPRO functionality as well as for logging purposes.
.EXAMPLE
    .\ORDPRO.ps1 [options]

    View detailed progess bar instead of verbose processing information during ORDPRO use.

    Omitting 'Verbose' will result in detailed progress bar information for each parameter. This is desired when wanting cleaner, more user friendly processing information presentation.
.NOTES
   NAME: ORDPRO.ps1 (Order Processing)
   AUTHOR: Ashton J. Hanisch
   TROUBLESHOOTING: All ORDPRO output will be in '.\TMP\LOGS' directory. Should you have any problems ORDPRO use, email ajhanisch@gmail.com with a description of your issue and the log file that is associated with your problem.
   SUPPORT: For any issues, comments, concerns, ideas, contributions, etc. to any part of ORDPRO or its functionality, reach out to me at ajhanisch@gmail.com. I am open to any thoughts you may have to make this work better for you or things you think are broken or need to be different. I will ensure to give credit where credit is due for any contributions or improvement ideas that are shared.
   UPDATES: To check out any updates or revisions made to ORDPRO check out the updated CHANGELOG file with ORDPRO or check out the gitlab link below for the most recent information.
   
   ADMINISTRATIVE COMMANDS: ORDPRO comes built in with runtime commands to make life of ORDPRO user easier. Runtime commands currently built in are as follows.

	+----------------------+--------------+
	| Keyboard Combination |    Result    |
	+----------------------+--------------+
	| CTRL + P             | Pause ORDPRO |
	| CTRL + Q             | Quit ORDPRO  |
	+----------------------+--------------+  
.LINK
   https://gitlab.com/ajhanisch/ORDPRO
#>

<#
PARAMETERS
#>
[CmdletBinding()]
param(
    [alias('h')][switch]$help,
    [alias('v')][switch]$version,
    [alias('o')][string]$output_dir,
    [alias('i')][string]$input_dir,
    [alias('d')][switch]$dir_create,
    [alias('b')][switch]$backups,
    [alias('sm')][switch]$split_main,
    [alias('sc')][switch]$split_cert,
    [alias('em')][switch]$edit_main,
    [alias('ec')][switch]$edit_cert,
    [alias('cm')][switch]$combine_main,
    [alias('cc')][switch]$combine_cert,
    [alias('mm')][switch]$magic_main,
    [alias('mc')][switch]$magic_cert,
    [alias('xm')][switch]$clean_main,
    [alias('xc')][switch]$clean_cert,
    [alias('xu')][switch]$clean_uics,
    [alias('p')][switch]$permissions,
    [alias('sp')][switch]$set_permissions,
    [alias('u')][switch]$undo_previous,
    [alias('a')][switch]$all
)


<#
REQUIRED SCRIPTS
#>
try {
    . (".\__FUNCTIONS\Archive-Directory.ps1")
    . (".\__FUNCTIONS\Clean-OrdersCertificate.ps1")
    . (".\__FUNCTIONS\Clean-OrdersMain.ps1")
    . (".\__FUNCTIONS\Clean-UICS.ps1")
    . (".\__FUNCTIONS\Combine-OrdersCertificate.ps1")
    . (".\__FUNCTIONS\Combine-OrdersMain.ps1")
    . (".\__FUNCTIONS\Create-RequiredDirectories.ps1")
    . (".\__FUNCTIONS\Edit-OrdersCertificate.ps1")
    . (".\__FUNCTIONS\Edit-OrdersMain.ps1")
    . (".\__FUNCTIONS\Get-Permissions.ps1")
    . (".\__FUNCTIONS\Move-OriginalToArchive.ps1")
    . (".\__FUNCTIONS\Parse-OrdersCertificate.ps1")
    . (".\__FUNCTIONS\Parse-OrdersMain.ps1")
    . (".\__FUNCTIONS\Present-Outcome.ps1")
    . (".\__FUNCTIONS\Process-KeyboardCommands.ps1")
    . (".\__FUNCTIONS\Split-OrdersCertificate.ps1")
    . (".\__FUNCTIONS\Split-OrdersMain.ps1")
    . (".\__FUNCTIONS\Undo-PreviousSessions.ps1")
    . (".\__FUNCTIONS\Validate-Variables.ps1")
    . (".\__FUNCTIONS\Work-Magic.ps1")
    . (".\__FUNCTIONS\Write-Log.ps1")
}
catch {
    Write-Host "Error while loading supporting ORDPRO scripts." 
    $_
    exit 1
}

<#
DIRECTORIES OUTPUT
#>
$ordmanagers_directory_output = "$($output_dir)\ORD_MANAGERS"
$ordmanagers_orders_by_soldier_output = "$($ordmanagers_directory_output)\ORDERS_BY_SOLDIER"
$ordmanagers_iperms_integrator_output = "$($ordmanagers_directory_output)\IPERMS_INTEGRATOR"
$ordregisters_output = "$($output_dir)\ORD_REGISTERS"
$uics_directory_output = "$($output_dir)\UICS"

<#
DIRECTORIES WORKING
#>
$current_directory_working = (Get-Item -Path ".\" -Verbose).FullName
$tmp_directory_working = "$($current_directory_working)\TMP"
$archive_directory_working = "$($current_directory_working)\ARCHIVE"
$mof_directory_working = "$($tmp_directory_working)\MOF"
$mof_directory_original_splits_working = "$($mof_directory_working)\ORIGINAL_EDITS"
$cof_directory_working = "$($tmp_directory_working)\COF"
$cof_directory_original_splits_working = "$($cof_directory_working)\ORIGINAL_EDITS"
$log_directory_working = "$($tmp_directory_working)\LOGS"
$remove_directory_working = "$($tmp_directory_working)\REMOVE"

<#
ARRAYS
#>
$directories = @(
"$($ordmanagers_directory_output)", 
"$($ordmanagers_orders_by_soldier_output)", 
"$($ordmanagers_iperms_integrator_output)",
"$($ordregisters_output)", 
"$($uics_directory_output)", 
"$($tmp_directory_working)", 
"$($archive_directory_working)",
"$($mof_directory_working)", 
"$($mof_directory_original_splits_working)", 
"$($cof_directory_working)", 
"$($cof_directory_original_splits_working)", 
"$($log_directory_working)",
"$($remove_directory_working)"
)

$known_bad_strings = @(
"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
"ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}",
" " # Line break that gets left behind after removing other lines in array. Leave this as is.
)

<#
HASH TABLES
#>
$months = @{ 
"January" = "01"; 
"February" = "02"; 
"March" = "03"; 
"April" = "04"; 
"May" = "05"; 
"June" = "06"; 
"July" = "07"; 
"August" = "08"; 
"September" = "09"; 
"October" = "10"; 
"November" = "11"; 
"December" = "12"; 
}

<#
REGEX MAGIX
#>
$regex_order_number_parse_orders_main = "^ORDERS\s{1}\d{3}-\d{3}\s\d{2}\s\w\s\d{4}"
$regex_name_parse_orders_main = "You are ordered to"
$regex_uic_parse_orders_main = "\(\w{5}-\w{3}\)"
$regex_period_parse_orders_main = "^Period \(\w\w\w\) :"
$regex_format_parse_orders_main = "^Format: \d{3}"
$regex_order_amdend_revoke_parse_orders_main = "So much of:" # Order being amended or revoked
$regex_pertaining_to_parse_orders_main = "^Pertaining to:" # To find "Pertaining to:" line in revoke order to capture name, SSN, UIC
$regex_old_fouo_3_edit_orders_main = "ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}"

$regex_order_number_parse_orders_cert = "Order number:"
$regex_period_parse_orders_cert = "Period of duty:"
$regex_uic_parse_orders_cert = "CERTIFICATE OF PERFORMANCE / STATEMENT OF ATTENDANCE"
$regex_name_parse_orders_cert = "XXX-XX-XXXX"

$regex_beginning_m_split_orders_main = "STATE OF SOUTH DAKOTA"
$regex_beginning_c_split_orders_cert = "FOR OFFICIAL USE ONLY - PRIVACY ACT"
$regex_end_cert = "Automated NGB Form 102-10A  dtd  12 AUG 96"

<#
VARIABLES NEEDED
#>
$version_info = "1.9"
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$script_name = $($MyInvocation.MyCommand.Name)
$exclude_directories = '$($mof_directory_original_splits_working)|$($cof_directory_original_splits_working)'
$files_orders_original = (Get-ChildItem -Path $input_dir -Filter "*.prt" -File)
$files_orders_m_prt = (Get-ChildItem -Path $input_dir -Filter "*m.prt" -File)
$files_orders_c_prt = (Get-ChildItem -Path $input_dir -Filter "*c.prt" -File)
$log_file = "$($log_directory_working)\$($run_date)\$($run_date)_ORDPRO.log"
$log_file_directory = "$($log_directory_working)\$($run_date)"
$sw = New-Object System.Diagnostics.Stopwatch
$sw.start()

if(Test-Path variable:global:psISE)
{
    Write-Log -level [WARN] -log_file $($log_file) -message "Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
    Write-Warning "Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
}
else
{
    [console]::TreatControlCAsInput = $true
}

<#
ENTRY POINT
#>
$Parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
$TotalParameters = $parameters.count
$ParametersPassed = $PSBoundParameters.Count
$params = @($psBoundParameters.Keys)
$params_results = $params  | Out-String

if($ParametersPassed -eq $TotalParameters) 
{     
    Write-Log -message "All $totalParameters parameters are being used. `n$($params_results)" -log_file $($log_file)
    Write-Verbose "All $totalParameters parameters are being used. `n$($params_results)"
}
elseif($ParametersPassed -eq 1) 
{ 
    Write-Log -message "1 parameter is being used. `n$($params_results)" -log_file $($log_file)
    Write-Verbose "1 parameter is being used. `n$($params_results)" 
}
else
{ 
    Write-Log -message "$parametersPassed parameters are being used. `n`n$($params_results)" -log_file $($log_file)
    Write-Output "$parametersPassed parameters are being used. `n`n$($params_results)" 
}

if($($ParametersPassed) -gt '0')
{
    foreach($p in $params -ne 'output_dir')
    {
        if($p -ne 'Verbose' -or $p -ne 'help' -or $p -ne 'version' -or $p -ne 'v')
        {
            Write-Host "[^] $($p) parameter specified. Running $($p) function now." -ForegroundColor Cyan
        }

        switch($p)
        {
            "help" 
            { 
	            Write-Host "[^] Help parameter specified. Presenting full help now." -ForegroundColor Cyan
	            Get-Help .\$($script_name) -Full 
            }

            "version" 
            { 
	            Write-Host "You are running ORDPRO version: $($version_info). Check https://gitlab.com/ajhanisch/ORDPRO for the most recent versions and updates."
            }

            "dir_create" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Creating required directories." -ForegroundColor Cyan
		        Create-RequiredDirectories -directories $($directories) -log_file $($log_file)

		        if($?) 
		        {
			        Write-Host "[^] Creating directories finished." -ForegroundColor Cyan 
		        } 
            }

            "backups" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <input_directory>' parameter included."
                    exit 1
                }

                if(!($($input_dir)))
                {
                    Write-Error " No input directory specified. Try again with '-i <output_directory>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Backing up original orders file. Input directory is $($input_dir). Output directory is $($output_dir)." -ForegroundColor Cyan
		        Move-OriginalToArchive -tmp_directory_working $($tmp_directory_working) -archive_directory_working $($archive_directory_working) -ordregisters_output $($ordregisters_output) -input_dir $($input_dir)

		        if($?) 
		        { 
			        Write-Host "[^] Backing up original orders file finished." -ForegroundColor Cyan 
		        }	
            }

            "split_main" 
            { 
                if(!($($input_dir)))
                {
                    Write-Error " No input directory specified. Try again with '-i <input_directory>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files. Input directory is $($input_dir)." -ForegroundColor Cyan	
		        Split-OrdersMain -input_dir $($input_dir) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)

		        if($?)
		        {
			        Write-Host "[^] Splitting '*m.prt' order file(s) finished." -ForegroundColor Cyan 
		        }
            }

            "split_cert"
            { 
                if(!($($input_dir)))
                {
                    Write-Error " No input directory specified. Try again with '-i <input_directory>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Splitting '*c.prt' cerfiticate file(s) into individual certificate files. Input directory is $($input_dir)." -ForegroundColor Cyan
		        Split-OrdersCertificate -input_dir $($input_dir) -cof_directory_working $($cof_directory_working) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)

		        if($?) 
		        {
			        Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished." -ForegroundColor Cyan
		        } 	

            }

            "edit_main" 
            { 
		        Write-Host "[^] Editing orders '*m.prt' files." -ForegroundColor Cyan
		        Edit-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_working $($mof_directory_working)

		        if($?) 
		        { 
			        Write-Host "[^] Editing orders '*m.prt' files finished." -ForegroundColor Cyan 
		        }
            }

            "edit_cert" 
            { 
		        Write-Host "[^] Editing orders '*c.prt' files." -ForegroundColor Cyan
		        Edit-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert) -cof_directory_original_splits_working $($cof_directory_original_splits_working)

		        if($?)
		        { 
			        Write-Host "[^] Editing orders '*c.prt' files finished." -ForegroundColor Cyan 
                    #Stop-Transcript 
		        } 
            }

            "combine_main" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Combining .mof orders files." -ForegroundColor Cyan
		        Combine-OrdersMain -exclude_directories $($exclude_directories) -run_date $($run_date) -mof_directory_working $($mof_directory_working) -iperms_integrator $($ordmanagers_iperms_integrator_output)
		        if($?) 
		        { 
			        Write-Host "[^] Combining .mof orders files finished." -ForegroundColor Cyan 
		        } 	
            }

            "combine_cert" 
            { 
		        Write-Host "[^] Combining .cof orders files." -ForegroundColor Cyan
		        Combine-OrdersCertificate -cof_directory_working $($cof_directory_working) -run_date $($run_date)
		        if($?) 
		        { 
			        Write-Host "[^] Combining .cof orders files finished." -ForegroundColor Cyan 
		        } 	
            }

            "magic_main" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

                Write-Host "[^ Working magic on .mof files now. Output directory is $($output_dir)." -ForegroundColor Cyan
                Parse-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
		        if($?) 
		        { 
			        Write-Host "[^] Magic on .mof files finished." -ForegroundColor Cyan 
                }
            }

            "magic_cert" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Working magic on .cof files. Output directory is $($output_dir)." -ForegroundColor Cyan
		        Parse-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		        if($?) 
		        { 
			        Write-Host "[^] Magic on .cof files finished." -ForegroundColor Cyan 
		        } 	
            }

            "clean_main" 
            { 
		        Write-Host "[^] Cleaning up .mof files." -ForegroundColor Cyan
		        Clean-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories)
		        if($?) 
		        { 
			        Write-Host "[^] Cleaning up .mof finished." -ForegroundColor Cyan 
		        } 	
            }

            "clean_cert" 
            { 
		        Write-Host "[^] Cleaning up .cof files." -ForegroundColor Cyan
		        Clean-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		        if($?) 
		        { 
			        Write-Host "[^] Cleaning up .cof finished." -ForegroundColor Cyan 
		        } 	
            }

            "clean_uics" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Cleaning up UICS folder. Output directory is $($output_dir)." -ForegroundColor Cyan
		        Clean-UICS -uics_directory_output $($uics_directory_output)
		        if($?)
		        { 
			        Write-Host "[^] Cleaning up UICS folder finished." -ForegroundColor Cyan 
		        } 	
            }

            "permissions" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Getting permissions. Output directory is $($output_dir)." -ForegroundColor Cyan
		        Get-Permissions -uics_directory_output $($uics_directory_output)
		        if($?) 
		        { 
			        Write-Host "[^] Getting permissions of UICS folder finished." -ForegroundColor Cyan 
		        } 	
            }

            "set_permissions"
            {
                if(!($($output_dir)))
                {
                    Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Assigning permissions. Output directory is $($output_dir)." -ForegroundColor Cyan
		        Set-Permissions -input_path "C:\temp\OUTPUT\UICS"
		        if($?) 
		        { 
			        Write-Host "[^] Assigning permissions of UICS folder finished." -ForegroundColor Cyan 
		        } 	
            }

            "undo_previous"
            {
		        Write-Host "[^] Removing unwanted files. Output directory is $($remove_directory_working)." -ForegroundColor Cyan
		        Undo-PreviousSessions -input_remove "$($remove_directory_working)" -results_remove "$($remove_directory_working)" -Verbose
		        if($?) 
		        { 
			        Write-Host "[^] Removing unwanted files finished." -ForegroundColor Cyan 
		        } 	
            }

            "input_dir"
            {
                Write-Host "[^] Input directory is $($input_dir)." -ForegroundColor Cyan
            }

            "all" 
            { 
                try
                {                   
				    Write-Host "[^] Creating required directories. Step [1/9]." -ForegroundColor Cyan
		            Create-RequiredDirectories -directories $($directories) -log_file $($log_file)
		            if($?) 
		            {
			            Write-Host "[^] Creating directories finished." -ForegroundColor Cyan
		            } 

				    if(!($($input_dir)))
                    {
                        Write-Error " No input directory specified. Try again with '-i <input_directory>' parameter included."
                        exit 1
                    }
		            Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files. Step [2/9]. Input directory is $($input_dir)." -ForegroundColor Cyan
		            Split-OrdersMain -input_dir $($input_dir) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)
		            if($?)
		            {
			            Write-Host "[^] Splitting '*m.prt' order file(s) finished." -ForegroundColor Cyan
		            }

				    if(!($($input_dir)))
                    {
                        Write-Error " No input directory specified. Try again with '-i <input_directory>' parameter included."
                        exit 1
                    }
		            Write-Host "[^] Splitting '*c.prt' cerfiticate file(s) into individual certificate files. Step [3/9]. Input directory is $($input_dir)." -ForegroundColor Cyan
		            Split-OrdersCertificate -input_dir $($input_dir) -cof_directory_working $($cof_directory_working) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)
		            if($?) 
		            {
			            Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished." -ForegroundColor Cyan
		            } 	     
                       
		            Write-Host "[^] Editing orders '*m.prt' files. Step [4/9]." -ForegroundColor Cyan
		            Edit-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_working $($mof_directory_working)
		            if($?) 
		            { 
			            Write-Host "[^] Editing orders '*m.prt' files finished." -ForegroundColor Cyan 
		            } 

		            Write-Host "[^] Editing orders '*c.prt' files. Step [5/9]." -ForegroundColor Cyan
		            Edit-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert) -cof_directory_original_splits_working $($cof_directory_original_splits_working)
		            if($?)
		            { 
			            Write-Host "[^] Editing orders '*c.prt' files finished." -ForegroundColor Cyan
		            } 

                    if(!($($output_dir)))
                    {
                        Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                        exit 1
                    }
		            Write-Host "[^] Combining .mof orders files. Step [6/9]." -ForegroundColor Cyan
		            Combine-OrdersMain -exclude_directories $($exclude_directories) -run_date $($run_date) -mof_directory_working $($mof_directory_working) -iperms_integrator $($ordmanagers_iperms_integrator_output)
		            if($?) 
		            { 
			            Write-Host "[^] Combining .mof orders files finished." -ForegroundColor Cyan 
		            } 	
                    
                    if(!($($output_dir)))
                    {
                        Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                        exit 1
                    }
                    Write-Host "[^] Working magic on .mof files now. Step [7/9]. Output directory is $($output_dir)." -ForegroundColor Cyan
                    Parse-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
		            if($?) 
		            { 
			            Write-Host "[^] Magic on .mof files finished." -ForegroundColor Cyan 
		            }	

                    if(!($($output_dir)))
                    {
                        Write-Error " No output directory specified. Try again with '-o <destination_folder>' parameter included."
                        exit 1
                    }
		            Write-Host "[^] Working magic on .cof files. Step [8/9]. Output directory is $($output_dir)." -ForegroundColor Cyan
		            Parse-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		            if($?) 
		            { 
			            Write-Host "[^] Magic on .cof files finished." -ForegroundColor Cyan 
		            }

                    Write-Host "[^] Zipping log directory now. Step [9/9]." -ForegroundColor Cyan
                    Archive-Directory -source $($log_file_directory) -destination "$($log_directory_working)\$($run_date)_archive.zip"
                    if($?)
                    {
                        Write-Host "[^] Zipping log directory finished." -ForegroundColor Cyan
                    }

                    Present-Outcome -outcome GO
                }
                catch
                {
                    Write-Log -level [ERROR] -log_file $($log_file) -message "$_"
                    Present-Outcome -outcome NOGO
                }              	            
            }

            "Verbose" 
            { 
                continue
            }

            default 
            { 
                Write-Log -level [ERROR] -log_file $log_file -message " Unrecognized parameter: $($p). Try again with proper parameter."
	            Write-Error " Unrecognized parameter: $($p). Try again with proper parameter."
            }
        }
    }
}
else
{
    Write-Log -level [ERROR] -log_file $log_file -message " No parameters passed. Run '.\$($script_name) -h' for detailed help information."
    Write-Error " No parameters passed. Run '.\$($script_name) -h' for detailed help information."
}