# Listing 6 - New-PoshServer
Function New-PoshServer {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # Validate that the server name is less than or equal to 50 characters
        [Parameter(Mandatory = $true)]
        [ValidateScript( { $_.Length -le 50 })]
        [string]$Name,

        # Validate that the OSType is one of the predefined values
        [Parameter(Mandatory = $true)]
        [ValidateSet('Windows', 'Linux')]
        [string]$OSType,

        # Validate that the OSVersion is less than or equal to 50 characters
        [Parameter(Mandatory = $true)]
        [ValidateScript( { $_.Length -le 50 })]
        [string]$OSVersion,

        # Validate that the Status is one of the predefined values
        [Parameter(Mandatory = $true)]
        [ValidateSet('Active', 'Depot', 'Retired')]
        [string]$Status,

        # Validate that the RemoteMethod is one of the predefined values
        [Parameter(Mandatory = $true)]
        [ValidateSet('WSMan', 'SSH', 'PowerCLI', 'HyperV', 'AzureRemote')]
        [string]$RemoteMethod,

        # Validate that the UUID is less than or equal to 255 characters
        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_.Length -le 255 })]
        [string]$UUID,

        # Validate that the Source is one of the predefined values.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Physical', 'VMware', 'Hyper-V', 'Azure', 'AWS')]
        [string]$Source,

        # Validate that the SourceInstance is less than or equal to 255 characters
        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_.Length -le 255 })]
        [string]$SourceInstance
    )

    # Build the data mapping for the SQL columns
    $Data = [pscustomobject]@{
        Name           = $Name
        OSType         = $OSType
        OSVersion      = $OSVersion
        Status         = $Status
        RemoteMethod   = $RemoteMethod
        UUID           = $UUID
        Source         = $Source
        SourceInstance = $SourceInstance
    }

    # Write the data to the table
    $DbaDataTable = @{
        SqlInstance = $_SqlInstance
        Database    = $_PoshAssetMgmt.Database
        InputObject = $Data
        Table       = $_PoshAssetMgmt.ServerTable
    }
    Write-DbaDataTable @DbaDataTable

    # Since Write-DbaDataTable doesn't have any output the data object, you know which ones were added
    Write-Output $Data
}
