<#
.Synopsis
   Script to help automate order management.
.DESCRIPTION
   Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
.PARAMETER help
   Help page. Alias: 'h'. This parameter tells the script you want to learn more about it. It will display this page after running the command 'Get-Help .\ORDPRO.ps1 -Full' for you.
.PARAMETER version
   Version information. Alias: 'v'. This parameter tells the script you want to check its version number.
.PARAMETER output_dir
   Version information. Alias: 'o'. This parameter tells the script where you want the output to go. Give it the full UNC path to the folder you want output to land and it will do the rest.
.PARAMETER dir_create
   Directory creation. Alias: 'd'. This parameter tells the script to create the required directories for the script to run. Directories created are ".\MASTER-HISTORY\{EDITED}{NONEDITED}" ".\UICS" ".\TMP\{___LOGS}{__MOF}{__COF}".
.PARAMETER backups
   Backup original order files. Alias: 'b'. This parameter tells the script to create backups of all files in current directory. Backups all files with ".prt" extension in current directory to ".\MASTER-HISTORY\NONEDITED" directory.
.PARAMETER split_main
   Split main order files with "*m.prt" name. Alias: 'sm'. This parameter tells the script to split the main "*m.prt" file into individual orders. Individual order files are split to ".\TMP\__MOF\{run_date}_{n}.mof" files for editing.
.PARAMETER split_cert
   Split certificate order files with "*c.prt" name. Alias: 'sc'. This parameter tells the script to split the main "*c.prt" file into individual certificate orders. Individual certificate orders files are split to ".\TMP\__COF\{run_date}_{n}.cof" files for editing.
.PARAMETER edit_main
   Edit main order files. Alias: 'em'. This parameter tells the script to edit the individual ".\TMP\__MOF\{run_date}_{n}.mof" files to be ready to be combined.
.PARAMETER edit_cert
   Edit certificate order files. Alias: 'ec'. This parameter tells the script to edit the individual ".\TMP\__COF\{run_date}_{n}.cof" files to be ready to be combined.
.PARAMETER combine_main
   Combine main order files. Alias: 'cm'. This parameter tells the script to combine the edited main order files into a single document to be used at a later date.
.PARAMETER combine_cert
   Combine certificate order files. Alias: 'cc'. This parameter tells the script to combine the edited certificate order files into a single document to be used at a later date.
.PARAMETER magic_main
   Magic work on main orders. TAlias: 'mm'. his parameter tells the script to parse the split main order files, create directory structure based on parsed data, and put orders in appropriate ".\UICS\UIC\SSN" folders.
.PARAMETER magic_cert
   Magic work on certificate orders. Alias: 'mc'. This parameter tells the script to parse the split certificate order files, create directory structure based on parsed data, and put orders in appropriate ".\UICS\UIC\SSN" folders. If you are not using the 'all' parameter, make sure to run 'magic_main' or 'mm' before this parameter.
.PARAMETER clean_main
   Cleanup main order files. Alias: 'xm'. This parameter tells the script to cleanup the ".\TMP\__MOF" directory of all "\TMP\__MOF\{run_date}_{n}.mof" files.
.PARAMETER clean_cert
   Cleanup certificate order files. Alias: 'xc'. This parameter tells the script to cleanup the ".\TMP" directory of all "\TMP\__COF\{run_date}_{n}.cof" files.
.PARAMETER clean_uics
   Cleanup UICS folder. Alias: 'xu'. This parameter tells the script to cleanup the ".\UICS" directory of all UIC folders. This parameter is NOT used when 'all' is used. This is typically only for development and administrative use.
.PARAMETER permissions
   Get permissions of ".\UICS" folder contents. Alias: 'p'. This parameter tells the script to recursively get the permissions of each file and folder in the UICS directory. Output includes a .csv file, .html report, and a .txt file.
.PARAMETER all
   All parameters. Alias: 'a'. This parameter tells the script to run all required parameters needed to be successful. Most common parameter to those new to using this script.
.INPUTS
   Script parses all "*m.prt" and "*c.prt" files in current directory.
.OUTPUTS
   Script creates directory structure and invididual order files within each ".\UIC\SSN" folder.
.NOTES
   NAME: ORDPRO.ps1 (Order Processing Automation)

   AUTHOR: Ashton J. Hanisch

   TROUBLESHOOTING: All script output will be in ".\TMP\___LOGS" folder. Should you have any problems script use, email ajhanisch@gmail.com with a description of your issue and the log file that is associated with your problem.

   SUPPORT: For any issues, comments, concerns, ideas, contributions, etc. to any part of this script or its functionality, reach out to me at ajhanisch@gmail.com. I am open to any thoughts you may have to make this work better for you or things you think are broken or need to be different. I will ensure to give credit where credit is due for any contributions or improvement ideas that are shared.

   UPDATES: To check out any updates or revisions made to this script check out the updated CHANGELOG file with this script.
   
   WISHLIST: 
            Warren Hofmann  - * - [x] Handle *c.prt files
                            - * - [] Assign permissions to UIC groups as needed

            Ryan Mattfield  - (10/5/2017)  [] Email group(s)/UIC(s) with required access UNC links to new orders published in their persepective folder
                            - (10/5/2017)  [] Shortcuts to SSN's rather than duplicating data in G1 master folder
                            - (10/6/2017)  [] Web page serving root directory structure to access orders

            Joshua Schaefer - (10/4/2017)  [] Reformat all orders processed and combine into single file to upload to iperms more easily

            Ashton Hanisch  - (10/6/2017)  [x] Progress bar with estimated time. Similar to YASP progress bar notification information.
                            - (10/6/2017)  [] Output summary results of orders parsed.
                            - (10/10/2017) [] Handle all formats not currently handled.
                            - (10/11/2017) [] Have orders follow soldier as they move UIC's
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
$version_info = "1.1"
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$script_name = $($MyInvocation.MyCommand.Name)
$exclude_directories = '$($mof_directory_original_splits_working)|$($cof_directory_original_splits_working)'
$files_orders_original = (Get-ChildItem -Path $current_directory_working -Filter "*.prt" -File)
$files_orders_m_prt = (Get-ChildItem -Path $current_directory_working -Filter "*m.prt" -File)
$files_orders_c_prt = (Get-ChildItem -Path $current_directory_working -Filter "*c.prt" -File)
$sw = New-Object System.Diagnostics.Stopwatch
$sw.start()

if(Test-Path variable:global:psISE)
{
    Write-Host "[#] Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE." -ForegroundColor Yellow
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
        [Parameter(mandatory = $true)] $directories
    )

    $total_to_create_directories = $directories.Length

    if($total_to_create_directories -gt 0)
    {
        Write-Verbose "Total to create: $($total_to_create_directories)."
        
        $total_directories_created = 0
        $total_directories_not_created = 0

        foreach($directory in $directories)
        {
            Process-DevCommands -sw $($sw)

            if(!(Test-Path $($directory)))
            {
                Write-Verbose "[#] $($directory) not created. Creating now."
                New-Item -ItemType Directory -Path $($directory) > $null

                if($?)
                {
                    $total_directories_created ++
                    Write-Verbose "[*] $($directory) created successfully."
                }
                else
                {
                    $total_directories_not_created ++
                    Write-Verbose "[!] $($directory) creation failed. Check the error logs at $($error_path)."
                }
            }
            else
            {
                $total_directories_created ++
                Write-Verbose "[*] $($directory) already created."
            }

            $activity = "Creating required directories."
            $status = "Created $($directory)."
            $percent_complete = (($total_directories_created)/$($total_to_create_directories )).ToString("P")
            $estimated_time = (($($total_to_create_directories) - ($total_directories_created)) * 0.2 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

            Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Created: ( $($total_directories_created) / $($total_to_create_directories) ). Not created: ( $($total_directories_not_created) / $($total_to_create_directories) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
        }
    }
    else
    {
        Write-Verbose "[!] Total to create: $($total_to_create_directories). No directories to create. Make sure the directories array is populated with your desired directories to create."
        throw "[!] Total to create: $($total_to_create_directories). No directories to create. Make sure the directories array is populated with your desired directories to create."
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

    $orders_file_m_prt = Get-ChildItem -Path $($current_directory_working) -Filter "*m.prt" -File
    $orders_file_c_prt = Get-ChildItem -Path $($current_directory_working) -Filter "*c.prt" -File
    $orders_file_r_prt = Get-ChildItem -Path $($current_directory_working) -Filter "*r.prt" -File
    $orders_file_r_reg = Get-ChildItem -Path $($current_directory_working) -Filter "*r.reg*" -File
    
    $year_suffix = (Get-Date -Format yyyy).Substring(2)
    $year_orders_archive_directory = "$($archive_directory_working)\$($year_suffix)_orders"
    $year_orders_registry_directory = "$($ordregisters_output)\$($year_suffix)_orders"

    $total_to_move_files = @(Get-ChildItem -Path $($current_directory_working) | Where { ! $_.PSIsContainer } | Where { $_.Name -eq "*m.prt" -or $_.Name -eq "*c.prt" -or $_.Name -eq "*r.prt" -or $_.Name -eq "*r.reg*" -or $_.Extension -ne '.ps1' }).Count

    if($total_to_move_files -gt 0)
    {
        $total_files_moved = @()
        $total_files_not_moved = @()

        $files_moved_to_archive_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_moved_to_archive.csv"
        $files_not_moved_to_archive_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_not_moved_to_archive.csv"

        # Ensure that required directories are in place before trying to move.
        if(!(Test-Path $($year_orders_archive_directory)))
        {
            Write-Verbose "[#] $($year_orders_archive_directory) not created yet. Creating now."
            New-Item -ItemType Directory -Path $($year_orders_archive_directory) -Force > $null

            if($?)
            {
                Write-Verbose "[*] $($year_orders_archive_directory) created successfully."
            }
            else
            {
                Write-Verbose "[!] $($year_orders_archive_directory) failed to create."
                throw "[!] $($year_orders_archive_directory) failed to create."
            }
        }
        else
        {
            Write-Verbose "[*] $($year_orders_archive_directory) already created."
        }

        if(!(Test-Path $($year_orders_registry_directory)))
        {
            Write-Verbose "[#] $($year_orders_registry_directory) not created yet. Creating now."
            New-Item -ItemType Directory -Path $($year_orders_registry_directory) -Force > $null

            if($?)
            {
                Write-Verbose "[*] $($year_orders_registry_directory) created successfully."
            }
            else
            {
                Write-Verbose "[!] $($year_orders_registry_directory) failed to create."
                throw "[!] $($year_orders_registry_directory) failed to create."
            }
        }
        else
        {
            Write-Verbose "[*] $($year_orders_registry_directory) already created."
        }

        # Move '*m.prt' files to archive folder.
        $orders_file_m_prt_count = $($orders_file_m_prt).Count

        if($($orders_file_m_prt_count) -gt 0)
        {
            foreach($file in $orders_file_m_prt)
            {
                Process-DevCommands -sw $($sw)

                Write-Verbose "[#] Moving $($file.Name) to $($year_orders_archive_directory) now."
                Move-Item -Path $($file) -Destination "$($year_orders_archive_directory)\$($file.Name)" -Force

                if($?)
                {
                    Write-Verbose "[*] $($file) moved to $($year_orders_archive_directory) successfully."
                
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*m.prt'
                        STATUS = 'SUCCESS'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_moved += $file_moved
                }
                else
                {
                    Write-Verbose "[!] $($file) move to $($year_orders_archive_directory) failed."

                    $hash = @{
                        FILE = $($file)
                        TYPE = '*m.prt'
                        STATUS = 'FAILED'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_not_moved += $file_moved
                }

                $activity = "Moving original '*m.prt' files to archive folder."
                $status = "Moved $($file)."
                $percent_complete = ($($total_files_moved.Length)/$($total_to_move_files)).ToString("P")
                $estimated_time = (($($total_to_move_files) - $($total_files_moved.Length)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Moved: ( $($total_files_moved.Length) / $($total_to_move_files) ). Not moved: ( $($total_files_not_moved.Length) / $($total_to_move_files) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }
        }
        else
        {
            Write-Verbose "[!] $($orders_file_m_prt_count) '*m.prt' files to move. No '*m.prt' files to move. Make sure to have the required '*m.prt' files in the current directory and try again."
        }

        # Move '*c.prt' files to archive folder.
        $orders_file_c_prt_count = $($orders_file_c_prt).Count

        if($($orders_file_c_prt_count) -gt 0)
        {
            foreach($file in $orders_file_c_prt)
            {
                Process-DevCommands -sw $($sw)

                Write-Verbose "[#] Moving $($file.Name) to $($year_orders_archive_directory) now."
                Move-Item -Path $($file) -Destination "$($year_orders_archive_directory)\$($file.Name)" -Force

                if($?)
                {
                    Write-Verbose "[*] $($file) moved to $($year_orders_archive_directory) successfully."
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*c.prt'
                        STATUS = 'SUCCESS'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_moved += $file_moved
                }
                else
                {
                    Write-Verbose "[!] $($file) move to $($year_orders_archive_directory) failed."
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*c.prt'
                        STATUS = 'FAILED'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_not_moved += $file_moved
                }

                $activity = "Moving original '*c.prt' files to archive folder."
                $status = "Moved $($file)."
                $percent_complete = ($($total_files_moved.Length)/$($total_to_move_files)).ToString("P")
                $estimated_time = (($($total_to_move_files) - $($total_files_moved.Length)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Moved: ( $($total_files_moved.Length) / $($total_to_move_files) ). Not moved: ( $($total_files_not_moved.Length) / $($total_to_move_files) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }
        }
        else
        {
            Write-Verbose "[!] $($orders_file_c_prt_count) '*c.prt' files to move. No '*c.prt' files to move. Make sure to have the required '*c.prt' files in the current directory and try again."
        }

        # Move '*r.prt' files to archive folder.
        $orders_file_r_prt_count = $($orders_file_r_prt).Count

        if($($orders_file_r_prt_count) -gt 0)
        {
            foreach($file in $orders_file_r_prt)
            {
                Process-DevCommands -sw $($sw)

                Write-Verbose "[#] Moving $($file.Name) to $($year_orders_registry_directory) now."
                Move-Item -Path $($file) -Destination "$($year_orders_registry_directory)\$($file.Name)" -Force

                if($?)
                {
                    Write-Verbose "[*] $($file) moved to $($year_orders_registry_directory) successfully."
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*p.prt'
                        STATUS = 'SUCCESS'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_moved += $file_moved
                }
                else
                {
                    Write-Verbose "[!] $($file) move to $($year_orders_registry_directory) failed."
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*r.prt'
                        STATUS = 'FAILED'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_not_moved += $file_moved
                }
            
                $activity = "Moving original '*r.prt' files to archive folder."
                $status = "Moved $($file)."
                $percent_complete = ($($total_files_moved.Length)/$($total_to_move_files)).ToString("P")
                $estimated_time = (($($total_to_move_files) - $($total_files_moved.Length)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Moved: ( $($total_files_moved.Length) / $($total_to_move_files) ). Not moved: ( $($total_files__not_moved.Length) / $($total_to_move_files) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }
        }
        else
        {
            Write-Verbose "[!] $($orders_file_r_prt_count) '*r.prt' files to move. No '*r.prt' files to move. Make sure to have the required '*r.prt' files in the current directory and try again."
        }

        # Move '*r.reg*' files to archive folder.
        $orders_file_r_reg_count = $($orders_file_r_reg).Count

        if($($orders_file_r_reg_count) -gt 0)
        {
            foreach($file in $orders_file_r_reg)
            {
                Process-DevCommands -sw $($sw)

                Write-Verbose "[#] Moving $($file.Name) to $($year_orders_registry_directory) now."
                Move-Item -Path $($file) -Destination "$($year_orders_registry_directory)\$($file.Name)" -Force

                if($?)
                {
                    Write-Verbose "[*] $($file) moved to $($year_orders_registry_directory) successfully."
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*r.reg*'
                        STATUS = 'SUCCESS'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_moved += $file_moved
                }
                else
                {
                    Write-Verbose "[!] $($file) move to $($year_orders_registry_directory) failed."
                    $hash = @{
                        FILE = $($file)
                        TYPE = '*r.reg*'
                        STATUS = 'FAILED'
                    }

	                $file_moved = New-Object -TypeName PSObject -Property $hash
                    $total_files_moved += $file_moved
                }
            
                $activity = "Moving original '*r.reg*' files to archive folder."
                $status = "Moved $($file)."
                $percent_complete = ($($total_files_moved.Length)/$($total_to_move_files )).ToString("P")
                $estimated_time = (($($total_to_move_files) - $($total_files_moved.Length)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Moved: ( $($total_files_moved.Length) / $($total_to_move_files) ). Not moved: ( $($total_files_not_moved.Length) / $($total_to_move_files) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }

            if($total_files_moved.Count -gt 0)
            {
                Write-Verbose "[*] Writing $($files_moved_to_archive_csv) file now."
                $total_files_moved | Select FILE, TYPE, STATUS | Sort -Property STATUS | Export-Csv "$($files_moved_to_archive_csv)" -NoTypeInformation -Force   
            }

            if($total_files_not_moved.Count -gt 0)
            {
                Write-Verbose "[*] Writing $($files_not_moved_to_archive_csv) file now."
                $total_files_not_moved | Select FILE, TYPE, STATUS | Sort -Property STATUS | Export-Csv "$($files_not_moved_to_archive_csv)" -NoTypeInformation -Force
            }
        }
        else
        {
            Write-Verbose "[!] $($orders_file_r_reg_count) '*r.reg*' files to move. No '*r.reg*' files to move. Make sure to have the required '*r.reg*' files in the current directory and try again."
        }
    }
    else
    {
        Write-Verbose "[!] Total to move: $($total_to_move_files). No files to move. Make sure to have the required '*m.prt', '*c.prt', '*r.prt', '*r.reg' files in the current directory and try again."
        throw "[!] Total to move: $($total_to_move_files). No files to move. Make sure to have the required '*m.prt', '*c.prt', '*r.prt', '*r.reg' files in the current directory and try again."
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

        if(!(Test-Path $($out_directory)))
        {
            Write-Verbose "[#] $($out_directory) not created. Creating now."
            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Verbose "[*] $($out_directory) created successfully."
            }
            else
            {
                Write-Verbose "[!] $($out_directory) creation failed."
                throw "[!] $($out_directory) creation failed."
            }
        }

        foreach($file in $files_orders_m_prt)
        {
            $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
            $orders = [regex]::Match($content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "$($regex_beginning_m_split_orders_main)"

            Write-Verbose "[#] Parsing $($file) now."

            foreach($order in $orders)
            {
                Process-DevCommands -sw $($sw)

                if($order)
                {
                    $count_orders ++

                    $out_file = "$($run_date)_$($count_orders).mof"

                    Write-Verbose "[#] Processing $($out_file) now."

                    New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

                    if($?)
                    {
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
                        Write-Verbose "[!] $($out_file) file creation failed."

                        $hash = @{
                            'ORIGINAL_FILE' = $($file)
                            'OUT_FILE' = $($out_file)
                            'ORDER_COUNT' = $($count_orders)
                        }

	                    $order_created = New-Object -TypeName PSObject -Property $hash
                        $orders_not_created += $order_created
                    }
                }

                $activity = "Splitting '*m.prt' file into individual order files."
                $status = "Parsing $($file)."
                $percent_complete = ($($count_files)/$($total_to_parse_orders_main_files )).ToString("P")
                $estimated_time = (($($total_to_parse_orders_main_files) - $($count_files)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Files parsed: ( $($count_files) / $($total_to_parse_orders_main_files) ). Orders split: ($($count_orders)). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }

            $count_files ++

            $activity = "Splitting '*m.prt' file into individual order files."
            $status = "Parsing $($file)."
            $percent_complete = ($($count_files)/$($total_to_parse_orders_main_files )).ToString("P")
            $estimated_time = (($($total_to_parse_orders_main_files) - $($count_files)) * 0.2 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

            Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Files parsed: ( $($count_files) / $($total_to_parse_orders_main_files) ). Orders split: ($($count_orders)). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
        }   

        if($orders_created.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_created_csv) file now."
            $orders_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT | Sort -Property ORDER_COUNT | Export-Csv "$($orders_created_csv)" -NoTypeInformation -Force
        }

        if($orders_not_created.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_not_created_csv) file now."
            $orders_not_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT| Sort -Property ORDER_COUNT | Export-Csv "$($orders_not_created_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Verbose "[!] $($current_directory_working) '*m.prt' files to split. No '*m.prt' files to split. Make sure to have the required '*m.prt' files in the current directory and try again."
        throw "[!] $($current_directory_working) '*m.prt' files to split. No '*m.prt' files to split. Make sure to have the required '*m.prt' files in the current directory and try again."
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

        if(!(Test-Path $($out_directory)))
        {
            Write-Verbose "[#] $($out_directory) not created. Creating now."
            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Verbose "[*] $($out_directory) created successfully."
            }
            else
            {
                Write-Verbose "[!] $($out_directory) creation failed."
                throw "[!] $($out_directory) creation failed."
            }
        }

        foreach($file in $files_orders_c_prt)
        {
            $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
            $orders = [regex]::Match($content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "$($regex_end_cert)"

            Write-Verbose "[#] Parsing $($file) now."

            foreach($order in $orders)
            {
                Process-DevCommands -sw $($sw)

                if($order)
                {
                    $count_orders ++

                    $out_file = "$($run_date)_$($count_orders).cof"

                    Write-Verbose "[#] Processing $($out_file) now."

                    New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

                    if($?)
                    {
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
                        Write-Verbose "[!] $($out_file) file creation failed."

                        $hash = @{
                            'ORIGINAL_FILE' = $($file)
                            'OUT_FILE' = $($out_file)
                            'ORDER_COUNT' = $($count_orders)
                        }

	                    $order_created = New-Object -TypeName PSObject -Property $hash
                        $orders_not_created += $order_created
                    }
                }

                $activity = "Splitting '*c.prt' file into individual order files."
                $status = "Parsing $($file)."
                $percent_complete = ($($count_files)/$($total_to_parse_orders_cert_files )).ToString("P")
                $estimated_time = (($($total_to_parse_orders_cert_files) - $($count_files)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Files parsed: ( $($count_files) / $($total_to_parse_orders_cert_files) ). Orders split: ($($count_orders)). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }

            $count_files ++

            $activity = "Splitting '*c.prt' file into individual order files."
            $status = "Parsing $($file)."
            $percent_complete = ($($count_files)/$($total_to_parse_orders_cert_files )).ToString("P")
            $estimated_time = (($($total_to_parse_orders_cert_files) - $($count_files)) * 0.2 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

            Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Files parsed: ( $($count_files) / $($total_to_parse_orders_cert_files) ). Orders split: ($($count_orders)). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
        }   

        if($orders_created.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_created_csv) file now."
            $orders_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT | Sort -Property ORDER_COUNT | Export-Csv "$($orders_created_csv)" -NoTypeInformation -Force
        }

        if($orders_not_created.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_not_created_csv) file now."
            $orders_not_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT| Sort -Property ORDER_COUNT | Export-Csv "$($orders_not_created_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Verbose "[!] $($current_directory_working) '*c.prt' files to split. No '*c.prt' files to split. Make sure to have the required '*c.prt' files in the current directory and try again."
        throw "[!] $($current_directory_working) '*c.prt' files to split. No '*c.prt' files to split. Make sure to have the required '*c.prt' files in the current directory and try again."
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
	  
    $total_to_edit_orders_main = (Get-ChildItem -Path "$($mof_directory_working)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length

    if($($total_to_edit_orders_main) -gt '0')
    {
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
                Write-Verbose "[#] Editing $($file.Name) in round 1 now."
                
                $out_file_name = "$($file.BaseName)_edited.mof"

                $file_content = (Get-Content "$($file)" | Select -Skip 1 )
                $file_content = @('                               STATE OF SOUTH DAKOTA') + $file_content

                # Remove known bad strings first.
                foreach($pattern in $known_bad_strings)
                {
                    Write-Verbose "[#] Removing known bad string $($pattern) from $($file)."
                    $file_content = ( $file_content | Select-String -Pattern $($pattern) -NotMatch )

                    if($?)
                    {
                        Write-Verbose "[*] Removed known bad string $($pattern) from $($file) succesfully."
                    }
                    else
                    {
                        Write-Verbose "[!] Removing known bad string $($pattern) from $($file) failed."
                        throw "[!] Removing known bad string $($pattern) from $($file) failed."
                    }
                }

                # Write to edited file.
                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $file_content

                if($?)
                {
                    Write-Verbose "[*] $($file.Name) edited in round 1 successfully."                    

                    if($($file.Name) -cnotcontains "*_edited.mof")
                    {
                        Write-Verbose "[#] Moving $($file.Name) to $($mof_directory_original_splits_working)"
                        Move-Item "$($file)" -Destination "$($mof_directory_original_splits_working)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Verbose "[*] $($file) moved to $($mof_directory_original_splits_working) successfully."
                        }
                        else
                        {
                            Write-Verbose "[!] $($file) move to $($mof_directory_original_splits_working) failed."
                            throw "[!] $($file) move to $($mof_directory_original_splits_working) failed."
                        }
                    }
                }
                else
                {
                    Write-Verbose "[!] $($file.Name) editing in round 1 failed."

                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Verbose "[!] $($file.Name) editing in round 1 failed."

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
                Write-Verbose "[#] Editing $($out_file_name) in round 2 now."
                $pattern_1 = '(?smi)Marital status / Number of dependents: \w{1,}(.*?)Type of incentive pay: \w{1,}'
                $string_1 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_1 = [regex]::Matches($string_1,$pattern_1).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Verbose "[!] $($out_file_name) is not the proper format to be edited in round 2. Not editing this file at this time as it is not needed."
                }
                $good_output_1 = $bad_output_1.Replace("`n`r`n`r`n","")
                $string_1 = $string_1 -replace $bad_output_1,$good_output_1

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_1
                if($?)
                {
                    Write-Verbose "[*] $($out_file_name) edited in round 2 successfully."
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Verbose "[!] $($out_file_name) edit in round 2 failed."

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
                Write-Verbose "[#] Editing $($out_file_name) in round 3 now."
                $pattern_2 = '(?smi)APC DJMS-RC: \w{1,}(.*?)APC STANFINS Pay:  \w{1,}'
                $string_2 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_2 = [regex]::Matches($string_2,$pattern_2).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Verbose "[!] $($out_file_name) is not the proper format to be edited in round 3. Not editing this file at this time as it is not needed."
                }
                $good_output_2 = $bad_output_2.Replace("`n`r`n","")
                $string_2 = $string_2 -replace $bad_output_2,$good_output_2

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_2
                if($?)
                {
                    Write-Verbose "[*] $($out_file_name) edited in round 3 successfully."
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Verbose "[!] $($out_file_name) edit in round 3 failed."

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
                Write-Verbose "[#] Editing $($out_file_name) in round 4 now."
                $pattern_3 = '(?smi)Auth:\s\w{1,}(.*?)HOR:\s\w{1,}'
                $string_3 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_3 = [regex]::Matches($string_3,$pattern_3).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Verbose "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."

                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Verbose "[!] $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."

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
                Write-Verbose "[#] $($file) is a directory. Skipping."
            }

            $activity = "Editing '*m.prt' files."
            $status = "Editing $($file)."
            $percent_complete = ($($orders_edited.Length)/$($total_to_edit_orders_main)).ToString("P")
            $estimated_time = (($($total_to_edit_orders_main) - $($orders_edited.Length)) * 0.2 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

            Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Orders edited: ( $($orders_edited.Length) / $($total_to_edit_orders_main) ). Orders not edited: ( $($orders_not_edited.Length) / $($total_to_edit_orders_main) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
        }

        if($orders_edited.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_edited_csv) file now."
            $orders_edited | Select FILE, ROUND, STATUS, REASON | Sort -Property FILE | Export-Csv "$($orders_edited_csv)" -NoTypeInformation -Force
        }

        if($orders_not_edited.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_not_edited_csv) file now."
            $orders_not_edited | Select FILE, ROUND, STATUS, REASON | Sort -Property FILE | Export-Csv "$($orders_not_edited_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Verbose "[!] Total to edit: $($total_to_edit_orders_main). No .mof files in $($mof_directory_working). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
        throw "[!] No .mof files in $($mof_directory_working). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
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

    $total_to_edit_orders_cert = (Get-ChildItem -Path "$($cof_directory_working)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length

    if($($total_to_edit_orders_cert) -gt '0')
    {
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
                Write-Verbose "[#] Editing $($file.Name) now."
                               
                $out_file_name = "$($file.BaseName)_edited.cof"

                $file_content = Get-Content "$($file)"

                # Remove known bad strings first.
                foreach($pattern in $known_bad_strings)
                {
                    Write-Verbose "[#] Removing known bad string $($pattern) from $($file)."
                    $file_content = ( $file_content | Select-String -Pattern $($pattern) -NotMatch )

                    if($?)
                    {
                        Write-Verbose "[*] Removed known bad string $($pattern) from $($file) succesfully."
                    }
                    else
                    {
                        Write-Verbose "[!] Removing known bad string $($pattern) from $($file) failed."
                        throw "[!] Removing known bad string $($pattern) from $($file) failed."
                    }
                }

                # Write to edited file.
                Set-Content -Path "$($cof_directory_working)\$($out_file_name)" $file_content
                Add-Content -Path "$($cof_directory_working)\$($out_file_name)" -Value $($regex_end_cert)

                if($?)
                {
                    Write-Verbose "[*] $($file.Name) edited successfully."
                    
                    $hash = @{
                        'FILE' = $($file)
                        'STATUS' = 'SUCCESS'
                    }

                    $order_edited = New-Object -TypeName PSObject -Property $hash
                    $orders_edited += $order_edited                 

                    if($($file.Name) -cnotcontains "*_edited.cof")
                    {
                        Write-Verbose "[#] Moving $($file.Name) to $($cof_directory_original_splits_working)"
                        Move-Item "$($file)" -Destination "$($cof_directory_original_splits_working)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Verbose "[*] $($file) moved to $($cof_directory_original_splits_working) successfully."
                        }
                        else
                        {
                            Write-Verbose "[!] $($file) move to $($cof_directory_original_splits_working) failed."
                            throw "[!] $($file) move to $($cof_directory_original_splits_working) failed."
                        }
                    }
                }
                else
                {
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
                Write-Verbose "[#] $($file) is a directory. Skipping."
            }

            $activity = "Editing '*c.prt' files."
            $status = "Editing $($file)."
            $percent_complete = ($($orders_edited.Length)/$($total_to_edit_orders_cert)).ToString("P")
            $estimated_time = (($($total_to_edit_orders_cert) - $($orders_edited.Length)) * 0.2 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

            Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Orders edited: ( $($orders_edited.Length) / $($total_to_edit_orders_cert) ). Orders not edited: ( $($orders_not_edited.Length) / $($total_to_edit_orders_cert) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
        }

        if($orders_edited.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_edited_csv) file now."
            $orders_edited | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_edited_csv)" -NoTypeInformation -Force
        }

        if($orders_not_edited.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_not_edited_csv) file now."
            $orders_not_edited | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_not_edited_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Verbose "[!] Total to edit: $($total_to_edit_orders_cert). No .cof files in $($cof_directory_working). Make sure to split '*c.prt' files first. Use '$($script_name) -sc' first, then try again."
        throw "[!] Total to edit: $($total_to_edit_orders_cert). No .cof files in $($cof_directory_working). Make sure to split '*c.prt' files first. Use '$($script_name) -sc' first, then try again."
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
	  
    $total_to_combine_orders_main = (Get-ChildItem -Path "$($mof_directory_working)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }).Length

    $orders_combined_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_combined_cert.csv"

    if($($total_to_combine_orders_main) -gt '0')
    {
        $orders_combined = @()

        $out_file = "$($log_directory_working)\$($run_date)\$($run_date)_combined_orders_main.txt"

        Write-Verbose "[#] Total to combine: $($total_to_combine_orders_main)."
        Write-Verbose "[#] Combining .mof files now."

        Get-ChildItem -Path $($mof_directory_working) -Recurse | Where { ! $_.PSIsContainer } | Where { $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" } | 
            ForEach-Object {
                Process-DevCommands -sw $($sw)

                Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append
                if($?)
                {
                    $hash = @{
                        'FILE' = $($_.FullName)
                        'STATUS' = 'SUCCESS'
                    }

                    $order_combined = New-Object -TypeName PSObject -Property $hash
                    $orders_combined += $order_combined

                    $activity = "Combining '*m.prt' files."
                    $status = "Combining $($_.FullName)."
                    $percent_complete = ($($orders_combined.Length)/$($total_to_combine_orders_main)).ToString("P")
                    $estimated_time = (($($total_to_combine_orders_main) - $($orders_combined.Length)) * 0.2 / 60)
                    $formatted_estimated_time = [math]::Round($estimated_time,2)
                    $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                    Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Orders combined: ( $($orders_combined.Length) / $($total_to_combine_orders_main) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
                 
                }
                else
                {
                    Write-Verbose "[!] Combining .mof files failed."
                    throw "[!] Combining .mof files failed."
                }
            }

        if($orders_combined.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_combined_csv) file now."
            $orders_combined | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_combined_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Verbose "[!] Total to combine: $($total_to_combine_orders_main). No .mof files in $($mof_directory_working) to combine. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
        throw "[!] No .mof files in $($mof_directory_working) to combine. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
    }
}

function Combine-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $run_date
    )
	  
    $total_to_combine_orders_cert = (Get-ChildItem -Path "$($cof_directory_working)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' -and $_.Name -like "*_edited.cof" }).Length

    $orders_combined_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_combined_cert.csv"

    if($($total_to_combine_orders_cert) -gt '0')
    {
        $orders_combined = @()

        $out_file = "$($log_directory_working)\$($run_date)\$($run_date)_combined_orders_cert.txt"

        Write-Verbose "[#] Total to combine: $($total_to_combine_orders_cert)."
        Write-Verbose "[#] Combining .cof files now."

        Get-ChildItem -Path $($cof_directory_working) -Recurse | Where { ! $_.PSIsContainer } | Where { $_.Extension -eq '.cof' -and $_.Name -like "*_edited.cof" } | 
            ForEach-Object {
                Process-DevCommands -sw $($sw)

                Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append
                if($?)
                {
                    $hash = @{
                        'FILE' = $($_.FullName)
                        'STATUS' = 'SUCCESS'
                    }

                    $order_combined = New-Object -TypeName PSObject -Property $hash
                    $orders_combined += $order_combined

                    $activity = "Combining '*c.prt' files."
                    $status = "Combining $($_.FullName)."
                    $percent_complete = ($($orders_combined.Length)/$($total_to_combine_orders_cert)).ToString("P")
                    $estimated_time = (($($total_to_combine_orders_cert) - $($orders_combined.Length)) * 0.2 / 60)
                    $formatted_estimated_time = [math]::Round($estimated_time,2)
                    $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                    Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Orders combined: ( $($orders_combined.Length) / $($total_to_combine_orders_cert) ). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
                 
                }
                else
                {
                    Write-Verbose "[!] Combining .cof files failed."
                    throw "[!] Combining .cof files failed."
                }
            }

        if($orders_combined.Count -gt 0)
        {
            Write-Verbose "[*] Writing $($orders_combined_csv) file now."
            $orders_combined | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_combined_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Verbose "[!] Total to combine: $($total_to_combine_orders_cert). No .cof files in $($cof_directory_working) to combine. Make sure to split and edit '*c.prt' files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
        throw "[!] No .cof files in $($cof_directory_working) to combine. Make sure to split and edit '*c.prt' files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
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
	  
    $total_to_create_orders_main = (Get-ChildItem -Path $($mof_directory_working) | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }).Length

    if($($total_to_create_orders_main) -gt '0')
    {
        $orders_created_orders_main = @()
        $orders_not_created_orders_main = @()
        
        $orders_created_orders_main_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_orders_main.csv"
        $orders_not_created_orders_main_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_orders_main.csv"

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

                    Write-Verbose "[+] $($error_info)"

                    $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_orders_main += $order_info

                    continue
                }

                if($($following_request_exists)) # Any format containing Following Request is APPROVED||DISAPPROVED and no Order Number.
                {
                    $error_code = "0xFR"
                    $error_info = "File $($file) containing 'Following request is APPROVED || DISAPPROVED'. This is a known issue and guidance has been to disregard these files. Error code $($error_code)."

                    Write-Verbose "[+] $($error_info)"

                     $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_orders_main += $order_info
                               
                    continue
                }
                elseif($($format) -eq '165' -and !($($following_request_exists)))
                {
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "[#] Looking for order number in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $order_number = $order_number[1]
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Verbose "[*] Found 'published year' in $($file)."

                    $anchor = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "You are ordered to" -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | 
                    Select -First 1 | 
                    ConvertFrom-String | 
                    Select P3, P4, P5, P6 ) # MI (3 = last, 4 = first, 5 = MI, 6 = SSN) // NO MI ( 3 = last, 4 = first, 5 = ssn, 6 = rank )

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
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

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
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

                    Write-Verbose "[#] Looking for 'period to year, month, day' in $($file)."
                    $period_to = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "Period of active duty: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period_to = $period_to.ToString()
                    $period_to = $period_to.Split(' ')
                    $period_to_number = $period_to[-2]
                    $period_to_time = $period_to[-1]
                    $period_to_time = $period_to_time.ToUpper()
                    $period_to_time = $period_to_time.Substring(0, 1)
                    $period_to = "NTE$($period_to_number)$($period_to_time)"
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."

                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_time $($period_to_time) -period_to_number $($period_to_number) -uic $($uic) -format $($format)
                    if(!($validation_results.Status -contains 'fail'))
                    {
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
                            PERIOD_TO_YEAR = ''
                            PERIOD_TO_MONTH = ''
                            PERIOD_TO_NUMBER = $($period_to_number)
                            PERIOD_TO_TIME = $($period_to_time)
                            FORMAT = $($format)
                            ORDER_AMENDED = ''
                            ORDER_REVOKE = ''
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_orders_main += $order_info         
                    }
                    else
                    {
                        $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
                        if($total_validation_fails -gt 1)
                        {
                            Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
                            $validation_results | Sort-Object -Property Status
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation."
                        }
                        elseif($total_validation_fails -eq 1)
                        {
                            Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
                            $validation_results | Sort-Object -Property Status
                            throw "[!] $($total_validation_fails) variables for $($file) failed validation."
                        }
                    }
                }
                elseif($($format) -eq '172' -and !($($following_request_exists)))
                {
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1]
                    Write-Verbose "[*] Found 'order number' in $($file)."

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
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."
                    
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
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

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
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."
                    
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -format $($format) -uic $($uic) -first_name $($first_name) -last_name $($last_name) -middle_initial $($middle_initial) -order_number $($order_number) -published_year $($published_year) -ssn $($ssn) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
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
	                    $orders_created_orders_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
                    }
                }
                elseif($($format) -like '700' -and !($($following_request_exists))) # Amendment order for "700" and "700 *" formats
                {
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Verbose "[*] Found 'order number' in $($file)."
                    
                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    Write-Verbose "[#] Looking for 'order amended' in $($file)."
                    $order_amended = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_amended = $order_amended.ToString()
                    $order_amended = $order_amended.Split(' ')
                    $order_amended = $order_amended[5]
                    $order_amended = $order_amended.Insert(3,"-")
                    Write-Verbose "[*] Found 'order amended' in $($file)."

                    $pertaining_to = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
                    $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

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
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -uic $($uic) -order_amended $($order_amended) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -format $($format)

                    if(!($validation_results.Status -contains 'fail'))
                    {
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
	                    $orders_created_orders_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
                    }
                }
                elseif($($format) -eq '705' -and !($($following_request_exists))) # Revoke.
                {
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Verbose "[*] Found 'order number' in $($file)."

                    Write-Verbose "[#] Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    Write-Verbose "[#] Looking for 'order revoke' in $($file)."
                    $order_revoke = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_revoke = $order_revoke.ToString()
                    $order_revoke = $order_revoke.Split(' ')
                    $order_revoke = $order_revoke[5]
                    $order_revoke = $order_revoke.Insert(3,"-")
                    Write-Verbose "[*] Found 'order revoke' in $($file)."

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
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -uic $($uic) -order_revoke $($order_revoke) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -format $($format)

                    if(!($validation_results.Status -contains 'fail'))
                    {
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
	                    $orders_created_orders_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
                    }
                }
                elseif($($format) -eq '290' -and !($($following_request_exists))) # Pay order only.
                {
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Verbose "[*] Found 'order number' in $($file)."

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
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

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
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

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
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."

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
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
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
	                    $orders_created_orders_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
                    }
                }
                elseif($($format) -eq '296' -or $($format) -eq '282' -or $($format) -eq '294' -or $($format) -eq '284' -and !($($following_request_exists))) # 296 AT Orders // 282 Unknown // 294 Full Time National Guard Duty - Operational Support (FTNGD-OS) // 284 Unknown.
                {
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "[#] Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_working)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $month = $order_number[-2]
                    $published_month = $months.Get_Item($($month)) # Retrieve month number value from hash table.
                    Write-Verbose "[#] Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Verbose "[*] Found 'published year' in $($file)."
                    $order_number = $order_number[1]
                    Write-Verbose "[*] Found 'order number' in $($file)."

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
                    Write-Verbose "[*] Found 'last, first, mi, ssn' in $($file)."

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
                    Write-Verbose "[*] Found 'period from year, month, day' in $($file)."

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
                    Write-Verbose "[*] Found 'period to year, month, day' in $($file)."
                    
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
                    Write-Verbose "[*] Found 'uic' in $($file)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
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
	                    $orders_created_orders_main += $order_info
                    }
                    else
                    {
	                    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                    if($total_validation_fails -gt 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
		                    Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
		                    $validation_results | Sort-Object -Property Status
		                    throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                    }
                    }
                }
                else
                {
                    $error_code = "0x00"
                    $error_info = "File $($file) with format $($format). This is not currently an unknown and/or handled format. Notify ORDPRO support of this error ASAP. Error code $($error_code)."

                    Write-Verbose "[+] $($error_info)"
                    
                    $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_orders_main += $order_info

                    continue
                }

                $activity = "Working magic on .mof files."
                $status = "Processed $($uic_soldier_order_file_name)."
                $percent_complete = (( $orders_created_orders_main.Length)/$($total_to_create_orders_main )).ToString("P")
                $estimated_time = (($($total_to_create_orders_main) - ($orders_created_orders_main.Length)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#] Activity: ($($activity)). Status: ($($status)). Created: ($($orders_created_orders_main.Length) / $($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main.Length) / $($total_to_create_orders_main)). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."
            }

            Write-Verbose "[*] Writing $($orders_created_orders_main_csv) file now."
            $orders_created_orders_main | Select FORMAT, ORDER_NUMBER, ORDER_AMENDED, ORDER_REVOKE, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PUBLISHED_YEAR, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY, PERIOD_TO_NUMBER, PERIOD_TO_TIME, PUBLISHED_MONTH, PUBLISHED_DAY | Sort -Property ORDER_NUMBER | Export-Csv "$($orders_created_orders_main_csv)" -NoTypeInformation -Force
            $orders_not_created_orders_main | Select FILE, ERROR_CODE, ERROR_INFO | Sort -Property ERROR_CODE | Export-Csv "$($orders_not_created_orders_main_csv)" -NoTypeInformation -Force
    }
    else
    {
        Write-Verbose "[!] Total to create: ($($total_to_create_orders_main)). No .mof files in $($mof_directory_working) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm -em' then try again."
        throw "[!] No .mof files in $($mof_directory_working) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
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

        $orders_created_orders_cert = @()
        $orders_created_orders_cert_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_orders_cert.csv"

        $soldiers = @(Get-ChildItem -Path "$($uics_directory_output)" -Exclude "__PERMISSIONS" -Recurse -Include "*.txt" | % { Split-Path  -Path $_  -Parent })
        $name_ssn = @{}

        Write-Verbose "[#] Total to create: $($total_to_create_orders_cert)"

        Write-Verbose "[#] Populating name_ssn hash table now."
        foreach($s in $soldiers)
        {
            Process-DevCommands -sw $($sw)

            $s = $s -split "\\" -split "___"
            $name = $s[-2]
            $ssn = $s[-1]

            if(!($name_ssn.ContainsKey($name)))
            {
                Write-Verbose "[#] $($name) not in hash table. Adding $($name) to hash table now."

                $name_ssn.Add($name, $ssn)

                if($?)
                {
                    Write-Verbose "[*] $($name) added to hash table succcessfully."
                }
                else
                {
                    Write-Verbose "[!] $($name) failed to add to hash table."  ([char]7)
                }
            }
            else
            {
                Write-Verbose "[*] $($name) already in hash table."
            }
        }
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
                Write-Verbose "[*] Found 'last, first, mi' in $($file)."

                Write-Verbose "[#] Looking for 'order number' in $($file)."
                $order_number = (Select-String -Path "$($file)" -Pattern $($regex_order_number_parse_orders_cert) -ErrorAction SilentlyContinue | Select -First 1)
                $order_number = $order_number.ToString()
                $order_number = $order_number.Split(' ')
                $order_number = $($order_number[2])
                $order_number = $order_number.Insert(3,"-")
                Write-Verbose "[*] Found 'order number' in $($file)."

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
                Write-Verbose "[*] Found 'period from year, month, day' in $($file)."
        
                Write-Verbose "[#] Looking up 'ssn' in hash table for $($file)."
                $ssn = $name_ssn."$($last_name)_$($first_name)_$($middle_initial)" # Retrieve ssn from soldiers_ssn hash table via key lookup.      
                Write-Verbose "[*] Found 'ssn' in hash table for $($file)."

                $validation_results = Validate-Variables -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                if(!($validation_results.Status -contains 'fail'))
                {
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
	                $orders_created_orders_cert += $order_info
                }
                else
                {
	                $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
	                if($total_validation_fails -gt 1)
	                {
		                Write-Verbose "[!] $($total_validation_fails) variables for $($file) failed validation."
                        $validation_results | Sort-Object -Property Status
		                throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                }
	                elseif($total_validation_fails -eq 1)
	                {
		                Write-Verbose "[!] $($total_validation_fails) variable for $($file) failed validation."
                        $validation_results | Sort-Object -Property Status
		                throw "[!] $($total_validation_fails) variables for $($file) failed validation."
	                }
                }

                $activity = "Working magic on .cof files"
                $status = "Processed $($uic_soldier_order_file_name)."
                $percent_complete = (( $orders_created_orders_cert.Length)/$($total_to_create_orders_cert )).ToString("P")
                $estimated_time = (($($total_to_create_orders_cert) - ($orders_created_orders_cert.Length)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $sw.Elapsed.ToString('hh\:mm\:ss')

                Write-Verbose "[#]Activity: ($($activity)). Status: ($($status)). Created: ($($orders_created_orders_cert.Length) / $($total_to_create_orders_cert)). Not created ($($orders_not_created_orders_cert.Length) / $($total_to_create_orders_cert)). Percent complete: ($($percent_complete)). Time left: (~$($formatted_estimated_time) minute(s)). Time elapsed: ($($elapsed_time))."

            }

            Write-Verbose "[*] Writing $($orders_created_orders_cert_csv) file now."
            $orders_created_orders_cert | Select FORMAT, ORDER_NUMBER, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY | Sort -Property ORDER_NUMBER | Export-Csv -NoTypeInformation -Path "$($orders_created_orders_cert_csv)"
    }
    else
    {
        Write-Verbose "[!] Total to create: $($total_to_create_orders_cert). No .cof files in $($cof_directory_working) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
        throw "[!] No .cof files in $($cof_directory_working) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
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
        Write-Verbose "[*] $($uic_directory) already created, continuing."
    }
    else
    {
        Write-Verbose "[#] $($uic_directory) not created. Creating now."
        New-Item -ItemType Directory -Path "$($uics_directory_output)\$($uic)" > $null

        if($?)
        {
            Write-Verbose "[*] $($uic_directory) created successfully."
        }
        else
        {
            Write-Verbose "[!] Failed to process for $($last_name) $($first_name) $($uic). $($uic_directory) creation failed."
            throw "[!] Failed to process for $($last_name) $($first_name) $($uic). $($uic_directory) creation failed."
        }
    }

    if(Test-Path $($soldier_directory_uics))
    {
        Write-Verbose "[*] $($soldier_directory_uics) already created, continuing."
    }
    else
    {
        Write-Verbose "[#] $($soldier_directory_uics) not created. Creating now."
        New-Item -ItemType Directory -Path "$($soldier_directory_uics)" > $null

        if($?)
        {
            Write-Verbose "[*] $($soldier_directory_uics) created successfully."
        }
        else
        {
            Write-Verbose "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics) creation failed."
            throw "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory_uics)\$($uic_soldier_order_file_name)")
    {
        Write-Verbose "[*] $($soldier_directory_uics)\$($uic_soldier_order_file_name) already created, continuing."
    }
    else
    {
        Write-Verbose "[#] $($soldier_directory_uics)\$($uic_soldier_order_file_name) not created. Creating now."
        New-Item -ItemType File -Path $($soldier_directory_uics) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

        if($?)
        {
            Write-Verbose "[*] $($soldier_directory_uics)\$($uic_soldier_order_file_name) created successfully."
        }
        else
        {
            Write-Verbose "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics)\$($uic_soldier_order_file_name) creation failed."
            throw "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics)\$($uic_soldier_order_file_name) creation failed."
        }
    }

    if(Test-Path $($soldier_directory_ord_managers))
    {
        Write-Verbose "[*] $($soldier_directory_ord_managers) already created, continuing."
    }
    else
    {
        Write-Verbose "[#] $($soldier_directory_ord_managers) not created. Creating now."
        New-Item -ItemType Directory -Path "$($soldier_directory_ord_managers)" > $null

        if($?)
        {
            Write-Verbose "[*] $($soldier_directory_ord_managers) created successfully."
        }
        else
        {
            Write-Verbose "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers) creation failed."
            throw "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name)")
    {
        Write-Verbose "[*] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) already created, continuing."
    }
    else
    {
        Write-Verbose "[#] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) not created. Creating now."
        New-Item -ItemType File -Path $($soldier_directory_ord_managers) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

        if($?)
        {
            Write-Verbose "[*] $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) created successfully."
        }
        else
        {
            Write-Verbose "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) creation failed."
            throw "[!] Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) creation failed."
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
	  
    $total_to_clean_main_files = (Get-ChildItem -Path "$($mof_directory_working)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length

    if($($total_to_clean_main_files) -gt '0')
    {
        Write-Verbose "[#] Total .mof files to clean in $($mof_directory_working): $($total_to_clean_main_files)"
        Remove-Item -Path "$($mof_directory_working)" -Recurse -Force

        if($?)
        {
            Write-Verbose "[*] $($mof_directory_working) removed successfully. Cleaned: $($total_to_clean_main_files) .mof files from $($mof_directory_working)."
            New-Item -ItemType Directory -Path "$($mof_directory_working)" -Force > $null
            New-Item -ItemType Directory -Path "$($mof_directory_original_splits_working)" -Force > $null
        }
        else
        {
            Write-Verbose "[!] Failed to remove $($mof_directory_working)."
            throw "[!] Failed to remove $($mof_directory_working)."
        }
    }
    else
    {
        Write-Verbose "[!] Total .mof files to clean: $($total_to_clean_main_files). No .mof files in $($mof_directory_working) to clean up."
    }
}

function Clean-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )
	  
    $total_to_clean_cert_files = (Get-ChildItem -Path "$($cof_directory_working)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length

    if($($total_to_clean_cert_files) -gt '0')
    {
        Write-Verbose "[#] Total .cof files to clean in $($cof_directory_working): $($total_to_clean_cert_files)"
        Remove-Item -Path "$($cof_directory_working)" -Recurse -Force

        if($?)
        {
            Write-Verbose "[*] $($cof_directory_working) removed successfully. Cleaned: $($total_to_clean_cert_files) .cof files from $($cof_directory_working)."
            New-Item -ItemType Directory -Path "$($cof_directory_working)" -Force > $null
            New-Item -ItemType Directory -Path "$($cof_directory_original_splits_working)" -Force > $null
        }
        else
        {
            Write-Verbose "[!] Failed to remove $($cof_directory_working)."
            throw "[!] Failed to remove $($cof_directory_working)."
        }
    }
    else
    {
        Write-Verbose "[!] Total .cof files to clean: $($total_to_clean_cert_files). No .cof files in $($cof_directory_working) to clean up."
    }
}

function Clean-UICS()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uics_directory_output
    )

    $total_to_clean_uics_directories = (Get-ChildItem -Path "$($uics_directory_output)").Length

    if($($total_to_clean_uics_directories) -gt '0')
    {
        Write-Verbose "[#] Total UICS directories to clean in $($uics_directory_output): $($total_to_clean_uics_directories)"
        Remove-Item -Path "$($uics_directory_output)" -Recurse -Force

        if($?)
        {
            Write-Verbose "[*] $($uics_directory_output) removed successfully. Cleaned: $($total_to_clean_uics_directories) directories from $($uics_directory_output)."
            New-Item -ItemType Directory -Path "$($uics_directory_output)" -Force > $null
        }
        else
        {
            Write-Verbose "[!] Failed to remove $($uics_directory_output)."
            throw "[!] Failed to remove $($uics_directory_output)."
        }
    }
    else
    {
        Write-Verbose "[!] Total directories to clean: $($total_to_clean_uics_directories). No directories in $($uics_directory_output) to clean up."
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

    $html_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory_output)_permissions_report.html"
    $csv_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory_output)_permissions_report.csv"
    $txt_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory_output)_permissions_report.txt"

    if(!(Test-Path "$($permissions_reports_directory)\$($run_date)"))
    {
        New-Item -ItemType Directory -Path "$($permissions_reports_directory)\$($run_date)" > $null
    }

    Write-Verbose "[#] Writing permissions of $($uics_directory_output) to .csv file now."
    Get-ChildItem -Recurse -Path $($uics_directory_output) -Exclude '__PERMISSIONS' | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | Export-Csv -Force -NoTypeInformation $($csv_report)
    if($?)
    {
        Write-Verbose "[*] $($uics_directory_output) permissions writing to .csv finished successfully."
    }
    else
    {
        Write-Verbose "[!] $($uics_directory_output) permissions writing to .csv failed."
        throw "[!] $($uics_directory_output) permissions writing to .csv failed."
    }

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
    Get-ChildItem -Recurse -Path $($uics_directory_output) -Exclude '__PERMISSIONS' | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | ConvertTo-Html -Title "$($uics_directory_output) Permissions Report" -Head $($css) -Body "<h1>$($uics_directory_output) Permissions Report</h1> <h5> Generated on $(Get-Date -UFormat "%Y-%m-%d @ %H-%M-%S")" | Out-File $($html_report)
    if($?)
    {
        Write-Verbose "[*] $($uics_directory_output) permissions writing to .html finished successfully."
    }
    else
    {
        Write-Verbose "[!] $($uics_directory_output) permissions writing to .html failed."
        throw "[!] $($uics_directory_output) permissions writing to .html failed."
    }

    Write-Verbose "[#] Writing permissions of $($uics_directory_output) to .txt file now."
    Get-ChildItem -Recurse -Path $($uics_directory_output) -Exclude '__PERMISSIONS' | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | Format-Table -AutoSize -Wrap | Out-File $($txt_report)
    if($?)
    {
        Write-Verbose "[*] $($uics_directory_output) permissions writing to .txt finished successfully."
    }
    else
    {
        Write-Verbose "[!] $($uics_directory_output) permissions writing to .txt failed."
        throw "[!] $($uics_directory_output) permissions writing to .txt failed."
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

                Write-Verbose "[#] Validating ( $($parameters_processed) / $($parameters_passed) ) parameters now."

                $key = $p.Key
                $value = $p.Value

                if($key -eq 'uic')
                {
                    if($value -match "^\w{5}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'last_name')
                {
                    if($value -match "^[a-zA-Z'-]{1,20}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'first_name')
                {
                    if($value -match "^[a-zA-Z'-]{1,20}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'middle_initial')
                {
                    if($value -match "^[A-Z]{1,3}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'published_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'published_month')
                {
                    if($value -match "^\d{2}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'published_day')
                {
                    if($value -match "^\d{2}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'ssn')
                {
                    if($value -match "^\d{3}-\d{2}-\d{4}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_from_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_from_month')
                {
                    if($value -match "^\d{2}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_from_day')
                {
                    if($value -match "^\d{2}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_to_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_to_month')
                {
                    if($value -match "^\d{2}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_to_day')
                {
                    if($value -match "^\d{2}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_to_number')
                {
                    if($value -match "^\d{1,4}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'period_to_time')
                {
                    if($value -match "^[A-Z]{4,6}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'format')
                {
                    if($value -match "^\d{3}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'order_amended')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'order_revoke')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                elseif($key -eq 'order_number')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
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
	                    Write-Verbose "[!] Value '$($value)' from '$($key)' failed validation."
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }

                        throw "[!] Value '$($value)' from '$($key)' failed validation."
                    }
                }
                else
                {
                    Write-Verbose "[!] Incorrect or unknown parameter specified. Try again with proper input."  -ForegroundColor Red
                    throw "[!] Incorrect or unknown parameter specified. Try again with proper input."
                }

                Write-Verbose "[*] Finished validating ( $($parameters_processed) / $($parameters_passed) ) parameters."
            }

            return $validation_results
    }
    else
    {
        Write-Verbose "[!] No parameters passed. Try again with proper input."  -ForegroundColor Red
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
                default { "Response not determined." }
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
        $log_path = "$($log_directory_working)\$($run_date)\$($run_date)_M=$($p).log"
        $error_path = "$($log_directory_working)\$($run_date)\$($run_date)_M=$($p)_errors.log"

        if($p -ne 'Verbose' -or $p -ne 'help' -or $p -ne 'version')
        {
            Start-Transcript -Path $($log_path)
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
	            Write-Host "[^] Version parameter specified. Presenting version information now." -ForegroundColor Cyan
	            Write-Host "Running version $($version_info)."
            }

            "dir_create" 
            { 
	            try
	            {
                    if(!($($output_dir)))
                    {
                        Write-Host "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included." -ForegroundColor Red
                        Stop-Transcript
                        exit 1
                    }

		            Write-Host "[^] Creating required directories." -ForegroundColor Cyan
		            Create-RequiredDirectories -directories $($directories)
		            if($?) 
		            {
			            Write-Host "[^] Creating directories finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript
		            } 
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Directory creation failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript
		            exit 1	
	            }
            }

            "backups" 
            { 
	            try
	            {
                    if(!($($output_dir)))
                    {
                        Write-Host "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included." -ForegroundColor Red
                        Stop-Transcript
                        exit 1
                    }

		            Write-Host "[^] Backing up original orders file." -ForegroundColor Cyan
		            Move-OriginalToArchive -tmp_directory_working $($tmp_directory_working) -archive_directory_working $($archive_directory_working) -ordregisters_output $($ordregisters_output)
		            if($?) 
		            { 
			            Write-Host "[^] Backing up original orders file finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript
		            }	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Backing up original orders failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript
		            exit 1 
	            }
            }

            "split_main" 
            { 
	            try
	            {
		            Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files." -ForegroundColor Cyan	
		            Split-OrdersMain -current_directory_working $($current_directory_working) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)
		            if($?)
		            {
			            Write-Host "[^] Splitting '*m.prt' order file(s) finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript
		            }
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Splitting '*m.prt' order file(s)  failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript
		            exit 1 
	            }
            }

            "split_cert"
            { 

	            try
	            {
		            Write-Host "[^] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor Cyan
		            Split-OrdersCertificate -current_directory_working $($current_directory_working) -cof_directory_working $($cof_directory_working) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)
		            if($?) 
		            {
			            Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished successfully." -ForegroundColor Cyan
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Splitting '*c.prt' certificate file(s) into individual certificate files failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 
	            }

            }

            "edit_main" 
            { 
	            try
	            {
		            Write-Host "[^] Editing orders '*m.prt' files." -ForegroundColor Cyan
		            Edit-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_original_splits_working $($mof_directory_original_splits_working)
		            if($?) 
		            { 
			            Write-Host "[^] Editing orders '*m.prt' files finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            }
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Editing orders '*m.prt' files failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1
	            }
            }

            "edit_cert" 
            { 
	            try
	            {
		            Write-Host "[^] Editing orders '*c.prt' files." -ForegroundColor Cyan
		            Edit-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert) -cof_directory_original_splits_working $($cof_directory_original_splits_working)
		            if($?)
		            { 
			            Write-Host "[^] Editing orders '*c.prt' files finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Editing orders '*c.prt' files failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1
	            }
            }

            "combine_main" 
            { 
	            try
	            {
		            Write-Host "[^] Combining .mof orders files." -ForegroundColor Cyan
		            Combine-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -run_date $($run_date)
		            if($?) 
		            { 
			            Write-Host "[^] Combining .mof orders files finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Combining .mof orders files failed. Check the error logs at $($error_path)." -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 
	            }
            }

            "combine_cert" 
            { 
	            try
	            {
		            Write-Host "[^] Combining .cof orders files." -ForegroundColor Cyan
		            Combine-OrdersCertificate -cof_directory_working $($cof_directory_working) -run_date $($run_date)
		            if($?) 
		            { 
			            Write-Host "[^] Combining .cof orders files finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Combining .cof orders files failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 	
	            }
            }

            "magic_main" 
            { 
                try
                {
                    if(!($($output_dir)))
                    {
                        Write-Host "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included." -ForegroundColor Red
                        Stop-Transcript
                        exit 1
                    }

                    Write-Host "[^ Working magic on .mof files now." -ForegroundColor Cyan
                    Parse-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
		            if($?) 
		            { 
			            Write-Host "[^] Magic on .mof files finished successfully. Did you expect anything less?" -ForegroundColor Cyan 
                        Stop-Transcript 
		            }
                }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Magic on .mof files failed?! Impossible. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 	
	            }
            }

            "magic_cert" 
            { 
	            try
	            {
                    if(!($($output_dir)))
                    {
                        Write-Host "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included." -ForegroundColor Red
                        Stop-Transcript
                        exit 1
                    }

		            Write-Host "[^] Working magic on .cof files." -ForegroundColor Cyan
		            Parse-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		            if($?) 
		            { 
			            Write-Host "[^] Magic on .cof files finished successfully. Did you expect anything less?" -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Magic on .cof files failed?! Impossible. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 	
	            }
            }

            "clean_main" 
            { 
	            try
	            {
		            Write-Host "[^] Cleaning up .mof files." -ForegroundColor Cyan
		            Clean-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories)
		            if($?) 
		            { 
			            Write-Host "[^] Cleaning up .mof finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Cleaning up .mof failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 	
	            }
            }

            "clean_cert" 
            { 
	            try
	            {
		            Write-Host "[^] Cleaning up .cof files." -ForegroundColor Cyan
		            Clean-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		            if($?) 
		            { 
			            Write-Host "[^] Cleaning up .cof finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Cleaning up .cof failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1
	            }
            }

            "clean_uics" 
            { 
	            try
	            {
                    if(!($($output_dir)))
                    {
                        Write-Host "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included." -ForegroundColor Red
                        Stop-Transcript
                        exit 1
                    }

		            Write-Host "[^] Cleaning up UICS folder." -ForegroundColor Cyan
		            Clean-UICS -uics_directory_output $($uics_directory_output)
		            if($?)
		            { 
			            Write-Host "[^] Cleaning up UICS folder finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Cleaning up UICS folder failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1
	            }
            }
            "permissions" 
            { 
	            try
	            {
                    if(!($($output_dir)))
                    {
                        Write-Host "[!] No output directory specified. Try again with '-o <destination_folder>' parameter included." -ForegroundColor Red
                        Stop-Transcript
                        exit 1
                    }

		            Write-Host "[^] Getting permissions." -ForegroundColor Cyan
		            Get-Permissions -uics_directory_output $($uics_directory_output)
		            if($?) 
		            { 
			            Write-Host "[^] Getting permissions of UICS folder finished successfully." -ForegroundColor Cyan 
                        Stop-Transcript 
		            } 	
	            }
	            catch
	            {
		            $_ | Out-File -Append $($error_path)
		            Write-Host "[!] Getting permissions failed. Check the error logs at $($error_path)."  -ForegroundColor Red
                    Stop-Transcript 
		            exit 1 
	            }
            }

            "all" 
            {  
	            try
	            {
	
	            }
	            catch
	            {
	
	            }

            }

            "Verbose" 
            { 
                continue
	            #Write-Host "[^] Verbose parameter specified. Presenting verbose information above." -ForegroundColor Cyan
            }

            default 
            { 
	            Write-Host "[!] Unrecognized parameter: $($p). Try again with proper parameter." -ForegroundColor Red 
            }
        }
    }
}
else
{
    Write-Host "[!] No parameters passed. Run 'Get-Help $($script_name) -Full' for detailed help information" -ForegroundColor Red
}
