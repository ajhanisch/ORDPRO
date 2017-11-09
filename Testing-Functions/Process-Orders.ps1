function Process-Orders()
{
    <#
    PARAMETERS
    #>
    [CmdletBinding()]
    param(
        [alias('i')][string]$input_dir,
        [alias('o')][string]$output_dir
    )

    <#
    FINAL STRUCTURE OF ORDERS_ARRAY

        $orders_array = @(
            $order_info = @{
                FORMAT = 282;
                ORDER_NUMBER = 004-001;
                NAME = SNUFFY_JOE_J;
                SSN = 123-45-6789;
                UIC = 8A7AA;
                PUBLISHED_YEAR = 17;
                PERIOD_FROM = 171109;
                PERIOD_TO = 171112;
                ORDER_M = [ORDER FROM '*m.prt' file];
                ORDER_C = [ORDER FROM '*c.prt' file];
            }
            $order_info = @{
                FORMAT = 282;
                ORDER_NUMBER = 004-002;
                NAME = SNUFFY_BEN_B;
                SSN = 09-87-6543;
                UIC = PKNA1;
                PUBLISHED_YEAR = 17;
                PERIOD_FROM = 171104;
                PERIOD_TO = 171109;
                ORDER_M = [ORDER FROM '*m.prt' file];
                ORDER_C = [ORDER FROM '*c.prt' file];
            }
            ...
            ...
        )
    #>

    <#
    VARIABLES
    #>
    $orders_array = @()
    $run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")

    $output_dir_uics = "$($output_dir)\UICS"
    $orders_array_csv = "$($output_dir)\$($run_date)_orders_array.csv"

    <#
    PARSE R.REG FILE(S) TO POPULATE ORDERS INDEX OF ALL NEEDED VARIABLES
    #>
    $files = (Get-ChildItem -Path $($input_dir) -Filter "*r.reg" -File)
    if($($files).Count -gt 0)
    {
        Write-Verbose "[-] Populating Orders Index now."

        $start_time = Get-Date
        Write-Verbose "Start time: $($start_time)."

        $files_parsed = 0
        $files_not_parsed = 0

        $added = 0
        $not_added = 0

        foreach($file in $files)
        {
            $files_parsed ++

            Write-Verbose "[-] Parsing $($file) now."

            Write-Verbose "Total to parse: $($files.Count)."

            $reg_file_content = (Get-Content -Path "$($input_dir)\$($file)")
            foreach($line in $reg_file_content)
            {
                $line = ($line | Out-String)

                $c = $line.ToCharArray()

                $format = $c[12..14] -join ''
                $order_number = ($c[0..5] -join '').Insert(3,"-")
                $name = ($c[15..36] -join '').Trim()
                $ssn = (($c[60..68]) -join '').Insert(3,"-").Insert(6,"-")
                $uic = ($c[37..41]) -join ''
                $published_year = ($c[6..11] -join '').Substring(0,2)
                $period_from = ($c[48..53]) -join ''
                $period_to = ($c[54..59]) -join ''

                $hash = @{
                    FORMAT = $($format);
                    ORDER_NUMBER = $($order_number);
                    NAME = $($name);
                    SSN = $($ssn);
                    UIC = $($uic);
                    PUBLISHED_YEAR = $($published_year);
                    PERIOD_FROM = $($period_from);
                    PERIOD_TO = $($period_to);
                    ORDER_M = '';
                    ORDER_C = '';
                }

                Write-Verbose "[#] Adding format $($format) for $($name) with an order number of $($order_number) to orders array."

	            $order_info = New-Object -TypeName PSObject -Property $hash
	            $orders_array += $order_info
                if($?)
                {
                    Write-Verbose "[+] Added format $($format) for $($name) with an order number of $($order_number) to orders array."
                    $added ++
                }
                else
                {
                    Write-Error "[!] Failed to add format $($format) for $($name) with an order number of $($order_number) to orders array."
                    $not_added ++
                    Read-Host -Prompt "Enter to continue"
                }
            }

            $status = "Populating Orders Index"
            $activity = "Processing file $($files_parsed) of $($files.Count). Added $($added). Not added $($not_added). Step [1/4]"
            $percent_complete = (($($files_parsed)/$($files.Count)) * 100)
            $current_operation = "$("{0:N2}" -f ((($($files_parsed)/$($files.Count)) * 100),2))% Complete. Started at $($start_time)"
            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
            $seconds_remaining = ($seconds_elapsed / ($($files_parsed) / $($files.Count))) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Verbose "$($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }

        $end_time = Get-Date
        Write-Verbose "End time: $($end_time)."
        Write-Verbose "[-] Finished populating Orders Index."   
    }
    else
    {
        Write-Error "[!] No '*r.reg' files in $($input_dir). Make sure to have the required files in $($input_dir) and try again."
        exit 1
    }

    <#
    ADD MAIN ORDER TO PERSONS OBJECT IN ARRAY
    #>
    $files = (Get-ChildItem -Path $($input_dir) -Filter "*m.prt" -File)
    if($($files).Count -gt 0)
    {
        Write-Verbose "[-] Adding main order files to persons object in array."

        $start_time = Get-Date
        Write-Verbose "Start time: $($start_time)."

        $files_parsed = 0
        $files_not_parsed = 0

        $added = 0
        $not_added = 0

        foreach($file in $files)
        {
            $files_parsed ++

            Write-Verbose "[-] Parsing $($file) now. Step [2/4]."

            Write-Verbose "Total to parse: $($files.Count)."

            $main_file_content = (Get-Content -Path "$($input_dir)\$($file)" | Out-String)
            #$orders_m = [regex]::Match($main_file_content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.
            $orders_m = [regex]::Match($main_file_content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "STATE OF SOUTH DAKOTA"
            foreach($o in $orders_m)
            {
                $regex_following_request = [regex]"Following Request is" # Disapproved || Approved
                $following_request_exists = $regex_following_request.Match($o).value

                $regex_memorandum_for_record = [regex]"MEMORANDUM FOR RECORD"
                $memorandum_for_record_exists = $regex_memorandum_for_record.Match($o).Value

                # Check for files not needed to parse or deal with.
                if($following_request_exists)
                {
                    Write-Warning "[!] Found 'Following Request is APPROVED|DISAPPROVED' in $($file). These files are not needed and guidance has been to disregard. Skipping. Error code 0xFR."
                    continue
                }

                # Check for "Memorandum for record" file that does not have format number, order number, period, basically nothing
                if($($memorandum_for_record_exists))
                {
                    Write-Warning "[!] Found 'MEMORANDUM FOR RECORD' in $($file). These files are not needed and guidance has been to disregard. Skipping. Error code 0xMR."
                    continue
                }

                $regex_format = [regex]"Format: \d{3}"
                $format = $regex_format.Match($o).Value.Split(' ')[1]
                # Check for files that have no format.
                if(!($($format)))
                {
                    Write-Warning "[!] Found file with no format from $($file). Error code 0xNF."
                    continue
                }
                $regex_order_number = [regex]"ORDERS\s{1,2}\d{3}-\d{3}"
                $order_number = $regex_order_number.Match($o).Value.Split(' ')[-1]

                $regex_ssn = [regex]"\d{3}-\d{2}-\d{4}"
                $ssn = $regex_ssn.Match($o).Value

                Write-Verbose "[#] Looking for main order file for format $($format) order number $($order_number) for ssn $($ssn) in $($file)."

                try
                {
                    ($orders_array | Where-Object { $_.FORMAT -eq $format -and $_.ORDER_NUMBER -eq $order_number -and $_.SSN -eq $ssn }).ORDER_M = $o
                    Write-Verbose "[+] Found and added main order file for format $($format) order number $($order_number) for ssn $($ssn) in $($file) to orders array."
                    $added ++
                }
                catch
                {
                    Write-Error "[!] Failed to find and add main order file for format $($format) order number $($order_number) for ssn $($ssn) in $($file)."
                    $not_added ++
                    Read-Host -Prompt "Enter to continue"
                }

                $status = "Adding main order files to persons object in array"
                $activity = "Processing file $($files_parsed) of $($files.Count). Added $($added). Not added $($not_added), Step [2/4]"
                $percent_complete = (($($files_parsed)/$($files.Count)) * 100)
                $current_operation = "$("{0:N2}" -f ((($($files_parsed)/$($files.Count)) * 100),2))% Complete. Started at $($start_time)"
                $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
                $seconds_remaining = ($seconds_elapsed / ($($files_parsed) / $($files.Count))) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Verbose "$($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }
            }
        }

        $end_time = Get-Date
        Write-Verbose "End time: $($end_time)."
        Write-Verbose "[-] Finished adding main order files to persons object in array."
    }
    else
    {
        Write-Error "[!] No '*m.prt' files in $($input_dir). Make sure to have the required files in $($input_dir) and try again."
        exit 1
    }

    <#
    ADD CERT ORDER TO PERSONS OBJECT IN ARRAY
    #>	
    $files = (Get-ChildItem -Path $($input_dir) -Filter "*c.prt" -File)
    if($($files).Count -gt 0)
    {
        Write-Verbose "[-] Adding cert order files to persons object in array."
	
        $start_time = Get-Date
        Write-Verbose "Start time: $($start_time)."

        $files_parsed = 0
        $files_not_parsed = 0

        $added = 0
        $not_added = 0

        foreach($file in $files)
        {
            $files_parsed ++

            Write-Verbose "[-] Parsing $($file) now. Step [3/4]."
		
		    Write-Verbose "Total to parse: $($files.Count)."
		
            $cert_file_content = (Get-Content -Path "$($input_dir)\$($file)" | Out-String)
            #$orders_c = [regex]::Match($cert_file_content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.
            $orders_c = [regex]::Match($cert_file_content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "Automated NGB Form 102-10A  dtd  12 AUG 96"
            foreach($o in $orders_c)
            {
                $regex_order_number = [regex]"Order number:\s{1}\d{6}"
                $order_number = $regex_order_number.Match($o).Value.Split(' ')[-1].Insert(3,"-")
        
                $regex_period_of_duty = [regex]"Period of duty:\s{1}\d{6}\s{3}To\s{1}\d{6}"
                $period_of_duty = ($regex_period_of_duty.Match($o).Value).Split(' ')
                $period_from = $period_of_duty[3]
                $period_to = $period_of_duty[-1]

                Write-Verbose "[#] Looking for cert file for $($order_number) with a period of duty from $($period_from) to $($period_to) in $($file)."

			    try
			    {
				    ($orders_array | Where-Object { $_.ORDER_NUMBER -eq $order_number -and $_.PERIOD_FROM -eq $period_from -and $_.PERIOD_TO -eq $period_to }).ORDER_C = $o
				    Write-Verbose "[+] Found and added cert file for $($order_number) with a period of duty from $($period_from) to $($period_to) in $($file) to orders array."
				    $added ++
			    }
			    catch
			    {
                    Write-Error "[!] Failed to find and add cert file for $($order_number) with a period of duty from $($period_from) to $($period_to) in $($file)."
				    $not_added ++
                    Read-Host -Prompt "Enter to continue"				
			    }

			    $status = "Adding cert files to persons object in array"
                $activity = "Processing file $($files_parsed) of $($files.Count). Added $($added). Not added $($not_added). Step [3/4]"
                $percent_complete = (($($files_parsed)/$($files.Count)) * 100)
                $current_operation = "$("{0:N2}" -f ((($($files_parsed)/$($files.Count)) * 100),2))% Complete. Started at $($start_time)"
                $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
                $seconds_remaining = ($seconds_elapsed / ($($files_parsed) / $($files.Count))) - $seconds_elapsed
                $ts =  [timespan]::fromseconds($seconds_remaining)
                $ts = $ts.ToString("hh\:mm\:ss")

                if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
                {
                    Write-Verbose "$($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
                }
            
                else
                {
                    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
                }
            }
        }
	
        $end_time = Get-Date
        Write-Verbose "End time: $($end_time)."
        Write-Verbose "[-] Finished adding cert order files to persons object in array."
    }
    else
    {
        Write-Error "[!] No '*c.prt' files in $($input_dir). Make sure to have the required files in $($input_dir) and try again."
        exit 1
    }

    <#
    CREATE AND OUTPUT RESULTS
    #>	
    if($($orders_array).Count -gt 0)
    {
        Write-Verbose "[-] Creating directory structure and order files."
	
        $start_time = Get-Date
        Write-Verbose "Start time: $($start_time)."

        $created = 0
        $not_created = 0

        foreach($o in $orders_array)
        {
            $o.NAME = $($o.NAME) -replace " ","_"

            $uic_directory = "$($output_dir_uics)\$($o.UIC)"
            $soldier_directory_uics = "$($output_dir_uics)\$($o.UIC)\$($o.NAME)___$($o.SSN)"
            $uic_soldier_order_file_name_main = "$($o.PUBLISHED_YEAR)___$($o.SSN)___$($o.ORDER_NUMBER)___$($o.PERIOD_FROM)___$($o.PERIOD_TO)___$($o.FORMAT).txt"
            $uic_solder_order_file_name_cert = "$($o.PUBLISHED_YEAR)___$($o.SSN)___$($o.ORDER_NUMBER)___$($o.PERIOD_FROM)___$($o.PERIOD_TO)___cert.txt"

            Write-Verbose "[-] Creating directory structure and order files for $($o.NAME)."
		
		    Write-Verbose "Total to create: $($orders_array.Count)."
    
            if(!(Test-Path "$($soldier_directory_uics)"))
            {
                Write-Verbose "[#] $($soldier_directory_uics) does not exist. Creating now."
                New-Item -ItemType Directory -Path "$($soldier_directory_uics)" > $null
                if($?)
                {
                    Write-Verbose "[+] $($soldier_directory_uics) created successfully."
                }
                else
                {
                    Write-Error -Message "[!] Failed to process for $($o.NAME) $($o.SSN) $($o.UIC). $($soldier_directory_uics) creation failed."
                    Read-Host -Prompt "Enter to continue"
                }
            }
            else
            {
                Write-Verbose "[+] $($soldier_directory_uics) already created. Continuing."
            }
        
            if(!(Test-Path "$($soldier_directory_uics)\$($uic_soldier_order_file_name_main)"))
            {
                Write-Verbose "[#] $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) does not exist. Creating now."
                New-Item -ItemType File -Path "$($soldier_directory_uics)" -Name "$($uic_soldier_order_file_name_main)" -Value $($o.ORDER_M) > $null
                if($?)
                {
                    Write-Verbose "[+] $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) created successfully."
                }
                else
                {
                    Write-Error -Message "[!] Failed to process for $($o.NAME) $($o.SSN) $($o.UIC). $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) creation failed."
                    Read-Host -Prompt "Enter to continue"
                }
            }
            else
            {
                Write-Verbose "[+] $($soldier_directory_uics)\$($uic_soldier_order_file_name_main) already created. Continuing."
            }

            if(!(Test-Path "$($soldier_directory_uics)\$($uic_solder_order_file_name_cert)"))
            {
                Write-Verbose "[#] $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) does not exist. Creating now."
		        New-Item -ItemType File -Path "$($soldier_directory_uics)" -Name "$($uic_solder_order_file_name_cert)" -Value $($o.ORDER_C) > $null
                if($?)
                {
                    Write-Verbose "[+] $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) created successfully."
				    $created ++
                }
                else
                {
                    Write-Error -Message "[!] Failed to process for $($o.NAME) $($o.SSN) $($o.UIC). $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) creation failed."
				    $not_created ++
                    Read-Host -Prompt "Enter to continue"
                }
            }
            else
            {
                Write-Verbose "[+] $($soldier_directory_uics)\$($uic_solder_order_file_name_cert) already created. Continuing."
            }

            Write-Verbose "[-] Finished creating directory structure and order files for $($o.NAME)."
		
		    $status = "Creating directory structure and order files"
		    $activity = "Processing order $($created) of $($orders_array.Count). Created $($created). Not created $($not_created). Step [4/4]"
		    $percent_complete = (($($created)/$($orders_array.Count)) * 100)
		    $current_operation = "$("{0:N2}" -f ((($($created)/$($orders_array.Count)) * 100),2))% Complete. Started at $($start_time)"
		    $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
		    $seconds_remaining = ($seconds_elapsed / ($($created) / $($orders_array.Count))) - $seconds_elapsed
		    $ts =  [timespan]::fromseconds($seconds_remaining)
		    $ts = $ts.ToString("hh\:mm\:ss")

		    if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
		    {
			    Write-Verbose "$($status) $($activity) $($ts) remaining. $($current_operation). Started at $($start_time)."
		    }
		
		    else
		    {
			    Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
		    }
        }

	    $end_time = Get-Date
	    Write-Verbose "End time: $($end_time)."
	    Write-Verbose "[-] Finished creating directory structure and order files."

        <#
        WRITE ORDERS_ARRAY TO CSV FOR TROUBLESHOOTING PURPOSES
        #>
        Write-Verbose "[-] Writing $($orders_array_csv) now"
        $orders_array | Select FORMAT, ORDER_NUMBER, NAME, SSN, UIC, PUBLISHED_YEAR, PERIOD_FROM, PERIOD_TO, ORDER_M, ORDER_C | Export-Csv $($orders_array_csv) -NoTypeInformation
        if($?)
        {
            Write-Verbose "[+] Wrote $($orders_array_csv) successfully."
        }
        else
        {
            Write-Error "[!] Failed to write $($orders_array_csv)."
        }
    }
    else
    {
        Write-Error "[!] Orders array is empty meaning nothing was parsed or added to the array. Contact support immediately."
        exit 1
    }
}

#Process-Orders -input_dir "C:\temp\SAMPLES\TEST" -output_dir "C:\temp\OUTPUT" -Verbose
Process-Orders -input_dir "C:\temp\SAMPLES\TEST" -output_dir "C:\temp\OUTPUT"