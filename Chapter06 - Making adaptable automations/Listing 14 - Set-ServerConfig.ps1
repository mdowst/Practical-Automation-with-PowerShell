# Listing 14 - Set-ServerConfig
Function Set-ServerConfig {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [object]$ConfigJson,
        [Parameter(Mandatory = $true)]
        [object]$LogFile
    )
    # Import the configuration data from the JSON file
    $JsonObject = Get-Content $ConfigJson -Raw | 
        ConvertFrom-Json
    # Convert the JSON data to the class you defined
    $Config = [ServerConfig]::new($JsonObject)

    # A small function to ensure consistent logs are written for an activity starting
    Function Write-StartLog {
        param(
            $Message
        )
        "`n$('#' * 50)`n# $($Message)`n" | Out-File $LogFile -Append
        Write-Host $Message
    }

    # A small function to ensure consistent logs are written for an activity completing
    Function Write-OutputLog {
        param(
            $Object
        )
        $output = $Object | Format-Table | Out-String
        if ([string]::IsNullOrEmpty($output)) {
            $output = 'No data'
        }
        "$($output.Trim())`n$('#' * 50)" | Out-File $LogFile -Append
        Write-Host $output
    }
    $msg = "Start Server Setup - $(Get-Date)`nFrom JSON $($ConfigJson)"
    Write-StartLog -Message $msg

    # Set Windows Features first
    Write-StartLog -Message "Set Features"
    $Features = Install-RequiredFeatures -Features $Config.Features
    Write-OutputLog -Object $Features

    # Set the services
    Write-StartLog -Message "Set Services"
    $WindowsService = @{
        Services        = $Config.Services
        HardKillSeconds = 60
        SecondsToWait   = 90
    }
    $Services = Disable-WindowsService @WindowsService
    Write-OutputLog -Object $Services
    
    Write-StartLog -Message "Set Security Baseline"
    # Check each registry key in the Security baseline
    foreach ($sbl in $Config.SecurityBaseline) {
        $sbl = Test-SecurityBaseline $sbl
    }

    # Fix any that did not pass the test
    foreach ($sbl in $Config.SecurityBaseline | 
        Where-Object { $_.Success -ne $true }) {
        Set-SecurityBaseline $sbl
        $sbl = Test-SecurityBaseline $sbl
    }
    $SecLog = $SecBaseline | 
        Select-Object -Property KeyPath, Name, Data, Result, SetValue
    Write-OutputLog -Object $SecLog

    # Set the firewall
    Write-StartLog -Message "Set Firewall"
    $Firewall = Set-FirewallDefaults -LogSize $Config.FirewallLogSize
    Write-OutputLog -Object $Firewall

    Write-Host "Server configuration is complete."
    Write-Host "All logs written to $($LogFile)"
}
