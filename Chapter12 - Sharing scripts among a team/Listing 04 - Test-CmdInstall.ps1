# Listing 4 - Test-CmdInstall
Function Test-CmdInstall {
    param(
        $TestCommand
    )
    try {
        # Capture the current ErrorActionPreference
        $Before = $ErrorActionPreference
        # Set ErrorActionPreference to stop on all errors, even nonterminating ones
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
        # Reset the ErrorActionPreference to the original value
        $ErrorActionPreference = $Before
    }
    $testResult
}