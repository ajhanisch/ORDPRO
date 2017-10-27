function Split-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $input_dir,
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $run_date,
        [Parameter(mandatory = $true)] $files_orders_c_prt,
        [Parameter(mandatory = $true)] $regex_end_cert
    )

    if($($files_orders_c_prt).Count -gt '0')
    {
        $count_orders = 0
        $count_files = 0

        $orders_created = @()
        $orders_not_created = @()

        $orders_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_created_cert.csv"
        $orders_not_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_created_cert.csv"

        $out_directory = $($cof_directory_working)

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        if(!(Test-Path $($out_directory)))
        {
            Write-Log -log_file $log_file -message "$($out_directory) not created. Creating now."
            Write-Verbose "$($out_directory) not created. Creating now."

            New-Item -ItemType Directory -Path $($out_directory) > $null

            if($?)
            {
                Write-Log -log_file $log_file -message "$($out_directory) created successfully."
                Write-Verbose "$($out_directory) created successfully."
            }
            else
            {
                Write-Log -level [ERROR] -log_file $log_file -message " $($out_directory) creation failed."
                Write-Error " $($out_directory) creation failed."
            }
        }
        else
        {
            Write-Log -log_file $log_file -message "$($out_directory) already created."
            Write-Verbose "$($out_directory) already created."
        }

        foreach($file in $files_orders_c_prt)
        {
	        $count_files ++
	        $content = (Get-Content "$($input_dir)\$($file)" | Out-String)
	        $orders = [regex]::Match($content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "$($regex_end_cert)"
            
            Write-Log -log_file $log_file -message "Parsing $($input_dir)\$($file) now."
	        Write-Verbose "Parsing $($input_dir)\$($file) now."

	        foreach($order in $orders)
	        {
		        Process-KeyboardCommands -sw $($sw)

		        if($order)
		        {
			        $count_orders ++

			        $out_file = "$($run_date)_$($count_orders).cof"

                    Write-Log -log_file $log_file -message "Processing $($out_file) now."
			        Write-Verbose "Processing $($out_file) now."

			        New-Item -ItemType File -Path $($out_directory) -Name $($out_file) -Value $($order) > $null

			        if($?)
			        {
                        Write-Log -log_file $log_file -message "$($out_file) file created successfully."
				        Write-Verbose "$($out_file) file created successfully."

				        $hash = @{
					        'ORIGINAL_FILE' = "$($input_dir)\$($file)"
					        'OUT_FILE' = $($out_file)
					        'ORDER_COUNT' = $($count_orders)
				        }

				        $order_created = New-Object -TypeName PSObject -Property $hash
				        $orders_created += $order_created
				
			        }
			        else
			        {
                        Write-Log -level [ERROR] -log_file $log_file -message " $($out_file) file creation failed."
				        Write-Error " $($out_file) file creation failed."

				        $hash = @{
					        'ORIGINAL_FILE' = "$($input_dir)\$($file)"
					        'OUT_FILE' = $($out_file)
					        'ORDER_COUNT' = $($count_orders)
				        }

				        $order_created = New-Object -TypeName PSObject -Property $hash
				        $orders_not_created += $order_created
			        }
		        }
	        }

	        $status = "Splitting '*c.prt' files."
	        $activity = "Processing file $count_files of $($files_orders_c_prt.Count)."
	        $percent_complete = (($count_files/$($files_orders_c_prt.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($count_files/$($files_orders_c_prt.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($count_files / $files_orders_c_prt.Count)) - $seconds_elapsed
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

        if($orders_created.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($orders_created_csv) file now."
            Write-Verbose "Writing $($orders_created_csv) file now."
            $orders_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT | Sort -Property ORDER_COUNT | Export-Csv "$($orders_created_csv)" -NoTypeInformation -Force
        }

        if($orders_not_created.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($orders_not_created_csv) file now."
            Write-Verbose "Writing $($orders_not_created_csv) file now."
            $orders_not_created | Select ORIGINAL_FILE, OUT_FILE, ORDER_COUNT| Sort -Property ORDER_COUNT | Export-Csv "$($orders_not_created_csv)" -NoTypeInformation -Force
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " $($input_dir) '*c.prt' files to split. No '*c.prt' files to split. Make sure to have the required '*c.prt' files in the current directory and try again."
        Write-Warning -Message " $($input_dir) '*c.prt' files to split. No '*c.prt' files to split. Make sure to have the required '*c.prt' files in the current directory and try again."
    }
}