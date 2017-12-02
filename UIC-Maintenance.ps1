<#
SCRIPT CONSTANTS
#>
$file_path = ""
$current_directory = (Get-Item -Path ".\" -Verbose).FullName
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$current_year = ((Get-Date).Year).ToString().Substring(2)
$one_year = ((Get-Date).Year - 1).ToString().Substring(2)
$time_line = @(
"^$($current_year)___*",
"^$($one_year)___*"
)

<#
OUTPUT FILES
#>
$directories_names_csv = "$($current_directory)\$($run_date)_directories_names.csv"
$active_txt = "$($current_directory)\$($run_date)_active.txt"
$inactive_csv = "$($current_directory)\$($run_date)_inactive.csv"

Write-Host "Gathering directories and files now."
#$directories = @(Get-ChildItem -Path $($file_path) -Recurse -Include "*.doc" | ? { $_.FullName -notmatch 'ZZUNK' } | Select Directory, Name)
$directories = @(Get-ChildItem -Path $($file_path) -Recurse -Include "*.doc" | Select Directory, Name)
Write-Host "Finished gathering directories and files."

Write-Host "Determining ACTIVE or INACTIVE."
$active = $directories | ? { $_.Name -match ($time_line -join "|") } | Select -ExpandProperty Directory
$inactive = $directories | ? { $active -notcontains $_.Directory }
Write-Host "Finished determining ACTIVE or INACTIVE."

Write-Host "Presenting numbers."
Write-Host "----------------------------"
Write-Host "Active: $($active.Count)"
Write-Host "Inactive: $($inactive.Directory.Count)"
Write-Host "Total: $($results.Directory.Count)"
Write-Host "----------------------------"
Write-Host "Finished presenting numbers."

Write-Host "Removing INACTIVE."
foreach($i in $inactive)
{
    Remove-Item -Path $($i.Directory) -Force -Recurse -ErrorAction SilentlyContinue
}
Write-Host "Finished removing INACTIVE."

Write-Host "Writing results to $($current_directory) now."
$active | Select -ExpandProperty Name | Sort -Unique | Out-File $($active_txt)
$inactive | Select Directory, Name | Sort |  Export-Csv $($inactive_csv) -NoTypeInformation -Force
$($directories) | Select Directory, Name | Export-Csv -Path $($directories_names_csv) -NoTypeInformation -Force
Write-Host "Finished writing results to $($current_directory)."