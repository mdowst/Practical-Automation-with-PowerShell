# Listing 9 - Invoke Action Script
param(
    $Source = 'P:\Scripts\CH03\Watcher\Source',
    $Destination = 'P:\Scripts\CH03\Watcher\Destination',
    $ActionScript = 'P:\Scripts\CH03\Watcher\Move-WatcherFile.ps1'
)

$files = Get-ChildItem -Path $Source

$sorted = $files | Sort-Object -Property CreationTime

# call your new PowerShell script in a new process
foreach($file in $sorted){
    $Arguments =  "-file ""$script""",
        "-FilePath ""$($file.FullName)""",
        "-Destination ""$($Destination)"""   
    $jobParams = @{
        FilePath = 'pwsh'
        ArgumentList = $Arguments
        NoNewWindow = $true
    }
    # use Start process to start a new PowerShell instance calling the action script
    Start-Process @jobParams
}