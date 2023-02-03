# Listing 9 - Set-SecurityBaseline
Function Set-SecurityBaseline{
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [RegistryCheck]$Check
    )
    # Create the registry key path if it does not exist
    if(-not (Test-Path -Path $Check.KeyPath)){
        New-Item -Path $Check.KeyPath -Force -ErrorAction Stop
    }
        
    # Create or Update the registry key with the predetermined value
    $ItemProperty = @{
        Path         = $Check.KeyPath
        Name         = $Check.Name
        Value        = $Check.Data
        PropertyType = $Check.Type
        Force        = $true
        ErrorAction  = 'Continue'
    }
    New-ItemProperty @ItemProperty
}
