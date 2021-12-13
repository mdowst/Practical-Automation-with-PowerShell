# Listing 8 - Test-SecurityBaseline
Function Test-SecurityBaseline {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [RegistryCheck]$Check
    )
    # Set the initial value of $Data to null
    $Data = $null
    if (-not (Test-Path -Path $Check.KeyPath)) {
        # If the path is not found, there is nothing to do because $Data is already set to null.
        Write-Verbose "Path not found"
    }
    else {
        # Get the keys that exist in the key path and confirm that the key you want is present.
        $SubKeys = Get-Item -LiteralPath $Check.KeyPath
        if ($SubKeys.Property -notcontains $Check.Name) {
            # If the key is not found, there is nothing to do because $Data is already set to null.
            Write-Verbose "Name not found"
        }
        else {
            try {
                # If the key is found, get the value and update the $Data variable with the value.
                $ItemProperty = @{
                    Path = $Check.KeyPath
                    Name = $Check.Name
                }
                $Data = Get-ItemProperty @ItemProperty | 
                    Select-Object -ExpandProperty $Check.Name
            }
            catch {
                $Data = $null
            }
        }
    }
    
    # Run through each test for this registry key.
    foreach ($test in $Check.Tests) {
        # Build the string to create the If statement to test the value of the $Data variable.
        $filter = 'if($Data -{0} {1}){{$true}}'
        $filter = $filter -f $test.operator, $test.Value
        Write-Verbose $filter
        if (Invoke-Expression $filter) {
            # If the statement returns true, you know a test passed, so update the Success property.
            $Check.Success = $true
        }
    }
    
    # Add the value of the key for your records and debugging
    $Check.SetValue = $Data
    $Check
}
