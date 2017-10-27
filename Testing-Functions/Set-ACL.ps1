Import-Module ActiveDirectory

$uics = @(Get-ChildItem -Path "\\ng\ngsd-misc\ORDERS\UICS" -Exclude "__PERMISSIONS" -Directory -ErrorAction SilentlyContinue | Select-Object *)

$results = @()

foreach($u in $uics)
{
    $uic = $u.BaseName
    $uic_path = $u.FullName
    #$group = Get-ADGroup -Identity "NGSD-FG-W$($uic)-ORD_R" -Properties Name
    $group =  (Get-ADGroup -Filter {name -eq "NGSD-FG-W$($uic)-ORD_R"}).Name


    $object = New-Object -TypeName PSObject
    $object | Add-Member -MemberType NoteProperty -Name PATH -Value $($uic_path)
    $object | Add-Member -MemberType NoteProperty -Name UIC -Value $($uic)
    $object | Add-Member -MemberType NoteProperty -Name GROUP -Value $($group)
    $results += $object
}

foreach($r in $results)
{
    $r
    Read-Host -Prompt "Enter to continue"
}

<#
foreach ($uic in $uics_folder) {
    $Path = $uic.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $uic.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify',                 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}

Access control entries (ACEs) are the individual rights inside of an ACL. An ACE can also be called a FileSystemAccessRule. This is a .NET object that has five parameters;

    The security identifier ($Username);
    The right (Modify);
    Inheritance settings (ContainerInherit,ObjectInherit) which means to force all folders and files underneath the folder to inherit the permission we’re setting here;
    Propagation settings (None) which is to not interfere with the inheritance settings;
    Type (Allow).

http://www.tomsitpro.com/articles/powershell-manage-file-system-acl,2-837.html
#>