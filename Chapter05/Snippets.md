# Snippet 1 - 
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

# Snippet 2 - 
```powershell
Enable-PSRemoting -Force
```

# Snippet 3 - 
```powershell
try{
    $session = New-PSSession -ComputerName $s -ErrorAction Stop
    $Sessions.Add($session)
}
catch{
    Write-Host "$($s) failed to connect: $($_)"
}
```

# Snippet 4 - 
```powershell
Get-WindowsCapability -Online | Where-Object{ $_.Name -like 'OpenSSH*' -and $_.State -ne 'Installed' } | ForEach-Object{ Add-WindowsCapability -Online -Name $_.Name }
```

# Snippet 5 - 
```powershell
Get-Service -Name sshd,ssh-agent |
    Set-Service -StartupType Automatic
Start-Service sshd,ssh-agent
```

# Snippet 6 - 
```
PasswordAuthentication yes
PubkeyAuthentication yes
```

# Snippet 7 - 
```powershell
# Windows
Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -NoLogo
# Linux with Snap
Subsystem powershell /snap/powershell/160/opt/powershell/pwsh -sshs -NoLogo
# Other Linux
Subsystem powershell /usr/bin/pwsh -sshs -NoLogo
```

# Snippet 8 - 
```
ssh-keygen
ssh-add "$($env:USERPROFILE)\.ssh\id_rsa"
```

# Snippet 9 - 
```
type "$($env:USERPROFILE)\.ssh\id_rsa.pub" | ssh username@hostname "mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys && chmod -R go= ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

# Snippet 10 - 
```powershell
Invoke-Command -HostName 'remotemachine' -UserName 'user' -ScriptBlock{$psversiontable}
```

# Snippet 11 - 
```
PasswordAuthentication no
StrictHostKeyChecking yes
```

# Snippet 12 - 
```powershell
"PasswordAuthentication no\r\nStrictHostKeyChecking yes" | Out-File "$($env:USERPROFILE)/.ssh/config"
```

