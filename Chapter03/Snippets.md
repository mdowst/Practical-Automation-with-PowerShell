# Snippet 1 - Disk Space Monitor Get Disks
```powershell
Get-PSDrive
```
```
Name           Used (GB)     Free (GB) Provider      Root
----           ---------     --------- --------      ----
Alias                                  Alias
C                  17.97         31.42 FileSystem    C:\
Cert                                   Certificate   \
Env                                    Environment
Function                               Function
HKCU                                   Registry      HKEY_CURRENT_USER
HKLM                                   Registry      HKEY_LOCAL_MACHINE
L                   0.97          9.01 FileSystem    L:\
P                   0.04          9.94 FileSystem    P:\
Temp               17.97         31.42 FileSystem    C:\Users\user\Temp\
Variable                               Variable
WSMan                                  WSMan
```
# Snippet 2 - Filter down to only file systems
```powershell
Get-PSDrive -PSProvider FileSystem
```
```
Name           Used (GB)     Free (GB) Provider      Root
----           ---------     --------- --------      ----
C                  17.97         31.42 FileSystem    C:\
L                   0.97          9.01 FileSystem    L:\
P                   0.04          9.94 FileSystem    P:\
Temp               17.97         31.42 FileSystem    C:\Users\user\Temp\
```

# Snippet 3 - Remove Temp Folder
```powershell
Get-PSDrive -PSProvider FileSystem |
    Where-Object{$_.Name -ne 'Temp'} 
```
```
Name           Used (GB)     Free (GB) Provider      Root
----           ---------     --------- --------      ----
C                  17.97         31.42 FileSystem    C:\
L                   0.97          9.01 FileSystem    L:\
P                   0.04          9.94 FileSystem    P:\
```

# Snippet 4 - Convert to JSON to see true output
```powershell
Get-PSDrive -PSProvider FileSystem | 
    Where-Object{$_.Name -ne 'Temp'} | 
    ConvertTo-Json -Depth 1
```
```
[
  {
    "CurrentLocation": "",
    "Name": "C",
    "Provider": "Microsoft.PowerShell.Core\\FileSystem",
    "Root": "C:\\",
    "Description": "",
    "MaximumSize": null,
    "Credential": "System.Management.Automation.PSCredential",
    "DisplayRoot": null,
    "VolumeSeparatedByColon": true,
    "Used": 19300188160,
    "Free": 33740976128
  },
...
```

# Snippet 5 - User Select-Object to get only the information you want
```powershell
Get-PSDrive -PSProvider FileSystem | 
    Where-Object{$_.Name -ne 'Temp'} |
    Select-Object -Property Name, Used, Free
```
```
Name        Used        Free
----        ----        ----
C    17454845952 35586318336
L     3410739200  7307800576
P       42938368 10675601408
```

# Snippet 6 - Convert values to GB
```powershell
Get-PSDrive -PSProvider FileSystem | 
    Where-Object{$_.Name -ne 'Temp'} |
    Select-Object -Property Name, 
    @{Label='UsedGB';Expression={$_.Used / 1GB}}, 
    @{Label='FreeGB';Expression={$_.Free / 1GB}}
```
```
Name             UsedGB           FreeGB
----             ------           ------
C       16.256103515625 33.1423301696777
L      3.17649841308594  6.8059196472168
P    0.0399894714355469 9.94242858886719
```

# Snippet 7 - Round Values
```powershell
Get-PSDrive -PSProvider FileSystem | 
    Where-Object{$_.Name -ne 'Temp'} |
    Select-Object -Property Name,
    @{Label='UsedGB';Expression={[math]::Round($_.Used / 1GB, 2)}},
    @{Label='FreeGB';Expression={[math]::Round($_.Free / 1GB, 2)}}
```
```
Name UsedGB FreeGB
---- ------ ------
C     17.98  31.42
L      0.97   9.01
P      0.04   9.94
```

# Snippet 8 - Add additional information
```powershell
Get-PSDrive -PSProvider FileSystem | 
    Where-Object{$_.Name -ne 'Temp'} |
    Select-Object -Property Name,
    @{Label='UsedGB';Expression={[math]::Round($_.Used / 1GB, 2)}},
    @{Label='FreeGB';Expression={[math]::Round($_.Free / 1GB, 2)}},
    @{Label='Date';Expression={Get-Date}},
    @{Label = 'Computer'; Expression = 
            { [system.environment]::MachineName } }
```
```
Name UsedGB FreeGB Date                 Computer
---- ------ ------ ----                 --------
C     16.26  33.14 2/28/2021 8:07:43 AM SERVER01
L      3.18   6.81 2/28/2021 8:07:43 AM SERVER01
P      0.04   9.94 2/28/2021 8:07:43 AM SERVER01
```

# Snippet 9 - Create Parameters
```powershell
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)
```

# Snippet 10 - Add folder check
```powershell
$CsvFolder = Split-Path -Path $CsvPath
if (-not (Test-Path -Path $CsvFolder)) {
    New-Item -Path $CsvFolder -ItemType Directory | Out-Null
    Write-Verbose "Created folder '$CsvFolder'"
}
```

# Snippet 11 - Create Scheduled Task trigger
```powershell
$Trigger = New-ScheduledTaskTrigger -Daily -At 8am
```

# Snippet 12 - Set Scheduled Task execution path
```powershell
$Execute = "C:\Program Files\PowerShell\7\pwsh.exe"
```

# Snippet 13 - Set Scheduled Task arguments
```powershell
$Argument = '-File ' +
    '"C:\Scripts\Export-DiskSpaceInfo.ps1"' +
    ' -CsvPath "C:\Logs\DiskSpaceMonitor.csv"'
```

# Snippet 14 - Set Scheduled Task Action
```powershell
$ScheduledTaskAction = @{
    Execute = $Execute 
    Argument = $Argument
}
$Action = New-ScheduledTaskAction @ScheduledTaskAction
```

# Snippet 15 - Create new Scheduled Task
```powershell
$ScheduledTask = @{
    TaskName = "PoSHAutomation\DiskSpaceMonitor"
    Trigger  = $Trigger
    Action   = $Action
    User     = 'NT AUTHORITY\SYSTEM'
}
Register-ScheduledTask @ScheduledTask
```

# Snippet 16- Export Scheduled Task
```powershell
$ScheduledTask = @{
    TaskName = "DiskSpaceMonitor"
    TaskPath = "\PoSHAutomation\"
}
$export = Export-ScheduledTask @ScheduledTask
$export | Out-File "\\srv01\PoSHAutomation\DiskSpaceMonitor.xml"
```

# Snippet 17- Import Scheduled Task
```powershell
$xml = Get-Content "\\srv01\PoSHAutomation\DiskSpaceMonitor.xml" -Raw
Register-ScheduledTask -Xml $xml -TaskName "PoSHAutomation\DiskSpaceMonitor"
```

# Snippet 18 - Run ps1 from Linux terminal
```shell
/snap/powershell/160/opt/powershell/pwsh -File "/home/posh/Export-DiskSpaceInfo.ps1" -CsvPath "/home/posh/DiskSpaceInfo.csv"
```

# Snippet 19 - Open CronTab file
```shell
crontab -e
```

# Snippet 20 - Open CronTab file as a different user
```shell
crontab -u username -e
```

# Snippet 21 - Schedule Disk Space script in Cron
```shell
* 8 * * * snap/powershell/160/opt/powershell/pwsh -File "/home/posh/Export-DiskSpaceInfo.ps1" -CsvPath "/home/posh/DiskSpaceInfo.csv"
```

# Snippet 22 - Jenkins environment variable
```powershell
$CsvPath = $env:cvspath
```

# Snippet 23 - Measure Watcher Execution Time
```powershell
$jobParams = @{
    FilePath = 'pwsh'
    ArgumentList = 'C:\Scripts\Watch-Folder.ps1'
    NoNewWindow = $true
}
Measure-Command -Expression {
    $job = Start-Process @jobParams -Wait}
```
```
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 2
Milliseconds      : 17
Ticks             : 20173926
TotalDays         : 2.33494513888889E-05
TotalHours        : 0.000560386833333333
TotalMinutes      : 0.03362321
TotalSeconds      : 2.0173926
TotalMilliseconds : 2017.3926
```

# Snippet 24 - Stopwatch
```powershell
$Timer =  [system.diagnostics.stopwatch]::StartNew()
Start-Sleep -Seconds 3
$Timer.Elapsed
$Timer.Stop()
```
```
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 2
Milliseconds      : 636
Ticks             : 26362390
TotalDays         : 3.0512025462963E-05
TotalHours        : 0.000732288611111111
TotalMinutes      : 0.0439373166666667
TotalSeconds      : 2.636239
TotalMilliseconds : 2636.239
```