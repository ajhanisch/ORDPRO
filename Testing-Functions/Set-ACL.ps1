function Set-Permissions()
{
    [CmdletBinding()]
    param(
        [string] $input_path
    )

    # Set permissions for each UIC in UICS.

    $uics = @(Get-ChildItem -Path "$($input_path)" -Exclude "__PERMISSIONS" -Directory -ErrorAction SilentlyContinue | Select-Object *)

    if($($uics.Count) -gt 0)
    {
        $sw = New-Object System.Diagnostics.Stopwatch
        $sw.start()

        $start_time = Get-Date
        Write-Log -log_file $log_file -message "Start time: $($start_time)."
        Write-Verbose "Start time: $($start_time)."

        $permissions_assigned = @()
        $permissions_not_assigned = @()
        $permissions_assigned_csv = "$($log_directory_working)\$($run_date)\$($run_date)_permissions_assigned.csv"
        $permissions_not_assigned_csv = "$($log_directory_working)\$($run_date)\$($run_date)_permissions_not_assigned.csv"

        foreach($u in $uics)
        {
            Process-KeyboardCommands -sw $($sw)

            $uic = $($u.BaseName)
            $uic_path = $($u.FullName)
        
            $target = "NGSD-FG-W" + $($uic) + "-ORD_R"
            Write-Debug "Target is $($target)."
            $group =  (Get-ADGroup -Filter {name -eq $target}).Name

            if(!($group))
            {
                $group = "N/A"
                $acl_old = "N/A"
                $acl_new = "N/A" 
            
                Write-Log -level [ERROR] -log_file $($log_file) -message "No group for $($uic) found. Skipping for now.  Make sure to create a group for $($uic) soon."
                Write-Verbose "No group for $($uic) found. Skipping for now.  Make sure to create a group for $($uic) soon."
            
                # Add path results to array
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType NoteProperty -Name PATH -Value $($uic_path)
                $object | Add-Member -MemberType NoteProperty -Name UIC -Value $($uic)
                $object | Add-Member -MemberType NoteProperty -Name GROUP -Value $($group)
                $object | Add-Member -MemberType NoteProperty -Name ACL_OLD -Value $($acl_old)
                $object | Add-Member -MemberType NoteProperty -Name ACL_NEW -Value $($acl_new)
                $results += $object
            }
            else
            {
                Write-Log -log_file $($log_file) -message "Setting 'READ' permissions for UIC group '$($group)'."
                Write-Verbose "Setting 'READ' permissions for '$($uic)' group '$($group)'."

                # Get the current ACL
                $acl_old = (Get-Acl $($uic_path))

                # Change the current ACL
                $access_rule = (New-Object System.Security.AccessControl.FileSystemAccessRule("$group", "Read", "ContainerInherit,ObjectInherit", "None", "Allow"))

                # Set the new ACL
                $acl_old.SetAccessRule($access_rule)
                Set-Acl "$($uic_path)" $($acl_old)

                if($?)
                {
                    # Check new ACL
                    $acl_new = (Get-Item $uic_path).GetAccessControl('Access').Access

                    # Add path results to array
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name PATH -Value $($uic_path)
                    $object | Add-Member -MemberType NoteProperty -Name UIC -Value $($uic)
                    $object | Add-Member -MemberType NoteProperty -Name GROUP -Value $($group)
                    $object | Add-Member -MemberType NoteProperty -Name ACL_OLD -Value $($acl_old)
                    $object | Add-Member -MemberType NoteProperty -Name ACL_NEW -Value $($acl_new)
                    $permissions_assigned += $object

                    Write-Log -log_file $($log_file) -message "Setting 'READ' permissions for '$($uic)' group '$($group)' set successfully."
                    Write-Verbose "'READ' permissions for '$($uic)' group '$($group)' set successfully."
                }
                else
                {
                    $acl_new = "N/A"
                    $error = $_

                    # Add path results to array
                    $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name PATH -Value $($uic_path)
                    $object | Add-Member -MemberType NoteProperty -Name UIC -Value $($uic)
                    $object | Add-Member -MemberType NoteProperty -Name GROUP -Value $($group)
                    $object | Add-Member -MemberType NoteProperty -Name ACL_OLD -Value $($acl_old)
                    $object | Add-Member -MemberType NoteProperty -Name ACL_NEW -Value $($acl_new)
                    $object | Add-Member -MemberType NoteProperty -Name ERROR -Value $($error)
                    $permissions_not_assigned += $object

                    Write-Log -level [ERROR] -log_file $($log_file) -message "'READ' permissions for '$($uic)' group '$($group)' failed."
                    Write-Verbose "Setting 'READ' permissions for '$($uic)' group '$($group)' failed."                
                }
            }

	        $status = "Assigning permissions to $($input_path)."
	        $activity = "Processing directory $($permissions_assigned.Count) of $($uics.Count). $($permissions_not_assigned.Count) of $($uics.Count) not permissioned."
	        $percent_complete = (($($permissions_assigned.Count)/$($uics.Count)) * 100)
	        $current_operation = "$("{0:N2}" -f ((($($permissions_assigned.Count)/$($uics.Count)) * 100),2))% Complete"
	        $seconds_elapsed = ((Get-Date) - $start_time).TotalSeconds
	        $seconds_remaining = ($seconds_elapsed / ($($permissions_assigned.Count) / $($uics.Count))) - $seconds_elapsed
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



        # Set permissions for NAME_SSN folders in '\ORD_MANAGERS\ORDERS_BY_SSN' directory.

            # Code here.


        # Output results to csv.



        if($($permissions_assigned.Count) -gt '0')
        {
            Write-Log -log_file $log_file -message "Writing $($permissions_assigned_csv) file now."
            Write-Verbose "Writing $($permissions_assigned_csv) file now."
            $permissions_assigned | Select PATH, UIC, GROUP, ACL_OLD, ACL_NEW | Sort -Property GROUP | Export-Csv "$($permissions_assigned_csv)" -NoTypeInformation -Force
        }

        if($($permissions_not_assigned.Count) -gt '0')
        {
            Write-Log -log_file $log_file -message "Writing $($permissions_not_assigned_csv) file now."
            Write-Verbose "Writing $($permissions_not_assigned_csv) file now."
            $permissions_not_assigned | Select PATH, UIC, GROUP, ACL_OLD, ACL_NEW | Sort -Property GROUP | Export-Csv "$($permissions_not_assigned_csv)" -NoTypeInformation -Force
        }
    }
    else
    {
        Write-Log -level [ERROR] -log_file $($log_file) -message "$($uics.Count) UICS to work with. No UICS folders to assign permissions to. Ensure to run previous ORDPRO steps before this."
        Write-Error "$($uics.Count) UICS to work with. No UICS folders to assign permissions to. Ensure to run previous ORDPRO steps before this."
        throw "$($uics.Count) UICS to work with. No UICS folders to assign permissions to. Ensure to run previous ORDPRO steps before this."
    }
}

<#
This should do the trick:

$group = "Domain\Domain Users"

$changeme = "C:\users\tome.tanasovski1\testacl\changeme"
$addbackmodify = Join-Path $changeme "addbackmodify"

$acl = Get-Item $dir |get-acl
# This removes inheritance
$acl.SetAccessRuleProtection($true,$true)
$acl |Set-Acl

$acl = Get-Item $dir |get-acl
# This removes all access for the group in question
$acl.Access |where {$_.IdentityReference -eq $group} |%{$acl.RemoveAccessRule($_)}
# This adds Read and Execute
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($group,"ReadAndExecute","Allow")
$acl.SetAccessRule($rule)
$acl |Set-Acl

$acl = Get-Item $addbackmodify |Get-Acl
# This adds modify to the subfolder
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @($group,"Modify","Allow")
$acl.SetAccessRule($rule)
$acl |Set-Acl
#>