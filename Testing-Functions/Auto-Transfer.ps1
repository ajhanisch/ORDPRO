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

    if($soldiers -match $soldier.NAME)
    {
        Write-Host "$($soldier.NAME) exists in array already."
        #Read-Host -Prompt "Enter to continue."
        $soldiers += $soldier
    }
    else
    {
        Write-Host "$($soldier.NAME) does not exist in array yet. Adding now."
        $soldiers += $soldier
    }
}

$soldiers = $soldiers | Sort -Property NAME, LASTWRITETIME| Format-Table -AutoSize
$soldiers