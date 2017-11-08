<#
VARIABLES
#>
$files_path = "C:\temp\SAMPLES\2017"
$orders_array = @()

<#
PARSE R.REG FILE(S) TO POPULATE ORDERS INDEX OF ALL NEEDED VARIABLES.
#>
<#
$files = (Get-ChildItem -Path $($files_path) -Filter "*r.reg" -File)
foreach($file in $files)
{
    Write-Host "Parsing reg file $($file)."

    $reg_file_content = (Get-Content -Path "$($files_path)\$($file)")

    foreach($line in $reg_file_content)
    {
        $line = ($line | Out-String)

        $c = $line.ToCharArray()

        $format = $c[12..14] -join ''
        $order_number = ($c[0..5] -join '').Insert(3,"-")
        $name = ($c[15..36] -join '').Trim()
        $ssn = ($c[60..68]) -join ''
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
            ORDER = '';
        }

	    $order_info = New-Object -TypeName PSObject -Property $hash
	    $orders_array += $order_info
    }
}
#>
<#
SPLIT ORDERS
#>
$files = (Get-ChildItem -Path $($files_path) -Filter "*m.prt" -File)
foreach($file in $files)
{
    $content = (Get-Content -Path "$($files_path)\$($file)" | Out-String)
    $orders = [regex]::Match($content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.

    Write-Host "Parsing file $($file)."

    foreach($o in $orders)
    {
        $regex_format = [regex]"Format: \d{3}"
        $format = $regex_format.Match($o).Value.Split(' ')[1]

        $regex_order_number = [regex]"ORDERS\s{1,}\d{3}-\d{3}"
        $order_number = $regex_order_number.Match($o).Value.Split(' ')[1]

        $regex_ssn = [regex]"\d{3}-\d{2}-\d{4}"
        $ssn = $regex_ssn.Match($o).Value

        Write-Host "file: $($o)"
        Write-Host "format: $($format) // order_number: $($order_number) // ssn: $($ssn)"
        Read-Host -Prompt "Enter to continue"

        cls
    }
}