# GOOD FOR 2006-2017. SHOULD BE GOOD FOR ALL YEARS NO MATTER WHAT
#$files = (Get-ChildItem -Path "C:\temp\SAMPLE ORDERS\2016" -Filter "*c.prt" -File)
$files = (Get-ChildItem -Path "C:\temp\SAMPLE ORDERS\2016" -Filter "*m.prt" -File)

foreach($file in $files)
{
    $content = (Get-Content -Path "C:\temp\SAMPLE ORDERS\2016\$($file)" | Out-String)
    $orders = [regex]::Match($content,"(?<= ).+(?= )","singleline").Value -split " " # This line looks like spaces, but it is actually looking for 'FF' or form feed characters and splitting orders using them. DO NOT modify this line.

    foreach($order in $orders)
    {
        $order
        Read-Host -Prompt "Enter to continue"
        cls
    }
}