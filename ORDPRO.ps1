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
.PARAMETER all
   All parameters. Alias: 'a'. This parameter tells ORDPRO to run all required parameters needed to be successful. Most common parameter to those new to using ORDPRO.
.INPUTS
   ORDPRO parses all '*m.prt' and '*c.prt' files in current directory. ORDPRO archives '*r.prt' and '*r.reg*' files to '.\ARCHIVE\YY_orders' directory with YY being the last 2 digits of the current year.
.OUTPUTS
   ORDPRO automatically creates required output directory structure, splits, edits, and moves orders to their appropiate location in the created structure. Output includes detailed results of success and failure of each parameter to .csv files in the '.\LOGS\<RUN_DATE>' directory to be viewed during troubleshooting and future reporting purposes as well as detailed logging of all parameter use when any parameter is combined with the 'Verbose' paramter. 
.EXAMPLE
    .\ORDPRO.ps1 -all -output_dir "\\path\to\your\desired\output\directory" -Verbose

    Run all required parameters for success while including detailed verbosity output.

    Short version of command would be .\ORDPRO.ps1 -a -o "\\path\to\your\desired\output\directory" -Verbose
.EXAMPLE
    .\ORDPRO.ps1 -all -output_dir "\\path\to\your\desired\output\directory"

    Run all required parameters for success showing detailed progress bar information.

    Short version of command would be .\ORDPRO.ps1 -a -o "\\path\to\your\desired\output\directory"
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
    [alias('a')][switch]$all
)


<#
DIRECTORIES OUTPUT
#>
$ordmanagers_directory_output = "$($output_dir)\ORD_MANAGERS"
$ordmanagers_orders_by_soldier_output = "$($ordmanagers_directory_output)\ORDERS_BY_SOLDIER"
$ordregisters_output = "$($output_dir)\ORD_REGISTERS"
$uics_directory_output = "$($output_dir)\UICS"

<#
DIRECTORIES WORKING
#>
$current_directory_working = (Get-Item -Path ".\" -Verbose).FullName
$tmp_directory_working = "$($current_directory_working)\TMP"
$archive_directory_working = "$($current_directory_working)\ARCHIVE"
$mof_directory_working = "$($tmp_directory_working)\MOF"
$mof_directory_original_splits_working = "$($mof_directory_working)\ORIGINAL_SPLITS"
$cof_directory_working = "$($tmp_directory_working)\COF"
$cof_directory_original_splits_working = "$($cof_directory_working)\ORIGINAL_SPLITS"
$log_directory_working = "$($tmp_directory_working)\LOGS"

<#
ARRAYS
#>
$directories = @(
"$($ordmanagers_directory_output)", 
"$($ordmanagers_orders_by_soldier_output)", 
"$($ordregisters_output)", 
"$($uics_directory_output)", 
"$($tmp_directory_working)", 
"$($archive_directory_working)",
"$($mof_directory_working)", 
"$($mof_directory_original_splits_working)", 
"$($cof_directory_working)", 
"$($cof_directory_original_splits_working)", 
"$($log_directory_working)"
)

$known_bad_strings = @(
"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
"ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}"
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
$version_info = "1.3"
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$script_name = $($MyInvocation.MyCommand.Name)
$exclude_directories = '$($mof_directory_original_splits_working)|$($cof_directory_original_splits_working)'
$files_orders_original = (Get-ChildItem -Path $current_directory_working -Filter "*.prt" -File)
$files_orders_m_prt = (Get-ChildItem -Path $current_directory_working -Filter "*m.prt" -File)
$files_orders_c_prt = (Get-ChildItem -Path $current_directory_working -Filter "*c.prt" -File)
$log_file = "$($log_directory_working)\$($run_date)\$($run_date)_ORDPRO.log"
$log_file_directory = "$($log_directory_working)\$($run_date)"
$sw = New-Object System.Diagnostics.Stopwatch
$sw.start()

if(Test-Path variable:global:psISE)
{
    Write-Warning "[#] Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
}
else
{
    [console]::TreatControlCAsInput = $true
}

<#
FUNCTIONS
#>
function Create-RequiredDirectories()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $directories,
        [Parameter(mandatory = $true)] $log_file
    )

    if($($directories.Count) -gt 0)
    {
        #cls

        $total_directories_created = 0
        $total_directories_not_created = 0

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total to create: $($($directories.Count))."
        Write-Verbose "Total to create: $($($directories.Count))."

        foreach($directory in $directories)
        {
            Process-DevCommands -sw $($sw)

            if(!(Test-Path $($directory)))
            {
                Write-Log -log_file $log_file -message "[#] $($directory) not created. Creating now."
                Write-Verbose "[#] $($directory) not created. Creating now."
                New-Item -ItemType Directory -Path $($directory) > $null

                if($?)
                {
                    $total_directories_created ++
                    Write-Log -log_file $log_file -message "[*] $($directory) created successfully."
                    Write-Verbose "[*] $($directory) created successfully."
                }
                else
                {
                    $total_directories_not_created ++
                    Write-Log -level [ERROR] -log_file $log_file -message "[!] $($directory) creation failed. Check the error logs at $($error_path). Reach out to ORDPRO support."
                    Write-Error -Message "[!] $($directory) creation failed. Check the error logs at $($error_path)." -RecommendedAction "Reach out to ORDPRO support."
                }
            }
            else
            {
                $total_directories_created ++
                Write-Log -log_file $log_file -message "[*] $($directory) already created."
                Write-Verbose "[*] $($directory) already created."
            }

            $status = "Creating required directories."
            $activity = "Creating directory $total_directories_created of $($directories.Count)."
            $percent_complete = (($total_directories_created/$($directories.Count)) * 100)
            $current_operation = "$("{0:N2}" -f ((($total_directories_created/$($directories.Count)) * 100),2))% Complete"
            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
            $seconds_remaining = ($seconds_elapsed / ($total_directories_created / $directories.Count)) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation)."
                Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to create: $($($directories.Count)). No directories to create. Support: Make sure the directories array is populated with your desired directories to create."
        Write-Warning -Message "[!] Total to create: $($($directories.Count)). No directories to create." -RecommendedAction "Support: Make sure the directories array is populated with your desired directories to create."
    }
}

function Move-OriginalToArchive()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $tmp_directory_working,
        [Parameter(mandatory = $true)] $ordregisters_output,
        [Parameter(mandatory = $true)] $archive_directory_working
    )

    #cls

    $year_suffix = (Get-Date -Format yyyy).Substring(2)
    $year_orders_archive_directory = "$($archive_directory_working)\$($year_suffix)_orders"
    $year_orders_registry_directory = "$($ordregisters_output)\$($year_suffix)_orders"

	$total_files_to_move = @(Get-ChildItem -Path $($current_directory_working) | Where { ! $_.PSIsContainer } | Where { $_.Name -eq "*m.prt" -or $_.Name -eq "*c.prt" -or $_.Name -eq "*r.prt" -or $_.Name -eq "*r.reg*" -or $_.Extension -ne '.ps1' }).Count
    $orders_file_m_prt = Get-ChildItem -Path $($current_directory_working) -Filter "*m.prt" -File
    $orders_file_c_prt = Get-ChildItem -Path $($current_directory_working) -Filter "*c.prt" -File
    $orders_file_r_prt = Get-ChildItem -Path $($current_directory_working) -Filter "*r.prt" -File
    $orders_file_r_reg = Get-ChildItem -Path $($current_directory_working) -Filter "*r.reg*" -File
	
	$archive_directories = @(
		"$($year_orders_archive_directory)",
		"$($year_orders_registry_directory)"
	)
	
	$order_files = @{
        M_PRT = $orders_file_m_prt; 
        C_PRT = $orders_file_c_prt; 
        R_PRT = $orders_file_r_prt; 
        R_REG = $orders_file_r_reg; 
    }
    
	if($total_files_to_move -gt 0)
	{

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        $total_files_moved = @()
        $total_files_not_moved = @()

        $files_moved_to_archive_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_moved_to_archive.csv"
        $files_not_moved_to_archive_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_not_moved_to_archive.csv"

		foreach($directory in $archive_directories)
		{
			if(!(Test-Path $($directory)))
			{
                Write-Log -log_file $log_file -message "[#] $($directory) not created yet. Creating now."
				Write-Verbose "[#] $($directory) not created yet. Creating now."

				New-Item -ItemType Directory -Path $($directory) -Force > $null

				if($?)
				{
                    Write-Log -log_file $log_file -message "[*] $($directory) created successfully."
					Write-Verbose "[*] $($directory) created successfully."
				}
				else
				{
                    Write-Log -level [ERROR] -log_file $log_file -message "[!] $($directory) failed to create."
					Write-Error "[!] $($directory) failed to create."
				}
			}
			else
			{
                Write-Log -log_file $log_file -message "[*] $($directory) already created."
				Write-Verbose "[*] $($directory) already created."
			}
		}
		
		foreach($order_file_type in $order_files.GetEnumerator())
		{
            foreach($name in $($order_file_type.Name))
            {
                foreach($value in $($order_file_type.Value))
                {
                    Process-DevCommands -sw $($sw)

                    if($name -eq 'C_PRT' -or $name -eq 'M_PRT')
                    {
                        Write-Log -log_file $log_file -message "[#] Moving $($value) to $($year_orders_archive_directory) now."
                        Write-Verbose "[#] Moving $($value) to $($year_orders_archive_directory) now."

                        Move-Item -Path $($value) -Destination "$($year_orders_archive_directory)\$($value)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "[*] $($value) moved to $($year_orders_archive_directory) successfully."
                            Write-Verbose "[*] $($value) moved to $($year_orders_archive_directory) successfully."
                
                            $hash = @{
                                FILE = $($value)
                                TYPE = $($name)
                                STATUS = 'SUCCESS'
                                DESTINATION = $($year_orders_archive_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_moved += $file_moved
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($value) move to $($year_orders_archive_directory) failed."
                            Write-Error -Message "[!] $($value) move to $($year_orders_archive_directory) failed."

                            $hash = @{
                                FILE = $($value)
                                TYPE = $($name)
                                STATUS = 'FAILED'
                                DESTINATION = $($year_orders_archive_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_not_moved += $file_moved
                        }
                    }
                    elseif($name -eq 'R_PRT' -or $name -eq 'R_REG')
                    {
                        Write-Verbose "[#] Moving $($value) to $($year_orders_registry_directory) now."
                        Move-Item -Path $($value) -Destination "$($year_orders_registry_directory)\$($value)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "[*] $($value) moved to $($year_orders_registry_directory) successfully."
                            Write-Verbose "[*] $($value) moved to $($year_orders_registry_directory) successfully."
                
                            $hash = @{
                                FILE = $($value)
                                TYPE = $($name)
                                STATUS = 'SUCCESS'
                                DESTINATION = $($year_orders_registry_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_moved += $file_moved
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($value) move to $($year_orders_registry_directory) failed."
                            Write-Verbose "[!] $($value) move to $($year_orders_registry_directory) failed."

                            $hash = @{
                                FILE = $($value)
                                TYPE = $($name)
                                STATUS = 'FAILED'
                                DESTINATION = $($year_orders_registry_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_not_moved += $file_moved
                        }
                    }

                    $status = "Moving original $($name) files to archive folder."
                    $activity = "Moving file $($total_files_moved.Count) of $($total_files_to_move). $($total_files_not_moved.Count) of $($total_files_to_move) not moved."
                    $percent_complete = (($total_files_moved.Count/$($total_files_to_move)) * 100)
                    $current_operation = "$("{0:N2}" -f (((($total_files_moved.Count)/$($total_files_to_move)) * 100),2))% Complete"
                    $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
                    $seconds_remaining = ($seconds_elapsed / ($total_files_moved.Count / $total_files_to_move)) - $seconds_elapsed
                    $ts =  [timespan]::fromseconds($seconds_remaining)
                    $ts = $ts.ToString("hh\:mm\:ss")

                    if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                    {
                        Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                        Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                    }
            
                    else
                    {
                        Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                    }
                }
            }
		}

        if($total_files_moved.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($files_moved_to_archive_csv) file now."
            Write-Verbose "[*] Writing $($files_moved_to_archive_csv) file now."
            $total_files_moved | Select FILE, TYPE, STATUS, DESTINATION | Sort -Property STATUS | Export-Csv "$($files_moved_to_archive_csv)" -NoTypeInformation -Force
        }

        if($total_files_not_moved.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($files_not_moved_to_archive_csv) file now."
            Write-Verbose "[*] Writing $($files_not_moved_to_archive_csv) file now."
            $total_files_not_moved | Select FILE, TYPE, STATUS, DESTINATION | Sort -Property STATUS | Export-Csv "$($files_not_moved_to_archive_csv)" -NoTypeInformation -Force
        }
	}
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to move: $($total_to_move_files). No files to move. Make sure to have the required '*m.prt', '*c.prt', '*r.prt', '*r.reg' files in the current directory and try again."
        Write-Warning -Message "[!] Total to move: $($total_to_move_files). No files to move." -RecommendedAction "Make sure to have the required '*m.prt', '*c.prt', '*r.prt', '*r.reg' files in the current directory and try again."
    }
}

function Split-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $current_directory_working,
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $run_date,
        [Parameter(mandatory = $true)] $files_orders_m_prt,
        [Parameter(mandatory = $true)] $regex_beginning_m_split_orders_main
    )

    #cls

    $total_to_parse_orders_main_files = @($files_orders_m_prt).Count

    $orders_created = @()
    $orders_not_created = @()

    $orders_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_main.csv"
    $orders_not_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_main.csv"

    $out_directory = $($mof_directory_working)

    if($total_to_parse_orders_main_files -gt '0')
    {
        $count_orders = 0
        $count_files = 0

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        if(!(Test-Path $($out_directory)))
        {
            Write-Log -log_file $log_file -message "[#] $($out_directory) not created. Creating now."
            Write-Verbose "[#] $($out_directory) not created. Creating now."

            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Log -log_file $log_file -message "[*] $($out_directory) created successfully."
                Write-Verbose "[*] $($out_directory) created successfully."
            }
            else
            {
                Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_directory) creation failed."
                Write-Error "[!] $($out_directory) creation failed."
            }
        }

        foreach ($file in $files_orders_m_prt)
        {
	        $count_files ++
	        $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
	        $orders = [regex]::Match($content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "$($regex_beginning_m_split_orders_main)"

            Write-Log -log_file $log_file -message "[#] Parsing $($file) now."
	        Write-Verbose "[#] Parsing $($file) now."

	        foreach($order in $orders)
	        {
		        Process-DevCommands -sw $($sw)

		        if($order)
		        {
			        $count_orders ++

			        $out_file = "$($run_date)_$($count_orders).mof"

                    Write-Log -log_file $log_file -message "[#] Processing $($out_file) now."
			        Write-Verbose "[#] Processing $($out_file) now."

			        New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

			        if($?)
			        {
                        Write-Log -log_file $log_file -message "[*] $($out_file) file created successfully."
				        Write-Verbose "[*] $($out_file) file created successfully."

				        $hash = @{
					        'ORIGINAL_FILE' = $($file)
					        'OUT_FILE' = $($out_file)
					        'ORDER_COUNT' = $($count_orders)
				        }

				        $order_created = New-Object -TypeName PSObject -Property $hash
				        $orders_created += $order_created				
			        }
			        else
			        {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_file) file creation failed."
				        Write-Error "[!] $($out_file) file creation failed."

				        $hash = @{
					        'ORIGINAL_FILE' = $($file)
					        'OUT_FILE' = $($out_file)
					        'ORDER_COUNT' = $($count_orders)
				        }

				        $order_created = New-Object -TypeName PSObject -Property $hash
				        $orders_not_created += $order_created
			        }
		        }
	        }
	
	        $status = "Splitting '*m.prt' files."
	        $activity = "Processing file $count_files of $($files_orders_m_prt.Count)."
	        $percent_complete = (($count_files/$($files_orders_m_prt.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($count_files/$($files_orders_m_prt.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($count_files / $files_orders_m_prt.Count)) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }

        if($orders_created.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_created_csv) file now."
            Write-Verbose "[*] Writing $($orders_created_csv) file now."
            $orders_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT | Sort -Property ORDER_COUNT | Export-Csv "$($orders_created_csv)" -NoTypeInformation -Force
        }

        if($orders_not_created.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_not_created_csv) file now."
            Write-Verbose "[*] Writing $($orders_not_created_csv) file now."
            $orders_not_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT| Sort -Property ORDER_COUNT | Export-Csv "$($orders_not_created_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] $($current_directory_working) '*m.prt' files to split. No '*m.prt' files to split. Make sure to have the required '*m.prt' files in the current directory and try again."
        Write-Warning -Message "[!] $($current_directory_working) '*m.prt' files to split. No '*m.prt' files to split." -RecommendedAction "Make sure to have the required '*m.prt' files in the current directory and try again."
    }
}

function Split-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $current_directory_working,
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $run_date,
        [Parameter(mandatory = $true)] $files_orders_c_prt,
        [Parameter(mandatory = $true)] $regex_end_cert
    )
	
    #cls

    $total_to_parse_orders_cert_files = @($files_orders_c_prt).Count

    $orders_created = @()
    $orders_not_created = @()

    $orders_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_cert.csv"
    $orders_not_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_cert.csv"

    $out_directory = $($cof_directory_working)

    if($total_to_parse_orders_cert_files -gt '0')
    {
        $count_orders = 0
        $count_files = 0

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        if(!(Test-Path $($out_directory)))
        {
            Write-Log -log_file $log_file -message "[#] $($out_directory) not created. Creating now."
            Write-Verbose "[#] $($out_directory) not created. Creating now."

            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Log -log_file $log_file -message "[*] $($out_directory) created successfully."
                Write-Verbose "[*] $($out_directory) created successfully."
            }
            else
            {
                Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_directory) creation failed."
                Write-Error "[!] $($out_directory) creation failed."
            }
        }

        foreach($file in $files_orders_c_prt)
        {
	        $count_files ++
	        $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
	        $orders = [regex]::Match($content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "$($regex_end_cert)"
            
            Write-Log -log_file $log_file -message "[#] Parsing $($file) now."
	        Write-Verbose "[#] Parsing $($file) now."

	        foreach($order in $orders)
	        {
		        Process-DevCommands -sw $($sw)

		        if($order)
		        {
			        $count_orders ++

			        $out_file = "$($run_date)_$($count_orders).cof"

                    Write-Log -log_file $log_file -message "[#] Processing $($out_file) now."
			        Write-Verbose "[#] Processing $($out_file) now."

			        New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

			        if($?)
			        {
                        Write-Log -log_file $log_file -message "[*] $($out_file) file created successfully."
				        Write-Verbose "[*] $($out_file) file created successfully."

				        $hash = @{
					        'ORIGINAL_FILE' = $($file)
					        'OUT_FILE' = $($out_file)
					        'ORDER_COUNT' = $($count_orders)
				        }

				        $order_created = New-Object -TypeName PSObject -Property $hash
				        $orders_created += $order_created
				
			        }
			        else
			        {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_file) file creation failed."
				        Write-Error "[!] $($out_file) file creation failed."

				        $hash = @{
					        'ORIGINAL_FILE' = $($file)
					        'OUT_FILE' = $($out_file)
					        'ORDER_COUNT' = $($count_orders)
				        }

				        $order_created = New-Object -TypeName PSObject -Property $hash
				        $orders_not_created += $order_created
			        }
		        }
	        }

	        $status = "Splitting '*c.prt' files."
	        $activity = "Processing file $count_files of $($files_orders_c_prt.Count)."
	        $percent_complete = (($count_files/$($files_orders_c_prt.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($count_files/$($files_orders_c_prt.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($count_files / $files_orders_c_prt.Count)) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }  

        if($orders_created.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_created_csv) file now."
            Write-Verbose "[*] Writing $($orders_created_csv) file now."
            $orders_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT | Sort -Property ORDER_COUNT | Export-Csv "$($orders_created_csv)" -NoTypeInformation -Force
        }

        if($orders_not_created.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_not_created_csv) file now."
            Write-Verbose "[*] Writing $($orders_not_created_csv) file now."
            $orders_not_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT| Sort -Property ORDER_COUNT | Export-Csv "$($orders_not_created_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] $($current_directory_working) '*c.prt' files to split. No '*c.prt' files to split. Make sure to have the required '*c.prt' files in the current directory and try again."
        Write-Warning -Message "[!] $($current_directory_working) '*c.prt' files to split. No '*c.prt' files to split." -RecommendedAction "Make sure to have the required '*c.prt' files in the current directory and try again."
    }
}

function Edit-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $regex_old_fouo_3_edit_orders_main,
        [Parameter(mandatory = $true)] $mof_directory_original_splits_working
    )
	 
    #cls 

    $total_to_edit_orders_main = (Get-ChildItem -Path "$($mof_directory_working)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length

    if($($total_to_edit_orders_main) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        Write-Log -log_file $log_file -message "[#] Total to edit: $($total_to_edit_orders_main)."
        Write-Verbose "[#] Total to edit: $($total_to_edit_orders_main)."

        $orders_edited = @()
        $orders_not_edited = @()

        $orders_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_edited_main.csv"
        $orders_not_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_edited_main.csv"

        foreach($file in (Get-ChildItem -Path "$($mof_directory_working)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof'}))
        {
            Process-DevCommands -sw $($sw)

            $following_request = "Following Request is" # Disapproved || Approved
            $following_request_exists = (Select-String -Path "$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $following_order = "Following order is." # Amendment order. $($format.Length) -eq 4
            $following_order_exists = (Select-String -Path "$($file)" -Pattern $($following_order) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

            if(!((Get-Item "$($file)") -is [System.IO.DirectoryInfo]))
            {
                Write-Log -log_file $log_file -message "[#] Editing $($file.Name) in round 1 now."
                Write-Verbose "[#] Editing $($file.Name) in round 1 now."
                
                $out_file_name = "$($file.BaseName)_edited.mof"

                $file_content = (Get-Content "$($file)" | Select -Skip 1 )
                $file_content = @('                               STATE OF SOUTH DAKOTA') + $file_content

                # Remove known bad strings first.
                foreach($pattern in $known_bad_strings)
                {
                    Write-Log -log_file $log_file -message "[#] Removing known bad string $($pattern) from $($file)."
                    Write-Verbose "[#] Removing known bad string $($pattern) from $($file)."
                    $file_content = ( $file_content | Select-String -Pattern $($pattern) -NotMatch )

                    if($?)
                    {
                        Write-Log -log_file $log_file -message "[*] Removed known bad string $($pattern) from $($file) succesfully."
                        Write-Verbose "[*] Removed known bad string $($pattern) from $($file) succesfully."
                    }
                    else
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Removing known bad string $($pattern) from $($file) failed."
                        Write-Error "[!] Removing known bad string $($pattern) from $($file) failed."
                    }
                }

                # Write to edited file.
                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $file_content

                if($?)
                {
                    Write-Log -log_file $log_file -message "[*] $($file.Name) edited in round 1 successfully."
                    Write-Verbose "[*] $($file.Name) edited in round 1 successfully."

                    if($($file.Name) -cnotcontains "*_edited.mof")
                    {
                        Write-Log -log_file $log_file -message "[#] Moving $($file.Name) to $($mof_directory_original_splits_working)"
                        Write-Verbose "[#] Moving $($file.Name) to $($mof_directory_original_splits_working)"

                        Move-Item "$($file)" -Destination "$($mof_directory_original_splits_working)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "[*] $($file) moved to $($mof_directory_original_splits_working) successfully."
                            Write-Verbose "[*] $($file) moved to $($mof_directory_original_splits_working) successfully."
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($file) move to $($mof_directory_original_splits_working) failed."
                            Write-Error "[!] $($file) move to $($mof_directory_original_splits_working) failed."
                        }
                    }
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message "[!] $($file.Name) editing in round 1 failed."
                    Write-Error "[!] $($file.Name) editing in round 1 failed."

                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($file.Name) editing in round 1 failed."
                        Write-Error "[!] $($file.Name) editing in round 1 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '2'
                            'STATUS' = 'FAILED'
                            'REASON' = "[!] $($file.Name) editing in round 1 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }

                # Remove bad spacing between 'Marital status / Number of dependents' and 'Type of incentive pay'
                Write-Log -log_file $log_file -message "[#] Editing $($out_file_name) in round 2 now."
                Write-Verbose "[#] Editing $($out_file_name) in round 2 now."

                $pattern_1 = '(?smi)Marital status / Number of dependents: \w{1,}(.*?)Type of incentive pay: \w{1,}'
                $string_1 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_1 = [regex]::Matches($string_1,$pattern_1).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Log -level [WARN] -log_file $log_file -message "[!] $($out_file_name) is not the proper format to be edited in round 2. Not editing this file at this time as it is not needed."
                    Write-Warning "[!] $($out_file_name) is not the proper format to be edited in round 2. Not editing this file at this time as it is not needed."
                }
                $good_output_1 = $bad_output_1.Replace("`n`r`n`r`n","")
                $string_1 = $string_1 -replace $bad_output_1,$good_output_1

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_1
                if($?)
                {
                    Write-Log -log_file $log_file -message "[*] $($out_file_name) edited in round 2 successfully."
                    Write-Verbose "[*] $($out_file_name) edited in round 2 successfully."
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_file_name) edit in round 2 failed."
                        Write-Error "[!] $($out_file_name) edit in round 2 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '2'
                            'STATUS' = 'FAILED'
                            'REASON' = "[!] $($out_file_name) edit in round 2 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }

                # Remove bad spacing between 'APC DJMS-RC' and 'APC STANFINS Pay'
                Write-Log -log_file $log_file -message "[#] Editing $($out_file_name) in round 3 now."
                Write-Verbose "[#] Editing $($out_file_name) in round 3 now."

                $pattern_2 = '(?smi)APC DJMS-RC: \w{1,}(.*?)APC STANFINS Pay:  \w{1,}'
                $string_2 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_2 = [regex]::Matches($string_2,$pattern_2).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Log -level [WARN] -log_file $log_file -message "[!] $($out_file_name) is not the proper format to be edited in round 3. Not editing this file at this time as it is not needed."
                    Write-Warning "[!] $($out_file_name) is not the proper format to be edited in round 3. Not editing this file at this time as it is not needed."
                }
                $good_output_2 = $bad_output_2.Replace("`n`r`n","")
                $string_2 = $string_2 -replace $bad_output_2,$good_output_2

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_2
                if($?)
                {
                    Write-Log -log_file $log_file -message "[*] $($out_file_name) edited in round 3 successfully."
                    Write-Verbose "[*] $($out_file_name) edited in round 3 successfully."
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_file_name) edit in round 3 failed."
                        Write-Error "[!] $($out_file_name) edit in round 3 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '3'
                            'STATUS' = 'FAILED'
                            'REASON' = "[!] $($out_file_name) edit in round 3 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }

                # Remove bad spacing between 'Auth:' and 'HOR:'
                Write-Log -log_file $log_file -message "[#] Editing $($out_file_name) in round 4 now."
                Write-Verbose "[#] Editing $($out_file_name) in round 4 now."

                $pattern_3 = '(?smi)Auth:\s\w{1,}(.*?)HOR:\s\w{1,}'
                $string_3 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_3 = [regex]::Matches($string_3,$pattern_3).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Log -level [WARN] -log_file $log_file -message "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."
                    Write-Warning "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."

                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [WARN] -log_file $log_file -message "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."
                        Write-Warning "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '4'
                            'STATUS' = 'FAILED'
                            'REASON' = "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }
                $good_output_3 = @($bad_output_3 -split '\r\n\r\n\r\n')
                $good_output_3 = $good_output_3[0] + "`n" + $good_output_3[1]
                $string_3 = $string_3.Replace($bad_output_3,$good_output_3)

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_3
                if($?)
                {
                    if( -not ($($orders_edited) -contains $file) -and -not ($($following_request_exists)) -and -not ($($following_order_exists)) )
                    {
                        Write-Log -log_file $log_file -message "[*] $($out_file_name) edited in round 4 successfully."
                        Write-Verbose "[*] $($out_file_name) edited in round 4 successfully."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '4'
                            'STATUS' = 'SUCCESS'
                            'REASON' = ''
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_edited += $order_edited
                    }
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($out_file_name) edit in round 4 failed."
                        Write-Verbose "[!] $($out_file_name) edit in round 4 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '4'
                            'STATUS' = 'FAILED'
                            'REASON' = "[!] $($out_file_name) edit in round 4 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }
            }
            else
            {
                Write-Log -level [WARN] -log_file $log_file -message "[#] $($file) is a directory. Skipping."
                Write-Verbose "[#] $($file) is a directory. Skipping."
            }

	        $status = "Editing '*m.prt' files."
	        $activity = "Processing file $($orders_edited.Count) of $($total_to_edit_orders_main). $($orders_not_edited.Count) of $($total_to_edit_orders_main) not edited."
	        $percent_complete = (($($orders_edited.Count)/$($total_to_edit_orders_main)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($($orders_edited.Count)/$($total_to_edit_orders_main)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($($orders_edited.Count) / $total_to_edit_orders_main)) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }

        if($orders_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_edited_csv) file now."
            Write-Verbose "[*] Writing $($orders_edited_csv) file now."
            $orders_edited | Select FILE, ROUND, STATUS, REASON | Sort -Property FILE | Export-Csv "$($orders_edited_csv)" -NoTypeInformation -Force
        }

        if($orders_not_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_not_edited_csv) file now."
            Write-Verbose "[*] Writing $($orders_not_edited_csv) file now."
            $orders_not_edited | Select FILE, ROUND, STATUS, REASON | Sort -Property FILE | Export-Csv "$($orders_not_edited_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to edit: $($total_to_edit_orders_main). No .mof files in $($mof_directory_working). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
        Write-Warning -Message "[!] Total to edit: $($total_to_edit_orders_main). No .mof files in $($mof_directory_working)." -RecommendedAction "Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
    }
}

function Edit-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $regex_end_cert,
        [Parameter(mandatory = $true)] $cof_directory_original_splits_working
    )

    #cls

    $total_to_edit_orders_cert = (Get-ChildItem -Path "$($cof_directory_working)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length

    if($($total_to_edit_orders_cert) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        Write-Log -log_file $log_file -message "[#] Total to edit: $($total_to_edit_orders_cert)."
        Write-Verbose "[#] Total to edit: $($total_to_edit_orders_cert)."

        $orders_edited = @()
        $orders_not_edited = @()

        $orders_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_edited_cert.csv"
        $orders_not_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_edited_cert.csv"

        foreach($file in (Get-ChildItem -Path "$($cof_directory_working)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof'}))
        {
            Process-DevCommands -sw $($sw)

            if(!((Get-Item "$($file)") -is [System.IO.DirectoryInfo]))
            { 
                Write-Log -log_file $log_file -message "[#] Editing $($file.Name) now."
                Write-Verbose "[#] Editing $($file.Name) now."
                               
                $out_file_name = "$($file.BaseName)_edited.cof"

                $file_content = Get-Content "$($file)"

                # Remove known bad strings first.
                foreach($pattern in $known_bad_strings)
                {
                    Write-Log -log_file $log_file -message "[#] Removing known bad string $($pattern) from $($file)."
                    Write-Verbose "[#] Removing known bad string $($pattern) from $($file)."
                    $file_content = ( $file_content | Select-String -Pattern $($pattern) -NotMatch )

                    if($?)
                    {
                        Write-Log -log_file $log_file -message "[*] Removed known bad string $($pattern) from $($file) succesfully."
                        Write-Verbose "[*] Removed known bad string $($pattern) from $($file) succesfully."
                    }
                    else
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Removing known bad string $($pattern) from $($file) failed."
                        Write-Error "[!] Removing known bad string $($pattern) from $($file) failed."
                    }
                }

                # Write to edited file.
                Set-Content -Path "$($cof_directory_working)\$($out_file_name)" $file_content
                Add-Content -Path "$($cof_directory_working)\$($out_file_name)" -Value $($regex_end_cert)

                if($?)
                {
                    Write-Log -log_file $log_file -message "[*] $($file.Name) edited successfully."
                    Write-Verbose "[*] $($file.Name) edited successfully."
                    
                    $hash = @{
                        'FILE' = $($file)
                        'STATUS' = 'SUCCESS'
                    }

                    $order_edited = New-Object -TypeName PSObject -Property $hash
                    $orders_edited += $order_edited                 

                    if($($file.Name) -cnotcontains "*_edited.cof")
                    {
                        Write-Log -log_file $log_file -message "[#] Moving $($file.Name) to $($cof_directory_original_splits_working)"
                        Write-Verbose "[#] Moving $($file.Name) to $($cof_directory_original_splits_working)"
                        Move-Item "$($file)" -Destination "$($cof_directory_original_splits_working)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "[*] $($file) moved to $($cof_directory_original_splits_working) successfully."
                            Write-Verbose "[*] $($file) moved to $($cof_directory_original_splits_working) successfully."
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($file) move to $($cof_directory_original_splits_working) failed."
                            Write-Error "[!] $($file) move to $($cof_directory_original_splits_working) failed."
                        }
                    }
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message "[!] $($file.Name) editing failed."
                    Write-Verbose "[!] $($file.Name) editing failed."

                    $hash = @{
                        'FILE' = $($file)
                        'STATUS' = 'FAILED'
                    }

                    $order_edited = New-Object -TypeName PSObject -Property $hash
                    $orders_not_edited += $order_edited   
                }
            }
            else
            {
                Write-Log -level [WARN] -log_file $log_file -message "[#] $($file) is a directory. Skipping."
                Write-Verbose "[#] $($file) is a directory. Skipping."
            }

	        $status = "Editing '*c.prt' files."
	        $activity = "Processing file $($orders_edited.Count) of $($total_to_edit_orders_cert). $($orders_not_edited.Count) of $($total_to_edit_orders_cert) not edited."
	        $percent_complete = (($($orders_edited.Count)/$($total_to_edit_orders_cert)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($($orders_edited.Count)/$($total_to_edit_orders_cert)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($($orders_edited.Count) / $total_to_edit_orders_cert)) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }

        if($orders_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_edited_csv) file now."
            Write-Verbose "[*] Writing $($orders_edited_csv) file now."
            $orders_edited | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_edited_csv)" -NoTypeInformation -Force
        }

        if($orders_not_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_not_edited_csv) file now."
            Write-Verbose "[*] Writing $($orders_not_edited_csv) file now."
            $orders_not_edited | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_not_edited_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to edit: $($total_to_edit_orders_cert). No .cof files in $($cof_directory_working). Make sure to split '*c.prt' files first. Use '$($script_name) -sc' first, then try again."
        Write-Warning -Message "[!] Total to edit: $($total_to_edit_orders_cert). No .cof files in $($cof_directory_working)." -RecommendedAction "Make sure to split '*c.prt' files first. Use '$($script_name) -sc' first, then try again."
    }
}

function Combine-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $run_date,
        [Parameter(mandatory = $true)] $exclude_directories
    )
	 
    #cls
 
    $total_to_combine_orders_main = Get-ChildItem -Path "$($mof_directory_working)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }

    $orders_combined_csv = "$($log_file_directory)\$($run_date)_combined_orders_main.csv"

    if($($($total_to_combine_orders_main.Count)) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        $orders_combined = @()

        $out_file = "$($log_directory_working)\$($run_date)\$($run_date)_orders_combined_main.txt"
        New-Item -ItemType File $out_file -Force > $null

        Write-Log -log_file $log_file -message "[#] Total to combine: $($total_to_combine_orders_main.Count). Combining .mof files now."
        Write-Verbose "[#] Total to combine: $($total_to_combine_orders_main.Count). Combining .mof files now."

        foreach($file in $total_to_combine_orders_main)
        {
            Process-DevCommands -sw $($sw)

            Get-Content "$($mof_directory_working)\$file" | Add-Content $out_file
            if($?)
            {
                $hash = @{
                    'FILE' = $($file.FullName)
                    'STATUS' = 'SUCCESS'
                }

                $order_combined = New-Object -TypeName PSObject -Property $hash
                $orders_combined += $order_combined

	            $status = "Combining '*m.prt' files."
	            $activity = "Processing file $($orders_combined.Count) of $($total_to_combine_orders_main.Count)."
	            $percent_complete = (($($orders_combined.Count)/$($total_to_combine_orders_main.Count)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_combined.Count)/$($total_to_combine_orders_main.Count)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_combined.Count) / $total_to_combine_orders_main.Count)) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                    Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }                    
            }
            else
            {
                Write-Log -level [ERROR] -log_file $log_file -message "[!] Combining .mof files failed."
                Write-Error "[!] Combining .mof files failed."
            }
        }

        if($orders_combined.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_combined_csv) file now."
            Write-Verbose "[*] Writing $($orders_combined_csv) file now."
            $orders_combined | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_combined_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to combine: $($total_to_combine_orders_main.Count). No .mof files in $($mof_directory_working) to combine. Make sure to split and edit '*m.prt' files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
        Write-Warning -Message "[!] Total to combine: $($total_to_combine_orders_main.Count). No .mof files in $($mof_directory_working) to combine." -RecommendedAction "Make sure to split and edit '*m.prt' files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
    }
}

function Combine-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $run_date
    )
	  
    #cls

    $total_to_combine_orders_cert = Get-ChildItem -Path "$($cof_directory_working)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' -and $_.Name -like "*_edited.cof" }

    $orders_combined_csv = "$($log_directory_working)\$($run_date)\$($run_date)_combined_orders_cert.csv"

    if($($($total_to_combine_orders_cert.Count)) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        $orders_combined = @()

        $out_file = "$($log_directory_working)\$($run_date)\$($run_date)_orders_combined_cert.txt"
        New-Item -ItemType File $out_file -Force > $null

        Write-Log -log_file $log_file -message "[#] Total to combine: $($total_to_combine_orders_cert.Count). Combining .cof files now."
        Write-Verbose "[#] Total to combine: $($total_to_combine_orders_cert.Count). Combining .cof files now."

        foreach($file in $total_to_combine_orders_cert)
        {
            Process-DevCommands -sw $($sw)

            Get-Content "$($cof_directory_working)\$file" | Add-Content $out_file
            if($?)
            {
                $hash = @{
                    'FILE' = $($file.FullName)
                    'STATUS' = 'SUCCESS'
                }

                $order_combined = New-Object -TypeName PSObject -Property $hash
                $orders_combined += $order_combined

	            $status = "Combining '*c.prt' files."
	            $activity = "Processing file $($orders_combined.Count) of $($total_to_combine_orders_cert.Count)."
	            $percent_complete = (($($orders_combined.Count)/$($total_to_combine_orders_cert.Count)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_combined.Count)/$($total_to_combine_orders_cert.Count)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_combined.Count) / $total_to_combine_orders_cert.Count)) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                    Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }                    
            }
            else
            {
                Write-Log -level [ERROR] -log_file $log_file -message "[!] Combining .cof files failed."
                Write-Error "[!] Combining .cof files failed."
            }
        }

        if($orders_combined.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "[*] Writing $($orders_combined_csv) file now."
            Write-Verbose "[*] Writing $($orders_combined_csv) file now."
            $orders_combined | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_combined_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to combine: $($total_to_combine_orders_cert.Count). No .cof files in $($cof_directory_working) to combine. Make sure to split and edit '*c.prt' files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
        Write-Warning -Message "[!] Total to combine: $($total_to_combine_orders_cert.Count). No .cof files in $($cof_directory_working) to combine." -RecommendedAction "Make sure to split and edit '*c.prt' files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
    }
}

function Parse-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $regex_format_parse_orders_main,
        [Parameter(mandatory = $true)] $regex_order_number_parse_orders_main,
        [Parameter(mandatory = $true)] $regex_uic_parse_orders_main,
        [Parameter(mandatory = $true)] $regex_pertaining_to_parse_orders_main
    )
	  
    #cls

    $total_to_create_orders_main = (Get-ChildItem -Path $($mof_directory_working) | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }).Length

    if($($total_to_create_orders_main) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        $orders_created_main = @()
        $orders_not_created_main = @()
        
        $orders_created_main_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_main.csv"
        $orders_not_created_main_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_main.csv"

        Write-Log -log_file $log_file -message "[#] Total to create: $($total_to_create_orders_main)."
        Write-Verbose "[#] Total to create: $($total_to_create_orders_main)."

        foreach($file in (Get-ChildItem -Path "$($mof_directory_working)" -Filter "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories }))
            {
                Process-DevCommands -sw $($sw)

                # Check for different 700 forms.
                $following_request = "Following Request is" # Disapproved || Approved
                $following_request_exists = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                $following_order = "Following order is amended as indicated." # Amendment order. $($format.Length) -eq 4
                $following_order_exists = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($following_order) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

                # Check for bad 282 forms.
                $following_request = "Following Request is" # Disapproved || Approved
                $following_request_exists = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

                # Check for "Memorandum for record" file that does not have format number, order number, period, basically nothing
                $memorandum_for_record = "MEMORANDUM FOR RECORD"
                $memorandum_for_record_exists = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($memorandum_for_record) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

                Write-Log -log_file $log_file -message "[#] Looking for 'format' in $($file)."
                Write-Verbose "[#] Looking for 'format' in $($file)."
                $format = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_format_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                if($($format))
                {
                    $format = $format.ToString()
                    $format = $format.Split(' ')
                    $format = $format[1]
                }
                else
                {
                    $error_code = "0xNF"
                    $error_info = "File $($file) with no format. Error code $($error_code)."

                    Write-Log -log_file $log_file -message "[+] $($error_info)"
                    Write-Verbose "[+] $($error_info)"

                    $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_main += $order_info

                    continue
                }

                if($($following_request_exists)) # Any format containing Following Request is APPROVED||DISAPPROVED and no Order Number.
                {
                    $error_code = "0xFR"
                    $error_info = "File $($file) containing 'Following request is APPROVED || DISAPPROVED'. This is a known issue and guidance has been to disregard these files. Error code $($error_code)."

                    Write-Log -level [WARN] -log_file $log_file -message "[+] $($error_info)"
                    Write-Warning "[!] $($error_info)"

                     $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_main += $order_info
                               
                    continue
                }
                elseif($($format) -eq '165' -and !($($following_request_exists)))
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "[#] Looking for order number in $($file)."
                    Write-Verbose "[#] Looking for order number in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $order_number = $order_number[1]
                    Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'published year' in $($file)."
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "[*] Found 'published year' in $($file)."
                    Write-Verbose "[*] Found 'published year' in $($file)."

                    $anchor = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "You are ordered to" -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | 
                    Select -First 1 | 
                    ConvertFrom-String | 
                    Select P3, P4, P5, P6 ) # MI (3 = last, 4 = first, 5 = MI, 6 = SSN) // NO MI ( 3 = last, 4 = first, 5 = ssn, 6 = rank )

                    Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    $last_name = $anchor.P3
                    $last_name = $last_name.Split(':')[-1]
                    $first_name = $anchor.P4
                    $middle_initial = $anchor.P5

                    if($($middle_initial).Length -ne 1 -and $($middle_initial).Length -gt 2)
                    {
                        $middle_initial = 'NMI'
                        $ssn = $anchor.P5
                    }
                    else
                    {
                        $middle_initial = $anchor.P5
                        $ssn = $anchor.P6
                    }
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "[*] Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period from year, month, day' in $($file)."
                    $period_from = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "REPORT TO " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period_from = $period_from.ToString()
                    $period_from = $period_from.Split(' ')
                    $period_from_day = $period_from[4]
                    $period_from_month = $period_from[5]
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_year = $period_from[6]
                    $period_from_year = @($period_from_year -split '(.{2})' | ? {$_})
                    $period_from_year = $($period_from_year[1]) # YYYY turned into YY
                    $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period from year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period to year, month, day' in $($file)."
                    $period_to = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "Period of active duty: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period_to = $period_to.ToString()
                    $period_to = $period_to.Split(' ')
                    $period_to_number = $period_to[-2]
                    $period_to_time = $period_to[-1]
                    $period_to_time = $period_to_time.ToUpper()
                    $period_to_time = $period_to_time.Substring(0, 1)
                    $period_to = "NTE$($period_to_number)$($period_to_time)"
                    Write-Log -log_file $log_file -message "[*] Found 'period to year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'uic' in $($file)."
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "[*] Found 'uic' in $($file)."
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_time $($period_to_time) -period_to_number $($period_to_number) -uic $($uic) -format $($format)
                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
                        Write-Verbose "[*] All variables for $($file) passed validation."

                        $uic_directory = "$($uics_directory_output)\$($uic)"
                        $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
                        $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
                        $uic_soldier_order_file_content = (Get-Content "$($mof_directory_working)\$($file)" -Raw)
                        
                        Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)
                        
                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                            PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                            PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                            PERIOD_TO_NUMBER = $($period_to_number)
                            PERIOD_TO_TIME = $($period_to_time)
                            FORMAT = $($format)
                            ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                            ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info         
                    }
                    else
                    {
                        $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
                        if($total_validation_fails -gt 1)
                        {                            
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = $($period_to_number)
                                PERIOD_TO_TIME = $($period_to_time)
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values." 
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."   
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                        }
                        elseif($total_validation_fails -eq 1)
                        {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = $($period_to_number)
                                PERIOD_TO_TIME = $($period_to_time)
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   
                            
                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values." 
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."     
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."                     
                        }
                    }
                }
                elseif($($format) -eq '172' -and !($($following_request_exists)))
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "[#] Looking for 'order number' in $($file)."
                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "[#] Looking for 'published year' in $($file)."
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "[*] Found 'published year' in $($file)."
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1]
                    Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    $anchor = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
                    $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

                    # Code to fix people that have no middle name.
                    if($($anchor.MiddleInitial).Length -ne 1 -and $($anchor.MiddleInitial).Length -gt 2)
                    {
                        $anchor.SSN = $anchor.MiddleInitial
                        $anchor.MiddleInitial = 'NMI'
                    }

                    $last_name = $($anchor.LastName)
                    $last_name = $last_name.Split(':')[-1]
                    $first_name = $($anchor.FirstName)
                    $middle_initial = $($anchor.MiddleInitial)
                    $ssn = $($anchor.SSN)
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "[*] Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."
                    
                    Write-Log -log_file $log_file -message "[#] Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period from year, month, day' in $($file)."
                    $period = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "Active duty commitment: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period = $period.ToString()
                    $period = $period.Split(' ')
                    $period_from_day = $period[3]
                    $period_from_day = $period_from_day.ToString()
                    if($($period_from_day).Length -ne 2)
                    {
                        $period_from_day = "0$($period_from_day)"
                    }
                    $period_from_month = $period[4]
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_year = $period[5]
                    $period_from_year = @($period_from_year -split '(.{2})' | ? {$_})
                    $period_from_year = $($period_from_year[1]) # YYYY turned into YY
                    $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period from year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period to year, month, day' in $($file)."
                    $period_to_day = $period[-3]
                    $period_to_day = $period_to_day.ToString()
                    if($($period_to_day).Length -ne 2)
                    {
                        $period_to_day = "0$($period_to_day)"
                    }

                    $period_to_month = $period[-2]
                    $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
                    $period_to_year = $period[-1]
                    $period_to_year = @($period_to_year -split '(.{2})' | ? {$_})
                    $period_to_year = $($period_to_year[1]) # YYYY turned into YY
                    $period_to = "$($period_to_year)$($period_to_month)$($period_to_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period to year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."
                    
                    Write-Log -log_file $log_file -message "[#] Looking for 'uic' in $($file)."
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "[*] Found 'uic' in $($file)."
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -format $($format) -uic $($uic) -first_name $($first_name) -last_name $($last_name) -middle_initial $($middle_initial) -order_number $($order_number) -published_year $($published_year) -ssn $($ssn) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
	                    Write-Verbose "[*] All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_working)\$($file)" -Raw)
	
	                    Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)

                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = ''
                            PUBLISHED_DAY = ''
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = $($period_to_year)
                            PERIOD_TO_MONTH = $($period_to_month)
                            PERIOD_TO_DAY = $($period_to_day)
                            PERIOD_TO_NUMBER = ''
                            PERIOD_TO_TIME = ''
                            FORMAT = $($format)
                            ORDER_AMENDED = ''
                            ORDER_REVOKE = ''
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -like '700' -and !($($following_request_exists))) # Amendment order for "700" and "700 *" formats
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "[#] Looking for 'order number' in $($file)."
                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "[#] Looking for 'published year' in $($file)."
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Log -log_file $log_file -message "[*] Found 'published year' in $($file)."
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                    Write-Verbose "[*] Found 'order number' in $($file)."
                    
                    Write-Log -log_file $log_file -message "[#] Looking for 'uic' in $($file)."
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "[*] Found 'uic' in $($file)."
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'order amended' in $($file)."
                    Write-Verbose "[#] Looking for 'order amended' in $($file)."
                    $order_amended = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_amended = $order_amended.ToString()
                    $order_amended = $order_amended.Split(' ')
                    $order_amended = $order_amended[5]
                    $order_amended = $order_amended.Insert(3,"-")
                    Write-Log -log_file $log_file -message "[*] Found 'order amended' in $($file)."
                    Write-Verbose "[*] Found 'order amended' in $($file)."

                    $pertaining_to = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
                    $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

                    Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    # Code to fix people that have no middle name. Currently untested for revoke section.
                    if($($pertaining_to.MiddleInitial).Length -ne 1 -and $($pertaining_to.MiddleInitial).Length -gt 2)
                    {
                        $pertaining_to.SSN = $pertaining_to.MiddleInitial
                        $pertaining_to.MiddleInitial = 'NMI'
                    }

                    $last_name = $($pertaining_to.LastName)
                    $first_name = $($pertaining_to.FirstName)
                    $middle_initial = $($pertaining_to.MiddleInitial)
                    $ssn = $($pertaining_to.SSN)
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "[*] Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -uic $($uic) -order_amended $($order_amended) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -format $($format)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
	                    Write-Verbose "[*] All variables for $($file) passed validation."

                        $uic_directory = "$($uics_directory_output)\$($uic)"
                        $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
                        $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_amended)___$($format).txt"
                        $uic_soldier_order_file_content = (Get-Content "$($mof_directory_working)\$($file)" -Raw)
	
	                    Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)

                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = ''
                            PUBLISHED_DAY = ''
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = ''
                            PERIOD_TO_MONTH = ''
                            PERIOD_TO_NUMBER = ''
                            PERIOD_TO_TIME = ''
                            FORMAT = $($format)
                            ORDER_AMENDED = $($order_amended)
                            ORDER_REVOKE = ''
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = $($order_amended)
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = $($order_amended)
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -eq '705' -and !($($following_request_exists))) # Revoke.
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "[#] Looking for 'order number' in $($file)."
                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "[#] Looking for 'published year' in $($file)."
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Log -log_file $log_file -message "[*] Found 'published year' in $($file)."
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'uic' in $($file)."
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "[*] Found 'uic' in $($file)."
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'order revoke' in $($file)."
                    Write-Verbose "[#] Looking for 'order revoke' in $($file)."
                    $order_revoke = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_revoke = $order_revoke.ToString()
                    $order_revoke = $order_revoke.Split(' ')
                    $order_revoke = $order_revoke[5]
                    $order_revoke = $order_revoke.Insert(3,"-")
                    Write-Log -log_file $log_file -message "[*] Found 'order revoke' in $($file)."
                    Write-Verbose "[*] Found 'order revoke' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    $pertaining_to = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
                    $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

                    # Code to fix people that have no middle name. Currently untested for revoke section.
                    if($($pertaining_to.MiddleInitial).Length -ne 1 -and $($pertaining_to.MiddleInitial).Length -gt 2)
                    {
                        $pertaining_to.SSN = $pertaining_to.MiddleInitial
                        $pertaining_to.MiddleInitial = 'NMI'
                    }

                    $last_name = $($pertaining_to.LastName)
                    $first_name = $($pertaining_to.FirstName)
                    $middle_initial = $($pertaining_to.MiddleInitial)
                    $ssn = $($pertaining_to.SSN)
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "[*] Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -uic $($uic) -order_revoke $($order_revoke) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -format $($format)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
	                    Write-Verbose "[*] All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_revoke)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_working)\$($file)" -Raw)

	                    Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)

                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = ''
                            PUBLISHED_DAY = ''
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = ''
                            PERIOD_TO_MONTH = ''
                            PERIOD_TO_NUMBER = ''
                            PERIOD_TO_TIME = ''
                            FORMAT = $($format)
                            ORDER_AMENDED = ''
                            ORDER_REVOKE = $($order_revoke)
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = $($order_revoke)
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = $($order_revoke)
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -eq '290' -and !($($following_request_exists))) # Pay order only.
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "[#] Looking for 'order number' in $($file)."
                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "[#] Looking for 'published year' in $($file)."
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Log -log_file $log_file -message "[*] Found 'published year' in $($file)."
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    $anchor = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "By order of the Secretary of the Army" -AllMatches -Context 5,0 -ErrorAction SilentlyContinue)
                    $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

                    # Code to fix people that have no middle name.
                    if($($anchor.MiddleInitial).Length -ne 1 -and $($anchor.MiddleInitial).Length -gt 2)
                    {
                        $anchor.SSN = $anchor.MiddleInitial
                        $anchor.MiddleInitial = 'NMI'
                    }
                    $last_name = $($anchor.LastName)
                    $last_name = $last_name.Split(':')[-1]
                    $first_name = $($anchor.FirstName)
                    $middle_initial = $($anchor.MiddleInitial)
                    $ssn = $($anchor.SSN)
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "[*] Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period from year, month, day' in $($file)."
                    $period = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period = $period.ToString()
                    $period = $period.Split(' ')        
                    $period_status = $($period[1])
                    $period_from_day = $($period[3])
                    if($($period_from_day).Length -ne 2)
                    {
                        $period_from_day = "0$($period_from_day)"
                    }
                    $period_from_month = $($period[4])
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_year = $($period[5])
                    $period_from_year = @($period_from_year -split '(.{2})' | ? {$_})
                    $period_from_year = $($period_from_year[1]) # YYYY turned into YY
                    $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period from year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period to year, month, day' in $($file)."
                    $period_to_day = $($period[-3])
                    if($($period_to_day).Length -ne 2)
                    {
                        $period_to_day = "0$($period_to_day)"
                    }
                    $period_to_month = $($period[-2])
                    $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
                    $period_to_year = $($period[-1])
                    $period_to_year = @($period_to_year -split '(.{2})' | ? {$_})
                    $period_to_year = $($period_to_year[1]) # YYYY turned into YY
                    $period_to = "$($period_to_year)$($period_to_month)$($period_to_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period to year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'uic' in $($file)."
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $uic = $uic.ToString()
                    $uic = $uic.Split(' ')
                    $uic = $uic[0]
                    $uic = $uic.Split(":")
                    $uic = $uic[-1]
                    $uic = $uic -replace "[:\(\)./]",""
                    $uic = $uic.Split('-')
                    $uic = $uic[0]
                    Write-Log -log_file $log_file -message "[*] Found 'uic' in $($file)."
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
	                    Write-Verbose "[*] All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_working)\$($file)" -Raw)

	                    Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)

                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = ''
                            PUBLISHED_DAY = ''
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = $($period_to_year)
                            PERIOD_TO_MONTH = $($period_to_month)
                            PERIOD_TO_DAY = $($period_to_day)
                            PERIOD_TO_NUMBER = ''
                            PERIOD_TO_TIME = ''
                            FORMAT = $($format)
                            ORDER_AMENDED = ''
                            ORDER_REVOKE = ''
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -eq '296' -or $($format) -eq '282' -or $($format) -eq '294' -or $($format) -eq '284' -and !($($following_request_exists))) # 296 AT Orders // 282 Unknown // 294 Full Time National Guard Duty - Operational Support (FTNGD-OS) // 284 Unknown.
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "[#] Looking for 'order number' in $($file)."
                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $month = $order_number[-2]
                    $published_month = $months.Get_Item($($month)) # Retrieve month number value from hash table.
                    Write-Log -log_file $log_file -message "[#] Looking for 'published year' in $($file)."
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "[*] Found 'published year' in $($file)."
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1]
                    Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[#] Looking for 'last, first, mi, ssn' in $($file)."
                    $anchor = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
                    $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

                    # Code to fix people that have no middle name.
                    if($($anchor.MiddleInitial).Length -ne 1 -and $($anchor.MiddleInitial).Length -gt 2)
                    {
                        $anchor.SSN = $anchor.MiddleInitial
                        $anchor.MiddleInitial = 'NMI'
                    }

                    $last_name = $($anchor.LastName)
                    $last_name = $last_name.Split(':')[-1]
                    $first_name = $($anchor.FirstName)
                    $middle_initial = $($anchor.MiddleInitial)
                    $ssn = $($anchor.SSN)
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "[*] Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period from year, month, day' in $($file)."
                    $period = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period = $period.ToString()
                    $period = $period.Split(' ')
                    $period_status = $($period[1])
                    $period_from_day = $($period[3])
                    if($($period_from_day).Length -ne 2)
                    {
                        $period_from_day = "0$($period_from_day)"
                    }
                    $period_from_month = $($period[4])
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_year = $($period[5])
                    $period_from_year = @($period_from_year -split '(.{2})' | ? {$_})
                    $period_from_year = $($period_from_year[1]) # YYYY turned into YY
                    $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period from year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "[#] Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "[#] Looking for 'period to year, month, day' in $($file)."
                    $period_to_day = $($period[-3])
                    if($($period_to_day).Length -ne 2)
                    {
                        $period_to_day = "0$($period_to_day)"
                    }
                    $period_to_month = $($period[-2])
                    $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
                    $period_to_year = $($period[-1])
                    $period_to_year = @($period_to_year -split '(.{2})' | ? {$_})
                    $period_to_year = $($period_to_year[1]) # YYYY turned into YY
                    $period_to = "$($period_to_year)$($period_to_month)$($period_to_day)"
                    Write-Log -log_file $log_file -message "[*] Found 'period to year, month, day' in $($file)."
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."
                    
                    Write-Log -log_file $log_file -message "[#] Looking for 'uic' in $($file)."
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $uic = $uic.ToString()
                    $uic = $uic.Split(' ')
                    $uic = $uic[0]
                    $uic = $uic.Split(":")
                    $uic = $uic[-1]
                    $uic = $uic -replace "[:\(\)./]",""
                    $uic = $uic.Split('-')
                    $uic = $uic[0]
                    Write-Log -log_file $log_file -message "[*] Found 'uic' in $($file)."
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
	                    Write-Verbose "[*] All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_working)\$($file)" -Raw)

	                    Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)

                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = ''
                            PUBLISHED_DAY = ''
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = $($period_to_year)
                            PERIOD_TO_MONTH = $($period_to_month)
                            PERIOD_TO_DAY = $($period_to_day)
                            PERIOD_TO_NUMBER = ''
                            PERIOD_TO_TIME = ''
                            FORMAT = $($format)
                            ORDER_AMENDED = ''
                            ORDER_REVOKE = ''
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                else
                {
                    $error_code = "0x00"
                    $error_info = "File $($file) with format $($format). This is not currently an unknown and/or handled format. Notify ORDPRO support of this error ASAP. Error code $($error_code)."

                    Write-Log -level [WARN] -log_file $log_file -message "[+] $($error_info)"
                    Write-Verbose "[+] $($error_info)"
                    
                    $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_main += $order_info

                    continue
                }

	            $status = "Working magic on '*m.prt' files."
	            $activity = "Processing file $($orders_created_main.Count) of $($total_to_create_orders_main). $($orders_not_created_main.Count) of $($total_to_create_orders_main) not created."
	            $percent_complete = (($($orders_created_main.Count)/$($total_to_create_orders_main)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_created_main.Count)/$($total_to_create_orders_main)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_created_main.Count) / $total_to_create_orders_main)) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                    Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }
            }

            if($($orders_created_main.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "[*] Writing $($orders_created_main_csv) file now."
                Write-Verbose "[*] Writing $($orders_created_main_csv) file now."
                $orders_created_main | Select FORMAT, ORDER_NUMBER, ORDER_AMENDED, ORDER_REVOKE, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PUBLISHED_YEAR, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY, PERIOD_TO_NUMBER, PERIOD_TO_TIME, PUBLISHED_MONTH, PUBLISHED_DAY | Sort -Property ORDER_NUMBER | Export-Csv "$($orders_created_main_csv)" -NoTypeInformation -Force
            }

            if($($orders_not_created_main.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "[*] Writing $($orders_not_created_main_csv) file now."
                Write-Verbose "[*] Writing $($orders_not_created_main_csv) file now."
                $orders_not_created_main | Select FILE, ERROR_CODE, ERROR_INFO | Sort -Property ERROR_CODE | Export-Csv "$($orders_not_created_main_csv)" -NoTypeInformation -Force
            }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total to create: ($($total_to_create_orders_main)). No .mof files in $($mof_directory_working) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm -em' then try again."
        Write-Warning -Message "[!] Total to create: ($($total_to_create_orders_main)). No .mof files in $($mof_directory_working) to work magic on." -RecommendedAction "Make sure to split and edit *m.prt files first. Use '$($script_name) -sm -em' then try again."
    }
}

function Parse-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )
	  
    $total_to_create_orders_cert = (Get-ChildItem -Path "$($cof_directory_working)" -Filter "*.cof" -Include "*_edited.cof" -Exclude $($exclude_directories) -Recurse).Length
    
    if($($total_to_create_orders_cert) -gt '0')
    {
        $sw = New-Object System.Diagnostics.Stopwatch
        $sw.start()

        #cls

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        $orders_created_cert = @()
        $orders_not_created_cert = @()
        $orders_created_cert_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_cert.csv"
        $orders_not_created_cert_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_cert.csv"

        $soldiers = @(Get-ChildItem -Path "$($uics_directory_output)" -Exclude "__PERMISSIONS" -Recurse -Include "*.txt" | % { Split-Path  -Path $_  -Parent })
        $name_ssn = @{}

        Write-Log -log_file $log_file -message "[#] Total to create: $($total_to_create_orders_cert). Populating name_ssn hash table now."
        Write-Verbose "[#] Total to create: $($total_to_create_orders_cert). Populating name_ssn hash table now."

        foreach($s in $soldiers)
        {
            Process-DevCommands -sw $($sw)

            $s = $s -split "\\" -split "___"
            $name = $s[-2]
            $ssn = $s[-1]

            if(!($name_ssn.ContainsKey($name)))
            {
                Write-Log -level [INFO] -log_file $log_file -message "[#] $($name) not in hash table. Adding $($name) to hash table now."
                Write-Verbose "[#] $($name) not in hash table. Adding $($name) to hash table now."

                $name_ssn.Add($name, $ssn)

                if($?)
                {
                    Write-Log -log_file $log_file -message "[*] $($name) added to hash table succcessfully."
                    Write-Verbose "[*] $($name) added to hash table succcessfully."
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message "[!] $($name) failed to add to hash table."  
                    Write-Verbose "[!] $($name) failed to add to hash table."  
                }
            }
            else
            {
                Write-Log -log_file $log_file -message "[*] $($name) already in hash table."
                Write-Verbose "[*] $($name) already in hash table."
            }
        }

        Write-Log -log_file $log_file -message "[*] Finished populating soldiers_ssn hash table."
        Write-Verbose "[*] Finished populating soldiers_ssn hash table."

        foreach($file in (Get-ChildItem -Path "$($cof_directory_working)" -Filter "*.cof" -Include "*_edited.cof" -Exclude $($exclude_directories) -Recurse))
            {
                Process-DevCommands -sw $($sw)

                foreach($line in (Get-Content "$($file)"))
                {
                    if($line -eq '')
                    {
                        continue
                    }
                    else
                    {
                        $uic = $($line)
                        $uic = $uic.ToString()
                        $uic = $uic.Split(' ')
                        $uic = $uic[-1]
                        break
                    }
                }

                Write-Log -log_file $log_file -message "[#] Looking for 'last, first, mi' in $($file)."
                Write-Verbose "[#] Looking for 'last, first, mi' in $($file)."
                $name = (Select-String -Path "$($file)" -Pattern $($regex_name_parse_orders_cert) -ErrorAction SilentlyContinue  | Select -First 1)
                $name = $name.ToString()
                $name = $name.Split(' ')
                $last_name = $name[5]
                $first_name = $name[6]
                $middle_initial = $name[7]
                if($($middle_initial).Length -ne 1 -and $($middle_initial).Length -gt '2' -or $($middle_initial) -eq '')
                {
                    $middle_initial = 'NMI'
                }
                else
                {
                    $middle_initial = $name[7]
                }
                $name = "$($last_name)_$($first_name)_$($middle_initial)"
                Write-Log -log_file $log_file -message "[*] Found 'last, first, mi' in $($file)."
                Write-Verbose "[*] Found 'last, first, mi' in $($file)."

                Write-Log -log_file $log_file -message "[#] Looking for 'order number' in $($file)."
                Write-Verbose "[#] Looking for 'order number' in $($file)."
                $order_number = (Select-String -Path "$($file)" -Pattern $($regex_order_number_parse_orders_cert) -ErrorAction SilentlyContinue | Select -First 1)
                $order_number = $order_number.ToString()
                $order_number = $order_number.Split(' ')
                $order_number = $($order_number[2])
                $order_number = $order_number.Insert(3,"-")
                Write-Log -log_file $log_file -message "[*] Found 'order number' in $($file)."
                Write-Verbose "[*] Found 'order number' in $($file)."

                Write-Log -log_file $log_file -message "[#] Looking for 'period from year, month, day' in $($file)."
                Write-Verbose "[#] Looking for 'period from year, month, day' in $($file)."
                $period = (Select-String -Path "$($file)" -Pattern $($regex_period_parse_orders_cert) -ErrorAction SilentlyContinue | Select -First 1)
                $period = $period.ToString()
                $period = $period.Split(' ')
                $period_from = $period[3]
                $period_from = @($period_from -split '(.{2})' | ? { $_ })
                $period_from_year = $period_from[0]
                $period_from_month = $period_from[1]
                $period_from_day = $period_from[2]
                $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"

                $period_to = $period[7]
                $period_to = @($period_to -split '(.{2})' | ? { $_ })
                $period_to_year = $period_to[0]
                $period_to_month = $period_to[1]
                $period_to_day = $period_to[2]
                $period_to = "$($period_to_year)$($period_to_month)$($period_to_day)"
                Write-Log -log_file $log_file -message "[*] Found 'period from year, month, day' in $($file)."
                Write-Verbose "[*] Found 'period from year, month, day' in $($file)."
        
                Write-Log -log_file $log_file -message "[#] Looking up 'ssn' in hash table for $($file)."
                Write-Verbose "[#] Looking up 'ssn' in hash table for $($file)."
                $ssn = $name_ssn."$($last_name)_$($first_name)_$($middle_initial)" # Retrieve ssn from soldiers_ssn hash table via key lookup.      
                Write-Log -log_file $log_file -message "[*] Found 'ssn' in hash table for $($file)."
                Write-Verbose "[*] Found 'ssn' in hash table for $($file)."

                $validation_results = Validate-Variables -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                if(!($validation_results.Status -contains 'fail'))
                {
                    Write-Log -log_file $log_file -message "[*] All variables for $($file) passed validation."
	                Write-Verbose "[*] All variables for $($file) passed validation."

	                $uic_directory = "$($uics_directory_output)\$($uic)"
	                $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                    $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                $uic_soldier_order_file_name = "$($period_from_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___cert.txt"
	                $uic_soldier_order_file_content = (Get-Content "$($file)" -Raw)

	                Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)

                    $hash = @{
                        UIC = $($uic)
                        LAST_NAME = $($last_name)
                        FIRST_NAME = $($first_name)
                        MIDDLE_INITIAL = $($middle_initial)
                        SSN = $($ssn)
                        PERIOD_FROM_YEAR = $($period_from_year)
                        PERIOD_FROM_MONTH = $($period_from_month)
                        PERIOD_FROM_DAY = $($period_from_day)
                        PERIOD_TO_YEAR = $($period_to_year)
                        PERIOD_TO_MONTH = $($period_to_month)
                        PERIOD_TO_DAY = $($period_to_day)
                        FORMAT = '102-10A'
                        ORDER_NUMBER = $($order_number)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
	                $orders_created_cert += $order_info
                }
                else
                {
	                $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                if($total_validation_fails -gt 1)
	                {
                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = $($period_to_year)
                            PERIOD_TO_MONTH = $($period_to_month)
                            PERIOD_TO_DAY = $($period_to_day)
                            FORMAT = '102-10A'
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_not_created_cert += $order_info

                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
		                Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
                        #throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
	                }
	                elseif($total_validation_fails -eq 1)
	                {
                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = $($period_to_year)
                            PERIOD_TO_MONTH = $($period_to_month)
                            PERIOD_TO_DAY = $($period_to_day)
                            FORMAT = '102-10A'
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_not_created_cert += $order_info

                        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
		                Write-Error -Message "[!] $($total_validation_fails) variables for $($file) failed validation." -RecommendedAction "Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
                        #throw "[!] $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
	                }
                }

	            $status = "Working magic on '*c.prt' files."
	            $activity = "Processing file $($orders_created_cert.Count) of $($total_to_create_orders_cert). $($orders_not_created_cert.Count) of $($total_to_create_orders_cert) not created."
	            $percent_complete = (($($orders_created_cert.Count)/$($total_to_create_orders_cert)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_created_cert.Count)/$($total_to_create_orders_cert)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_created_cert.Count) / $total_to_create_orders_cert)) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Log -log_file $log_file -message "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                    Write-Verbose "[#] $($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }

            }

            if($($orders_created_cert.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "[*] Writing $($orders_created_cert_csv) file now."
                Write-Verbose "[*] Writing $($orders_created_cert_csv) file now."
                $orders_created_cert | Select FORMAT, ORDER_NUMBER, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY | Sort -Property ORDER_NUMBER | Export-Csv -NoTypeInformation -Path "$($orders_created_cert_csv)"
            }

            if($($orders_not_created_cert.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "[*] Writing $($orders_not_created_cert_csv) file now."
                Write-Verbose "[*] Writing $($orders_not_created_cert_csv) file now."
                $orders_not_created_cert | Select FORMAT, ORDER_NUMBER, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY | Sort -Property ORDER_NUMBER | Export-Csv -NoTypeInformation -Path "$($orders_not_created_cert_csv)"
            }
    }
    else
    {
        Write-Log -level [WARN] -logfile $logfile -message "[!] Total to create: $($total_to_create_orders_cert). No .cof files in $($cof_directory_working) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
        Write-Warning -Message "[!] Total to create: $($total_to_create_orders_cert). No .cof files in $($cof_directory_working) to work magic on." -RecommendedAction "Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
    }
}

function Work-Magic()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uic_directory,
        [Parameter(mandatory = $true)] $soldier_directory_uics,
        [Parameter(mandatory = $true)] $uic_soldier_order_file_name,
        [Parameter(mandatory = $true)] $uic_soldier_order_file_content,
        [Parameter(mandatory = $true)] $uic,
        [Parameter(mandatory = $true)] $last_name,
        [Parameter(mandatory = $true)] $first_name,
        [Parameter(mandatory = $true)] $middle_initial,
        [Parameter(mandatory = $true)] $ssn,
        [Parameter(mandatory = $true)] $soldier_directory_ord_managers
    )
	  
    if(Test-Path $($uic_directory))
    {
        Write-Log -log_file $log_file -message "[*] $($uic_directory) already created, continuing."
        Write-Verbose "[*] $($uic_directory) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "[#] $($uic_directory) not created. Creating now."
        Write-Verbose "[#] $($uic_directory) not created. Creating now."
        New-Item -ItemType Directory -Path "$($uics_directory_output)\$($uic)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($uic_directory) created successfully."
            Write-Verbose "[*] $($uic_directory) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($uic_directory) creation failed."
            Write-Error -Message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($uic_directory) creation failed."
        }
    }

    if(Test-Path $($soldier_directory_uics))
    {
        Write-Log -log_file $log_file -message "[*] $($soldier_directory_uics) already created, continuing."
        Write-Verbose "[*] $($soldier_directory_uics) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "[#] $($soldier_directory_uics) not created. Creating now."
        Write-Verbose "[#] $($soldier_directory_uics) not created. Creating now."
        New-Item -ItemType Directory -Path "$($soldier_directory_uics)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($soldier_directory_uics) created successfully."
            Write-Verbose "[*] $($soldier_directory_uics) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics) creation failed."
            Write-Error -Message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory_uics)\$($uic_soldier_order_file_name)")
    {
        Write-Log -log_file $log_file -message "[*] $($soldier_directory_uics)\$($uic_soldier_order_file_name) already created, continuing."
        Write-Verbose "[*] $($soldier_directory_uics)\$($uic_soldier_order_file_name) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "[#] $($soldier_directory_uics)\$($uic_soldier_order_file_name) not created. Creating now."
        Write-Verbose "[#] $($soldier_directory_uics)\$($uic_soldier_order_file_name) not created. Creating now."
        New-Item -ItemType File -Path $($soldier_directory_uics) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($soldier_directory_uics)\$($uic_soldier_order_file_name) created successfully."
            Write-Verbose "[*] $($soldier_directory_uics)\$($uic_soldier_order_file_name) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics)\$($uic_soldier_order_file_name) creation failed."
            Write-Error -Message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics)\$($uic_soldier_order_file_name) creation failed."
        }
    }

    if(Test-Path $($soldier_directory_ord_managers))
    {
        Write-Log -log_file $log_file -message "[*] $($soldier_directory_ord_managers) already created, continuing."
        Write-Verbose "[*] $($soldier_directory_ord_managers) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "[#] $($soldier_directory_ord_managers) not created. Creating now."
        Write-Verbose "[#] $($soldier_directory_ord_managers) not created. Creating now."
        New-Item -ItemType Directory -Path "$($soldier_directory_ord_managers)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($soldier_directory_ord_managers) created successfully."
            Write-Verbose "[*] $($soldier_directory_ord_managers) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers) creation failed."
            Write-Error -Message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name)")
    {
        Write-Log -log_file $log_file -message "[*] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) already created, continuing."
        Write-Verbose "[*] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "[#] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) not created. Creating now."
        Write-Verbose "[#] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) not created. Creating now."
        New-Item -ItemType File -Path $($soldier_directory_ord_managers) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) created successfully."
            Write-Verbose "[*] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) creation failed."
            Write-Error -Message "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) creation failed."
        }
    }
}

function Clean-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )

    $total_to_clean_main_files = @(Get-ChildItem -Path "$($mof_directory_working)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Count

    if($($total_to_clean_main_files) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        Write-Log -log_file $log_file -message "[#] Total .mof files to clean in $($mof_directory_working): $($total_to_clean_main_files)"
        Write-Verbose "[#] Total .mof files to clean in $($mof_directory_working): $($total_to_clean_main_files)"
        Remove-Item -Path "$($mof_directory_working)" -Recurse -Force

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($mof_directory_working) removed successfully. Cleaned: $($total_to_clean_main_files) .mof files from $($mof_directory_working)."
            New-Item -ItemType Directory -Path "$($mof_directory_working)" -Force > $null
            Start-Sleep -Milliseconds 250
            Write-Verbose "[*] $($mof_directory_working) removed successfully. Cleaned: $($total_to_clean_main_files) .mof files from $($mof_directory_working)."
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($mof_directory_working)" -Force > $null
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($mof_directory_original_splits_working)" -Force > $null
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to remove $($mof_directory_working). Make sure you don't have any files in the directory open still."
            Write-Error -Message "[!] Failed to remove $($mof_directory_working)." -RecommendedAction "Make sure you don't have any files in the directory open still."
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total .mof files to clean: $($total_to_clean_main_files). No .mof files in $($mof_directory_working) to clean up."
        Write-Warning "[!] Total .mof files to clean: $($total_to_clean_main_files). No .mof files in $($mof_directory_working) to clean up."
    }
}

function Clean-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )
	  
    $total_to_clean_cert_files = @(Get-ChildItem -Path "$($cof_directory_working)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Count

    if($($total_to_clean_cert_files) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        Write-Log -log_file $log_file -message "[#] Total .cof files to clean in $($cof_directory_working): $($total_to_clean_cert_files)"
        Write-Verbose "[#] Total .cof files to clean in $($cof_directory_working): $($total_to_clean_cert_files)"
        Remove-Item -Path "$($cof_directory_working)" -Recurse -Force

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($cof_directory_working) removed successfully. Cleaned: $($total_to_clean_cert_files) .cof files from $($cof_directory_working)."
            Write-Verbose "[*] $($cof_directory_working) removed successfully. Cleaned: $($total_to_clean_cert_files) .cof files from $($cof_directory_working)."
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($cof_directory_working)" -Force > $null
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($cof_directory_original_splits_working)" -Force > $null
            Start-Sleep -Milliseconds 250
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to remove $($cof_directory_working)." -RecommendedAction "Make sure you don't have any files in $($cof_directory_working) open still."
            Write-Error -Message "[!] Failed to remove $($cof_directory_working)." -RecommendedAction "Make sure you don't have any files in $($cof_directory_working) open still."
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total .cof files to clean: $($total_to_clean_cert_files). No .cof files in $($cof_directory_working) to clean up."
        Write-Warning "[!] Total .cof files to clean: $($total_to_clean_cert_files). No .cof files in $($cof_directory_working) to clean up."
    }
}

function Clean-UICS()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uics_directory_output
    )

    $total_to_clean_uics_directories = @(Get-ChildItem -Path "$($uics_directory_output)").Count

    if($($total_to_clean_uics_directories) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
        Write-Verbose "[#] Start time: $($start_time)."

        Write-Log -log_file $log_file -message "[#] Total UICS directories to clean in $($uics_directory_output): $($total_to_clean_uics_directories)."
        Write-Verbose "[#] Total UICS directories to clean in $($uics_directory_output): $($total_to_clean_uics_directories)."
        Remove-Item -Path "$($uics_directory_output)" -Recurse -Force

        if($?)
        {
            Write-Log -log_file $log_file -message "[*] $($uics_directory_output) removed successfully. Cleaned: $($total_to_clean_uics_directories) directories from $($uics_directory_output)."
            Write-Verbose "[*] $($uics_directory_output) removed successfully. Cleaned: $($total_to_clean_uics_directories) directories from $($uics_directory_output)."
            New-Item -ItemType Directory -Path "$($uics_directory_output)" -Force > $null
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message "[!] Failed to remove $($uics_directory_output)." -RecommendedAction "Make sure you don't have any files in $($uics_directory_output) open still."
            Write-Error -Message "[!] Failed to remove $($uics_directory_output)." -RecommendedAction "Make sure you don't have any files in $($uics_directory_output) open still."
        }
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message "[!] Total directories to clean: $($total_to_clean_uics_directories). No directories in $($uics_directory_output) to clean up."
        Write-Warning -Message "[!] Total directories to clean: $($total_to_clean_uics_directories). No directories in $($uics_directory_output) to clean up."
    }
}

function Get-Permissions()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uics_directory_output
    )

    $uics_directory = "$($uics_directory_output)\UICS"
    $permissions_reports_directory = "$($uics_directory_output)\__PERMISSIONS"
    $uics_directory = $uics_directory.Split('\')
    $uics_directory = $uics_directory[-1]

    $html_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.html"
    $csv_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.csv"
    $txt_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.txt"

    $start_time = Get-Date
    Write-Log -log_file $log_file -message "[#] Start time: $($start_time)."
    Write-Verbose "[#] Start time: $($start_time)."

    if(!(Test-Path "$($permissions_reports_directory)\$($run_date)"))
    {
        Write-Log -log_file $log_file -message "[#] $($permissions_reports_directory)\$($run_date) not created. Creating now."
        Write-Verbose "[#] $($permissions_reports_directory)\$($run_date) not created. Creating now."
        New-Item -ItemType Directory -Path "$($permissions_reports_directory)\$($run_date)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "$($permissions_reports_directory)\$($run_date) created successfully."
            Write-Verbose "$($permissions_reports_directory)\$($run_date) created successfully."
        }
    }

    Write-Log -log_file $log_file -message "[#] Writing permissions of $($uics_directory_output) to .csv file now."
    Write-Verbose "[#] Writing permissions of $($uics_directory_output) to .csv file now."

    Get-ChildItem -Recurse -Path $($uics_directory_output) | Where { $_.FullName -notmatch '__PERMISSIONS' } | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | Export-Csv -Force -NoTypeInformation $($csv_report)
    if($?)
    {
        Write-Log -log_file $log_file -message "[*] $($uics_directory_output) permissions writing to .csv finished successfully."
        Write-Verbose "[*] $($uics_directory_output) permissions writing to .csv finished successfully."
    }
    else
    {
        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($uics_directory_output) permissions writing to .csv failed."
        Write-Error -Message "[!] $($uics_directory_output) permissions writing to .csv failed."
    }

    Write-Log -log_file $log_file -message "[#] Writing permissions of $($uics_directory_output) to .html file now."
    Write-Verbose "[#] Writing permissions of $($uics_directory_output) to .html file now."
$css = 
@"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { font-size: 17px; background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 12px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
    Get-ChildItem -Recurse -Path $($uics_directory_output)  | Where { $_.FullName -notmatch '__PERMISSIONS' } | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | ConvertTo-Html -Title "$($uics_directory_output) Permissions Report" -Head $($css) -Body "<h1>$($uics_directory_output) Permissions Report</h1> <h5> Generated on $(Get-Date -UFormat "%Y-%m-%d @ %H-%M-%S")" | Out-File $($html_report)
    if($?)
    {
        Write-Log -log_file $log_file -message "[*] $($uics_directory_output) permissions writing to .html finished successfully."
        Write-Verbose "[*] $($uics_directory_output) permissions writing to .html finished successfully."
    }
    else
    {
        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($uics_directory_output) permissions writing to .html failed."
        Write-Error -Message "[!] $($uics_directory_output) permissions writing to .html failed."
    }

    Write-Log -log_file $log_file -message "[#] Writing permissions of $($uics_directory_output) to .txt file now."
    Write-Verbose "[#] Writing permissions of $($uics_directory_output) to .txt file now."
    Get-ChildItem -Recurse -Path $($uics_directory_output)  | Where { $_.FullName -notmatch '__PERMISSIONS' } | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | Format-Table -AutoSize -Wrap | Out-File $($txt_report)
    if($?)
    {
        Write-Log -log_file $log_file -message "[*] $($uics_directory_output) permissions writing to .txt finished successfully."
        Write-Verbose "[*] $($uics_directory_output) permissions writing to .txt finished successfully."
    }
    else
    {
        Write-Log -level [ERROR] -log_file $log_file -message "[!] $($uics_directory_output) permissions writing to .txt failed."
        Write-Error -Message "[!] $($uics_directory_output) permissions writing to .txt failed."
    }
}

function Validate-Variables()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $false)] $uic,
        [Parameter(mandatory = $false)] $last_name,
        [Parameter(mandatory = $false)] $first_name,
        [Parameter(mandatory = $false)] $middle_initial,
        [Parameter(mandatory = $false)] $published_year,
        [Parameter(mandatory = $false)] $published_month,
        [Parameter(mandatory = $false)] $published_day,
        [Parameter(mandatory = $false)] $ssn,
        [Parameter(mandatory = $false)] $period_from_year,
        [Parameter(mandatory = $false)] $period_from_month,
        [Parameter(mandatory = $false)] $period_from_day,
        [Parameter(mandatory = $false)] $period_to_year,
        [Parameter(mandatory = $false)] $period_to_month,
        [Parameter(mandatory = $false)] $period_to_day,
        [Parameter(mandatory = $false)] $period_to_number,
        [Parameter(mandatory = $false)] $period_to_time,
        [Parameter(mandatory = $false)] $format,
        [Parameter(mandatory = $false)] $order_amended,
        [Parameter(mandatory = $false)] $order_revoke,
        [Parameter(mandatory = $false)] $order_number
    )
    
    $parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
    $total_parameters = $parameters.count
    $parameters_passed = $PSBoundParameters.Count
    $parameters_processed = 0

    if($($parameters_passed) -gt '0')
    {
        $validation_results = @()

            foreach($p in $PSBoundParameters.GetEnumerator())
            {
                $parameters_processed ++

                Write-Log -log_file $log_file -message "[#] Validating ( $($parameters_processed) / $($parameters_passed) ) parameters now."
                Write-Verbose "[#] Validating ( $($parameters_processed) / $($parameters_passed) ) parameters now."

                $key = $p.Key
                $value = $p.Value

                if($key -eq 'uic')
                {
                    if($value -match "^\w{5}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'last_name')
                {
                    if($value -match "^[a-zA-Z'-]{1,20}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                    }
                }
                elseif($key -eq 'first_name')
                {
                    if($value -match "^[a-zA-Z'-]{1,20}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'middle_initial')
                {
                    if($value -match "^[A-Z]{1,3}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'published_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'published_month')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'published_day')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'ssn')
                {
                    if($value -match "^\d{3}-\d{2}-\d{4}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_from_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_from_month')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_from_day')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_month')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_day')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_number')
                {
                    if($value -match "^\d{1,4}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_time')
                {
                    if($value -match "^[A-Z]{4,6}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'format')
                {
                    if($value -match "^\d{3}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'order_amended')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'order_revoke')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'order_number')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
                        Write-Log -log_file $log_file -message "[*] Value '$($value)' from '$($key)' passed validation."
	                    Write-Verbose "[*] Value '$($value)' from '$($key)' passed validation."
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
                        Write-Log -level [ERROR] -log_file $log_file -message "[!] Value '$($value)' from '$($key)' failed validation."
	                    Write-Error "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message "[!] Incorrect or unknown parameter specified. Try again with proper input."
                    Write-Error "[!] Incorrect or unknown parameter specified. Try again with proper input."
                }

                Write-Verbose "[*] Finished validating ( $($parameters_processed) / $($parameters_passed) ) parameters."
            }

            return $validation_results
    }
    else
    {
        Write-Log -level [ERROR] -log_file $log_file -message "[!] No parameters passed. Try again with proper input."
        Write-Error "[!] No parameters passed. Try again with proper input."
    }
}

Function Write-Log 
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)][ValidateSet("[INFO]","[WARN]","[ERROR]","[FATAL]","[DEBUG]")][String]$level = "[INFO]",
        [Parameter(Mandatory=$True)][string]$message,
        [Parameter(Mandatory=$False)][string]$log_file
    )

    if(!(Test-Path $log_file))
    {
        New-Item -ItemType File -Path $log_file -Force > $null
    }

    $stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $line = "$stamp $level $message"

    If($log_file) 
    {            
        Add-Content $log_file -Value $line
    }
    Else 
    {
        Write-Output $line
    }
}

function Process-DevCommands()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $sw
    )

    if ([console]::KeyAvailable)
    {
        $key = [system.console]::readkey($true)

        if(($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "P"))
        {
            Write-Verbose "[-] Pausing at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
            $sw.Stop()

            Pause

		    Write-Verbose "[-] Resuming at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
            $sw.Start()
        }
        elseif(($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "Q" ))
        {
            $sw.Stop()
            $response = Read-Host -Prompt "Are you sure you want to exit? [ (Y|y) / (N|n) ]"
            
            switch($response)
            {
                { @("y", "Y") -contains $_ } { "Terminating at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd) by user."; exit 0 }
                { @("n", "N") -contains $_ } { $sw.Start(); continue }
                default { Write-Warning "Response not determined." }
            }
        }
    }
}


<#
ENTRY POINT
#>
$Parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
$TotalParameters = $parameters.count
$ParametersPassed = $PSBoundParameters.Count

If ($ParametersPassed -eq $TotalParameters) { Write-Verbose "All $totalParameters parameters are being used." }
ElseIf ($ParametersPassed -eq 1) { Write-Verbose "1 parameter is being used." }
Else { Write-Output "$parametersPassed parameters are being used." }

if($($ParametersPassed) -gt '0')
{
    $params = @($psBoundParameters.Keys)

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
                    Write-Error "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included."
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
                    Write-Error "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Backing up original orders file." -ForegroundColor Cyan
		        Move-OriginalToArchive -tmp_directory_working $($tmp_directory_working) -archive_directory_working $($archive_directory_working) -ordregisters_output $($ordregisters_output)

		        if($?) 
		        { 
			        Write-Host "[^] Backing up original orders file finished." -ForegroundColor Cyan 
		        }	
            }

            "split_main" 
            { 
		        Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files." -ForegroundColor Cyan	
		        Split-OrdersMain -current_directory_working $($current_directory_working) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)

		        if($?)
		        {
			        Write-Host "[^] Splitting '*m.prt' order file(s) finished." -ForegroundColor Cyan 
		        }
            }

            "split_cert"
            { 
		        Write-Host "[^] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor Cyan
		        Split-OrdersCertificate -current_directory_working $($current_directory_working) -cof_directory_working $($cof_directory_working) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)

		        if($?) 
		        {
			        Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished." -ForegroundColor Cyan
		        } 	

            }

            "edit_main" 
            { 
		        Write-Host "[^] Editing orders '*m.prt' files." -ForegroundColor Cyan
		        Edit-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_original_splits_working $($mof_directory_original_splits_working)

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
		        Write-Host "[^] Combining .mof orders files." -ForegroundColor Cyan
		        Combine-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -run_date $($run_date)

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
                    Write-Error "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

                Write-Host "[^ Working magic on .mof files now." -ForegroundColor Cyan
                Parse-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
		        if($?) 
		        { 
			        Write-Host "[^] Magic on .mof files finished. Did you expect anything less?" -ForegroundColor Cyan 
                }
            }

            "magic_cert" 
            { 
                if(!($($output_dir)))
                {
                    Write-Error "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Working magic on .cof files." -ForegroundColor Cyan
		        Parse-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		        if($?) 
		        { 
			        Write-Host "[^] Magic on .cof files finished. Did you expect anything less?" -ForegroundColor Cyan 
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
                    Write-Error "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Cleaning up UICS folder." -ForegroundColor Cyan
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
                    Write-Error "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included."
                    exit 1
                }

		        Write-Host "[^] Getting permissions." -ForegroundColor Cyan
		        Get-Permissions -uics_directory_output $($uics_directory_output)
		        if($?) 
		        { 
			        Write-Host "[^] Getting permissions of UICS folder finished." -ForegroundColor Cyan 
		        } 	
            }

            "all" 
            {                  	            
				Write-Host "[^] Creating required directories." -ForegroundColor Cyan
		        Create-RequiredDirectories -directories $($directories) -log_file $($log_file)
		        if($?) 
		        {
			        Write-Host "[^] Creating directories finished." -ForegroundColor Cyan
		        } 

		        Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files." -ForegroundColor Cyan	
		        Split-OrdersMain -current_directory_working $($current_directory_working) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)
		        if($?)
		        {
			        Write-Host "[^] Splitting '*m.prt' order file(s) finished." -ForegroundColor Cyan
		        }

		        Write-Host "[^] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor Cyan
		        Split-OrdersCertificate -current_directory_working $($current_directory_working) -cof_directory_working $($cof_directory_working) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)
		        if($?) 
		        {
			        Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished." -ForegroundColor Cyan
		        } 	     
                       
		        Write-Host "[^] Editing orders '*m.prt' files." -ForegroundColor Cyan
		        Edit-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_original_splits_working $($mof_directory_original_splits_working)
		        if($?) 
		        { 
			        Write-Host "[^] Editing orders '*m.prt' files finished." -ForegroundColor Cyan 
		        } 

		        Write-Host "[^] Editing orders '*c.prt' files." -ForegroundColor Cyan
		        Edit-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert) -cof_directory_original_splits_working $($cof_directory_original_splits_working)
		        if($?)
		        { 
			        Write-Host "[^] Editing orders '*c.prt' files finished." -ForegroundColor Cyan
		        } 

		        Write-Host "[^] Combining .mof orders files." -ForegroundColor Cyan
		        Combine-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -run_date $($run_date)
		        if($?) 
		        { 
			        Write-Host "[^] Combining .mof orders files finished." -ForegroundColor Cyan 
		        } 	

		        Write-Host "[^] Combining .cof orders files." -ForegroundColor Cyan
		        Combine-OrdersCertificate -cof_directory_working $($cof_directory_working) -run_date $($run_date)
		        if($?) 
		        { 
			        Write-Host "[^] Combining .cof orders files finished." -ForegroundColor Cyan 
		        } 	

                Write-Host "[^ Working magic on .mof files now." -ForegroundColor Cyan
                Parse-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
		        if($?) 
		        { 
			        Write-Host "[^] Magic on .mof files finished. Did you expect anything less?" -ForegroundColor Cyan 
		        }	

		        Write-Host "[^] Working magic on .cof files." -ForegroundColor Cyan
		        Parse-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		        if($?) 
		        { 
			        Write-Host "[^] Magic on .cof files finished. Did you expect anything less?" -ForegroundColor Cyan 
		        } 
            }

            "Verbose" 
            { 
                continue
            }

            default 
            { 
                Write-Log -level [ERROR] -log_file $log_file -message "[!] Unrecognized parameter: $($p). Try again with proper parameter."
	            Write-Error "[!] Unrecognized parameter: $($p). Try again with proper parameter."
            }
        }
    }
}
else
{
    Write-Log -level [ERROR] -log_file $log_file -message "[!] No parameters passed. Run 'Get-Help $($script_name) -Full' for detailed help information"
    Write-Error "[!] No parameters passed. Run 'Get-Help $($script_name) -Full' for detailed help information"
}