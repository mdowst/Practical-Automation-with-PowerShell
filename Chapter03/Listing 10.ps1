# Listing 10 - Invoke Action Script with Limiter
param(
    $Source = '.\CH03\Watcher\Source',
    $Destination = '.\CH03\Watcher\Destination',
    $ActionScript = '.\CH03\Watcher\Move-WatcherFile.ps1',
    $ConcurrentJobs = 10
)

$files = Get-ChildItem -Path $Source

$sorted = $files | Sort-Object -Property CreationTime

# Create an int array to collect the process ids
[int[]]$Pids = @()
foreach($file in $sorted){
    $Arguments =  "-file ""$script""",
        "-FilePath ""$($file.FullName)""",
        "-Destination ""$($Destination)"""
    $jobParams = @{
        FilePath = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow = $true 
    }
    # Run job with PassThru switch to pass the process id to a variable
    $job = Start-Process @jobParams -PassThru
    # Add the process id to the array
    $Pids += $job.Id
    
    # If the number of process ids is greater than or equal to the number of current jobs loop until it drops.
    while($Pids.Count -ge $ConcurrentJobs){
        $Pids = @(Get-Process -Id $Pids -ErrorAction SilentlyContinue |
        # Get-Process will only return running processes, so execute it to find the total number running.
            Select-Object -ExpandProperty Id)
        # Pause 1 second before checking again to help reduce the number of times you query the running processes.
        Start-Sleep -Seconds 1
        Write-Host "Pausing PID count : $($Pids.Count)"
    }
}