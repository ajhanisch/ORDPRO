function Parse-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_original_splits_working,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $regex_format_parse_orders_main,
        [Parameter(mandatory = $true)] $regex_order_number_parse_orders_main,
        [Parameter(mandatory = $true)] $regex_uic_parse_orders_main,
        [Parameter(mandatory = $true)] $regex_pertaining_to_parse_orders_main
    )

    $total_to_create_orders_main = Get-ChildItem -Path $($mof_directory_original_splits_working) | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' -and $_.Name -like "*_edited.mof" }

    if($($total_to_create_orders_main.Count) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        $orders_created_main = @()
        $orders_not_created_main = @()
        
        $orders_created_main_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_main.csv"
        $orders_not_created_main_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_main.csv"

        Write-Log -log_file $log_file -message "Total to create: $($total_to_create_orders_main.Count)."
        Write-Verbose "Total to create: $($total_to_create_orders_main.Count)."

        foreach($file in (Get-ChildItem -Path "$($mof_directory_original_splits_working)" -Filter "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories }))
            {
                Process-KeyboardCommands -sw $($sw)

                # Check for different 700 forms.
                $following_request = "Following Request is" # Disapproved || Approved
                $following_request_exists = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($following_request) -AllMatches | Select -First 1)
                $following_order = "Following order is amended as indicated." # Amendment order. $($format.Length) -eq 4
                $following_order_exists = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($following_order) -AllMatches | Select -First 1)

                # Check for bad 282 forms.
                $following_request = "Following Request is" # Disapproved || Approved
                $following_request_exists = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($following_request) -AllMatches | Select -First 1)

                # Check for "Memorandum for record" file that does not have format number, order number, period, basically nothing
                $memorandum_for_record = "MEMORANDUM FOR RECORD"
                $memorandum_for_record_exists = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($memorandum_for_record) -AllMatches | Select -First 1)

                Write-Log -log_file $log_file -message "Looking for 'format' in $($file)."
                Write-Verbose "Looking for 'format' in $($file)."
                $format = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_format_parse_orders_main) -AllMatches | Select -First 1)
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

                    Write-Log -log_file $log_file -message "[+] $($error_info)"
                    Write-Warning "[+] $($error_info)"

                    $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_main += $order_info

                    continue
                }

                if($($following_request_exists)) # Any format containing Following Request is APPROVED||DISAPPROVED and no Order Number.
                {
                    $error_code = "0xFR"
                    $error_info = "File $($file) containing 'Following request is APPROVED || DISAPPROVED'. This is a known issue and guidance has been to disregard these files. Error code $($error_code)."

                    Write-Log -level [WARN] -log_file $log_file -message "[+] $($error_info)"
                    Write-Warning " $($error_info)"

                     $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_main += $order_info
                               
                    continue
                }
                elseif($($format) -eq '400' -and !($($following_request_exists)))
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Verbose "Looking for order number in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_month = $months.Get_Item($($published_month)) # Retrieve month number value from hash table.
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1]

                    $anchor = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "You are to proceed on temporary duty" -AllMatches -Context 4,0 | Select -First 1 | ConvertFrom-String | Select P3, P4, P5, P6 ) # MI (3 = last, 4 = first, 5 = MI, 6 = SSN) // NO MI ( 3 = last, 4 = first, 5 = ssn, 6 = rank )

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
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

                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period from year, month, day' and 'period to year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period from year, month, day' and 'period to year, month, day' in $($file)."
                    $period_to_from = Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "Number of days: " -AllMatches | Select -First 1 | ConvertFrom-String | Select P6, P7, P8, P10, P11, P12
                    $period_from_year = $period_to_from.P8
                    $period_from_month = $period_to_from.P7.ToString()
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_day = $period_to_from.P6.Substring(1) # Removes the ( at the beginning of the day value
                    if($($period_from_day).Length -ne 2)
                    {
	                    $period_from_day = "0$($period_from_day)"
                    }                  

                    $period_to_year = $period_to_from.P12
                    $period_to_month = $period_to_from.P11
                    $period_to_month = $months.Get_Item($($period_to_month)) # Retrieve month number value from hash table.
                    $period_to_day = $period_to_from.P10.ToString()
                    if($($period_to_day.Length) -eq 1)
                    {
	                    $period_to_day = "0$($period_to_day)"
                    }
                    else
                    {
                        $period_to_day = $period_to_from.P10
                    }

                    Write-Log -log_file $log_file -message "Found 'period from year, month, day' and 'period to year, month, day' in $($file)."
                    Write-Verbose "Found 'period from year, month, day' and 'period to year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."

                    Write-Debug "Variables before cleaning`nFile: $($file). Format: $($format). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Order Number: $($order_number). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

                    # CLEAN ALL VARIABLES BEFORE VALIDATING.
                    $last_name = $last_name -replace "[^a-zA-Z-']",''
                    $first_name = $first_name -replace "[^a-zA-Z-']",''
                    $middle_initial = $middle_initial -replace "[^a-zA-Z-']",''
                    #$ssn = $ssn -replace "[^\d{3}-\d{2}-\d{4}]",''
                    $uic = $uic -replace "[^\w{5}]",''
                    #$order_number = $order_number -replace "[^\d{3}-\d{3}]",''
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

                    Write-Debug "Variables after cleaning`nFile: $($file). Format: $($format). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Order Number: $($order_number). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)
                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
                        Write-Verbose "All variables for $($file) passed validation."

                        $uic_directory = "$($uics_directory_output)\$($uic)"
                        $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
                        $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
                        $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)
                        
                        Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)
                        
                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                            PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                            PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                            PERIOD_TO_NUMBER = $($period_to_number)
                            PERIOD_TO_TIME = $($period_to_time)
                            FORMAT = $($format)
                            ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                            ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info         
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = $($period_to_number)
                                PERIOD_TO_TIME = $($period_to_time)
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values." 
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."   
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                        }
                        elseif($total_validation_fails -eq 1)
                        {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = $($period_to_number)
                                PERIOD_TO_TIME = $($period_to_time)
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   
                            
                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values." 
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."                     
                        }
                    }
                }
                elseif($($format) -eq '165' -and !($($following_request_exists)))
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "Looking for order number in $($file)."
                    Write-Verbose "Looking for order number in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1]

                    # Orders '12 and newer
                    # $anchor = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "You are ordered to" -AllMatches -Context 5,0 | Select -First 1 | ConvertFrom-String | Select P3, P4, P5, P6 ) # MI (3 = last, 4 = first, 5 = MI, 6 = SSN) // NO MI ( 3 = last, 4 = first, 5 = ssn, 6 = rank )

                    # Orders '11 and older
                    $anchor = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "You are ordered to" -AllMatches -Context 4,0 | Select -First 1 | ConvertFrom-String | Select P3, P4, P5, P6 ) # MI (3 = last, 4 = first, 5 = MI, 6 = SSN) // NO MI ( 3 = last, 4 = first, 5 = ssn, 6 = rank )

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
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

                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period from year, month, day' in $($file)."
                    $period_from = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "REPORT TO " -AllMatches | Select -First 1)
                    $period_from = $period_from.ToString()
                    $period_from = $period_from.Split(' ')
                    $period_from_day = $period_from[4]
                    $period_from_month = $period_from[5]
                    $period_from_month = $months.Get_Item($($period_from_month)) # Retrieve month number value from hash table.
                    $period_from_year = $period_from[6]
                    $period_from_year = @($period_from_year -split '(.{2})' | ? {$_})
                    $period_from_year = $($period_from_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'period from year, month, day' in $($file)."
                    Write-Verbose "Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period to year, month, day' in $($file)."
                    $period_to = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "Period of active duty: " -AllMatches | Select -First 1)
                    $period_to = $period_to.ToString()
                    $period_to = $period_to.Split(' ')
                    $period_to_number = $period_to[-2]
                    $period_to_time = $period_to[-1].ToUpper()
                    Write-Log -log_file $log_file -message "Found 'period to year, month, day' in $($file)."
                    Write-Verbose "Found 'period to year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."
                    
                    Write-Debug "Variables before cleaning.`nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year:$($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Time: $($period_to_time). Period To Number: $($period_to_number)."
                    
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
                    $period_to_time = $period_to_time -replace "[^[A-Z]{4,6}]",''
                    $period_to_number = $period_to_number -replace "[^\d{1,4}]",''

                    # SET FINAL VARIALBES BEFORE VALIDATING
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"
                    $period_to = "NTE$($period_to_number)$($period_to_time)"

                    Write-Debug "Variables after cleaning.`nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year:$($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Time: $($period_to_time). Period To Number: $($period_to_number)."
                    
                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_time $($period_to_time) -period_to_number $($period_to_number) -uic $($uic) -format $($format)
                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
                        Write-Verbose "All variables for $($file) passed validation."

                        $uic_directory = "$($uics_directory_output)\$($uic)"
                        $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
                        $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
                        $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)
                        
                        Work-Magic -uic_directory $($uic_directory) -soldier_directory_uics $($soldier_directory_uics) -uic_soldier_order_file_name $($uic_soldier_order_file_name) -uic_soldier_order_file_content $($uic_soldier_order_file_content) -uic $($uic) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -soldier_directory_ord_managers $($soldier_directory_ord_managers)
                        
                        $hash = @{
                            UIC = $($uic)
                            LAST_NAME = $($last_name)
                            FIRST_NAME = $($first_name)
                            MIDDLE_INITIAL = $($middle_initial)
                            PUBLISHED_YEAR = $($published_year)
                            PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                            PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                            SSN = $($ssn)
                            PERIOD_FROM_YEAR = $($period_from_year)
                            PERIOD_FROM_MONTH = $($period_from_month)
                            PERIOD_FROM_DAY = $($period_from_day)
                            PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                            PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                            PERIOD_TO_NUMBER = $($period_to_number)
                            PERIOD_TO_TIME = $($period_to_time)
                            FORMAT = $($format)
                            ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                            ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                            ORDER_NUMBER = $($order_number)
                        }

	                    $order_info = New-Object -TypeName PSObject -Property $hash
	                    $orders_created_main += $order_info         
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = $($period_to_number)
                                PERIOD_TO_TIME = $($period_to_time)
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values." 
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."   
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                        }
                        elseif($total_validation_fails -eq 1)
                        {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = $($period_to_number)
                                PERIOD_TO_TIME = $($period_to_time)
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   
                            
                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values." 
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."                     
                        }
                    }
                }
                elseif($($format) -eq '172' -and !($($following_request_exists)))
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "Looking for 'order number' in $($file)."
                    Write-Verbose "Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1]
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
                    $anchor = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 | Select -First 1)
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

                    # Remove non lower/upper case letters from name variables.
                    $last_name = $last_name -replace "[^a-zA-Z-']",''
                    $first_name = $first_name -replace "[^a-zA-Z-']",''
                    $middle_initial = $middle_initial -replace "[^a-zA-Z-']",''
                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."
                    
                    Write-Log -log_file $log_file -message "Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period from year, month, day' in $($file)."
                    $period = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "Active duty commitment: " -AllMatches | Select -First 1)
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

                    Write-Log -log_file $log_file -message "Found 'period from year, month, day' in $($file)."
                    Write-Verbose "Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period to year, month, day' in $($file)."
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
                    
                    Write-Log -log_file $log_file -message "Found 'period to year, month, day' in $($file)."
                    Write-Verbose "Found 'period to year, month, day' in $($file)."
                    
                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."

                    Write-Debug "Variables before cleaning.`nFile: $($file). Format: $($format). Order Number: $($order_number). First Name: $($first_name). Last Name: $($last_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day) Period To Year: $($period_to_day). Period to Month: $($period_to_month). Period To Day: $($period_to_day)."

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

                    Write-Debug "Variables after cleaning.`nFile: $($file). Format: $($format). Order Number: $($order_number). First Name: $($first_name). Last Name: $($last_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day) Period To Year: $($period_to_day). Period to Month: $($period_to_month). Period To Day: $($period_to_day)."

                    $validation_results = Validate-Variables -format $($format) -uic $($uic) -first_name $($first_name) -last_name $($last_name) -middle_initial $($middle_initial) -order_number $($order_number) -published_year $($published_year) -ssn $($ssn) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
	                    Write-Verbose "All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)
	
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
	                    $orders_created_main += $order_info
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

	                        $order_info = New-Object -TypeName PSObject -Property $hash
	                        $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -like '700' -and !($($following_request_exists))) # Amendment order for "700" and "700 *" formats
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "Looking for 'order number' in $($file)."
                    Write-Verbose "Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."
                    
                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'order amended' in $($file)."
                    Write-Verbose "Looking for 'order amended' in $($file)."
                    $order_amended = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "So much of:" -AllMatches | Select -First 1)
                    $order_amended = $order_amended.ToString()
                    $order_amended = $order_amended.Split(' ')
                    $order_amended = $order_amended[5]
                    $order_amended = $order_amended.Insert(3,"-")
                    Write-Log -log_file $log_file -message "Found 'order amended' in $($file)."
                    Write-Verbose "Found 'order amended' in $($file)."

                    $pertaining_to = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
                    $pertaining_to = $pertaining_to | ConvertFrom-String -PropertyNames GreaterThan, Pertaining, to, Colon_1, Colon_2, DutyCode, For, LastName, FirstName, MiddleInitial, SSN | Select LastName, FirstName, MiddleInitial, SSN

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
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
                    
                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."

                    Write-Debug "Variables before cleaning. `nFile: $($file). Format $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Order Amended: $($order_amended)."

                    # CLEAN ALL VARIABLES BEFORE VALIDATING.
                    $format = $format -replace "[^\d{3}]",''
                    #$order_number = $order_number -replace "[^\d{3}-\d{3}]",''
                    $last_name = $last_name -replace "[^a-zA-Z-']",''
                    $first_name = $first_name -replace "[^a-zA-Z-']",''
                    $middle_initial = $middle_initial -replace "[^a-zA-Z-']",''
                    #$ssn = $ssn -replace "[^\d{3}-\d{2}-\d{4}]",''
                    $uic = $uic -replace "[^\w{5}]",''
                    $published_year = $published_year -replace "[^\d{2,4}]",''
                    #$order_amended = $order_amended -replace "[^\d{3}-\d{3}]",''

                    # SET FINAL VARIALBES BEFORE VALIDATING
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"

                    Write-Debug "Variables after cleaning. `nFile: $($file). Format $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Order Amended: $($order_amended)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -uic $($uic) -order_amended $($order_amended) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -format $($format)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
	                    Write-Verbose "All variables for $($file) passed validation."

                        $uic_directory = "$($uics_directory_output)\$($uic)"
                        $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
                        $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_amended)___$($format).txt"
                        $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)
	
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
	                    $orders_created_main += $order_info
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = $($order_amended)
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = $($order_amended)
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -eq '705' -and !($($following_request_exists))) # Revoke.
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "Looking for 'order number' in $($file)."
                    Write-Verbose "Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | % { $_.Matches } | % {$_ -replace "[:\(\)./]","" })
                    $uic = $uic.Split("-")
                    $uic = $($uic[0])
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'order revoke' in $($file)."
                    Write-Verbose "Looking for 'order revoke' in $($file)."
                    $order_revoke = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "So much of:" -AllMatches | Select -First 1)
                    $order_revoke = $order_revoke.ToString()
                    $order_revoke = $order_revoke.Split(' ')
                    $order_revoke = $order_revoke[5]
                    $order_revoke = $order_revoke.Insert(3,"-")
                    Write-Log -log_file $log_file -message "Found 'order revoke' in $($file)."
                    Write-Verbose "Found 'order revoke' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
                    $pertaining_to = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_pertaining_to_parse_orders_main) -AllMatches -Context 0,3 | Select -First 1)
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

                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."

                    Write-Debug "Variables before cleaning. `nFile: $($file). Format $($format).Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Order Revoked: $($order_revoke)."

                    # CLEAN ALL VARIABLES BEFORE VALIDATING.
                    $format = $format -replace "[^\d{3}]",''
                    #$order_number = $order_number -replace "[^\d{3}-\d{3}]",''
                    $last_name = $last_name -replace "[^a-zA-Z-']",''
                    $first_name = $first_name -replace "[^a-zA-Z-']",''
                    $middle_initial = $middle_initial -replace "[^a-zA-Z-']",''
                    #$ssn = $ssn -replace "[^\d{3}-\d{2}-\d{4}]",''
                    $uic = $uic -replace "[^\w{5}]",''
                    $published_year = $published_year -replace "[^\d{2,4}]",''
                    #$order_revoke = $order_revoke -replace "[^\d{3}-\d{3}]",''

                    # SET FINAL VARIALBES BEFORE VALIDATING
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"

                    Write-Debug "Variables after cleaning. `nFile: $($file). Format $($format).Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Order Revoked: $($order_revoke)."

                    $validation_results = Validate-Variables -order_number $($order_number) -published_year $($published_year) -uic $($uic) -order_revoke $($order_revoke) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -format $($format)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
	                    Write-Verbose "All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($order_revoke)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)

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
	                    $orders_created_main += $order_info
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = $($order_revoke)
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = $($order_revoke)
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -eq '290' -and !($($following_request_exists))) # Pay order only.
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "Looking for 'order number' in $($file)."
                    Write-Verbose "Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $published_month = $order_number[-2]
                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? { $_ })
                    $published_year = $published_year[1]
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1] # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
                    $anchor = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "By order of the Secretary of the Army" -AllMatches -Context 5,0)
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

                    # Remove non lower/upper case letters from name variables.
                    $last_name = $last_name -replace "[^a-zA-Z-']",''
                    $first_name = $first_name -replace "[^a-zA-Z-']",''
                    $middle_initial = $middle_initial -replace "[^a-zA-Z-']",''
                    $name = "$($last_name)_$($first_name)_$($middle_initial)"
                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period from year, month, day' in $($file)."
                    $period = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches | Select -First 1)
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
                    Write-Log -log_file $log_file -message "Found 'period from year, month, day' in $($file)."
                    Write-Verbose "Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period to year, month, day' in $($file)."
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
                    Write-Log -log_file $log_file -message "Found 'period to year, month, day' in $($file)."
                    Write-Verbose "Found 'period to year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | Select -First 1)
                    $uic = $uic.ToString()
                    $uic = $uic.Split(' ')
                    $uic = $uic[0]
                    $uic = $uic.Split(":")
                    $uic = $uic[-1]
                    $uic = $uic -replace "[:\(\)./]",""
                    $uic = $uic.Split('-')
                    $uic = $uic[0]
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."

                    Write-Debug "Variables before cleaning. `nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

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

                    Write-Debug "Variables after cleaning. `nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
	                    Write-Verbose "All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)

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
	                    $orders_created_main += $order_info
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                elseif($($format) -eq '296' -or $($format) -eq '282' -or $($format) -eq '294' -or $($format) -eq '284' -and !($($following_request_exists))) # 296 AT Orders // 282 Unknown // 294 Full Time National Guard Duty - Operational Support (FTNGD-OS) // 284 Unknown.
                {
                    Write-Log -log_file $log_file -message "[+] Found format $($format) in $($file)!"
                    Write-Verbose "[+] Found format $($format) in $($file)!"

                    Write-Log -log_file $log_file -message "Looking for 'order number' in $($file)."
                    Write-Verbose "Looking for 'order number' in $($file)."
                    $order_number = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern "ORDERS " -AllMatches | Select -First 1)
                    $order_number = $order_number.ToString()
                    $order_number = $order_number.Split(' ')
                    $published_day = $order_number[-3]
                    $month = $order_number[-2]
                    $published_month = $months.Get_Item($($month)) # Retrieve month number value from hash table.
                    Write-Log -log_file $log_file -message "Looking for 'published year' in $($file)."
                    Write-Verbose "Looking for 'published year' in $($file)."
                    $published_year = $order_number[-1]
                    $published_year = @($published_year -split '(.{2})' | ? {$_})
                    $published_year = $($published_year[1]) # YYYY turned into YY
                    Write-Log -log_file $log_file -message "Found 'published year' in $($file)."
                    Write-Verbose "Found 'published year' in $($file)."
                    $order_number = $order_number[1]
                    Write-Log -log_file $log_file -message "Found 'order number' in $($file)."
                    Write-Verbose "Found 'order number' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Looking for 'last, first, mi, ssn' in $($file)."
                    $anchor = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_name_parse_orders_main) -AllMatches -Context 5,0 | Select -First 1)
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
                    Write-Log -log_file $log_file -message "Found 'last, first, mi, ssn' in $($file)."
                    Write-Verbose "Found 'last, first, mi, ssn' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period from year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period from year, month, day' in $($file)."
                    $period = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_period_parse_orders_main) -AllMatches | Select -First 1)
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
                    Write-Log -log_file $log_file -message "Found 'period from year, month, day' in $($file)."
                    Write-Verbose "Found 'period from year, month, day' in $($file)."

                    Write-Log -log_file $log_file -message "Looking for 'period to year, month, day' in $($file)."
                    Write-Verbose "Looking for 'period to year, month, day' in $($file)."
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
                    Write-Log -log_file $log_file -message "Found 'period to year, month, day' in $($file)."
                    Write-Verbose "Found 'period to year, month, day' in $($file)."
                    
                    Write-Log -log_file $log_file -message "Looking for 'uic' in $($file)."
                    Write-Verbose "Looking for 'uic' in $($file)."
                    $uic = (Select-String -Path "$($mof_directory_original_splits_working)\$($file)" -Pattern $($regex_uic_parse_orders_main) -AllMatches | Select -First 1)
                    $uic = $uic.ToString()
                    $uic = $uic.Split(' ')
                    $uic = $uic[0]
                    $uic = $uic.Split(":")
                    $uic = $uic[-1]
                    $uic = $uic -replace "[:\(\)./]",""
                    $uic = $uic.Split('-')
                    $uic = $uic[0]
                    Write-Log -log_file $log_file -message "Found 'uic' in $($file)."
                    Write-Verbose "Found 'uic' in $($file)."

                    Write-Debug "Variables before cleaning. `nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

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

                    Write-Debug "Variables after cleaning. `nFile: $($file). Format: $($format). Order Number: $($order_number). Last Name: $($last_name). First Name: $($first_name). Middle Initial: $($middle_initial). SSN: $($ssn). UIC: $($uic). Published Year: $($published_year). Period From Year: $($period_from_year). Period From Month: $($period_from_month). Period From Day: $($period_from_day). Period To Year: $($period_to_year). Period To Month: $($period_to_month). Period To Day: $($period_to_day)."

                    $validation_results = Validate-Variables -format $($format) -last_name $($last_name) -first_name $($first_name) -middle_initial $($middle_initial) -ssn $($ssn) -uic $($uic) -order_number $($order_number) -published_year $($published_year) -period_from_year $($period_from_year) -period_from_month $($period_from_month) -period_from_day $($period_from_day) -period_to_year $($period_to_year) -period_to_month $($period_to_month) -period_to_day $($period_to_day)

                    if(!($validation_results.Status -contains 'fail'))
                    {
                        Write-Log -log_file $log_file -message "All variables for $($file) passed validation."
	                    Write-Verbose "All variables for $($file) passed validation."

	                    $uic_directory = "$($uics_directory_output)\$($uic)"
	                    $soldier_directory_uics = "$($uics_directory_output)\$($uic)\$($name)___$($ssn)"
                        $soldier_directory_ord_managers = "$($ordmanagers_orders_by_soldier_output)\$($name)___$($ssn)"
	                    $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"
	                    $uic_soldier_order_file_content = (Get-Content "$($mof_directory_original_splits_working)\$($file)" -Raw)

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
	                    $orders_created_main += $order_info
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
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
	                    elseif($total_validation_fails -eq 1)
	                    {
                            $hash = @{
                                UIC = $($uic)
                                LAST_NAME = $($last_name)
                                FIRST_NAME = $($first_name)
                                MIDDLE_INITIAL = $($middle_initial)
                                PUBLISHED_YEAR = $($published_year)
                                PUBLISHED_MONTH = "NOT NEEDED FOR FORMAT $($format)"
                                PUBLISHED_DAY = "NOT NEEDED FOR FORMAT $($format)"
                                SSN = $($ssn)
                                PERIOD_FROM_YEAR = $($period_from_year)
                                PERIOD_FROM_MONTH = $($period_from_month)
                                PERIOD_FROM_DAY = $($period_from_day)
                                PERIOD_TO_YEAR = $($period_to_year)
                                PERIOD_TO_MONTH = $($period_to_month)
                                PERIOD_TO_DAY = $($period_to_day)
                                PERIOD_TO_NUMBER = "NOT NEEDED FOR FORMAT $($format)"
                                PERIOD_TO_TIME = "NOT NEEDED FOR FORMAT $($format)"
                                FORMAT = $($format)
                                ORDER_AMENDED = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_REVOKE = "NOT NEEDED FOR FORMAT $($format)"
                                ORDER_NUMBER = $($order_number)
                            }

                            $order_info = New-Object -TypeName PSObject -Property $hash
                            $orders_not_created_main += $order_info   

                            Write-Log -level [ERROR] -log_file $log_file -message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            Write-Error -Message " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
                            throw " $($total_validation_fails) variables for $($file) failed validation. Check the $($orders_not_created_main_csv) file. Look for variables that do not have any values."
	                    }
                    }
                }
                else
                {
                    $error_code = "0x00"
                    $error_info = "File $($file) with format $($format). This is not currently an unknown and/or handled format. Notify ORDPRO support of this error ASAP. Error code $($error_code)."

                    Write-Log -level [WARN] -log_file $log_file -message "[+] $($error_info)"
                    Write-Warning "[+] $($error_info)"
                    
                    $hash = @{
                        FILE = $($file)
                        ERROR_CODE = $($error_code)
                        ERROR_INFO = $($error_info)
                    }

	                $order_info = New-Object -TypeName PSObject -Property $hash
                    $orders_not_created_main += $order_info

                    continue
                }

	            $status = "Working magic on '*m.prt' files."
	            $activity = "Processing file $($orders_created_main.Count) of $($total_to_create_orders_main.Count). $($orders_not_created_main.Count) of $($total_to_create_orders_main.Count) not created."
	            $percent_complete = (($($orders_created_main.Count)/$($total_to_create_orders_main.Count)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_created_main.Count)/$($total_to_create_orders_main.Count)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_created_main.Count) / $($total_to_create_orders_main.Count))) - $seconds_elapsed
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

            if($($orders_created_main.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "Writing $($orders_created_main_csv) file now."
                Write-Verbose "Writing $($orders_created_main_csv) file now."
                $orders_created_main | Select FORMAT, ORDER_NUMBER, ORDER_AMENDED, ORDER_REVOKE, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, PUBLISHED_YEAR, PERIOD_FROM_YEAR, PERIOD_FROM_MONTH, PERIOD_FROM_DAY, PERIOD_TO_YEAR, PERIOD_TO_MONTH, PERIOD_TO_DAY, PERIOD_TO_NUMBER, PERIOD_TO_TIME, PUBLISHED_MONTH, PUBLISHED_DAY | Sort -Property ORDER_NUMBER | Export-Csv "$($orders_created_main_csv)" -NoTypeInformation -Force
            }

            if($($orders_not_created_main.Count) -gt '0')
            {
                Write-Log -log_file $log_file -message "Writing $($orders_not_created_main_csv) file now."
                Write-Verbose "Writing $($orders_not_created_main_csv) file now."
                $orders_not_created_main | Select FILE, ERROR_CODE, ERROR_INFO | Sort -Property ERROR_CODE | Export-Csv "$($orders_not_created_main_csv)" -NoTypeInformation -Force
            }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to create: ($($total_to_create_orders_main.Count)). No .mof files in $($mof_directory_original_splits_working) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm -em' then try again."
        Write-Warning -Message " Total to create: ($($total_to_create_orders_main.Count)). No .mof files in $($mof_directory_original_splits_working) to work magic on. Make sure to split and edit *m.prt files first. Use '$($script_name) -sm -em' then try again."
    }
}