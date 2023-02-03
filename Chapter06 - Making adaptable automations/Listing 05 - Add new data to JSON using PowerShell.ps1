# Listing 5 - Add new data to JSON using PowerShell
# Import the JSON file and convert it to a PowerShell object
$checks = Get-Content .\RegistryChecks.json -Raw | 
    ConvertFrom-Json

# Use Select-Object to add new properties to the object
$updated = $checks | 
    Select-Object -Property *, @{l='Type';e={'DWORD'}}, 
        @{l='Data';e={$_.Tests[0].Value}}

# Convert the updated object with the new properties back to JSON and export it
ConvertTo-Json -InputObject $updated -Depth 3 | 
    Out-File -FilePath .\RegistryChecksAndResolves.json -Encoding utf8
