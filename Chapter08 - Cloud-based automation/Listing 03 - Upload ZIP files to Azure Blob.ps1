# Listing 3 - Upload ZIP files to Azure Blob
# Set the local variables
$FolderPath = 'L:\Archives'
$Container = 'devtest'

# Set the Azure Storage Variables
$ResourceGroupName = 'PoshAutomate'
$StorageAccountName = ''
$SubscriptionID = ''

# Connect to Azure
Connect-AzAccount
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

# Check to see whether the container exists. If it does not, create it
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
    # Check whether the file already exists in the container. If not, upload it, and then delete it from the local server
    $AzStorageBlob = @{
        Container   = $container
        Blob        = $file.Name
        Context     = $Context
        ErrorAction = 'SilentlyContinue'
    }
    $blobCheck = Get-AzStorageBlob @AzStorageBlob
    if (-not $blobCheck) {
        # Upload the file to Azure storage
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
