Function Invoke-PackageCmd {
    param(
        $PackageMgr,
        $Argurements
    )
    try {
        $Before = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        $testResult = Invoke-Expression -Command "$PackageMgr $Argurements"
    }
    catch {
        $testResult = $null
    }
    finally {
        $ErrorActionPreference = $Before
    }
    $testResult
}

Function Find-PackageManager {
    param(
        $TestCommand
    )
    $packageMgr = $null

    if (Invoke-PackageCmd 'winget' '-v') {
        $packageMgr = 'winget'
    }

    if (-not $packageMgr -and (Invoke-PackageCmd 'choco' '-v')) {
        $packageMgr = 'choco'
    }

    if (-not $packageMgr -and (Invoke-PackageCmd'apt-get' '--version')) {
        $packageMgr = 'apt-get'
    }

    if (-not $packageMgr -and (Invoke-PackageCmd'yum' '--version')) {
        $packageMgr = 'yum'
    }

    if (-not $packageMgr -and (Invoke-PackageCmd'homebrew' '--version')) {
        $packageMgr = 'brew'
    }

    $packageMgr
}

Function Set-EnvPath {
    $env:Path =
    [System.Environment]::GetEnvironmentVariable("Path", "Machine") +
    ";" +
    [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Host "Find package manager..."
$packageMgr = Find-PackageManager

if ([string]::IsNullOrEmpty($packageMgr) -and $IsWindows) {
    Write-Host 'Installing Chocolatey...'
    [System.Net.ServicePointManager]::SecurityProtocol =
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $Install = Invoke-RestMethod https://chocolatey.org/install.ps1
    Invoke-Expression "& { $($Install) }"
    Set-EnvPath
    $packageMgr = Find-PackageManager
    if (-not($choco)) {
        throw "Unable to locate choco package. Try restarting this script."
    }
}

if ([string]::IsNullOrEmpty($packageMgr)){
    throw "A package manager could not be found"
}
else{
    Write-Host "Using package manager '$packageMgr'"
}

$testGit = Invoke-PackageCmd 'git' '--version'
if ([string]::IsNullOrEmpty($testGit)) {
    Write-Host "Installing Git..."
    switch ($packageMgr) {
        'winget' { $params = 'install --id Git.Git' +
                    ' -e --source winget --accept-package-agreements' +
                    ' --accept-source-agreements' }
        'choco' { $params = 'install git.install --params "/GitAndUnixToolsOnPath /NoGitLfs /SChannel /NoAutoCrlf" -y'}
        'apt-get' { $params = 'install git -y'}
        'yum' { $params = 'install git -y'}
        'brew' { $params = 'install git -y'}
    }
    Invoke-PackageCmd -PackageMgr $packageMgr -Argurements $params

    Set-EnvPath
    $testGit = Invoke-PackageCmd 'git' '--version'
    Write-Host "Git version $($testGit) has been installed"
}
else {
    Write-Host "Git version $($testGit) is already installed"
}

$testGH = Invoke-PackageCmd 'gh' '--version'
if ([string]::IsNullOrEmpty($testGH)) {
    Write-Host "Installing GitHub CLI..."
    switch ($packageMgr) {
        'winget' { $params = 'install --id GitHub.cli' +
                    ' -e --source winget --accept-package-agreements' +
                    ' --accept-source-agreements' }
        'choco' { $params = 'install gh -y'}
        'apt-get' { $params = 'install gh -y'}
        'yum' { $params = 'install gh -y'}
        'brew' { $params = 'install gh -y'}
    }
    Invoke-PackageCmd -PackageMgr $packageMgr -Argurements $params

    Set-EnvPath
    $testGH = Invoke-PackageCmd 'gh' '--version'
    Write-Host "GitHub CLI version $($testGH.Split("`n")[0]) has been installed"
}
else {
    Write-Host "GitHub CLI version $($testGH.Split("`n")[0]) is already installed"
}