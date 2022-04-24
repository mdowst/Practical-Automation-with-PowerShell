# Listing 3 - Find the oscdimg.exe file
$FileName = 'oscdimg.exe'
[System.Collections.Generic.List[PSObject]] $SearchFolders = @()

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

$filePath