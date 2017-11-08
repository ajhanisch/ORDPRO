# GOOD FOR 2006-2017. SHOULD BE GOOD FOR ALL YEARS NO MATTER WHAT
#$files = (Get-ChildItem -Path "C:\temp\SAMPLES\2017" -Filter "*c.prt" -File)
#$files = (Get-ChildItem -Path "C:\temp\SAMPLES\2017" -Filter "*m.prt" -File)
$files = (Get-ChildItem -Path "C:\temp\SAMPLES\2017" -Filter "*r.reg" -File)

$regex_order_number_main = "ORDERS\s{1,2}\d{3}-\d{3}"
$regex_order_number_cert = "Order number: \d{6}"
$regex_format = "Format: \d{3}"

# Parse 'r.reg' files to gather 99% of variables.
foreach($file in $files)
{
    Write-Host "Parsing reg file $($file)."

    $reg_file_content = (Get-Content -Path "C:\temp\SAMPLES\2017\$($file)")

    foreach($line in $reg_file_content)
    {
        $line = ($line | Out-String)

        $format = $($line).Substring(12,3)

        Write-Host "Format: $($format)"

        Read-Host -Prompt "Enter to continue"
    
        if($($format) -eq 282 -or $($format) -eq 296 -or $($format) -eq 294 -or $($format) -eq 284)
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            $split_line = $line -split "\s{2,}"
            $split_line[0]
            Read-Host -Prompt "Enter to continue"
            $split_line[2]
            Read-Host -Prompt "Enter to continue"

            $format = $format
            $order_number = $($line).Substring(0,6)
            #$name = $($line).Substring(15, $($line).IndexOf("")).Trim()
            $ssn =  
            $uic = 
            $published_year = 
            $period_from_year = 
            $period_from_month = 
            $period_from_day = 
            $period_to_year = 
            $period_to_month = 
            $period_to_day = 

            Write-Host "Format: $($format). Order Number: $($order_number). Name: $($name). SSN: $($ssn). UIC: $($uic). PublishedYear: $($published_year). PeriodFrom: $($period_from). PeriodTo: $($period_to)."
        }
        elseif($($format) -eq 290) # Pay order only.
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            <#
            $format = 
            $order_number = 
            $last_name = 
            $first_name = 
            $middle_initial = 
            $ssn = 
            $uic = 
            $published_year = 
            $period_from_year = 
            $period_from_month = 
            $period_from_day = 
            $period_to_year = 
            $period_to_month = 
            $period_to_day = 
            #>
        }
        elseif($($format) -eq 705)
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            <#
            $format = 
            $order_number = 
            $last_name = 
            $first_name = 
            $middle_initial = 
            $ssn = 
            $uic = 
            $published_year = 
            $order_revoke = 
            #>
        }
        elseif($($format) -eq 700)
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            <#
            $format = 
            $order_number = 
            $last_name = 
            $first_name = 
            $middle_initial = 
            $ssn = 
            $uic = 
            $published_year = 
            $order_amended = 
            #>
        }
        elseif($($format) -eq 172)
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            <#
            $format = 
            $order_number = 
            $last_name = 
            $first_name = 
            $middle_initial = 
            $ssn = 
            $uic = 
            $published_year = 
            $period_from_year = 
            $period_from_month = 
            $period_from_day = 
            $period_to_year = 
            $period_to_month = 
            $period_to_day = 
            #>
        }
        elseif($($format) -eq 165)
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            <#
            $format = 
            $order_number = 
            $last_name = 
            $first_name = 
            $middle_initial = 
            $ssn = 
            $uic = 
            $published_year = 
            $period_from_year = 
            $period_from_month = 
            $period_from_day = 
            $period_to_time = 
            $period_to_number = 
            #>
        }
        elseif($($format) -eq 400)
        {
            Write-Host "Found format '$($format)' in line: '$($line)' from file '$($file)'."

            <#
            $last_name = 
            $first_name = 
            $middle_initial = 
            $ssn = 
            $uic = 
            $order_number = 
            $published_year = 
            $period_from_year = 
            $period_from_month = 
            $period_from_day = 
            $period_to_year = 
            $period_to_month = 
            $period_to_day = 
            #>
        }
    }
}



<#
# Split orders out from main and cert files.
foreach($file in $files)
{
    $content = (Get-Content -Path "C:\temp\SAMPLES\2017\$($file)" | Out-String)
    $orders = [regex]::Match($content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.

    if($file.Name -like "*m.prt")
    {
        Write-Host "Parsing '*m.prt' file in $file."

        foreach($o in $orders)
        {
            $order_number = ([regex]::matches($o, $regex_order_number_main)).Value
            $order_number = [string]::new(@($order_number.ToCharArray() | Select-Object -Last 7))
            $format = [regex]::Matches($o, $regex_format)

            Write-Host "file: $($o)"
            Write-Host "order_number; $($order_number). format: $($format)."
            Read-Host -Prompt "Enter to continue"

            cls
        }
    }
    
    if($file.Name -like "*c.prt")
    {
        Write-Host "Parsing '*c.prt' file in $file."

        foreach($o in $orders)
        {
            $format = [regex]::Matches($o, $regex_format)

            $order_number = ([regex]::matches($o, $regex_order_number_cert)).Value.ToString().Split(":").Trim()
            $order_number = $order_number[-1].Insert(4,"-")

            Write-Host "file: $($o)"
            Write-Host "order_number; $($order_number). format: $($format)."
            Read-Host -Prompt "Enter to continue"

            cls
        }
    }
}
#>