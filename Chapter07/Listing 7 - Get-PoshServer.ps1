# Listing 7 - Get-PoshServer
Function Get-PoshServer {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $false)]
        [int]$ID,
        
        [Parameter(Mandatory = $false)]
        [string]$Name,

        [Parameter(Mandatory = $false)]
        [string]$OSType,

        [Parameter(Mandatory = $false)]
        [string]$OSVersion,

        [Parameter(Mandatory = $false)]
        [string]$Status,

        [Parameter(Mandatory = $false)]
        [string]$RemoteMethod,

        [Parameter(Mandatory = $false)]
        [string]$UUID,

        [Parameter(Mandatory = $false)]
        [string]$Source,

        [Parameter(Mandatory = $false)]
        [string]$SourceInstance
    )
    
    [System.Collections.Generic.List[string]] $where = @()
    $SqlParameter = @{}
    # Loop through each item in the $PSBoundParameters to create the where clause while filtering out common parameters
    $PSBoundParameters.GetEnumerator() | 
    Where-Object { $_.Key -notin 
        [System.Management.Automation.Cmdlet]::CommonParameters } |
    ForEach-Object {
        $where.Add("$($_.Key) = @$($_.Key)")
        $SqlParameter.Add($_.Key, $_.Value)
    }
    
    # Set the default query
    $Query = "SELECT * FROM " +
        $_PoshAssetMgmt.ServerTable
    
    # If where clause is needed, add it to the query
    if ($where.Count -gt 0) {
        $Query += " Where " + ($where -join (' and '))
    }

    Write-Verbose $Query

    $DbaQuery = @{
        SqlInstance  = $_SqlInstance
        Database     = $_PoshAssetMgmt.Database
        Query        = $Query
        SqlParameter = $SqlParameter
    }

    # Execute the query and output the results
    Invoke-DbaQuery @DbaQuery
}
