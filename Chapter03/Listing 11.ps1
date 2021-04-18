# Listing 11 - Invoke Action Script with Limiter and Date Log
param(
    $Source = '.\CH03\Watcher\Source',
    $Destination = '.\CH03\Watcher\Destination',
    $ActionScript = '.\CH03\Watcher\Move-WatcherFile.ps1',
    $ConcurrentJobs = 10,
    $WatcherLog = '.\CH03\Watcher\Logs\Watch-Folder.log'
    # Set a path to a log file to use for this watcher
)

# If the watch log exists, extract the date from it and converts it to DateTime
if(Test-Path $WatcherLog){
    $logDate = Get-Content $WatcherLog -Raw
    try{
        $LastCreationTime = Get-Date $logDate -ErrorAction Stop
    }
    catch{
        $LastCreationTime = Get-Date 1970-01-01
    }
}
else{
    $LastCreationTime = Get-Date 1970-01-01
}

# Filter results to only return items after the last date
$files = Get-ChildItem -Path $Source | 
    Where-Object{$_.CreationTimeUtc -gt $LastCreationTime}

$sorted = $files | Sort-Object -Property CreationTime

[int[]]$Pids = @()
foreach($file in $sorted){
    # Write the create time of the file to the log to prevent it from being picked up again
    Get-Date $file.CreationTimeUtc -Format o | 
        Out-File $WatcherLog
    $Arguments =  "-file ""$ActionScript""",
        "-FilePath ""$($file.FullName)""",
        "-Destination ""$($Destination)"""
    $jobParams = @{
        FilePath = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow = $true 
    }

    $job = Start-Process @jobParams -PassThru
    $Pids += $job.Id
    
    while($Pids.Count -ge $ConcurrentJobs){
        $Pids = @(Get-Process -Id $Pids -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty Id)
        Start-Sleep -Seconds 1
        Write-Host "Pausing PID count : $($Pids.Count)"
    }
}