# Listing 2 - Disk Space Monitor Advanced
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

# Convert disk space gathering to a function
Function Get-DiskSpaceInfo {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $false)]
        [datetime]$Date = (Get-Date).ToUniversalTime()
    )

    $DiskSpace = Get-PSDrive -PSProvider FileSystem |
        Where-Object { $_.Name -ne 'Temp' } |
        Select-Object -Property Name,
        @{Label = 'UsedGB'; Expression = {[math]::Round($_.Used/1GB,2)}},
        @{Label = 'FreeGB'; Expression = {[math]::Round($_.Free/1GB,2)}},
        @{Label = 'Date'; Expression = { $Date } },
        @{Label = 'Computer'; Expression = { $env:COMPUTERNAME } } 

    $DiskSpace
}

# Check that path to the CSV exists and create it if it does not
$CsvFolder = Split-Path -Path $CsvPath
if (-not (Test-Path -Path $CsvFolder)) {
    New-Item -Path $CsvFolder -ItemType Directory | Out-Null
    Write-Verbose "Created folder '$CsvFolder'"
}

# Get date once so all entries have the same time and convert to UTC
$Date = (Get-Date).ToUniversalTime()

# Get disk space information and export to CSV
Get-DiskSpaceInfo -Date $Date | 
    Export-Csv -Path $CsvPath -Append
