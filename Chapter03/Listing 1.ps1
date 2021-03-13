# Listing 1 - Disk Space Monitor
$CsvPath = '.\CH03\Monitor\DiskSpaceMonitor.csv'

# Gather Disk Information and Save it to variable
$DiskSpace = Get-PSDrive -PSProvider FileSystem |
    Where-Object{$_.Name -ne 'Temp'} |
    Select-Object -Property Name,
    @{Label='UsedGB';Expression={[math]::Round($_.Used / 1GB, 2)}},
    @{Label='FreeGB';Expression={[math]::Round($_.Free / 1GB, 2)}},
    @{Label='Date';Expression={Get-Date}},
    @{Label='Computer';Expression={$env:COMPUTERNAME}} 

# Export data to CSV with append
$DiskSpace | Export-Csv -Path $CsvPath -Append

