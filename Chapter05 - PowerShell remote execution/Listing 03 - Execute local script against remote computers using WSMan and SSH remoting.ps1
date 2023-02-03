# Listing 3 - Execute local script against remote computers using WSMan and SSH remoting
# Added variable for the default ssh username to use
$SshUser = 'posh'
# Remaining variables are unchanged
$servers = 'Svr01', 'Svr02', 'Svr03'
$CsvFile = 'P:\Scripts\VSCodeExtensions.csv'
$ScriptFile = 'P:\Scripts\Get-VSCodeExtensions.ps1'
$ConnectionErrors = "P:\Scripts\VSCodeErrors.csv"

if (Test-Path -Path $CsvFile) {
    $csvData = Import-Csv -Path $CsvFile | 
    Select-Object -ExpandProperty PSComputerName -Unique
    $servers = $servers | Where-Object { $_ -notin $csvData }
}

[System.Collections.Generic.List[PSObject]] $Sessions = @()
foreach ($s in $servers) {
    # Set the parameters for the Test-NetConnection calls
    $test = @{
        ComputerName     = $s
        InformationLevel = 'Quiet'
        WarningAction    = 'SilentlyContinue'
    }
    try {
        # Create a hashtable for New-PSSession parameters
        $PSSession = @{
            ErrorAction = 'Stop'
        }
        # If listening on the WSMan port
        if (Test-NetConnection @test -Port 5985) {
            $PSSession.Add('ComputerName', $s)
        }
        # If listening on the SSH port
        elseif (Test-NetConnection @test -Port 22) {
            $PSSession.Add('HostName', $s)
            $PSSession.Add('UserName', $SshUser)
        }
        # If neither, throw to the catch block
        else {
            throw "connection test failed"
        }
        # Create a remote session using the parameters set based on the results of the Test-NetConnection commands.
        $session = New-PSSession @PSSession
        $Sessions.Add($session)
    }
    catch {
        [pscustomobject]@{
            ComputerName = $s
            Date         = Get-Date
            ErrorMsg     = $_
        } | Export-Csv -Path $ConnectionErrors -Append
    }
}

# Remainder of the script is unchanged from listing 5.2
$Command = @{
    Session  = $Sessions
    FilePath = $ScriptFile
}
$Results = Invoke-Command @Command

$Results | Export-Csv -Path $CsvFile -Append

Remove-PSSession -Session $Sessions