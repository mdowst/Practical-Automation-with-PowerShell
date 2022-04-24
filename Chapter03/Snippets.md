# Snippet 1 - Scheduled Task arguments example
```powershell
-File "C:\Scripts\Invoke-LogFileCleanup.ps1" -LogPath "L:\Logs\" -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -NumberOfDays 30
```

# Snippet 2 - Set Scheduled Task arguments
```powershell
$Argument = '-File ' +
    '"C:\Scripts\Invoke-LogFileCleanup.ps1"' +
    ' -LogPath "L:\Logs\" -ZipPath "L:\Archives\"' +
    ' -ZipPrefix "LogArchive-" -NumberOfDays 30'
$Argument
```
```
-File "C:\Scripts\Invoke-LogFileCleanup.ps1" -LogPath "L:\Logs\" -ZipPath "L:\Archives\" -ZipPrefix "LogArchive-" -NumberOfDays 30
```

# Snippet 3 - Export Scheduled Task
```powershell
$ScheduledTask = @{
    TaskName = "LogFileCleanup"
    TaskPath = "\PoSHAutomation\"
}
$export = Export-ScheduledTask @ScheduledTask
$export | Out-File "\\srv01\PoSHAutomation\LogFileCleanup.xml"
```

# Snippet 4 - Run ps1 from Linux terminal
```shell
/snap/powershell/160/opt/powershell/pwsh -File "/home/posh/Invoke-LogFileCleanup.ps1" -LogPath "/etc/poshtest/Logs" -ZipPath "/etc/poshtest/Logs/Archives" -ZipPrefix "LogArchive-" -NumberOfDays 30
```

# Snippet 5 - Open CronTab file as a different user
```shell
crontab -u username -e
```

# Snippet 6 - Schedule script in Cron
```shell
* 8 * * * /snap/powershell/160/opt/powershell/pwsh -File "/home/posh/Invoke-LogFileCleanup.ps1" -LogPath "/etc/poshtest/Logs" -ZipPath "/etc/poshtest/Logs/Archives" -ZipPrefix "LogArchive-" -NumberOfDays 30
```

# Snippet 7 - Subsitute parameters for Jenkins environment variables
```powershell
$LogPath = $env:logpath
$ZipPath = $env:zippath
$ZipPrefix = $env:zipprefix
$NumberOfDays = $env:numberofdays
```

# Snippet 8 - Stopwatch example
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

# Snippet 9 - Test Watch-Folder.ps1 execution times
```powershell
$Argument = '-File ' +
    '"C:\Scripts\Invoke-LogFileCleanup.ps1"' +
    ' -LogPath "L:\Logs\" -ZipPath "L:\Archives\"' +
    ' -ZipPrefix "LogArchive-" -NumberOfDays 30'
$jobParams = @{
    FilePath = "C:\Program Files\PowerShell\7\pwsh.exe"
    ArgumentList = $Argument
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

