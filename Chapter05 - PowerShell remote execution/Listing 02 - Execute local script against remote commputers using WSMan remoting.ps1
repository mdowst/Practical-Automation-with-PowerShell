# Listing 2 - Execute local script against remote commputers using WSMan remoting
# Array of servers to connect to
$servers = 'Svr01', 'Svr02', 'Svr03'
# Path to save results to
$CsvFile = 'P:\Scripts\VSCodeExtensions.csv'
# The script file from listing 5.1
$ScriptFile = 'P:\Scripts\Get-VSCodeExtensions.ps1'
# Another CSV file to record connection errors
$ConnectionErrors = "P:\Scripts\VSCodeErrors.csv"

# Test whether the CSV file exists; if it does, exclude the servers already scanned
if (Test-Path -Path $CsvFile) {
    $csvData = Import-Csv -Path $CsvFile | 
        Select-Object -ExpandProperty PSComputerName -Unique
    $servers = $servers | Where-Object { $_ -notin $csvData }
}

[System.Collections.Generic.List[PSObject]] $Sessions = @()
# Connect to each server and add the session to the $Sessions array list
foreach ($s in $servers) {
    $PSSession = @{
        ComputerName = $s
    }
    try {
        $session = New-PSSession @PSSession -ErrorAction Stop
        $Sessions.Add($session)
    }
    catch {
        # Add any errors to the connection error CSV file
        [pscustomobject]@{
            ComputerName = $s
            Date         = Get-Date
            ErrorMsg     = $_
        } | Export-Csv -Path $ConnectionErrors -Append
    }
}

# Execute the script on all remote sessions at once
$Command = @{
    Session  = $Sessions
    FilePath = $ScriptFile
}
$Results = Invoke-Command @Command

# Export the results to CSV
$Results | Export-Csv -Path $CsvFile -Append

# Close and remove the remote sessions
Remove-PSSession -Session $Sessions