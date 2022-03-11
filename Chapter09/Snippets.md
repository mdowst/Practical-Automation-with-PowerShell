# Snippet 1 - 
```powershell
$Word = New-Object -ComObject Word.Application
```

# Snippet 2 - 
```powershell
$GAC = Join-Path $env:WINDIR 'assembly\GAC_MSIL'
Get-ChildItem -Path $GAC -Recurse -Include 'Microsoft.Office.Interop.Word.dll','office.dll' | Foreach-Object{
    Add-Type -Path $_.FullName
}
```

# Snippet 3 - 
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

# Snippet 4 - 
```powershell
$Word = New-Object -ComObject Word.Application
$Word.Visible = $True
$Document = $Word.Documents.Add()
$Selection = $Word.Selection
```

# Snippet 5 - 
```powershell
PS D:\> $Selection | Get-Member -Name TypeText, TypeParagraph
```
```

   TypeName: System.__ComObject#{00020975-0000-0000-c000-000000000046}

Name          MemberType Definition
----          ---------- ----------
TypeText      Method     void TypeText (string Text)
TypeParagraph Method     void TypeParagraph ()
```

# Snippet 6 - 
```powershell
$Selection.Style = 'Title'
$Selection.TypeText("$([system.environment]::MachineName) - System Document")
$Selection.TypeParagraph()
```

# Snippet 7 - 
```powershell
PS D:\> $Selection.Tables.psobject.methods
```
```
OverloadDefinitions
-------------------
Table Item (int Index)
Table AddOld (Range Range, int NumRows, int NumColumns)
Table Add (Range Range, int NumRows, int NumColumns, Variant DefaultTableBehavior, Variant AutoFitBehavior)
```

# Snippet 8 - 
```powershell
[Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent
```

# Snippet 9 - 
```powershell
[[Microsoft.Office.Interop.Word.WdAutoFitBehavior].GetEnumValues() |
 Select-Object @{l='Name';e={$_}}, @{l='value';e={$_.value__}}
```
```
            Name Value
            ---- -----
  wdAutoFitFixed     0
wdAutoFitContent     1
 wdAutoFitWindow     2
```

# Snippet 10 - 
```powershell
$Table = $Selection.Tables.add($Word.Selection.Range, 3, 2,
  [Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior,
  [Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitContent)
```

# Snippet 11 - 
```powershell
$Table.Cell(1,1).Range.Text = 'First Cell'
$Table.Cell(3,2).Range.Text = 'Last Cell'
```

# Snippet 12 - 
```powershell
$OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object Caption, InstallDate, ServicePackMajorVersion, OSArchitecture, BootDevice,  BuildNumber, CSName, @{l='Total Memory';e={[math]::Round($OS.TotalVisibleMemorySize/1MB)}}
```

# Snippet 13 - 
```powershell
$OS = Get-CimInstance -Class Win32_OperatingSystem |
    Select-Object Caption, InstallDate, ServicePackMajorVersion,
    OSArchitecture, BootDevice, BuildNumber, CSName,
    @{l='Total Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
New-WordTableFromObject $OS
```

# Snippet 14 - 
```powershell
$DiskInfo = Get-CimInstance -Class Win32_LogicalDisk |
    Select-Object DeviceId,
    @{l='Size';e={[Math]::Round($_.Size / 1GB, 2)}},
    @{l='FreeSpace';e={[Math]::Round($_.FreeSpace / 1GB, 2)}}
New-WordTableFromArray $DiskInfo
```

# Snippet 15 - 
```powershell
$IP = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
 $IP
```
```
ip
--
48.52.216.180
```

# Snippet 16 - 
```powershell
Invoke-RestMethod "https://sys.airtel.lv/ip2country/$($ip.ip)/?full=true"
```
```
country : US
city    : Denton
asn     : AS20115
lat     : 33.15
lon     : -97.06
```

# Snippet 17 - 
```powershell
$ip = Invoke-RestMethod -Uri 'https://api.ipify.org?format=json'
$Selection.TypeText("IP Address  : $($ip.ip)")
$Selection.TypeText([char]11)
$ipData = Invoke-RestMethod "https://sys.airtel.lv/ip2country/$($ip.ip)/?full=true"
$Selection.TypeText("IP Location : $($ipData.city), $($ipData.country)")
$Selection.TypeParagraph()
```

# Snippet 18 - 
```powershell
Start-Process -FilePath 'ping.exe' -ArgumentList 'google.com'
Start-Process -FilePath 'ping.exe' -ArgumentList 'google.com','-n 10'
```

# Snippet 19 - 
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

# Snippet 20 - 
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

# Snippet 21 - 
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

# Snippet 22 - 
```powershell
$sampleData = Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 2 -MaxSamples 10
```

