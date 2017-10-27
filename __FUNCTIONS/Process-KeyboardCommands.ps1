function Process-KeyboardCommands()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $sw
    )

    if ([console]::KeyAvailable)
    {
        $key = [system.console]::readkey($true)

        if(($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "P"))
        {
            Write-Log -level [INFO] -log_file $($log_file) -message "[-] Pausing at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
            Write-Host "[-] Pausing at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
            $sw.Stop()

            Write-Host "Press any key to continue..."
            [void][System.Console]::ReadKey($true)

            Write-Log -level [INFO] -log_file $($log_file) -message "[-] Resuming at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
            Write-Host "[-] Resuming at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
            $sw.Start()
        }
        elseif(($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "Q" ))
        {
            $sw.Stop()

            Do 
            {
                $response = Read-Host -Prompt "Are you sure you want to exit? [Y/N]"

                if($response -eq "Y") 
                {
                    Write-Log -level [INFO] -log_file $($log_file) -message "Terminating at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd) by user."
                    exit 0  
                }
                elseif($response -eq "N")
                {
                    Write-Log -level [INFO] -log_file $($log_file) -message "[-] Resuming at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
                    Write-Host "[-] Resuming at $(Get-Date -Format hh:mm:ss) on $(Get-Date -Format yyyy-M-dd)."
                    $sw.Start()
                    continue
                }
                else
                {
                    Write-Log -level [WARN] -log_file $($log_file) -message " Response not determined."
                    Write-Warning " Response not determined. Try again with proper input."
                }
            }
            Until ($response -eq "N")
        }
    }
}