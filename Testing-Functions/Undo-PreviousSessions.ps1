function Undo-PreviousSessions()
{
    $format_165 = @()
    $format_172 = @()
    $format_700 = @()
    $format_705 = @()
    $format_290 = @()
    $format_others = @()

    $created_orders = @{
	    FORMAT_165 = $format_165; 
	    FORMAT_172 = $format_172; 
	    FORMAT_700 = $format_700; 
	    FORMAT_705 = $format_705; 
	    FORMAT_290 = $format_290;
	    FORMAT_OTHERS = $format_others
    }

    # Populate each format array using import-csv and if, ifelse statements
    $csv_path = 'C:\temp\ORDPRO\TMP\LOGS\2017-10-29_23-42-06\2017-10-29_23-42-06_orders_created_main.csv'
    Get-ChildItem $csv_path -Include *.csv |
	    ForEach-Object {
		    $source_data = Import-Csv $_.FullName
		    foreach($source in $source_data)
		    {
			    if($source.FORMAT -eq '165')
			    {
				    $object = New-Object -TypeName PSObject
				    $object | Add-Member -MemberType NoteProperty -Name UIC -Value $source.UIC
				    $object | Add-Member -MemberType NoteProperty -Name LAST_NAME -Value $source.LAST_NAME
				    $object | Add-Member -MemberType NoteProperty -Name FIRST_NAME -Value $source.FIRST_NAME
				    $object | Add-Member -MemberType NoteProperty -Name MIDDLE_INITIAL -Value $source.MIDDLE_INITIAL
				    $object | Add-Member -MemberType NoteProperty -Name PUBLISHED_YEAR -Value $source.PUBLISHED_YEAR
				    $object | Add-Member -MemberType NoteProperty -Name PUBLISHED_MONTH -Value $source.PUBLISHED_MONTH
				    $object | Add-Member -MemberType NoteProperty -Name PUBLISHED_DAY -Value $source.PUBLISHED_DAY
				    $object | Add-Member -MemberType NoteProperty -Name SSN -Value $source.SSN
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_YEAR -Value $source.PERIOD_FROM_YEAR
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_MONTH -Value $source.PERIOD_FROM_MONTH
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_DAY -Value $source.PERIOD_FROM_DAY
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_YEAR -Value $source.PERIOD_TO_YEAR
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_MONTH -Value $source.PERIOD_TO_MONTH
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_NUMBER -Value $source.PERIOD_TO_NUMBER
				    $object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_TIME -Value $source.PERIOD_TO_TIME
				    $object | Add-Member -MemberType NoteProperty -Name FORMAT -Value $source.FORMAT
				    $object | Add-Member -MemberType NoteProperty -Name ORDER_AMENDED -Value $source.ORDER_AMENDED
				    $object | Add-Member -MemberType NoteProperty -Name ORDER_REVOKE -Value $source.ORDER_REVOKE
				    $object | Add-Member -MemberType NoteProperty -Name ORDER_NUMBER -Value $source.ORDER_NUMBER
				    $format_165 += $object
			    }
			    elseif($source.FORMAT -eq '172')
			    {
				$object = New-Object -TypeName PSObject
				$object | Add-Member -MemberType NoteProperty -Name UIC -Value $source.UIC
				$object | Add-Member -MemberType NoteProperty -Name LAST_NAME -Value $source.LAST_NAME
				$object | Add-Member -MemberType NoteProperty -Name FIRST_NAME -Value $source.FIRST_NAME
				$object | Add-Member -MemberType NoteProperty -Name MIDDLE_INITIAL -Value $source.MIDDLE_INITIAL
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_YEAR -Value $source.PUBLISHED_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_MONTH -Value $source.PUBLISHED_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_DAY -Value $source.PUBLISHED_DAY
				$object | Add-Member -MemberType NoteProperty -Name SSN -Value $source.SSN
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_YEAR -Value $source.PERIOD_FROM_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_MONTH -Value $source.PERIOD_FROM_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_DAY -Value $source.PERIOD_FROM_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_YEAR -Value $source.PERIOD_TO_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_MONTH -Value $source.PERIOD_TO_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_DAY -Value $source.PERIOD_TO_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_NUMBER -Value $source.PERIOD_TO_NUMBER
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_TIME -Value $source.PERIOD_TO_TIME
				$object | Add-Member -MemberType NoteProperty -Name FORMAT -Value $source.FORMAT
				$object | Add-Member -MemberType NoteProperty -Name ORDER_AMENDED -Value $source.ORDER_AMENDED
				$object | Add-Member -MemberType NoteProperty -Name ORDER_REVOKE -Value $source.ORDER_REVOKE
				$object | Add-Member -MemberType NoteProperty -Name ORDER_NUMBER -Value $source.ORDER_NUMBER
				$format_172 += $object
			    }
			    elseif($source.FORMAT -eq '700')
                {
				$object = New-Object -TypeName PSObject
				$object | Add-Member -MemberType NoteProperty -Name UIC -Value $source.UIC
				$object | Add-Member -MemberType NoteProperty -Name LAST_NAME -Value $source.LAST_NAME
				$object | Add-Member -MemberType NoteProperty -Name FIRST_NAME -Value $source.FIRST_NAME
				$object | Add-Member -MemberType NoteProperty -Name MIDDLE_INITIAL -Value $source.MIDDLE_INITIAL
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_YEAR -Value $source.PUBLISHED_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_MONTH -Value $source.PUBLISHED_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_DAY -Value $source.PUBLISHED_DAY
				$object | Add-Member -MemberType NoteProperty -Name SSN -Value $source.SSN
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_YEAR -Value $source.PERIOD_FROM_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_MONTH -Value $source.PERIOD_FROM_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_DAY -Value $source.PERIOD_FROM_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_YEAR -Value $source.PERIOD_TO_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_MONTH -Value $source.PERIOD_TO_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_NUMBER -Value $source.PERIOD_TO_NUMBER
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_TIME -Value $source.PERIOD_TO_TIME
				$object | Add-Member -MemberType NoteProperty -Name FORMAT -Value $source.FORMAT
				$object | Add-Member -MemberType NoteProperty -Name ORDER_AMENDED -Value $source.ORDER_AMENDED
				$object | Add-Member -MemberType NoteProperty -Name ORDER_REVOKE -Value $source.ORDER_REVOKE
				$object | Add-Member -MemberType NoteProperty -Name ORDER_NUMBER -Value $source.ORDER_NUMBER
				$format_700 += $object
                }
			    elseif($source.FORMAT -eq '705')
                {
				$object = New-Object -TypeName PSObject
				$object | Add-Member -MemberType NoteProperty -Name UIC -Value $source.UIC
				$object | Add-Member -MemberType NoteProperty -Name LAST_NAME -Value $source.LAST_NAME
				$object | Add-Member -MemberType NoteProperty -Name FIRST_NAME -Value $source.FIRST_NAME
				$object | Add-Member -MemberType NoteProperty -Name MIDDLE_INITIAL -Value $source.MIDDLE_INITIAL
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_YEAR -Value $source.PUBLISHED_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_MONTH -Value $source.PUBLISHED_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_DAY -Value $source.PUBLISHED_DAY
				$object | Add-Member -MemberType NoteProperty -Name SSN -Value $source.SSN
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_YEAR -Value $source.PERIOD_FROM_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_MONTH -Value $source.PERIOD_FROM_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_DAY -Value $source.PERIOD_FROM_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_YEAR -Value $source.PERIOD_TO_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_MONTH -Value $source.PERIOD_TO_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_NUMBER -Value $source.PERIOD_TO_NUMBER
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_TIME -Value $source.PERIOD_TO_TIME
				$object | Add-Member -MemberType NoteProperty -Name FORMAT -Value $source.FORMAT
				$object | Add-Member -MemberType NoteProperty -Name ORDER_AMENDED -Value $source.ORDER_AMENDED
				$object | Add-Member -MemberType NoteProperty -Name ORDER_REVOKE -Value $source.ORDER_REVOKE
				$object | Add-Member -MemberType NoteProperty -Name ORDER_NUMBER -Value $source.ORDER_NUMBER
				$format_705 += $object
                }
			    elseif($source.FORMAT -eq '290')
                {
				$object = New-Object -TypeName PSObject
				$object | Add-Member -MemberType NoteProperty -Name UIC -Value $source.UIC
				$object | Add-Member -MemberType NoteProperty -Name LAST_NAME -Value $source.LAST_NAME
				$object | Add-Member -MemberType NoteProperty -Name FIRST_NAME -Value $source.FIRST_NAME
				$object | Add-Member -MemberType NoteProperty -Name MIDDLE_INITIAL -Value $source.MIDDLE_INITIAL
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_YEAR -Value $source.PUBLISHED_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_MONTH -Value $source.PUBLISHED_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_DAY -Value $source.PUBLISHED_DAY
				$object | Add-Member -MemberType NoteProperty -Name SSN -Value $source.SSN
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_YEAR -Value $source.PERIOD_FROM_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_MONTH -Value $source.PERIOD_FROM_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_DAY -Value $source.PERIOD_FROM_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_YEAR -Value $source.PERIOD_TO_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_MONTH -Value $source.PERIOD_TO_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_DAY -Value $source.PERIOD_TO_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_NUMBER -Value $source.PERIOD_TO_NUMBER
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_TIME -Value $source.PERIOD_TO_TIME
				$object | Add-Member -MemberType NoteProperty -Name FORMAT -Value $source.FORMAT
				$object | Add-Member -MemberType NoteProperty -Name ORDER_AMENDED -Value $source.ORDER_AMENDED
				$object | Add-Member -MemberType NoteProperty -Name ORDER_REVOKE -Value $source.ORDER_REVOKE
				$object | Add-Member -MemberType NoteProperty -Name ORDER_NUMBER -Value $source.ORDER_NUMBER
				$format_290 += $object
                }
			    elseif($source.FORMAT -eq '296' -or $source.FORMAT -eq '282' -or $source.FORMAT -eq '294' -or $source.FORMAT -eq '284')
                {
				$object = New-Object -TypeName PSObject
				$object | Add-Member -MemberType NoteProperty -Name UIC -Value $source.UIC
				$object | Add-Member -MemberType NoteProperty -Name LAST_NAME -Value $source.LAST_NAME
				$object | Add-Member -MemberType NoteProperty -Name FIRST_NAME -Value $source.FIRST_NAME
				$object | Add-Member -MemberType NoteProperty -Name MIDDLE_INITIAL -Value $source.MIDDLE_INITIAL
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_YEAR -Value $source.PUBLISHED_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_MONTH -Value $source.PUBLISHED_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PUBLISHED_DAY -Value $source.PUBLISHED_DAY
				$object | Add-Member -MemberType NoteProperty -Name SSN -Value $source.SSN
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_YEAR -Value $source.PERIOD_FROM_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_MONTH -Value $source.PERIOD_FROM_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_FROM_DAY -Value $source.PERIOD_FROM_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_YEAR -Value $source.PERIOD_TO_YEAR
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_MONTH -Value $source.PERIOD_TO_MONTH
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_DAY -Value $source.PERIOD_TO_DAY
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_NUMBER -Value $source.PERIOD_TO_NUMBER
				$object | Add-Member -MemberType NoteProperty -Name PERIOD_TO_TIME -Value $source.PERIOD_TO_TIME
				$object | Add-Member -MemberType NoteProperty -Name FORMAT -Value $source.FORMAT
				$object | Add-Member -MemberType NoteProperty -Name ORDER_AMENDED -Value $source.ORDER_AMENDED
				$object | Add-Member -MemberType NoteProperty -Name ORDER_REVOKE -Value $source.ORDER_REVOKE
				$object | Add-Member -MemberType NoteProperty -Name ORDER_NUMBER -Value $source.ORDER_NUMBER
				$FORMAT_OTHERS += $object
			    }
		    }
	    }
}