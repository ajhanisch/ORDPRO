function Move-OriginalToArchive()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $input_dir,
        [Parameter(mandatory = $true)] $tmp_directory_working,
        [Parameter(mandatory = $true)] $ordregisters_output,
        [Parameter(mandatory = $true)] $archive_directory_working
    )

    $total_files_to_move = @(Get-ChildItem -Path $($input_dir) | Where { ! $_.PSIsContainer } | Where { $_.Name -eq "*m.prt" -or $_.Name -eq "*c.prt" -or $_.Name -eq "*r.prt" -or $_.Name -eq "*r.reg*" -or $_.Extension -ne '.ps1' }).Count
    
	if($total_files_to_move -gt 0)
	{
        $year_suffix = (Get-Date -Format yyyy).Substring(2)
        $year_orders_archive_directory = "$($archive_directory_working)\$($year_suffix)_orders"
        $year_orders_registry_directory = "$($ordregisters_output)\$($year_suffix)_orders"

        $orders_file_m_prt = Get-ChildItem -Path $($input_dir) -Filter "*m.prt" -File
        $orders_file_c_prt = Get-ChildItem -Path $($input_dir) -Filter "*c.prt" -File
        $orders_file_r_prt = Get-ChildItem -Path $($input_dir) -Filter "*r.prt" -File
        $orders_file_r_reg = Get-ChildItem -Path $($input_dir) -Filter "*r.reg*" -File
	
	    $archive_directories = @(
		    "$($year_orders_archive_directory)",
		    "$($year_orders_registry_directory)"
	    )
	
	    $order_files = @{
            M_PRT = $orders_file_m_prt; 
            C_PRT = $orders_file_c_prt; 
            R_PRT = $orders_file_r_prt; 
            R_REG = $orders_file_r_reg; 
        }

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        $total_files_moved = @()
        $total_files_not_moved = @()

        $files_moved_to_archive_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_moved_to_archive.csv"
        $files_not_moved_to_archive_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_not_moved_to_archive.csv"

		foreach($directory in $archive_directories)
		{
			if(!(Test-Path $($directory)))
			{
                Write-Log -log_file $log_file -message "$($directory) not created yet. Creating now."
				Write-Verbose "$($directory) not created yet. Creating now."

				New-Item -ItemType Directory -Path $($directory) -Force > $null

				if($?)
				{
                    Write-Log -log_file $log_file -message "$($directory) created successfully."
					Write-Verbose "$($directory) created successfully."
				}
				else
				{
                    Write-Log -level [ERROR] -log_file $log_file -message " $($directory) failed to create."
					Write-Error " $($directory) failed to create."
				}
			}
			else
			{
                Write-Log -log_file $log_file -message "$($directory) already created."
				Write-Verbose "$($directory) already created."
			}
		}
		
		foreach($order_file_type in $order_files.GetEnumerator())
		{
            foreach($name in $($order_file_type.Name))
            {
                foreach($value in $($order_file_type.Value))
                {
                    Process-KeyboardCommands -sw $($sw)

                    if($name -eq 'C_PRT' -or $name -eq 'M_PRT')
                    {
                        Write-Log -log_file $log_file -message "Moving $($input_dir)\$($value) to $($year_orders_archive_directory) now."
                        Write-Verbose "Moving $($input_dir)\$($value) to $($year_orders_archive_directory) now."

                        Move-Item -Path "$($input_dir)\$($value)" -Destination "$($year_orders_archive_directory)\$($value)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "$($input_dir)\$($value) moved to $($year_orders_archive_directory) successfully."
                            Write-Verbose "$($input_dir)\$($value) moved to $($year_orders_archive_directory) successfully."
                
                            $hash = @{
                                FILE = "$($input_dir)\$($value)"
                                TYPE = $($name)
                                STATUS = 'SUCCESS'
                                DESTINATION = $($year_orders_archive_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_moved += $file_moved
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message " $($input_dir)\$($value) move to $($year_orders_archive_directory) failed."
                            Write-Error -Message " $($input_dir)\$($value) move to $($year_orders_archive_directory) failed."

                            $hash = @{
                                FILE = "$($input_dir)\$($value)"
                                TYPE = $($name)
                                STATUS = 'FAILED'
                                DESTINATION = $($year_orders_archive_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_not_moved += $file_moved
                        }
                    }
                    elseif($name -eq 'R_PRT' -or $name -eq 'R_REG')
                    {
                        Write-Verbose "Moving $($input_dir)\$($value) to $($year_orders_registry_directory) now."
                        Move-Item -Path "$($input_dir)\$($value)" -Destination "$($year_orders_registry_directory)\$($value)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "$($input_dir)\$($value) moved to $($year_orders_registry_directory) successfully."
                            Write-Verbose "$($input_dir)\$($value) moved to $($year_orders_registry_directory) successfully."
                
                            $hash = @{
                                FILE = "$($input_dir)\$($value)"
                                TYPE = $($name)
                                STATUS = 'SUCCESS'
                                DESTINATION = $($year_orders_registry_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_moved += $file_moved
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message " $($input_dir)\$($value) move to $($year_orders_registry_directory) failed."
                            Write-Verbose " $($input_dir)\$($value) move to $($year_orders_registry_directory) failed."

                            $hash = @{
                                FILE = "$($input_dir)\$($value)"
                                TYPE = $($name)
                                STATUS = 'FAILED'
                                DESTINATION = $($year_orders_registry_directory)
                            }

	                        $file_moved = New-Object -TypeName PSObject -Property $hash
                            $total_files_not_moved += $file_moved
                        }
                    }

                    $status = "Moving original $($name) files to archive folder."
                    $activity = "Moving file $($total_files_moved.Count) of $($total_files_to_move). $($total_files_not_moved.Count) of $($total_files_to_move) not moved."
                    $percent_complete = (($total_files_moved.Count/$($total_files_to_move)) * 100)
                    $current_operation = "$("{0:N2}" -f (((($total_files_moved.Count)/$($total_files_to_move)) * 100),2))% Complete"
                    $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
                    $seconds_remaining = ($seconds_elapsed / ($total_files_moved.Count / $total_files_to_move)) - $seconds_elapsed
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
            }
		}

        if($total_files_moved.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($files_moved_to_archive_csv) file now."
            Write-Verbose "Writing $($files_moved_to_archive_csv) file now."
            $total_files_moved | Select FILE, TYPE, STATUS, DESTINATION | Sort -Property STATUS | Export-Csv "$($files_moved_to_archive_csv)" -NoTypeInformation -Force
        }

        if($total_files_not_moved.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($files_not_moved_to_archive_csv) file now."
            Write-Verbose "Writing $($files_not_moved_to_archive_csv) file now."
            $total_files_not_moved | Select FILE, TYPE, STATUS, DESTINATION | Sort -Property STATUS | Export-Csv "$($files_not_moved_to_archive_csv)" -NoTypeInformation -Force
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
	}
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to move: $($total_to_move_files). No files to move. Make sure to have the required '*m.prt', '*c.prt', '*r.prt', '*r.reg' files in the current directory and try again."
        Write-Warning -Message " Total to move: $($total_to_move_files). No files to move. Make sure to have the required '*m.prt', '*c.prt', '*r.prt', '*r.reg' files in the current directory and try again."
    }
}