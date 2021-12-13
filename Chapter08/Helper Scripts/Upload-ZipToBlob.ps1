param(
    [Parameter(Mandatory = $true)]
    [string]$FolderPath,
    [Parameter(Mandatory = $true)]
    [string]$Container
)

# Connect to Azure
Connect-AzAccount -Identity

# Get the values from the automation variables
$ResourceGroupName = Get-AutomationVariable -Name 'ZipStorage_ResourceGroup'
$StorageAccountName = Get-AutomationVariable -Name 'ZipStorage_AccountName'

# Get all the ZIP files in the folder
$ZipFiles = Get-ChildItem -Path $FolderPath -Filter '*.zip'

# Get the storage keys and create a context object that will be used to authenticate with the storage account
$Keys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Keys[0].Value

# Check to see if the container exsists. If it does not create it.
$containerCheck = Get-AzStorageContainer -Name $Container -Context $Context -ErrorAction SilentlyContinue
if(-not $containerCheck){
    New-AzStorageContainer -Name $Container -Context $Context -ErrorAction Stop | Out-Null
}

foreach($file in $ZipFiles){
    # Check if the file already exists in the container. If not upload it, then delete it from the local server.
    $blobCheck = Get-AzStorageBlob -Container $container -Blob $file.Name -Context $Context -ErrorAction SilentlyContinue
    if (-not $blobCheck) {
        # Upload the file to the Azure storage
        Set-AzStorageBlobContent -File $file.FullName -Container $Container -Blob $file.Name -Context $Context -Force -ErrorAction Stop
        Remove-Item -Path $file.FullName -Force
    }
}