# Listing 1 - Extract the ISO
$ExtractTo = 'C:\Temp'
$SourceISOPath = 'C:\ISO\WindowsSrv2022.iso'
# Check if the folder exists and delete it if it does
if (test-path $ExtractTo) {
    Remove-Item -Path $ExtractTo -Recurse -Force 
} 

# Mount the ISO image
$DiskImage = @{
    ImagePath = $SourceISOPath
    PassThru  = $true
}
$image = Mount-DiskImage @DiskImage

# Get the new drive letter
$drive = $image | 
    Get-Volume | 
    Select-Object -ExpandProperty DriveLetter

# Create destination folder
New-Item -type directory -Path $ExtractTo

# Copy the ISO files
Get-ChildItem -Path "$($drive):" | 
    Copy-Item -Destination $ExtractTo -recurse -Force

# Remove the read-only flag for all files and folders
Get-ChildItem -Path $ExtractTo -Recurse | 
    ForEach-Object {
    Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $false
}

# Dismount the ISO
$image | Dismount-DiskImage