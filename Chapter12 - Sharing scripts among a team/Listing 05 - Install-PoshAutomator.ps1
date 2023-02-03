# Listing 5 - Install-PoshAutomator.ps1
# The URL to your GitHub repository
$RepoUrl = 
    'https://github.com/<yourprofile>/PoshAutomator.git'
Function Test-CmdInstall {
    param(
        $TestCommand
    )
    try {
        $Before = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        $testResult = Invoke-Expression -Command $TestCommand
    }
    catch {
        $testResult = $null
    }
    finally {
        $ErrorActionPreference = $Before
    }
    $testResult
}

Function Set-EnvPath{
    # Reload the Path environment variables
    $env:Path = 
        [System.Environment]::GetEnvironmentVariable("Path", "Machine") + 
        ";" + 
        [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Check for Git.exe and install if not found
$GitVersion = Test-CmdInstall 'git --version'
if (-not ($GitVersion)) {
    if($IsWindows){
        Write-Host "Installing Git for Windows..."
        $wingetParams = 'winget install --id Git.Git' +
            ' -e --source winget --accept-package-agreements' +
            ' --accept-source-agreements'
        Invoke-Expression  $wingetParams
    }
    elseif ($IsLinux) {
        Write-Host "Installing Git for Linux..."
        apt-get install git -y
    }
    elseif ($IsMacOS) {
        Write-Host "Installing Git for macOS..."
        brew install git -y
    }
    # Reload environment variables to ensure Git is available
    Set-EnvPath
    $GitVersion = Test-CmdInstall 'git --version'
    if (-not ($GitVersion)) {
        throw "Unable to locate Git.exe install. 
            Please install manually and rerun this script."
    }
    else{
        Write-Host "Git Version $($GitVersion) has been installed"
    }
}
else {
    Write-Host "Git Version $($GitVersion) is already installed"
}

# Set the location to the user's profile
if($IsWindows){
    Set-Location $env:USERPROFILE
}
else {
    Set-Location $env:HOME
}

# Clone the repository locally
Invoke-Expression -Command "git clone $RepoUrl"

$ModuleFolder = Get-Item './PoshAutomator'
# Get the first folder listed in the PSModulePath
$UserPowerShellModules = 
    [Environment]::GetEnvironmentVariable("PSModulePath").Split(';')[0]
# Create the Symbolic Link
$SimLinkProperties = @{ 
    ItemType = 'SymbolicLink' 
    Path     = (Join-Path $UserPowerShellModules $ModuleFolder.BaseName) 
    Target   = $ModuleFolder.FullName 
    Force    = $true 
} 
New-Item @SimLinkProperties