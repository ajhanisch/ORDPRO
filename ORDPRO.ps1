<#
.Synopsis
   Script to help automate orders management.
.DESCRIPTION
   Description goes here.
.PARAMETER input_dir
   Input directory. Alias is 'i'. This is the directory that contains the required orders files to be processed. Required files include '*r.reg', '*m.prt', and '*c.prt'.
.PARAMETER output_dir
   Output directory. Alias is 'o'. This is the directory that will house the results of processing. Results include directory structure as well as split, edited, and organized order files.
.PARAMETER version
   Version information. Alias is 'v'. This will tell the user the version of ORDPRO they are currently running.
.PARAMETER help
   Help information. Alias is 'h'. This will present the user with this menu.
.LINK
   https://gitlab.com/ajhanisch/ORDPRO
#>

<#
PARAMETERS
#>
[CmdletBinding()]
    Param(
        [alias('i')][string]$input_dir,
        [alias('o')][string]$output_dir,
        [alias('h')][switch]$help,
        [alias('v')][switch]$version
    )

<#
FUNCTIONS
#>
function Write-Log 
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)][ValidateSet("[INFO]","[WARN]","[ERROR]","[FATAL]","[DEBUG]")][String]$level = "[INFO]",
        [Parameter(Mandatory=$true)][string]$message,
        [Parameter(Mandatory=$false)][string]$log_file
    )

    $stamp = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    $line = "$stamp $level $message"
	
    if(!(Test-Path $log_file))
    {
        New-Item -ItemType File -Path $($log_file) -Force > $null
    }

    if($log_file) 
    {            
        Add-Content $log_file -Value $line
    }
    else 
    {
        Write-Output $line
    }
}

<#
DIRECTORIES OUTPUT
#>
$ordmanagers_directory_output = "$($output_dir)\ORD_MANAGERS"
$ordmanagers_orders_by_soldier_output = "$($ordmanagers_directory_output)\ORDERS_BY_SOLDIER"
$ordmanagers_iperms_integrator_output = "$($ordmanagers_directory_output)\IPERMS_INTEGRATOR"
$uics_directory_output = "$($output_dir)\UICS"

<#
DIRECTORIES WORKING
#>
$current_directory_working = (Get-Item -Path ".\" -Verbose).FullName
$log_directory_working = "$($current_directory_working )\LOGS"

<#
ARRAYS
#>
$directories = @(
"$($ordmanagers_directory_output)", 
"$($ordmanagers_orders_by_soldier_output)", 
"$($ordmanagers_iperms_integrator_output)",
"$($uics_directory_output)", 
"$($log_directory_working)"
)

<#
VARIABLES
#>
$script_name = $($MyInvocation.MyCommand.Name)
$version_info = "2.1"
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$log_file = "$($log_directory_working)\$($run_date)_ORDPRO.log"

<#
ENTRY POINT
#>
$parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
$total_parameters = $parameters.count
$parameters_passed = $PSBoundParameters.Count
$params = @($PSBoundParameters.Keys)
$params_results = $params  | Out-String

if($parameters_passed -eq $total_parameters) 
{     
    Write-Log -log_file $($log_file) -message "All $total_parameters parameters are being used. `n$($params_results)"
    Write-Verbose "All $total_parameters parameters are being used. `n$($params_results)"
}
elseif($parameters_passed -eq 1) 
{ 
    Write-Log -log_file $($log_file) -message "1 parameter is being used. `n$($params_results)"
    Write-Verbose "1 parameter is being used. `n$($params_results)" 
}
else
{ 
    Write-Log -log_file $($log_file) -message "$parameters_passed parameters are being used. `n`n$($params_results)"
    Write-Verbose "$parameters_passed parameters are being used. `n`n$($params_results)" 
}

if($($parameters_passed) -gt '0')
{
    if($($help))
    {
        Get-Help .\$($script_name) -Full
    }

    if($($version))
    {
        Write-Verbose "You are running $($script_name) version $($version_info). Make sure to check https://gitlab.com/ajhanisch/ORDPRO for the most recent version of ORDPRO."
    }

    if($($input_dir) -and $($output_dir))
    {
        try
        {
            $start_time = Get-Date
            Write-Log -log_file $($log_file) -message "Start time: $($start_time)."
            Write-Verbose "Start time: $($start_time)."

            foreach($directory in $directories)
            {
                if(!(Test-Path $($directory)))
                {
                    Write-Log -log_file $log_file -message "$($directory) not created. Creating now."
                    Write-Verbose "$($directory) not created. Creating now."
                    New-Item -ItemType Directory -Path $($directory) > $null

                    if($?)
                    {
                        Write-Log -log_file $log_file -message "$($directory) created successfully."
                        Write-Verbose "$($directory) created successfully."
                    }
                    else
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message "$($directory) creation failed. Check the error logs at $($error_path). Reach out to ORDPRO support."
                        Write-Error -Message " $($directory) creation failed. Check the error logs at $($error_path). Reach out to ORDPRO support." 
                    }
                }
                else
                {
                    Write-Log -log_file $log_file -message "$($directory) already created."
                    Write-Verbose "$($directory) already created."
                }
            }

            $files = (Get-ChildItem -Path "$($input_dir)" -Filter "*r.reg" -File)
            $files_processed = 0
            if($($files).Count -gt 0)
            {
                Write-Log -log_file $($log_file) -message "Total to process: $($files.Count)."
                Write-Verbose "Total to process: $($files.Count)."

                foreach($file in $files)
                {
                    $files_processed ++

                    # Present current operation
                    $order_n = $file.ToString().Substring(3,6)
                    Write-Log -log_file $($log_file) -message "Processing $($order_n.Insert(3,"-"))."
                    Write-Verbose "Processing $($order_n.Insert(3,"-"))."

                    # Find corresponding main and cert file and get content of each
                    $order_file_main = (Get-ChildItem -Path "$($input_dir)" -Filter "*$($order_n)m.prt" -File)
                    $main_file_content = (Get-Content -Path "$($input_dir)\$($order_file_main)" | Out-String)

                    $order_file_cert = (Get-ChildItem -Path "$($input_dir)" -Filter "*$($order_n)c.prt" -File)
                    $cert_file_content = (Get-Content -Path "$($input_dir)\$($order_file_cert)" | Out-String)

                    Write-Log -log_file $($log_file) -message "Registry file found is $($file). Main file found is $($order_file_main). Cert file found is $($order_file_cert)."
                    Write-Verbose "Registry file found is $($file). Main file found is $($order_file_main). Cert file found is $($order_file_cert)."

                    # Build orders array index for order_n
                    $reg_file_content = (Get-Content -Path "$($input_dir)\$($file)")
                    $last_line = ($reg_file_content | Select -Last 1 | Out-String)
                    $line_count = 0

                    foreach($line in $reg_file_content)
                    {
                        $line_count ++
                        
                        # Get needed information from registry file
                        $line = ($line | Out-String)
                        $c = $line.ToCharArray()
                        $format = $c[12..14] -join ''
                        $order_number = ($c[0..5] -join '').Insert(3,"-")
                        $name = ($c[15..36] -join '').Trim()
                        $name = $name -replace "\W","_"
                        $ssn = (($c[60..68]) -join '').Insert(3,"-").Insert(6,"-")
                        $uic = ($c[37..41]) -join ''
                        $published_year = ($c[6..11] -join '').Substring(0,2)
                        $period_from = ($c[48..53]) -join ''
                        $period_to = ($c[54..59]) -join ''

                        # Find order in main file and edit order. Still has spacing between 'Marital status / Number of dependents' and 'Type of incentive pay' & 'APC DJMS-RC' and 'APC STANFINS Pay' & 'Auth:' and 'HOR:'
                        # Test to fix last order in m.prt file not getting properly split and set to file
                        if($($line) -eq $($last_line))
                        {
                            $orders_m = [regex]::Match($main_file_content,"(?<=                          FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=                          FOR OFFICIAL USE ONLY - PRIVACY ACT)","singleline").Value -split "                          FOR OFFICIAL USE ONLY - PRIVACY ACT"
                            $order_m = $orders_m -match "ORDERS\s{1,2}$($order_number)"
                            $order_m = ($order_m -replace "FOR OFFICIAL USE ONLY - PRIVACY ACT`r`n",'' -replace "ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}",'' -replace " ",'' | Out-String)
                        }
                        else
                        {
                            $orders_m = [regex]::Match($main_file_content,"(?<= ).+(?= )","singleline").Value -split " "
                            $order_m = $orders_m -match "ORDERS\s{1,2}$($order_number)"
                            $order_m = ($order_m -replace "FOR OFFICIAL USE ONLY - PRIVACY ACT`r`n",'' -replace "ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}",'' -replace " ",'' | Out-String)
                        }

                        # Find order in cert file and edit order
                        if($($format) -eq 700 -or $($format) -eq 705 -or $($format) -eq 172 -or $($format) -eq 294)
                        {
                            Write-Log -log_file $($log_file) -message "Found format $($format) in $($file) for $($name) $($ssn) order number $($order_number). 294, 172, 700, and 705 formats do not have corresponding certificate files. Skipping."
                            Write-Verbose "Found format $($format) in $($file) for $($name) $($ssn) order number $($order_number). 294, 172, 700, and 705 formats do not have corresponding certificate files. Skipping."
                        }
                        else
                        {
                            #$orders_c = [regex]::Match($cert_file_content,"(?<= ).+(?= )","singleline").Value -split " "
                            #$orders_c = [regex]::Match($cert_file_content,"(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=FOR OFFICIAL USE ONLY - PRIVACY ACT)","singleline").Value -split "FOR OFFICIAL USE ONLY - PRIVACY ACT"
                            $orders_c = [regex]::Match($cert_file_content,"(?<=                          FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=FOR OFFICIAL USE ONLY - PRIVACY ACT)","singleline").Value -split "                          FOR OFFICIAL USE ONLY - PRIVACY ACT"
                            $order_c = $orders_c -match "Order number: $($c[0..5] -join '')"
                            $order_c = $order_c -replace "FOR OFFICIAL USE ONLY - PRIVACY ACT`r`n",''
                        }

                        # Create directories and move orders
                        $uic_directory = "$($uics_directory_output)\$($uic)" # Paths and names for UICS directory of output directory.
                        $soldier_directory_uics = "$($uic_directory)\$($name)___$($ssn)" # Paths and names for UICS directory of output directory.
                        $uic_soldier_order_file_name_main = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt" # Paths and names for UICS directory of output directory.
                        $uic_solder_order_file_name_cert = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___cert.txt" # Paths and names for UICS directory of output directory.
                        $ord_managers_soldier_directory = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)" # Paths and names for ORD_MANAGERS directory of output directory.

                        Write-Log -log_file $($log_file) -message "Creating directory structure and order files for $($name)."
                        Write-Verbose "Creating directory structure and order files for $($name)."
            
                        if(!(Test-Path "$($soldier_directory_uics)"))
                        {
                            Write-Log -log_file $($log_file) -message "$($soldier_directory_uics) does not exist. Creating now."
                            Write-Verbose "$($soldier_directory_uics) does not exist. Creating now."
                            New-Item -ItemType Directory -Path "$($soldier_directory_uics)" > $null
                            if($?)
                            {
                                Write-Log -log_file $($log_file) -message "$($soldier_directory_uics) created successfully."
                                Write-Verbose "$($soldier_directory_uics) created successfully."
                            }
                            else
                            {
                                Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics) creation failed." -level [ERROR]
                                Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics) creation failed."
                                throw "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics) creation failed."
                            }
                        }
                        else
                        {
                            Write-Log -log_file $($log_file) -message "$($soldier_directory_uics) already created. Continuing."
                            Write-Verbose "$($soldier_directory_uics) already created. Continuing."
                        }
        
                        if(!(Test-Path "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main)"))
                        {
                            Write-Log -log_file $($log_file) -message "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main) does not exist. Creating now."
                            Write-Verbose "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main) does not exist. Creating now."
                            New-Item -ItemType File -Path "$($soldier_directory_uics)" -Name "$($uic_soldier_order_file_name_main)" -Value $order_m > $null

                            if($?)
                            {
                                Write-Log -log_file $($log_file) -message "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main) created successfully."
                                Write-Verbose "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main) created successfully."
                            }
                            else
                            {
                                Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) creation failed."
                                Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) creation failed." -level [ERROR]
                                throw "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) creation failed."
                            }
                        }
                        else
                        {
                            Write-Log -log_file $($log_file) -message "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main) already created. Continuing."
                            Write-Verbose "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main) already created. Continuing."
                        }

                        if($($format) -eq 700 -or $($format) -eq 705 -or $($format) -eq 172 -or $($format) -eq 294)
                        {
                            Write-Log -log_file $($log_file) -message "Found format $($format) in $($file) for $($name) $($ssn) order number $($order_number). 294, 172, 700, and 705 formats do not have corresponding certificate files. Skipping."
                            Write-Verbose "Found format $($format) in $($file) for $($name) $($ssn) order number $($order_number). 294, 172, 700, and 705 formats do not have corresponding certificate files. Skipping."
                        }
                        else
                        {
                            if(!(Test-Path "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert)"))
                            {
                                Write-Log -log_file $($log_file) -message "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert) does not exist. Creating now."
                                Write-Verbose "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert) does not exist. Creating now."
		                        New-Item -ItemType File -Path "$($soldier_directory_uics)" -Name "$($uic_solder_order_file_name_cert)" -Value $($order_c) > $null
                                if($?)
                                {
                                    Write-Log -log_file $($log_file) -message "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert) created successfully."
                                    Write-Verbose "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert) created successfully."
                                }
                                else
                                {
                                    Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) creation failed."
                                    Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) creation failed." -level [ERROR]
                                    throw "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) creation failed."
                                }
                            }
                            else
                            {
                                Write-Log -log_file $($log_file) -message "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert) already created. Continuing."
                                Write-Verbose "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert) already created. Continuing."
                            }
                        }

                        # Testing and creation to put orders in the ORD_MANAGERS directory of output directory.
                        if(!(Test-Path $($ord_managers_soldier_directory)))
                        {
                            Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory) does not exist. Creating now."
                            Write-Verbose "$($ord_managers_soldier_directory) does not exist. Creating now."
                            New-Item -ItemType Directory -Path $($ord_managers_soldier_directory) > $null
                            if($?)
                            {
                                Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory) created successfully."
                                Write-Verbose "$($ord_managers_soldier_directory) created successfully."
                            }
                            else
                            {
                                Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory) creation failed."
                                Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory) creation failed." -level [ERROR]
                                throw "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory) creation failed."
                            }
                        }
                        else
                        {
                            Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory) already created. Continuing."
                            Write-Verbose "$($ord_managers_soldier_directory) already created. Continuing."
                        }

                        if(!(Test-Path "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main)"))
                        {
                            Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) does not exists. Creating now."
                            Write-Verbose "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) does not exists. Creating now."
                            New-Item -ItemType File -Path $($ord_managers_soldier_directory) -Name $($uic_soldier_order_file_name_main) -Value $($order_m) > $null
                            if($?)
                            {
                                Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) created successfully."   
                                Write-Verbose "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) created successfully."   
                            }
                            else
                            {
                                Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) creation failed."
                                Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) creation failed." -level [ERROR]
                                throw "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory) creation failed."
                            }
                        }
                        else
                        {
                            Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) already created. Continuing."
                            Write-Verbose "$($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) already created. Continuing."
                        }


                        if($($format) -eq 700 -or $($format) -eq 705 -or $($format) -eq 172 -or $($format) -eq 294)
                        {
                            Write-Log -log_file $($log_file) -message "Found format $($format) in $($file) for $($name) $($ssn) order number $($order_number). 294, 172, 700, and 705 formats do not have corresponding certificate files. Skipping."
                            Write-Verbose "Found format $($format) in $($file) for $($name) $($ssn) order number $($order_number). 294, 172, 700, and 705 formats do not have corresponding certificate files. Skipping."
                        }
                        else
                        {
                            if(!(Test-Path "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert)"))
                            {
                                Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) does not exist. Creating now."
                                Write-Verbose "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) does not exist. Creating now."
		                        New-Item -ItemType File -Path "$($ord_managers_soldier_directory)" -Name "$($uic_solder_order_file_name_cert)" -Value $($order_c) > $null
                                if($?)
                                {
                                    Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) created successfully."
                                    Write-Verbose "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) created successfully."
                                }
                                else
                                {
                                    Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) creation failed."
                                    Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) creation failed." -level [ERROR]
                                    throw "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) creation failed."
                                }
                            }
                            else
                            {
                                Write-Log -log_file $($log_file) -message "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) already created. Continuing."
                                Write-Verbose "$($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) already created. Continuing."
                            }

                            Write-Log -log_file $($log_file) -message "Finished creating directory structure and order files for $($name)."
                            Write-Verbose "Finished creating directory structure and order files for $($name)."
                        }

                        Write-Log -log_file $($log_file) -message "Finished processing $($order_n.Insert(3,"-")). Processed $($files_processed)/$($files.Count)."
                        Write-Verbose "Finished processing $($order_n.Insert(3,"-")). Processed $($files_processed)/$($files.Count)."
                    }
                }

                Write-Log -log_file $($log_file) -message "Combining processed orders into batches of no more than 250 in each file to $($ordmanagers_iperms_integrator_output)\$($run_date)."
                Write-Verbose "Combining processed orders into batches of no more than 250 in each file to $($ordmanagers_iperms_integrator_output)\$($run_date)."

                $order_files = (Get-ChildItem "$($ordmanagers_orders_by_soldier_output)" -Recurse -File -Exclude "*___cert.txt" | ? { $_.CreationTime -gt (Get-Date).Date } | Select -First 250 | Select FullName)
                $order_files_processed = @()

                $order_files_count = $($order_files).Count

                $start = 1
                $end = $order_files.Count

                do{            
                    $out_file = "$($ordmanagers_iperms_integrator_output)\$($run_date)\$($start)-$($end).txt"

                    if(!(Test-Path "$($ordmanagers_iperms_integrator_output)\$($run_date)"))
                    {
                        Write-Log -log_file $($log_file) -message "$($ordmanagers_iperms_integrator_output)\$($run_date) not created. Creating now."
                        Write-Verbose "$($ordmanagers_iperms_integrator_output)\$($run_date) not created. Creating now."
                        New-Item -ItemType Directory -Path "$($ordmanagers_iperms_integrator_output)\$($run_date)" -Force > $null
                
                        if($?)
                        {
                            Write-Log -log_file $($log_file) -message "$($ordmanagers_iperms_integrator_output)\$($run_date) created successfully."
                            Write-Verbose "$($ordmanagers_iperms_integrator_output)\$($run_date) created successfully."                        
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $($log_file) -message "$($ordmanagers_iperms_integrator_output)\$($run_date) creation failed."
                            Write-Error "$($ordmanagers_iperms_integrator_output)\$($run_date) creation failed."    
                            throw "$($ordmanagers_iperms_integrator_output)\$($run_date) creation failed."
                        }
                    }
            
                    # Set outfile name for each batch
                    Write-Log -log_file $log_file -message "Name of outfile is $($out_file)."
                    Write-Verbose "Name of outfile is $($out_file)."
                    New-Item -ItemType File $out_file -Force > $null

                    # Combine 250 files into batch
                    Write-Log -log_file $log_file -message "Combining $($start) - $($end) files into $($out_file)."
                    Write-Verbose "Combining $($start) - $($end) files into $($out_file)."
                    $order_files | % { Get-Content $_.FullName | Add-Content $($out_file) }

                    # Move files to array containing files already processed
                    $order_files | % { $order_files_processed += $_.FullName }

                    # Repopulate array
                    $order_files = (Get-ChildItem "$($ordmanagers_orders_by_soldier_output)" -Recurse -File -Exclude "*___cert.txt" | ? { $_.CreationTime -gt (Get-Date).Date } | ? { $_ -notin $order_files_processed } | Select -First 250 | Select FullName)
                    $order_files_count = $($order_files).Count

                    $start = $end + 1
                    $end = $start + $($order_files_count) - 1
                }
                While($order_files_count -ne 0)

                $end_time = Get-Date
                #$run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“dd\:hh\:mm\:ss”))
                $run_time = $([timespan]::fromseconds(((Get-Date)-$($start_time)).Totalseconds).ToString(“hh\:mm\:ss”))

                Write-Log -log_file $($log_file) -message "Total processed $($files_processed)/$($files.Count)."
                Write-Log -log_file $($log_file) -message "End time: $($end_time)."
                Write-Log -log_file $($log_file) -message "Run time: $($run_time)"

                Write-Verbose "Total processed $($files_processed)/$($files.Count)."
                Write-Verbose "End time: $($end_time)."
                Write-Verbose "Run time: $($run_time)"
            }
            else
            {
                Write-Log -log_file $($log_file) -message "No '*r.reg' files in input directory. Try again with proper input."
                Write-Error -Message "No '*r.reg' files in input directory. Try again with proper input." -level [ERROR]
                throw "No '*r.reg' files in input directory. Try again with proper input."
            }
        }
        catch
        {
            $end_time = Get-Date
            #$run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“dd\:hh\:mm\:ss”))
            $run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“hh\:mm\:ss”))
            $error_message = $_.Exception.Message
            $failed_item = $_.Exception.ItemName

            Write-Log -log_file $($log_file) -message "Total processed $($files_processed)/$($files.Count)."
            Write-Log -log_file $($log_file) -message "End time: $($end_time)."
            Write-Log -log_file $($log_file) -message "Run time: $($run_time)"
            Write-Log -log_file $($log_file) -message "Processing orders failed.`nThe error message was $error_message`nThe failed item was $failed_item" -level [ERROR]

            Write-Verbose "Total processed $($files_processed)/$($files.Count)."
            Write-Verbose "End time: $($end_time)."
            Write-Verbose "Run time: $($run_time)"

            Write-Error -Message "Processing orders failed.`nThe error message was $error_message`nThe failed item was $failed_item"
        }
    }
}
else
{
    Write-Log -log_file $($log_file) -message "No parameters passed. Try '.\$($script_name) -h' for help using ORDPRO. Typical usage: .\$($script_name) -i '\\path\to\input' -o '\\path\to\output'"
    Write-Warning "No parameters passed. Try '.\$($script_name) -h' for help using ORDPRO."
    Write-Host "Typical usage: .\$($script_name) -i '\\path\to\input' -o '\\path\to\output'" -ForegroundColor Green
}