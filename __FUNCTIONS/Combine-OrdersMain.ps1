function Combine-OrdersMain()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $mof_directory_working,
        [Parameter(mandatory = $true)] $run_date,
        [Parameter(mandatory = $true)] $exclude_directories,
        [Parameter(mandatory = $true)] $iperms_integrator
    )

    $total_to_combine_orders_main = @(Get-ChildItem -Path $($mof_directory_working) -File -Filter "*_edited.mof")

    if($($($total_to_combine_orders_main.Count)) -gt '0')
    {
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        Write-Log -log_file $log_file -message "Total to combine: $($total_to_combine_orders_main.Count). Combining .mof files now."
        Write-Verbose "Total to combine: $($total_to_combine_orders_main.Count). Combining .mof files now."

        $order_files = @(
        Get-ChildItem -Path $($mof_directory_working) -File -Filter "*_edited.mof" | 
        Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } | 
        Select -First 250 | 
        Select FullName
        )

        $order_files_count = $($order_files).Count

        $start = 1
        $end = $order_files.Count

        do{
            Process-KeyboardCommands -sw $($sw)
            
            $out_file = "$($ordmanagers_iperms_integrator_output)\$($run_date)\$($start)-$($end).txt"

            if(!(Test-Path "$($ordmanagers_iperms_integrator_output)\$($run_date)"))
            {
                Write-Log -log_file $($log_file) -message "$($ordmanagers_iperms_integrator_output)\$($run_date) not created. Creating now."
                Write-Verbose "$($ordmanagers_iperms_integrator_output)\$($run_date) not created. Creating now."
                New-Item -ItemType Directory -Path "$($ordmanagers_iperms_integrator_output)\$($run_date)" -Force > $null
                
                if($?)
                {
                    Write-Log -log_file $($log_file) -message "$($ordmanagers_iperms_integrator_output)\$($run_date) created successfully."
                    Write-Verbose "$($ordmanagers_iperms_integrator_output)\$($run_date) created successfully."                        
                }
                else
                {
                    Write-Log -level [ERROR] -log_file $($log_file) -message "$($ordmanagers_iperms_integrator_output)\$($run_date) creation failed."
                    Write-Error "$($ordmanagers_iperms_integrator_output)\$($run_date) creation failed."    
                    throw "$($ordmanagers_iperms_integrator_output)\$($run_date) creation failed."
                }
            }
            
            # Set outfile name for each batch
            Write-Log -log_file $log_file -message "Name of outfile is $($out_file)."
            Write-Verbose "Name of outfile is $($out_file)."

            New-Item -ItemType File $out_file -Force > $null

            # Combine 250 files into batch
            Write-Log -log_file $log_file -message "Combining $($start) - $($end) files into $($out_file)."
            Write-Verbose "Combining $($start) - $($end) files into $($out_file)."
            $order_files | % { Get-Content $_.FullName | Add-Content $($out_file) }

            # Move files out
            Write-Log -log_file $log_file -message "Moving original $($start) - $($end) files into $($mof_directory_original_splits_working)\$($_.Name)."
            Write-Verbose "Moving original $($start) - $($end) files into $($mof_directory_original_splits_working)\$($_.Name)."
            $order_files | % { Move-Item $_.FullName "$($mof_directory_original_splits_working)\$($_.Name)" }

            # Repopulate array
            $order_files = @(Get-ChildItem -Path "$($mof_directory_working)" -File | Where { $_.Extension -eq '.mof' } | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } | Select -First 250 | Select FullName)
            $order_files_count = $($order_files).Count

            $start = $end + 1
            $end = $start + $($order_files_count) - 1
        }
        While($order_files_count -ne 0)


        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to combine: $($total_to_combine_orders_main.Count). No .mof files in $($mof_directory_working) to combine. Make sure to split and edit '*m.prt' files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
        Write-Warning -Message " Total to combine: $($total_to_combine_orders_main.Count). No .mof files in $($mof_directory_working) to combine. Make sure to split and edit '*m.prt' files first. Use '$($script_name) -sm' first, then use '$($script_name) -em', then try again."
    }
}