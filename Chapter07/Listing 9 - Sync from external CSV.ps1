# Listing 9 - Sync from external CSV
# Import the data from the CSV
$ServerData = Import-Csv ".\SampleData.CSV"

# Get all the Virtual Machines
$ServerData | ForEach-Object {
    # Get the values for all items and mapped to the parameters for the Set-PoshServer and New-PoshServer functions.
    $values = @{
        Name           = $_.Name
        OSType         = $_.OSType
        OSVersion      = $_.OSVersion
        Status         = 'Active'
        RemoteMethod   = 'PowerCLI'
        UUID           = $_.UUID
        Source         = 'VMware'
        SourceInstance = $_.SourceInstance
    }
    
    # Run the Get-PoshServer to see if a record exists with a matching UUID
    $record = Get-PoshServer -UUID $_.UUID 

    # If the record exists, update it; otherwise, add a new record
    if($record){
        $record | Set-PoshServer @values
    }
    else{
        New-PoshServer @values
    }
}