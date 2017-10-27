function Archive-Directory
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$source,
        [Parameter(Mandatory=$true)][string]$destination
    )

    if(Test-path $destination) 
    {
        Remove-item $destination
    }

    Write-Log -level [INFO] -log_file $($log_file) -message "Zipping up $($source) to $($destination) now."
    Write-Verbose "Zipping up $($source) to $($destination) now."

    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($source, $destination)
}