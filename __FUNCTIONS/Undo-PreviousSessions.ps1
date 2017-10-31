function Undo-PreviousSessions()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $input_remove,
        [Parameter(mandatory = $true)] $results_remove
    )

    $start_time = Get-Date
    Write-Log -log_file $log_file -message "Start time: $($start_time)."
    Write-Verbose "Start time: $($start_time)."
    Write-Verbose "Input: $($input_remove)."
    $csvs_in_path = @(Get-ChildItem -Path $($input_remove) -Recurse -Include *.csv | Where { $_.Name -like '*_orders_created_*.csv' })

    if($($csvs_in_path.Count) -gt 0)
    {
        foreach($csv in $csvs_in_path)
        {

            # Call function to allow for keyboard commands during function runtime.
            Process-KeyboardCommands -sw $($sw)

            $format_165 = @()
            $format_172 = @()
            $format_700 = @()
            $format_705 = @()
            $format_290 = @()
            $format_others = @()
            $format_1020A = @()

            $files_removed = @()
            $files_not_removed = @()

            $files_removed_csv = "$($results_remove)\$($run_date)_files_removed.csv"
            $files_not_removed_csv = "$($results_remove)\$($run_date)_files_not_removed.csv"

            $formats = @{
                F_165 = $format_165;
                F_172 = $format_172;
                F_700 = $format_700;
                F_705 = $format_705;
                F_290 = $format_290;
                F_OTHERS = $format_others;
                F_1020A = $format_1020A;
            }

            $data = Import-csv $csv.FullName
            foreach($d in $data)
            {
                # Call function to allow for keyboard commands during function runtime.
                Process-KeyboardCommands -sw $($sw)

			    if($d.FORMAT -eq '165')
			    {
                    $file_name = "$($d.PUBLISHED_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.PERIOD_FROM_YEAR)$($d.PERIOD_FROM_MONTH)$($d.PERIOD_FROM_DAY)___NTE$($d.PERIOD_TO_NUMBER)$($d.PERIOD_TO_TIME)___$($d.FORMAT).txt"
				    $format_165 += $file_name
			    }
			    elseif($d.FORMAT -eq '172')
			    {
                    $file_name = "$($d.PUBLISHED_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.PERIOD_FROM_YEAR)$($d.PERIOD_FROM_MONTH)$($d.PERIOD_FROM_DAY)___$($d.PERIOD_TO_YEAR)$($d.PERIOD_TO_MONTH)$($d.PERIOD_TO_DAY)___$($d.FORMAT).txt"
				    $format_172 += $file_name
			    }
			    elseif($d.FORMAT -eq '700')
                {
                    $file_name = "$($d.PUBLISHED_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.ORDER_AMENDED)___$($d.FORMAT).txt"
				    $format_700 += $file_name
                }
			    elseif($d.FORMAT -eq '705')
                {
                    $file_name = "$($d.PUBLISHED_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.ORDER_REVOKE)___$($d.FORMAT).txt"
                    $format_705 += $file_name
                }
			    elseif($d.FORMAT -eq '290')
                {
                    $file_name = "$($d.PUBLISHED_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.PERIOD_FROM_YEAR)$($d.PERIOD_FROM_MONTH)$($d.PERIOD_FROM_DAY)___$($d.PERIOD_TO_YEAR)$($d.PERIOD_TO_MONTH)$($d.PERIOD_TO_DAY)___$($d.FORMAT).txt"
				    $format_290 += $file_name
                }
			    elseif($d.FORMAT -eq '296' -or $d.FORMAT -eq '282' -or $d.FORMAT -eq '294' -or $d.FORMAT -eq '284')
                {
                    $file_name = "$($d.PUBLISHED_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.PERIOD_FROM_YEAR)$($d.PERIOD_FROM_MONTH)$($d.PERIOD_FROM_DAY)___$($d.PERIOD_TO_YEAR)$($d.PERIOD_TO_MONTH)$($d.PERIOD_TO_DAY)___$($d.FORMAT).txt"
				    $format_others += $file_name
			    }
                elseif($d.FORMAT -eq '102-10A')
                {
                    $file_name = "$($d.PERIOD_FROM_YEAR)___$($d.SSN)___$($d.ORDER_NUMBER)___$($d.PERIOD_FROM_YEAR)$($d.PERIOD_FROM_MONTH)$($d.PERIOD_FROM_DAY)___$($d.PERIOD_TO_YEAR)$($d.PERIOD_TO_MONTH)$($d.PERIOD_TO_DAY)___cert.txt"
                    $format_1020A += $file_name
                }
            }
        }

        $total_files_to_remove = @( $($format_165) + $($format_172) + $($format_700) + $($format_705) + $($format_290) + $($format_others) + $($format_1020A) )

        # Add arrays to hash table
        $formats.Set_Item("F_165",$format_165)
        $formats.Set_Item("F_172",$format_172)
        $formats.Set_Item("F_700",$format_700)
        $formats.Set_Item("F_705",$format_705)
        $formats.Set_Item("F_290",$format_290)
        $formats.Set_Item("F_OTHERS",$format_others)
        $formats.Set_Item("F_1020A",$format_1020A)   

        # Populate array to hold current files
        $files_uics = Get-ChildItem -Path "$($uics_directory_output)" -Exclude "__PERMISSIONS" -Recurse -Include "*.txt" | Select Directory, Name
        $files_ord_managers = Get-ChildItem -Path "$($ordmanagers_orders_by_soldier_output)" -Exclude "__PERMISSIONS" -Recurse -Include "*.txt" | Select Directory, Name
        $dir_file_uics = @{}
        $dir_file_ord_managers = @{}

        # Populate hash table to hold directory and file name of files created prviously that wish to be removed.
        foreach($f in $files_uics)
        {
            # If hash table doesn't contain key of $($f.Name), add the file name and directory to hash table.
            if(!($dir_file_uics.ContainsKey($($f.Name))))
            {
                $($dir_file_uics.Add($($f.Name), $($f.Directory)))
            }
        }

        foreach($f in $files_ord_managers)
        {
            # If hash table doesn't contain key of $($f.Name), add the file name and directory to hash table.
            if(!($dir_file_ord_managers.ContainsKey($($f.Name))))
            {
                $($dir_file_ord_managers.Add($($f.Name), $($f.Directory)))
            }
        }

        # Search each format array for files already created, remove them if found, add success and failure results to csv.
        foreach($f in $dir_file_uics.GetEnumerator())
        {
            $file_name = $f.Key
            $file_directory = $f.Value

            foreach($kvp in $formats.GetEnumerator())
            {
                # Call function to allow for keyboard commands during function runtime.
                Process-KeyboardCommands -sw $($sw)

                $format_type = $kvp.Key
                $format_value = $kvp.Value

                if($($format_value) -contains $($file_name) -and $($files_removed) -notcontains $($file_name))
                {
                    Write-Log -log_file $log_file -message "Found $($file_name) in $($format_type). Removing $($file_directory)\$($file_name)."
                    Write-Verbose "Found $($file_name) in $($format_type). Removing $($file_directory)\$($file_name)."

                    Remove-Item -Path "$($file_directory)\$($file_name)" -Force
                    if($?)
                    {
                        Write-Log -log_file $log_file -message "$($file_name) removed from $($file_directory) successfully."
                        Write-Verbose "$($file_name) removed from $($file_directory) successfully."
                    }

                    $hash = @{
                        FILE = $($file_name);
                        DIRECTORY = $($file_directory);
                        FORMAT = $($format_type);
                        STATUS = 'REMOVED';
                    }

                    $file_removed = New-Object -TypeName PSObject -Property $hash
                    $files_removed += $file_removed

                    #Write-Log -log_file $log_file -message "Files Removed: $($files_removed.Count)."
                    #Write-Verbose "Files Removed: $($files_removed.Count)."
                }
                else
                {
                    #Write-Log -log_file $log_file -message "$($file_name) not found in $($format_type). Do not remove."
                    #Write-Verbose "$($file_name) not found in $($format_type). Do not remove."
                    $files_not_removed += $($file_name)

                    <#
                    $hash = @{
                        FILE = $($file_name);
                        DIRECTORY = $($file_directory);
                        FORMAT = $($format_type);
                        STATUS = 'NOT REMOVED';
                    }

                    $file_not_removed = New-Object -TypeName PSObject -Property $hash
                    $files_not_removed += $file_not_removed
                    #>
                }
            }
        }

        foreach($f in $dir_file_ord_managers.GetEnumerator())
        {
            $file_name = $f.Key
            $file_directory = $f.Value

            foreach($kvp in $formats.GetEnumerator())
            {
                # Call function to allow for keyboard commands during function runtime.
                Process-KeyboardCommands -sw $($sw)

                $format_type = $kvp.Key
                $format_value = $kvp.Value

                if($($format_value) -contains $($file_name) -and $($files_removed) -notcontains $($file_name))
                {
                    Write-Log -log_file $log_file -message "Found $($file_name) in $($format_type). Removing $($file_directory)\$($file_name)."
                    Write-Verbose "Found $($file_name) in $($format_type). Removing $($file_directory)\$($file_name)."

                    Remove-Item -Path "$($file_directory)\$($file_name)" -Force
                    if($?)
                    {
                        Write-Log -log_file $log_file -message "$($file_name) removed from $($file_directory) successfully."
                        Write-Verbose "$($file_name) removed from $($file_directory) successfully."
                    }

                    $hash = @{
                        FILE = $($file_name);
                        DIRECTORY = $($file_directory);
                        FORMAT = $($format_type);
                        STATUS = 'REMOVED';
                    }

                    $file_removed = New-Object -TypeName PSObject -Property $hash
                    $files_removed += $file_removed

                    #Write-Log -log_file $log_file -message "Files Removed: $($files_removed.Count)."
                    #Write-Verbose "Files Removed: $($files_removed.Count)."
                }
                else
                {
                    #Write-Log -log_file $log_file -message "$($file_name) not found in $($format_type). Do not remove."
                    #Write-Verbose "$($file_name) not found in $($format_type). Do not remove."
                    $files_not_removed += $($file_name)

                    <#
                    $hash = @{
                        FILE = $($file_name);
                        DIRECTORY = $($file_directory);
                        FORMAT = $($format_type);
                        STATUS = 'NOT REMOVED';
                    }

                    $file_not_removed = New-Object -TypeName PSObject -Property $hash
                    $files_not_removed += $file_not_removed
                    #>
                }
            }
        }

        # Write results
        if($files_removed.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Writing $($files_removed_csv) file now."
            Write-Verbose "Writing $($files_removed_csv) file now."
            $files_removed | Select FILE, DIRECTORY, FORMAT, STATUS | Sort -Property FILE | Export-Csv "$($files_removed_csv)" -NoTypeInformation -Force
            Write-Verbose "Files removed: $($files_removed.Count)."
        }

        if($files_not_removed.Count -gt 0)
        {
            Write-Log -log_file $log_file -message "Files not removed: $($files_not_removed.Count)."
            Write-Verbose "Files not removed: $($files_not_removed.Count)."
            
            <#
            Write-Log -log_file $log_file -message "Writing $($files_not_removed_csv) file now."
            Write-Verbose "Writing $($files_not_removed_csv) file now."
            $files_not_removed | Select FILE, DIRECTORY, FORMAT, STATUS | Sort -Property FILE | Export-Csv "$($files_not_removed_csv)" -NoTypeInformation -Force
            #>
        }

        $end_time = Get-Date
        Write-Log -log_file $log_file -message "End time: $($end_time)."
        Write-Verbose "End time: $($end_time)."
    }
    else
    {
        Write-Log -level [WARN] -log_file $log_file -message " Total to remove: $($total_files_to_remove). No files to remove. Make sure to have the required .csv files in the input directory and try again."
        Write-Warning -Message " Total to remove: $($total_files_to_remove). No files to remove. Make sure to have the required .csv files in the input directory and try again."
    }
}