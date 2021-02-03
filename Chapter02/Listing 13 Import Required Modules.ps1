# Listing 13 Import Required Modules
[System.Collections.Generic.List[PSObject]]$RequiredModules = @()
$RequiredModules.Add([pscustomobject]@{    #A
    Name = 'Pester'
    Version = '4.1.2'
})

foreach($module in $RequiredModules){    #B
    $Check = Get-Module $module.Name -ListAvailable    #C
    
    if(-not $check){    #D
        throw "Module $($module.Name) not found"
    }
    
    $VersionCheck = $Check |     #E
        Where-Object{ $_.Version -ge $module.Version }
    
    if(-not $VersionCheck){    #F
        Write-Error "Module $($module.Name) running older version"
    }
    
    Import-Module -Name $module.Name    #G
}
#A Create object for each module to check
#B Loop through each module to check
#C Check if the module is installed on the local machine
#D If not found throw a terminating error to stop this module from loading
#E If if is found, check the version
#F If an older version is found write an error, but do not stop
#G Import the module into the current session