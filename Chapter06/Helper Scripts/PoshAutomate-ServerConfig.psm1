# Registry Test Class
class RegistryTest {
    [string]$operator
	[string]$Value
    # Method to create a blank instance of this class
    RegistryTest(){
    }
    # Method to create an instance of this class populated with data from a generic PowerShell object
    RegistryTest(
        [object]$object
    ){
        $this.operator = $object.operator
		$this.Value = $object.Value
    }
}


# Registry Check Class
class RegistryCheck {
    [string]$KeyPath
	[string]$Name
	[string]$Type
    [string]$Data
    [string]$SetValue
    [Boolean]$Success
    [RegistryTest[]]$Tests
    # Method to create a blank instance of this class
    RegistryCheck(){
        $this.Tests += [RegistryTest]::new()
        $this.Success = $false
    }
    # Method to create an instance of this class populated with data from a generic PowerShell object
    RegistryCheck(
        [object]$object
    ){
        $this.KeyPath = $object.KeyPath
		$this.Name = $object.Name
		$this.Type = $object.Type
        $this.Data = $object.Data
        $this.Success = $false
        $this.SetValue = $object.SetValue

        $object.Tests | Foreach-Object {
            $this.Tests += [RegistryTest]::new($_)
        }
    }
}

# Server Config Class
class ServerConfig {
    [string[]]$Features
    [string[]]$Services
    [RegistryCheck[]]$SecurityBaseline
	[UInt64]$FirewallLogSize
    # Method to create a blank instance of this class
    ServerConfig(){
        $this.SecurityBaseline += [RegistryCheck]::new()
    }
    # Method to create an instance of this class populated with data from a generic PowerShell object
    ServerConfig(
        [object]$object
    ){
        $this.Features = $object.Features
        $this.Services = $object.Services
        $this.FirewallLogSize = $object.FirewallLogSize
        $object.SecurityBaseline | Foreach-Object {
            $this.SecurityBaseline += [RegistryCheck]::new($_)
        }
    }
}


# New-ServerConfig
Function New-ServerConfig{
    [ServerConfig]::new()
}


# Invoke-ServerConfig
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

# Get all the ps1 files in the Public folder
$Path = Join-Path $PSScriptRoot 'Public'
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