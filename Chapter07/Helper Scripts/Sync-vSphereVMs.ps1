# Set vSphere server name
$vSphere = 'YourServer'
# Set vSphere credentials
$Credential = Get-Credential

# Import PowerCLI and PoshAssetMgmt modules
Import-Module -Name VMware.PowerCLI, PoshAssetMgmt

# Connect to vSphere
Connect-VIServer -Server $vSphere -Credential $Credential -Force | Out-Null

Get-VM | ForEach-Object {
    # Get the values for all items and mapped to the parameters for the Set-PoshServer and New-PoshServer functions.
    $values = @{
        Name           = $_.Name
        OSType         = (Get-OSType $_.ExtensionData.Config.GuestFullname)
        OSVersion      = $_.ExtensionData.Config.GuestFullname
        Status         = 'Active'
        RemoteMethod   = 'PowerCLI'
        UUID           = $_.Id
        Source         = 'VMware'
        SourceInstance = (Get-Cluster -VM $vm).Name
    }

    # Run the Get-PoshServer to see if a record exists with a matching UUID
    $record = Get-PoshServer -UUID $_.UUID 

    # If record exists update it otherwise add a new record
    if($record){
        # Remove any blank or null values from the hashtable to keep from erasing existing values
        ($values.GetEnumerator() | Where-Object { [string]::IsNullOrEmpty($_.Value) }) | 
            ForEach-Object { $values.Remove($_.Name) }
        
        # Update the existing object
        $record | Set-PoshServer @values
    }
    else{
        # Create a new entry in the database
        New-PoshServer @values
    }
}

# Disconnect from vSphere
Disconnect-VIServer -Server $vSphere -Force -Confirm:$false