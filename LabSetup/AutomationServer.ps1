#Requires -RunAsAdministrator

Function Test-RegUninstallKey($DisplayName){
    $Install = $null
    Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object{
        if($_.GetValue('DisplayName') -like $DisplayName){
            $Install = [pscustomobject]@{
                Version = $_.GetValue('DisplayVersion')
                InstallLocation = $_.GetValue('InstallLocation')
            }
        }
    }
    if(-not ($Install)){
        Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object{
            if($_.GetValue('DisplayName') -like $DisplayName){
                $Install = [pscustomobject]@{
                    Version = $_.GetValue('DisplayVersion')
                    InstallLocation = $_.GetValue('InstallLocation')
                }
            }
        }
    }
    $Install
}

Function Test-ChocoInstall{
    try{
        $Before = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        $testchoco = choco -v
    }
    catch{
        $testchoco = $null
    }
    $ErrorActionPreference = $Before
    $testchoco
}

$percent = 0
$increment = 8
$percent += $increment


# Install PowerShell 7
if($PSVersionTable.PSVersion.Major -lt 7){
    $testPoSh7 = Get-CimInstance -Class Win32_Product -Filter "Name='PowerShell 7-x64'"
    if(-not ($testPoSh7)){
        Write-Progress -Activity 'Installing' -Status 'Installing PowerShell 7...' -PercentComplete $percent;$percent += $increment
        Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet -AddExplorerContextMenu"
    }
    else{
        Write-Progress -Activity 'Installing' -Status "PowerShell 7 is already installed" -PercentComplete $percent;$percent += $increment
    }
}
else{
    Write-Progress -Activity 'Installing' -Status "PowerShell 7 is already running" -PercentComplete $percent;$percent += $increment
}

# Install Chocolatey
$testchoco = Test-ChocoInstall
if(-not($testChoco)){
    Write-Progress -Activity 'Installing' -Status 'Installing Chocolatey...' -PercentComplete $percent;$percent += $increment
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression "& { $(Invoke-RestMethod https://chocolatey.org/install.ps1) }"
}
else{
    Write-Progress -Activity 'Installing' -Status "Chocolatey Version $testchoco is already installed" -PercentComplete $percent;$percent += $increment
}

# Reload environment variables to ensure choco is avaiable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# confirm choco is available
$testChoco = Test-ChocoInstall
if(-not($testChoco)){
    Write-Host "Unable to locate choco package. If it was just installed try restarting this script." -ForegroundColor Red
    Start-Sleep -Seconds 30
    break
}

# Install Jenkins for Windows
$testJenkins = Test-RegUninstallKey -DisplayName 'Jenkins*'
if(-not ($testJenkins)){
    Write-Progress -Activity 'Installing' -Status "Installing Jenkins for Windows..." -PercentComplete $percent;$percent += $increment
    choco install jenkins -y
    $testJenkins = Test-RegUninstallKey -Url 'Jenkins*'
}
else{
    Write-Progress -Activity 'Installing' -Status "Jenkins for Windows Version $($testJenkins.Version) is already installed" -PercentComplete $percent;$percent += $increment
}

# Install Visual Studio Code
$testVSCode = Test-RegUninstallKey -DisplayName 'Microsoft Visual Studio Code'
if(-not ($testVSCode)){
    Write-Progress -Activity 'Installing' -Status "Installing Visual Studio Code..." -PercentComplete $percent;$percent += $increment
    choco install vscode -y
    $testVSCode = Test-RegUninstallKey -DisplayName 'Microsoft Visual Studio Code'
}
else{
    Write-Progress -Activity 'Installing' -Status "Visual Studio Code Version $($testVSCode.Version) is already installed" -PercentComplete $percent;$percent += $increment
}

# Reload environment variables to get VS Code and Git
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Get currently installed extensions
Write-Progress -Activity 'Configuring' -Status 'Installing VS Code Extensions..' -PercentComplete $percent;$percent += $increment
$InstalledExtensions = Invoke-Expression -Command "code --list-extensions"
# Install the missing extensions
$extensions = 'GitHub.vscode-pull-request-github','ms-vscode.powershell','Tyriar.shell-launcher'
$extensions | Where-Object{ $_ -notin $InstalledExtensions } | ForEach-Object {
    Invoke-Expression -Command "code --install-extension $_ --force"
}