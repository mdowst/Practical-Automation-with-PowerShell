<# 
This script is a single collection of all the snippets required to 
set up the Azure environment used in chapter 8. You can run this
as a single script if you don't want to go through the individual commands.
#>

# Set variables
$SubscriptionId = 'The GUID of your Azure subscription'
$ResourceGroupName = 'PoshAutomate'
$AutomationLocation = 'SouthCentralUS'
$WorkspaceLocation = 'SouthCentralUS'

# Date string to add to resource names
$DateString = (Get-Date).ToString('yyMMddHHmm')

# Install and import the required modules
$modules = 'Az', 'Az.MonitoringSolutions'
$modules | ForEach-Object {
    if (-not (Get-Module $_ -ListAvailable)) {
        Install-Module -Name $_ -Force
    }
    Import-Module -Name $_
}

# Connect to Azure
if ($(Get-AzContext).Subscription.SubscriptionId -ne $SubscriptionId) {
    Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction SilentlyContinue
    if ($(Get-AzContext).Subscription.SubscriptionId -ne $SubscriptionId) {
        Connect-AzAccount -SubscriptionId $SubscriptionId
    }
}

# Create the resource group
Write-Host "Create resource group:"
$ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $ResourceGroup) {
    New-AzResourceGroup -Name $ResourceGroupName -Location $AutomationLocation
}
$AllResources = Get-AzResource -ResourceGroupName $ResourceGroupName

# Create the Log Analytics workspace
Write-Host "Create Log Analytics workspace:"
$WorkspaceName = $AllResources.Where({ $_.ResourceType -eq 'Microsoft.OperationalInsights/workspaces' }) | 
    Select-Object -ExpandProperty Name -First 1
if ([string]::IsNullOrEmpty($WorkspaceName)) {
    $WorkspaceName = 'poshauto' + $DateString
    $WorkspaceParams = @{
        ResourceGroupName = $ResourceGroupName
        Name              = $WorkspaceName
        Location          = $WorkspaceLocation
    }
    New-AzOperationalInsightsWorkspace @WorkspaceParams
}


# Create the Azure Automation account
Write-Host "Create automation account:"
$AutomationAccountName = $AllResources.Where({ $_.ResourceType -eq 'Microsoft.Automation/automationAccounts' }) | 
    Select-Object -ExpandProperty Name -First 1
if ([string]::IsNullOrEmpty($AutomationAccountName)) {
    $AutomationAccountName = 'poshauto' + $DateString
    $AzAutomationAccount = @{
        ResourceGroupName = $ResourceGroupName
        Name              = $AutomationAccountName
        Location          = $AutomationLocation
        Plan              = 'Basic'
    }
    New-AzAutomationAccount @AzAutomationAccount
}

# Create the storage account
Write-Host "Create storage account:"
$StorageAccountName = $AllResources.Where({ $_.ResourceType -eq 'Microsoft.Storage/storageAccounts' }) | 
    Select-Object -ExpandProperty Name -First 1
if ([string]::IsNullOrEmpty($StorageAccountName)) {
    $StorageAccountName = 'poshauto' + $DateString
    $AzStorageAccount = @{
        ResourceGroupName = $ResourceGroupName
        AccountName       = $StorageAccountName
        Location          = $AutomationLocation
        SkuName           = 'Standard_LRS'
        AccessTier        = 'Cool'
    }
    New-AzStorageAccount @AzStorageAccount
}

# Add the Automation solution to Log Analytics
Write-Host "Add the Automation solution to Log Analytics:"
if (-not $AllResources.Where({ $_.Name -eq "AzureAutomation($WorkspaceName)" -and $_.ResourceType -eq 'Microsoft.OperationsManagement/solutions' })) {
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
}

# Get the storage account
$AzStorageAccount = @{
    ResourceGroupName = $ResourceGroupName
    AccountName       = $StorageAccountName
}
$storage = Get-AzStorageAccount @AzStorageAccount

# Create a managed indentity for the Automation account
Write-Host "Create a managed indentity for the Automation account:"
$AzAutomationAccount = @{
    ResourceGroupName     = $ResourceGroupName
    AutomationAccountName = $AutomationAccountName
    AssignSystemIdentity  = $true
}
$Identity = Set-AzAutomationAccount @AzAutomationAccount

# Give the managed indentity Contributor access to the Storage Account
Write-Host "Give the managed indentity Contributor access to the Storage Account:"
$AzRoleAssignment = @{
    ObjectId           = $Identity.Identity.PrincipalId
    Scope              = $storage.Id
    RoleDefinitionName = "Contributor"
}
if (-not (Get-AzRoleAssignment @AzRoleAssignment)) {
    New-AzRoleAssignment @AzRoleAssignment
}

Set-Location $PSScriptRoot

# Upload Upload-ZipToBlob.ps1 file to Azure Automation as a runbook
Write-Host "Upload Upload-ZipToBlob.ps1 file to Azure Automation as a runbook:"
$AzAutomationRunbook = @{
    Path                  = '.\Upload-ZipToBlob.ps1'
    ResourceGroupName     = $ResourceGroupName
    AutomationAccountName = $AutomationAccountName
    Type                  = 'PowerShell'
    Name                  = 'Upload-ZipToBlob'
    Published             = $true
    Force                 = $true
}
Import-AzAutomationRunbook @AzAutomationRunbook

# Upload Output-Examples.ps1 file to Azure Automation as a runbook
Write-Host "Upload Output-Examples.ps1 file to Azure Automation as a runbook:"
$AzAutomationRunbook = @{
    Path                  = '.\Output-Examples.ps1'
    ResourceGroupName     = $ResourceGroupName
    AutomationAccountName = $AutomationAccountName
    Type                  = 'PowerShell'
    Name                  = 'Output-Examples'
    Published             = $true
    Force                 = $true
}
Import-AzAutomationRunbook @AzAutomationRunbook

# Creating the Azure Automation variables
Write-Host "Creating the Azure Automation variables:"
$AutoAcct = @{
    ResourceGroupName     = $ResourceGroupName
    AutomationAccountName = $AutomationAccountName
}
$AllVariables = Get-AzAutomationVariable @AutoAcct

$Variable = @{
    Name      = 'ZipStorage_AccountName'
    Value     = $StorageAccountName
    Encrypted = $true
}
if (-not $AllVariables.Where({ $_.Name -eq $Variable['Name'] })) {
    New-AzAutomationVariable @AutoAcct @Variable
}

$Variable = @{
    Name      = 'ZipStorage_Subscription'
    Value     = $SubscriptionID
    Encrypted = $true
}
if (-not $AllVariables.Where({ $_.Name -eq $Variable['Name'] })) {
    New-AzAutomationVariable @AutoAcct @Variable
}

$Variable = @{
    Name      = 'ZipStorage_ResourceGroup'
    Value     = $ResourceGroupName
    Encrypted = $true
}
if (-not $AllVariables.Where({ $_.Name -eq $Variable['Name'] })) {
    New-AzAutomationVariable @AutoAcct @Variable
}

# Get the keys for the MMA Agent
Write-Host "Get the keys for the MMA Agent:"
$InsightsWorkspace = @{
    ResourceGroupName = $ResourceGroupName
    Name              = $WorkspaceName
}
$Workspace = Get-AzOperationalInsightsWorkspace @InsightsWorkspace
$WorkspaceSharedKey = @{
    ResourceGroupName = $ResourceGroupName
    Name              = $WorkspaceName
    WarningAction     = 'SilentlyContinue'
}
$WorspaceKeys = Get-AzOperationalInsightsWorkspaceSharedKey @WorkspaceSharedKey

# Get the keys for the hybrid worker registration
Write-Host "Get the keys for the hybrid worker registration:"
$AzAutomationRegistrationInfo = @{
    ResourceGroupName     = $ResourceGroupName
    AutomationAccountName = $AutomationAccountName
}
$AutomationReg = Get-AzAutomationRegistrationInfo @AzAutomationRegistrationInfo

# Output the keys for future use
Write-Host "`nSave these keys to setup hybrid runbook worker:" -ForegroundColor Green
$keys = @"
`$WorkspaceID = '$($Workspace.CustomerId)'
`$WorkSpaceKey = '$($WorspaceKeys.PrimarySharedKey)'
`$AutoURL = '$($AutomationReg.Endpoint)'
`$AutoKey = '$($AutomationReg.PrimaryKey)'
"@
Write-Host $keys -ForegroundColor Yellow