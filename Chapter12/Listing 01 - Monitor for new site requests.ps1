# Listing 1 - Monitor for new site requests
# Your connection information
$ClientId = '<Your Client GUID>'
$Thumbprint = '<Your Certificate Thumbprint>'
$RequestSite = "https://<subdomain>.sharepoint.com/sites/SiteManagement"
$Tenant = '<subdomain>.onmicrosoft.com'

# The Action script that will perform the site creation
$ActionScript = ".\Listing 2.ps1"

# The name of the list
$RequestList = 'Site Requests'

# Connect to the Site Management site
$PnPOnline = @{
    ClientId   = $ClientId
    Url        = $RequestSite
    Tenant     = $Tenant
    Thumbprint = $Thumbprint
}
Connect-PnPOnline @PnPOnline

# Query to get all entries on the Site Request list with the status of Submitted
$Query = @'
<View>
  <Query>
    <Where>
      <Eq>
        <FieldRef Name='Status'/>
        <Value Type='Text'>Submitted</Value>
      </Eq>
    </Where>
  </Query>
</View>
'@
$submittedSites = Get-PnPListItem -List $RequestList -Query $Query

foreach ($newSite in $submittedSites) {
    # Set the arguments from the action script
    $Arguments = "-file ""$ActionScript""",
    "-ListItemId ""$($newSite.Id)"""

    $jobParams = @{
        FilePath     = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow  = $true
        ErrorAction  = 'Stop'
    }

    # Set the status to Creating
    $PnPListItem = @{
        List     = $RequestList
        Identity = $newSite
        Values   = @{ Status = 'Creating' }
    }
    Set-PnPListItem @PnPListItem

    try {
        # Confirm that the Action Script can be found
        if (-not (Test-Path -Path $ActionScript)) {
            throw ("The file '$($ActionScript)' is not recognized as " +
                "the name of a script file. Check the spelling of the " +
                "name, or if a path was included, verify that the path " +
                "is correct and try again.")
        }

        # Invoke the action script
        Start-Process @jobParams -PassThru
    }
    catch {
        # If it errors trying to execute the action script, then report a problem
        $PnPListItem['Values'] = 
        @{ Status = 'Problem' }
        Set-PnPListItem @PnPListItem

        Write-Error $_
    }
}