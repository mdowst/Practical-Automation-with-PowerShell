# Snippet 1 - Install and import Azure modules
```powershell
Install-Module -Name Az
Install-Module -Name Az.MonitoringSolutions
Import-Module -Name Az,Az.MonitoringSolutions
```

# Snippet 2 - Set the variables for the Azure resources to create
```powershell
$SubscriptionId = 'The GUID of your Azure subscription'
$DateString = (Get-Date).ToString('yyMMddHHmm')
$ResourceGroupName = 'PoshAutomate'
$WorkspaceName = 'poshauto' + $DateString
$AutomationAccountName = 'poshauto' + $DateString
$StorageAccountName = 'poshauto' + $DateString
$AutomationLocation = 'SouthCentralUS'
$WorkspaceLocation = 'SouthCentralUS'
```

# Snippet 3 - Connect to Azure
```powershell
Connect-AzAccount -Subscription $SubscriptionId
```

# Snippet 4 - Create the resource group
```powershell
New-AzResourceGroup -Name $ResourceGroupName -Location $AutomationLocation
```

# Snippet 5 - Create the Log Analytics workspace, Azure Automation account, and Storage account inside the resource group
```powershell
$WorkspaceParams = @{
	ResourceGroupName = $ResourceGroupName
	Name              = $WorkspaceName
	Location          = $WorkspaceLocation
}
New-AzOperationalInsightsWorkspace @WorkspaceParams

$AzAutomationAccount = @{
	ResourceGroupName = $ResourceGroupName
	Name              = $AutomationAccountName
	Location          = $AutomationLocation
	Plan              = 'Basic'
}
New-AzAutomationAccount @AzAutomationAccount

$AzStorageAccount = @{
	ResourceGroupName = $ResourceGroupName
	AccountName       = $StorageAccountName
	Location          = $AutomationLocation
	SkuName           = 'Standard_LRS'
	AccessTier        = 'Cool'
}
New-AzStorageAccount @AzStorageAccount
```

# Snippet 6 - Add the Azure Automation solution to the Log Analytics workspace
```powershell
$WorkspaceParams = @{
	ResourceGroupName = $ResourceGroupName
	Name              = $WorkspaceName
}
$workspace = Get-AzOperationalInsightsWorkspace @WorkspaceParams

$AzMonitorLogAnalyticsSolution = @{
	Type                = 'AzureAutomation'
	ResourceGroupName   = $ResourceGroupName
	Location            = $workspace.Location
	WorkspaceResourceId = $workspace.ResourceId
}
New-AzMonitorLogAnalyticsSolution @AzMonitorLogAnalyticsSolution
```

# Snippet 7 - Create a managed identity and give it contributor access to the storage account
```powershell
$AzStorageAccount = @{
	ResourceGroupName = $ResourceGroupName
	AccountName       = $StorageAccountName
}
$storage = Get-AzStorageAccount @AzStorageAccount

$AzAutomationAccount = @{
	ResourceGroupName     = $ResourceGroupName
	AutomationAccountName = $AutomationAccountName
	AssignSystemIdentity  = $true
}
$Identity = Set-AzAutomationAccount @AzAutomationAccount

$AzRoleAssignment = @{
	ObjectId           = $Identity.Identity.PrincipalId
	Scope              = $storage.Id
	RoleDefinitionName = "Contributor"
}
New-AzRoleAssignment @AzRoleAssignment
```

# Snippet 8 - Get the keys for the MMA Agent and hybrid worker registration
```powershell
$InsightsWorkspace = @{
	ResourceGroupName = $ResourceGroupName
	Name              = $WorkspaceName
}
$Workspace = Get-AzOperationalInsightsWorkspace @InsightsWorkspace

$WorkspaceSharedKey = @{
	ResourceGroupName = $ResourceGroupName
	Name              = $WorkspaceName
}
$WorspaceKeys = Get-AzOperationalInsightsWorkspaceSharedKey @WorkspaceSharedKey

$AzAutomationRegistrationInfo = @{
	ResourceGroupName     = $ResourceGroupName
	AutomationAccountName = $AutomationAccountName
}
$AutomationReg = Get-AzAutomationRegistrationInfo @AzAutomationRegistrationInfo
@"
`$WorkspaceID = '$($Workspace.CustomerId)'
`$WorkSpaceKey = '$($WorspaceKeys.PrimarySharedKey)'
`$AutoURL = '$($AutomationReg.Endpoint)'
`$AutoKey = '$($AutomationReg.PrimaryKey)'
"@
```

# Snippet 9 - Install Az modules on the Hybrid Runbook Worker
```powershell
Install-Module -Name Az -Scope AllUsers
```

# Snippet 10 - Upload local ps1 file to Azure Automation as a runbook
```powershell
$AzAutomationRunbook = @{
	Path                  = 'C:\Path\Upload-ZipToBlob.ps1'
	ResourceGroupName     = $ResourceGroupName
	AutomationAccountName = $AutomationAccountName
	Type                  = 'PowerShell'
	Name                  = 'Upload-ZipToBlob'
	Force                 = $true
}
$import = Import-AzAutomationRunbook @AzAutomationRunbook
```

# Snippet 11 - Creating Azure Automation variables
```powershell
$AutoAcct = @{
	ResourceGroupName     = $ResourceGroupName
	AutomationAccountName = $AutomationAccountName
	Encrypted             = $true
}
$Variable = @{
	Name  = 'ZipStorage_AccountName'
	Value = $StorageAccountName
}
New-AzAutomationVariable @AutoAcct @Variable

$Variable = @{
    Name  = 'ZipStorage_SubscriptionID'
    Value = $SubscriptionID
}
New-AzAutomationVariable @AutoAcct @Variable

$Variable = @{
    Name  = 'ZipStorage_ResourceGroup'
    Value = $ResourceGroupName
}
New-AzAutomationVariable @AutoAcct @Variable
```

# Snippet 12 - Importing the value of an automation variable in a runbook
```powershell
$SubscriptionID = Get-AutomationVariable -Name 'ZipStorage_SubscriptionID'
```

