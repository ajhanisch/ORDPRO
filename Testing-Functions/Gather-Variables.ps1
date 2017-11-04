$files = @(Get-ChildItem -Path C:\temp\SAMPLES\TEST -Recurse -Exclude '*r.reg')
$parsed_files = @()
$orders = @()

foreach($file in $files)
{
    if($parsed_files -notcontains $file)
    {
        $julian = $file.Name.Substring(3,6)
        $files_to_parse = $files | Where-Object { $_.Name -match $julian }

        $file_reg = $files_to_parse | Where-Object { $_.Name -match "reg$($julian)r.prt" }
        $file_main = $files_to_parse | Where-Object { $_.Name -match "ord$($julian)m.prt" }

        $lines_reg = @(Select-String -Path $file_reg -Pattern "\d{3}-\d{3}")
        $lines_main = @(Select-String -Path $file_main -Pattern "\d{3}-\d{2}-\d{4}")

        foreach($line in $lines_reg)
        {
            $line = $line | ConvertFrom-String
            $order_number = $line.P2
            $dated = $line.P3.ToString().Substring(0,2)
            $format = $line.P4
            $last_name = $line.P5
            $first_name = $line.P6
            $middle_initial = $line.P7
            if($($middle_initial).Length -ne 1 -and $($middle_initial).Length -gt 2)
            {
	            $middle_initial = ' '
            }
            $uic = $line.P8.ToString().Substring(0,5)
            $period_of_duty = $line.P10
            $p = $period_of_duty.Split("-")
            $period_from = $p[0]
            $period_to = $p[1]
            $ssn = $lines_main -match "$($last_name) $($first_name) $($middle_initial)" -split " " | Select-String -Pattern "\d{3}-\d{2}-\d{4}" | Select -First 1

            <#
            Write-Host "File: $file. Order Number: $order_number. Dated. $dated. Format: $format. LastName: $last_name. FirstName: $first_name. MiddleInitial: $middle_initial. UIC: $uic. PeriodFrom: $period_from. PeriodTo: $period_to. SSN: $ssn."
            Read-Host -Prompt "Enter to continue"
            #>

            if($order.SSN -notin $orders)
            {
                $hash = @{
                    DATED = $dated;
                    LAST_NAME = $last_name;
                    FIRST_NAME = $first_name;
                    MIDDLE_INITIAL = $middle_initial;
                    SSN = $ssn;
                    ORDER_NUMBER = $order_number;
                    PERIOD_FROM = $period_from;
                    PERIOD_TO = $period_to;
                    FORMAT = $format;
                    UIC = $uic;
                }

                $order = New-Object -TypeName PSObject -Property $hash
                $orders += $order 
            }
        }
    }
}

$orders |  Select DATED, LAST_NAME, FIRST_NAME, MIDDLE_INITIAL, SSN, UIC, ORDER_NUMBER, PERIOD_FROM, PERIOD_TO, FORMAT | Sort -Property ORDER_NUMBER| Format-Table -AutoSize -Wrap