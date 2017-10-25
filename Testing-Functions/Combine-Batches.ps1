$order_files = @(Get-ChildItem -Path "C:\temp\TESTING\TMP\MOF" -File | Where { $_.Extension -eq '.mof' } | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } | Select -First 250 | Select FullName)
$order_files_done = @()

$start = 1
$end = $order_files.Count

$run_date = (Get-Date -UFormat "%Y-%m-%d_%H-%M-%S")
$order_files_count = $($order_files).Count

do{
    # Set outfile name for each batch
    $out_file = "C:\temp\OUTPUT\$($start)-$($end)_$($run_date).txt"
    New-Item -ItemType File $out_file -Force > $null

    # Combine 250 files into batch
    $order_files | % { Get-Content $_.FullName | Add-Content $($out_file) }

    # Move files out
    $order_files | % { Move-Item $_.FullName "C:\temp\TESTING\TMP\MOF\ORIGINAL_SPLITS\$($_.Name)" }

    # Repopulate array
    $order_files = @(Get-ChildItem -Path "C:\temp\TESTING\TMP\MOF" -File | Where { $_.Extension -eq '.mof' } | Sort-Object { [regex]::Replace($_.Name, '\d+', { $args[0].Value.PadLeft(20) }) } | Select -First 250 | Select FullName)
    $order_files_count = $($order_files).Count

    $start = $end
    $end = $start + $($order_files_count)
}
While($order_files_count -ne 0)