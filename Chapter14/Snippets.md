# Snippet 1 - Create new branch for updating the module
```powershell
git checkout -b add_linux
```

# Snippet 2 - The orginal Get-SystemInfo function from chapter 1
```powershell
Function Get-SystemInfo{
    Get-CimInstance -Class Win32_OperatingSystem |
        Select-Object Caption, InstallDate, ServicePackMajorVersion,
        OSArchitecture, BootDevice, BuildNumber, CSName,
        @{l='Total_Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
}
Get-SystemInfo
```
```
Caption                 : Microsoft Windows 11 Enterprise
InstallDate             : 10/21/2021 5:09:00 PM
ServicePackMajorVersion : 0
OSArchitecture          : 64-bit
BootDevice              : \Device\HarddiskVolume3
BuildNumber             : 22000
CSName                  : MyPC
Total_Memory            : 32
```

# Snippet 3 - Export the results of the Get-CimInstance cmdlet
```powershell
Get-CimInstance | Export-Clixml -Path .\Test\Get-CimInstance.Windows.xml
```

# Snippet 4 - Quickly generate text you can use to build test scripts
```powershell
$Info = Get-SystemInfo
$Info.psobject.Properties | ForEach-Object{
    "`$Info.$($_.Name) | Should -Be '$($_.Value)'"
}
```

# Snippet 5 - Run the unit tests
```powershell
.\Get-SystemInfo.Unit.Tests.ps1
```
```
Starting discovery in 1 files.
Discovery found 2 tests in 19ms.
Running tests.
[+] D:\PoshAutomator\Test\Get-SystemInfo.Unit.Tests.ps1 178ms (140ms|22ms)
Tests completed in 181ms
Tests Passed: 2, Failed: 0, Skipped: 0 NotRun: 0
```

# Snippet 6 - Using Get-Variable to test for different operating systems
```powershell
If(Get-Variable -Name IsLinux -ValueOnly){
    <# Linux commands #>
}
ElseIf(Get-Variable -Name IsMacOS -ValueOnly){
    Write-Warning 'Support for macOS has not been added yet.'
}
Else{
    <# Windows commands #>
}
```

# Snippet 7 - Get the contents of the os-release file
```powershell
Get-Content -Path /etc/os-release
```
```
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

# Snippet 8 - Convert the content of the os-release file to a PowerShell object
```powershell
$OS = Get-Content -Path /etc/os-release | ConvertFrom-StringData
$OS.PRETTY_NAME
$OS.PRETTY_NAME.Replace('"',"")
```
```
"Ubuntu 20.04.4 LTS"
Ubuntu 20.04.4 LTS
```

# Snippet 9 - Search the meminfo file for the MemTotal line
```powershell
Select-String -Path /proc/meminfo -Pattern 'MemTotal'
```
```
/proc/meminfo:1:MemTotal:        4019920 kB
```

# Snippet 10 - Extract the number of the MemTotal line
```powershell
Select-String -Path /proc/meminfo -Pattern 'MemTotal' |
    ForEach-Object{ [regex]::Match($_.line, "(\d+)").value}
```
```
4019920
```

# Snippet 11 - Get the birth date from the stat file
```powershell
$stat = Invoke-Expression -Command 'stat /'
$stat | Select-String -Pattern 'Birth:' | ForEach-Object{
    Get-Date $_.Line.Replace('Birth:','').Trim()
}
```
```
Wednesday, 26 January 2022 15:47:51
```

# Snippet 12 - Get the boot drive from the df command output
```powershell
$boot = Invoke-Expression -Command 'df /boot'
$boot.Split("`n")[-1].Split()[0]
```
```
/dev/sda1
```

# Snippet 13 - Export the data from the stat command for mocking
```powershell
stat / | Out-File .\test.stat.txt
```

# Snippet 14 - mocking the df command
```powershell
Mock Invoke-Expression -ParameterFilter { $Command -eq 'df /boot' } -MockWith {
    Get-Content -Path (Join-Path $PSScriptRoot 'test.df.txt')
}
```

# Snippet 15 - Testing that the df command was mocked
```powershell
Should -Invoke -CommandName 'Invoke-Expression' -ParameterFilter {
    $Command -eq 'df /boot' } -Times 1
```

# Snippet 16 - Creating a GitHub workflow to run on new pull requests
```powershell
name: PoshAutomator Pester Tests
on:
  pull_request:
    types: [opened, reopened]
```

# Snippet 17 - Commite changes and push to GitHub
```powershell
git add .
git commit -m "added Linux support and Pester workflow"
git push origin add_linux
```

# Snippet 18 - Create a new pull request
```powershell
gh pr create --title "Add Linux Support" --body " Updated Get-SystemInfo function to work on most major Linux distros. Add workflows for testing"
```

# Snippet 19 - Original parameters
```powershell
param(
    [string]$Name
)
```

# Snippet 20 - Parameters with Alias added
```powershell
param(
    [Alias('Name')]
    [string]$HostName
)
```

# Snippet 21 - Parameters with an Alias and Warning added
```powershell
param(
    [Alias('Name')]
    [ValidateScript({
        Write-Warning "The parameter Name is being replaced with HostName. Be sure to update any scripts using Name";
        $true}
    )]
    [string]$HostName
)
```

# Snippet 22 - Creating and exporting a function alias in a module
```powershell
New-Alias -Name Old-Function -Value New-Function
Export-ModuleMember -Alias * -Function *
```

