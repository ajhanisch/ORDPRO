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
$version_info = "1.6"
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

function Show-MenuMain
{
    $menu =   ' * * * Main Menu * * * '
    $system = 'Order Processing System'
    $title =  '   ORDPRO by SDNG-SA   '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                                        /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                                        /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                                        /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Automatically process orders.                                                                /" 
    Write-Host "/  2: Create required directories.                                                                 /"                                                                
    Write-Host "/  3: Split orders from '*m.prt' files.                                                            /" 
    Write-Host "/  4: Edit orders split from '*m.prt' files.                                                       /" 
    Write-Host "/  5: Combine edited orders split from '*m.prt' files.                                             /" 
    Write-Host "/  6: Work magic on edited orders split from '*m.prt' files.                                       /" 
    Write-Host "/  7: Split orders from '*c.prt' files.                                                            /" 
    Write-Host "/  8: Edit orders split from '*c.prt' files.                                                       /" 
    Write-Host "/  9: Work magic on edited orders split from '*c.prt' files.                                       /" 
    Write-Host "/ 10: Clean up .\TMP\MOF directory.                                                                /" 
    Write-Host "/ 11: Clean up .\TMP\COF directory.                                                                /" 
    Write-Host "/ 12: Clean up .\{OUTPUT_DIR}\UICS directory.                                                      /" 
    Write-Host "/ 13: Get permissions of .\{OUTPUT_DIR}\UICS directory.                                            /" 
    Write-Host "/ 14: Archive original '*m.prt', '*c.prt', '*r.reg', and '*r.prt' files.                           /" 
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
}

function Show-Menu-All
{
    $menu =   ' * * * Auto Menu * * * '
    $system = 'Order Processing System'
    $title =  '   ORDPRO by SDNG-SA   '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                                        /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                                        /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                                        /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set input directory.                                                                         /" 
    Write-Host "/  2: Set output directory.                                                                        /"                                                                
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Input [$($input_dir)]: "
    Write-Host "Output [$($output_dir)]: "
}


function Show-Menu-DirCreate
{
    $menu =   ' * * * Create Directories Main Menu * * * '
    $system = '         Order Processing System          '
    $title =  '            ORDPRO by SDNG-SA             '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                               " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                         /" 
    Write-Host "/                               " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                         /"
    Write-Host "/                               " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                         /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set ouptut directory.                                                                         /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Output [$($output_dir)]: "
}

function Show-Menu-SplitOrdersMain
{
    $menu =   ' * * * Split Orders Main Menu * * * '
    $system = '      Order Processing System       '
    $title =  '         ORDPRO by SDNG-SA          '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                              /" 
    Write-Host "/                                " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                              /"
    Write-Host "/                                " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                              /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set input directory.                                                                         /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Input [$($input_dir)]: "
}


function Show-Menu-CombineOrdersMain
{
    $menu =   ' * * * Combine Orders Main Menu * * * '
    $system = '      Order Processing System        '
    $title =  '         ORDPRO by SDNG-SA           '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                            /" 
    Write-Host "/                                " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                             /"
    Write-Host "/                                " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                             /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set input directory.                                                                         /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Input [$($input_dir)]: "
}

function Show-Menu-MagicMain
{
    $menu =   ' * * * Magic Work Main Menu * * *    '
    $system = '      Order Processing System        '
    $title =  '         ORDPRO by SDNG-SA           '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                          /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                          /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                          /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set output directory.                                                                        /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Output [$($output_dir)]: "
}

function Show-Menu-SplitOrdersCert
{
    $menu =   ' * * * Split Certs Main Menu * * *  '
    $system = '      Order Processing System       '
    $title =  '         ORDPRO by SDNG-SA          '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                           /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                           /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                           /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set input directory.                                                                         /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Input [$($input_dir)]: "
}

function Show-Menu-MagicCert
{
    $menu =   ' * * * Magic Work Cert Main Menu * * *    '
    $system = '      Order Processing System             '
    $title =  '         ORDPRO by SDNG-SA                '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                     /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                     /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                     /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set output directory.                                                                        /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Output [$($output_dir)]: "
}


function Show-Menu-GetPermissions
{
    $menu =   ' * * * Get Permissions Main Menu * * *'
    $system = '        Order Processing System       '
    $title =  '         ORDPRO by SDNG-SA            '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                  " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                          /" 
    Write-Host "/                                  " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                          /"
    Write-Host "/                                  " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                          /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set output directory.                                                                        /"                                                              
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Output [$($output_dir)]: "
}

function Show-Menu-Backup
{
    $menu =   ' * * * Backup Menu * * * '
    $system = 'Order Processing System  '
    $title =  '   ORDPRO by SDNG-SA     '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                                      /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                                      /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                                      /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set input directory.                                                                         /" 
    Write-Host "/  2: Set output directory.                                                                        /"                                                                
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host ""
    Write-Host "Input [$($input_dir)]: "
    Write-Host "Output [$($output_dir)]: "
}

do
{

    Show-MenuMain

    $selection = Read-Host -Prompt "Please make a selection (default is 1)"

    if(!($selection))
    {
        $selection = 1
    }

    switch($selection)
    {
        1
        {
            Show-Menu-All
        }

        2
        {
            Show-Menu-DirCreate
            do
            {
                $response = Read-Host -Prompt "Enter response"

                switch($response)
                {
                    1
                    {
                        $output_dir = Read-Host -Prompt "Enter output directory"

                        Show-Menu-DirCreate

                        Pause

		                Write-Host "[^] Creating required directories." -ForegroundColor Cyan
		                Create-RequiredDirectories -directories $($directories) -log_file $($log_file)

		                if($?) 
		                {
			                Write-Host "[^] Creating directories finished." -ForegroundColor Cyan 
                            Pause
		                } 
                    }

                    H
                    {
                        Write-Host "Presenting help now."
                        Pause
                    }

                    Q
                    {
                        Write-Host "Chose to quit. Exitting now."
                        break
                    }
                }
            }
            until($response -eq 'Q')
        }

        3
        {
            Show-Menu-SplitOrdersMain
        }

        4
        {
            "You chose option 4 to edit main order files."
        }

        5
        {
            Show-Menu-CombineOrdersMain
        }

        6
        {
            Show-Menu-MagicMain
        }

        7
        {
            Show-Menu-SplitOrdersCert
        }

        8
        {
            "You chose option 8 to edit cert order files."
        }

        9
        {
            Show-Menu-MagicCert
        }

        10
        {
            "You chose option 10 to clean main order files."
        }

        11
        {
            "You chose option 11 to clean cert order files."
        }

        12
        {
            "You chose option 12 to clean uics directory."
        }

        13
        {
            Show-Menu-GetPermissions
        }

        14
        {
            Show-Menu-Backup
        }
    
        'Q'
        {
            "You chose to exit. Exiting now."
            return
        }
    }

    Pause
}
until($selection -eq 'Q')