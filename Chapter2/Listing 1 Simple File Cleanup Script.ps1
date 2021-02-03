# Listing 1 Simple File Cleanup Script
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


$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File | 
    Where-Object{ $_.LastWriteTime -lt $Date}    #A

$ZipName = "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
$ZipFile = Join-Path $ZipPath $ZipName    #B

$files | Compress-Archive -DestinationPath $ZipFile    #C

$files | Remove-Item -Force    #D

#A Collect the old files and save them to variable
#B Set the zip file path
#C Compress the old files
#D Delete the old files