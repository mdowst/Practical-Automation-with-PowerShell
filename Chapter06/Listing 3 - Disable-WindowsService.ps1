# Listing 3 - Disable-WindowsService
Function Disable-WindowsService {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Services,
        [Parameter(Mandatory = $true)]
        [int]$HardKillSeconds,
        [Parameter(Mandatory = $true)]
        [int]$SecondsToWait
    )

    [System.Collections.Generic.List[PSObject]] $ServiceStatus = @()
    foreach ($Name in $Services) {
        # Create a custom PowerShell object to track the status of each service
        $ServiceStatus.Add([pscustomobject]@{
                Service  = $Name
                HardKill = $false
                Status   = $null
                Startup  = $null
            })
        try {
            # Attempt to find the service, then disable and stop it
            $Get = @{
                Name        = $Name
                ErrorAction = 'Stop'
            }
            $Service = Get-Service @Get
            $Set = @{
                InputObject = $Service
                StartupType = 'Disabled'
            }
            Set-Service @Set
            $Stop = @{
                InputObject = $Service
                Force       = $true
                NoWait      = $true
                ErrorAction = 'SilentlyContinue'
            }
            Stop-Service @Stop
            Get-Service -Name $Name | ForEach-Object {
                $ServiceStatus[-1].Status = $_.Status.ToString()
                $ServiceStatus[-1].Startup = $_.StartType.ToString()
            }
        }
        catch {
            $msg = 'NoServiceFoundForGivenName,Microsoft.PowerShell' +
                '.Commands.GetServiceCommand'
            if ($_.FullyQualifiedErrorId -eq $msg) {
                # If the service doesn't exist, then there is nothing to stop, so consider that a success
                $ServiceStatus[-1].Status = 'Stopped'
            }
            else {
                Write-Error $_
            }
        }
    }

    $timer = [system.diagnostics.stopwatch]::StartNew()
    # Monitor the stopping of each service
    do {
        $ServiceStatus | Where-Object { $_.Status -ne 'Stopped' } | 
        ForEach-Object { 
            $_.Status = (Get-Service $_.Service).Status.ToString()
            
            # If any services have not stopped in the predetermined amount of time, kill the process.
            if ($_.HardKill -eq $false -and 
                $timer.Elapsed.TotalSeconds -gt $HardKillSeconds) {
                Write-Verbose "Attempting hard kill on $($_.Service)"
                $query = "SELECT * from Win32_Service WHERE name = '{0}'"
                $query = $query -f $_.Service
                $svcProcess = Get-CimInstance -Query $query
                $Process = @{
                    Id          = $svcProcess.ProcessId
                    Force       = $true
                    ErrorAction = 'SilentlyContinue'
                }
                Stop-Process @Process
                $_.HardKill = $true
            }
        }
        $Running = $ServiceStatus | Where-Object { $_.Status -ne 'Stopped' }
    } while ( $Running -and $timer.Elapsed.TotalSeconds -lt $SecondsToWait )
    # set reboot required if any services did not stop
    $ServiceStatus | 
        Where-Object { $_.Status -ne 'Stopped' } | 
        ForEach-Object { $_.Status = 'Reboot Required' }
    
    # return results
    $ServiceStatus
}