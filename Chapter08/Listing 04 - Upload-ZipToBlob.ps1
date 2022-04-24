# Listing 4 - Upload-ZipToBlob
param(
    [Parameter(Mandatory = $true)]
    [string]$FolderPath,
    [Parameter(Mandatory = $true)]
    [string]$Container
)

# Get the Azure Storage Variables
$SubscriptionID = Get-AutomationVariable `
    -Name 'ZipStorage_SubscriptionID'
$ResourceGroupName = Get-AutomationVariable -Name 'ZipStorage_ResourceGroup'
$StorageAccountName = Get-AutomationVariable -Name 'ZipStorage_AccountName'

# Connect to Azure
Connect-AzAccount -Identity
Set-AzContext -Subscription $SubscriptionID

# Get all the ZIP files in the folder
$ChildItem = @{
	Path   = $FolderPath
	Filter = '*.zip'
}
$ZipFiles = Get-ChildItem @ChildItem

# Get the storage keys and create a context object that will be used to authenticate with the storage account
$AzStorageAccountKey = @{
	ResourceGroupName = $ResourceGroupName
	Name              = $StorageAccountName
}
$Keys = Get-AzStorageAccountKey @AzStorageAccountKey
$AzStorageContext = @{
	StorageAccountName = $StorageAccountName
	StorageAccountKey  = $Keys[0].Value
}
$Context = New-AzStorageContext @AzStorageContext

# Check to see if the container exists. If it does not, create it.
$AzStorageContainer = @{
	Name        = $Container
	Context     = $Context
	ErrorAction = 'SilentlyContinue'
}
$containerCheck = Get-AzStorageContainer @AzStorageContainer
if(-not $containerCheck){
    $AzStorageContainer = @{
        Name        = $Container
        Context     = $Context
        ErrorAction = 'Stop'
    }
    New-AzStorageContainer @AzStorageContainer| Out-Null
}

foreach($file in $ZipFiles){
    # Check if the file already exists in the container. If not, upload it, then delete it from the local server.
    $AzStorageBlob = @{
        Container   = $container
        Blob        = $file.Name
        Context     = $Context
        ErrorAction = 'SilentlyContinue'
    }
    $blobCheck = Get-AzStorageBlob @AzStorageBlob
    if (-not $blobCheck) {
        # Upload the file to the Azure storage
        $AzStorageBlobContent = @{
            File        = $file.FullName
            Container   = $Container
            Blob        = $file.Name
            Context     = $Context
            Force       = $true
            ErrorAction = 'Stop'
        }
        Set-AzStorageBlobContent @AzStorageBlobContent
        Remove-Item -Path $file.FullName -Force
    }
}