# Listing 1 - Get-VSCodeExtensions.ps1
[System.Collections.Generic.List[PSObject]] $extensions = @()
# Set the home folder path based on the operating system
if ($IsLinux) {
    $homePath = '/home/'
}
else {
    $homePath = "$($env:HOMEDRIVE)\Users"
}

# Get the subfolders under the home path
$homeDirs = Get-ChildItem -Path $homePath -Directory

# Parse through each folder and check for VS Code extensions
foreach ($dir in $homeDirs) {
    $vscPath = Join-Path $dir.FullName '.vscode\extensions'
    # If the VS Code extension folder is present, search it for vsixmanifest files
    if (Test-Path -Path $vscPath) {
        $ChildItem = @{
            Path    = $vscPath
            Recurse = $true
            Filter  = '.vsixmanifest'
            Force   = $true
        }
        $manifests = Get-ChildItem @ChildItem
        foreach ($m in $manifests) {
            # Get the contents of the vsixmanifest file and convert it to a PowerShell XML object
            [xml]$vsix = Get-Content -Path $m.FullName
            # Get the details from the manifest and add them to the extensions list
            $vsix.PackageManifest.Metadata.Identity | 
            Select-Object -Property Id, Version, Publisher,
            # Add the folder path, computer name, and date to the output
            @{l = 'Folder'; e = { $m.FullName } },
            @{l = 'ComputerName'; e = {[system.environment]::MachineName}},
            @{l = 'Date'; e = { Get-Date } } | 
            ForEach-Object { $extensions.Add($_) }
        }
    }
}
# If no extensions are found, return a PowerShell object with the same properties stating nothing was found
if ($extensions.Count -eq 0) {
    $extensions.Add([pscustomobject]@{
            Id           = 'No extension found'
            Version      = $null
            Publisher    = $null
            Folder       = $null
            ComputerName = [system.environment]::MachineName
            Date         = Get-Date
        })
}
# Just like an extension, include the output at the end
$extensions