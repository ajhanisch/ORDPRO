function Create-TestData()
{
    $random_number = Get-Random -Minimum 10 -Maximum 100

    Write-Host "[^] Random number is: $($random_number)! Creating $($random_number) UICS, SOLDIERS, and FILES now." -ForegroundColor Cyan

    $last_name_file = @(Get-Content .\Lastnames.txt)
    $first_name_file = @(Get-Content .\Lastnames.txt)

    for($i=1; $i -le $random_number; $i++)
    {
        $last_name = Get-Random -InputObject $last_name_file -Count 1
        $first_name = Get-Random -InputObject $first_name_file -Count 1
        $middle_initial_list = @('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z')
        $middle_initial = Get-Random -InputObject $middle_initial_list -Count 1
        $name = "$($last_name)_$($first_name)_$($middle_initial)"

        $uic = -join ((65..90) | Get-Random -Count 5 | % {[char]$_})

        $ssn_1 = Get-Random -Minimum '111' -Maximum '999'
        $ssn_2 = Get-Random -Minimum '11' -Maximum '99'
        $ssn_3 = Get-Random -Minimum '1111' -Maximum '9999'
        $ssn = "$($ssn_1)-$($ssn_2)-$($ssn_3)"

        $published_year = Get-Random -Minimum '11' -Maximum '17'

        $order_number_1 = Get-Random -Minimum '111' -Maximum '999'
        $order_number_2 = Get-Random -Minimum '111' -Maximum '999'
        $order_number = "$($order_number_1)-$($order_number_2)"

        $order_amended_1 = Get-Random -Minimum '111' -Maximum '999'
        $order_amended_2 = Get-Random -Minimum '111' -Maximum '999'
        $order_amended = "$($order_amended_1)-$($order_amended_2)"

        $order_revoke_1 = Get-Random -Minimum '111' -Maximum '999'
        $order_revoke_2 = Get-Random -Minimum '111' -Maximum '999'
        $order_revoke = "$($order_revoke_1)-$($order_revoke_2)"

        $period_from_year = Get-Random -Minimum '1993' -Maximum '2017'
        $period_from_month = Get-Random -Minimum '01' -Maximum '12'
        if($period_from_month-lt '10')
        {
            $period_from_month = "0$($period_from_month)"
        }
        $period_from_day = Get-Random -Minimum '01' -Maximum '31'
        if($period_from_day -lt '10')
        {
            $period_from_day = "0$($period_from_day)"
        }
        $period_from = "$($period_from_year)$($period_from_month)$($period_from_day)"

        $period_to_year = Get-Random -Minimum '1993' -Maximum '2017'
        $period_to_month = Get-Random -Minimum '01' -Maximum '12'
        if($period_to_month -lt '10')
        {
            $period_to_month = "0$($period_to_month)"
        }
        $period_to_day = Get-Random -Minimum '01' -Maximum '31'
        if($period_to_day -lt '10')
        {
            $period_to_day = "0$($period_to_day)"
        }
        $period_to = "$($period_to_year)$($period_to_month)$($period_to_day)"

        $format_list = @('296', '282', '700', '705', '284', '290', '165', 'cert')
        $format = Get-Random -InputObject $format_list -Count 1

        $extention = '.txt'

        $current_directory = (Get-Item -Path ".\" -Verbose).FullName
        $uics_directory = "$($current_directory)\UICS"
        $uic_directory = "$($uics_directory)\$($uic)"
        $soldier_directory = "$($uics_directory)\$($uic)\$($name)___$($ssn)"
        $uic_soldier_order_file_name = "$($published_year)___$($ssn)___$($order_number)___$($period_from)___$($period_to)___$($format).txt"

        if(Test-Path $($uic_directory))
        {
            Write-Host "[*] $($uic_directory) already created, continuing." -ForegroundColor Green
        }
        else
        {
            Write-Host "[#] $($uic_directory) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path "$($uics_directory)\$($uic)" > $null

            if($?)
            {
                Write-Host "[*] $($uic_directory) created successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" ([char]7) -ForegroundColor Red
                Write-Host "[!] $($uic_directory) creation failed." ([char]7) -ForegroundColor Red
                throw "[!] $($uic_directory) creation failed."
            }
        }

        if(Test-Path $($soldier_directory))
        {
            Write-Host "[*] $($soldier_directory) already created, continuing." -ForegroundColor Green
        }
        else
        {
            Write-Host "[#] $($soldier_directory) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path "$($soldier_directory)" > $null

            if($?)
            {
                Write-Host "[*] $($soldier_directory) created successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)." ([char]7) -ForegroundColor Red
                Write-Host "[!] $($soldier_directory) creation failed." ([char]7) -ForegroundColor Red
                throw "[!] $($soldier_directory) creation failed."
            }
        }

        if(Test-Path "$($soldier_directory)\$($uic_soldier_order_file_name)")
        {
            Write-Host "[*] $($soldier_directory)\$($uic_soldier_order_file_name) already created, continuing." -ForegroundColor Green
        }
        else
        {
            Write-Host "[#] $($soldier_directory)\$($uic_soldier_order_file_name) not created. Creating now." -ForegroundColor Yellow
            New-Item -ItemType File -Path $($soldier_directory) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

            if($?)
            {
                Write-Host "[*] $($soldier_directory)\$($uic_soldier_order_file_name) created successfully." -ForegroundColor Green
            }
            else
            {
                Write-Host "[!] Failed to process for $($last_name) $($first_name) $($uic)" ([char]7) -ForegroundColor Red
                Write-Host "[!] $($soldier_directory)\$($uic_soldier_order_file_name) creation failed." ([char]7) -ForegroundColor Red
                throw "[!] $($soldier_directory)\$($uic_soldier_order_file_name) creation failed."
            }
        }
    }

    Write-Host "[^] Creating $($random_number) UICS, SOLDIERS, and FILES finished successfully!" -ForegroundColor Cyan
}

Create-TestData