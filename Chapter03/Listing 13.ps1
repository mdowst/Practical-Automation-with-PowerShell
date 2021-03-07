# Listing 13 - Graceful Terminations
param(
    $Source = 'P:\Scripts\CH03\Watcher\Source',
    $Destination = 'P:\Scripts\CH03\Watcher\Destination',
    $ActionScript = 'P:\Scripts\CH03\Watcher\Move-WatcherFile.ps1',
    $ConcurrentJobs = 10,
    $WatcherLog = 'P:\Scripts\CH03\Watcher\Logs\Watch-Folder.log',
    # Set your execution time limit
    $TimeLimit = 30
)

# Start Stopwatch timer
$Timer = [system.diagnostics.stopwatch]::StartNew()

if (Test-Path $WatcherLog) {
    $logDate = Get-Content $WatcherLog -Raw
    try {
        $LastCreationTime = Get-Date $logDate -ErrorAction Stop
    }
    catch {
        $LastCreationTime = Get-Date 1970-01-01
    }
}
else {
    $LastCreationTime = Get-Date 1970-01-01
}

$files = Get-ChildItem -Path $Source |
    Where-Object { $_.CreationTimeUtc -gt $LastCreationTime }
$sorted = $files | Sort-Object -Property CreationTime
-Filter '*.xml'
[int[]]$Pids = @()
foreach ($file in $sorted) {
    # Do not terminate at the beinning of the loop because nothing may ever get processed
    Get-Date $file.CreationTimeUtc -Format o | 
    Out-File $WatcherLog
    
    $Arguments = "-file ""$ActionScript""",
    "-FilePath ""$($file.FullName)""",
    "-Destination ""$($Destination)""",
    "-LogPath ""$($ActionLog)"""
    $jobParams = @{
        FilePath     = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow  = $true 
    }
    # Do not terminate before the execution if you've already written the time to the log
    $job = Start-Process @jobParams -PassThru
    $Pids += $job.Id
    
    # Do not terminate inside this loop because there is no guarantee you will hit your current limit and be over time
    while ($Pids.Count -ge $ConcurrentJobs) {
        $Pids = @(Get-Process -Id $Pids -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty Id)
        Start-Sleep -Seconds 1
        Write-Host "Pausing PID count : $($Pids.Count)"
    }

    # Break here to ensure that the current file has been completely processed and sent to the action script
    if ($Timer.Elapsed.TotalSeconds -gt $TimeLimit) {
        Write-Host "Graceful terminating after $TimeLimit seconds"
        # The 'break' command is used to exit the foreach loop, stopping the script since there is nothing after the loop
        break
    }
}