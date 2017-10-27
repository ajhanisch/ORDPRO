function Edit-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $regex_end_cert,
        [Parameter(mandatory = $true)] $cof_directory_original_splits_working
    )

    $total_to_edit_orders_cert = Get-ChildItem -Path "$($cof_directory_working)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }

    if($($total_to_edit_orders_cert.Count) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total to edit: $($total_to_edit_orders_cert.Count)."
        Write-Verbose "Total to edit: $($total_to_edit_orders_cert.Count)."

        $orders_edited = @()
        $orders_not_edited = @()

        $orders_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_edited_cert.csv"
        $orders_not_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_edited_cert.csv"

        foreach($file in (Get-ChildItem -Path "$($cof_directory_working)" -Exclude "*_edited.cof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof'}))
        {
            Process-KeyboardCommands -sw $($sw)

            if(!((Get-Item "$($file)") -is [System.IO.DirectoryInfo]))
            { 
                Write-Log -log_file $log_file -message "Editing $($file.Name) now."
                Write-Verbose "Editing $($file.Name) now."
                               
                $out_file_name = "$($file.BaseName)_edited.cof"

                $file_content = Get-Content "$($file)"

                # Remove known bad strings first.
                foreach($pattern in $known_bad_strings)
                {
                    Write-Log -log_file $log_file -message "Removing known bad string $($pattern) from $($file)."
                    Write-Verbose "Removing known bad string $($pattern) from $($file)."
                    $file_content = ( $file_content | Select-String -Pattern $($pattern) -NotMatch )

                    if($?)
                    {
                        Write-Log -log_file $log_file -message "Removed known bad string $($pattern) from $($file) succesfully."
                        Write-Verbose "Removed known bad string $($pattern) from $($file) succesfully."
                    }
                    else
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message " Removing known bad string $($pattern) from $($file) failed."
                        Write-Error " Removing known bad string $($pattern) from $($file) failed."
                    }
                }

                # Write to edited file.
                Set-Content -Path "$($cof_directory_working)\$($out_file_name)" $file_content
                Add-Content -Path "$($cof_directory_working)\$($out_file_name)" -Value $($regex_end_cert)

                if($?)
                {
                    Write-Log -log_file $log_file -message "$($file.Name) edited successfully."
                    Write-Verbose "$($file.Name) edited successfully."
                    
                    $hash = @{
                        'FILE' = $($file)
                        'STATUS' = 'SUCCESS'
                    }

                    $order_edited = New-Object -TypeName PSObject -Property $hash
                    $orders_edited += $order_edited                 

                    if($($file.Name) -cnotcontains "*_edited.cof")
                    {
                        Write-Log -log_file $log_file -message "Moving $($file.Name) to $($cof_directory_original_splits_working)"
                        Write-Verbose "Moving $($file.Name) to $($cof_directory_original_splits_working)"
                        Move-Item "$($file)" -Destination "$($cof_directory_original_splits_working)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "$($file) moved to $($cof_directory_original_splits_working) successfully."
                            Write-Verbose "$($file) moved to $($cof_directory_original_splits_working) successfully."
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message " $($file) move to $($cof_directory_original_splits_working) failed."
                            Write-Error " $($file) move to $($cof_directory_original_splits_working) failed."
                        }
                    }
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message " $($file.Name) editing failed."
                    Write-Verbose " $($file.Name) editing failed."

                    $hash = @{
                        'FILE' = $($file)
                        'STATUS' = 'FAILED'
                    }

                    $order_edited = New-Object -TypeName PSObject -Property $hash
                    $orders_not_edited += $order_edited   
                }
            }
            else
            {
                Write-Log -level [WARN] -log_file $log_file -message "$($file) is a directory. Skipping."
                Write-Verbose "$($file) is a directory. Skipping."
            }

	        $status = "Editing '*c.prt' files."
	        $activity = "Processing file $($orders_edited.Count) of $($total_to_edit_orders_cert.Count). $($orders_not_edited.Count) of $($total_to_edit_orders_cert.Count) not edited."
	        $percent_complete = (($($orders_edited.Count)/$($total_to_edit_orders_cert.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($($orders_edited.Count)/$($total_to_edit_orders_cert.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($($orders_edited.Count) / $($total_to_edit_orders_cert.Count))) - $seconds_elapsed
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

        if($orders_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($orders_edited_csv) file now."
            Write-Verbose "Writing $($orders_edited_csv) file now."
            $orders_edited | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_edited_csv)" -NoTypeInformation -Force
        }

        if($orders_not_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($orders_not_edited_csv) file now."
            Write-Verbose "Writing $($orders_not_edited_csv) file now."
            $orders_not_edited | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_not_edited_csv)" -NoTypeInformation -Force
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to edit: $($total_to_edit_orders_cert.Count). No .cof files in $($cof_directory_working). Make sure to split '*c.prt' files first. Use '$($script_name) -sc' first, then try again."
        Write-Warning -Message " Total to edit: $($total_to_edit_orders_cert.Count). No .cof files in $($cof_directory_working). Make sure to split '*c.prt' files first. Use '$($script_name) -sc' first, then try again."
    }
}