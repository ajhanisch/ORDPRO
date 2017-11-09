<#
.Synopsis
   Script to help automate orders management.
.DESCRIPTION
   Description goes here.
.PARAMETER input_dir
   Input directory. Alias is 'i'. This is the directory that contains the required orders files to be processed. Required files include '*r.reg', '*m.prt', and '*c.prt'.
.PARAMETER output_dir
   Output directory. Alias is 'o'. This is the directory that will house the results of processing. Results include directory structure and order files.
.LINK
   https://gitlab.com/ajhanisch/ORDPRO
#>

<#
PARAMETERS
#>
[CmdletBinding()]
param(
    [alias('i')][string]$input_dir,
    [alias('o')][string]$output_dir,
    [alias('h')][switch]$help,
    [alias('v')][switch]$version
)

<#
REQUIRED SCRIPTS
#>
try {
    . (".\Functions\Archive-Directory.ps1")
    . (".\Functions\Create-RequiredDirectories.ps1")
    . (".\Functions\Present-Outcome.ps1")
    . (".\Functions\Process-KeyboardCommands.ps1")
    . (".\Functions\Work-Magic.ps1")
    . (".\Functions\Write-Log.ps1")
}
catch {
    Write-Error "Error while loading supporting ORDPRO scripts."
    $_
    exit 1
}

<#
DIRECTORIES OUTPUT
#>
$ordmanagers_directory_output = "$($output_dir)\ORD_MANAGERS"
$ordmanagers_orders_by_soldier_output = "$($ordmanagers_directory_output)\ORDERS_BY_SOLDIER"
$ordmanagers_iperms_integrator_output = "$($ordmanagers_directory_output)\IPERMS_INTEGRATOR"
$ordregisters_output = "$($output_dir)\ORD_REGISTERS"
$uics_directory_output = "$($output_dir)\UICS"

<#
DIRECTORIES WORKING
#>
$current_directory_working = (Get-Item -Path ".\" -Verbose).FullName
$tmp_directory_working = "$($current_directory_working)\TMP"
$archive_directory_working = "$($current_directory_working)\ARCHIVE"
$log_directory_working = "$($tmp_directory_working)\LOGS"

<#
ARRAYS
#>
$directories = @(
"$($ordmanagers_directory_output)", 
"$($ordmanagers_orders_by_soldier_output)", 
"$($ordmanagers_iperms_integrator_output)",
"$($ordregisters_output)", 
"$($uics_directory_output)", 
"$($tmp_directory_working)", 
"$($archive_directory_working)",
"$($log_directory_working)"
)

$known_bad_strings = @(
"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
"                          FOR OFFICIAL USE ONLY - PRIVACY ACT",
"ORDERS\s{2}\d{3}-\d{3}\s{2}\w{2}\s{1}\w{2}\s{1}\w{2}\W{1}\s{1}\w{4},\s{2}\d{2}\s{1}\w{1,}\s{1}\d{4}",
" " # Line break that gets left behind after removing other lines in array. Leave this as is.
)

<#
VARIABLES
#>
$script_name = $($MyInvocation.MyCommand.Name)
$version_info = "2.0"
$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$log_file = "$($log_directory_working)\$($run_date)\$($run_date)_ORDPRO.log"
$log_file_directory = "$($log_directory_working)\$($run_date)"
$orders_array_csv = "$($log_file_directory)\$($run_date)_orders_array.csv"
$sw = New-Object System.Diagnostics.Stopwatch
$sw.start()

if(Test-Path variable:global:psISE)
{
    Write-Log -level [WARN] -log_file $($log_file) -message "Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
    Write-Warning "Working in PowerShell ISE. Unable to use administrative commands while using PowerShell ISE."
}
else
{
    [console]::TreatControlCAsInput = $true
}

<#
ENTRY POINT
#>
$Parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
$TotalParameters = $parameters.count
$ParametersPassed = $PSBoundParameters.Count
$params = @($psBoundParameters.Keys)
$params_results = $params  | Out-String

if($ParametersPassed -eq $TotalParameters) 
{     
    Write-Verbose "All $totalParameters parameters are being used. `n$($params_results)"
}
elseif($ParametersPassed -eq 1) 
{ 
    Write-Verbose "1 parameter is being used. `n$($params_results)" 
}
else
{ 
    Write-Verbose "$ParametersPassed parameters are being used. `n`n$($params_results)" 
}

if($($ParametersPassed) -gt '0')
{
    if($($help))
    {
        Get-Help .\$($script_name) -Full
    }

    if($($version))
    {
        Write-Host "You are running $($script_name) version $($version_info). Make sure to check https://gitlab.com/ajhanisch/ORDPRO for the most recent version of ORDPRO." -ForegroundColor Green
    }

    if($($input_dir) -and $($output_dir) -and $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
    {
        Work-Magic -i $($input_dir) -o $($output_dir) -Verbose
    }

    if($($input_dir) -and $($output_dir) -and !($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent))
    {
        try
        {
            Create-RequiredDirectories -directories $($directories) -log_file $($log_file)
		    if($?) 
		    {
			    Write-Host "Creating directories finished." -ForegroundColor White
		    } 
            
            Work-Magic -i $($input_dir) -o $($output_dir)
            if($?)
            {
                Write-Host "Working magic finished." -ForegroundColor White
            }
            
            Archive-Directory -source $($log_file_directory) -destination "$($log_directory_working)\$($run_date)_archive.zip"
            if($?)
            {
                Write-Host "Zipping log directory finished." -ForegroundColor White
            }

            Present-Outcome -outcome GO
        }
        catch
        {
            Write-Log -level [ERROR] -log_file $($log_file) -message "$_"
            Present-Outcome -outcome NOGO
        }
    }
}
else
{
    Write-Warning "No parameters passed. Try '.\$($script_name) -h' for help using ORDPRO."
    Write-Host "Typical usage: .\$($script_name) -i '\\path\to\input' -o '\\path\to\output'" -ForegroundColor Green
}