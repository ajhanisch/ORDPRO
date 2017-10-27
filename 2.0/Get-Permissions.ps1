function Get-Permissions()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uics_directory_output
    )

    if(Test-Path $($uics_directory_output))
    {
        $permissions_reports_directory = "$($uics_directory_output)\__PERMISSIONS"
        $uics_directory = $uics_directory_output.Split('\')
        $uics_directory = $uics_directory[-1]

        $html_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.html"
        $csv_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.csv"
        $txt_report = "$($permissions_reports_directory)\$($run_date)\$($uics_directory)_permissions_report.txt"
$css = 
@"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { font-size: 17px; background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 12px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        if(!(Test-Path "$($permissions_reports_directory)\$($run_date)"))
        {
            Write-Log -log_file $log_file -message "$($permissions_reports_directory)\$($run_date) not created. Creating now."
            Write-Verbose "$($permissions_reports_directory)\$($run_date) not created. Creating now."
            New-Item -ItemType Directory -Path "$($permissions_reports_directory)\$($run_date)" > $null

            if($?)
            {
                Write-Log -log_file $log_file -message "$($permissions_reports_directory)\$($run_date) created successfully."
                Write-Verbose "$($permissions_reports_directory)\$($run_date) created successfully."
            }
        }

        Write-Log -log_file $log_file -message "Writing permissions of $($uics_directory_output) to .csv file now."
        Write-Verbose "Writing permissions of $($uics_directory_output) to .csv file now."

        Get-ChildItem -Path $($uics_directory_output) -Exclude '__PERMISSIONS' -Directory | 
            Select-Object Name, LastWriteTime, @{Label="Owner";Expression={(Get-Acl $_.FullName).Owner}} | 
            Export-Csv -Force -NoTypeInformation $($csv_report)
        if($?)
        {
            Write-Log -log_file $log_file -message "$($uics_directory_output) permissions writing to .csv finished successfully."
            Write-Verbose "$($uics_directory_output) permissions writing to .csv finished successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " $($uics_directory_output) permissions writing to .csv failed."
            Write-Error -Message " $($uics_directory_output) permissions writing to .csv failed."
        }

        Write-Log -log_file $log_file -message "Writing permissions of $($uics_directory_output) to .html file now."
        Write-Verbose "Writing permissions of $($uics_directory_output) to .html file now."

        Get-ChildItem -Path $($uics_directory_output)  -Exclude '__PERMISSIONS' -Directory | 
            Select-Object Name, LastWriteTime, @{Label="Owner";Expression={(Get-Acl $_.FullName).Owner}} | 
            ConvertTo-Html -Title "$($uics_directory_output) Permissions Report" -Head $($css) -Body "<h1>$($uics_directory_output) Permissions Report</h1> <h5> Generated on $(Get-Date -UFormat "%Y-%m-%d @ %H-%M-%S")" | 
            Out-File $($html_report)
        if($?)
        {
            Write-Log -log_file $log_file -message "$($uics_directory_output) permissions writing to .html finished successfully."
            Write-Verbose "$($uics_directory_output) permissions writing to .html finished successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " $($uics_directory_output) permissions writing to .html failed."
            Write-Error -Message " $($uics_directory_output) permissions writing to .html failed."
        }

        Write-Log -log_file $log_file -message "Writing permissions of $($uics_directory_output) to .txt file now."
        Write-Verbose "Writing permissions of $($uics_directory_output) to .txt file now."

        Get-ChildItem -Path $($uics_directory_output) -Exclude '__PERMISSIONS' -Directory | 
            Select-Object Name, LastWriteTime, @{Label="Owner";Expression={(Get-Acl $_.FullName).Owner}} |
            Format-Table -AutoSize -Wrap | 
            Out-File $($txt_report)
        if($?)
        {
            Write-Log -log_file $log_file -message "$($uics_directory_output) permissions writing to .txt finished successfully."
            Write-Verbose "$($uics_directory_output) permissions writing to .txt finished successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " $($uics_directory_output) permissions writing to .txt failed."
            Write-Error -Message " $($uics_directory_output) permissions writing to .txt failed."
        }
    }
    else
    {
        Write-Log -level [ERROR] -log_file $log_file -message " $($uics_directory_output) does not exist. Make sure to run $($script_name) -d -o '\\path\to\desired\output' and try again."
        Write-Error -Message " $($uics_directory_output) does not exist. Make sure to run $($script_name) -d -o '\\path\to\desired\output' and try again."
    }
}