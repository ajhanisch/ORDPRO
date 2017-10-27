function Create-RequiredDirectories()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $directories,
        [Parameter(mandatory = $true)] $log_file
    )

    if($($directories.Count) -gt 0)
    {
        $total_directories_created = 0
        $total_directories_not_created = 0

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total to create: $($($directories.Count))."
        Write-Verbose "Total to create: $($($directories.Count))."

        foreach($directory in $directories)
        {
            Process-KeyboardCommands -sw $($sw)

            if(!(Test-Path $($directory)))
            {
                Write-Log -log_file $log_file -message "$($directory) not created. Creating now."
                Write-Verbose "$($directory) not created. Creating now."
                New-Item -ItemType Directory -Path $($directory) > $null

                if($?)
                {
                    $total_directories_created ++
                    Write-Log -log_file $log_file -message "$($directory) created successfully."
                    Write-Verbose "$($directory) created successfully."
                }
                else
                {
                    $total_directories_not_created ++
                    Write-Log -level [ERROR] -log_file $log_file -message " $($directory) creation failed. Check the error logs at $($error_path). Reach out to ORDPRO support."
                    Write-Error -Message " $($directory) creation failed. Check the error logs at $($error_path). Reach out to ORDPRO support." 
                }
            }
            else
            {
                $total_directories_created ++
                Write-Log -log_file $log_file -message "$($directory) already created."
                Write-Verbose "$($directory) already created."
            }

            $status = "Creating required directories."
            $activity = "Creating directory $total_directories_created of $($directories.Count)."
            $percent_complete = (($total_directories_created/$($directories.Count)) * 100)
            $current_operation = "$("{0:N2}" -f ((($total_directories_created/$($directories.Count)) * 100),2))% Complete"
            $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
            $seconds_remaining = ($seconds_elapsed / ($total_directories_created / $directories.Count)) - $seconds_elapsed
            $ts =  [timespan]::fromseconds($seconds_remaining)
            $ts = $ts.ToString("hh\:mm\:ss")

            if((Get-PSCallStack)[1].Arguments -like '*Verbose=True*')
            {
                Write-Log -log_file $log_file -message "$($status) $($activity) $($ts) remaining. $($current_operation)."
                Write-Verbose "$($status) $($activity) $($ts) remaining. $($current_operation)."
            }
            
            else
            {
                Write-Progress -Status $($status) -Activity $($activity) -PercentComplete $($percent_complete) -CurrentOperation $($current_operation) -SecondsRemaining $($seconds_remaining)
            }
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to create: $($($directories.Count)). No directories to create. Support: Make sure the directories array is populated with your desired directories to create."
        Write-Warning -Message " Total to create: $($($directories.Count)). No directories to create. Support: Make sure the directories array is populated with your desired directories to create."
    }
}