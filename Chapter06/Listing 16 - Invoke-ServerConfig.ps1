# Listing 16 - Invoke-ServerConfig
Function Invoke-ServerConfig{
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [string[]]$Config = $null
    )
    [System.Collections.Generic.List[PSObject]]$selection = @()
    # Get all the Configurations folder
    $Path = @{
        Path      = $PSScriptRoot
        ChildPath = 'Configurations'
    }
    $ConfigPath = Join-Path @Path

    # Get all the Json files in the Configurations folder
    $ChildItem = @{
        Path   = $ConfigPath
        Filter = '*.JSON'
    }
    $Configurations = Get-ChildItem @ChildItem
    
    # If a config name is passed, attempt to find the file
    if(-not [string]::IsNullOrEmpty($Config)){
        foreach($c in $Config){
            $Configurations | Where-Object{ $_.BaseName -eq $Config } | 
                ForEach-Object { $selection.Add($_) }
        }
    }

    # If config name is not passed or name is not found, prompt for a file to use
    if($selection.Count -eq 0){
        $Configurations | Select-Object BaseName, FullName | 
            Out-GridView -PassThru | ForEach-Object { $selection.Add($_) }
    }
    
    # Set the default log file path
    $Log = "$($env:COMPUTERNAME)-Config.log"
    $LogFile = Join-Path -Path $($env:SystemDrive) -ChildPath $Log

    # Run the Set-ServerConfig for each json file
    foreach($json in $selection){
        Set-ServerConfig -ConfigJson $json.FullName -LogFile $LogFile
    }
}
