# Listing 15 - Create Server Config JSON
# Import the module
Import-Module .\PoshAutomate-ServerConfig.psd1 -Force

# Create a blank configuration item
$Config = New-ServerConfig 

# Import security baseline registry keys
$Content = @{
    Path = '.\RegistryChecksAndResolves.json'
    Raw  = $true
}
$Data = (Get-Content @Content | ConvertFrom-Json)
$Config.SecurityBaseline = $Data

# Set the default firewall log size
$Config.FirewallLogSize = 4096

# Set roles and features to install
$Config.Features = @(
    "RSAT-AD-PowerShell"
    "RSAT-AD-AdminCenter"
    "RSAT-ADDS-Toolsf"
)

# Set services to disable
$Config.Services = @(
    "PrintNotify",
    "Spooler",
    "lltdsvc",
    "SharedAccess",
    "wisvc"
)

# Create the Configurations folder
if(-not (Test-Path ".\Configurations")){
    New-Item -Path ".\Configurations" -ItemType Directory
}

# Export the security baseline
$Config | ConvertTo-Json -Depth 4 | 
    Out-File ".\Configurations\SecurityBaseline.json" -Encoding UTF8