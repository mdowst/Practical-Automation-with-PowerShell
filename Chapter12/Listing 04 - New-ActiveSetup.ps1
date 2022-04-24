# Listing 4 - New-ActiveSetup
Function New-ActiveSetup {
    param(
        [string]$Name,
        [System.Management.Automation.ScriptBlock]$ScriptBlock,
        [version]$Version = '1.0.0.0'
    )

    # The path to the Active Setup registry keys
    $ActiveSetupReg = 
    'HKLM:\Software\Microsoft\Active Setup\Installed Components'

    # Create the Active Setup registry key
    $Item = @{
        Path  = $ActiveSetupReg
        Name  = $Name
        Force = $true
    }
    $ActiveSetup = New-Item @Item | Select-Object -ExpandProperty PSPath

    # Set the path for the script
    $DefaultPath = 'ActiveSetup\{0}_v{1}.ps1'
    $ChildPath = $DefaultPath -f $Name, $Version
    $ScriptPath = Join-Path -Path $env:ProgramData -ChildPath $ChildPath
    $ScriptFolder = Split-Path -Path $ScriptPath

    # Create the ActiveSetup folder if it does not exist
    if (-not(Test-Path -Path $ScriptFolder)) {
        New-Item -type Directory -Path $ScriptFolder | Out-Null
    }

    # Declare the Wrapper script code
    $WrapperScript = {
        param($Name,$Version)
        $Path = "ActiveSetup\$($Name)_$($Version).log"
        $log = Join-Path $env:APPDATA $Path
        $Transcript = @{ Path = $log; Append = $true;
        IncludeInvocationHeader = $true; Force = $true}
        Start-Transcript @Transcript
        try{
            {0}
        }
        catch{ Write-Host $_ }
        finally{ Stop-Transcript }
    }

    # Convert wrapper code to string and fix curly brackets to all for string formating
    $WrapperString = $WrapperScript.ToString()
    $WrapperString = $WrapperString.Replace('{','{{')
    $WrapperString = $WrapperString.Replace('}','}}')
    $WrapperString = $WrapperString.Replace('{{0}}','{0}')
    
    # Add the script block to the wrapper code and export it to the script file
    $WrapperString -f $ScriptBlock.ToString() | 
        Out-File -FilePath $ScriptPath -Encoding utf8

    # Set the registry values for the Active Setup
    $args = @{
        Path  = $ActiveSetup
        Force = $true
    }
    $ActiveSetupValue = 'powershell.exe -ExecutionPolicy bypass ' +
    "-File ""$($ScriptPath.Replace('\', '\\'))""" +
    " -Name ""$($Name)"" -Version ""$($Version)"""
    Set-ItemProperty @args -Name '(Default)' -Value $Name
    Set-ItemProperty @args -Name 'Version' -Value $Version
    Set-ItemProperty @args -Name 'StubPath' -Value $ActiveSetupValue
}