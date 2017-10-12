<#
.Synopsis
   Script to help automate order management.
.DESCRIPTION
   Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
.PARAMETER h
   Help page. This parameter tells the script you want to learn more about it. It will display this page after running the command 'Get-Help .\ORDPRO.ps1 -Full' for you.
.PARAMETER dir_create
   Directory creation. This parameter tells the script to create the required directories for the script to run. Directories created are ".\MASTER-HISTORY\{EDITED}{NONEDITED}" ".\UICS" ".\TMP".
.PARAMETER backups
   Backup original order files. This parameter tells the script to create backups of all files in current directory. Backups all files with ".prt" extension in current directory to ".\MASTER-HISTORY\NONEDITED" directory.
.PARAMETER split_main
   Split main order files with "*m.prt" name. This parameter tells the script to split the main "*m.prt" file into individual orders. Individual order files are split to ".\TMP\{n}.mof" files for editing.
.PARAMETER split_cert
   Split certificate order files with "*c.prt" name. This parameter tells the script to split the main "*c.prt" file into individual certificate orders. Individual certificate orders files are split to ".\TMP\{n}.cof" files for editing.
.PARAMETER edit_main
   Edit main order files. This parameter tells the script to edit the individual ".\TMP\{n}.mof" files to be ready to be combined.
.PARAMETER edit_cert
   Edit certificate order files. This parameter tells the script to edit the individual ".\TMP\{n}.cof" files to be ready to be combined.
.PARAMETER combine_main
   Combine main order files. This parameter tells the script to combine the edited main order files into a single document to be used at a later date.
.PARAMETER combine_cert
   Combine certificate order files. This parameter tells the script to combine the edited certificate order files into a single document to be used at a later date.
.PARAMETER magic_main
   Magic work on main orders. This parameter tells the script to parse the split main order files, create directory structure based on parsed data, and put orders in appropriate ".\UICS\UIC\SSN" folders.
.PARAMETER magic_cert
   Magic work on certificate orders. This parameter tells the script to parse the split certificate order files, create directory structure based on parsed data, and put orders in appropriate ".\UICS\UIC\SSN" folders.
.PARAMETER clean_main
   Cleanup main order files. This parameter tells the script to cleanup the ".\TMP" directory of all {n}.mof files.
.PARAMETER clean_main
   Cleanup certificate order files. This parameter tells the script to cleanup the ".\TMP" directory of all {n}.cof files.
.PARAMETER all
   All parameters. This parameter tells the script to run all required parameters needed to be successful. Most common parameter to those new to using this script.
.INPUTS
   Script parses all "*m.prt" and "*c.prt" files in current directory.
.OUTPUTS
   Script creates directory structure and invididual order files within each ".\UIC\SSN" folder.
.NOTES
   NAME: ORDPRO.ps1 (Order Processing Automation)

   AUTHOR: Ashton J. Hanisch

   VERSION: 0.3

   TROUBLESHOOTING: All script output will be in .\tmp\logs folder. Should you have any problems script use, email ajhanisch@gmail.com with a description of your issue and the log file that is associated with your problem.

   SUPPORT: For any issues, comments, concerns, ideas, contributions, etc. to any part of this script or its functionality, reach out to me at ajhanisch@gmail.com. I am open to any thoughts you may have to make this work better for you or things you think are broken or need to be different. I will ensure to give credit where credit is due for any contributions or improvement ideas that are shared with me in the "Credits and Acknowledgements" section in the README.txt file.

   UPDATES: To check out any updates or revisions made to this script check out the updated README.txt included with this script.
   
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
param(
    [switch]$h,
    [switch]$dir_create,
    [switch]$backups,
    [switch]$split_main,
    [switch]$split_cert,
    [switch]$edit_main,
    [switch]$edit_cert,
    [switch]$combine_main,
    [switch]$combine_cert,
    [switch]$magic_main,
    [switch]$magic_cert,
    [switch]$clean_main,
    [switch]$clean_cert,
    [switch]$all
)

<#
DIRECTORIES
#>
$current_directory = (Get-Item -Path ".\" -Verbose).FullName
$master_history_edited = "$($current_directory)\MASTER-HISTORY\EDITED"
$master_history_unedited = "$($current_directory)\MASTER-HISTORY\UNEDITED"
$uics_directory = "$($current_directory)\UICS"
$tmp_directory = "$($current_directory)\TMP"
$log_directory = "$($tmp_directory)\LOGS"

<#
ARRAYS
#>
$directories = @("$($master_history_edited)","$($master_history_unedited)","$($uics_directory)","$($tmp_directory)", "$($log_directory)")

<#
HASH TABLES
#>
$months = @{"January" = "01"; "February" = "02"; "March" = "03"; "April" = "04"; "May" = "05"; "June" = "06"; "July" = "07"; "August" = "08"; "September" = "09"; "October" = "10"; "November" = "11"; "December" = "12";}

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
$regex_period_parse_orders_cert = "^Period of duty: \d{6}"
$regex_uic_parse_orders_cert = "CERTIFICATE OF PERFORMANCE / STATEMENT OF ATTENDANCE"
$regex_name_parse_orders_cert = "XXX-XX-XXXX"

$regex_beginning_m_split_orders_main = "STATE OF SOUTH DAKOTA"
$regex_beginning_c_split_orders_cert = "FOR OFFICIAL USE ONLY - PRIVACY ACT"
$regex_end_cert = "Automated NGB Form 102-10A  dtd  12 AUG 96"

<#
VARIABLES NEEDED
#>
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$log_path = "$($log_directory)\$($run_date).log"
$error_path = "$($log_directory)\$($run_date)_errors.log"
$script_name = $($MyInvocation.MyCommand.Name)
$year_prefix = (Get-Date -Format yyyy).Substring(0,2)
$exclude_directories = '$($master_history_edited)|$($master_history_unedited)'
$files_orders_original = Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq ".prt" }
$files_orders_m_prt = Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.FullName -like "*m.prt" }
$files_orders_c_prt = Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.FullName -like "*c.prt" }
[console]::TreatControlCAsInput = $true

<#
FUNCTIONS
#>

function Display-ProgressBar($percent_complete, $estimated_time, $formatted_estimated_time, $elapsed_time, $orders_created, $total_to_create, $uic_soldier_order_file_name)
{
    for($i = $orders_created; $i -le $total_to_create; $i++)
    {
	    Write-Progress -Activity "Creating orders ..." -Status "Creating $($uic_soldier_order_file_name)" -PercentComplete ($($orders_created)/$($total_to_create)*100) -CurrentOperation "$($percent_complete) complete          ~$($formatted_estimated_time) minute(s) left          $($orders_created)/$($total_to_create) created          $($elapsed_time) time elapsed"
    }
}

function Create-RequiredDirectories($directories)
{
    foreach($directory in $directories)
    {
        Process-DevCommands

        if(!(Test-Path $($directory)))
        {
            Write-Host "[#] $($directory) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $($directory) -ErrorAction SilentlyContinue > $null

            if($?)
            {
                Write-Host "[*] $($directory) created successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] $($directory) creation failed." ([char]7) -ForegroundColor Red
                throw "[!] $($directory) creation failed."
            }
        }
        else
        {
            Write-Host "[*] $($directory) already created." -ForegroundColor Green
        }
    }
}

function Move-OriginalToHistorical($files_orders_original, $master_history_edited, $master_history_unedited)
{
    foreach($file in $files_orders_original)
    {
        Process-DevCommands

        if(Test-Path "$($master_history_edited)\$($file)")
        {
            Write-Host "[*] $($file.BaseName) in $($master_history_unedited)." -ForegroundColor Green
        }
        else
        {
            Write-Host "[#] $($file.BaseName) not in $($master_history_unedited). Copying $($file.BaseName) to it now." -ForegroundColor Yellow
            Copy-Item $($file) -Destination $($master_history_unedited) -ErrorAction SilentlyContinue > $null

            if($?)
            {
                Write-Host "[*] $($file.BaseName) moved to $($master_history_unedited) successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] $($file.BaseName) move to $($master_history_unedited) failed." ([char]7) -ForegroundColor Red
                throw "[!] $($file.BaseName) move to $($master_history_unedited) failed."
            }
        }
    }
}

function Split-OrdersMain($tmp_directory, $files_orders_m_prt, $regex_beginning_m_split_orders_main)
{
    $count = 0

    foreach($file in $files_orders_m_prt)
    {
        $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
        $orders = [regex]::Match($content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "$($regex_beginning_m_split_orders_main)"

        foreach($order in $orders)
        {
            Process-DevCommands

            if($order)
            {
                $count ++

                $out_file = "$($count).mof"

                Write-Host "[#] Processing $($out_file) now." -ForegroundColor Yellow
                #$order >> "$($tmp_directory)\$($file.BaseName).txt" ## 1,120 KB same name as original .doc file containing edited orders
                $order >> "$($tmp_directory)\$($out_file)"

                if($?)
                {
                    Write-Host "[*] $($out_file) file created successfully." -ForegroundColor Green
                }
                else
                {
                    Write-Host "[!] $($out_file) file creation failed." ([char]7) -ForegroundColor Red
                    throw "[!] $($out_file) file creation failed."
                }
            }
        }
    }
}

function Split-OrdersCertificate($tmp_directory, $files_orders_c_prt, $regex_end_cert)
{
    $count = 0

    foreach($file in $files_orders_c_prt)
    {
        $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
        $orders = [regex]::Match($content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "$($regex_end_cert)"

        foreach($order in $orders)
        {
            Process-DevCommands

            if($order)
            {
                $count ++

                $out_file = "$($count).cof"

                Write-Host "[#] Processing $($out_file) now." -ForegroundColor Yellow
                #$order >> "$($tmp_directory)\$($file.BaseName).txt" ## 1,120 KB same name as original .doc file containing edited orders
                $order >> "$($tmp_directory)\$($out_file)"

                if($?)
                {
                    Write-Host "[*]$($out_file) file created successfully." -ForegroundColor Green
                }
                else
                {
                    Write-Host "[!] $($out_file) file creation failed." ([char]7) -ForegroundColor Red
                    throw "[!] $($out_file) file creation failed." 
                }
            }
        }
    }
}

function Edit-OrdersMain($tmp_directory, $exclude_directories, $regex_old_fouo_3_edit_orders_main)
{
    $total_to_edit_orders_main = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length
    Write-Host "[#] Total to edit: $($total_to_edit_orders_main)" -ForegroundColor Yellow
    $total_edited_orders_main = 0

$old_header = @"

                               DEPARTMENT OF MILITARY
                           OFFICE OF THE ADJUTANT GENERAL
                  2823 West Main Street, Rapid City, SD 57702-8186
"@
$new_header = @"
                              STATE OF SOUTH DAKOTA
                              DEPARTMENT OF MILITARY
                           OFFICE OF THE ADJUTANT GENERAL
                  2823 West Main Street, Rapid City, SD 57702-8186
"@
$old_spacing = @"

                          
                          


"@ # Spacing between APC DJMS-RC: and APC STANFINS Pay: created after removing FOUO's and others below

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }))
    {
        Process-DevCommands

        $file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw -ErrorAction SilentlyContinue)
        $file_content = $file_content -replace $old_header,$new_header
        $file_content = $file_content -replace "`f",''
        $file_content = $file_content -replace "FOR OFFICIAL USE ONLY - PRIVACY ACT",''
        $file_content = $file_content -replace $regex_old_fouo_3_edit_orders_main,''
        $file_content = $file_content -replace "`n$old_spacing",''

        if(!((Get-Item "$($tmp_directory)\$($file)") -is [System.IO.DirectoryInfo]))
        {
            Write-Host "[#] Editing $($file.Name) now." -ForegroundColor Yellow

            Set-Content -Path "$($tmp_directory)\$($file.Name)" $file_content
            
            if($?)
            {
                Write-Host "[*] $($file.Name) edited successfully." -ForegroundColor Green
                $total_edited_orders_main ++
            }
            else
            {
                Write-Host "[!] $($file.Name) editing failed." ([char]7) -ForegroundColor Red
                throw "[!] $($file.Name) editing failed."
            }
        }
        else
        {
            Write-Host "[#] $($file) is a directory. Skipping." -ForegroundColor Yellow
        }

        Write-Host "[#] Edited: $($total_edited_orders_main)/$($total_to_edit_orders_main)." -ForegroundColor Yellow
    }
}

function Edit-OrdersCertificate($tmp_directory, $exclude_directories, $regex_end_cert)
{
    $total_to_edit_orders_cert = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length
    Write-Host "[#] Total to edit: $($total_to_edit_orders_cert)" -ForegroundColor Yellow
    $total_edited_orders_cert = 0

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }))
    {
        Process-DevCommands

        $file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw -ErrorAction SilentlyContinue)
        $file_content = $file_content -replace "`f",''
        $file_content = $file_content -replace "                          FOR OFFICIAL USE ONLY - PRIVACY ACT",''
        $file_content = $file_content -replace "                          FOR OFFICIAL USE ONLY - PRIVACY ACT",''

        if(!((Get-Item "$($tmp_directory)\$($file)") -is [System.IO.DirectoryInfo]))
        {
            Write-Host "[#] Editing $($file.Name) now." -ForegroundColor Yellow

            Set-Content -Path "$($tmp_directory)\$($file.Name)" $file_content
            Add-Content -Path "$($tmp_directory)\$($file.Name)" -Value $($regex_end_cert)

            if($?)
            {
                Write-Host "[*] $($file.Name) edited successfully." -ForegroundColor Green
                $total_edited_orders_cert ++
            }
            else
            {
                Write-Host "[!] $($file.Name) editing failed." ([char]7) -ForegroundColor Red
                throw "[!] $($file.Name) editing failed."
            }
        }
        else
        {
            Write-Host "[#] $($file) is a directory. Skipping." -ForegroundColor Yellow
        }

        Write-Host "[#] Edited: $($total_edited_orders_cert)/$($total_to_edit_orders_cert)." -ForegroundColor Yellow
    }
}

function Combine-OrdersMain($tmp_directory, $run_date)
{
    $total_to_combine_orders_main = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length
    Write-Host "[#] Total to combine: $($total_to_combine_orders_main)" -ForegroundColor Yellow
    $orders_combined_orders_main = 0

    $out_file = "$($tmp_directory)\$($run_date)_m_combined_orders.txt"

    Write-Host "[#] Combining .mof files now." -ForegroundColor Yellow

    Get-ChildItem -Path $($tmp_directory) -Recurse | ? { ! $_.PSIsContainer } | ? { $_.Extension -eq '.mof' } | % { Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append; if($?){ Process-DevCommands; $orders_combined_orders_main ++; Write-Host "[#] Combined: $($orders_combined_orders_main)/$($total_to_combine_orders_main) .mof files." -ForegroundColor Yellow; } }

    if($?)
    {
        Write-Host "[*] Combined .mof files successfully." -ForegroundColor Green
        Write-Host "[*] Check your results at $($out_file)." -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] Combining .mof files failed." ([char]7) -ForegroundColor Red
        throw "[!] Combining .mof files failed."
    }
}

function Combine-OrdersCertificate($tmp_directory, $run_date)
{
    $total_to_combine_orders_cert = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length
    Write-Host "[#] Total to combine: $($total_to_combine_orders_cert)" -ForegroundColor Yellow
    $orders_combined_orders_cert = 0

    $out_file = "$($tmp_directory)\$($run_date)_c_combined_orders.txt"

    Write-Host "[#] Combining .cof files now." -ForegroundColor Yellow

    Process-DevCommands

    Get-ChildItem -Path $($tmp_directory) -Recurse | ? { ! $_.PSIsContainer } | ? { $_.Extension -eq '.cof' } | % { Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append; if($?){ Process-DevCommands; $orders_combined_orders_cert ++; Write-Host "[#] Combined: $($orders_combined_orders_cert)/$($total_to_combine_orders_cert) .cof files." -ForegroundColor Yellow; } }

    if($?)
    {
        Write-Host "[*] Combined .cof files successfully." -ForegroundColor Green
        Write-Host "[*] Check your results at $($out_file)." -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] Combining .cof files failed." ([char]7) -ForegroundColor Red
        throw "[!] Combining .cof files failed."
    }
}

function Parse-OrdersMain($tmp_directory, $exclude_directories, $regex_format_parse_orders_main, $regex_order_number_parse_orders_main, $regex_uic_parse_orders_main, $regex_order_amdend_revoke_parse_orders_main, $regex_pertaining_to_parse_orders_main)
{
    #$stop_watch = [system.diagnostics.stopwatch]::startNew()

    $total_to_create_orders_main = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length
    Write-Host "[#] Total to create: $($total_to_create_orders_main)" -ForegroundColor Yellow
    $orders_created_orders_main = 0

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }))
    {
        Process-DevCommands

        # Check for different 700 forms.
        $following_request = "Following Request is" # Disapproved || Approved
        $following_request_exists = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
        $following_order = "Following order is amended as indicated." # Amendment order. $($format.Length) -eq 4
        $following_order_exists = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($following_order) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

        # Check for bad 282 forms.
        $following_request = "Following Request is" # Disapproved || Approved
        $following_request_exists = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

        # Check for "Memorandum for record" file that does not have format number, order number, period, basically nothing
        $memorandum_for_record = "MEMORANDUM FOR RECORD"
        $memorandum_for_record_exists = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($memorandum_for_record) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

        $format = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_format_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
        if($($format))
        {
            $format = $format.ToString()
            $format = $format.Split(' ')
            $format = $format[1]
        }
        else
        {
            $error_code = "0xNF"
            $error_info = "File: $($file) Error: Found file with no format."

            Write-Host "[+] Found file with no format in $($file)!" -ForegroundColor Cyan
            Write-Host "[+] Specific format not existing not currently handled, skipping." -ForegroundColor Cyan
            
            continue
        }

        if($($following_request_exists)) # Any format containing Following Request is APPROVED||DISAPPROVED and no Order Number.
        {
            Write-Host "[+] Found format $($format) containing $($following_request) in $($file)!" -ForegroundColor Cyan
            Write-Host "[+] Specific format $($format) not currently handled, skipping." -ForegroundColor Cyan
            
            continue
        }
        elseif($($format) -eq '165' -and !($($following_request_exists)))
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            Read-Host -Prompt "Enter to continue"

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_number = $order_number.ToString()
            $order_number = $order_number.Split(' ')
            $published_day = $order_number[-3]
            $published_month = $order_number[-2]
            $published_year = $order_number[-1]
            $published_year = @($published_year -split '(.{2})' | ? {$_})
            $published_year = $($published_year[1]) # YYYY turned into YY
            $order_number = $order_number[1]

            $anchor = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
            $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name.
            if($($anchor.MiddleInitial).Length -ne 1)
            {
                $anchor.SSN = $anchor.MiddleInitial
                $anchor.MiddleInitial = 'NMI'
            }

            $last_name = $($anchor.LastName)
            $last_name = $last_name.Split(':')[-1]
            $first_name = $($anchor.FirstName)
            $middle_initial = $($anchor.MiddleInitial)
            $ssn = $($anchor.SSN)

            $period_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "Period of active duty: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $period_to = $period_to.ToString()
            $period_to = $period_to.Split(' ')
            $period_to_number = $period_to[-2]
            $period_to_time = $period_to[-1]
            $period_to_time = $period_to_time.ToUpper()
            $period_to_time = $period_to_time.Substring(0, 1)

            $period_from = (Select-String -Path "C:\temp\Ord\TMP\2632.mof" -Pattern "REPORT TO " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $period_from = $period_from.ToString()
            $period_from = $period_from.Split(' ')
            $period_from_day = $period_from[4]
            $period_from_month = $period_from[5]
            $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
            $period_from_year = $period_from[6]

            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___NTE$($period_to_number)$($period_to_time)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created_orders_main ++

            Write-Host "[#] Created: $($orders_created_orders_main)/$($total_to_create_orders_main)." -ForegroundColor Yellow

            Read-Host -Prompt "Enter to continue"

            <#
            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($orders_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
            #>
        }
        elseif($($format) -eq '172' -and !($($following_request_exists)))
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_number = $order_number.ToString()
            $order_number = $order_number.Split(' ')
            $published_day = $order_number[-3]
            $published_month = $order_number[-2]
            $published_year = $order_number[-1]
            $published_year = @($published_year -split '(.{2})' | ? {$_})
            $published_year = $($published_year[1]) # YYYY turned into YY
            $order_number = $order_number[1]

            $anchor = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
            $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name.
            if($($anchor.MiddleInitial).Length -ne 1)
            {
                $anchor.SSN = $anchor.MiddleInitial
                $anchor.MiddleInitial = 'NMI'
            }

            $last_name = $($anchor.LastName)
            $last_name = $last_name.Split(':')[-1]
            $first_name = $($anchor.FirstName)
            $middle_initial = $($anchor.MiddleInitial)
            $ssn = $($anchor.SSN)
        
            $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "Active duty commitment: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
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


            $period_to_day = $period[-3]
            $period_to_day = $period_to_day.ToString()
            if($($period_to_day).Length -ne 2)
            {
                $period_to_day = "0$($period_to_day)"
            }

            $period_to_month = $period[-2]
            $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
            $period_to_year = $period[-1]
        
            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created_orders_main ++

            Write-Host "[#] Created: $($orders_created_orders_main)/$($total_to_create_orders_main)." -ForegroundColor Yellow

            <#
            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($orders_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
            #>
        }
        elseif($($format) -eq '700' -and $($following_order_exists) -and !($($following_request_exists))) # Amendment order for "700" and "700 *" formats
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_number = $order_number.ToString()
            $order_number = $order_number.Split(' ')
            $published_day = $order_number[-3]
            $published_month = $order_number[-2]
            $published_year = $order_number[-1]
            $published_year = @($published_year -split '(.{2})' | ? { $_ })
            $published_year = $published_year[1]
            $order_number = $order_number[1] # YYYY turned into YY
                        
            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $order_amended = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_amended = $order_amended.ToString()
            $order_amended = $order_amended.Split(' ')
            $order_amended = $order_amended[5]
            $order_amended = $order_amended.Insert(3,"-")

            $pertaining_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
            $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name. Currently untested for revoke section.
            if($($pertaining_to.MiddleInitial).Length -ne 1)
            {
                $pertaining_to.SSN = $pertaining_to.MiddleInitial
                $pertaining_to.MiddleInitial = 'X'
            }

            $last_name = $($pertaining_to.LastName)
            $first_name = $($pertaining_to.FirstName)
            $middle_initial = $($pertaining_to.MiddleInitial)
            $ssn = $($pertaining_to.SSN)
            
            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_amended)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created_orders_main ++

            Write-Host "[#] Created: $($orders_created_orders_main)/$($total_to_create_orders_main)." -ForegroundColor Yellow

            <#
            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($orders_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
            #>
        }
        elseif($($format) -eq '705' -and !($($following_request_exists))) # Revoke.
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_number = $order_number.ToString()
            $order_number = $order_number.Split(' ')
            $published_day = $order_number[-3]
            $published_month = $order_number[-2]
            $published_year = $order_number[-1]
            $published_year = @($published_year -split '(.{2})' | ? { $_ })
            $published_year = $published_year[1]
            $order_number = $order_number[1] # YYYY turned into YY

            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $order_revoke = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_revoke = $order_revoke.ToString()
            $order_revoke = $order_revoke.Split(' ')
            $order_revoke = $order_revoke[5]
            $order_revoke = $order_revoke.Insert(3,"-")

            $pertaining_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
            $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name. Currently untested for revoke section.
            if($($pertaining_to.MiddleInitial).Length -ne 1)
            {
                $pertaining_to.SSN = $pertaining_to.MiddleInitial
                $pertaining_to.MiddleInitial = 'X'
            }

            $last_name = $($pertaining_to.LastName)
            $first_name = $($pertaining_to.FirstName)
            $middle_initial = $($pertaining_to.MiddleInitial)
            $ssn = $($pertaining_to.SSN)

            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_revoke)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created_orders_main ++

            Write-Host "[#] Created: $($orders_created_orders_main)/$($total_to_create_orders_main)." -ForegroundColor Yellow

            <#
            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($orders_created)) * 0.5 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
            #>
        }
        elseif($($format) -eq '290' -and !($($following_request_exists))) # Pay order only.
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_number = $order_number.ToString()
            $order_number = $order_number.Split(' ')
            $published_day = $order_number[-3]
            $published_month = $order_number[-2]
            $published_year = $order_number[-1]
            $published_year = @($published_year -split '(.{2})' | ? { $_ })
            $published_year = $published_year[1]
            $order_number = $order_number[1] # YYYY turned into YY

            $anchor = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "By order of the Secretary of the Army" -AllMatches -Context 5,0 -ErrorAction SilentlyContinue)
            $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name.
            if($($anchor.MiddleInitial).Length -ne 1)
            {
                $anchor.SSN = $anchor.MiddleInitial
                $anchor.MiddleInitial = 'NMI'
            }

            $last_name = $($anchor.LastName)
            $last_name = $last_name.Split(':')[-1]
            $first_name = $($anchor.FirstName)
            $middle_initial = $($anchor.MiddleInitial)
            $ssn = $($anchor.SSN)

            $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue  | Select -First 1 | ConvertFrom-String -PropertyNames Period, Status, Colon, FromDay, FromMonth, FromYear, Dash, ToDay, ToMonth, ToYear | Select Status, FromDay, FromMonth, FromYear, ToDay, ToMonth, ToYear)
            $period_status = $($period.Status)
            $period_from_day = $($period.FromDay)
            $period_from_day = $period_from_day.ToString()
            if($($period_from_day).Length -ne 2)
            {
                $period_from_day = "0$($period_from_day)"
            }
            $period_from_month = $($period.FromMonth)
            $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
            $period_from_year = $($period.FromYear)
            $period_to_day = $($period.ToDay)
            $period_to_day = $period_to_day.ToString()
            if($($period_to_day).Length -ne 2)
            {
                $period_to_day = "0$($period_to_day)"
            }

            $period_to_month = $($period.ToMonth)
            $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
            $period_to_year = $($period.ToYear)

            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created_orders_main ++

            Write-Host "[#] Created: $($orders_created_orders_main)/$($total_to_create_orders_main)." -ForegroundColor Yellow

            <#
            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($orders_created)) * 0.2 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
            #>
        }
        elseif($($format) -eq '296' -or $($format) -eq '282' -or $($format) -eq '294' -or $($format) -eq '284' -and !($($following_request_exists))) # 296 AT Orders // 282 Unknown // 294 Full Time National Guard Duty - Operational Support (FTNGD-OS) // 284 Unknown.
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
            $order_number = $order_number.ToString()
            $order_number = $order_number.Split(' ')
            $published_day = $order_number[-3]
            $published_month = $order_number[-2]
            $published_month = $months.Get_Item($($published_month)) # Retrieve month number value from hash table.
            $published_year = $order_number[-1]
            $published_year = @($published_year -split '(.{2})' | ? {$_})
            $published_year = $($published_year[1]) # YYYY turned into YY
            $order_number = $order_number[1]

            $anchor = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
            $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name.
            if($($anchor.MiddleInitial).Length -ne 1)
            {
                $anchor.SSN = $anchor.MiddleInitial
                $anchor.MiddleInitial = 'NMI'
            }

            $last_name = $($anchor.LastName)
            $last_name = $last_name.Split(':')[-1]
            $first_name = $($anchor.FirstName)
            $middle_initial = $($anchor.MiddleInitial)
            $ssn = $($anchor.SSN)
        
            $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue  | Select -First 1 | ConvertFrom-String -PropertyNames Period, Status, Colon, FromDay, FromMonth, FromYear, Dash, ToDay, ToMonth, ToYear | Select Status, FromDay, FromMonth, FromYear, ToDay, ToMonth, ToYear)
            $period_status = $($period.Status)
            $period_from_day = $($period.FromDay)
            $period_from_day = $period_from_day.ToString()
            if($($period_from_day).Length -ne 2)
            {
                $period_from_day = "0$($period_from_day)"
            }
            $period_from_month = $($period.FromMonth)
            $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
            $period_from_year = $($period.FromYear)
            $period_to_day = $($period.ToDay)
            $period_to_day = $period_to_day.ToString()
            if($($period_to_day).Length -ne 2)
            {
                $period_to_day = "0$($period_to_day)"
            }

            $period_to_month = $($period.ToMonth)
            $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
            $period_to_year = $($period.ToYear)
        
            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created_orders_main ++

            Write-Host "[#] Created: $($orders_created_orders_main)/$($total_to_create_orders_main)." -ForegroundColor Yellow

            <#
            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($orders_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
            #>
        }
        else
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan
            Write-Host "[+] Format $($format) not currently known or handled, skipping." -ForegroundColor Cyan            
            continue
        }
    }
}

function Parse-OrdersCertificate($tmp_directory, $exclude_directories)
{
    #$stop_watch = [system.diagnostics.stopwatch]::startNew()

    $total_to_create_orders_cert = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length
    Write-Host "[#] Total to create: $($total_to_create_orders_cert)" -ForegroundColor Yellow
    $orders_created_orders_cert = 0

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }))
    {
        Process-DevCommands

        $count = 0

        foreach($line in (Get-Content "$($tmp_directory)\$($file)"))
        {
            $count ++

            if($line -eq '')
            {
                #Write-Host "[#] Blank line found at line #$($count) in $($file)." -ForegroundColor Yellow
            }
            else
            {
                #Write-Host "[*] Non-blank line found at line #$($count) in $($file)." -ForegroundColor Green
                $uic = $($line)
                $uic = $uic.ToString()
                $uic = $uic.Split(' ')
                $uic = $uic[-1]
                break
            }
        }

        $name = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name_parse_orders_cert) -AllMatches -List -ErrorAction SilentlyContinue  | Select -First 1 | ConvertFrom-String -PropertyNames SanSSN, LastName, FirstName, MiddleInitial | Select LastName, FirstName, MiddleInitial)
        $last_name = $($name.LastName)
        $first_name = $($name.FirstName)
        $middle_initial = $($name.MiddleInitial)

        $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number_parse_orders_cert) -SimpleMatch -ErrorAction SilentlyContinue | Select -First 1)
        $order_number = $order_number.ToString()
        $order_number = $order_number.Split(' ')
        $order_number = $($order_number[2])
        $order_number = $order_number.Insert(3,"-")

        $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_period_parse_orders_cert) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
        $period = $period | ConvertFrom-String -PropertyNames Period, of, duty:, PeriodFrom, To, PeriodTo | Select PeriodFrom, PeriodTo
        $period_from = $period.PeriodFrom
        $period_from = @($period_from -split '(.{2})' | ? {$_})
        $period_from_year = $period_from[0]
        $period_from_month = $period_from[1]
        #$period_from_month_numerical = $months.GetEnumerator() | ? { $_.Value -eq $($period_from_month) } | % {$_.Key } # Retrieve key from value in months hashtable
        $period_from_day = $period_from[2]

        $period_to = $period.PeriodTo
        $period_to = @($period_to -split '(.{2})' | ? {$_})
        $period_to_year = $period_to[0]
        $period_to_month = $period_to[1]
        #$period_to_month = $months.GetEnumerator() | ? { $_.Value -eq $($period_to_month) } | % {$_.Key } # Retrieve key from value in months hashtable
        $period_to_day = $period_to[2]
        
        $ssn = Get-ChildItem -Path $($uics_directory) -Recurse | Where { $_.Name -like "*___$($order_number)___*$($period_from_year)$($period_from_month)$($period_from_day)___*$($period_to_year)$($period_to_month)$($period_to_day)___*.txt" } | ConvertFrom-String -Delimiter "___" | Select -First 1
        $ssn = $($ssn.P2) # Assumes SSN exists in structure already? May need alternative.
        
        $uic_directory = "$($uics_directory)\$($uic)"
        $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
        $uic_soldier_order_file_name = "$($period_from_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___cert.txt"
        $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)
        
        Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

        $orders_created_orders_cert ++

        Write-Host "[#] Created: $($orders_created_orders_cert)/$($total_to_create_orders_cert)." -ForegroundColor Yellow

        <#
        $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
        $estimated_time = (($($total_to_create) - $($orders_created)) * 0.2 / 60)
        $formatted_estimated_time = [math]::Round($estimated_time,2)
        $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

        Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
        #>
    }
}

function Work-Magic($uic_directory, $soldier_directory, $uic_soldier_order_file_name, $uic_soldier_order_file_content, $uic, $last_name, $first_name, $middle_initial, $ssn)
{
    Process-DevCommands

    if(Test-Path $($uic_directory))
    {
        Write-Host "[*] $($uic_directory) already created, continuing." -ForegroundColor Green
    }
    else
    {
        Write-Host "[#] $($uic_directory) not created. Creating now." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "$($uics_directory)\$($uic)" -ErrorAction SilentlyContinue > $null

        if($?)
        {
            Write-Host "[*] $($uic_directory) created successfully." -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" ([char]7) -ForegroundColor Red
            Write-Host "[!] $($uic_directory) creation failed." ([char]7) -ForegroundColor Red
            throw "[!] $($uic_directory) creation failed."
        }
    }

    if(Test-Path $($soldier_directory))
    {
        Write-Host "[*] $($soldier_directory) already created, continuing." -ForegroundColor Green
    }
    else
    {
        Write-Host "[#] $($soldier_directory) not created. Creating now." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "$($soldier_directory)" -ErrorAction SilentlyContinue > $null

        if($?)
        {
            Write-Host "[*] $($soldier_directory) created successfully." -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)." ([char]7) -ForegroundColor Red
            Write-Host "[!] $($soldier_directory) creation failed." ([char]7) -ForegroundColor Red
            throw "[!] $($soldier_directory) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory)\$($uic_soldier_order_file_name)")
    {
        Write-Host "[*] $($soldier_directory)\$($uic_soldier_order_file_name) already created, continuing." -ForegroundColor Green
    }
    else
    {
        Write-Host "[#] $($soldier_directory)\$($uic_soldier_order_file_name) not created. Creating now." -ForegroundColor Yellow
        New-Item -ItemType File -Path $($soldier_directory) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) -ErrorAction SilentlyContinue > $null

        if($?)
        {
            Write-Host "[*] $($soldier_directory)\$($uic_soldier_order_file_name) created successfully." -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" ([char]7) -ForegroundColor Red
            Write-Host "[!] $($soldier_directory)\$($uic_soldier_order_file_name) creation failed." ([char]7) -ForegroundColor Red
            throw "[!] $($soldier_directory)\$($uic_soldier_order_file_name) creation failed."
        }
    }
}

function Start-CleanUpOrdersMain($tmp_directory, $exclude_directories)
{
    $total_to_clean_orders_main = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length
    Write-Host "[#] Total to clean: $($total_to_clean_orders_main)" -ForegroundColor Yellow
    $orders_clean_orders_main = 0

    # Remove .tmp files permanently
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }) | ? { ($_.Extension) -eq '.mof' })
    {
        Process-DevCommands

        Write-Host "[#] Removing $($file)." -ForegroundColor Yellow
        Remove-Item "$($tmp_directory)\$($file)"

        if($?)
        {
            Write-Host "[*] $($file) removed successfully." -ForegroundColor Green
            $total_to_clean_orders_main ++
        }
        else
        {
            Write-Host "[!] Failed to remove $($file)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($file)."
        }

        Write-Host "[#] Cleaned: $($total_to_clean_orders_main)/$($total_to_clean_orders_main)." -ForegroundColor Yellow
    }
}

function Start-CleanUpOrdersCertificate($tmp_directory, $exclude_directories)
{
    $total_to_clean_orders_cert = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length
    Write-Host "[#] Total to clean: $($total_to_clean_orders_cert)" -ForegroundColor Yellow
    $orders_clean_orders_cert = 0

    # Remove .tmp files permanently
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }) | ? { $_.Extension -eq '.cof' })
    {
        Process-DevCommands

        Write-Host "[#] Removing $($file)." -ForegroundColor Yellow
        Remove-Item "$($tmp_directory)\$($file)"

        if($?)
        {
            Write-Host "[*] $($file) removed successfully." -ForegroundColor Green
            $orders_clean_orders_cert ++
        }
        else
        {
            Write-Host "[!] Failed to remove $($file)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($file)."
        }

        Write-Host "[#] Cleaned: $($orders_clean_orders_cert)/$($total_to_clean_orders_cert)." -ForegroundColor Yellow
    }
}

function Process-DevCommands()
{
    if ([console]::KeyAvailable)
    {
        $key = [system.console]::readkey($true)

        if(($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "P"))
        {
            Write-Host "[-] Pausing at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)." -ForegroundColor White

            Pause

		    Write-Host "[-] Resuming at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)." -ForegroundColor White
        }
        elseif(($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "Q" ))
        {
            $response = Read-Host -Prompt "Are you sure you want to exit? [Y|y / N|n]"
            
            switch($response)
            {
                { @("y", "Y") -contains $_ } { "Terminating at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."; exit 0 }
                { @("n", "N") -contains $_ } { continue }
                default { "Response not determined." }
            }
        }
    }
}

<#
ENTRY POINT
#>

if($h)
{
    cls
    Write-Host ""
    Write-Host "[^] Help parameter specified. Presenting full help now." -ForegroundColor Cyan
    Get-Help .\$($script_name) -Full
}
elseif($dir_create)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Directory creation parameter specified. Creating required directories now." -ForegroundColor Cyan

    try{
        Write-Host "[-] Creating required directories." -ForegroundColor White

        Create-RequiredDirectories -directories $($directories)
        Process-DevCommands
    
        if($?)
        {
            Write-Host "[^] Creating directories finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Directory creation failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($backups)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Backup parameter specified. Creating backups now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Backing up original orders file." -ForegroundColor White

        Move-OriginalToHistorical -files_orders_original $($files_orders_original) -master_history_edited $($master_history_edited) -master_history_unedited $($master_history_unedited)

        if($?)
        {
            Write-Host "[^] Backing up original ordres file finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Backing up original orders failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($split_main)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Split main order file parameter specified. Splitting main order files now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Splitting '*m.prt' order file(s) into individual order files." -ForegroundColor White

        Split-OrdersMain -tmp_directory $($tmp_directory) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)
    
        if($?)
        {
            Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Splitting '*m.prt' order file(s) into individual order files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($split_cert)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Split certificate file parameter specified. Splitting '*c.prt' files now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor White

        Split-OrdersCertificate -tmp_directory $($tmp_directory) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)
    
        if($?)
        {
            Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Splitting '*c.prt' certificate file(s) into individual certificate files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($edit_main)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Edit orders '*m.prt' parameter specified. Editing orders now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Editing orders '*m.prt' files." -ForegroundColor White

        Edit-OrdersMain -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main)

        if($?)
        {
            Write-Host "[^] Editing orders '*m.prt' files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Editing orders '*m.prt' files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($edit_cert)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Edit orders '*c.prt' parameter specified. Editing orders now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Editing orders '*c.prt' files." -ForegroundColor White

        Edit-OrdersCertificate -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert)

        if($?)
        {
            Write-Host "[^] Editing orders '*c.prt' files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Editing orders '*c.prt' files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($combine_main)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Combine .mof orders parameter specified. Combining .mof orders now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Combining .mof orders files." -ForegroundColor White

        Combine-OrdersMain -tmp_directory $($tmp_directory) -run_date $($run_date)

        if($?)
        {
            Write-Host "[^] Combining .mof orders files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Combining .mof orders files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($combine_cert)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Combine .cof orders parameter specified. Combining .cof orders now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Combining .cof orders files." -ForegroundColor White

        Combine-OrdersCertificate -tmp_directory $($tmp_directory) -run_date $($run_date)

        if($?)
        {
            Write-Host "[^] Combining .cof orders files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Combining .cof orders files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($magic_main)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Magic parameter specified. Working magic on .mof files now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Working magic on .mof files now." -ForegroundColor White

        Parse-OrdersMain -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_order_amdend_revoke_parse_orders_main $($regex_order_number_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)

        if($?)
        {
            Write-Host "[^] Magic on .mof finished successfully. Did you expect anything less?" -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Magic on .mof failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($magic_cert)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Magic parameter specified. Working magic on .cof files now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Working magic on .cof files." -ForegroundColor White

        Parse-OrdersCertificate -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories)

        if($?)
        {
            Write-Host "[^] Magic on .cof files finished successfully. Did you expect anything less?" -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Magic on .cof files failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($clean_main)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Clean up parameter specified. Cleaning up .mof files now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Cleaning up .mof files." -ForegroundColor White

        Start-CleanUpOrdersMain -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories)

        if($?)
        {
            Write-Host "[^] Cleaning up .mof finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Cleaning up .mof failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($clean_cert)
{
    # Start logging
    Start-Transcript -Path $($log_path)

    cls
    Write-Host "[^] Clean up parameter specified. Cleaning up .cof files now." -ForegroundColor Cyan

    try {
        Write-Host "[-] Cleaning up .cof files." -ForegroundColor White

        Start-CleanUpOrdersCertificate -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories)

        if($?)
        {
            Write-Host "[^] Cleaning up .cof finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Cleaning up .cof failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
elseif($all)
{
    cls
    Write-Host "[^] Run all parameter specified. Running .\$($script_name) with all required parameters now." -ForegroundColor Cyan

    # Start logging
    Start-Transcript -Path $($log_path)

    try{
        Write-Host "[-] Creating required directories." -ForegroundColor White

        Create-RequiredDirectories -directories $($directories)
        Process-DevCommands
    
        if($?)
        {
            Write-Host "[^] Creating directories finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Directory creation failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Backing up original orders file." -ForegroundColor White

        Move-OriginalToHistorical -files_orders_original $($files_orders_original) -master_history_edited $($master_history_edited) -master_history_unedited $($master_history_unedited)

        if($?)
        {
            Write-Host "[^] Backing up original ordres file finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Backing up original orders failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Splitting '*m.prt' order file(s) into individual order files." -ForegroundColor White

        Split-OrdersMain -tmp_directory $($tmp_directory) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)
    
        if($?)
        {
            Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Splitting '*m.prt' order file(s) into individual order files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor White

        Split-OrdersCertificate -tmp_directory $($tmp_directory) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)
    
        if($?)
        {
            Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Splitting '*c.prt' certificate file(s) into individual certificate files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Editing orders '*m.prt' files." -ForegroundColor White

        Edit-OrdersMain -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main)

        if($?)
        {
            Write-Host "[^] Editing orders '*m.prt' files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Editing orders '*m.prt' files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Editing orders '*c.prt' files." -ForegroundColor White

        Edit-OrdersCertificate -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert)

        if($?)
        {
            Write-Host "[^] Editing orders '*c.prt' files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Editing orders '*c.prt' files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Combining .mof orders files." -ForegroundColor White

        Combine-OrdersMain -tmp_directory $($tmp_directory) -run_date $($run_date)

        if($?)
        {
            Write-Host "[^] Combining .mof orders files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Combining .mof orders files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Combining .cof orders files." -ForegroundColor White

        Combine-OrdersCertificate -tmp_directory $($tmp_directory) -run_date $($run_date)

        if($?)
        {
            Write-Host "[^] Combining .cof orders files finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Combining .cof orders files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Working magic on .mof files now." -ForegroundColor White

        Parse-OrdersMain -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_order_amdend_revoke_parse_orders_main $($regex_order_number_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)

        if($?)
        {
            Write-Host "[^] Magic on .mof finished successfully. Did you expect anything less?" -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Magic on .mof failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Working magic on .cof files." -ForegroundColor White

        Parse-OrdersCertificate -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories)

        if($?)
        {
            Write-Host "[^] Magic on .cof files finished successfully. Did you expect anything less?" -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Magic on .cof files failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Cleaning up .mof files." -ForegroundColor White

        Start-CleanUpOrdersMain -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories)

        if($?)
        {
            Write-Host "[^] Cleaning up .mof finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Cleaning up .mof failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }
	
    try {
        Write-Host "[-] Cleaning up .cof files." -ForegroundColor White

        Start-CleanUpOrdersCertificate -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories)

        if($?)
        {
            Write-Host "[^] Cleaning up .cof finished successfully." -ForegroundColor Cyan
        }
    }
    catch {
        $_ | Out-File -Append $($error_path)
        Write-Host ""
        Write-Host "[!] Cleaning up .cof failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
        Write-Host ""
        exit 1
    }

    # Stop logging
    Stop-Transcript
}
else
{
    cls
    Write-Host "[!] Unknown or incorrect parameter specified." ([char]7) -ForegroundColor Red
    Write-Host "[!] Run command: '.\$($script_name) -h' or 'Get-Help .\$($script_name) -Full' to get detailed help information." ([char]7) -ForegroundColor Red
}