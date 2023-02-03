# Listing 4 - PoshAutomate-AssetMgmt
$_PoshAssetMgmt = [pscustomobject]@{
    # Update SqlInstance to match your server name
    SqlInstance  = 'YourSqlSrv\SQLEXPRESS'
    Database     = 'PoshAssetMgmt'
    ServerTable  = 'Servers'
}

$Path = Join-Path $PSScriptRoot 'Public'
# Get all the ps1 files in the Public folder
$Functions = Get-ChildItem -Path $Path -Filter '*.ps1'

# Loop through each ps1 file
Foreach ($import in $Functions) {
    Try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        # Execute each ps1 file to load the function into memory
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}

[System.Collections.Generic.List[PSObject]]$RequiredModules = @()
# Create an object for each module to check
$RequiredModules.Add([pscustomobject]@{
    Name = 'dbatools'
    Version = '1.1.5'
})

# Check whether the module is installed on the local machine
foreach($module in $RequiredModules){
    $Check = Get-Module $module.Name -ListAvailable
    
    if(-not $check){
        throw "Module $($module.Name) not found"
    }
    
    $VersionCheck = $Check |
        Where-Object{ $_.Version -ge $module.Version }
    
    if(-not $VersionCheck){
        Write-Error "Module $($module.Name) running older version"
    }
    
    Import-Module -Name $module.Name
}
