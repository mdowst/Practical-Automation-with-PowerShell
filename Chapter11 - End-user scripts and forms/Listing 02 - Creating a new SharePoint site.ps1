# Listing 2 - Creating a new SharePoint site
param(
    [Parameter(Mandatory = $false)]
    [int]$ListItemId = 1
)
# Your connection information
$ClientId = '<Your Client GUID>'
$Thumbprint = '<Your Certificate Thumbprint>'
$RequestSite = "https://<subdomain>.sharepoint.com/sites/SiteManagement"
$Tenant = '<subdomain>.onmicrosoft.com'

# The name of the list
$RequestList = 'Site Requests'
$TemplateList = 'Site Templates'

# Set the parameters to set the Status to Problem if anything goes wrong during the script execution
$SiteProblem = @{
    List     = $RequestList
    Identity = $ListItemId
    Values   = @{ Status = 'Problem' }
}

# Connect to the Site Management site
$PnPOnline = @{
    ClientId   = $ClientId
    Url        = $RequestSite
    Tenant     = $Tenant
    Thumbprint = $Thumbprint
}
Connect-PnPOnline @PnPOnline

# Get the site request details from SharePoint
$PnPListItem = @{
	List = $RequestList
	Id   = $ListItemId
}
$siteRequest = Get-PnPListItem @PnPListItem

# Look up the name of the template from the Site Templates list
$PnpListItem = @{
    List = $TemplateList
    Id   = $siteRequest['Template'].LookupId
}
$templateItem = Get-PnpListItem @PnpListItem

# Get the current web object. It will be used to determine URL and time zone ID.
$web = Get-PnPWeb -Includes 'RegionalSettings.TimeZone'

# Get the top-level SharePoint URL from the current website URL
$URI = [URI]::New($web.Url)
$ParentURL = $URI.GetLeftPart([System.UriPartial]::Authority)
$BaseURL = $ParentURL + '/sites/'

# Get the site URL path from the title
$regex = "[^0-9a-zA-Z_\-'\.]"
$Path = [regex]::Replace($siteRequest['Title'], $regex, "")
$URL = $BaseURL + $Path

$iteration = 1
do {
    try {
        # If the site is not found, then trigger the catch
        $PnPTenantSite = @{
            Identity    = $URL
            ErrorAction = 'Stop'
        }
        Get-PnPTenantSite @PnPTenantSite
        # If it is found, then add a number to the end and check again
        $URL = $BaseURL + $Path + 
            $iteration.ToString('00')
        $iteration++
    }
    catch {
        # If error ID does not match the expected value for the site not being there, set the Status to Problem and throw a terminating error
        if ($_.FullyQualifiedErrorId -ne 
            'EXCEPTION,PnP.PowerShell.Commands.GetTenantSite') {
            Set-PnPListItem @SiteProblem
            throw $_
        }
        else {
            $siteCheck = $null
        }
    }
    # Final fail-safe: If the iterations get too high, something went wrong, so set the Status to Problem and terminate the script
    if ($iteration -gt 99) {
        Set-PnPListItem @SiteProblem
        throw "Unable to find unique website name for '$($URL)'"
    }
} while ( $siteCheck )

# Set all the parameter values
$PnPTenantSite = @{
    Title    = $siteRequest['Title']
    Url      = $URL
    Owner    = $siteRequest['Author'].Email
    Template = $templateItem['Name']
    TimeZone = $web.RegionalSettings.TimeZone.Id
}
try {
    # Create the new site
    New-PnPTenantSite @PnPTenantSite -ErrorAction Stop

    # Update the original request with the URL and set the status to Active
    $values = @{
        Status  = 'Active'
        SiteURL = $URL
    }
    $PnPListItem = @{
        List     = $RequestList
        Identity = $ListItemId
        Values   = $values
    }
    Set-PnPListItem @PnPListItem
}
catch {
    # If something goes wrong in the site- creation process, set the status to Problem
    Set-PnPListItem @SiteProblem
}