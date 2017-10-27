$ordpro_scripts = @(
".\ORDPRO.ps1",
".\__FUNCTIONS\Archive-Directory.ps1",
".\__FUNCTIONS\Clean-OrdersCertificate.ps1",
".\__FUNCTIONS\Clean-OrdersMain.ps1",
".\__FUNCTIONS\Clean-UICS.ps1",
".\__FUNCTIONS\Combine-OrdersCertificate.ps1",
".\__FUNCTIONS\Combine-OrdersMain.ps1",
".\__FUNCTIONS\Create-RequiredDirectories.ps1",
".\__FUNCTIONS\Edit-OrdersCertificate.ps1",
".\__FUNCTIONS\Edit-OrdersMain.ps1",
".\__FUNCTIONS\Get-Permissions.ps1",
".\__FUNCTIONS\Move-OriginalToArchive.ps1",
".\__FUNCTIONS\Parse-OrdersCertificate.ps1",
".\__FUNCTIONS\Parse-OrdersMain.ps1",
".\__FUNCTIONS\Present-Outcome.ps1",
".\__FUNCTIONS\Process-KeyboardCommands.ps1",
".\__FUNCTIONS\Split-OrdersCertificate.ps1",
".\__FUNCTIONS\Split-OrdersMain.ps1",
".\__FUNCTIONS\Validate-Variables.ps1",
".\__FUNCTIONS\Work-Magic.ps1",
".\__FUNCTIONS\Write-Log.ps1"
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