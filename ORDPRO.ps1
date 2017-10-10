<#
.Synopsis
   Script to help automate order management.
.DESCRIPTION
   Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
.PARAMETER h
    Help page. This parameter tells the script you want to learn more about it. It will display this page after running the command 'Get-Help .\ORDPRO.ps1 -Full' for you.
.INPUTS
   Script parses all .doc files in current directory.
.OUTPUTS
   
.NOTES
   NAME: ORDPRO.ps1 (Order Processing Automation)

   AUTHOR: Ashton J. Hanisch

   VERSION: 0.1

   TROUBLESHOOTING: All script output will be in .\tmp\logs folder. Should you have any problems script use, email ajhanisch@gmail.com with a description of your issue and the log file that is associated with your problem.

   SUPPORT: For any issues, comments, concerns, ideas, contributions, etc. to any part of this script or its functionality, reach out to me at ajhanisch@gmail.com. I am open to any thoughts you may have to make this work better for you or things you think are broken or need to be different. I will ensure to give credit where credit is due for any contributions or improvement ideas that are shared with me in the "Credits and Acknowledgements" section in the README.txt file.

   UPDATES: To check out any updates or revisions made to this script check out the updated README.txt included with this script.
   
   WISHLIST: 
            Warren Hofmann  - 

            Ryan Mattfield  - (10/5/2017) [] Email group(s)/UIC(s) with required access UNC links to new orders published in their persepective folder
                            - (10/5/2017) [] Shortcuts to SSN's rather than duplicating data in G1 master folder
                            - (10/6/2017) [] Web page serving root directory structure to access orders

            Joshua Schaefer - (10/4/2017) [] Reformat all orders processed and combine into single file to upload to iperms more easily

            Ashton Hanisch  - (10/6/2017) [] Progress bar with estimated time. Similar to YASP progress bar notification information.
                            - (10/6/2017) [] Output summary results of orders parsed.
#>

<#
DIRECTORIES
#>
$current_directory = (Get-Item -Path ".\" -Verbose).FullName
$master_history_edited = "$($current_directory)\MASTER-HISTORY\EDITED"
$master_history_unedited = "$($current_directory)\MASTER-HISTORY\UNEDITED"
$uics_directory = "$($current_directory)\UICS"
$tmp_directory = "$($current_directory)\TMP"

<#
ARRAYS
#>
$directories = @("$($master_history_edited)","$($master_history_unedited)","$($uics_directory)","$($tmp_directory)")

<#
HASH TABLES
#>
$months = @{"January" = "01"; "February" = "02"; "March" = "03"; "April" = "04"; "May" = "05"; "June" = "06"; "July" = "07"; "August" = "08"; "September" = "09"; "October" = "10"; "November" = "11"; "December" = "12";}

<#
REGEX MAGIX
#>
$regex_order_number = "^ORDERS\s{1}\d{3}-\d{3}"
$regex_name = "You are ordered to"
$regex_uic = "\(\w{5}-\w{3}\)"
$regex_period = "^Period \(\w\w\w\) :"
$regex_format = "^Format: \d{3}"
$regex_order_amdend_revoke = "^So much of:  Orders \d{6}" # Order being amended or revoked
$regex_pertaining_to = "^Pertaining to:" # To find "Pertaining to:" line in revoke order to capture name, SSN, UIC
$regex_old_fouo_3 = "ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}"

<#
VARIABLES NEEDED
#>
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$log_path = "$($tmp_directory)\logs\$($run_date).log"
$error_path = "$($tmp_directory)\logs\$($run_date)_errors.log"
$script_name = $($MyInvocation.MyCommand.Name)
$exclude_directories = '$($master_history_edited)|$($master_history_unedited)'
$files_orders_original = Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq ".doc" -or $_.Extension -eq ".prt"}
$beginning = "STATE OF SOUTH DAKOTA"
$end = "The Adjutant General"

<#
FUNCTIONS
#>
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
                Write-Host "[!] $($directory) creation failed." -ForegroundColor Red
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
                Write-Host "[!] $($file.BaseName) move to $($master_history_unedited) failed." -ForegroundColor Red
                throw "[!] $($file.BaseName) move to $($master_history_unedited) failed."
            }
        }
    }
}

function Split-MainOrderFile($files_orders_original, $beginning, $tmp_directory)
{
    $count = 0

    foreach($file in $files_orders_original)
    {
        $content = Get-Content $($file) -ErrorAction SilentlyContinue | Out-String
        $orders = [regex]::Match($content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "$($beginning)"

        foreach($order in $orders)
        {
            if($order)
            {
                $count ++

                Write-Host "[#] Processing order #$($count) now." -ForegroundColor Yellow
                #$order >> "$($tmp_directory)\$($file.BaseName).txt" ## 1,120 KB same name as original .doc file containing edited orders
                $order >> "$($tmp_directory)\$($count).tmp"

                if($?)
                {
                    Write-Host "[*] Order #$($count) tmp file created successfully." -ForegroundColor Green
                }
                else
                {
                    Write-Host "[!] Order #$($count) tmp file creation failed." -ForegroundColor Red
                    throw "[!] Order #$($count) tmp file creation failed." 
                }
            }
        }
    }
}

function Edit-Orders($tmp_directory, $exclude_directories, $regex_old_fouo_3)
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
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }))
    {
        $file_content = Get-Content "$($tmp_directory)\$($file)" -Raw -ErrorAction SilentlyContinue
        $file_content = $file_content -replace $old_header,$new_header
        $file_content = $file_content -replace "`f",''
        $file_content = $file_content -replace $old_fouo_1,''
        $file_content = $file_content -replace $old_fouo_2,''
        $file_content = $file_content -replace $old_fouo_3,''
        $file_content = $file_content -replace $old_fouo_4,''
        $file_content = $file_content -replace $old_fouo_5,''
        $file_content = $file_content -replace $regex_old_fouo_3,''
        $file_content = $file_content -replace "`r`n`r`n`r",''


        if(!((Get-Item "$($tmp_directory)\$($file)") -is [System.IO.DirectoryInfo]))
        {
            Set-Content -Path "$($tmp_directory)\$($file.Name)" $file_content
        }
        else
        {
            Write-Host "[#] $($file) is a directory. Skipping." -ForegroundColor Yellow
        }
    }
}

function Parse-TmpFiles($regex_format, $regex_order_number, $regex_uic, $regex_order_amdend_revoke, $regex_pertaining_to)
{
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }) | ? { ($_.Name).Contains(".tmp") })
    {
        $format = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_format) -AllMatches -ErrorAction SilentlyContinue)
        $format = $format | ConvertFrom-String -PropertyNames Format, FormatNumber, Asterisks | Select FormatNumber
        $format = $($format.FormatNumber)

        if($($format) -eq "700") # 700 Amend
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number) -AllMatches -ErrorAction SilentlyContinue)
            $order_number = $order_number | ConvertFrom-String -PropertyNames Orders, OrderNumber, PublishedDay, PublishedMonth, PublishedYear | Select OrderNumber, PublishedDay, PublishedMonth, PublishedYear
            $order_number_amend = $($order_number.OrderNumber)
            $published_day_amend = $($order_number.PublishedDay)
            $published_month_amend = $($order_number.PublishedMonth)
            $published_year_amend = $($order_number.PublishedYear)
            
            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $order_amended = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_amdend_revoke) -AllMatches -ErrorAction SilentlyContinue)
            $order_amended = $order_amended | ConvertFrom-String -PropertyNames So, Much, Of, Orders, AmendOrdersNumber | Select AmendOrdersNumber
            $order_amended = $($order_amended.AmendOrdersNumber)
            $order_amended = $order_amended.ToString()
            $order_amended = $order_amended.Insert(3,"-")

            $pertaining_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_pertaining_to) -AllMatches -Context 0,3)
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

        }
        elseif($($format) -eq "705") # 705 Revoke
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number) -AllMatches -ErrorAction SilentlyContinue)
            $order_number = $order_number | ConvertFrom-String -PropertyNames Orders, OrderNumber, PublishedDay, PublishedMonth, PublishedYear | Select OrderNumber, PublishedDay, PublishedMonth, PublishedYear
            $order_number_revoke = $($order_number.OrderNumber)
            $published_day_revoke = $($order_number.PublishedDay)
            $published_month_revoke = $($order_number.PublishedMonth)
            $published_year_revoke = $($order_number.PublishedYear)

            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $order_revoke = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_amdend_revoke) -AllMatches -ErrorAction SilentlyContinue)
            $order_revoke = $order_revoke | ConvertFrom-String -PropertyNames So, Much, Of, Orders, RevokeOrdersNumber | Select RevokeOrdersNumber
            $order_revoke = $($order_revoke.RevokeOrdersNumber)
            $order_revoke = $order_revoke.ToString()
            $order_revoke = $order_revoke.Insert(3,"-")

            $pertaining_to = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_pertaining_to) -AllMatches -Context 0,3)
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

        }
        else # Format eq 296 // 282 // 284 (PCS)
        {
            Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

            $order_number = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_order_number) -AllMatches -ErrorAction SilentlyContinue)
            $order_number = $order_number | ConvertFrom-String -PropertyNames Orders, OrderNumber, PublishedDay, PublishedMonth, PublishedYear | Select OrderNumber, PublishedDay, PublishedMonth, PublishedYear
            $order_number_others = $($order_number.OrderNumber)
            $published_day_others = $($order_number.PublishedDay)
            $published_month_others = $($order_number.PublishedMonth)
            $published_year_others = $($order_number.PublishedYear)

            $anchor = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_name) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue)
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
        
            $period = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_period) -AllMatches -ErrorAction SilentlyContinue)
            $period = $period | ConvertFrom-String -PropertyNames Period, Status, Colon, FromDay, FromMonth, FromYear, Dash, ToDay, ToMonth, ToYear | Select Status, FromDay, FromMonth, FromYear, ToDay, ToMonth, ToYear
            $period_status = $($period.Status)
            $period_from_day = $($period.FromDay)
            $period_from_month = $($period.FromMonth)
            $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
            $period_from_year = $($period.FromYear)
            $period_to_day = $($period.ToDay)
            $period_to_month = $($period.ToMonth)
            $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
            $period_to_year = $($period.ToYear)
        
            $uic = (Select-String -Path "$($tmp_directory)\$($file)" -Pattern $($regex_uic) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
            $uic = $uic.Split("-")
            $uic = $($uic[0])

            $uic_directory = "$($uics_directory)\$($uic)"
            $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
            $uic_soldier_order_file_name = "$($published_year_others)___$($ssn)___$($order_number_others)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
            $uic_soldier_order_file_content = (Get-Content "$($tmp_directory)\$($file)" -Raw)

            Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)
        }
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
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" -ForegroundColor Red
            Write-Host "[!] $($uic_directory) creation failed." -ForegroundColor Red
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
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" -ForegroundColor Red
            Write-Host "[!] $($soldier_directory) creation failed." -ForegroundColor Red
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
            Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" -ForegroundColor Red
            Write-Host "[!] $($soldier_directory)\$($uic_soldier_order_file_name) creation failed." -ForegroundColor Red
            throw "[!] $($soldier_directory)\$($uic_soldier_order_file_name) creation failed."
        }
    }
}
function Start-CleanUp()
{
    # Remove .tmp files permanently
    foreach($file in (Get-ChildItem -Path $tmp_directory | Where { $_.FullName -notmatch $exclude_directories }) | ? { ($_.Extension) -eq ".tmp" })
    {
        Write-Host "[#] Removing $($file)." -ForegroundColor Yellow
        Remove-Item "$($tmp_directory)\$($file)"

        if($?)
        {
            Write-Host "[*] $($file) removed successfully." -ForegroundColor Green
        }
        else
        {
            Write-Host "[!] Failed to remove $($file)." -ForegroundColor Red
            throw "[!] Failed to remove $($file)."
        }
    }
}

# Output summary results of parsing? Send summary results of parsing?

<#
ENTRY POINT
#>

# Start logging
Start-Transcript -Path $($log_path)

try{
    Write-Host "[-] Creating required directories." -ForegroundColor White

    Create-RequiredDirectories -directories $($directories)
    
    if($?)
    {
        Write-Host "[*] Creating directories finished successfully." -ForegroundColor Green
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
        Write-Host "[*] Backing up original ordres file finished successfully." -ForegroundColor Green
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
    Write-Host "[-] Splitting main order file(s) into individual order files." -ForegroundColor White

    Split-MainOrderFile -files_orders_original $($files_orders_original) -beginning $($beginning) -tmp_directory $($tmp_directory)
    
    if($?)
    {
        Write-Host "[*] Splitting main order file(s) into individual order files finished successfully." -ForegroundColor Green
    }
}
catch {
    $_ | Out-File -Append $($error_path)
    Write-Host ""
    Write-Host "[!] Splitting main order file(s) into individual order files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
    Write-Host ""
    exit 1
}

try {
    Write-Host "[-] Editing order files." -ForegroundColor White

    Edit-Orders -tmp_directory $($tmp_directory) -exclude_directories $($exclude_directories) -regex_old_fouo_3 $($regex_old_fouo_3)

    if($?)
    {
        Write-Host "[*] Editing order files finished successfully." -ForegroundColor Green
    }
}
catch {
    $_ | Out-File -Append $($error_path)
    Write-Host ""
    Write-Host "[!] Editing order files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
    Write-Host ""
    exit 1
}

try {
    Write-Host "[-] Combining order files." -ForegroundColor White

    Get-ChildItem -Path $($tmp_directory) -Recurse | ? { ! $_.PSIsContainer } | ? { ($_.Name).Contains(".tmp") } | % { Out-File -FilePath "$($tmp_directory)\$($run_date)_combined_orders.txt" -InputObject (Get-Content $_.FullName) -Append }

    if($?)
    {
        Write-Host "[*] Combining order files finished successfully." -ForegroundColor Green
    }
}
catch {
    $_ | Out-File -Append $($error_path)
    Write-Host ""
    Write-Host "[!] Combining order files failed. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
    Write-Host ""
    exit 1
}

try {
    Write-Host "[-] Working magic." -ForegroundColor White

    Parse-TmpFiles -regex_format $($regex_format) -regex_order_number $($regex_order_number) -regex_uic $($regex_uic) -regex_order_amdend_revoke $($regex_order_amdend_revoke) -regex_pertaining_to $($regex_pertaining_to)
}
catch {
    $_ | Out-File -Append $($error_path)
    Write-Host ""
    Write-Host "[!] Magic failed?! Impossible. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
    Write-Host ""
    exit 1
}

try {
    Write-Host "[*] Cleaning up." -ForegroundColor Green

    #Start-CleanUp

    if($?)
    {
        Write-Host "[*] Cleaning up finished successfully." -ForegroundColor Green
    }
}
catch {
    $_ | Out-File -Append $($error_path)
    Write-Host ""
    Write-Host "[!] Clean up. Check the error logs at $($tmp_directory)\$($run_date)_errors.log." ([char]7)  -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Stop logging
Stop-Transcript

