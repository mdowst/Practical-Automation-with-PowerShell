# Listing 4 - Test-CmdInstall
Function Test-CmdInstall {
    param(
        $TestCommand
    )
    try {
        # Capture the current Error Action Preference
        $Before = $ErrorActionPreference
        # Set Error Action Preference to stop on all errors, even none terminating ones
        $ErrorActionPreference = 'Stop'
        # Attempt to run the command
        $Command = @{
            Command = $TestCommand
        }
        $testResult = Invoke-Expression @Command
    }
    catch {
        # If an error is returned, set results to null
        $testResult = $null
    }
    finally {
        # Reset the Error Action Preference to the original value
        $ErrorActionPreference = $Before
    }
    $testResult
}