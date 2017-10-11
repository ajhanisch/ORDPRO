<#
.Synopsis
   Script to help automate order management.
.DESCRIPTION
   Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
.PARAMETER h
   Help page. This parameter tells the script you want to learn more about it. It will display this page after running the command 'Get-Help .\ORDPRO.ps1 -Full' for you.
.PARAMETER d
   Directory creation. This parameter tells the script to create the required directories for the script to run. Directories created are ".\MASTER-HISTORY\{EDITED}{NONEDITED}" ".\UICS" ".\TMP".
.PARAMETER b
   Backup original order files. This parameter tells the script to create backups of all files in current directory. Backups all files with ".prt" extension in current directory to ".\MASTER-HISTORY\NONEDITED" directory.
.PARAMETER s
   Split main order files with "*m.prt" name. This parameter tells the script to split the main "*m.prt" file into individual orders. Individual order files are split to ".\TMP\{n}.tmp" files for editing.
.PARAMETER e
   Edit order files. This parameter tells the script to edit the individual ".\TMP\*.tmp" files to be ready to be combined. Editing includes removing unwanted line breaks and multiple FOUO lines and spacing.
.PARAMETER c
   Combine order files. This parameter tells the script to combine the edited order files into a single document to be used by the 
.PARAMETER m
   Magic work. This parameter tells the script to parse the split order files, create directory structure based on parsed data, and put orders in appropriate ".\UICS\UIC\USER" folders.
.PARAMETER z
   Cleanup. This parameter tells the script to cleanup the ".\TMP" directory of all .tmp files.
.PARAMETER a
   All parameters. This parameter tells the script to run all required parameters needed to be successful. Most common parameter to those new to using this script.
.INPUTS
   Script parses all "*m.prt" and "*c.prt" files in current directory.
.OUTPUTS
   Script creates directory structure and invididual order files within each ".\UIC\USER" folder.
.NOTES
   NAME: ORDPRO.ps1 (Order Processing Automation)

   AUTHOR: Ashton J. Hanisch

   VERSION: 0.1

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

            Ashton Hanisch  - (10/6/2017)  [] Progress bar with estimated time. Similar to YASP progress bar notification information.
                            - (10/6/2017)  [] Output summary results of orders parsed.
                            - (10/10/2017) [] Handle all formats not currently handled.
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
# $formats_handled = @("284","700", "705", "296")
# $formats_not_handled = @("172")

<#
HASH TABLES
#>
$months = @{"January" = "01"; "February" = "02"; "March" = "03"; "April" = "04"; "May" = "05"; "June" = "06"; "July" = "07"; "August" = "08"; "September" = "09"; "October" = "10"; "November" = "11"; "December" = "12";}

<#
REGEX MAGIX
#>
$regex_order_number_parse_orders_main = "^ORDERS\s{1}\d{3}-\d{3}"
$regex_name_parse_orders_main = "You are ordered to"
$regex_uic_parse_orders_main = "\(\w{5}-\w{3}\)"
$regex_period_parse_orders_main = "^Period \(\w\w\w\) :"
$regex_format_parse_orders_main = "^Format: \d{3}"
$regex_order_amdend_revoke_parse_orders_main = "^So much of:  Orders \d{6}" # Order being amended or revoked
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
        $orders = [regex]::Match($content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "$($beginning_m)"

        foreach($order in $orders)
        {
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

function Split-OrdersCertificate($tmp_directory, $files_orders_c_prt, $regex_beginning_c_split_orders_cert)
{
    $count = 0

    foreach($file in $files_orders_c_prt)
    {
        $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
        $orders = [regex]::Match($content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "$($regex_end_cert)"

        foreach($order in $orders)
        {
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
$old_fouo_1 = @"

                          FOR OFFICIAL USE ONLY - PRIVACY ACT

                          FOR OFFICIAL USE ONLY - PRIVACY ACT

"@ # FOUO between Marital status and Type of incentive pay
$old_fouo_2 = @"
 
 

                          FOR OFFICIAL USE ONLY - PRIVACY ACT

                          FOR OFFICIAL USE ONLY - PRIVACY ACT

                               


"@ # FOUO at end of each tmp file
$old_fouo_3 = @"
 
 

                          FOR OFFICIAL USE ONLY - PRIVACY ACT
                          FOR OFFICIAL USE ONLY - PRIVACY ACT

                               

"@ # FOUO between 
$old_fouo_4 = @"

                          FOR OFFICIAL USE ONLY - PRIVACY ACT
                          FOR OFFICIAL USE ONLY - PRIVACY ACT


"@
$old_fouo_5 = @"
 
 

                               

"@
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }))
    {
        $file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw -ErrorAction SilentlyContinue)
        $file_content = $file_content -replace $old_header,$new_header
        $file_content = $file_content -replace "`f",''
        $file_content = $file_content -replace $old_fouo_1,''
        $file_content = $file_content -replace $old_fouo_2,''
        $file_content = $file_content -replace $old_fouo_3,''
        $file_content = $file_content -replace $old_fouo_4,''
        $file_content = $file_content -replace $old_fouo_5,''
        $file_content = $file_content -replace $regex_old_fouo_3_edit_orders_main,''
        $file_content = $file_content -replace "`r`n`r`n`r",''

        if(!((Get-Item "$($tmp_directory)\$($file)") -is [System.IO.DirectoryInfo]))
        {
            Write-Host "[#] Editing $($file.Name) now." -ForegroundColor Yellow

            Set-Content -Path "$($tmp_directory)\$($file.Name)" $file_content
            
            if($?)
            {
                Write-Host "[*] $($file.Name) edited successfully." -ForegroundColor Green
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
    }
}

function Edit-OrdersCertificate($tmp_directory, $exclude_directories, $regex_end_cert)
{
$old_header_1 = @"

                          FOR OFFICIAL USE ONLY - PRIVACY ACT

"@
$old_header_2 = @"


                          FOR OFFICIAL USE ONLY - PRIVACY ACT
                          FOR OFFICIAL USE ONLY - PRIVACY ACT

"@
$old_header_3 = @"
                          FOR OFFICIAL USE ONLY - PRIVACY ACT
"@
$old_header_4 = @"



"@

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }))
    {
        $file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw -ErrorAction SilentlyContinue)
        $file_content = $file_content -replace $old_header_1,''
        $file_content = $file_content -replace $old_header_2,''
        $file_content = $file_content -replace $old_header_3,''

        if(!((Get-Item "$($tmp_directory)\$($file)") -is [System.IO.DirectoryInfo]))
        {
            Write-Host "[#] Editing $($file.Name) now." -ForegroundColor Yellow

            Set-Content -Path "$($tmp_directory)\$($file.Name)" $file_content
            Add-Content -Path "$($tmp_directory)\$($file.Name)" -Value $($regex_end_cert)

            if($?)
            {
                Write-Host "[*] $($file.Name) edited successfully." -ForegroundColor Green
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
    }
}

function Combine-OrdersMain($tmp_directory, $run_date)
{
    $out_file = "$($tmp_directory)\$($run_date)_m_combined_orders.txt"

    Write-Host "[#] Combining .mof files now" -ForegroundColor Yellow

    Get-ChildItem -Path $($tmp_directory) -Recurse | ? { ! $_.PSIsContainer } | ? { $_.Extension -eq '.mof' } | % { Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append }

    if($?)
    {
        Write-Host "[*] Combined .mof files successfully." -ForegroundColor Green
        Write-Host "[*] Check your results at $($out_file)" -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] Combining .mof files failed." ([char]7) -ForegroundColor Red
        throw "[!] Combining .mof files failed."
    }
}

function Combine-OrdersCertificate($tmp_directory, $run_date)
{
    $out_file = "$($tmp_directory)\$($run_date)_c_combined_orders.txt"

    Write-Host "[#] Combining .cof files now" -ForegroundColor Yellow

    Get-ChildItem -Path $($tmp_directory) -Recurse | ? { ! $_.PSIsContainer } | ? { $_.Extension -eq '.cof' } | % { Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append }

    if($?)
    {
        Write-Host "[*] Combined .cof files successfully." -ForegroundColor Green
        Write-Host "[*] Check your results at $($out_file)" -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] Combining .cof files failed." ([char]7) -ForegroundColor Red
        throw "[!] Combining .cof files failed."
    }
}

function Parse-OrdersMain($tmp_directory, $exclude_directories, $regex_format_parse_orders_main, $regex_order_number_parse_orders_main, $regex_uic_parse_orders_main, $regex_order_amdend_revoke_parse_orders_main, $regex_pertaining_to_parse_orders_main)
{
    $stop_watch = [system.diagnostics.stopwatch]::startNew()

    $total_to_create = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length
    Write-Host "[#] Total to create: $($total_to_create)" -ForegroundColor Yellow
    $orders_created = 0

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }))
    {
        $format = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_format_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue)
        $format = $format | ConvertFrom-String -PropertyNames Format, FormatNumber, Asterisks | Select FormatNumber
        $format = $($format.FormatNumber)

        if($($format) -eq "700") # 700 Amend
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue)
            $order_number = $order_number | ConvertFrom-String -PropertyNames Orders, OrderNumber, PublishedDay, PublishedMonth, PublishedYear | Select OrderNumber, PublishedDay, PublishedMonth, PublishedYear
            $order_number_amend = $($order_number.OrderNumber)
            $published_day_amend = $($order_number.PublishedDay)
            $published_month_amend = $($order_number.PublishedMonth)
            $published_year_amend = $($order_number.PublishedYear)
            $published_year_amend = @($published_year_amend -split '(.{2})' | ? {$_})
            $published_year_amend = $published_year_amend[1] # 2017 turned into 17
            
            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $order_amended = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_amdend_revoke_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue)
            $order_amended = $order_amended | ConvertFrom-String -PropertyNames So, Much, Of, Orders, AmendOrdersNumber | Select AmendOrdersNumber
            $order_amended = $($order_amended.AmendOrdersNumber)
            $order_amended = $order_amended.ToString()
            $order_amended = $order_amended.Insert(3,"-")

            $pertaining_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3)
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
            $uic_soldier_order_file_name = "$($published_year_amend)___$($ssn)___$($order_number_amend)___$($order_amended)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created ++

            Write-Host "[#] Created: $($orders_created)." -ForegroundColor Yellow

            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($documents_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)

        }
        elseif($($format) -eq "705") # 705 Revoke
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue)
            $order_number = $order_number | ConvertFrom-String -PropertyNames Orders, OrderNumber, PublishedDay, PublishedMonth, PublishedYear | Select OrderNumber, PublishedDay, PublishedMonth, PublishedYear
            $order_number_revoke = $($order_number.OrderNumber)
            $published_day_revoke = $($order_number.PublishedDay)
            $published_month_revoke = $($order_number.PublishedMonth)
            $published_year_revoke = $($order_number.PublishedYear)
            $published_year_revoke = @($published_year_revoke -split '(.{2})' | ? {$_})
            $published_year_amend = $published_year_revoke[1] # 2017 turned into 17

            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $order_revoke = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_amdend_revoke_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue)
            $order_revoke = $order_revoke | ConvertFrom-String -PropertyNames So, Much, Of, Orders, RevokeOrdersNumber | Select RevokeOrdersNumber
            $order_revoke = $($order_revoke.RevokeOrdersNumber)
            $order_revoke = $order_revoke.ToString()
            $order_revoke = $order_revoke.Insert(3,"-")

            $pertaining_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3)
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
            $uic_soldier_order_file_name = "$($published_year_revoke)___$($ssn)___$($order_number_revoke)___$($order_revoke)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created ++

            Write-Host "[#] Created: $($orders_created)." -ForegroundColor Yellow

            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($documents_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)

        }
        elseif($($format) -eq '172')
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan
            Write-Host "[+] Format ($format) not currently handled, skipping." -ForegroundColor Cyan
            continue
        }
        elseif($($format) -eq '282' -and $($problem_282_exists))
        {
            Write-Host "[+] Found format $($format) formatted differently than other $($format)'s in $($file)!" -ForegroundColor Cyan
            Write-Host "[+] Format $($format) not currently handled, skipping." -ForegroundColor Cyan
        }
        else
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue)
            $order_number = $order_number | ConvertFrom-String -PropertyNames Orders, OrderNumber, PublishedDay, PublishedMonth, PublishedYear | Select OrderNumber, PublishedDay, PublishedMonth, PublishedYear
            $order_number_others = $($order_number.OrderNumber)
            $published_day_others = $($order_number.PublishedDay)
            $published_month_others = $($order_number.PublishedMonth)
            $published_year_others = $($order_number.PublishedYear)
            $published_year_others = @($published_year_others -split '(.{2})' | ? {$_})
            $published_year_others = $published_year_others[1] # 2017 turned into 17

            $anchor = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue)
            $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

            # Code to fix people that have no middle name.
            if($($anchor.MiddleInitial).Length -ne 1)
            {
                $anchor.SSN = $anchor.MiddleInitial
                $anchor.MiddleInitial = 'X'
            }

            $last_name = $($anchor.LastName)
            $last_name = $last_name.Split(':')[-1]
            $first_name = $($anchor.FirstName)
            $middle_initial = $($anchor.MiddleInitial)
            $ssn = $($anchor.SSN)
        
            $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | ConvertFrom-String -PropertyNames Period, Status, Colon, FromDay, FromMonth, FromYear, Dash, ToDay, ToMonth, ToYear | Select Status, FromDay, FromMonth, FromYear, ToDay, ToMonth, ToYear)
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
            $uic_soldier_order_file_name = "$($published_year_others)___$($ssn)___$($order_number_others)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

            $orders_created ++

            Write-Host "[#] Created: $($orders_created)." -ForegroundColor Yellow

            $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
            $estimated_time = (($($total_to_create) - $($documents_created)) * 0.1 / 60)
            $formatted_estimated_time = [math]::Round($estimated_time,2)
            $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

            Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
        }
    }
}

function Parse-OrdersCertificate($tmp_directory, $exclude_directories)
{
    $stop_watch = [system.diagnostics.stopwatch]::startNew()

    $total_to_create = (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length
    Write-Host "[#] Total to create: $($total_to_create)" -ForegroundColor Yellow
    $orders_created = 0

    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }))
    {
        $count = 0

        foreach($line in (Get-Content "$($tmp_directory)\$($file)"))
        {
            $count ++

            if($line -eq '')
            {
                Write-Host "[#] Blank line found at line #$($count) in $($file)." -ForegroundColor Yellow
            }
            else
            {
                Write-Host "[*] Non-blank line found at line #$($count) in $($file)." -ForegroundColor Green
                $uic = $($line)
                $uic = $uic.ToString()
                $uic = $uic.Split(' ')
                $uic = $uic[-1]
                break
            }
        }

        $name = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name_parse_orders_cert) -AllMatches -List -ErrorAction SilentlyContinue | ConvertFrom-String -PropertyNames SanSSN, LastName, FirstName, MiddleInitial | Select LastName, FirstName, MiddleInitial)
        $last_name = $($name.LastName)
        $first_name = $($name.FirstName)
        $middle_initial = $($name.MiddleInitial)

        $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number_parse_orders_cert) -SimpleMatch -ErrorAction SilentlyContinue)
        $order_number = $order_number.ToString()
        $order_number = $order_number.Split(' ')
        $order_number = $($order_number[2])
        $order_number = $order_number.Insert(3,"-")

        $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_period_parse_orders_cert) -AllMatches -ErrorAction SilentlyContinue)
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
        
        $ssn = Get-ChildItem -Path $($uics_directory) -Recurse | Where { $_.Name -like "*___$($order_number)___*$($period_from_year)$($period_from_month)$($period_from_day)___*$($period_to_year)$($period_to_month)$($period_to_day)___*.txt" } | ConvertFrom-String -Delimiter "___"
        $ssn = $($ssn.P2) # Assumes SSN exists in structure already? May need alternative.
        
        $uic_directory = "$($uics_directory)\$($uic)"
        $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
        $uic_soldier_order_file_name = "$($period_from_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___cert.txt"
        $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)
        
        Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

        $orders_created ++

        Write-Host "[#] Created: $($orders_created)." -ForegroundColor Yellow

        $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
        $estimated_time = (($($total_to_create) - $($documents_created)) * 0.1 / 60)
        $formatted_estimated_time = [math]::Round($estimated_time,2)
        $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

        Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
    }
}

function Work-Magic($uic_directory, $soldier_directory, $uic_soldier_order_file_name, $uic_soldier_order_file_content, $uic, $last_name, $first_name, $middle_initial, $ssn)
{
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
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" ([char]7) -ForegroundColor Red
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
    # Remove .tmp files permanently
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }) | ? { ($_.Extension) -eq '.mof' })
    {
        Write-Host "[#] Removing $($file)." -ForegroundColor Yellow
        Remove-Item "$($tmp_directory)\$($file)"

        if($?)
        {
            Write-Host "[*] $($file) removed successfully." -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] Failed to remove $($file)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($file)."
        }
    }
}

function Start-CleanUpOrdersCertificate($tmp_directory, $exclude_directories)
{
    # Remove .tmp files permanently
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }) | ? { $_.Extension -eq '.cof' })
    {
        Write-Host "[#] Removing $($file)." -ForegroundColor Yellow
        Remove-Item "$($tmp_directory)\$($file)"

        if($?)
        {
            Write-Host "[*] $($file) removed successfully." -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] Failed to remove $($file)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($file)."
        }
    }
}

# Output summary results of parsing? Send summary results of parsing?

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

        Split-OrdersCertificate -tmp_directory $($tmp_directory) -files_orders_c_prt $($files_orders_c_prt) -regex_beginning_c_split_orders_cert $($regex_beginning_c_split_orders_cert)
    
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

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' })
    {
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
            Write-Host "[!] Splitting '*m.prt' order file(s) into individual order files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }
    
    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' })
    {
        try {
            Write-Host "[-] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor White

            Split-OrdersCertificate -tmp_directory $($tmp_directory) -files_orders_c_prt $($files_orders_c_prt) -regex_beginning_c_split_orders_cert $($regex_beginning_c_split_orders_cert)
    
            if($?)
            {
                Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished successfully." -ForegroundColor Cyan
            }
        }
        catch {
            $_ | Out-File -Append $($error_path)
            Write-Host ""
            Write-Host "[!] Splitting '*c.prt' certificate file(s) into individual certificate files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }  
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' })
    {
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
            Write-Host "[!] Editing orders '*m.prt' files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' })
    {
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
            Write-Host "[!] Editing orders '*c.prt' files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' })
    {
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
            Write-Host "[!] Combining .mof orders files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' })
    {
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
            Write-Host "[!] Combining .cof orders files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' })
    {
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
            Write-Host "[!] Magic on .mof failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' })
    {
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
            Write-Host "[!] Magic on .cof files failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' })
    {
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
            Write-Host "[!] Cleaning up .mof failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
    }

    if(Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' })
    {
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
            Write-Host "[!] Cleaning up .cof failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7) -ForegroundColor Red
            Write-Host ""
            exit 1
        }
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