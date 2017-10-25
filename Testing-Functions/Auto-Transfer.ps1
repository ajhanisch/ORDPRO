$soldiers = @()
$array = @(Get-ChildItem -Path "C:\temp\OUTPUT\UICS\*" -Exclude "__PERMISSIONS")

foreach($s in $array)
{
    $n = $s.Name -split "___"
    $name = $n[0]
    $ssn = $n[1]

    $u = $s.FullName -split "\\"
    $uic = $u[-2]

    $lastwritetime = $s.LastWriteTime

    $uic_folder = $s.Name

    $soldier = New-Object -TypeName PSObject
    $soldier | Add-Member -MemberType NoteProperty -Name NAME -Value $($name)
    $soldier | Add-Member -MemberType NoteProperty -Name SSN -Value $($ssn)
    $soldier | Add-Member -MemberType NoteProperty -Name UIC -Value $($uic)
    $soldier | Add-Member -MemberType NoteProperty -Name UIC_FOLDER -Value $($uic_folder)
    $soldier | Add-Member -MemberType NoteProperty -Name LASTWRITETIME -Value $($lastwritetime)

    $soldiers += $soldier
}

$duplicates = ( $soldiers | Group-Object NAME | Where { $_.Count -gt 1 })

foreach($n in $duplicates)
{
    $all_directories = @(Get-ChildItem -Path "C:\temp\OUTPUT\UICS\*" -Exclude "__PERMISSIONS" | Where { $_.Name -match $n.NAME } | Sort-Object LastWriteTime  -Descending)
    $most_recent_directory = @(Get-ChildItem -Path "C:\temp\OUTPUT\UICS\*" -Exclude "__PERMISSIONS" | Where { $_.Name -match $n.NAME } | Sort-Object LastWriteTime  -Descending | Select-Object -First 1)
    
    Write-Host "All directories for $($n.NAME) are: "
    foreach($d in $all_directories)
    {
        Write-Host "$($d)"
    }

    Write-Host "Most recent UIC directory for $($n.NAME) is: $($most_recent_directory)."

    Read-Host -Prompt "Enter to continue"
}