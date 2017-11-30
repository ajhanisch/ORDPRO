<#
SCRIPT CONSTANTS
#>
#$file_path = ""
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

Write-Host "Gathering directories and files now."
#$directories = @(Get-ChildItem -Path $($file_path) -Recurse -Include "*.doc" | ? { $_.FullName -notmatch 'ZZUNK' } | Select Directory, Name)
$directories = @(Get-ChildItem -Path $($file_path) -Recurse -Include "*.doc" | Select Directory, Name)
Write-Host "Finished gathering directories and files."

$directories = Import-Csv "C:\temp\PROGRAMS\TESTING\directories_names - Copy.csv"
Write-Host "Determining ACTIVE or INACTIVE."
Write-Host "Starting ACTIVE ..."
$active = $directories | ? { $_.Name -match ($time_line -join "|") } | Select -ExpandProperty Directory
Write-Host "Finished with ACTIVE ..."
Write-Host "Starting INACTIVE ..."
$inactive = $directories | ? { $active -notcontains $_.Directory }
Write-Host "Finished INACTIVE ..."
Write-Host "Finished determining ACTIVE or INACTIVE."

<#
PRESENT STATS
#>
$active_count = ($active | Select -Unique).Count
$inactive_count = ($inactive.Directory | Select -Unique).Count
Write-Host "Presenting numbers."
Write-Host "----------------------------"
Write-Host "Active SSN's: $($active_count)"
Write-Host "Inactive SSN's: $($inactive_count)"
Write-Host "----------------------------"
Write-Host "Finished presenting numbers."

<#
REMOVE INACTIVE
#>
Write-Host "Removing INACTIVE."
foreach($i in $inactive)
{
    Remove-Item -Path $($i.Directory) -Force -Verbose
}
Write-Host "Finished removing INACTIVE."

<#
OUTPUT RESULTS
#>
Write-Host "Writing results to $($current_directory) now."
Write-Host "Starting ACTIVE ..."
$active | Select -ExpandProperty Name -Unique | Out-File $($active_txt)
Write-Host "Finished with ACTIVE ..."
Write-Host "Starting INACTIVE ..."
$inactive | Select Directory, Name | Export-Csv -Path $($inactive_csv) -NoTypeInformation -Force
Write-Host "Finished INACTIVE ..."
Write-Host "Starting DIRECTORIES_NAMES ..."
$($directories) | Select Directory, Name | Export-Csv -Path $($directories_names_csv) -NoTypeInformation -Force
Write-Host "Finished DIRECTORIES_NAMES ..."
Write-Host "Finished writing results to $($current_directory)."

$end_time = Get-Date
Write-Host "Start time: $($start_time)"
Write-Host "End time: $($end_time)"
