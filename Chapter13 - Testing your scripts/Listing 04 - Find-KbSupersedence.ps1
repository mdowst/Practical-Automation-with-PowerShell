# Listing 4 - Find-KbSupersedence.ps1
Function Find-KbSupersedence {
    param(
        $KbArticle
    )

    $UriHost = 'https://www.catalog.update.microsoft.com/'
    $SearchUri = $UriHost + 'Search.aspx?q=' +
        $KbArticle
    $Search = ConvertFrom-Html -URI $SearchUri

    # XPath query for the KB articles returned from the search
    $xPath = '//*[' +
    '@class="contentTextItemSpacerNoBreakLink" ' +
    'and @href="javascript:void(0);"]'

    # Parse through each search result
    $Search.SelectNodes($xPath) | ForEach-Object {
        # Get the title and GUID of the KB article
        $Title = $_.InnerText.Trim()
        $Id = $_.Id.Replace('_link', '')

        # Get the details page from the Catalog
        $DetailsUri = $UriHost + 
            "ScopedViewInline.aspx?updateid=$($Id)"
        $Headers = @{"accept-language"="en-US,en;q=0.9"}
        $Request = Invoke-WebRequest -Uri $DetailsUri -Headers $Headers 
        $Details = ConvertFrom-Html -Content $Request
        
        # Get the Architecture
        $xPath = '//*[@id="archDiv"]'
        $Architecture = $Details.SelectSingleNode($xPath).InnerText
        $Architecture = $Architecture.Replace('Architecture:', '').Trim()

        # Get the products
        $xPath = '//*[@id="productsDiv"]'
        $Products = $Details.SelectSingleNode($xPath).InnerText
        $Products = $Products.Replace('Supported products:', '')
        $Products = $Products.Split(',').Trim()
    
        # Get the Superseded By Updates
        $xPath = '//*[@id="supersededbyInfo"]'
        $DivElements = $Details.SelectSingleNode($xPath).Elements("div")
        if ($DivElements.HasChildNodes) { 
            $SupersededBy = $DivElements.Elements("a") | Foreach-Object {
                $KB = [regex]::Match($_.InnerText.Trim(), 'KB[0-9]{7}')
                [pscustomobject]@{
                    KbArticle = $KB.Value
                    Title     = $_.InnerText.Trim()
                    ID        = [guid]$_.Attributes.Value.Split('=')[-1]
                }
            }
        }

        # Create a PowerShell object with search results
        [pscustomobject]@{
            KbArticle    = $KbArticle
            Title        = $Title
            Id           = $Id
            Architecture = $Architecture
            Products     = $Products
            SupersededBy = $SupersededBy
        }
    }
}