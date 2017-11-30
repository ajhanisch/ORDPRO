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

<#
PROCESS FILES
#>
$start_time = Get-Date
Write-Host "Start time: $($start_time)"

Write-Host "Gathering directories and files at $(Get-Date)."
#$directories = @(Get-ChildItem -Path $($file_path) -Recurse -Include "*.doc" | ? { $_.FullName -notmatch 'ZZUNK' } | Select Directory, Name)
$directories = @(Get-ChildItem -Path $($file_path) -Recurse -Include "*.doc" | Select Directory, Name)
Write-Host "Finished gathering directories and files at $(Get-Date)."

Write-Host "Determining ACTIVE or INACTIVE at $(Get-Date)."
Write-Host "Starting ACTIVE at $(Get-Date) ..."
$active = $directories | ? { $_.Name -match ($time_line -join "|") } | Select -ExpandProperty Directory
Write-Host "Finished with ACTIVE at $(Get-Date) ..."
Write-Host "Starting INACTIVE at $(Get-Date) ..."
$inactive = $directories | ? { $active -notcontains $_.Directory }
Write-Host "Finished INACTIVE at $(Get-Date) ..."
Write-Host "Finished determining ACTIVE or INACTIVE at $(Get-Date)."

<#
REMOVE INACTIVE
#>
Write-Host "Removing INACTIVE at $(Get-Date)."
foreach($i in $inactive)
{
    Remove-Item -Path $($i.Directory) -Force -Verbose
}
Write-Host "Finished removing INACTIVE at $(Get-Date)."

<#
OUTPUT RESULTS
#>
Write-Host "Writing results to $($current_directory) at $(Get-Date)."
Write-Host "Starting INACTIVE at $(Get-Date) ..."
$inactive | Select Directory, Name | Export-Csv -Path $($inactive_csv) -NoTypeInformation -Force
Write-Host "Finished INACTIVE at $(Get-Date) ..."
Write-Host "Starting ACTIVE ..."
$active | Out-File $($active_txt)
Write-Host "Finished with ACTIVE at $(Get-Date) ..."
Write-Host "Starting DIRECTORIES_NAMES at $(Get-Date) ..."
$($directories) | Select Directory, Name | Export-Csv -Path $($directories_names_csv) -NoTypeInformation -Force
Write-Host "Finished DIRECTORIES_NAMES at $(Get-Date) ..."
Write-Host "Finished writing results to $($current_directory) at $(Get-Date)."

$end_time = Get-Date
Write-Host "Start time: $($start_time)"
Write-Host "End time: $($end_time)"
