function Clean-OrdersCertificate()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $cof_directory_working,
        [Parameter(mandatory = $true)] $exclude_directories
    )
	  
    $total_to_clean_cert_files = Get-ChildItem -Path "$($cof_directory_working)" -Recurse | Where { $_.FullName -notmatch $exclude_directories -and $_.Extension -eq '.cof' }

    if($($total_to_clean_cert_files.Count) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total .cof files to clean in $($cof_directory_working): $($total_to_clean_cert_files.Count)"
        Write-Verbose "Total .cof files to clean in $($cof_directory_working): $($total_to_clean_cert_files.Count)"
        Remove-Item -Path "$($cof_directory_working)" -Recurse -Force

        if($?)
        {
            Write-Log -log_file $log_file -message "$($cof_directory_working) removed successfully. Cleaned: $($total_to_clean_cert_files.Count) .cof files from $($cof_directory_working)."
            Write-Verbose "$($cof_directory_working) removed successfully. Cleaned: $($total_to_clean_cert_files.Count) .cof files from $($cof_directory_working)."
            Write-Log -log_file $log_file -message "Creating $($cof_directory_working) now."
            Write-Verbose "Creating $($cof_directory_working) now."
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($cof_directory_working)" -Force > $null
            if($?)
            {
                Write-Log -log_file $log_file -message "$($cof_directory_working) created successfully."
                Write-Verbose "$($cof_directory_working) created successfully."
            }

            Write-Log -log_file $log_file -message "Creating $($cof_directory_original_splits_working) now."
            Write-Verbose "Creating $($cof_directory_original_splits_working) now."
            Start-Sleep -Milliseconds 250
            New-Item -ItemType Directory -Path "$($cof_directory_original_splits_working)" -Force > $null
            if($?)
            {
                Write-Log -log_file $log_file -message "$($cof_directory_original_splits_working) created successfully."
                Write-Verbose "$($cof_directory_original_splits_working) created successfully."
            }
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to remove $($cof_directory_working). Make sure you don't have any files in $($cof_directory_working) open still."
            Write-Error -Message " Failed to remove $($cof_directory_working). Make sure you don't have any files in $($cof_directory_working) open still."
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total .cof files to clean: $($total_to_clean_cert_files.Count). No .cof files in $($cof_directory_working) to clean up."
        Write-Warning " Total .cof files to clean: $($total_to_clean_cert_files.Count). No .cof files in $($cof_directory_working) to clean up."
    }
}