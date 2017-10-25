$HomeFolders = Get-ChildItem "C:\temp\OUTPUT\UICS" -Directory

foreach ($uic in $uics_folder) {
    $Path = $uic.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')
    $Username = $uic.Name
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'Modify',                 'ContainerInherit,ObjectInherit', 'None', 'Allow')
    $Acl.SetAccessRule($Ar)
    Set-Acl -path $Path -AclObject $Acl
}

<#
Access control entries (ACEs) are the individual rights inside of an ACL. An ACE can also be called a FileSystemAccessRule. This is a .NET object that has five parameters;

    The security identifier ($Username);
    The right (Modify);
    Inheritance settings (ContainerInherit,ObjectInherit) which means to force all folders and files underneath the folder to inherit the permission we’re setting here;
    Propagation settings (None) which is to not interfere with the inheritance settings;
    Type (Allow).

http://www.tomsitpro.com/articles/powershell-manage-file-system-acl,2-837.html
#>