# Snippet 1 - 
```powershell
Get-TopProcess -TopN 5
```
```


  Id ProcessName   CPU
  -- -----------   ---
1168 dwm           39,633.27
9152 mstsc         33,772.52
9112 Code          16,023.08
1216 svchost       13,093.50
2664 HealthService 10,345.77
```

# Snippet 2 - 
```powershell
Set-ArchiveFilePath -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -Date "2021-02-24" -Verbose
```
```

VERBOSE: Created folder 'L:\Archives\'
L:\Archives\LogArchive-20210124.zip
```

# Snippet 3 - 
```powershell
Set-ArchiveFilePath -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -Date "2021-02-24" -Verbose
```
```

L:\Archives\LogArchive-20210124.zip
```

# Snippet 4 - 
```powershell
Set-ArchiveFilePath -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -Date "2021-02-24" -Verbose
```
```

Exception:
Line |
  24 |          throw "The file '$ZipFile' already exists"
     |          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | The file 'L:\Archives\LogArchive-20210224.zip' already exists
```

# Snippet 5 - 
```powershell
Get-ChildItem -Path $LogPath -File |  Where-Object{ $_.LastWriteTime -lt $Date} | Compress-Archive -DestinationPath $ZipFile
```

# Snippet 6 - 
```powershell
$ZipFile = Join-Path $ZipPath "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
```

# Snippet 7 - 
```powershell
$timeString = $Date.ToString('yyyyMMdd')
$ZipName = "$($ZipPrefix)$($timeString).zip"
$ZipFile = Join-Path $ZipPath $ZipName
```

# Snippet 8 - 
```powershell
$ZipFilePattern = '{0}_{1}.{2}'
$ZipFileDate = $($Date.ToString('yyyyMMdd'))
$ZipExtension = "zip"
$ZipFileName = $ZipFilePattern -f $ZipPrefix, $ZipFileDate, $ZipExtension
$ZipFile = Join-Path -Path $ZipPath -ChildPath $ZipFileName
```

# Snippet 9 - 
```powershell
$OpenZip = [IO.Compression.ZipFile]::OpenRead($ZipFile)
```

# Snippet 10 - 
```powershell
$LogPath = "L:\Logs\"
$ZipPath = "L:\Archives\"
$ZipPrefix = "LogArchive-"
$NumberOfDays = 30
```

# Snippet 11 - 
```powershell
$Date = (Get-Date).AddDays(-$NumberOfDays)
```
```
$files = Get-ChildItem -Path $LogPath -File |
    Where-Object{ $_.LastWriteTime -lt $Date}
```

# Snippet 12 - 
```powershell
$Date
```
```
Sunday, January 10, 2021 7:59:29 AM

$files
```
```
    Directory: L:\Logs

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          11/12/2020  7:59 AM       32505856 u_ex20201112.log
-a---          11/13/2020  7:59 AM       10485760 u_ex20201113.log
-a---          11/14/2020  7:59 AM        4194304 u_ex20201114.log
-a---          11/15/2020  7:59 AM       40894464 u_ex20201115.log
-a---          11/16/2020  7:59 AM       32505856 u_ex20201116.log
…
```

# Snippet 13 - 
```powershell
$ZipParameters = @{
```
```
     >>     ZipPath = $ZipPath
     >>     ZipPrefix = $ZipPrefix
     >>     Date = $Date
     >> }
     >> $ZipFile = Set-ArchiveFilePath @ZipParameters

$ZipFile
```
```
L:\Archives\LogArchive-20210110.zip
```

# Snippet 14 - 
```powershell
$files | Compress-Archive -DestinationPath $ZipFile
```

# Snippet 15 - 
```powershell
Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files -WhatIf
```
```
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201112.log".
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201113.log".
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201114.log".
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201115.log".
```

# Snippet 16 - 
```powershell
Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files
```

# Snippet 17 - 
```powershell
$Public = Join-Path $PSScriptRoot 'Public'
$Private = Join-Path $PSScriptRoot 'Private'
$Functions = Get-ChildItem -Path $Public,$Private -Filter '*.ps1'
```

# Snippet 18 - 
```powershell
P:\FileCleanupTools> Import-Module .\FileCleanupTools.psd1 -Force -PassThru

ModuleType Version  Name             ExportedCommands
---------- -------  ----             ----------------
Script     1.0.0.0  FileCleanupTools {Remove-ArchivedFiles,
                                       Set-ArchiveFilePath}
```

# Snippet 19 - 
```powershell
FunctionsToExport = 'Remove-ArchivedFiles', 'Set-ArchiveFilePath'
```