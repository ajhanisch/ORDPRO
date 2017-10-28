$ordpro_scripts = @(
"..\ORDPRO.ps1",
".\Archive-Directory.ps1",
".\Clean-OrdersCertificate.ps1",
".\Clean-OrdersMain.ps1",
".\Clean-UICS.ps1",
".\Combine-OrdersCertificate.ps1",
".\Combine-OrdersMain.ps1",
".\Create-RequiredDirectories.ps1",
".\Edit-OrdersCertificate.ps1",
".\Edit-OrdersMain.ps1",
".\Get-Permissions.ps1",
".\Move-OriginalToArchive.ps1",
".\Parse-OrdersCertificate.ps1",
".\Parse-OrdersMain.ps1",
".\Present-Outcome.ps1",
".\Process-KeyboardCommands.ps1",
".\Split-OrdersCertificate.ps1",
".\Split-OrdersMain.ps1",
".\Validate-Variables.ps1",
".\Work-Magic.ps1",
".\Write-Log.ps1"
)

foreach($s in $ordpro_scripts)
{
    Write-Host "[#] Trusting $($s) so we don't get prompted to trust these scripts every time." -ForegroundColor Yellow

    Unblock-File $($s)
    if($?)
    {
        Write-Host "[*] $($s) trusted successfully. No more annoying popups." -ForegroundColor Green
    }
    else
    {
        Write-Error "$($s) trust failed. Check it out."
        exit 1
    }
}