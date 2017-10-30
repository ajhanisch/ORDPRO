function Clean-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )

    $total_to_clean_main_files = (Get-ChildItem -Path "$($mof_directory_working)" -Recurse)

    if($($total_to_clean_main_files.Count) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total .mof files to clean in $($mof_directory_working): $($total_to_clean_main_files.Count)"
        Write-Verbose "Total .mof files to clean in $($mof_directory_working): $($total_to_clean_main_files.Count)"
        Remove-Item -Path "$($mof_directory_working)" -Recurse -Force

        if($?)
        {
            Write-Log -log_file $log_file -message "$($mof_directory_working) removed successfully. Cleaned: $($total_to_clean_main_files.Count) .mof files from $($mof_directory_working)."
            New-Item -ItemType Directory -Path "$($mof_directory_working)" -Force > $null
            Start-Sleep -Milliseconds 250
            Write-Verbose "$($mof_directory_working) removed successfully. Cleaned: $($total_to_clean_main_files.Count) .mof files from $($mof_directory_working)."

            Write-Log -log_file $log_file -message "Creating $($mof_directory_working) now."
            Write-Verbose "Creating $($mof_directory_working) now."
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($mof_directory_working)" -Force > $null
            if($?)
            {
                Write-Log -log_file $log_file -message "$($mof_directory_working) created successfully."
                Write-Verbose "$($mof_directory_working) created successfully."
            }


            Write-Log -log_file $log_file -message "Creating $($mof_directory_working) now."
            Write-Verbose "Creating $($mof_directory_working) now."
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($mof_directory_working)" -Force > $null
            if($?)
            {
                Write-Log -log_file $log_file -message "$($mof_directory_working) created successfully."
                Write-Verbose "$($mof_directory_working) created successfully."
            }
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to remove $($mof_directory_working). Make sure you don't have any files in the directory open still."
            Write-Error -Message " Failed to remove $($mof_directory_working). Make sure you don't have any files in the directory open still."
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total .mof files to clean: $($total_to_clean_main_files.Count). No .mof files in $($mof_directory_working) to clean up."
        Write-Warning " Total .mof files to clean: $($total_to_clean_main_files.Count). No .mof files in $($mof_directory_working) to clean up."
    }
}