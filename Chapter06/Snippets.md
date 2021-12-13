# Snippet 1 - Disable and Stop service one-liner
```powershell
Get-Service -Name Spooler |
    Set-Service -StartupType Disabled -PassThru |
    Stop-Service -PassThru
```

# Snippet 2 - Get service with try/catch to capture errors
```powershell
try{
   Get-Service -Name xyz -ErrorAction Stop
}
catch{
   $_
}
```

# Snippet 3 - Get service with try/catch to capture errors and test for certain conditions based on the error message
```powershell
$Name = 'xyz'
try{
    $Service = Get-Service -Name $Name -ErrorAction Stop
}
catch{
    if($_.FullyQualifiedErrorId -ne 'NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.GetServiceCommand'){
        Write-Error $_
    }
}
```

# Snippet 4 - Registry Check Hash table
```powershell
@{
    KeyPath = 'HKLM:\SYSTEM\Path\Example'
    Name    = 'SecurityKey'
    Tests   = @(
        @{operator = 'eq'; value = '1' }
        @{operator = 'eq'; value = $null }
    )
}
```

# Snippet 5 - Test for true example
```powershell
if($Data -eq 1){
    $true
}
```

# Snippet 6 - Test for true example converted to a string with replacable value and operator
```powershell
'if($Data -{0} {1}){{$true}}' -f 'eq', 1
```

# Snippet 7 - Creating and executing the test for true string
```powershell
$Data = 3
$Operator = 'in'
$Expected = '1..15'
$cmd = 'if($Data -{0} {1}){{$true}}' -f $Operator, $Expected
Invoke-Expression $cmd
```

# Snippet 8 - Import PoshAutomate-ServerConfig Module and create blank config object
```powershell
Import-Module .\PoshAutomate-ServerConfig.psd1 -Force
New-ServerConfig | ConvertTo-Json -Depth 4
```
```
{
    "Features": null,
    "Service": null,
    "SecurityBaseline": [
        {
            "KeyPath": null,
            "Name": null,
            "Type": null,
            "Data": null,
            "SetValue": null,
            "Tests": [
                {
                    "operator": null,
                    "Value": null
                }
            ]
        }
    ],
    "FirewallLogSize": 0
}
```

# Snippet 9 - Import and execute the PoshAutomate-ServerConfig module to set up a new server
```powershell
Import-Module .\PoshAutomate-ServerConfig.psd1 -Force
Invoke-ServerConfig
```

# Snippet 10 - Properly using Add Years to create date
```powershell
$AddYears = 1
$Data = Get-Date 1/21/2035
$DateFromConfig = (Get-Date).AddYears($AddYears)
$cmd = 'if($Data -{0} {1}){{$true}}' -f 'gt', '$DateFromConfig'
Invoke-Expression $cmd
```

# Snippet 11 - Do not include commands in your configurations
```powershell
$Data = Get-Date 1/21/2035
$cmd = 'if($Data -{0} {1}){{$true}}' -f 'gt', '(Get-Date).AddYears(1)'
Invoke-Expression $cmd
```

