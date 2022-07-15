# Snippet 1 - Autounattend.xml example
```xml
<UserAccounts>
  <AdministratorPassword>
    <Value>UABAAHMAcwB3ADAAcgBkAEEAZABtAGkAbgAA==</Value>
    <PlainText>false</PlainText>
  </AdministratorPassword>
</UserAccounts>
```

# Snippet 2 - Setting a new password in the Autounattend PowerShell object
```powershell
$object = $Autounattend.unattend.settings |
    Where-Object { $_.pass -eq "oobeSystem" }
$object.component.UserAccounts.AdministratorPassword.Value = $NewPassword
```

# Snippet 3 - Encoding the password for the Autounattend.xml
```powershell
$NewPassword = 'P@ssw0rd'
$pass = $NewPassword + 'AdministratorPassword'
$bytes = [System.Text.Encoding]::Unicode.GetBytes($pass)
$base64Password = [system.convert]::ToBase64String($bytes)
```

# Snippet 4 - The updated Autounattend.xml with the encoded password
```powershell
<UserAccounts>
  <AdministratorPassword>
    <Value>UABAAHMAcwB3ADAAcgBkAEEAZABtAGkAbgAA==</Value>
    <PlainText>false</PlainText>
  </AdministratorPassword>
</UserAccounts>
```

# Snippet 5 - The current installed applications in Windows
```powershell
HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
```

# Snippet 6 - Search the registry for a certain value
```powershell
$SearchFor = '*Windows Assessment and Deployment Kit*'
$Path =  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
Get-ChildItem -Path $Path | ForEach-Object{
    if($_.GetValue('DisplayName') -like $SearchFor){
        $_
    }
}
```

# Snippet 7 - Get the value of a registry entry
```powershell
$Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots'
$DevTools = Get-ItemProperty -Path $Path
$DevTools.KitsRoot10
```

# Snippet 8 - Multiple-line comment example
```powershell
#region Section the requires explaining
<#
This is where I would put a multiple-line
comment. It is also best to use the less than hash
and hash greater than when creating multiple-line
comments, as it allows you to collapse the entire
comment section.
#>

... your code

#endregion
```

# Snippet 9 - VS Code auto-generated help section
```powershell
Function New-VmFromIso {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER VMName
    Parameter description

    .PARAMETER VMHostName
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,
        [Parameter(Mandatory = $true)]
        [string]$VMHostName
    )

}
```

# Snippet 10 - Help section example with details about how to set the parameter values
```powershell
.EXAMPLE
$ISO = 'D:\ISO\Windows11.iso'
$VM = Get-VM -Name 'Vm01'
Set-VmSettings -VM $VM -ISO $ISO
```

# Snippet 11 - Line breaks after pipelines
```powershell
Get-Service -Name Spooler | Stop-Service

Get-Service -Name Spooler |
    Stop-Service
```