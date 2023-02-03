Function Test-PythonInstall {
    $Before = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $testpy = py -0p
    if (-not [string]::IsNullOrEmpty($testpy)) {
        $testpy.Split("`n").Trim() | ForEach-Object {
            if ($_.Split() -eq '-3.8-64') {
                $_.Split() | Where-Object { $_ -and $_ -ne '-3.8-64' }
            }
        }
    }
    $ErrorActionPreference = $Before
}



# Install Python
$PyPath = Test-PythonInstall
if (-not($PyPath)) {
    Write-Host 'Installing Python...'
    choco install python3 --version=3.8.0 --side-by-side --params "/InstallDir:$env:USERPROFILE\Python38" -y
    # Reload environment variables to ensure python is now avaiable
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}
else {
    Write-Host "Python 3.8 is already installed"
}



# confirm Python is available
$PyPath = Test-PythonInstall
if (-not($PyPath)) {
    Write-Host "Unable to locate PythonInstall package. If it was just installed try restarting this script." -ForegroundColor Red -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 30
    break
}


Function Install-PythonModule {
    param(
        $PyPath,    
        $Module
    )
    try {
        $Before = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        Invoke-Expression "$PyPath -m pip install $Module"
    }
    catch {
        $_
    }
    $ErrorActionPreference = $Before
}

Install-PythonModule $PyPath '--upgrade pip setuptools wheel'
Install-PythonModule $PyPath 'pandas'
Install-PythonModule $PyPath 'matplotlib'