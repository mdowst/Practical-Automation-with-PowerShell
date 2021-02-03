$LogPath      = "L:\Logs"
$ZipPath      = "L:\Archives\"
$ZipPrefix    = "LogArchive-"
$NumberOfDays = 30
# Collect the old files and save them to variable
$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File | 
    Where-Object{ $_.LastWriteTime -lt $Date}

# Set the zip file path
$ZipFile = Set-ArchiveFilePath -ZipPath $ZipPath -ZipPrefix $ZipPrefix -Date $Date

# Compress the old files
$files | Compress-Archive -DestinationPath $ZipFile -PassThru

$ZipFile = Join-Path $ZipPath "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
$ZipFileDate = $($Date.ToString('yyyyMMdd')) 
$ZipExtension = ".zip"
$ZipFileName = $ZipPrefix + $ZipFileDate + $ZipExtension
$ZipFile = Join-Path -Path $ZipPath -ChildPath $ZipFileName