function Work-Magic()
{
    [cmdletbinding()]
    Param(
        [Parameter(mandatory = $true)] $uic_directory,
        [Parameter(mandatory = $true)] $soldier_directory_uics,
        [Parameter(mandatory = $true)] $uic_soldier_order_file_name,
        [Parameter(mandatory = $true)] $uic_soldier_order_file_content,
        [Parameter(mandatory = $true)] $uic,
        [Parameter(mandatory = $true)] $last_name,
        [Parameter(mandatory = $true)] $first_name,
        [Parameter(mandatory = $true)] $middle_initial,
        [Parameter(mandatory = $true)] $ssn,
        [Parameter(mandatory = $true)] $soldier_directory_ord_managers
    )
	  
    if(Test-Path $($uic_directory))
    {
        Write-Log -log_file $log_file -message "$($uic_directory) already created, continuing."
        Write-Verbose "$($uic_directory) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "$($uic_directory) not created. Creating now."
        Write-Verbose "$($uic_directory) not created. Creating now."

        New-Item -ItemType Directory -Path "$($uics_directory_output)\$($uic)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "$($uic_directory) created successfully."
            Write-Verbose "$($uic_directory) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to process for $($last_name) $($first_name) $($uic). $($uic_directory) creation failed."
            Write-Error -Message " Failed to process for $($last_name) $($first_name) $($uic). $($uic_directory) creation failed."
        }
    }

    if(Test-Path $($soldier_directory_uics))
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_uics) already created, continuing."
        Write-Verbose "$($soldier_directory_uics) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_uics) not created. Creating now."
        Write-Verbose "$($soldier_directory_uics) not created. Creating now."

        New-Item -ItemType Directory -Path "$($soldier_directory_uics)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "$($soldier_directory_uics) created successfully."
            Write-Verbose "$($soldier_directory_uics) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics) creation failed."
            Write-Error -Message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory_uics)\$($uic_soldier_order_file_name)")
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_uics)\$($uic_soldier_order_file_name) already created, continuing."
        Write-Verbose "$($soldier_directory_uics)\$($uic_soldier_order_file_name) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_uics)\$($uic_soldier_order_file_name) not created. Creating now."
        Write-Verbose "$($soldier_directory_uics)\$($uic_soldier_order_file_name) not created. Creating now."

        New-Item -ItemType File -Path $($soldier_directory_uics) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "$($soldier_directory_uics)\$($uic_soldier_order_file_name) created successfully."
            Write-Verbose "$($soldier_directory_uics)\$($uic_soldier_order_file_name) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics)\$($uic_soldier_order_file_name) creation failed."
            Write-Error -Message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_uics)\$($uic_soldier_order_file_name) creation failed."
        }
    }

    if(Test-Path $($soldier_directory_ord_managers))
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_ord_managers) already created, continuing."
        Write-Verbose "$($soldier_directory_ord_managers) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_ord_managers) not created. Creating now."
        Write-Verbose "$($soldier_directory_ord_managers) not created. Creating now."

        New-Item -ItemType Directory -Path "$($soldier_directory_ord_managers)" > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "$($soldier_directory_ord_managers) created successfully."
            Write-Verbose "$($soldier_directory_ord_managers) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers) creation failed."
            Write-Error -Message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers) creation failed."
        }
    }

    if(Test-Path "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name)")
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) already created, continuing."
        Write-Verbose "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) already created, continuing."
    }
    else
    {
        Write-Log -log_file $log_file -message "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) not created. Creating now."
        Write-Verbose "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) not created. Creating now."

        New-Item -ItemType File -Path $($soldier_directory_ord_managers) -Name $($uic_soldier_order_file_name) -Value $($uic_soldier_order_file_content) > $null

        if($?)
        {
            Write-Log -log_file $log_file -message "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) created successfully."
            Write-Verbose "$($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) created successfully."
        }
        else
        {
            Write-Log -level [ERROR] -log_file $log_file -message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) creation failed."
            Write-Error -Message " Failed to process for $($last_name) $($first_name) $($uic). $($soldier_directory_ord_managers)\$($uic_soldier_order_file_name) creation failed."
        }
    }
}