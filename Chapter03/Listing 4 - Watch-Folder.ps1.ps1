# Listing 4 - Watch-Folder.ps1
param(
    $Source = '.\CH03\Watcher\Source',
    $Destination = '.\CH03\Watcher\Destination',
    $ActionScript = '.\CH03\Watcher\Move-WatcherFile.ps1',
    $ConcurrentJobs = 10,
    $WatcherLog = '.\CH03\Watcher\Logs\Watch-Folder.log',
    $TimeLimit = 30
)

# Start Stopwatch timer
$Timer = [system.diagnostics.stopwatch]::StartNew()

# check if log file exists and set filter date if it does.
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
    # Default time if no log file is found
    $LastCreationTime = Get-Date 1970-01-01
}

# Get all the files in the folder
$files = Get-ChildItem -Path $Source |
    Where-Object { $_.CreationTimeUtc -gt $LastCreationTime }
# Sort the files based on creation time
$sorted = $files | Sort-Object -Property CreationTime

# Create an array to hold the process IDs of the action scripts
[int[]]$Pids = @()
foreach ($file in $sorted) {
    # Record the files time to the log
    Get-Date $file.CreationTimeUtc -Format o | 
        Out-File $WatcherLog
    
    # Set the arguments from the action script
    $Arguments = "-file ""$ActionScript""",
        "-FilePath ""$($file.FullName)""",
        "-Destination ""$($Destination)""",
        "-LogPath ""$($ActionLog)"""
    $jobParams = @{
        FilePath     = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow  = $true 
    }
    # Invoke the action script with the PassThruswitch to pass the process id to a variable
    $job = Start-Process @jobParams -PassThru
    # And the id to the array
    $Pids += $job.Id
    
    # If the number of process ids is greater than or equal to the number of current jobs loop until it drops.
    while ($Pids.Count -ge $ConcurrentJobs) {
        Write-Host "Pausing PID count : $($Pids.Count)"
        Start-Sleep -Seconds 1
        $Pids = @(Get-Process -Id $Pids -ErrorAction SilentlyContinue |
        # Get-Process will only return running processes, so execute it to find the total number running.
            Select-Object -ExpandProperty Id)
    }

    # Check if the total execution time is great than the timelimit
    if ($Timer.Elapsed.TotalSeconds -gt $TimeLimit) {
        Write-Host "Graceful terminating after $TimeLimit seconds"
        # The 'break' command is used to exit the foreach loop, stopping the script since there is nothing after the loop
        break
    }
}