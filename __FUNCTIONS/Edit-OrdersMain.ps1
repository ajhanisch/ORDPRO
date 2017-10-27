function Edit-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $regex_old_fouo_3_edit_orders_main,
        [Parameter(mandatory = $true)] $mof_directory_original_splits_working
    )

    $total_to_edit_orders_main = Get-ChildItem -Path "$($mof_directory_working)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof' }

    if($($total_to_edit_orders_main.Count) -gt '0')
    {
        $orders_edited = @()
        $orders_not_edited = @()

        $orders_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_edited_main.csv"
        $orders_not_edited_csv = "$($log_directory_working)\$($run_date)\$($run_date)_orders_not_edited_main.csv"

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total to edit: $($total_to_edit_orders_main.Count)."
        Write-Verbose "Total to edit: $($total_to_edit_orders_main.Count)."

        foreach($file in (Get-ChildItem -Path "$($mof_directory_working)" -Exclude "*_edited.mof" | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.mof'}))
        {
            Process-KeyboardCommands -sw $($sw)

            $following_request = "Following Request is" # Disapproved || Approved
            $following_request_exists = (Select-String -Path "$($file)" -Pattern $($following_request) -AllMatches | Select -First 1)
            $following_order = "Following order is." # Amendment order. $($format.Length) -eq 4
            $following_order_exists = (Select-String -Path "$($file)" -Pattern $($following_order) -AllMatches | Select -First 1)

            if(!((Get-Item "$($file)") -is [System.IO.DirectoryInfo]))
            {
                Write-Log -log_file $log_file -message "Editing $($file.Name) in round 1 now."
                Write-Verbose "Editing $($file.Name) in round 1 now."
                
                $out_file_name = "$($file.BaseName)_edited.mof"

                $file_content = (Get-Content "$($file)" | Select -Skip 1 )
                $file_content = @('                               STATE OF SOUTH DAKOTA') + $file_content

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
                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $file_content

                if($?)
                {
                    Write-Log -log_file $log_file -message "$($file.Name) edited in round 1 successfully."
                    Write-Verbose "$($file.Name) edited in round 1 successfully."

                    if($($file.Name) -cnotcontains "*_edited.mof")
                    {
                        Write-Log -log_file $log_file -message "Moving $($file.Name) to $($mof_directory_original_splits_working)"
                        Write-Verbose "Moving $($file.Name) to $($mof_directory_original_splits_working)"

                        Move-Item "$($file)" -Destination "$($mof_directory_original_splits_working)\$($file.Name)" -Force

                        if($?)
                        {
                            Write-Log -log_file $log_file -message "$($file) moved to $($mof_directory_original_splits_working) successfully."
                            Write-Verbose "$($file) moved to $($mof_directory_original_splits_working) successfully."
                        }
                        else
                        {
                            Write-Log -level [ERROR] -log_file $log_file -message " $($file) move to $($mof_directory_original_splits_working) failed."
                            Write-Error " $($file) move to $($mof_directory_original_splits_working) failed."
                        }
                    }
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $log_file -message " $($file.Name) editing in round 1 failed."
                    Write-Error " $($file.Name) editing in round 1 failed."

                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message " $($file.Name) editing in round 1 failed."
                        Write-Error " $($file.Name) editing in round 1 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '2'
                            'STATUS' = 'FAILED'
                            'REASON' = " $($file.Name) editing in round 1 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }

                # Remove bad spacing between 'Marital status / Number of dependents' and 'Type of incentive pay'
                Write-Log -log_file $log_file -message "Editing $($out_file_name) in round 2 now."
                Write-Verbose "Editing $($out_file_name) in round 2 now."

                $pattern_1 = '(?smi)Marital status / Number of dependents: \w{1,}(.*?)Type of incentive pay: \w{1,}'
                $string_1 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_1 = [regex]::Matches($string_1,$pattern_1).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Log -level [WARN] -log_file $log_file -message " $($out_file_name) is not the proper format to be edited in round 2. Not editing this file at this time as it is not needed."
                    Write-Warning " $($out_file_name) is not the proper format to be edited in round 2. Not editing this file at this time as it is not needed."
                }
                $good_output_1 = $bad_output_1.Replace("`n`r`n`r`n","")
                $string_1 = $string_1 -replace $bad_output_1,$good_output_1

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_1
                if($?)
                {
                    Write-Log -log_file $log_file -message "$($out_file_name) edited in round 2 successfully."
                    Write-Verbose "$($out_file_name) edited in round 2 successfully."
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message " $($out_file_name) edit in round 2 failed."
                        Write-Error " $($out_file_name) edit in round 2 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '2'
                            'STATUS' = 'FAILED'
                            'REASON' = " $($out_file_name) edit in round 2 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }

                # Remove bad spacing between 'APC DJMS-RC' and 'APC STANFINS Pay'
                Write-Log -log_file $log_file -message "Editing $($out_file_name) in round 3 now."
                Write-Verbose "Editing $($out_file_name) in round 3 now."

                $pattern_2 = '(?smi)APC DJMS-RC: \w{1,}(.*?)APC STANFINS Pay:  \w{1,}'
                $string_2 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_2 = [regex]::Matches($string_2,$pattern_2).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    Write-Log -level [WARN] -log_file $log_file -message " $($out_file_name) is not the proper format to be edited in round 3. Not editing this file at this time as it is not needed."
                    Write-Warning " $($out_file_name) is not the proper format to be edited in round 3. Not editing this file at this time as it is not needed."
                }
                $good_output_2 = $bad_output_2.Replace("`n`r`n","")
                $string_2 = $string_2 -replace $bad_output_2,$good_output_2

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_2
                if($?)
                {
                    Write-Log -log_file $log_file -message "$($out_file_name) edited in round 3 successfully."
                    Write-Verbose "$($out_file_name) edited in round 3 successfully."
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message " $($out_file_name) edit in round 3 failed."
                        Write-Error " $($out_file_name) edit in round 3 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '3'
                            'STATUS' = 'FAILED'
                            'REASON' = " $($out_file_name) edit in round 3 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }

                # Remove bad spacing between 'Auth:' and 'HOR:'
                Write-Log -log_file $log_file -message "Editing $($out_file_name) in round 4 now."
                Write-Verbose "Editing $($out_file_name) in round 4 now."

                $pattern_3 = '(?smi)Auth:\s\w{1,}(.*?)HOR:\s\w{1,}'
                $string_3 = Get-Content "$($mof_directory_working)\$($out_file_name)" -Raw
                try
                {
                    $bad_output_3 = [regex]::Matches($string_3,$pattern_3).Groups[0].Value
                }
                catch [System.Management.Automation.RuntimeException] # Catch the error that happens when this variable is empty due to being wrong format file to edit.
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [WARN] -log_file $log_file -message " $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."
                        Write-Warning " $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '4'
                            'STATUS' = 'FAILED'
                            'REASON' = " $($out_file_name) is not the proper format to be edited in round 4. Not editing this file at this time as it is not needed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }
                $good_output_3 = @($bad_output_3 -split '\r\n\r\n\r\n')
                $good_output_3 = $good_output_3[0] + "`n" + $good_output_3[1]
                $string_3 = $string_3.Replace($bad_output_3,$good_output_3)

                Set-Content -Path "$($mof_directory_working)\$($out_file_name)" $string_3
                if($?)
                {
                    if( -not ($($orders_edited) -contains $file) -and -not ($($following_request_exists)) -and -not ($($following_order_exists)) )
                    {
                        Write-Log -log_file $log_file -message "$($out_file_name) edited in round 4 successfully."
                        Write-Verbose "$($out_file_name) edited in round 4 successfully."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '4'
                            'STATUS' = 'SUCCESS'
                            'REASON' = ''
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_edited += $order_edited
                    }
                }
                else
                {
                    if(-not ($($orders_not_edited) -contains $file))
                    {
                        Write-Log -level [ERROR] -log_file $log_file -message " $($out_file_name) edit in round 4 failed."
                        Write-Verbose " $($out_file_name) edit in round 4 failed."

                        $hash = @{
                            'FILE' = $($file)
                            'ROUND' = '4'
                            'STATUS' = 'FAILED'
                            'REASON' = " $($out_file_name) edit in round 4 failed."
                        }

                        $order_edited = New-Object -TypeName PSObject -Property $hash
                        $orders_not_edited += $order_edited
                    }
                }
            }
            else
            {
                Write-Log -level [WARN] -log_file $log_file -message "$($file) is a directory. Skipping."
                Write-Verbose "$($file) is a directory. Skipping."
            }

	        $status = "Editing '*m.prt' files."
	        $activity = "Processing file $($orders_edited.Count) of $($total_to_edit_orders_main.Count). $($orders_not_edited.Count) of $($total_to_edit_orders_main.Count) not edited."
	        $percent_complete = (($($orders_edited.Count)/$($total_to_edit_orders_main.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($($orders_edited.Count)/$($total_to_edit_orders_main.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($($orders_edited.Count) / $($total_to_edit_orders_main.Count))) - $seconds_elapsed
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
            $orders_edited | Select FILE, ROUND, STATUS, REASON | Sort -Property FILE | Export-Csv "$($orders_edited_csv)" -NoTypeInformation -Force
        }

        if($orders_not_edited.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($orders_not_edited_csv) file now."
            Write-Verbose "Writing $($orders_not_edited_csv) file now."
            $orders_not_edited | Select FILE, ROUND, STATUS, REASON | Sort -Property FILE | Export-Csv "$($orders_not_edited_csv)" -NoTypeInformation -Force
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to edit: $($total_to_edit_orders_main.Count). No .mof files in $($mof_directory_working). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
        Write-Warning -Message " Total to edit: $($total_to_edit_orders_main.Count). No .mof files in $($mof_directory_working). Make sure to split *m.prt files first. Use '$($script_name) -sm' first, then try again."
    }
}