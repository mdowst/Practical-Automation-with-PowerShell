# Listing 5 - Updated find installed Visual Studio Code extensions to output results to network share
# Add a variable with the path to the network share.
$CsvPath = '\\Srv01\IT\Automations\VSCode'
[System.Collections.Generic.List[PSObject]] $extensions = @()
if ($IsLinux) {
    $homePath = '/home/'
}
else {
    $homePath = "$($env:HOMEDRIVE)\Users"
}

$homeDirs = Get-ChildItem -Path $homePath -Directory

foreach ($dir in $homeDirs) {
    $vscPath = Join-Path $dir.FullName '.vscode\extensions'
    if (Test-Path -Path $vscPath) {
        $ChildItem = @{
            Path    = $vscPath
            Recurse = $true
            Filter  = '.vsixmanifest'
            Force   = $true
        }
        $manifests = Get-ChildItem @ChildItem
        foreach ($m in $manifests) {
            [xml]$vsix = Get-Content -Path $m.FullName
            $vsix.PackageManifest.Metadata.Identity | 
            Select-Object -Property Id, Version, Publisher,
            @{l = 'Folder'; e = { $m.FullName } },
            @{l = 'ComputerName'; e = {[system.environment]::MachineName}},
            @{l = 'Date'; e = { Get-Date } } | 
            ForEach-Object { $extensions.Add($_) }
        }
    }
}

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
# Create a unique file name by combining the machine name with a randomly generate GUID
$fileName = [system.environment]::MachineName +
    '-' + (New-Guid).ToString() + '.csv'
# Combine the file name with the path of the network share
$File = Join-Path -Path $CsvPath -ChildPath $fileName
# Export the results to the CSV file
$extensions | Export-Csv -Path $File -Append