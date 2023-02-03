# Listing 10 - Install-RequiredFeatures
Function Install-RequiredFeatures {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Features
    )
    [System.Collections.Generic.List[PSObject]] $FeatureInstalls = @()
    # Loops through each feature and install it
    foreach ($Name in $Features) {
        Install-WindowsFeature -Name $Name -ErrorAction SilentlyContinue | 
            Select-Object -Property @{l='Name';e={$Name}}, * | 
            ForEach-Object{ $FeatureInstalls.Add($_) }
    }

    $FeatureInstalls
}
