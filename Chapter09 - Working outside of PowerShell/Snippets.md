# Snippet 1 - Load Word ComObject
```powershell
$Word = New-Object -ComObject Word.Application
```

# Snippet 2 - Load Office Interop DKK
```powershell
$GAC = Join-Path $env:WINDIR 'assembly\GAC_MSIL'
Get-ChildItem -Path $GAC -Recurse -Include 'Microsoft.Office.Interop.Word.dll','office.dll' | Foreach-Object{
    Add-Type -Path $_.FullName
}
```

# Snippet 3 - View the methods and properties of the the Word object
```powershell
$Word | Get-Member
```
```
Name                              MemberType            Definition
----                              ----------            ----------
Activate                          Method                void Activate ()
AddAddress                        Method                void AddAddress ()
AutomaticChange                   Method                void AutomaticChange ()
BuildKeyCode                      Method                int BuildKeyCode (WdKey..
CentimetersToPoints               Method                float CentimetersToPoints ()
ChangeFileOpenDirectory           Method                void ChangeFileOpenDirectory
CheckGrammar                      Method                bool CheckGrammar (string..
…
ActiveDocument                    Property              Document ActiveDocument ()
ActiveEncryptionSession           Property              int ActiveEncryptionSession
ActivePrinter                     Property              string ActivePrinter (){get}
ActiveWindow                      Property              Window ActiveWindow () {get}
AddIns                            Property              AddIns AddIns () {get}
…
```

# Snippet 4 - Create a new Word document
```powershell
$Word = New-Object -ComObject Word.Application
$Word.Visible = $True
$Document = $Word.Documents.Add()
$Selection = $Word.Selection
```

# Snippet 5 - Get the methods and properties of the current section
```powershell
$Selection | Get-Member -Name TypeText, TypeParagraph
```
```
   TypeName: System.__ComObject#{00020975-0000-0000-c000-000000000046}

Name          MemberType Definition
----          ---------- ----------
TypeText      Method     void TypeText (string Text)
TypeParagraph Method     void TypeParagraph ()
```

# Snippet 6 - Create the document title
```powershell
$Selection.Style = 'Title'
$Selection.TypeText("$([system.environment]::MachineName) - System Document")
$Selection.TypeParagraph()
```

# Snippet 7 - View the methods avaiable for a Word table
```powershell
$Selection.Tables.psobject.methods
```
```
OverloadDefinitions
-------------------
Table Item (int Index)
Table AddOld (Range Range, int NumRows, int NumColumns)
Table Add (Range Range, int NumRows, int NumColumns, Variant DefaultTableBehavior, Variant AutoFitBehavior)
```

# Snippet 8 - Get the auto-fit enum
```powershell
[Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent
```

# Snippet 9 - Get all the auto-fit options
```powershell
[Microsoft.Office.Interop.Word.WdAutoFitBehavior].GetEnumValues() |
    Select-Object @{l='Name';e={$_}}, @{l='value';e={$_.value__}}
```
```
            Name Value
            ---- -----
  wdAutoFitFixed     0
wdAutoFitContent     1
 wdAutoFitWindow     2
```

# Snippet 10 - Add a new table to Word
```powershell
$Table = $Selection.Tables.add($Word.Selection.Range, 3, 2,
  [Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior,
  [Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent)
```

# Snippet 11 - Populate test in the cells
```powershell
$Table.Cell(1,1).Range.Text = 'First Cell'
$Table.Cell(3,2).Range.Text = 'Last Cell'
```

# Snippet 12 - Get the Windows OS information
```powershell
$OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName, @{l='Total Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
```

# Snippet 13 - Add the OS information to the Word document in a table
```powershell
$OperatingSystem = Get-CimInstance -Class Win32_OperatingSystem |
    Select-Object Caption, InstallDate, ServicePackMajorVersion,
    OSArchitecture, BootDevice, BuildNumber, CSName,
    @{l='Total Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
New-WordTableFromObject $OperatingSystem
```

# Snippet 14 - Add the disk information to the Word document in a table
```powershell
$DiskInfo = Get-CimInstance -Class Win32_LogicalDisk |
    Select-Object DeviceId,
    @{l='Size';e={[Math]::Round($_.Size / 1GB, 2)}},
    @{l='FreeSpace';e={[Math]::Round($_.FreeSpace / 1GB, 2)}}
New-WordTableFromArray $DiskInfo
```

# Snippet 15 - Use a REST API to get your public IP address
```powershell
$IP = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
$IP
```
```
ip
--
48.52.216.180
```

# Snippet 16 - Use a REST API to get location information from the IP address
```powershell
$apiKey = "your_API_key"
$ApiUrl = "https://geo.ipify.org/api/v2/country,city"
$Body = @{
    apiKey    = $apiKey
    ipAddress = $IP.ip
}
$geoData = $null
$geoData = Invoke-RestMethod -Uri $ApiUrl -Body $Body
$geoData.location
```
```
country    : US
region     : Illinois
city       : Chicago
lat        : 41.94756
lng        : -87.65650
postalCode : 60613
timezone   : -05:00
```

# Snippet 17 - Add the REST API information to the Word document
```powershell
$IP = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
$Selection.TypeText("IP Address  : $($IP.ip)")
$Selection.TypeText([char]11)

$apiKey = "your_API_key"
$ApiUrl = "https://geo.ipify.org/api/v2/country,city"
$Body = @{
    apiKey = $apiKey
    ipAddress = $IP.ip
}
$geoData = $null
$geoData = Invoke-RestMethod -Uri $ApiUrl -Body $Body
$Selection.TypeText("IP Location : $($geoData.location.city), $($geoData.location.country)")
$Selection.TypeParagraph()

```

# Snippet 18 - Start process ping and wait for completion
```powershell
Start-Process -FilePath 'ping.exe' -ArgumentList 'google.com'
Start-Process -FilePath 'ping.exe' -ArgumentList 'google.com','-n 10'
```

# Snippet 19 - Start process and monitor for completion
```powershell
$RuntimeSeconds = 2
$ping = Start-Process -FilePath 'ping.exe' -ArgumentList 'google.com','-n 10' -PassThru
$timer =  [system.diagnostics.stopwatch]::StartNew()
while($ping.HasExited -eq $false){
    if($timer.Elapsed.TotalSeconds -gt $RuntimeSeconds){
        $ping | Stop-Process -Force
        throw "The application did not exit in time"
    }
}
$timer.Elapsed.TotalSeconds
$timer.Stop()
```

# Snippet 20 - Record external command output and errors
```powershell
$Process = @{
	FilePath               = 'Driverquery.exe'
	ArgumentList           = '/NH'
	RedirectStandardOutput = 'StdOutput.txt'
	RedirectStandardError  = 'ErrorOutput.txt'
	NoNewWindow            = $true
	Wait                   = $true
}
Start-Process @Process
Get-Content 'ErrorOutput.txt'
Get-Content 'StdOutput.txt'
```
```
1394ohci     1394 OHCI Compliant Ho Kernel
3ware        3ware                  Kernel        5/18/2015 5:28:03 PM
ACPI         Microsoft ACPI Driver  Kernel
AcpiDev      ACPI Devices driver    Kernel
acpiex       Microsoft ACPIEx Drive Kernel
acpipagr     ACPI Processor Aggrega Kernel
AcpiPmi      ACPI Power Meter Drive Kernel
acpitime     ACPI Wake Alarm Driver Kernel
Acx01000     Acx01000               Kernel
ADP80XX      ADP80XX                Kernel        4/9/2015 3:49:48 PM
...
```
# Snippet 21 - Record external command output and errors
```powershell
$Process = @{
	FilePath               = 'Driverquery.exe'
	ArgumentList           = '/FO List /NH'
	RedirectStandardOutput = 'StdOutput.txt'
	RedirectStandardError  = 'ErrorOutput.txt'
	NoNewWindow            = $true
	Wait                   = $true
}
Start-Process @Process
Get-Content 'ErrorOutput.txt'
Get-Content 'StdOutput.txt'
```
```
ERROR: Invalid syntax. /NH option is valid only for "TABLE" and "CSV" format.
Type "DRIVERQUERY /?" for usage.
```
# Snippet 22 - Get Counter data to pass to the Python script
```powershell
$sampleData = Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 10
```

