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
    $most_recent_time = ''
    $most_recent_uic = ''

    foreach($g in $n.Group)
    {
        Write-Host "Name: $($g.NAME). UIC: $($g.UIC). LastWriteTime: $($g.LASTWRITETIME)."
        
        if($g.LASTWRITETIME -gt $most_recent)
        {
            $most_recent_time = $($g.LASTWRITETIME)
            $most_recent_uic = $($g.UIC)

            Write-Host "Most Recent UIC: $($most_recent_uic). Most Recent Time: $($most_recent_time)."

            Read-Host -Prompt "Enter to continue"
        }
        else
        {
            Write-Host "$($g.UIC) for $($n.NAME) is not newer than $($most_recent_time) for $($most_recent_uic). Continuing."
        }
    }
}