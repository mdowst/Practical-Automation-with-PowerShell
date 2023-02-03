# Listing 8 - Set-PoshServer
Function Set-PoshServer {
    [CmdletBinding()]
    [OutputType([object])]
    param
    (
        [Parameter(ValueFromPipeline = $true, 
            ParameterSetName = "Pipeline")]
        [object]$InputObject,
        [Parameter(Mandatory = $true, 
            ParameterSetName = "ID")]
        [int]$ID,

        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_.Length -le 50 })]
        [string]$Name,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Windows', 'Linux')]
        [string]$OSType,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_.Length -le 50 })]
        [string]$OSVersion,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Active', 'Depot', 'Retired')]
        [string]$Status,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('WSMan', 'SSH', 'PowerCLI', 'HyperV', 'AzureRemote')]
        [string]$RemoteMethod,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_.Length -le 255 })]
        [string]$UUID,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Physical', 'VMware', 'Hyper-V', 'Azure', 'AWS')]
        [string]$Source,
        
        [Parameter(Mandatory = $false)]
        [ValidateScript( { $_.Length -le 255 })]
        [string]$SourceInstance
    )
    begin {
        [System.Collections.Generic.List[object]] $Return = @()
        [System.Collections.Generic.List[string]] $Set = @()
        [System.Collections.Generic.List[string]] $Output = @()
        # Create the SQL Parameters hashtable to hold the values for the SQL variables, starting with a null value for the ID
        $SqlParameter = @{ID = $null}
        
        # Loop through each item in the $PSBoundParameters to create the where clause while filtering out common parameters and the ID and InputObject parameters.
        $PSBoundParameters.GetEnumerator() | 
        Where-Object { $_.Key -notin @('ID', 'InputObject') +
            [System.Management.Automation.Cmdlet]::CommonParameters  } |
        ForEach-Object {
            # Add parameters other than the ID or InputObject to the Set clause array and SqlParameters.
            $set.Add("$($_.Key) = @$($_.Key)")
            $Output.Add("deleted.$($_.Key) AS Prev_$($_.Key), 
                inserted.$($_.Key) AS $($_.Key)")
            $SqlParameter.Add($_.Key, $_.Value)
        }
        
        # Set the query with the output of the changed items
        $query = 'UPDATE [dbo].' +
        "[$($_PoshAssetMgmt.ServerTable)] " +
        'SET ' + 
        ($set -join (', ')) +
        ' OUTPUT @ID AS ID, ' +
        ($Output -join (', ')) +
        ' WHERE ID = @ID'

        Write-Verbose $query

        # Set the parameters for the database update command
        $Parameters = @{
            SqlInstance  = $_SqlInstance
            Database     = $_PoshAssetMgmt.Database
            Query        = $query
            SqlParameter = @{}
        }

        # If the ID was passed, check that it matches an existing server
        if ($PSCmdlet.ParameterSetName -eq 'ID') {
            $InputObject = Get-PoshServer -Id $Id
            if (-not $InputObject) {
                throw "No server object was found for id '$Id'"
            }
        }
    }
    process {
        # Update the ID for this InputObject
        $SqlParameter['ID'] = $InputObject.ID
       
        # Update SQL parameters and execute the update
        $Parameters['SqlParameter'] = $SqlParameter
        Invoke-DbaQuery @Parameters | ForEach-Object { $Return.Add($_) }
    }
    end {
        # Return the changes
        $Return
    }
}