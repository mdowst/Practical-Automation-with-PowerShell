# Set directory to create test files in
$Directory = 'P:\Scripts'
# For the watcher test, set number of files to create
$fileCount = 90

Function New-ChapterFolder {
    param(
        $Path,
        $ChildPath
    )
    $Directory = Join-Path -Path $Path -ChildPath $ChildPath
    if (-not (Test-Path $Directory)) {
        New-Item -Path $Directory -ItemType Directory | Out-Null
    }
    $Directory
}

Function New-ChapterScript {
    param(
        $Path,
        $ScriptName
    )
    $ScriptPath = Join-Path -Path $Path -ChildPath $ScriptName
    if (-not (Test-Path $ScriptPath)) {
        "# $ScriptName" | Out-File -FilePath $ScriptPath -Encoding UT8
    }
    $ScriptPath
}

$chFolder = New-ChapterFolder -Path $Path -ChildPath 'CH03'
$Monitor = New-ChapterFolder -Path $chFolder -ChildPath 'Monitor'
$Export = New-ChapterFolder -Path $Monitor -ChildPath 'Export'
$Watcher = New-ChapterFolder -Path $chFolder -ChildPath 'Watcher'
$Destination = New-ChapterFolder -Path $Watcher -ChildPath 'Destination'
$Logs = New-ChapterFolder -Path $Watcher -ChildPath 'Logs'
$Source = New-ChapterFolder -Path $Watcher -ChildPath 'Source'

New-ChapterScript -Path $Monitor -ScriptName 'Export-DiskSpaceInfo.ps1'
New-ChapterScript -Path $Watcher -ScriptName 'Move-WatcherFile.ps1'
New-ChapterScript -Path $Watcher -ScriptName 'Watch-Folder.ps1'

Function Set-RandomFileSize {
    param( [string]$FilePath )
    $size = Get-Random -Minimum 1 -Maximum 50
    $size = $size * 1024 * 1024
    $file = [System.IO.File]::Open($FilePath, 4)
    $file.SetLength($Size)
    $file.Close()
    Get-Item $file.Name
}
 
Function Get-RandomFileName {
    $len = 5..12 | Get-Random
    $string = ''
    for ($i = 0; $i -lt $len; $i++) {
        0..31 | Get-Random | Format-Hex | ForEach-Object {
            $string += $_.HexBytes.Split()[0]
        }
    }
    $string
}
 
$ExistingFileCount = @(Get-ChildItem -Path $Source).Count
# loop to create a file for each day back
for ($i = $ExistingFileCount; $i -lt $fileCount; $i++) {
    $minutes = 0..720 | Get-Random
    # Get Date and create log file
    $Date = (Get-Date).AddMinutes(-$minutes)
    # create unique file name with the date in it
    $FileName = "$(Get-RandomFileName).txt"
    # set the file path
    $FilePath = Join-Path -Path $Source -ChildPath $FileName
    # write the date inside the file, will override existing files
    $Date | Out-File $FilePath
    # set a random file size
    Set-RandomFileSize -FilePath $FilePath 
 
    # Set the Creation, Write, and Access time of log file to past date
    Get-Item $FilePath | ForEach-Object { 
        $_.CreationTime = $date
        $_.LastWriteTime = $date
        $_.LastAccessTime = $date 
    }
}