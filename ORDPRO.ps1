[CmdletBinding()]
Param()

function Write-Log 
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)][ValidateSet("[INFO]","[WARN]","[ERROR]","[FATAL]","[DEBUG]")][String]$level = "[INFO]",
        [Parameter(Mandatory=$true)][string]$message,
        [Parameter(Mandatory=$false)][string]$log_file
    )

    $stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
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

try
{
    $run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
    $log_file = "C:\temp\PROGRAMS\TESTING\LOGS\$($run_date)_ORDPRO.log"

    $files = (Get-ChildItem -Path "C:\temp\INPUT" -Filter "*r.reg" -File)
    if($($files).Count -gt 0)
    {
        $files_count = 0
        $start_time = Get-Date
        Write-Log -log_file $($log_file) -message "[-] Start time: $($start_time)."
        Write-Host "[-] Start time: $($start_time)." -ForegroundColor Cyan
        Write-Log -log_file $($log_file) -message "[-] Total to process: $($files.Count)."
        Write-Host "[-] Total to process: $($files.Count)." -ForegroundColor Cyan

        foreach($file in $files)
        {
            $files_count ++

            # Present current operation
            $order_n = $file.ToString().Substring(3,6)
            Write-Log -log_file $($log_file) -message "[#] Processing $($order_n.Insert(3,"-"))."
            Write-Host "[#] Processing $($order_n.Insert(3,"-"))." -ForegroundColor Yellow

            # Find corresponding main and cert file and get content of each
            $order_file_main = (Get-ChildItem -Path "C:\temp\INPUT" -Filter "*$($order_n)m.prt" -File)
            $main_file_content = (Get-Content -Path "C:\temp\INPUT\$($order_file_main)" | Out-String)

            $order_file_cert = (Get-ChildItem -Path "C:\temp\INPUT" -Filter "*$($order_n)c.prt" -File)
            $cert_file_content = (Get-Content -Path "C:\temp\INPUT\$($order_file_cert)" | Out-String)

            Write-Log -log_file $($log_file) -message "Registry file found is $($file). Main file found is $($order_file_main). Cert file found is $($order_file_cert)."
            Write-Verbose "Registry file found is $($file). Main file found is $($order_file_main). Cert file found is $($order_file_cert)."

            # Build orders array index for order_n
            $reg_file_content = (Get-Content -Path "C:\temp\INPUT\$($file)")
            $last_line = ($reg_file_content | Select -Last 1 | Out-String)

            foreach($line in $reg_file_content)
            {
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
                $uic_directory = "C:\temp\OUTPUT\UICS\$($uic)" # Paths and names for UICS directory of output directory.
                $soldier_directory_uics = "$($uic_directory)\$($name)___$($ssn)" # Paths and names for UICS directory of output directory.
                $uic_soldier_order_file_name_main = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt" # Paths and names for UICS directory of output directory.
                $uic_solder_order_file_name_cert = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___cert.txt" # Paths and names for UICS directory of output directory.
                $ord_managers_soldier_directory = "C:\temp\OUTPUT\ORD_MANAGERS\ORDERS_BY_SOLDIER\$($name)___$($ssn)" # Paths and names for ORD_MANAGERS directory of output directory.

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
                        Write-Log -log_file $($log_file) -message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics) creation failed." -level '[ERROR]'
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
                        Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) creation failed." -level '[ERROR]'
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
                            Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) creation failed." -level '[ERROR]'
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
                        Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory) creation failed." -level '[ERROR]'
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
                        Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_soldier_order_file_name_main) creation failed." -level '[ERROR]'
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
                            Write-Error -Message "Failed to process $($file) for $($name) $($ssn) order number $($order_number). $($ord_managers_soldier_directory)\$($uic_solder_order_file_name_cert) creation failed." -level '[ERROR]'
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


            }

            Write-Log -log_file $($log_file) -message "[+] Finished processing $($order_n.Insert(3,"-")). Processed $($files_count)/$($files.Count)."
            Write-Host "[+] Finished processing $($order_n.Insert(3,"-")). Processed $($files_count)/$($files.Count)." -ForegroundColor Green

            #Read-Host -Prompt "enter to continue"
        }

        $end_time = Get-Date
        #$run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“dd\:hh\:mm\:ss”))
        $run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“hh\:mm\:ss”))

        Write-Log -log_file $($log_file) -message "[-] Total processed $($files_count)/$($files.Count)."
        Write-Host "[-] Total processed $($files_count)/$($files.Count)." -ForegroundColor Cyan
        Write-Log -log_file $($log_file) -message "[-] End time: $($end_time)."
        Write-Host "[-] End time: $($end_time)." -ForegroundColor Cyan
        Write-Log -log_file $($log_file) -message "[-] Run time: $($run_time)"
        Write-Host "[-] Run time: $($run_time)" -ForegroundColor Cyan
    }
    else
    {
        Write-Log -log_file $($log_file) -message "No '*r.reg' files in input directory. Try again with proper input."
        Write-Error -Message "No '*r.reg' files in input directory. Try again with proper input." -level '[ERROR]'
        throw "No '*r.reg' files in input directory. Try again with proper input."
    }
}
catch
{
    $end_time = Get-Date
    #$run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“dd\:hh\:mm\:ss”))
    $run_time = $([timespan]::fromseconds(((Get-Date)-$start_time).Totalseconds).ToString(“hh\:mm\:ss”))
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName

    Write-Log -log_file $($log_file) -message "[-] Total processed $($files_count)/$($files.Count)."
    Write-Host "[-] Total processed $($files_count)/$($files.Count)." -ForegroundColor Cyan
    Write-Log -log_file $($log_file) -message "[-] End time: $($end_time)."
    Write-Host "[-] End time: $($end_time)." -ForegroundColor Cyan
    Write-Log -log_file $($log_file) -message "[-] Run time: $($run_time)"
    Write-Host "[-] Run time: $($run_time)" -ForegroundColor Cyan
    Write-Log -log_file $($log_file) -message "Processing orders failed.`nThe error message was $ErrorMessage`nThe failed item was $FailedItem" -level '[ERROR]'
    Write-Error -Message "Processing orders failed.`nThe error message was $ErrorMessage`nThe failed item was $FailedItem"
}