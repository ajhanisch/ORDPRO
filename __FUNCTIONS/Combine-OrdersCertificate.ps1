function Combine-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $run_date
    )

    $total_to_combine_orders_cert = Get-ChildItem -Path "$($cof_directory_working)" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' -and $_.Name -like "*_edited.cof" }

    if($($($total_to_combine_orders_cert.Count)) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        $orders_combined = @()
        $orders_combined_csv = "$($log_directory_working)\$($run_date)\$($run_date)_combined_orders_cert.csv"

        $out_file = "$($log_directory_working)\$($run_date)\$($run_date)_orders_combined_cert.txt"
        New-Item -ItemType File $out_file -Force > $null

        Write-Log -log_file $log_file -message "Total to combine: $($total_to_combine_orders_cert.Count). Combining .cof files now."
        Write-Verbose "Total to combine: $($total_to_combine_orders_cert.Count). Combining .cof files now."

        foreach($file in $total_to_combine_orders_cert)
        {
            Process-KeyboardCommands -sw $($sw)

            Get-Content "$($cof_directory_working)\$file" | Add-Content $out_file
            if($?)
            {
                $hash = @{
                    'FILE' = $($file.FullName)
                    'STATUS' = 'SUCCESS'
                }

                $order_combined = New-Object -TypeName PSObject -Property $hash
                $orders_combined += $order_combined

	            $status = "Combining '*c.prt' files."
	            $activity = "Processing file $($orders_combined.Count) of $($total_to_combine_orders_cert.Count)."
	            $percent_complete = (($($orders_combined.Count)/$($total_to_combine_orders_cert.Count)) * 100)
	            $current_operation = "$("{0:N2}" -f ((($($orders_combined.Count)/$($total_to_combine_orders_cert.Count)) * 100),2))% Complete"
	            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	            $seconds_remaining = ($seconds_elapsed / ($($orders_combined.Count) / $total_to_combine_orders_cert.Count)) - $seconds_elapsed
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
            else
            {
                Write-Log -level [ERROR] -log_file $log_file -message " Combining .cof files failed."
                Write-Error " Combining .cof files failed."
            }
        }

        if($orders_combined.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($orders_combined_csv) file now."
            Write-Verbose "Writing $($orders_combined_csv) file now."
            $orders_combined | Select FILE, STATUS | Sort -Property FILE | Export-Csv "$($orders_combined_csv)" -NoTypeInformation -Force
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to combine: $($total_to_combine_orders_cert.Count). No .cof files in $($cof_directory_working) to combine. Make sure to split and edit '*c.prt' files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
        Write-Warning -Message " Total to combine: $($total_to_combine_orders_cert.Count). No .cof files in $($cof_directory_working) to combine. Make sure to split and edit '*c.prt' files first. Use '$($script_name) -sc' first, then use '$($script_name) -ec', then try again."
    }
}