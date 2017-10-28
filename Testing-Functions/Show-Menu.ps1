function Show-Menu
{
     param (
           [string]$Title = 'ORDPRO Menu'
     )

     cls
     Write-Host "================ $Title ================"
     Write-Host " 1: Automatically process orders."
     Write-Host "----------------------------------------"
     Write-Host " Choices 2-15 are for manual processing."
     Write-Host "----------------------------------------"
     Write-Host " 2: Create required directories."
     Write-Host " 3: Split orders from '*m.prt' files."
     Write-Host " 4: Edit orders split from '*m.prt' files."
     Write-Host " 5: Combine edited orders split from '*m.prt' files."
     Write-Host " 6: Work magic on edited orders split from '*m.prt' files."
     Write-Host " 7: Split orders from '*c.prt' files."
     Write-Host " 8: Edit orders split from '*c.prt' files."
     Write-Host " 9: Combine edited orders split from '*c.prt' files."
     Write-Host "10: Work magic on edited orders split from '*c.prt' files."
     Write-Host "11: Clean up .\TMP\MOF directory."
     Write-Host "12: Clean up .\TMP\COF directory."
     Write-Host "13: Clean up .\{OUTPUT_DIR}\UICS directory."
     Write-Host "14: Get permissions of .\{OUTPUT_DIR}\UICS directory."
     Write-Host "15: Archive original '*m.prt', '*c.prt', '*r.reg', and '*r.prt' files."
     Write-Host " H: Help"
     Write-Host " Q: Exit"
     Write-Host "================ $Title ================"
}

do
{

    Show-Menu | Out-GridView -Title "ORDPRO Menu"
    $selection = Read-Host -Prompt "Please make a selection"
    switch($selection)
    {
        1
        {
            "You chose option 1"
        }

        2
        {
            "You chose option 2"
        }

        3
        {
            "You chose option 3"
        }

        4
        {
            "You chose option 4"
        }

        5
        {
            "You chose option 5"
        }

        'Q'
        {
            "You chose to exit. Exiting now."
            return
        }
    }
}
until($selection -eq 'Q')