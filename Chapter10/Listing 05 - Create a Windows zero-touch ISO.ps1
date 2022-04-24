# Listing 5 - Create a Windows zero-touch ISO
$SourceISOPath = "C:\ISO\Windows_Server_2022.iso"
$NewIsoPath = 'D:\ISO\Windows_Server_2022_ZeroTouch.iso' 
$ExtractTo = 'D:\Win_ISO'
$password = 'P@55word'

$Uri = "https://gist.githubusercontent.com/mdowst/3826e74507e0d0188e13b8' +
  'c1be453cf1/raw/0f018ec04d583b63c8cb98a52ad9f500be4ece75/Autounattend.xml"
$FileName = 'oscdimg.exe'
[System.Collections.Generic.List[PSObject]] $SearchFolders = @()

# Check if the folder exists and delete it if it does
if(test-path $ExtractTo){
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

# dismount the ISO
$image | Dismount-DiskImage

# Delete the bootfix.bin
$bootFix = Join-Path $ExtractTo "boot\bootfix.bin"
Remove-Item -Path $bootFix -Force 

# Rename the efisys files
$ChildItem = @{
	Path    = $ExtractTo
	Filter  = "efisys.bin"
	Recurse = $true
}
Get-ChildItem @ChildItem | Rename-Item -NewName "efisys_prompt.bin"
$ChildItem['Filter'] = "efisys_noprompt.bin"
Get-ChildItem @ChildItem | Rename-Item -NewName "efisys.bin"

# Download the AutoUnattend XML
$Path = @{
	Path      = $ExtractTo
	ChildPath = "Autounattend.xml"
}
$AutounattendXML = Join-Path @Path
Invoke-WebRequest -Uri $Uri -OutFile $AutounattendXML
 
# load the Autounattend.xml
[xml]$Autounattend = Get-Content $AutounattendXML

# Update the values
$passStr = $password + 'AdministratorPassword'
$bytes = [System.Text.Encoding]::Unicode.GetBytes($passStr)
$passEncoded = [system.convert]::ToBase64String($bytes)
$setting = $Autounattend.unattend.settings | 
    Where-Object{$_.pass -eq 'oobeSystem'}
$setting.component.UserAccounts.AdministratorPassword.Value = $passEncoded

# Select the image to use
$ChildItem = @{
	Path    = $ExtractTo
	Include = "install.wim"
	Recurse = $true
}
$ImageWim = Get-ChildItem @ChildItem
$WinImage = Get-WindowsImage -ImagePath $ImageWim.FullName | 
    Out-GridView -Title 'Select the image to use' -PassThru
$image = $WinImage.ImageIndex.ToString()

# Set the selected image in the Autounattend.xml
$setup = $Autounattend.unattend.settings | 
    Where-Object{$_.pass -eq 'windowsPE'} | 
    Select-Object -ExpandProperty component | 
    Where-Object{ $_.name -eq "Microsoft-Windows-Setup"} 
$setup.ImageInstall.OSImage.InstallFrom.MetaData.Value = $image
 
# Save the updated XML file
$Autounattend.Save($AutounattendXML)

# Check if the Assessment and Deployment Kit is installed
$ItemProperty = @{
	Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
}
$DevTools = Get-ItemProperty @ItemProperty

# If ADK is found, add the path to the folder search list
if(-not [string]::IsNullOrEmpty($DevTools.KitsRoot10)){
    $SearchFolders.Add($DevTools.KitsRoot10)
}

# Add the other common installation locations to the folder search list
$SearchFolders.Add($env:ProgramFiles)
$SearchFolders.Add(${env:ProgramFiles(x86)})
$SearchFolders.Add($env:ProgramData)
$SearchFolders.Add($env:LOCALAPPDATA)

# Add the system disks to the folder search list
Get-Volume | 
    Where-Object { $_.FileSystemLabel -ne 'Temporary Storage' -and 
    $_.DriveType -ne 'Removable' -and $_.DriveLetter } | 
    Sort-Object DriveLetter -Descending | Foreach-Object {
        $SearchFolders.Add("$($_.DriveLetter):\")
} 

# Loop through each folder and break if the executable is found
foreach ($path in $SearchFolders) {
    $ChildItem = @{
        Path        = $path
        Filter      = $FileName
        Recurse     = $true
        ErrorAction = 'SilentlyContinue'
    }
    $filePath = Get-ChildItem @ChildItem | 
        Select-Object -ExpandProperty FullName -First 1
    if($filePath){
        break
    }
}

if(-not $filePath){
    throw "$FileName not found"
}

# Get the path to the etfsboot.com file
$Path = @{
	Path      = $ExtractTo
	ChildPath = 'boot\etfsboot.com'
}
# Get the path to the efisys.bin file
$etfsboot = Join-Path @Path
$Path = @{
	Path      = $ExtractTo
	ChildPath = 'efi\microsoft\boot\efisys.bin'
}
$efisys = Join-Path @Path
# Build an array with the arguments for the oscdimg.exe
$arguments = @(
    '-m'
    '-o'
    '-u2'
    '-udfver102'
    "-bootdata:2#p0,e,b$($etfsboot)#pEF,e,b$($efisys)"
    $ExtractTo
    $NewIsoPath
)

# Execute the oscdimg.exe with the arguments using the call operator
& $filePath $arguments

# Confirm the last exit code is zero
if($LASTEXITCODE -ne 0){
    throw "ISO creation failed"
}