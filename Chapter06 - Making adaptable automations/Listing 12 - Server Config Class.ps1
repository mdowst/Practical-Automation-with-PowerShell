# Listing 12 - Server Config Class
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
