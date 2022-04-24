# Listing 4 - Connect to all Virtual Machines from a Hyper-V Host
# Prompt for credentials
$Credential = Get-Credential
# Path to save results to
$CsvFile = 'P:\Scripts\VSCodeExtensions.csv'
# The script file from listing 1
$ScriptFile = 'P:\Scripts\Get-VSCodeExtensions.ps1'
# Another CSV file to record connection errors
$ConnectionErrors = "P:\Scripts\VSCodeErrors.csv"

# Get all the virtual machines on the host
$servers = Get-VM
foreach ($VM in $servers) {
    $TurnOff = $false
    # Check if the virtual machine is running
    if ($VM.State -ne 'Running') {
        try {
            # Start the virtual machine
            $VM | Start-VM -ErrorAction Stop
        }
        catch {
            [pscustomobject]@{
                ComputerName = $s
                Date         = Get-Date
                ErrorMsg     = $_
            } | Export-Csv -Path $ConnectionErrors -Append
            # If the start command fails, continue to the next virtual machine
            continue
        }
        $TurnOff = $true
        $timer = [system.diagnostics.stopwatch]::StartNew()
        # Wait for the heartbeat to equal a value that starts with OK, letting you know the OS has booted
        while ($VM.Heartbeat -notmatch '^OK') {
            if ($timer.Elapsed.TotalSeconds -gt 5) {
                # If does not boot, break the loop and continue to the connection
                break
            }
        }
    }

    # Set the parameters using the virtual machine Id
    $Command = @{
        VMId        = $Vm.Id
        FilePath    = $ScriptFile
        Credential  = $Credential
        ErrorAction = 'Stop'
    }
    try {
        # Execute the script on the virtual machine
        $Results = Invoke-Command @Command
        $Results | Export-Csv -Path $CsvFile -Append
    }
    catch {
        # If execution fails, record the error
        [pscustomobject]@{
            ComputerName = $s
            Date         = Get-Date
            ErrorMsg     = $_
        } | Export-Csv -Path $ConnectionErrors -Append
    }

    # If the virtual machine was not running to start with, turn it back off
    if ($TurnOff -eq $true) {
        $VM | Stop-VM
    }

    # There is no disconnect needed because you did not create a persistent connection
}