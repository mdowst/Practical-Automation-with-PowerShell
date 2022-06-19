# Listing 4 - System Information Documentation
$PyPath = "$($env:UserProfile)\Python38\python.exe"
$TimeseriesScript = ".\Helper Scripts\timeseries.py"
Function New-WordTableFromObject {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]    
        [object]$object
    )
    
    $Properties = @($object.psobject.Properties)
    
    $Table = $Selection.Tables.add(
    $Word.Selection.Range, 
    $Properties.Count, 
    2, 
[Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior
    ,[Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent
    )

    for ($r = 0; $r -lt $Properties.Count; $r++) {
        $Table.Cell($r + 1, 1).Range.Text = 
        $Properties[$r].Name.ToString()
        $Table.Cell($r + 1, 2).Range.Text = 
        $Properties[$r].Value.ToString()
    }

    $Word.Selection.Start = $Document.Content.End
    $Selection.TypeParagraph()
}

Function New-WordTableFromArray{
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]    
        [object]$object
    )
    $columns = $object | Select-Object -First 1 | 
    Select-Object -Property @{l='Name';e={$_.psobject.Properties.Name}} | 
    Select-Object -ExpandProperty Name

    $Table = $Selection.Tables.add(
    $Word.Selection.Range, 
    $Object.Count + 1, 
    $columns.Count, 
[Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior
    ,[Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent
    )

    $Table.Style = 'Grid Table 1 Light'
    
    for($c = 0; $c -lt $columns.Count; $c++){
        $Table.Cell(1,$c+1).Range.Text = $columns[$c]
    }

    for($r = 0; $r -lt $object.Count; $r++){
        for($c = 0; $c -lt $columns.Count; $c++){
            $Table.Cell($r+2,$c+1).Range.Text = 
                $object[$r].psobject.Properties.Value[$c].ToString()
        }
    }

    $Word.Selection.Start= $Document.Content.End
    $Selection.TypeParagraph()
}

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
    $CounterJson = $CounterData | 
        Select-Object Timestamp, 
        @{l = 'Value'; e = { $_.CounterSamples.CookedValue } } | 
        ConvertTo-Json -Compress
    
    $Guid = New-Guid

    $path = @{
        Path = $env:TEMP
    }
    $picture = Join-Path @Path -ChildPath "$($Guid).PNG"
    $StandardOutput = Join-Path @Path -ChildPath "$($Guid)-Output.txt"
    $StandardError = Join-Path @Path -ChildPath "$($Guid)-Error.txt"

    $ArgumentList = @(
        """$($ScriptPath)"""
        """$($picture)"""
        """$($Title)"""
        $CounterJson.Replace('"', '\"')
    )

    $Process = @{
        FilePath               = $PyPath
        ArgumentList           = $ArgumentList
        RedirectStandardOutput = $StandardOutput
        RedirectStandardError  = $StandardError
        NoNewWindow            = $true
        PassThru               = $true
    }
    $graph = Start-Process @Process

    $RuntimeSeconds = 30
    $timer = [system.diagnostics.stopwatch]::StartNew()
    while ($graph.HasExited -eq $false) {
        if ($timer.Elapsed.TotalSeconds -gt $RuntimeSeconds) {
            $graph | Stop-Process -Force
            throw "The application did not exit in time"
        }
    }
    $timer.Stop()

    $OutputContent = Get-Content -Path $StandardOutput
    $ErrorContent = Get-Content -Path $StandardError
    if ($ErrorContent) {
        Write-Error $ErrorContent
    }
    elseif ($OutputContent | Where-Object { $_ -match 'File saved to :' }) {
        $output = $OutputContent | 
            Where-Object { $_ -match 'File saved to :' }
        $Return = $output.Substring($output.IndexOf(':') + 1).Trim()
    }
    else {
        Write-Error "Unknown error occurred"
    }

    Remove-Item -LiteralPath $StandardOutput -Force
    Remove-Item -LiteralPath $StandardError -Force

    $Return
}

Function Add-WordHeader{
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]    
        [string]$Text,
        [Parameter(Mandatory = $false)]    
        [int]$Style = 1
    )
    $Selection.Style = "Heading $Style"
    $Selection.TypeText($Text)
    $Selection.TypeParagraph()
}

# Import the Word Com Object to PowerShell
$Word = New-Object -ComObject Word.Application
$Word.Visible = $True
$Document = $Word.Documents.Add()
$Selection = $Word.Selection

# Load the Office Interop assemblies into the current session
$GAC = Join-Path $env:WINDIR 'assembly\GAC_MSIL'
$OfficeDlls = 'Microsoft.Office.Interop.Word.dll','office.dll'
Get-ChildItem -Path $GAC -Recurse -Include $OfficeDlls | Foreach-Object{
    Add-Type -Path $_.FullName
}

# Add some text to start with
$Selection.Style = 'Title'
$Name = [system.environment]::MachineName
$Selection.TypeText("$($Name) - System Document")
$Selection.TypeParagraph()

# Add the Table of Contents
$range = $Selection.Range
$toc = $Document.TablesOfContents.Add($range)
$Selection.TypeParagraph()

# Add the first section header
Add-WordHeader -Text "System Information"
# Gather the OS information 
$class = @{
    Class = 'Win32_OperatingSystem'
}
$OperatingSystem = Get-CimInstance @class | 
    Select-Object Caption, InstallDate, ServicePackMajorVersion, 
    OSArchitecture, BootDevice, BuildNumber, CSName, 
    @{l='Total Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}

# Write the OS information to a table in Word
New-WordTableFromObject $OperatingSystem

# Add a sub-header for the disk space
Add-WordHeader -Text "Disk Space" -Style 2

# Get disk information
$DiskInfo = Get-CimInstance -Class Win32_LogicalDisk | 
    Select-Object DeviceId, 
    @{l='Size';e={[Math]::Round($_.Size / 1GB, 2)}}, 
    @{l='FreeSpace';e={[Math]::Round($_.FreeSpace / 1GB, 2)}}
# Write the disk space information to a table in Word
New-WordTableFromArray $DiskInfo

# Add Networking section
Add-WordHeader -Text "Network Data"

# Get the IP address information
$IPAddress = Get-NetIPAddress -AddressFamily IPv4 | 
    Select-Object InterfaceAlias, IPAddress, AddressFamily, InterfaceIndex
# Write the IP address information to Word
New-WordTableFromArray -object $IPAddress

# Add a sub-header for the external IP
Add-WordHeader -Text "External IP Address" -Style 2

# Get the external IP address data from the Web API and write it into the Word document
$Selection.Style = 'Normal'
$ip = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
$Selection.TypeText("IP Address  : $($ip.ip)")
# Use [char]11 to create a line break without creating a new paragraph
$Selection.TypeText([char]11)
$Uri = "https://sys.airtel.lv/ip2country/$($ip.ip)/?full=true"
$ipData = Invoke-RestMethod -Uri $Uri
$Selection.TypeText("IP Location : $($ipData.city), $($ipData.country)")
$Selection.TypeParagraph()

# Create the Counters section
Add-WordHeader -Text "Counters"

# Get the % Processor Time data to create the graph
$Counter = @{
	Counter        = "\Processor(_Total)\% Processor Time"
	SampleInterval = 2
	MaxSamples     = 10
}
$sampleData = Get-Counter @Counter

# Execute the Python script to create the graph PNG
$graph = @{
    PyPath = $PyPath
    ScriptPath = $TimeseriesScript
    Title = '% Processor Time'
    CounterData = $sampleData
}
$picture = New-TimeseriesGraph @graph

# Add the picture to the Word document
$Document.InlineShapes.AddPicture($picture) | Out-Null

# Delete the PNG file
if(Test-Path $picture){
    Remove-Item -LiteralPath $picture -Force
}

# Move the selection to the end of the document
$Word.Selection.Start= $Document.Content.End
$Selection.TypeParagraph()
# Update the TOC now that everything has been written to the document 
$toc.Update()

# Save the document and close word
$Report = "$($Name).docx"
$Document.SaveAs([ref]$Report)
$word.Quit()