# Listing 12 Moving Functions to Module
param(
    [Parameter(Mandatory = $true)]
    [string]$LogPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPrefix,
    
    [Parameter(Mandatory = $false)]
    [double]$NumberOfDays = 30
)

Import-Module FileCleanupTools    #A

$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File | 
    Where-Object{ $_.LastWriteTime -lt $Date}


$ZipParameters = @{
    ZipPath = $ZipPath 
    ZipPrefix = $ZipPrefix 
    Date = $Date
}
$ZipFile = Set-ArchiveFilePath @ZipParameters

$files | Compress-Archive -DestinationPath $ZipFile

Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files
#A Replaced function with command to load the FileCleanupTools module