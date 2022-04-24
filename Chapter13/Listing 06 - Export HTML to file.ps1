# Listing 6 - Export HTML to file
$KbArticle = 'KB5008295'

# Build the search URL
$UriHost = 'https://www.catalog.update.microsoft.com/'
$SearchUri = $UriHost + 'Search.aspx?q=' + $KbArticle

# Get the search results
$Search = ConvertFrom-Html -URI $SearchUri

# Output the HTML of the page to a file named after the KB
$Search.OuterHtml | Out-File ".\$($KbArticle).html"

# XPath query for the KB articles returned from the search
$xPath = '//*[' +
'@class="contentTextItemSpacerNoBreakLink" ' +
'and @href="javascript:void(0);"]'

# Parse through each search result
$Search.SelectNodes($xPath) | ForEach-Object {
    # Get the ID and use it to get the details page from the Catalog
    $Id = $_.Id.Replace('_link', '')
    $DetailsUri = $UriHost +
        "ScopedViewInline.aspx?updateid=$($Id)"
    $Header = @{"accept-language"="en-US,en;q=0.9"}
    $Details = Invoke-WebRequest -Uri $DetailsUri -Headers $Header | 
        ConvertFrom-Html
    
    # Output the HTML of the page to a file named after the ID
    $Details.OuterHtml | Out-File ".\$($Id).html"
}

