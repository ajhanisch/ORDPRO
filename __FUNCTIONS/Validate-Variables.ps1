function Validate-Variables()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $false)] $uic,
        [Parameter(mandatory = $false)] $last_name,
        [Parameter(mandatory = $false)] $first_name,
        [Parameter(mandatory = $false)] $middle_initial,
        [Parameter(mandatory = $false)] $published_year,
        [Parameter(mandatory = $false)] $published_month,
        [Parameter(mandatory = $false)] $published_day,
        [Parameter(mandatory = $false)] $ssn,
        [Parameter(mandatory = $false)] $period_from_year,
        [Parameter(mandatory = $false)] $period_from_month,
        [Parameter(mandatory = $false)] $period_from_day,
        [Parameter(mandatory = $false)] $period_to_year,
        [Parameter(mandatory = $false)] $period_to_month,
        [Parameter(mandatory = $false)] $period_to_day,
        [Parameter(mandatory = $false)] $period_to_number,
        [Parameter(mandatory = $false)] $period_to_time,
        [Parameter(mandatory = $false)] $format,
        [Parameter(mandatory = $false)] $order_amended,
        [Parameter(mandatory = $false)] $order_revoke,
        [Parameter(mandatory = $false)] $order_number
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

                Write-Log -log_file $log_file -message "Validating ( $($parameters_processed) / $($parameters_passed) ) parameters now."
                Write-Verbose "Validating ( $($parameters_processed) / $($parameters_passed) ) parameters now."

                $key = $p.Key
                $value = $p.Value

                if($key -eq 'uic')
                {
                    if($value -match "^\w{5}$")
                    { 
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation. User most likely does not exist output directory yet. 'Make sure to run $($script_name) -sm -em -mm -o <output>' before dealing with certificate order files."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation. User most likely does not exist output directory yet. 'Make sure to run $($script_name) -sm -em -mm -o <output>' before dealing with certificate order files."
                        throw " Value '$($value)' from '$($key)' failed validation. User most likely does not exist output directory yet. 'Make sure to run $($script_name) -sm -em -mm -o <output>' before dealing with certificate order files."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                elseif($key -eq 'period_to_year')
                {
                    if($value -match "^\d{2,4}$")
                    { 
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                elseif($key -eq 'period_to_month')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                elseif($key -eq 'period_to_day')
                {
                    if($value -match "^\d{2}$")
                    { 
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                        Write-Log -log_file $log_file -message "Value '$($value)' from '$($key)' passed validation."
    
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
                        Write-Log -level [ERROR] -log_file $log_file -message " Value '$($value)' from '$($key)' failed validation."
	                    Write-Error " Value '$($value)' from '$($key)' failed validation."
                        throw " Value '$($value)' from '$($key)' failed validation."
	
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
                    Write-Log -level [ERROR] -log_file $log_file -message " Incorrect or unknown parameter specified. Try again with proper input."
                    Write-Error " Incorrect or unknown parameter specified. Try again with proper input."
                }

                Write-Verbose "Finished validating ( $($parameters_processed) / $($parameters_passed) ) parameters."
            }

            return $validation_results
    }
    else
    {
        Write-Log -level [ERROR] -log_file $log_file -message " No parameters passed. Try again with proper input."
        Write-Error " No parameters passed. Try again with proper input."
    }
}