# Listing 1 - Get-HotFixStatus
Function Get-HotFixStatus{
    param(
        $Id,
        $Computer
    )
    
    # Set the initial value to false
    $Found = $false
    try{
        # Attempt to return the patch and stop execution on any error
        $HotFix = @{
            Id           = $Id
            ComputerName = $Computer
            ErrorAction  = 'Stop'
        }
        Get-HotFix @HotFix | Out-Null
        # If the previous command did not error, then it is safe to assume it was found
        $Found = $true
    }
    catch{
        # If the catch block is triggered, check to see if the error was because the patch was not found
        $NotFound = 'GetHotFixNoEntriesFound,' +
            'Microsoft.PowerShell.Commands.GetHotFixCommand'
        if($_.FullyQualifiedErrorId -ne $NotFound){
            # Termination execution on any error other than the patch not found
            throw $_
        }
    }
    $Found
}