$source = "C:\temp\ORDPRO\TMP\LOGS\2017-10-23_04-43-42"
$destination = "C:\temp\ORDPRO\TMP\LOGS\2017-10-23_04-43-42_archive.zip"

function Archive-Directory
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)][String]$source,
        [Parameter(Mandatory=$false)][string]$destination
    )

    if(Test-path $destination) 
    {
        Remove-item $destination
    }

    Add-Type -assembly "system.io.compression.filesystem"

    [io.compression.zipfile]::CreateFromDirectory($Source, $destination) 
}

Archive-Directory -source $($source) -destination $($destination)