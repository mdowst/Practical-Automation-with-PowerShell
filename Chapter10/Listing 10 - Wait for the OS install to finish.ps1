# Listing 10 - Wait for the OS install to finish
$OsInstallTimeLimit = 30
# Command to return the VM guest hostname. It will be used to determine that the OS install has been completed.
$Command = @{
    VMId        = $VM.Id
    ScriptBlock = { $env:COMPUTERNAME }
    Credential  = $Credential
    ErrorAction = 'Stop'
}

# Include a timer or counter to ensure that your script doesn't end after so many minutes
$timer = [system.diagnostics.stopwatch]::StartNew()

# Set the variable the while loop to $null to ensure that past variables are not causing false positives
$Results = $null
while ([string]::IsNullOrEmpty($Results)) {
    try {
        # Run the command to get the hostname
        $Results = Invoke-Command @Command
    }
    catch {
        # If the timer exceeds the number of minutes, then throw a terminating error
        if ($timer.Elapsed.TotalMinutes -gt 
            $OsInstallTimeLimit) {
            throw "Failed to provision virtual machine after 10 minutes."
        }
    }
}