# Listing 9 - Import Required Modules
[System.Collections.Generic.List[PSObject]]$RequiredModules = @()
# Create an object for each module to check
$RequiredModules.Add([pscustomobject]@{
    Name = 'Pester'
    Version = '4.1.2'
})

# Loop through each module to check
foreach($module in $RequiredModules){
    # Check if the module is installed on the local machine
    $Check = Get-Module $module.Name -ListAvailable

    # If not found, throw a terminating error to stop this module from loading
    if(-not $check){
        throw "Module $($module.Name) not found"
    }

    # If it is found, check the version
    $VersionCheck = $Check |
        Where-Object{ $_.Version -ge $module.Version }

    # If an older version is found, write an error but do not stop
    if(-not $VersionCheck){
        Write-Error "Module $($module.Name) running older version"
    }

    # Import the module into the current session
    Import-Module -Name $module.Name
}
