function Clean-UICS()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uics_directory_output
    )

    $total_to_clean_uics_directories = Get-ChildItem -Path "$($uics_directory_output)"

    if($($total_to_clean_uics_directories.Count) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total UICS directories to clean in $($uics_directory_output): $($total_to_clean_uics_directories.Count)."
        Write-Verbose "Total UICS directories to clean in $($uics_directory_output): $($total_to_clean_uics_directories.Count)."
        Remove-Item -Recurse -Force -Path "$($uics_directory_output)"

        if($?)
        {
            Write-Log -log_file $log_file -message "$($uics_directory_output) removed successfully. Cleaned: $($total_to_clean_uics_directories.Count) directories from $($uics_directory_output)."
            Write-Verbose "$($uics_directory_output) removed successfully. Cleaned: $($total_to_clean_uics_directories.Count) directories from $($uics_directory_output)."

            Write-Log -log_file $log_file -message "Creating $($uics_directory_output) now."
            Write-Verbose "Creating $($uics_directory_output) now."

            New-Item -ItemType Directory -Path "$($uics_directory_output)" -Force > $null
            if($?)
            {
                Write-Log -log_file $log_file -message "$($uics_directory_output) created successfully."
                Write-Verbose "$($uics_directory_output) created successfully."
            }

        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to remove $($uics_directory_output). Make sure you don't have any files in $($uics_directory_output) open still."
            Write-Error -Message " Failed to remove $($uics_directory_output). Make sure you don't have any files in $($uics_directory_output) open still."
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total directories to clean: $($total_to_clean_uics_directories.Count). No directories in $($uics_directory_output) to clean up."
        Write-Warning -Message " Total directories to clean: $($total_to_clean_uics_directories.Count). No directories in $($uics_directory_output) to clean up."
    }
}