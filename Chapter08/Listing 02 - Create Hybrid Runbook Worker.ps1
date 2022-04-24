# Listing 2 - Create Hybrid Runbook Worker
# Set the parameters for your Automation Account
$AutoUrl = ''
$AutoKey = ''
$Group   = $env:COMPUTERNAME

# Find the directory the agent was installed in
$Path = 'HKLM:\SOFTWARE\Microsoft\System Center ' +
    'Operations Manager\12\Setup\Agent'
$installPath = Get-ItemProperty -Path $Path | 
    Select-Object -ExpandProperty InstallDirectory
$AutomationFolder = Join-Path $installPath 'AzureAutomation'

# Search the folder for the HybridRegistration module
$ChildItem = @{
	Path    = $AutomationFolder
	Recurse = $true
	Include = 'HybridRegistration.psd1'
}
Get-ChildItem @ChildItem | Select-Object -ExpandProperty FullName

# Import the HybridRegistration module
Import-Module $modulePath

# Register the local machine with the automation account
$HybridRunbookWorker = @{
	Url       = $AutoUrl
	key       = $AutoKey
	GroupName = $Group
}
Add-HybridRunbookWorker @HybridRunbookWorker