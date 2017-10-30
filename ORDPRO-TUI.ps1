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
GET INPUT AND OUTPUT FROM USER
#>
do
{
    $input_dir = Read-Host -Prompt "Enter input directory"
}
until($input_dir -ne $null)

do
{
    $output_dir = Read-Host -Prompt "Enter output directory"
}
until($output_dir -ne $null)

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

if(Test-Path variable:psISE)
{
    Write-Log -level [WARN] -log_file $($log_file) -message "Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
    Write-Warning "Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
}
else
{
    [console]::TreatControlCAsInput = $true
}

function Show-Menu-Main
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
    Write-Host "/  S: Set input/output directories.                                                                /"
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "Input directory: [$($input_dir)]"
    Write-Host "Output directory: [$($output_dir)]"
    Write-Host ""
}

function Show-Menu-SetVariables
{
    $menu =   ' * * * Variable Menu * * * '
    $system = '  Order Processing System  '
    $title =  '     ORDPRO by SDNG-SA     '

    cls
    Write-Host ""
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                   " -NoNewline -ForegroundColor Gray;Write-Host -NoNewline -ForegroundColor Gray "$($menu)";Write-Host "                                    /" 
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Cyan "$($system)";Write-Host "                                    /"
    Write-Host "/                                   " -NoNewline;Write-Host -NoNewline -ForegroundColor Green "$($title)";Write-Host "                                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "/                                                                                                  /" 
    Write-Host "/  1: Set input directory.                                                                         /" 
    Write-Host "/  2: Set output directory.                                                                        /"                                                                
    Write-Host "/  H: Help                                                                                         /" 
    Write-Host "/  Q: Exit                                                                                         /" 
    Write-Host "/                                                                                                  /" 
    Write-Host "/                     " -NoNewline;Write-Host -NoNewline -ForegroundColor Yellow "$(Get-Date) - Running as $($env:COMPUTERNAME)\$($env:USERNAME)";Write-Host "                    /" 
    Write-Host "////////////////////////////////////////////////////////////////////////////////////////////////////"
    Write-Host "Input directory: [$($input_dir)]"
    Write-Host "Output directory: [$($output_dir)]"
    Write-Host ""
}

do
{

    Show-Menu-Main

    $selection = Read-Host -Prompt "Please make a selection (default is 1)"

    if(!($selection))
    {
        $selection = 1
    }

    switch($selection)
    {
        1
        {
            try
            {   
                Write-Host "[^] Creating required directories. Step [1/9]." -ForegroundColor Cyan
                Create-RequiredDirectories -directories $($directories) -log_file $($log_file)
                if($?) 
                {
	                Write-Host "[^] Creating directories finished." -ForegroundColor Cyan
                } 

                Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files. Step [2/9]. Input directory is $($input_dir)." -ForegroundColor Cyan
                Split-OrdersMain -input_dir $($input_dir) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)
                if($?)
                {
	                Write-Host "[^] Splitting '*m.prt' order file(s) finished." -ForegroundColor Cyan
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

                Write-Host "[^] Combining .mof orders files. Step [6/9]." -ForegroundColor Cyan
                Combine-OrdersMain -exclude_directories $($exclude_directories) -run_date $($run_date) -mof_directory_working $($mof_directory_working) -iperms_integrator $($ordmanagers_iperms_integrator_output)
                if($?) 
                { 
	                Write-Host "[^] Combining .mof orders files finished." -ForegroundColor Cyan 
                } 	

                Write-Host "[^] Working magic on .mof files now. Step [7/9]. Output directory is $($output_dir)." -ForegroundColor Cyan
                Parse-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
                if($?) 
                { 
	                Write-Host "[^] Magic on .mof files finished." -ForegroundColor Cyan 
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

        2
        {
		    Write-Host "[^] Creating required directories." -ForegroundColor Cyan
		    Create-RequiredDirectories -directories $($directories) -log_file $($log_file)

		    if($?) 
		    {
			    Write-Host "[^] Creating directories finished." -ForegroundColor Cyan 
		    }
        }

        3
        {
		    Write-Host "[^] Splitting '*m.prt' order file(s) into individual order files. Input directory is $($input_dir)." -ForegroundColor Cyan	
		    Split-OrdersMain -input_dir $($input_dir) -mof_directory_working $($mof_directory_working) -run_date $($run_date) -files_orders_m_prt $($files_orders_m_prt) -regex_beginning_m_split_orders_main $($regex_beginning_m_split_orders_main)

		    if($?)
		    {
			    Write-Host "[^] Splitting '*m.prt' order file(s) finished." -ForegroundColor Cyan 
		    }
        }

        4
        {
		    Write-Host "[^] Editing orders '*m.prt' files." -ForegroundColor Cyan
		    Edit-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_old_fouo_3_edit_orders_main $($regex_old_fouo_3_edit_orders_main) -mof_directory_working $($mof_directory_working)

		    if($?) 
		    { 
			    Write-Host "[^] Editing orders '*m.prt' files finished." -ForegroundColor Cyan 
		    }
        }

        5
        {
		    Write-Host "[^] Combining .mof orders files." -ForegroundColor Cyan
		    Combine-OrdersMain -exclude_directories $($exclude_directories) -run_date $($run_date) -mof_directory_working $($mof_directory_working) -iperms_integrator $($ordmanagers_iperms_integrator_output)
		    if($?) 
		    { 
			    Write-Host "[^] Combining .mof orders files finished." -ForegroundColor Cyan 
		    } 	
        }

        6
        {
            Write-Host "[^ Working magic on .mof files now. Output directory is $($output_dir)." -ForegroundColor Cyan
            Parse-OrdersMain -mof_directory_original_splits_working $($mof_directory_original_splits_working) -exclude_directories $($exclude_directories) -regex_format_parse_orders_main $($regex_format_parse_orders_main) -regex_order_number_parse_orders_main $($regex_order_number_parse_orders_main) -regex_uic_parse_orders_main $($regex_uic_parse_orders_main) -regex_pertaining_to_parse_orders_main $($regex_pertaining_to_parse_orders_main)
		    if($?) 
		    { 
			    Write-Host "[^] Magic on .mof files finished." -ForegroundColor Cyan 
            }
        }

        7
        {
		    Write-Host "[^] Splitting '*c.prt' cerfiticate file(s) into individual certificate files. Input directory is $($input_dir)." -ForegroundColor Cyan
		    Split-OrdersCertificate -input_dir $($input_dir) -cof_directory_working $($cof_directory_working) -run_date $($run_date) -files_orders_c_prt $($files_orders_c_prt) -regex_end_cert $($regex_end_cert)

		    if($?) 
		    {
			    Write-Host "[^] Splitting '*c.prt' certificate file(s) into individual certificate files finished." -ForegroundColor Cyan
		    } 	
        }

        8
        {
		    Write-Host "[^] Editing orders '*c.prt' files." -ForegroundColor Cyan
		    Edit-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories) -regex_end_cert $($regex_end_cert) -cof_directory_original_splits_working $($cof_directory_original_splits_working)

		    if($?)
		    { 
			    Write-Host "[^] Editing orders '*c.prt' files finished." -ForegroundColor Cyan 
                #Stop-Transcript 
		    } 
        }

        9
        {
		    Write-Host "[^] Working magic on .cof files. Output directory is $($output_dir)." -ForegroundColor Cyan
		    Parse-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		    if($?) 
		    { 
			    Write-Host "[^] Magic on .cof files finished." -ForegroundColor Cyan 
		    } 
        }

        10
        {
		    Write-Host "[^] Cleaning up .mof files." -ForegroundColor Cyan
		    Clean-OrdersMain -mof_directory_working $($mof_directory_working) -exclude_directories $($exclude_directories)
		    if($?) 
		    { 
			    Write-Host "[^] Cleaning up .mof finished." -ForegroundColor Cyan 
		    } 	
        }

        11
        {
		    Write-Host "[^] Cleaning up .cof files." -ForegroundColor Cyan
		    Clean-OrdersCertificate -cof_directory_working $($cof_directory_working) -exclude_directories $($exclude_directories)
		    if($?) 
		    { 
			    Write-Host "[^] Cleaning up .cof finished." -ForegroundColor Cyan 
		    } 	
        }

        12
        {
		    Write-Host "[^] Cleaning up UICS folder. Output directory is $($output_dir)." -ForegroundColor Cyan
		    Clean-UICS -uics_directory_output $($uics_directory_output)
		    if($?)
		    { 
			    Write-Host "[^] Cleaning up UICS folder finished." -ForegroundColor Cyan 
		    } 	
        }

        13
        {
		    Write-Host "[^] Getting permissions. Output directory is $($output_dir)." -ForegroundColor Cyan
		    Get-Permissions -uics_directory_output $($uics_directory_output)
		    if($?) 
		    { 
			    Write-Host "[^] Getting permissions of UICS folder finished." -ForegroundColor Cyan 
		    } 
        }

        14
        {
		    Write-Host "[^] Backing up original orders file. Input directory is $($input_dir). Output directory is $($output_dir)." -ForegroundColor Cyan
		    Move-OriginalToArchive -tmp_directory_working $($tmp_directory_working) -archive_directory_working $($archive_directory_working) -ordregisters_output $($ordregisters_output) -input_dir $($input_dir)

		    if($?) 
		    { 
			    Write-Host "[^] Backing up original orders file finished." -ForegroundColor Cyan 
		    }
        }

        'S'
        {
            do
            {
                Show-Menu-SetVariables
                $input_dir = Read-Host -Prompt "Enter input directory"
                Set-Variable -Name input_dir -Value $input_dir -Scope Global -Option Constant -Description "Variable to hold input directory for processing."
                Show-Menu-SetVariables
            }
            until($input_dir -ne $null)

            do
            {
                Show-Menu-SetVariables
                $output_dir = Read-Host -Prompt "Enter output directory"
                Set-Variable -Name output_dir -Value $output_dir -Scope Global -Option Constant -Description "Variable to hold output directory for processing."
                Show-Menu-SetVariables
            }
            until($output_dir -ne $null)
        }
    
        'Q'
        {
            "You chose to exit. Exiting now."
            return
        }
    }

    #Pause
}
until($selection -eq 'Q')