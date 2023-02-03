# Listing 11 - Set-FirewallDefaults
Function Set-FirewallDefaults {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [UInt64]$LogSize
    )
    # Create a custom object to record and output the results of the commands.
    $FirewallSettings = [pscustomobject]@{
        Enabled       = $false
        PublicBlocked = $false
        LogFileSet    = $false
        Errors        = $null
    }

    try {
        # Enable all firewall profiles
        $NetFirewallProfile = @{
            Profile     = 'Domain', 'Public', 'Private'
            Enabled     = 'True'
            ErrorAction = 'Stop'
        }
        Set-NetFirewallProfile @NetFirewallProfile
        $FirewallSettings.Enabled = $true
        
        # Block all inbound public traffic
        $NetFirewallProfile = @{
            Name                 = 'Public'
            DefaultInboundAction = 'Block'
            ErrorAction          = 'Stop'
        }
        Set-NetFirewallProfile @NetFirewallProfile
        $FirewallSettings.PublicBlocked = $true

        $log = '%windir%\system32\logfiles\firewall\pfirewall.log'
        # Set the firewall log settings, including the size.
        $NetFirewallProfile = @{
            Name                 = 'Domain', 'Public', 'Private'
            LogFileName          = $log
            LogBlocked           = 'True'
            LogMaxSizeKilobytes  = $LogSize
            ErrorAction          = 'Stop'
        }
        Set-NetFirewallProfile @NetFirewallProfile
        $FirewallSettings.LogFileSet = $true
    }
    catch {
        $FirewallSettings.Errors = $_
    }

    $FirewallSettings
}
