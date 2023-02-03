# Listing 3 - New-TimeseriesGraph
Function New-TimeseriesGraph {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]    
        [string]$PyPath,
        [Parameter(Mandatory = $true)]    
        [string]$ScriptPath,
        [Parameter(Mandatory = $true)]    
        [string]$Title,
        [Parameter(Mandatory = $true)]    
    [Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSampleSet[]]
        $CounterData
    )

    # Convert the counter data into a JSON string
    $CounterJson = $CounterData | 
        Select-Object Timestamp, 
        @{l = 'Value'; e = { $_.CounterSamples.CookedValue } } | 
        ConvertTo-Json -Compress
    
    # Generate a random GUID to use with the file names
    $Guid = New-Guid

    # Set the name and path of the picture and output file
    $path = @{
        Path = $env:TEMP
    }
    $picture = Join-Path @Path -ChildPath "$($Guid).PNG"
    $StandardOutput = Join-Path @Path -ChildPath "$($Guid)-Output.txt"
    $StandardError = Join-Path @Path -ChildPath "$($Guid)-Error.txt"

    # Set the arguments for the timeseries.py script. Wrap the parameters in double quotes to account for potential spaces.
    $ArgumentList = @(
        """$($ScriptPath)"""
        """$($picture)"""
        """$($Title)"""
        $CounterJson.Replace('"', '\"')
    )
    # Set the arguments for the Start-Process command
    $Process = @{
        FilePath               = $PyPath
        ArgumentList           = $ArgumentList
        RedirectStandardOutput = $StandardOutput
        RedirectStandardError  = $StandardError
        NoNewWindow            = $true
        PassThru               = $true
    }
    $graph = Start-Process @Process

    # Start the timer and wait for the process to exit
    $RuntimeSeconds = 30
    $timer = [system.diagnostics.stopwatch]::StartNew()
    while ($graph.HasExited -eq $false) {
        if ($timer.Elapsed.TotalSeconds -gt $RuntimeSeconds) {
            $graph | Stop-Process -Force
            throw "The application did not exit in time"
        }
    }
    $timer.Stop()

    # Get the content from the output and error files
    $OutputContent = Get-Content -Path $StandardOutput
    $ErrorContent = Get-Content -Path $StandardError
    if ($ErrorContent) {
        # If there is anything in the error file, write it as an error in the PowerShell console.
        Write-Error $ErrorContent
    }
    elseif ($OutputContent | Where-Object { $_ -match 'File saved to :' }) {
        # If the output has the expected data, parse it to return what you need in PowerShell
        $output = $OutputContent | 
            Where-Object { $_ -match 'File saved to :' }
        $Return = $output.Substring($output.IndexOf(':') + 1).Trim()
    }
    else {
        # If there was no error and no output, then something else went wrong, so you will want to notify the person running the script.
        Write-Error "Unknown error occurred"
    }

    # Delete the output files
    Remove-Item -LiteralPath $StandardOutput -Force
    Remove-Item -LiteralPath $StandardError -Force

    $Return
}