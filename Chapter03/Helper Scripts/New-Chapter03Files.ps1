# Set directory to create test files in
$Path = '.\'
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
        "# $ScriptName" | Out-File -FilePath $ScriptPath -Encoding UTF8
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

$FilesScript = Join-Path $PSScriptRoot 'New-TestWatcherFiles.ps1'
. $FilesScript
New-TestWatcherFiles -Directory $Source -fileCount $fileCount