function Function-Template()
{
    # Define parameters and their attributes if needed.
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $parameter
    )

    # Collection of files, directories, objects, etc to work on with this function.
    $files = @()

    # Check to make sure we have any files, directories, objects, etc to work with. If not exit and explain error to user.
    if($($files.Count) -gt 0)
    {
        # Start the stopwatch object to keep track of function run time to present to user in progress bar information.
        $sw = New-Object System.Diagnostics.Stopwatch
        $sw.start()

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        # Arrays, variables, and paths to store good and bad results of function processing.
        $files_created = @()
        $files_not_created = @()
        $files_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_created.csv"
        $files_not_created_csv = "$($log_directory_working)\$($run_date)\$($run_date)_files_not_created.csv"

        foreach($f in $files)
        {
            # Call function to allow for keyboard commands during function runtime.
            Process-KeyboardCommands -sw $($sw)

            # PROCESSING CODE HERE. Capture your needed variables, objects, etc and add them to the $object below as needed.

            <# 
            Use write and throws to tell user of success and errors. Use $object to create output results of processing and to write to csv at the end.

            Write-Log -level [ERROR] -log_file $($log_file) -message ""
            Write-Verbose ""
            Write-Debug ""
            Write-Error ""
            throw ""

            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name  -Value $($)
            $files_created += $object

            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name  -Value $($)
            $files_not_created += $object
            #>

            # Set your status, activity, and replace the '$variable.Count' variables with your relevant variables above. Example: $files_created.Count & $files_not_created.Count & $files.Count
	        $status = "Creating files to $($output_path)."
	        $activity = "Processing file $($files_created.Count) of $($files.Count). $($files_not_created.Count) of $($files.Count) not permissioned."
	        $percent_complete = (($($files_created.Count)/$($files.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($($files_created.Count)/$($files.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($($files_created.Count) / $($files.Count))) - $seconds_elapsed
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

        # Output results to csv. Make sure to select your created object names from above in the Select statement below and Sort by a specific property with the Sort cmdlet.
        if($($files_created.Count) -gt '0')
        {
            Write-Log -log_file $log_file -message "Writing $($files_created_csv) file now."
            Write-Verbose "Writing $($files_created_csv) file now."
            $files_created | Select  | Sort -Property  | Export-Csv "$($files_created_csv)" -NoTypeInformation -Force
        }

        if($($files_not_created.Count) -gt '0')
        {
            Write-Log -log_file $log_file -message "Writing $($files_not_created_csv) file now."
            Write-Verbose "Writing $($files_not_created_csv) file now."
            $files_not_created | Select | Sort -Property  | Export-Csv "$($files_not_created_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        # Tell user and write to log file the details of what is missing for script to work.
        Write-Log -level [ERROR] -log_file $($log_file) -message "$($files.Count) UICS to work with. No UICS folders to assign permissions to. Ensure to run previous ORDPRO steps before this."
        Write-Error "$($files.Count) UICS to work with. No UICS folders to assign permissions to. Ensure to run previous ORDPRO steps before this."
        throw "$($files.Count) UICS to work with. No UICS folders to assign permissions to. Ensure to run previous ORDPRO steps before this."
    }
}