# Listing 5 - Connect-PoshAssetMgmt
Function Connect-PoshAssetMgmt {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$SqlInstance = $_PoshAssetMgmt.SqlInstance,

        [Parameter(Mandatory = $false)]
        [string]$Database = $_PoshAssetMgmt.Database,

        [Parameter(Mandatory = $false)]
        [PSCredential]$Credential
    )

    # Set default connection parameters
    $connection = @{
        SqlInstance = $SqlInstance
        Database    = $Database
    }

    # Add credential object if passed
    if ($Credential) {
        $connection.Add('SqlCredential', $Credential)
    }

    $Script:_SqlInstance = Connect-DbaInstance @connection

    # Output the result, so the person running it can confirm the connection information
    $Script:_SqlInstance
}