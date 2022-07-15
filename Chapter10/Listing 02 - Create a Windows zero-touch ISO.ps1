# Listing 2 - Create a Windows zero-touch ISO
$ExtractTo = 'C:\Temp'
$password = 'P@55word'
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
$Uri = 'https://gist.githubusercontent.com/mdowst/3826e74507e0d0188e13b8' +
  'c1be453cf1/raw/0f018ec04d583b63c8cb98a52ad9f500be4ece75/Autounattend.xml'
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