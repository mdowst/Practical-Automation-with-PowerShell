[CmdletBinding()]
[OutputType()]
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

# Import the FileCleanupTools module
Import-Module FileCleanupTools

# Set the date filter based on the number of days in the past
$Date = (Get-Date).AddDays(-$NumberOfDays)
# Get the files to archive based on the date filter
$files = Get-ChildItem -Path $LogPath -File |
    Where-Object{ $_.LastWriteTime -lt $Date}

$ZipParameters = @{
    ZipPath = $ZipPath
    ZipPrefix = $ZipPrefix
    Date = $Date
}
# Get the archive file path
$ZipFile = Set-ArchiveFilePath @ZipParameters

# Add the files to the archive file
$files | Compress-Archive -DestinationPath $ZipFile

$RemoveFiles = @{
    ZipFile = $ZipFile
    FilesToDelete = $files
}
# confirm files are in the archive and delete
Remove-ArchivedFiles @RemoveFiles
