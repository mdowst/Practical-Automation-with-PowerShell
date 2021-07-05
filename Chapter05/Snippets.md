# Snippet 1 - IsLinux and IsMacOS variables
```powershell
if ($IsLinux) {
    # set Linux specific variables
}
elseif ($IsMacOS) {
    # set macOS specific variables
}
else {
    # set Windows specific variables
}
```

# Snippet 2 - Enable PowerShell Remoting
```powershell
Enable-PSRemoting -Force
```

# Snippet 3 - Creating presistent connections with try/catch
```powershell
try{
    $session = New-PSSession -ComputerName $s -ErrorAction Stop
    $Sessions.Add($session)
}
catch{
    Write-Host "$($s) failed to connect: $($_)"
}
```

# Snippet 4 - Install OpenSSH on Windows 10 and Windows Server 2019
```powershell
Get-WindowsCapability -Online | Where-Object{ $_.Name -like 'OpenSSH*' -and $_.State -ne 'Installed' } | ForEach-Object{ Add-WindowsCapability -Online -Name $_.Name }
```

# Snippet 5 - Set SSH services
```powershell
Get-Service -Name sshd,ssh-agent |
    Set-Service -StartupType Automatic
Start-Service sshd,ssh-agent
```

# Snippet 6 - Enabling Password and Key-based Authentication in sshd_config
```
PasswordAuthentication yes
PubkeyAuthentication yes
```

# Snippet 7 - Add PowerShell subsystem to the sshd_config file
```powershell
# Windows
Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo
# Linux with Snap
Subsystem powershell /snap/powershell/160/opt/powershell/pwsh -sshs -NoLogo
# Other Linux
Subsystem powershell /usr/bin/pwsh -sshs -NoLogo
```

# Snippet 8 - Generate SSH key pair and add to ssh-agent
```
ssh-keygen
ssh-add "$($env:USERPROFILE)\.ssh\id_rsa"
```

# Snippet 9 - Copy the SSH public key to the remote Linux servers
```
type "$($env:USERPROFILE)\.ssh\id_rsa.pub" | ssh username@hostname "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

# Snippet 10 - Test SSH connection
```powershell
Invoke-Command -HostName 'remotemachine' -UserName 'user' -ScriptBlock{$psversiontable}
```

# Snippet 11 - Disable Password Authentication in the user config file manually
```
PasswordAuthentication no
StrictHostKeyChecking yes
```

# Snippet 12 - Disable Password Authentication in the user config file with PowerShell
```powershell
"PasswordAuthentication no\r\nStrictHostKeyChecking yes" | Out-File "$($env:USERPROFILE)/.ssh/config"
```

