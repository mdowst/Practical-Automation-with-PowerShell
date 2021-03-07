# Listing 10 - Invoke Action Script with Limiter
param(
    $Source = 'P:\Scripts\CH03\Watcher\Source',
    $Destination = 'P:\Scripts\CH03\Watcher\Destination',
    $ActionScript = 'P:\Scripts\CH03\Watcher\Move-WatcherFile.ps1',
    $ConcurrentJobs = 10
)

$files = Get-ChildItem -Path $Source

$sorted = $files | Sort-Object -Property CreationTime

# create a int array to collect the process ids
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
    # run job with PassThru switch to pass the process id to a variable
    $job = Start-Process @jobParams -PassThru
    # add the process id to the array
    $Pids += $job.Id
    
    # if the number of process ids is great than or equal to the number of current jobs loop until it drops
    while($Pids.Count -ge $ConcurrentJobs){
        $Pids = @(Get-Process -Id $Pids -ErrorAction SilentlyContinue |
        # Get-Process will only return processes that are running, so requery it to find total number running
            Select-Object -ExpandProperty Id)
        # Pause 1 second before checking again to help reduce number of times you query the running processes
        Start-Sleep -Seconds 1
        Write-Host "Pausing PID count : $($Pids.Count)"
    }
}