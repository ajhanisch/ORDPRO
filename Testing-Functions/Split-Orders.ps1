<#
VARIABLES
#>
$files_path = "C:\temp\SAMPLES\TEST"
$orders_array = @()

<#
PARSE R.REG FILE(S) TO POPULATE ORDERS INDEX OF ALL NEEDED VARIABLES.
#>
Write-Host "Populating Orders Index now."

$files = (Get-ChildItem -Path $($files_path) -Filter "*r.reg" -File)
foreach($file in $files)
{
    $reg_file_content = (Get-Content -Path "$($files_path)\$($file)")
    foreach($line in $reg_file_content)
    {
        $line = ($line | Out-String)

        $c = $line.ToCharArray()

        $format = $c[12..14] -join ''
        $order_number = ($c[0..5] -join '').Insert(3,"-")
        $name = ($c[15..36] -join '').Trim()
        $ssn = (($c[60..68]) -join '').Insert(3,"-").Insert(6,"-")
        $uic = ($c[37..41]) -join ''
        $published_year = ($c[6..11] -join '').Substring(0,2)
        $period_from = ($c[48..53]) -join ''
        $period_to = ($c[54..59]) -join ''

        $hash = @{
            FORMAT = $($format);
            ORDER_NUMBER = $($order_number);
            NAME = $($name);
            SSN = $($ssn);
            UIC = $($uic);
            PUBLISHED_YEAR = $($published_year);
            PERIOD_FROM = $($period_from);
            PERIOD_TO = $($period_to);
            ORDER_M = '';
            ORDER_C = '';
        }

	    $order_info = New-Object -TypeName PSObject -Property $hash
	    $orders_array += $order_info
    }
}
Write-Host "Finished populating Orders Index now."

<#
ADD MAIN ORDER TO PERSONS OBJECT IN ARRAY
#>
Write-Host "Adding main order files to persons object in array."
$main_files = (Get-ChildItem -Path $($files_path) -Filter "*m.prt" -File)
foreach($file in $main_files)
{
    Write-Host "Parsing file $($file) now."
    $main_file_content = (Get-Content -Path "$($files_path)\$($file)" | Out-String)
    #$orders_m = [regex]::Match($main_file_content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.
    $orders_m = [regex]::Match($main_file_content,'(?<=STATE OF SOUTH DAKOTA).+(?=The Adjutant General)',"singleline").Value -split "STATE OF SOUTH DAKOTA"
    foreach($o in $orders_m)
    {
        $regex_format = [regex]"Format: \d{3}"
        $format = $regex_format.Match($o).Value.Split(' ')[1]

        $regex_order_number = [regex]"ORDERS\s{1,2}\d{3}-\d{3}"
        $order_number = $regex_order_number.Match($o).Value.Split(' ')[-1]

        $regex_ssn = [regex]"\d{3}-\d{2}-\d{4}"
        $ssn = $regex_ssn.Match($o).Value

        ($orders_array | Where-Object { $_.FORMAT -eq $format -and $_.ORDER_NUMBER -eq $order_number -and $_.SSN -eq $ssn }).ORDER_M = $o
    }
}
Write-Host "Finished adding main order files to persons object in array."

<#
ADD CERT ORDER TO PERSONS OBJECT IN ARRAY
#>
Write-Host "Adding cert order files to persons object in array."
$cert_files = (Get-ChildItem -Path $($files_path) -Filter "*c.prt" -File)
foreach($file in $cert_files)
{
    Write-Host "Parsing file $($file) now."
    $cert_file_content = (Get-Content -Path "$($files_path)\$($file)" | Out-String)
    #$orders_c = [regex]::Match($cert_file_content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.
    $orders_c = [regex]::Match($cert_file_content,'(?<=FOR OFFICIAL USE ONLY - PRIVACY ACT).+(?=Automated NGB Form 102-10A  dtd  12 AUG 96)',"singleline").Value -split "Automated NGB Form 102-10A  dtd  12 AUG 96"
    foreach($o in $orders_c)
    {
        $regex_order_number = [regex]"Order number:\s{1}\d{6}"
        $order_number = $regex_order_number.Match($o).Value.Split(' ')[-1].Insert(3,"-")
        
        $regex_period_of_duty = [regex]"Period of duty:\s{1}\d{6}\s{3}To\s{1}\d{6}"
        $period_of_duty = ($regex_period_of_duty.Match($o).Value).Split(' ')
        $period_from = $period_of_duty[3]
        $period_to = $period_of_duty[-1]

        ($orders_array | Where-Object { $_.ORDER_NUMBER -eq $order_number -and $_.PERIOD_FROM -eq $period_from -and $_.PERIOD_TO -eq $period_to }).ORDER_C = $o
    }
}
Write-Host "Finished adding cert order files to persons object in array."

<#
CHECK RESULTS
#>
Write-Host "Creating directory structure and order files."
foreach($o in $orders_array)
{
    Write-Host "Creating directory structure and order files for $($o.NAME)."
    
    New-Item -ItemType Directory -Path "C:\temp\OUTPUT\UICS\$($o.UIC)\$($o.NAME)_$($o.SSN)" > $null
    New-Item -ItemType File -Path "C:\temp\OUTPUT\UICS\$($o.UIC)\$($o.NAME)_$($o.SSN)" -Name "$($o.PUBLISHED_YEAR)___$($o.SSN)___$($o.ORDER_NUMBER)___$($o.PERIOD_FROM)___$($o.PERIOD_TO)___$($o.FORMAT).txt" -Value $($o.ORDER_M) > $null
    New-Item -ItemType File -Path "C:\temp\OUTPUT\UICS\$($o.UIC)\$($o.NAME)_$($o.SSN)" -Name "$($o.PUBLISHED_YEAR)___$($o.SSN)___$($o.ORDER_NUMBER)___$($o.PERIOD_FROM)___$($o.PERIOD_TO)___cert.txt" -Value $($o.ORDER_C) > $null

    Write-Host "Finished creating directory structure and order files for $($o.NAME)."

    #Read-Host -Prompt "enter to continue"
}
Write-Host "Finished creating directory structure and order files."