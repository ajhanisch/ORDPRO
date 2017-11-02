function Parse-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )
	  
    $total_to_create_orders_cert = Get-ChildItem -Path "$($cof_directory_working)" -Filter "*.cof" -Include "*_edited.cof" -Exclude $($exclude_directories) -Recurse
    
    if($($total_to_create_orders_cert.Count) -gt '0')
    {
        $sw = New-Object System.Diagnostics.Stopwatch
        $sw.start()

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        $orders_created_cert = @()
        $orders_not_created_cert = @()
        $orders_created_cert_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_cert.csv"
        $orders_not_created_cert_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_cert.csv"

        $soldiers = @(Get-ChildItem -Path "$($uics_directory_output)" -Exclude "__PERMISSIONS" -Recurse -Include "*.txt" | % { Split-Path  -Path $_  -Parent })
        $name_ssn = @{}

        Write-Log -log_file $log_file -message "Total to create: $($total_to_create_orders_cert.Count). Populating name_ssn hash table now."
        Write-Verbose "Total to create: $($total_to_create_orders_cert.Count). Populating name_ssn hash table now."

        foreach($s in $soldiers)
        {
            Process-KeyboardCommands -sw $($sw)

            $s = $s -split "\\" -split "___"
            $name = $s[-2]
            $ssn = $s[-1]

            if(!($name_ssn.ContainsKey($name)))
            {
                Write-Log -log_file $log_file -message "$($name) not in hash table. Adding $($name) to hash table now."
                Write-Verbose "$($name) not in hash table. Adding $($name) to hash table now."

                $name_ssn.Add($name, $ssn)

                if($?)
                {
                    Write-Log -log_file $log_file -message "$($name) added to hash table succcessfully."
                    Write-Verbose "$($name) added to hash table succcessfully."
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message " $($name) failed to add to hash table."  
                    Write-Verbose " $($name) failed to add to hash table."  
                }
            }
            else
            {
                Write-Log -log_file $log_file -message "$($name) already in hash table."
                Write-Verbose "$($name) already in hash table."
            }
        }

        Write-Log -log_file $log_file -message "Finished populating soldiers_ssn hash table."
        Write-Verbose "Finished populating soldiers_ssn hash table."

        foreach($file in (Get-ChildItem -Path "$($cof_directory_working)" -Filter "*.cof" -Include "*_edited.cof" -Exclude $($exclude_directories) -Recurse))
            {
                Process-KeyboardCommands -sw $($sw)

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

                $format = '102-10A'

                Write-Log -log_file $log_file -message "Looking for 'last, first, mi' in $($file)."
                Write-Verbose "Looking for 'last, first, mi' in $($file)."
                $name = (Select-String -Path "$($file)" -Pattern $($regex_name_parse_orders_cert)  | Select -First 1)
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
                Write-Log -log_file $log_file -message "Found 'last, first, mi' in $($file)."
                Write-Verbose "Found 'last, first, mi' in $($file)."

                Write-Log -log_file $log_file -message "Looking for 'order number' in $($file)."
                Write-Verbose "Looking for 'order number' in $($file)."
                $order_number_published_year = (Select-String -Path "$($file)" -Pattern $($regex_order_number_parse_orders_cert) | Select -First 1)
                $order_number_published_year = $order_number_published_year.ToString()
                $order_number_published_year = $order_number_published_year.Split(' ')
                $order_number = $order_number_published_year[2]
                $order_number = $order_number.Insert(3,"-")
                $published_year = $order_number_published_year[5]
                $published_year = $published_year.substring(0,2)
                Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                Write-Verbose "Found 'order number' in $($file)."

                Write-Log -log_file $log_file -message "Looking for 'period from year, month, day' in $($file)."
                Write-Verbose "Looking for 'period from year, month, day' in $($file)."
                $period = (Select-String -Path "$($file)" -Pattern $($regex_period_parse_orders_cert) | Select -First 1)
                $period = $period.ToString()
                $period = $period.Split(' ')
                $period_from = $period[3]
                $period_from = @($period_from -split '(.{2})' | ? { $_ })
                $period_from_year = $period_from[0]
                $period_from_month = $period_from[1]
                $period_from_day = $period_from[2]

                $period_to = $period[7]
                $period_to = @($period_to -split '(.{2})' | ? { $_ })
                $period_to_year = $period_to[0]
                $period_to_month = $period_to[1]
                $period_to_day = $period_to[2]
                Write-Log -log_file $log_file -message "Found 'period from year, month, day' in $($file)."
                Write-Verbose "Found 'period from year, month, day' in $($file)."
        
                Write-Log -log_file $log_file -message "Looking up 'ssn' in hash table for $($file)."
                Write-Verbose "Looking up 'ssn' in hash table for $($file)."
                $ssn = $name_ssn."$($last_name)_$($first_name)_$($middle_initial)" # Retrieve ssn from soldiers_ssn hash table via key lookup.      
                Write-Log -log_file $log_file -message "Found 'ssn' in hash table for $($file)."
                Write-Verbose "Found 'ssn' in hash table for $($file)."
                
                Write-Debug "Variables before cleaning. `nFile: $($file). Format: $($format).Order Number: $($order_number).Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic).  Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

                # CLEAN ALL VARIABLES BEFORE VALIDATING.
                $format = $format -replace "[^\d{3}]",''
                #$order_number = $order_number -replace "[^\d{3}-\d{3}]",''
                $last_name = $last_name -replace "[^a-zA-Z-']",''
                $first_name = $first_name -replace "[^a-zA-Z-']",''
                $middle_initial = $middle_initial -replace "[^a-zA-Z-']",''
                #$ssn = $ssn -replace "[^\d{3}-\d{2}-\d{4}]",''
                $uic = $uic -replace "[^\w{5}]",''
                $published_year = $published_year -replace "[^\d{2,4}]",''
                $period_from_year = $period_from_year -replace "[^\d{2,4}]",''
                $period_from_month = $period_from_month -replace "[^\d{2}]",''
                $period_from_day = $period_from_day -replace "[^\d{2}]",''
                $period_to_year = $period_to_year -replace "[^\d{2,4}]",''
                $period_to_month = $period_to_month -replace "[^\d{2}]",''
                $period_to_day = $period_to_day -replace "[^\d{2}]",''

                # SET FINAL VARIALBES BEFORE VALIDATING
                $name = "$($last_name)_$($first_name)_$($middle_initial)"
                $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"
                $period_to = "$($period_to_year)$($period_to_month)$($period_to_day)"

                Write-Debug "Variables after cleaning. `nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic).  Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."
                
                $validation_results = Validate-Variables -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                if(!($validation_results.Status -contains 'fail'))
                {
                    Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
	                Write-Verbose "All variables for $($file) passed validation."

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

                        Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
		                Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
                        #throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
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

                        Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
		                Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
                        #throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_cert_csv) file. Look for variables that do not have any values."
	                }
                }

	            $status = "Working magic on '*c.prt' files."
	            $activity = "Processing file $($orders_created_cert.Count) of $($total_to_create_orders_cert.Count). $($orders_not_created_cert.Count) of $($total_to_create_orders_cert.Count) not created."
	            $percent_complete = (($($orders_created_cert.Count)/$($total_to_create_orders_cert.Count)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_created_cert.Count)/$($total_to_create_orders_cert.Count)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_created_cert.Count) / $($total_to_create_orders_cert.Count))) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Log -log_file $log_file -message "$($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                    Write-Verbose "$($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }

            }

            if($($orders_created_cert.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "Writing $($orders_created_cert_csv) file now."
                Write-Verbose "Writing $($orders_created_cert_csv) file now."
                $orders_created_cert | Select FORMAT, ORDER_NUMBER, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY | Sort -Property ORDER_NUMBER | Export-Csv -NoTypeInformation -Path "$($orders_created_cert_csv)"
            }

            if($($orders_not_created_cert.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "Writing $($orders_not_created_cert_csv) file now."
                Write-Verbose "Writing $($orders_not_created_cert_csv) file now."
                $orders_not_created_cert | Select FORMAT, ORDER_NUMBER, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY | Sort -Property ORDER_NUMBER | Export-Csv -NoTypeInformation -Path "$($orders_not_created_cert_csv)"
            }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to create: $($total_to_create_orders_cert.Count). No .cof files in $($cof_directory_working) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
        Write-Warning -Message " Total to create: $($total_to_create_orders_cert.Count). No .cof files in $($cof_directory_working) to work magic on. Make sure to split and edit *c.prt files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
    }
}