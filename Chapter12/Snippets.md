# Snippet 1 - Install and Import the PnP.Powershell module
```powershell
Install-Module PnP.Powershell
Import-Module PnP.Powershell
```

# Snippet 2 - Connect to SharePoint Online
```powershell
Connect-PnPOnline -Url "https://<subdomain>.SharePoint.com" -UseWebLogin
```

# Snippet 3 - Create a new SharePoint site
```powershell
$PnPSite = @{
	Type       = 'CommunicationSite'
	Title      = 'Site Management'
	Url        = "https://<subdomain>.sharepoint.com/sites/SiteManagement"
	Owner      = "<your-username>@<subdomain>.onmicrosoft.com"
	SiteDesign = 'Blank'
}
New-PnPSite @PnPSite
```

# Snippet 4 - Connect to your new site
```powershell
Connect-PnPOnline -Url "https://<subdomain>.SharePoint.com/sites/SiteManagement " -UseWebLogin
```

# Snippet 5 - Get the parameters for the New-PnPTenantSite cmdlet
```powershell
$commandData = Get-Command 'New-PnPTenantSite'
$commandData.ParameterSets |
Select-Object -Property @{l='ParameterSet';
    e={$_.Name}} -ExpandProperty Parameters |
    Where-Object{ $_.Name -notin
        [System.Management.Automation.Cmdlet]::CommonParameters } |
Format-Table ParameterSet, Name, ParameterType, IsMandatory
```

# Snippet 6 - Get the SharePoint templates
```powershell
Get-PnPWebTemplates | Select-Object Name, Title, DisplayCategory
```
```
Name                 Title                                    DisplayCategory
----                 -----                                    ---------------
STS#3                Team site (no Microsoft 365 group)       Collaboration
STS#0                Team site (classic experience)           Collaboration
BDR#0                Document Center                          Enterprise
DEV#0                Developer Site                           Collaboration
OFFILE#1             Records Center                           Enterprise
EHS#1                Team Site - SharePoint Online            Enterprise
BICenterSite#0       Business Intelligence Center             Enterprise
SRCHCEN#0            Enterprise Search Center                 Enterprise
ENTERWIKI#0          Enterprise Wiki                          Publishing
PROJECTSITE#0        Project Site                             Collaboration
PRODUCTCATALOG#0     Product Catalog                          Publishing
COMMUNITY#0          Community Site                           Collaboration
COMMUNITYPORTAL#0    Community Portal                         Enterprise
SITEPAGEPUBLISHING#0 Communication site                       Publishing
SRCHCENTERLITE#0     Basic Search Center                      Enterprise
visprus#0            Visio Process Repository                 Enterprise
```

# Snippet 7 - Create a new SharePoint list to store template information
```powershell
$templateList = New-PnPList -Title 'Site Templates' -Template GenericList
Add-PnPField -List $templateList -DisplayName "Name" -InternalName "Name" -Type Text -AddToDefaultView
```

# Snippet 8 - Add the template information to the list
```powershell
$WebTemplates = Get-PnPWebTemplates
foreach($t in $WebTemplates){
    $values = @{
        Title = $t.Title
        Name = $t.Name
    }
    Add-PnpListItem -List $templateList -Values $values
}
```

# Snippet 9 - Create a list for new site requests
```powershell
$list = New-PnPList -Title 'Site Requests' -Template GenericList -OnQuickLaunch
Set-PnPList -Identity $list -EnableAttachments $false
```

# Snippet 10 - Rename the Title field
```powershell
Set-PnPField -List $list -Identity "Title" -Values @{Title="Site name"}
```

# Snippet 11 - Create a URL and Status field that are hidden from the form
```powershell
Add-PnPField -List $list -DisplayName "Site URL" -InternalName "SiteURL" -Type URL -AddToDefaultView
Set-PnPField -List $list -Identity "SiteURL" -Values @{Hidden=$True}

Add-PnPField -List $list -DisplayName "Status" -InternalName "Status" -Type Choice -AddToDefaultView -Choices "Submitted","Creating","Active","Retired",'Problem'
Set-PnPField -List $list -Identity "Status" -Values @{DefaultValue="Submitted"; Hidden=$True}
```

# Snippet 12 - Add the template list as a lookup on the Site Request list
```powershell
$xml = @"
<Field
    Type="Lookup"
    DisplayName="Template"
    Required="TRUE"
    EnforceUniqueValues="FALSE"
    List="{$($templateList.Id)}"
    ShowField="Title"
    UnlimitedLengthInDocumentLibrary="FALSE"
    RelationshipDeleteBehavior="None"
    ID="{$(New-Guid)}"
    SourceID="{$($list.Id)}"
    StaticName="Template"
    Name="Template"
    ColName="int1"
    RowOrdinal="0"
/>
"@
Add-PnPFieldFromXml -List $list -FieldXml $xml
```

# Snippet 13 - Create an app registration to use to authentication automations with SharePoint
```powershell
Register-PnPAzureADApp -ApplicationName 'PnP-SiteRequests' -Tenant '51pxfv.onmicrosoft.com' -Store CurrentUser -Interactive
```
```
WARNING: No permissions specified, using default permissions
Certificate added to store
Checking if application 'PnP-SiteRequests' does not exist yet...Success. Application 'PnP-SiteRequests' can be registered.
App PnP-SiteRequests with id 581af0eb-0d07-4744-a6f7-29ef06a7ea9f created.
Starting consent flow.

Pfx file               : C:\PnP\PnP-SiteRequests.pfx
Cer file               : C:\PnP\PnP-SiteRequests.cer
AzureAppId/ClientId    : 34873c07-f9aa-460d-b17b-ac02c8e8e77f
Certificate Thumbprint : FBE0D17755F6321E07EFDBFD6A046E4975C0277C
Base64Encoded          : MIIKRQIBAzCCCgEGCSqGSIb3DQEHAaCCCfIEggnu…
```

# Snippet 14 - Connect to SharePoint using the app registration
```powershell
$ClientId = '<Your Client GUID>'
$Thumbprint = '<Your Certificate Thumbprint>'
$RequestSite = "https://51pxfv.sharepoint.com/sites/SiteManagement"
$Tenant = '51pxfv.onmicrosoft.com'
Connect-PnPOnline -ClientId $ClientId -Url $RequestSite -Tenant $Tenant -Thumbprint $Thumbprint
```

# Snippet 15 - Get the items from an entry in the Site Requests list
```powershell
$item = Get-PnpListItem -List 'Site Requests' -Id 1
$item['Title']
$item['Author']
$item['Template']
```
```
Posh Tester

Email                       LookupId  LookupValue
-----                       --------  -----------
user@<sub>.onmicrosoft.com  6         Matthew Dowst

LookupId LookupValue        TypeId
-------- -----------        ------
      15 Communication site {f1d34cc0-9b50-4a78-be78-d5facfcccfb7}
```

# Snippet 16 - Get the internal name of the template selected
```powershell
$templateItem = Get-PnpListItem -List 'Site Templates' -Id $item['Template'].LookupId
$templateItem['Name']
```
```
SITEPAGEPUBLISHING#0
```

# Snippet 17 - Replace any illegal URL characters
```powershell
[regex]::Replace($string, "[^0-9a-zA-Z_\-'\.]", "")
```

# Snippet 18 - Set autocrlf at the system level
```powershell
git config --system core.autocrlf true
```

# Snippet 19 - Set the default branch at the user level
```powershell
git config --global init.defaultBranch <name>
```

# Snippet 20 - Install git with chocolety
```powershell
choco uninstall git.install -y
Remove-Item "$($env:USERPROFILE)\.gitconfig" -force
Remove-Item "$($env:ProgramFiles)\Git" -Recurse -force
```

# Snippet 21 - Run the git-install.ps1
```powershell
.\git-install.ps1 -branch 'main'
```
```
Chocolatey v0.12.1
Installing the following packages:
git.install
By installing, you accept licenses for the packages.
Progress: Downloading git.install 2.35.1.2... 100%

chocolatey-core.extension v1.3.5.1 [Approved]
chocolatey-core.extension package files install completed. Performing other installation steps.
 Installed/updated chocolatey-core extensions.
 The install of chocolatey-core.extension was successful.
  Software installed to 'C:\ProgramData\chocolatey\extensions\chocolatey-core'

git.install v2.35.1.2 [Approved]
git.install package files install completed. Performing other installation steps.
Using Git LFS
Installing 64-bit git.install...
git.install has been installed.
Environment Vars (like PATH) have changed. Close/reopen your shell to
 see the changes (or in powershell/cmd.exe just type `refreshenv`).
 The install of git.install was successful.
  Software installed to 'C:\Program Files\Git\'

Chocolatey installed 2/2 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
```

# Snippet 22 - Check the git configuration
```powershell
git config --list --show-scope
```
```
diff.astextplain.textconv=astextplain
system  filter.lfs.clean=git-lfs clean -- %f
system  filter.lfs.smudge=git-lfs smudge -- %f
system  filter.lfs.process=git-lfs filter-process
system  filter.lfs.required=true
system  http.sslbackend=openssl
system  http.sslcainfo=C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
system  core.autocrlf=true
system  core.fscache=true
system  core.symlinks=false
system  pull.rebase=false
system  credential.helper=manager-core
system  credential.https://dev.azure.com.usehttppath=true
system  init.defaultbranch=master
global  init.defaultbranch=main
```

# Snippet 23 - Invoke-CommandAs as System
```powershell
Install-Module -Name Invoke-CommandAs
Import-Module -Name Invoke-CommandAs
Invoke-CommandAs -ScriptBlock { . C:\git-install.ps1 } -AsSystem
```
```
Progress: Downloading git.install 2.35.1.2... 100%

git.install v2.35.1.2 [Approved]
git.install package files install completed. Performing other installation steps.
Using Git LFS
Installing 64-bit git.install...
git.install has been installed.
WARNING: Can't find git.install install location
  git.install can be automatically uninstalled.
Environment Vars (like PATH) have changed. Close/reopen your shell to
 see the changes (or in powershell/cmd.exe just type `refreshenv`).
 The install of git.install was successful.
  Software installed to 'C:\Program Files\Git\'

Chocolatey installed 1/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
```

# Snippet 24 - Check the git configuration
```powershell
git config --list --show-scope
```
```
system  diff.astextplain.textconv=astextplain
system  filter.lfs.clean=git-lfs clean -- %f
system  filter.lfs.smudge=git-lfs smudge -- %f
system  filter.lfs.process=git-lfs filter-process
system  filter.lfs.required=true
system  http.sslbackend=openssl
system  http.sslcainfo=C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
system  core.autocrlf=true
system  core.fscache=true
system  core.symlinks=false
system  pull.rebase=false
system  credential.helper=manager-core
system  credential.https://dev.azure.com.usehttppath=true
system  init.defaultbranch=master
```

# Snippet 25 - Reload environment variables
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

# Snippet 26 - Remove git and custom configuration
```powershell
choco uninstall git.install -y
Remove-Item "$($env:USERPROFILE)\.gitconfig" -force
Remove-Item "$($env:ProgramFiles)\Git" -Recurse -force
Invoke-CommandAs -ScriptBlock { . C:\git-install.ps1 } -AsSystem
```

# Snippet 27 - Reload environment variables and check the git configuration
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
git config --list --show-scope
```
```
system  diff.astextplain.textconv=astextplain
system  filter.lfs.clean=git-lfs clean -- %f
system  filter.lfs.smudge=git-lfs smudge -- %f
system  filter.lfs.process=git-lfs filter-process
system  filter.lfs.required=true
system  http.sslbackend=openssl
system  http.sslcainfo=C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
system  core.autocrlf=true
system  core.fscache=true
system  core.symlinks=false
system  pull.rebase=false
system  credential.helper=manager-core
system  credential.https://dev.azure.com.usehttppath=true
system  init.defaultbranch=master
```

# Snippet 28 - Check the git configuration
```powershell
git config --list --show-scope
```
```
system  diff.astextplain.textconv=astextplain
system  filter.lfs.clean=git-lfs clean -- %f
system  filter.lfs.smudge=git-lfs smudge -- %f
system  filter.lfs.process=git-lfs filter-process
system  filter.lfs.required=true
system  http.sslbackend=openssl
system  http.sslcainfo=C:/Program Files/Git/mingw64/ssl/certs/ca-bundle.crt
system  core.autocrlf=true
system  core.fscache=true
system  core.symlinks=false
system  pull.rebase=false
system  credential.helper=manager-core
system  credential.https://dev.azure.com.usehttppath=true
system  init.defaultbranch=master
global  init.defaultbranch=main
```
