function Write-Log 
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)][ValidateSet("[INFO]","[WARN]","[ERROR]","[FATAL]","[DEBUG]")][String]$level = "[INFO]",
        [Parameter(Mandatory=$true)][string]$message,
        [Parameter(Mandatory=$false)][string]$log_file
    )

    $stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $line = "$stamp $level $message"
	
    if(!(Test-Path $log_file))
    {
        New-Item -ItemType File -Path $($log_file) -Force > $null
    }

    If($log_file) 
    {            
        Add-Content $log_file -Value $line
    }
    Else 
    {
        Write-Output $line
    }
}