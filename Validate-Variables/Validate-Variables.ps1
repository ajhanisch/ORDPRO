function Validate-Variables()
{
    Param(
      [Parameter(mandatory = $false)] [String] $uic,
      [Parameter(mandatory = $false)] [String] $last_name,
      [Parameter(mandatory = $false)] [String] $first_name,
      [Parameter(mandatory = $false)] [String] $middle_initial,
      [Parameter(mandatory = $false)] [String] $published_year,
      [Parameter(mandatory = $false)] [String] $published_month,
      [Parameter(mandatory = $false)] [String] $published_day,
      [Parameter(mandatory = $false)] [String] $ssn,
      [Parameter(mandatory = $false)] [String] $period_from_year,
      [Parameter(mandatory = $false)] [String] $period_from_month,
      [Parameter(mandatory = $false)] [String] $period_from_day,
      [Parameter(mandatory = $false)] [String] $period_to_number,
      [Parameter(mandatory = $false)] [String] $period_to_time,
      [Parameter(mandatory = $false)] [String] $format,
      [Parameter(mandatory = $false)] [String] $order_amended,
      [Parameter(mandatory = $false)] [String] $order_revoke,
      [Parameter(mandatory = $false)] [String] $order_number
      )
    
    $parameters = (Get-Command -Name $MyInvocation.InvocationName).Parameters | Select -ExpandProperty Keys | Where-Object { $_ -NotIn ('Verbose', 'ErrorAction', 'WarningAction', 'PipelineVariable', 'OutBuffer', 'Debug', 'ErrorAction','WarningAction', 'ErrorVariable', 'WarningVariable', 'OutVariable') }
    $total_parameters = $parameters.count
    $parameters_passed = $PSBoundParameters.Count
    $parameters_processed = 0

    if($($parameters_passed) -gt '0')
    {
        $validation_results = @()

            foreach($p in $PSBoundParameters.GetEnumerator())
            {
                $parameters_processed ++

                Write-Host "[#] Validating $($parameters_processed)/$($parameters_passed) parameters now." -ForegroundColor Yellow

                $key = $p.Key
                $value = $p.Value

                if($key -eq 'uic')
                {
                    if($value -match "^\w{5}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {

                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'last_name')
                {
                    if($value -match "^[a-zA-Z'-]{1,20}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'first_name')
                {
                    if($value -match "^[a-zA-Z'-]{1,20}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'middle_initial')
                {
                    if($value -match "^[A-Z]{1,3}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'published_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'published_month')
                {
                    if($value -match "^\d{2}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'published_day')
                {
                    if($value -match "^\d{2}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'ssn')
                {
                    if($value -match "^\d{3}-\d{2}-\d{4}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_from_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_from_month')
                {
                    if($value -match "^\d{2}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_from_day')
                {
                    if($value -match "^\d{2}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_number')
                {
                    if($value -match "^\d{1,4}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'period_to_time')
                {
                    if($value -match "^[A-Z]{4,6}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'format')
                {
                    if($value -match "^\d{3}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'order_amended')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'order_revoke')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                elseif($key -eq 'order_number')
                {
                    if($value -match "^\d{3}-\d{3}$")
                    { 
	                    Write-Host "[*] Value '$($value)' from '$($key)' passed validation." -ForegroundColor Green
    
                        $status = "pass"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    } 
                    else 
                    { 
	                    Write-Host "[!] Value '$($value)' from '$($key)' failed validation." ([char]7) -ForegroundColor Red
	
                        $status = "fail"

                        if(!($validation_results -contains "$($key)"))
                        {
                            $validation_result = New-Object -TypeName PSObject
                            $validation_result | Add-Member -MemberType NoteProperty -Name Variable -Value $key
                            $validation_result | Add-Member -MemberType NoteProperty -Name Status -Value $status
                            $validation_result | Add-Member -MemberType NoteProperty -Name Value -Value $value
                            $validation_results += $validation_result
                        }
                    }
                }
                else
                {
                    Write-Host "[!] Incorrect or unknown parameter specified. Try again with proper input." ([char]7)  -ForegroundColor Red
                }

                Write-Host "[*] Finished validating $($parameters_processed)/$($parameters_passed) parameters." -ForegroundColor Green
            }

            return $validation_results
    }
    else
    {
        Write-Host "[!] No parameters passed. Try again with proper input." ([char]7)  -ForegroundColor Red
    }
}


$validation_results = Validate-Variables -uic '8a7aa' -last_name 'HANISCH-brtna' -first_name '908' -middle_initial 'N' -published_year '17' -published_month '12' -published_day '01' -ssn '504-19-1997' -period_from_year '12' -period_from_month '05' -period_from_day '02' -period_to_number '588' -period_to_time 'DAYS' -format '292' -order_amended '123-098' -order_revoke '587-632'

if(!($validation_results.Status -contains 'fail'))
{
    Write-Host "[*] All variables passed validation." -ForegroundColor Green
    # Work-Magic goes here
}
else
{
    $total_validation_fails = @($validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }).Count
    if($total_validation_fails -gt 1)
    {
        Write-Host "[!] $($total_validation_fails) variables failed validation." ([char]7)  -ForegroundColor Red
        #$validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }
        $validation_results | Sort-Object -Property Status
    }
    elseif($total_validation_fails -eq 1)
    {
        Write-Host "[!] $($total_validation_fails) variable failed validation." ([char]7)  -ForegroundColor Red
        #$validation_results | Sort-Object -Property Status | Where { $_.Status -eq 'fail' }
        $validation_results | Sort-Object -Property Status
    }
}