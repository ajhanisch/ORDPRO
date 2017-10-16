<#
.Synopsis
   Script to help automate order management.
.DESCRIPTION
   Script designed to assist in management and processing of orders given in the format of a single file containing numerous orders. The script begins by splitting each order into individual orders. It determines what folders need to be created based on UIC and SSN information parsed from each order. It creates folders for each UIC and SSN and places orders in appropriate SSN folder. During this time it also creates historical backups of each order parsed for back and redundancy. After this it will assign permissions to appropiate groups on each UIC and SSN folder. When it has finished this and cleaned up, it will notify appropriate users and groups of newly published orders.
.PARAMETER help
   Help page. Alias: 'h'. This parameter tells the script you want to learn more about it. It will display this page after running the command 'Get-Help .\ORDPRO.ps1 -Full' for you.
.PARAMETER version
   Version information. Alias: 'v'. This parameter tells the script you want to check its version number.
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
param(
    [cmdletbinding()]

    [alias('h')]
    [switch]$help
    ,
    [alias('v')]
    [switch]$version
    ,
    [alias('d')]
    [switch]$dir_create
    ,
    [alias('b')]
    [switch]$backups
    ,
    [alias('sm')]
    [switch]$split_main
    ,
    [alias('sc')]
    [switch]$split_cert
    ,
    [alias('em')]
    [switch]$edit_main
    ,
    [alias('ec')]
    [switch]$edit_cert
    ,
    [alias('cm')]
    [switch]$combine_main
    ,
    [alias('cc')]
    [switch]$combine_cert
    ,
    [alias('mm')]
    [switch]$magic_main
    ,
    [alias('mc')]
    [switch]$magic_cert
    ,
    [alias('xm')]
    [switch]$clean_main
    ,
    [alias('xc')]
    [switch]$clean_cert
    ,
    [alias('xu')]
    [switch]$clean_uics
    ,
    [alias('p')]
    [switch]$permissions
    ,
    [alias('a')]
    [switch]$all
)

<#
DIRECTORIES
#>
$current_directory = (Get-Item -Path ".\" -Verbose).FullName
$uics_directory = "$($current_directory)\UICS"
$permissions_directory = "$($uics_directory)\__PERMISSIONS"
$tmp_directory = "$($current_directory)\TMP"
$master_history_edited = "$($current_directory)\MASTER-HISTORY\EDITED"
$master_history_unedited = "$($current_directory)\MASTER-HISTORY\UNEDITED"
$mof_directory = "$($tmp_directory)\__MOF"
$mof_directory_original_splits = "$($mof_directory)\__ORIGINALSPLITS"
$cof_directory = "$($tmp_directory)\__COF"
$cof_directory_original_splits = "$($cof_directory)\__ORIGINALSPLITS"
$log_directory = "$($tmp_directory)\___LOGS"

<#
ARRAYS
#>
$directories = @("$($uics_directory)","$($tmp_directory)", "$($master_history_edited)","$($master_history_unedited)", "$($mof_directory)", "$($cof_directory)", "$($log_directory)", "$($mof_directory_original_splits)", "$($cof_directory_original_splits)", $($permissions_directory))

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
$version_info = "0.7"
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$script_name = $($MyInvocation.MyCommand.Name)
$year_prefix = (Get-Date -Format yyyy).Substring(0,2)
$exclude_directories = '$($master_history_edited)|$($master_history_unedited)|$($mof_directory_original_splits)|$($cof_directory_original_splits)'
$files_orders_original = (Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq ".prt" })
$files_orders_m_prt = (Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.FullName -like "*m.prt" })
$files_orders_c_prt = (Get-ChildItem -Path $current_directory | Where { $_.FullName -notmatch $exclude_directories -and $_.FullName -like "*c.prt" })

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
function Create-RequiredDirectories($directories)
{
    foreach($directory in $directories)
    {
        Process-DevCommands

        if(!(Test-Path $($directory)))
        {
            Write-Host "[#] $($directory) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $($directory) > $null

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

function Move-OriginalToHistorical($current_directory, $files_orders_original, $master_history_edited, $master_history_unedited)
{
    if(Get-ChildItem -Path $current_directory | Where { $_.Extension -eq '.prt' })
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
    else
    {
        Write-Host "[!] No .prt files in $($current_directory). Come back with proper input next time." ([char]7) -ForegroundColor Red
        throw "[!] No .prt files in $($current_directory). Come back with proper input next time."
    }
}

function Split-OrdersMain($current_directory, $mof_directory, $run_date, $files_orders_m_prt, $regex_beginning_m_split_orders_main)
{
    $total_to_parse_orders_main_files = ($($files_orders_m_prt)).Length

    if($total_to_parse_orders_main_files -gt '0')
    {
        $count_files = 0
        $count_orders = 0

        $out_directory = "$($mof_directory)"

        if(!(Test-Path $($out_directory)))
        {
            Write-Host "[#] $($out_directory) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Host "[*] $($out_directory) created successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] $($out_directory) creation failed." ([char]7) -ForegroundColor Red
                throw "[!] $($out_directory) creation failed."
            }
        }

        foreach($file in $files_orders_m_prt)
        {
            $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
            $orders = [regex]::Match($content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "$($regex_beginning_m_split_orders_main)"
            $count_files ++

            Write-Host "[#] Parsing $($file) ($($count_files)/$($total_to_parse_orders_main_files)) now." -ForegroundColor Yellow

            foreach($order in $orders)
            {
                Process-DevCommands

                if($order)
                {
                    $count_orders ++

                    $out_file = "$($run_date)_$($count_orders).mof"

                    Write-Host "[#] Processing $($out_file) now." -ForegroundColor Yellow

                    New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

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

            Write-Host "[*] $($file) ($($count_files)/$($total_to_parse_orders_main_files)) parsed successfully." -ForegroundColor Green
        }   
    }
    else
    {
        Write-Host "[!] No *m.prt files in $($current_directory). Come back with proper input next time." ([char]7) -ForegroundColor Red
        throw "[!] No *m.prt files in $($current_directory). Come back with proper input next time."
    }
}

function Split-OrdersCertificate($current_directory, $cof_directory, $run_date, $files_orders_c_prt, $regex_end_cert)
{
    $total_to_parse_orders_cert_files = ($($files_orders_c_prt)).Length

    if($total_to_parse_orders_cert_files -gt '0')
    {
        $count_files = 0
        $count_orders = 0

        $out_directory = "$($cof_directory)"

        if(!(Test-Path $($out_directory)))
        {
            Write-Host "[#] $($out_directory) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Host "[*] $($out_directory) created successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] $($out_directory) creation failed." ([char]7) -ForegroundColor Red
                throw "[!] $($out_directory) creation failed."
            }
        }

        foreach($file in $files_orders_c_prt)
        {
            $content = (Get-Content $($file) -ErrorAction SilentlyContinue | Out-String)
            $orders = [regex]::Match($content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "$($regex_end_cert)"
            $count_files ++

            Write-Host "[#] Parsing $($file) ($($count_files)/$($total_to_parse_orders_cert_files)) now." -ForegroundColor Yellow

            foreach($order in $orders)
            {
                Process-DevCommands

                if($order)
                {
                    $count_orders ++

                    $out_file = "$($run_date)_$($count_orders).cof"

                    Write-Host "[#] Processing $($out_file) now." -ForegroundColor Yellow

                    New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

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

            Write-Host "[*] $($file) ($($count_files)/$($total_to_parse_orders_cert_files)) parsed successfully." -ForegroundColor Green
        }
    }
    else
    {
        Write-Host "[!] No *c.prt files in $($current_directory). Come back with proper input next time." ([char]7) -ForegroundColor Red
        throw "[!] No *c.prt files in $($current_directory). Come back with proper input next time."
    }
}

function Edit-OrdersMain($mof_directory, $exclude_directories, $regex_old_fouo_3_edit_orders_main, $mof_directory_original_splits)
{
    $total_to_edit_orders_main = (Get-ChildItem -Path "$($mof_directory)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length

    if($($total_to_edit_orders_main) -gt '0')
    {
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
$old_spacing_1 = @"

                          
                          


"@ # Spacing between APC DJMS-RC: and APC STANFINS Pay: created after removing FOUO's and others below
$old_spacing_2 = @"

                          
                          



"@ # Spacing between last line of Additional Instructions and FOR ARMY USE caused by removing FOUO and ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4} below

        foreach($file in (Get-ChildItem -Path "$($mof_directory)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof'}))
        {
            Process-DevCommands

            $file_content = (Get-Content "$($file)" -Raw -ErrorAction SilentlyContinue)
            $file_content = $file_content -replace $old_header,$new_header
            $file_content = $file_content -replace "`f",''
            $file_content = $file_content -replace "FOR OFFICIAL USE ONLY - PRIVACY ACT",''
            $file_content = $file_content -replace $regex_old_fouo_3_edit_orders_main,''
            $file_content = $file_content -replace "`n$old_spacing_1",''
            $file_content = $file_content -replace "$old_spacing_2",''

           if(!((Get-Item "$($file)") -is [System.IO.DirectoryInfo]))
            {
                $out_file_name = "$($file.BaseName)_edited.mof"

                Write-Host "[#] Editing $($file.Name) now." -ForegroundColor Yellow

                Set-Content -Path "$($mof_directory)\$($out_file_name)" $file_content
            
                if($?)
                {
                    Write-Host "[*] $($file.Name) edited successfully." -ForegroundColor Green                    
                    $total_edited_orders_main ++

                    if($($file.Name) -cnotcontains "*_edited.mof")
                    {
                        Write-Host "[#] Moving $($file.Name) to $($mof_directory_original_splits)" -ForegroundColor Yellow
                        Move-Item "$($file)" -Destination "$($mof_directory_original_splits)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Host "[*] $($file) moved to $($mof_directory_original_splits) successfully." -ForegroundColor Green
                        }
                        else
                        {
                            Write-Host "[!] $($file) move to $($mof_directory_original_splits) failed." ([char]7) -ForegroundColor Red
                            throw "[!] $($file) move to $($mof_directory_original_splits) failed."
                        }
                    }
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

            Write-Host "[#] Edited: ($($total_edited_orders_main)/$($total_to_edit_orders_main))." -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Host "[!] Total to edit: $($total_to_edit_orders_main)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .mof files in $($mof_directory). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again." ([char]7) -ForegroundColor Red
        throw "[!] No .mof files in $($mof_directory). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
    }
}

function Edit-OrdersCertificate($cof_directory, $exclude_directories, $regex_end_cert, $cof_directory_original_splits)
{
    $total_to_edit_orders_cert = (Get-ChildItem -Path "$($cof_directory)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length

    if($($total_to_edit_orders_cert) -gt '0')
    {
        Write-Host "[#] Total to edit: $($total_to_edit_orders_cert)" -ForegroundColor Yellow
        $total_edited_orders_cert = 0

        foreach($file in (Get-ChildItem -Path "$($cof_directory)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof'}))
        {
            Process-DevCommands

            $file_content = (Get-Content "$($file)" -Raw -ErrorAction SilentlyContinue)
            $file_content = $file_content -replace "`f",''
            $file_content = $file_content -replace "                          FOR OFFICIAL USE ONLY - PRIVACY ACT",''
            $file_content = $file_content -replace "                          FOR OFFICIAL USE ONLY - PRIVACY ACT",''

            if(!((Get-Item "$($file)") -is [System.IO.DirectoryInfo]))
            {
                $out_file_name = "$($file.BaseName)_edited.cof"

                Write-Host "[#] Editing $($file.Name) now." -ForegroundColor Yellow

                Set-Content -Path "$($cof_directory)\$($out_file_name)" $file_content
				Add-Content -Path "$($cof_directory)\$($out_file_name)" -Value $($regex_end_cert)
            
                if($?)
                {
                    Write-Host "[*] $($file.Name) edited successfully." -ForegroundColor Green                    
                    $total_edited_orders_cert ++

                    if($($file.Name) -cnotcontains "*_edited.cof")
                    {
                        Write-Host "[#] Moving $($file.Name) to $($cof_directory_original_splits)" -ForegroundColor Yellow
                        Move-Item -Path "$($file)" -Destination "$($cof_directory_original_splits)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Host "[*] $($file) moved to $($cof_directory_original_splits) successfully." -ForegroundColor Green
                        }
                        else
                        {
                            Write-Host "[!] $($file) move to $($cof_directory_original_splits) failed." ([char]7) -ForegroundColor Red
                            throw "[!] $($file) move to $($cof_directory_original_splits) failed."
                        }
                    }
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

            Write-Host "[#] Edited: ($($total_edited_orders_cert)/$($total_to_edit_orders_cert))." -ForegroundColor Yellow
        }
    }
    else
    {
        Write-Host "[!] Total to edit: $($total_to_edit_orders_cert)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .cof files in $($cof_directory). Make sure to split *c.prt files first. Use '$($script_name) -sc' first, then try again." ([char]7) -ForegroundColor Red
        throw "[!] No .cof files in $($cof_directory). Make sure to split *c.prt files first. Use '$($script_name) -sc' first, then try again."
    }
}

function Combine-OrdersMain($mof_directory, $run_date, $exclude_directories)
{
    $total_to_combine_orders_main = (Get-ChildItem -Path "$($mof_directory)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }).Length

    if($($total_to_combine_orders_main) -gt '0')
    {
        $orders_combined_orders_main = 0
        $out_file = "$($mof_directory)\$($run_date)_combined_orders_m.txt"

        Write-Host "[#] Total to combine: $($total_to_combine_orders_main)" -ForegroundColor Yellow
        Write-Host "[#] Combining .mof files now." -ForegroundColor Yellow

        Get-ChildItem -Path $($mof_directory) -Recurse | Where { ! $_.PSIsContainer } | Where { $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" } | 
            ForEach-Object {
                Process-DevCommands

                Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append
                if($?)
                {
                    $orders_combined_orders_main ++
                    Write-Host "[#] Combined ($($orders_combined_orders_main)/$($total_to_combine_orders_main)) .mof files." -ForegroundColor Yellow
                }
                else
                {
                    Write-Host "[!] Combining .mof files failed." ([char]7) -ForegroundColor Red
                    throw "[!] Combining .mof files failed."
                }
            }

        Write-Host "[*] Combining .mof files finished successfully. Check your results at $($out_file)" -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] Total to combine: $($total_to_combine_orders_main)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .mof files in $($mof_directory) to combine. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again." ([char]7) -ForegroundColor Red
        throw "[!] No .mof files in $($mof_directory) to combine. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
    }
}

function Combine-OrdersCertificate($cof_directory, $run_date)
{
    $total_to_combine_orders_cert = (Get-ChildItem -Path "$($cof_directory)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' -and $_.Name -like "*_edited.cof" }).Length

    if($($total_to_combine_orders_cert) -gt '0')
    {
        $orders_combined_orders_cert = 0
        $out_file = "$($cof_directory)\$($run_date)_combined_orders_c.txt"

        Write-Host "[#] Total to combine: $($total_to_combine_orders_cert)" -ForegroundColor Yellow
        Write-Host "[#] Combining .cof files now." -ForegroundColor Yellow

        Get-ChildItem -Path $($cof_directory) -Recurse | Where { ! $_.PSIsContainer } | Where { $_.Extension -eq '.cof' -and $_.Name -like "*_edited.cof" } | 
            ForEach-Object {
                Process-DevCommands

                Out-File -FilePath $($out_file) -InputObject (Get-Content $_.FullName) -Append
                if($?)
                {
                    $orders_combined_orders_cert ++
                    Write-Host "[#] Combined ($($orders_combined_orders_cert)/$($total_to_combine_orders_cert)) .cof files." -ForegroundColor Yellow
                }
                else
                {
                    Write-Host "[!] Combining .cof files failed." ([char]7) -ForegroundColor Red
                    throw "[!] Combining .cof files failed."
                }
            }

        Write-Host "[*] Combining .cof files finished successfully. Check your results at $($out_file)" -ForegroundColor Green
    }
    else
    {
        Write-Host "[#] Total to combine: $($total_to_combine_orders_cert)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .cof files in $($cof_directory) to combine. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again." ([char]7) -ForegroundColor Red
        throw "[!] No .cof files in $($cof_directory) to combine. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
    }
}

function Parse-OrdersMain($mof_directory, $exclude_directories, $regex_format_parse_orders_main, $regex_order_number_parse_orders_main, $regex_uic_parse_orders_main, $regex_pertaining_to_parse_orders_main)
{
    $total_to_create_orders_main = (Get-ChildItem -Path "$($mof_directory)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }).Length

    if($($total_to_create_orders_main) -gt '0')
    {
        #$stop_watch = [system.diagnostics.stopwatch]::startNew()
        $orders_created_orders_main = 0
        $orders_not_created_orders_main = 0

        Write-Host "[#] Total to create: $($total_to_create_orders_main)" -ForegroundColor Yellow

        foreach($file in (Get-ChildItem -Path "$($mof_directory)"| Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }))
            {
                Process-DevCommands

                # Check for different 700 forms.
                $following_request = "Following Request is" # Disapproved || Approved
                $following_request_exists = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                $following_order = "Following order is amended as indicated." # Amendment order. $($format.Length) -eq 4
                $following_order_exists = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($following_order) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

                # Check for bad 282 forms.
                $following_request = "Following Request is" # Disapproved || Approved
                $following_request_exists = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($following_request) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

                # Check for "Memorandum for record" file that does not have format number, order number, period, basically nothing
                $memorandum_for_record = "MEMORANDUM FOR RECORD"
                $memorandum_for_record_exists = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($memorandum_for_record) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)

                $format = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_format_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
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
                    
                    $orders_not_created_orders_main++
            
                    continue
                }

                if($($following_request_exists)) # Any format containing Following Request is APPROVED||DISAPPROVED and no Order Number.
                {
                    Write-Host "[+] Found format $($format) containing $($following_request) in $($file)!" -ForegroundColor Cyan
                    Write-Host "[+] Specific format $($format) not currently handled, skipping." -ForegroundColor Cyan

                    $orders_not_created_orders_main++
            
                    continue
                }
                elseif($($format) -eq '165' -and !($($following_request_exists)))
                {
                    Write-Host "[+] Found format $($format) in $($file)!" -ForegroundColor Cyan

                    $order_number = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    $order_number = $order_number[1]

                    $anchor = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "You are ordered to" -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | 
                    Select -First 1 | 
                    ConvertFrom-String | 
                    Select P3, P4, P5, P6 ) # MI (3 = last, 4 = first, 5 = MI, 6 = SSN) // NO MI ( 3 = last, 4 = first, 5 = ssn 6 = rank )

                    $last_name = $anchor.P3
                    $last_name = $last_name.Split(':')[-1]
                    $first_name = $anchor.P4
                    $middle_initial = $anchor.P5

                    if($($middle_initial).Length -gt '1')
                    {
                        $middle_initial = 'NMI'
                        $ssn = $anchor.P5
                    }
                    else
                    {
                        $middle_initial = $anchor.P5
                        $ssn = $anchor.P6
                    }

                    $period_to = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "Period of active duty: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period_to = $period_to.ToString()
                    $period_to = $period_to.Split(' ')
                    $period_to_number = $period_to[-2]
                    $period_to_time = $period_to[-1]
                    $period_to_time = $period_to_time.ToUpper()
                    $period_to_time = $period_to_time.Substring(0, 1)

                    $period_from = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "REPORT TO " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $period_from = $period_from.ToString()
                    $period_from = $period_from.Split(' ')
                    $period_from_day = $period_from[4]
                    $period_from_month = $period_from[5]
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_year = $period_from[6]

                    $uic = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])

                    $uic_directory = "$($uics_directory)\$($uic)"
                    $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___NTE$($period_to_number)$($period_to_time)___$($format).txt"
                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory)\$($file)" -Raw)

                    Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                    $orders_created_orders_main ++

                    Write-Host "[#] Created: ($($orders_created_orders_main)/$($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main)/$($total_to_create_orders_main))" -ForegroundColor Yellow

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

                    $order_number = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    $order_number = $order_number[1]

                    $anchor = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
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
        
                    $period = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "Active duty commitment: " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
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
        
                    $uic = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])

                    $uic_directory = "$($uics_directory)\$($uic)"
                    $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory)\$($file)" -Raw)

                    Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                    $orders_created_orders_main ++

                    Write-Host "[#] Created: ($($orders_created_orders_main)/$($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main)/$($total_to_create_orders_main))" -ForegroundColor Yellow

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

                    $order_number = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    $order_number = $order_number[1] # YYYY turned into YY
                        
                    $uic = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])

                    $order_amended = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_amended = $order_amended.ToString()
                    $order_amended = $order_amended.Split(' ')
                    $order_amended = $order_amended[5]
                    $order_amended = $order_amended.Insert(3,"-")

                    $pertaining_to = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
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
                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory)\$($file)" -Raw)

                    Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                    $orders_created_orders_main ++

                    Write-Host "[#] Created: ($($orders_created_orders_main)/$($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main)/$($total_to_create_orders_main))" -ForegroundColor Yellow

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

                    $order_number = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    $order_number = $order_number[1] # YYYY turned into YY

                    $uic = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])

                    $order_revoke = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "So much of:" -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_revoke = $order_revoke.ToString()
                    $order_revoke = $order_revoke.Split(' ')
                    $order_revoke = $order_revoke[5]
                    $order_revoke = $order_revoke.Insert(3,"-")

                    $pertaining_to = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
                    $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

                    # Code to fix people that have no middle name. Currently untested for revoke section.
                    if($($pertaining_to.MiddleInitial).Length -ne 1)
                    {
                        $pertaining_to.SSN = $pertaining_to.MiddleInitial
                        $pertaining_to.MiddleInitial = 'NMI'
                    }

                    $last_name = $($pertaining_to.LastName)
                    $first_name = $($pertaining_to.FirstName)
                    $middle_initial = $($pertaining_to.MiddleInitial)
                    $ssn = $($pertaining_to.SSN)

                    $uic_directory = "$($uics_directory)\$($uic)"
                    $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_revoke)___$($format).txt"
                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory)\$($file)" -Raw)

                    Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                    $orders_created_orders_main ++

                    Write-Host "[#] Created: ($($orders_created_orders_main)/$($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main)/$($total_to_create_orders_main))" -ForegroundColor Yellow

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

                    $order_number = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    $order_number = $order_number[1] # YYYY turned into YY

                    $anchor = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "By order of the Secretary of the Army" -AllMatches -Context 5,0 -ErrorAction SilentlyContinue)
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

                    $period = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
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

                    $period_to_day = $($period[-3])
                    if($($period_to_day).Length -ne 2)
                    {
                        $period_to_day = "0$($period_to_day)"
                    }
                    $period_to_month = $($period[-2])
                    $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
                    $period_to_year = $($period[-1])

                    $uic = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $uic = $uic.ToString()
                    $uic = $uic.Split(' ')
                    $uic = $uic[0]
                    $uic = $uic.Split(":")
                    $uic = $uic[-1]
                    $uic = $uic -replace "[:\(\)./]",""
                    $uic = $uic.Split('-')
                    $uic = $uic[0]

                    $uic_directory = "$($uics_directory)\$($uic)"
                    $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory)\$($file)" -Raw)

                    Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                    $orders_created_orders_main ++

                    Write-Host "[#] Created: ($($orders_created_orders_main)/$($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main)/$($total_to_create_orders_main))" -ForegroundColor Yellow

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

                    $order_number = (Select-String -Path "$($mof_directory)\$($file)" -Pattern "ORDERS " -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_month = $months.Get_Item($($published_month)) # Retrieve month number value from hash table.
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    $order_number = $order_number[1]

                    $anchor = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 -ErrorAction SilentlyContinue | Select -First 1)
                    $anchor = $anchor | ConvertFrom-String -PropertyNames Blank_1, Orders, OrdersNumber, PublishedDay, PublishedMonth, PublishedYear, Blank_2, LastName, FirstName, MiddleInitial, SSN  | Select LastName, FirstName, MiddleInitial, SSN

                    # Code to fix people that have no middle name.
                    if($($anchor.MiddleInitial).Length -ne 1)
                    {
                        $anchor.SSN = $anchor.MiddleInitial
                        $anchor.MiddleInitial = 'NMI'
                    }

                    $period = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
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

                    $period_to_day = $($period[-3])
                    if($($period_to_day).Length -ne 2)
                    {
                        $period_to_day = "0$($period_to_day)"
                    }
                    $period_to_month = $($period[-2])
                    $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
                    $period_to_year = $($period[-1])
        
                    $uic = (Select-String -Path "$($mof_directory)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches -ErrorAction SilentlyContinue | Select -First 1)
                    $uic = $uic.ToString()
                    $uic = $uic.Split(' ')
                    $uic = $uic[0]
                    $uic = $uic.Split(":")
                    $uic = $uic[-1]
                    $uic = $uic -replace "[:\(\)./]",""
                    $uic = $uic.Split('-')
                    $uic = $uic[0]

                    $uic_directory = "$($uics_directory)\$($uic)"
                    $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___$($format).txt"
                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory)\$($file)" -Raw)

                    Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                    $orders_created_orders_main ++

                    Write-Host "[#] Created: ($($orders_created_orders_main)/$($total_to_create_orders_main)). Not created ($($orders_not_created_orders_main)/$($total_to_create_orders_main))" -ForegroundColor Yellow

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
    else
    {
        Write-Host "[!] Total to create: $($total_to_create_orders_main)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .mof files in $($mof_directory) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again." ([char]7) -ForegroundColor Red
        throw "[!] No .mof files in $($mof_directory) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
    }
}

function Parse-OrdersCertificate($cof_directory, $exclude_directories)
{
    $total_to_create_orders_cert = (Get-ChildItem -Path "$($cof_directory)" -Filter "*.cof" -Include "*_edited.cof" -Exclude $($exclude_directories) -Recurse).Length
    
    if($($total_to_create_orders_cert) -gt '0')
    {
        #$stop_watch = [system.diagnostics.stopwatch]::startNew()
        $orders_created_orders_cert = 0

        Write-Host "[#] Total to create: $($total_to_create_orders_cert)" -ForegroundColor Yellow

        foreach($file in (Get-ChildItem -Path "$($cof_directory)" -Filter "*.cof" -Include "*_edited.cof" -Exclude $($exclude_directories) -Recurse))
            {
                Process-DevCommands

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

                $name = (Select-String -Path "$($file)" -Pattern $($regex_name_parse_orders_cert) -ErrorAction SilentlyContinue  | Select -First 1)
                $name = $name.ToString()
                $name = $name.Split(' ')
                $last_name = $name[5]
                $first_name = $name[6]
                $middle_initial = $name[7]
                if($($middle_initial).Length -ne '1')
                {
                    $middle_initial = 'NMI'
                }
                else
                {
                    $middle_initial = $name[7]
                }

                $order_number = (Select-String -Path "$($file)" -Pattern $($regex_order_number_parse_orders_cert) -ErrorAction SilentlyContinue | Select -First 1)
                $order_number = $order_number.ToString()
                $order_number = $order_number.Split(' ')
                $order_number = $($order_number[2])
                $order_number = $order_number.Insert(3,"-")

                $period = (Select-String -Path "$($file)" -Pattern $($regex_period_parse_orders_cert) -ErrorAction SilentlyContinue | Select -First 1)
                $period = $period.ToString()
                $period = $period.Split(' ')
                $period = $period[3]
                $period_from = @($period -split '(.{2})' | ? { $_ })
                $period_from_year = $period_from[0]
                $period_from_month = $period_from[1]
                $period_from_day = $period_from[2]

                $period_to = $period[7]
                $period_to = @($period_to -split '(.{2})' | ? { $_ })
                $period_to_year = $period_to[0]
                $period_to_month = $period_to[1]
                $period_to_day = $period_to[2]
        
                $ssn = (Get-ChildItem -Path $($uics_directory) -Filter "*___$($order_number)___*$($period_from_year)$($period_from_month)$($period_from_day)___*$($period_to_year)$($period_to_month)$($period_to_day)___*.txt" -Recurse -Force | ConvertFrom-String -Delimiter "___" | Select -First 1)
                $ssn = $($ssn.P2)
        
                $uic_directory = "$($uics_directory)\$($uic)"
                $soldier_directory = "$($uics_directory)\$($uic)\$($last_name)_$($first_name)_$($middle_initial)___$($ssn)"
                $uic_soldier_order_file_name = "$($period_from_year)___$($ssn)___$($order_number)___$($period_from_year)$($period_from_month)$($period_from_day)___$($period_to_year)$($period_to_month)$($period_to_day)___cert.txt"
                $uic_soldier_order_file_content = (Get-Content "$($file)" -Raw)
        
                Work-Magic -uic_directory $($uic_directory) -soldier_directory $($soldier_directory) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn)

                $orders_created_orders_cert ++

                Write-Host "[#] Created: ($($orders_created_orders_cert)/$($total_to_create_orders_cert))." -ForegroundColor Yellow

                <#
                $percent_complete = ($($orders_created)/$($total_to_create)).ToString("P")
                $estimated_time = (($($total_to_create) - $($orders_created)) * 0.2 / 60)
                $formatted_estimated_time = [math]::Round($estimated_time,2)
                $elapsed_time = $stop_watch.Elapsed.ToString('hh\:mm\:ss')

                Display-ProgressBar -percent_complete $($percent_complete) -estimated_time $($estimated_time) -formatted_estimated_time $($formatted_estimated_time) -elapsed_time $($elapsed_time) -orders_created $($orders_created) -total_to_create $($total_to_create) -uic_soldier_order_file_name $($uic_soldier_order_file_name)
                #>
            }
    }
    else
    {
        Write-Host "[!] Total to create: $($total_to_create_orders_cert)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .cof files in $($cof_directory) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again." ([char]7) -ForegroundColor Red
        throw "[!] No .cof files in $($cof_directory) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
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
        New-Item -ItemType Directory -Path "$($uics_directory)\$($uic)" > $null

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
        New-Item -ItemType Directory -Path "$($soldier_directory)" > $null

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
        New-Item -ItemType File -Path $($soldier_directory) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

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

function Clean-OrdersMain($mof_directory, $exclude_directories)
{
    $total_to_clean_main_files = (Get-ChildItem -Path "$($mof_directory)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }).Length

    if($($total_to_clean_main_files) -gt '0')
    {
        Write-Host "[#] Total .mof files to clean in $($mof_directory): $($total_to_clean_main_files)" -ForegroundColor Yellow
        Remove-Item -Path "$($mof_directory)" -Recurse -Force

        if($?)
        {
            Write-Host "[*] $($mof_directory) removed successfully. Cleaned: $($total_to_clean_main_files) .mof files from $($mof_directory)." -ForegroundColor Green
            New-Item -ItemType Directory -Path "$($mof_directory)" -Force > $null
            New-Item -ItemType Directory -Path "$($mof_directory_original_splits)" -Force > $null
        }
        else
        {
            Write-Host "[!] Failed to remove $($mof_directory)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($mof_directory)."
        }
    }
    else
    {
        Write-Host "[!] Total .mof files to clean: $($total_to_clean_main_files)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .mof files in $($mof_directory) to clean up." ([char]7) -ForegroundColor Red
        throw "[!] No .mof files in $($mof_directory) to clean up."
    }
}

function Clean-OrdersCertificate($cof_directory, $exclude_directories)
{
    $total_to_clean_cert_files = (Get-ChildItem -Path "$($cof_directory)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }).Length

    if($($total_to_clean_cert_files) -gt '0')
    {
        Write-Host "[#] Total .cof files to clean in $($cof_directory): $($total_to_clean_cert_files)" -ForegroundColor Yellow
        Remove-Item -Path "$($cof_directory)" -Recurse -Force

        if($?)
        {
            Write-Host "[*] $($cof_directory) removed successfully. Cleaned: $($total_to_clean_cert_files) .cof files from $($cof_directory)." -ForegroundColor Green
            New-Item -ItemType Directory -Path "$($cof_directory)" -Force > $null
            New-Item -ItemType Directory -Path "$($cof_directory_original_splits)" -Force > $null
        }
        else
        {
            Write-Host "[!] Failed to remove $($cof_directory)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($cof_directory)."
        }
    }
    else
    {
        Write-Host "[!] Total .cof files to clean: $($total_to_clean_cert_files)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No .cof files in $($cof_directory) to clean up." ([char]7) -ForegroundColor Red
        throw "[!] No .cof files in $($cof_directory) to clean up."
    }
}

function Clean-UICS($uics_directory)
{
    $total_to_clean_uics_directories = (Get-ChildItem -Path "$($uics_directory)").Length

    if($($total_to_clean_uics_directories) -gt '0')
    {
        Write-Host "[#] Total UICS directories to clean in $($uics_directory): $($total_to_clean_uics_directories)" -ForegroundColor Yellow
        Remove-Item -Path "$($uics_directory)" -Recurse -Force

        if($?)
        {
            Write-Host "[*] $($uics_directory) removed successfully. Cleaned: $($total_to_clean_uics_directories) directories from $($uics_directory)." -ForegroundColor Green
            New-Item -ItemType Directory -Path "$($uics_directory)" -Force > $null
        }
        else
        {
            Write-Host "[!] Failed to remove $($uics_directory)." ([char]7) -ForegroundColor Red
            throw "[!] Failed to remove $($uics_directory)."
        }
    }
    else
    {
        Write-Host "[!] Total directories to clean: $($total_to_clean_uics_directories)" ([char]7) -ForegroundColor Red
        Write-Host "[!] No directories in $($uics_directory) to clean up." ([char]7) -ForegroundColor Red
        throw "[!] No directories in $($uics_directory) to clean up."
    }
}

function Display-ProgressBar($percent_complete, $estimated_time, $formatted_estimated_time, $elapsed_time, $orders_created, $total_to_create, $uic_soldier_order_file_name)
{
    for($i = $orders_created; $i -le $total_to_create; $i++)
    {
	    Write-Progress -Activity "Creating orders ..." -Status "Creating $($uic_soldier_order_file_name)" -PercentComplete ($($orders_created)/$($total_to_create)*100) -CurrentOperation "$($percent_complete) complete          ~$($formatted_estimated_time) minute(s) left          $($orders_created)/$($total_to_create) created          $($elapsed_time) time elapsed"
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
            $response = Read-Host -Prompt "Are you sure you want to exit? [ (Y|y) / (N|n) ]"
            
            switch($response)
            {
                { @("y", "Y") -contains $_ } { "Terminating at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd) by user."; exit 0 }
                { @("n", "N") -contains $_ } { continue }
                default { "Response not determined." }
            }
        }
    }
}

function Get-Permissions()
{
    $directory = (Get-Item -Path ".\" -Verbose).FullName
    $uics_directory = "$($directory)\UICS"
    $permissions_reports_directory = "$($uics_directory)\__PERMISSIONS"
    $uics_directory = $uics_directory.Split('\')
    $uics_directory = $uics_directory[-1]

    $html_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.html"
    $csv_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.csv"
    $txt_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.txt"

    if(!(Test-Path "$($permissions_reports_directory)\$($run_date)"))
    {
        New-Item -ItemType Directory -Path "$($permissions_reports_directory)\$($run_date)" > $null
    }

    Write-Host "[#] Writing permissions of $($uics_directory) to .csv file now." -ForegroundColor Yellow
    Get-ChildItem -Recurse -Path $($uics_directory) | Where { $_.FullName -notmatch '__PERMISSIONS' } | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner -PassThru} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | Export-Csv -Force -NoTypeInformation $($csv_report)
    if($?)
    {
        Write-Host "[*] $($uics_directory) permissions writing to .csv finished successfully." -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] $($uics_directory) permissions writing to .csv failed." ([char]7) -ForegroundColor Red
        throw "[!] $($uics_directory) permissions writing to .csv failed."
    }

    Write-Host "[#] Writing permissions of $($uics_directory) to .html file now." -ForegroundColor Yellow
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
    Get-ChildItem -Recurse -Path $($uics_directory) | Where { $_.FullName -notmatch '__PERMISSIONS' } | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner -PassThru} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | ConvertTo-Html -Title "$($uics_directory) Permissions Report" -Head $($css) -Body "<h1>$($uics_directory) Permissions Report</h1> <h5> Generated on $(Get-Date -UFormat "%Y-%m-%d @ %H-%M-%S")" | Out-File $($html_report)
    if($?)
    {
        Write-Host "[*] $($uics_directory) permissions writing to .html finished successfully." -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] $($uics_directory) permissions writing to .html failed." ([char]7) -ForegroundColor Red
        throw "[!] $($uics_directory) permissions writing to .html failed."
    }

    Write-Host "[#] Writing permissions of $($uics_directory) to .txt file now." -ForegroundColor Yellow
    Get-ChildItem -Recurse -Path $($uics_directory) | Where { $_.FullName -notmatch '__PERMISSIONS' } | ForEach-Object { $_ | Add-Member -Name "Owner" -MemberType NoteProperty -Value (Get-Acl $_.FullName).Owner -PassThru} | Sort-Object FullName | Select FullName,CreationTime,LastWriteTime,Length,Owner | Format-Table -AutoSize -Wrap | Out-File $($txt_report)
    if($?)
    {
        Write-Host "[*] $($uics_directory) permissions writing to .txt finished successfully." -ForegroundColor Green
    }
    else
    {
        Write-Host "[!] $($uics_directory) permissions writing to .txt failed." ([char]7) -ForegroundColor Red
        throw "[!] $($uics_directory) permissions writing to .txt failed."
    }
}

<#
ENTRY POINT
#>
$Parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
$TotalParameters = $parameters.count
$ParametersPassed = $PSBoundParameters.Count

If ($ParametersPassed -eq $TotalParameters) { Write-Output "All $totalParameters parameters are being used" }
ElseIf ($ParametersPassed -eq 1) { Write-Output "1 parameter is being used" }
Else { Write-Output "$parametersPassed parameters are being used" }

if($($ParametersPassed) -gt '0')
{
    $params = @($psBoundParameters.Keys)

    foreach($p in $params)
    {
        $log_path = "$($log_directory)\$($run_date)\$($run_date)_M=$($p).log"
        $error_path = "$($log_directory)\$($run_date)\$($run_date)_M=$($p)_errors.log"

        Start-Transcript -Path $($log_path)
        Write-Host "[^] $($p) parameter specified. Running $($p) function now." -ForegroundColor Cyan

        switch($p)
        {
            "help" { Write-Host "[^] Help parameter specified. Presenting full help now." -ForegroundColor Cyan; Get-Help .\$($script_name) -Full }
            "version" { Write-Host "[^] Version parameter specified. Presenting version information now." -ForegroundColor Cyan; Write-Host "Running version $($version_info)." }
            "dir_create" { Write-Host "[-] Creating required directories." -ForegroundColor White;  Create-RequiredDirectories -directories $($directories); if($?) {Write-Host "[^] Creating directories finished successfully." -ForegroundColor Cyan } else{ $_ | Out-File -Append $($error_path); Write-Host "[!] Directory creation failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 }  }
            "backups" { Write-Host "[-] Backing up original orders file." -ForegroundColor White; Move-OriginalToHistorical -current_directory $($current_directory) -files_orders_original $($files_orders_original) -master_history_edited $($master_history_edited) -master_history_unedited $($master_history_unedited); if($?) { Write-Host "[^] Backing up original orders file finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Backing up original orders failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "split_main" { Write-Host "[-] Splitting '*m.prt' order file(s) into individual order files." -ForegroundColor White; Split-OrdersMain -current_directory $($current_directory) -mof_directory $($mof_directory) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main);  }
            "split_cert" { Write-Host "[-] Splitting '*c.prt' cerfiticate file(s) into individual certificate files." -ForegroundColor White; Split-OrdersCertificate -current_directory $($current_directory) -cof_directory $($cof_directory) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert); if($?) { Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished successfully." -ForegroundColor Cyan } else{ $_ | Out-File -Append $($error_path); Write-Host "[!] Splitting '*c.prt' certificate file(s) into individual certificate files failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "edit_main" { Write-Host "[-] Editing orders '*m.prt' files." -ForegroundColor White; Edit-OrdersMain -mof_directory $($mof_directory) -run_date $($run_date) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_original_splits $($mof_directory_original_splits); if($?) { Write-Host "[^] Editing orders '*m.prt' files finished successfully." -ForegroundColor Cyan } else{ $_ | Out-File -Append $($error_path); Write-Host "[!] Editing orders '*m.prt' files failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "edit_cert" { Write-Host "[-] Editing orders '*c.prt' files." -ForegroundColor White; Edit-OrdersCertificate -cof_directory $($cof_directory) -run_date $($run_date) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert) -cof_directory_original_splits $($cof_directory_original_splits); if($?) { Write-Host "[^] Editing orders '*c.prt' files finished successfully." -ForegroundColor Cyan } else{ $_ | Out-File -Append $($error_path); Write-Host "[!] Editing orders '*c.prt' files failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "combine_main" { Write-Host "[-] Combining .mof orders files." -ForegroundColor White; Combine-OrdersMain -mof_directory $($mof_directory) -exclude_directories $($exclude_directories) -run_date $($run_date); if($?) { Write-Host "[^] Combining .mof orders files finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Combining .mof orders files failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red ; exit 1 } }
            "combine_cert" { Write-Host "[-] Combining .cof orders files." -ForegroundColor White; Combine-OrdersCertificate -cof_directory $($cof_directory) -run_date $($run_date); if($?) { Write-Host "[^] Combining .cof orders files finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Combining .cof orders files failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "magic_main" { Write-Host "[-] Working magic on .mof files now." -ForegroundColor White; Parse-OrdersMain -mof_directory $($mof_directory) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main); if($?) { Write-Host "[^] Magic on .mof finished successfully. Did you expect anything less?" -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Magic on .mof failed?! Impossible. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "magic_cert" { Write-Host "[-] Working magic on .cof files." -ForegroundColor White; Parse-OrdersCertificate -cof_directory $($cof_directory) -exclude_directories $($exclude_directories); if($?) { Write-Host "[^] Magic on .cof files finished successfully. Did you expect anything less?" -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Magic on .cof files failed?! Impossible. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "clean_main" { Write-Host "[-] Cleaning up .mof files." -ForegroundColor White; Clean-OrdersMain -mof_directory $($mof_directory) -exclude_directories $($exclude_directories); if($?) { Write-Host "[^] Cleaning up .mof finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Cleaning up .mof failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "clean_cert" { Write-Host "[-] Cleaning up .cof files." -ForegroundColor White; Clean-OrdersCertificate -cof_directory $($cof_directory) -exclude_directories $($exclude_directories); if($?) { Write-Host "[^] Cleaning up .cof finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Cleaning up .cof failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "clean_uics" { Write-Host "[-] Cleaning up UICS folder." -ForegroundColor White; Clean-UICS -uics_directory $($uics_directory); if($?) { Write-Host "[^] Cleaning up UICS folder finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Cleaning up UICS folder failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "permissions" { Write-Host "[-] Getting permissions." -ForegroundColor White; Get-Permissions; if($?) { Write-Host "[^] Getting permissions of UICS folder finished successfully." -ForegroundColor Cyan } else { $_ | Out-File -Append $($error_path); Write-Host "[!] Getting permissions failed. Check the error logs at $($error_path)." ([char]7)  -ForegroundColor Red; exit 1 } }
            "all" {  }
            default { "Unrecognized parameter: $($p). Try again with proper parameter." }
        }

        Stop-Transcript
    }
}
else
{
    Write-Host "[!] No parameters passed. Run 'Get-Help $($script_name) -Full' for detailed help information" ([char]7)  -ForegroundColor Red
}