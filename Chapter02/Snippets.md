# Snippet 1 - Test Listing 1 Get Top N Processes
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

# Snippet 2 - Test Listing 2 Set-ArchiveFilePath Function where folder does not exist
```powershell
Set-ArchiveFilePath -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -Date "2021-02-24" -Verbose
```
```

VERBOSE: Created folder 'L:\Archives\'
L:\Archives\LogArchive-20210124.zip
```

# Snippet 3 - Test Listing 2 Set-ArchiveFilePath Function where folder does exist
```powershell
Set-ArchiveFilePath -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -Date "2021-02-24" -Verbose
```
```

L:\Archives\LogArchive-20210124.zip
```

# Snippet 4 - Test Listing 2 Set-ArchiveFilePath Function where the zip file already exist
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

# Snippet 5 - Brevity versus efficiency example 1
```powershell
Get-ChildItem -Path $LogPath -File |  Where-Object{ $_.LastWriteTime -lt $Date} | Compress-Archive -DestinationPath $ZipFile
```

# Snippet 6 - Brevity versus efficiency example 2
```powershell
$ZipFile = Join-Path $ZipPath "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
```

# Snippet 7 - Brevity versus efficiency example 3
```powershell
$timeString = $Date.ToString('yyyyMMdd')
$ZipName = "$($ZipPrefix)$($timeString).zip"
$ZipFile = Join-Path $ZipPath $ZipName
```

# Snippet 8 - Brevity versus efficiency example 4
```powershell
$ZipFilePattern = '{0}_{1}.{2}'
$ZipFileDate = $($Date.ToString('yyyyMMdd'))
$ZipExtension = "zip"
$ZipFileName = $ZipFilePattern -f $ZipPrefix, $ZipFileDate, $ZipExtension
$ZipFile = Join-Path -Path $ZipPath -ChildPath $ZipFileName
```

# Snippet 9 - Reading inside a zip file without extracting
```powershell
$OpenZip = [IO.Compression.ZipFile]::OpenRead($ZipFile)
```

# Snippet 10 - Test Listing 4 Putting it All Together set parameters
```powershell
$LogPath = "L:\Logs\"
$ZipPath = "L:\Archives\"
$ZipPrefix = "LogArchive-"
$NumberOfDays = 30
```

# Snippet 11 - Test Listing 4 Putting it All Together - test lines date and files
```powershell
$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File |
    Where-Object{ $_.LastWriteTime -lt $Date}
```

# Snippet 12 - Test Listing 4 Putting it All Together - confirm values
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

# Snippet 13 - Test Listing 4 Putting it All Together - test Set-ArchiveFilePath
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

# Snippet 14 - Test Listing 4 Putting it All Together - test archiving files
```powershell
$files | Compress-Archive -DestinationPath $ZipFile
```

# Snippet 15 - Test Listing 4 Putting it All Together - test file removal with whatif
```powershell
Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files -WhatIf
```
```
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201112.log".
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201113.log".
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201114.log".
What if: Performing the operation "Remove File" on target "L:\Logs\u_ex20201115.log".
```

# Snippet 16 - Test Listing 4 Putting it All Together - test file removal
```powershell
Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files
```

# Snippet 17 - Import module function scripts from multiple folders
```powershell
$Public = Join-Path $PSScriptRoot 'Public'
$Private = Join-Path $PSScriptRoot 'Private'
$Functions = Get-ChildItem -Path $Public,$Private -Filter '*.ps1'
```

# Snippet 18 - Import custom module for testing
```powershell
P:\FileCleanupTools> Import-Module .\FileCleanupTools.psd1 -Force -PassThru

ModuleType Version  Name             ExportedCommands
---------- -------  ----             ----------------
Script     1.0.0.0  FileCleanupTools {Remove-ArchivedFiles,
                                       Set-ArchiveFilePath}
```

# Snippet 19 - Functions to export example
```powershell
FunctionsToExport = 'Remove-ArchivedFiles', 'Set-ArchiveFilePath'
```