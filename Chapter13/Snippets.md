# Snippet 1 - Install Pester
```powershell
Install-Module Pester -Scope AllUsers -Force -SkipPublisherCheck
```

# Snippet 2 - Basic test structure
```powershell
Describe "Test 1" {
    Context "Sub Test A" {
        # Test code
    }

    Context "Sub Test B" {
        # Test code
    }
}
```

# Snippet 3 - Simple test example
```powershell
Describe "Boolean Test" {
    Context "True Tests" {
        It '$true is true' {
            $true | Should -Be $true
            $true | Should -Not -Be $false
            $true | Should -BeTrue
            $true | Should -BeOfType [System.Boolean]
        }
    }

    Context "False Tests" {
        It '$false is false' {
            $false | Should -Be $false
            $false | Should -Not -Be $true
            $false | Should -BeFalse
            $false | Should -BeOfType [System.Boolean]
        }
    }
}
```

# Snippet 4 - BeforeAll Example
```powershell
Describe "Boolean Test" {
    Context "True Tests" {
        BeforeAll{
            $var = $true
        }

        It '$true is true' {
            $var | Should -BeTrue
        }

        It '$true is still true' {
            $var | Should -BeTrue
        }
    }
}
```

# Snippet 5 - BeforeAll to import function
```powershell
BeforeAll {
    Set-Location -Path $PSScriptRoot
    . .\Get-HotFixStatus.ps1
}
```

# Snippet 6 - Test Hotfix is found on the computer
```powershell
Describe 'Get-HotFixStatus' {
    It "Hotfix is found on the computer" {
        $KBFound = Get-HotFixStatus -Id 'KB5011493' -Computer 'localhost'
        $KBFound | Should -Be $true
    }
}
```

# Snippet 7 - Test Hotfix is not found on the computer
```powershell
It "Hotfix is not found on the computer" {
    $KBFound = Get-HotFixStatus -Id 'KB1234567' -Computer 'localhost'
    $KBFound | Should -Be $false
}
```

# Snippet 8 - Test remote computer connection error
```powershell
It "Hotfix is found on the computer" {
    { Get-HotFixStatus -Id 'KB5011493' -Computer 'Srv123' } | Should -Throw
}
```

# Snippet 9 - Pester Mock
```powershell
Mock Get-HotFix {}
```

# Snippet 10 - Mock the hotfix not found error
```powershell
Mock Get-HotFix {
    throw 'GetHotFixNoEntriesFound,Microsoft.PowerShell.Commands.GetHotFixCommand'
}
```

# Snippet 11 - Mock the connection failed error
```powershell
Mock Get-HotFix {
    throw 'System.Runtime.InteropServices.COMException,Microsoft.PowerShell.Commands.GetHotFixCommand'
}
```

# Snippet 12 - Install PowerHTML
```powershell
Install-Module PowerHTML
```

# Snippet 13 - Convert the results from a web page to HtmlAgilityPack.HtmlNode 
```powershell
$KbArticle = 'KB4521858'
$UriHost = 'https://www.catalog.update.microsoft.com/'
$SearchUri = $UriHost + 'Search.aspx?q=' + $KbArticle
$Search = ConvertFrom-Html -URI $SearchUri
```

# Snippet 14 - Link ID XPath
```powershell
//*[@id="83d7bc64-ff39-4073-9d77-02102226aff6_link"]
```

# Snippet 15 - Full HTML of the link used to help build the custom XPath
```powershell
<a id="83d7bc64-ff39-4073-9d77-02102226aff6_link"
   href="javascript:void(0);"
   onclick="goToDetails(&quot;83d7bc64-ff39-4073-9d77-02102226aff6&quot;);"
   class="contentTextItemSpacerNoBreakLink">
2019-10 Servicing Stack Update for Windows Server 2016 for x64-based Systems (KB4521858)
</a>
```

# Snippet 16 - Custom XPath to find links
```powershell
$xPath = '//*[' +
    '@class="contentTextItemSpacerNoBreakLink" ' +
    'and @href="javascript:void(0);"]'
$Search.SelectNodes($xPath) | Format-Table NodeType, Name, Id, InnerText
```
```
NodeType Name AttributeCount ChildNodeCount ContentLength InnerText
-------- ---- -------------- -------------- ------------- ---------
Element  a    4              1              144           …
Element  a    4              1              148           …
Element  a    4              1              148           …
```

# Snippet 17 - Loop through each search result
```powershell
$Search.SelectNodes($xPath) | ForEach-Object {
    $_.Id
}
```
```
83d7bc64-ff39-4073-9d77-02102226aff6_link
3767d7ce-29db-4d75-93b7-34922d49c9e3_link
250bfd45-b92c-49af-b604-dbdfd15061e6_link
```

# Snippet 18 - Build the URL for the search result
```powershell
$Search.SelectNodes($xPath) | ForEach-Object {
    $Id = $_.Id.Replace('_link', '')
    $DetailsUri = $UriHost +
        "ScopedViewInline.aspx?updateid=$($Id)"
    $Details = ConvertFrom-Html -Uri $DetailsUri
    $DetailsUri
}
```
```
https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=83d7bc64-ff39-4073-9d77-02102226aff6
https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=3767d7ce-29db-4d75-93b7-34922d49c9e3
https://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=250bfd45-b92c-49af-b604-dbdfd15061e6
```

# Snippet 19 - Get the web page for the hotfix details page
```powershell
$Headers = @{"accept-language"="en-US,en;q=0.9"}
$Request = Invoke-WebRequest -Uri $DetailsUri -Headers $Headers
$Details = ConvertFrom-Html -Content $Request
```

# Snippet 20 - Extract the Architecture
```powershell
$xPath = '//*[@id="archDiv"]'
$Architecture = $Details.SelectSingleNode($xPath).InnerText
$Architecture.Replace('Architecture:', '').Trim()
```
```
AMD64
```

# Snippet 21 - Extract the products
```powershell
$xPath = '//*[@id="productsDiv"]'
$Products = $Details.SelectSingleNode($xPath).InnerText
$Products = $Products.Replace('Supported products:', '')
$Products
```
```



                                    Windows 10
                                ,
                                    Windows 10 LTSB

```

# Snippet 22 - Clean up the products extract
```powershell
$xPath = '//*[@id="productsDiv"]'
$Products = $Details.SelectSingleNode($xPath).InnerText
$Products = $Products.Replace('Supported products:', '')
$Products = $Products.Split(',').Trim()
$Products
```
```
Windows 10
Windows 10 LTSB
```

# Snippet 23 - Get the superseded by information
```powershell
$xPath = '//*[@id="supersededbyInfo"]'
$DivElements = $Details.SelectSingleNode($xPath).Elements("div")
$SupersededBy = $DivElements.Elements("a")
$SupersededBy | Format-Table NodeType, Name, InnerText
```
```
NodeType Name InnerText
-------- ---- ---------
 Element a    2019-11 Servicing Stack Update for Windows Server…(KB4520724)
 Element a    2020-03 Servicing Stack Update for Windows Server…(KB4540723)
 Element a    2020-04 Servicing Stack Update for Windows Server…(KB4550994)
 Element a    2020-06 Servicing Stack Update for Windows Server…(KB4562561)
 Element a    2020-07 Servicing Stack Update for Windows Server…(KB4565912)
 Element a    2021-02 Servicing Stack Update for Windows Server…(KB5001078)
 Element a    2021-04 Servicing Stack Update for Windows Server…(KB5001402)
 Element a    2021-09 Servicing Stack Update for Windows Server…(KB5005698)
 Element a    2022-03 Servicing Stack Update for Windows Server…(KB5011570)
```

# Snippet 24 - Build a custom object with the superseded by information
```powershell
$xPath = '//*[@id="supersededbyInfo"]'
$DivElements = $Details.SelectSingleNode($xPath).Elements("div")
$SupersededBy = $DivElements.Elements("a") | Foreach-Object {
    $KB = [regex]::Match($_.InnerText.Trim(), 'KB[0-9]{7}')
    [pscustomobject]@{
        KbArticle = $KB.Value
        Title     = $_.InnerText.Trim()
        ID        = $_.Attributes.Value.Split('=')[-1]
    }
}
$SupersededBy
```
```
KbArticle Title                                                   ID
--------- -----                                                   --
KB4520724 2019-11 Servicing Stack Update for Window...(KB4520724) 447b628f…
KB4540723 2020-03 Servicing Stack Update for Window...(KB4540723) 3974a7ca…
KB4550994 2020-04 Servicing Stack Update for Window...(KB4550994) f72420c7…
KB4562561 2020-06 Servicing Stack Update for Window...(KB4562561) 3a5f48ad…
KB4565912 2020-07 Servicing Stack Update for Window...(KB4565912) 6c6eeeea…
KB5001078 2021-02 Servicing Stack Update for Window...(KB5001078) ef131c9c…
KB5001402 2021-04 Servicing Stack Update for Window...(KB5001402) 6ab99962…
KB5005698 2021-09 Servicing Stack Update for Window...(KB5005698) c0399f37…
KB5011570 2022-03 Servicing Stack Update for Window...(KB5011570) c8388301…
```
# Snippet 25 - Mock the ConvertFrom-Html with Parameter Filters and the Invoke-WebRequest cmdlet
```powershell
Mock ConvertFrom-Html -ParameterFilter{ $URI } -MockWith {
    $Path = Join-Path $PSScriptRoot "$($URI.AbsoluteUri.Split('=')[-1]).html"
    ConvertFrom-Html -Path $Path
}

Mock Invoke-WebRequest -MockWith {
    $Path = Join-Path $PSScriptRoot "$($URI.AbsoluteUri.Split('=')[-1]).html"
    $Content = Get-Content -Path $Path -Raw
    [pscustomobject]@{
        Content = $Content
    }
}
```

# Snippet 26 - Test the detail results
```powershell
$KBSearch = Find-KbSupersedence -KbArticle 'KB4521858'
$KBSearch.Id | Should -Contain '250bfd45-b92c-49af-b604-dbdfd15061e6'
$KBSearch | Where-Object{ $_.Products -contains 'Windows 10' } | Should -HaveCount 2
$KBSearch | Where-Object{ $_.Architecture -eq 'AMD64' }  | Should -HaveCount 2
$KB = $KBSearch | Where-Object{ $_.Id -eq '83d7bc64-ff39-4073-9d77-02102226aff6' }
$KB.Products  | Should -Be 'Windows Server 2016'
```

# Snippet 27 - Get the superseded results
```powershell
$KB = Find-KbSupersedence -KbArticle 'KB4521858' |
    Where-Object{ $_.Products -contains 'Windows Server 2016' }
$KB.SupersededBy
```
```
KbArticle Title                                                  ID
--------- -----                                                  --
KB4520724 2019-11 Servicing Stack Update for Windows…(KB4520724) 6d4809e8- KB4540723 2020-03 Servicing Stack Update for Windows…(KB4540723) 14075cbe-
KB4550994 2020-04 Servicing Stack Update for Windows…(KB4550994) d43e862f-
KB4562561 2020-06 Servicing Stack Update for Windows…(KB4562561) 2ce894bd-
KB4565912 2020-07 Servicing Stack Update for Windows…(KB4565912) 0804dba3-
KB5001078 2021-02 Servicing Stack Update for Windows…(KB5001078) 99e788ad-
KB5001402 2021-04 Servicing Stack Update for Windows…(KB5001402) 95335a9a-
KB5005698 2021-09 Servicing Stack Update for Windows…(KB5005698) 73f45b23-
KB5011570 2022-03 Servicing Stack Update for Windows…(KB5011570) 3fbca6b8-
```

# Snippet 28 - Confirm the IDs returned are GUIDs
```powershell
$KBSearch.Id |
   Should -Match "(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}"
$KBSearch.Products | Should -Not -Be $null
```

# Snippet 29 - Run all Pester test scripts in the current folder
```powershell
Invoke-Pester
```
```
Starting discovery in 4 files.
Discovery found 10 tests in 25ms.
Running tests.
[+] D:\Ch13\Find-KbSupersedence.Integration.Tests.ps1 10.81s (10.78s|28ms)
[+] D:\Ch13\Find-KbSupersedence.Unit.Tests.ps1 84ms (54ms|25ms)
[+] D:\Ch13\Get-HotFixStatus.Unit.Tests.ps1 48ms (15ms|25ms)
[+] D:\Ch13\Get-VulnerabilityStatus.Integration.Tests.ps1 17.05s (17.02s|23ms)
Tests completed in 28.01s
Tests Passed: 10, Failed: 0, Skipped: 0 NotRun: 0
```

# Snippet 30 - Run all Pester test scripts in the current folder and display detailed results
```powershell
$config = New-PesterConfiguration
$config.TestResult.Enabled = $true
$config.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration $config
```
```
Pester v5.3.1

Starting discovery in 4 files.
Discovery found 10 tests in 63ms.
Running tests.

Running tests from 'D:\Ch13\Find-KbSupersedence.Integration.Tests.ps1'
Describing Find-KbSupersedence
  [+] KB Article is found 3.73s (3.73s|1ms)

Running tests from 'D:\Ch13\Find-KbSupersedence.Unit.Tests.ps1'
Describing Find-KbSupersedence
  [+] KB Article is found 139ms (137ms|2ms)
  [+] In Depth Search results 21ms (20ms|0ms)
  [+] SupersededBy results 103ms (103ms|0ms)

Running tests from 'D:\Ch13\Get-HotFixStatus.Unit.Tests.ps1'
Describing Get-HotFixStatus
 Context Hotfix Found
   [+] Hotfix is found on the computer 8ms (4ms|4ms)
 Context Hotfix Not Found
   [+] Hotfix is not found on the computer 5ms (4ms|1ms)
 Context Not able to connect to the remote machine
   [+] Unable to connect 10ms (10ms|1ms)

Running tests from 'D:\Ch13\Get-VulnerabilityStatus.Integration.Tests.ps1'
Describing Find-KbSupersedence not superseded
 Context Patch Found
   [+] Patch is found on the computer 9ms (7ms|3ms)
 Context Patch Not Found
   [+] Patch is not found on the computer 10.46s (10.46s|1ms)
 Context Superseding Patch Found
   [+] Superseding Patch is found on the computer 4.27s (4.27s|1ms)
Tests completed in 18.99s
Tests Passed: 10, Failed: 0, Skipped: 0 NotRun: 0
```
