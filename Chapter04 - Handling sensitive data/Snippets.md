# Snippet 1 - Create secure string with Read-Host
```powershell
$SecureString = Read-Host -AsSecureString
$SecureString
```
```
System.Security.SecureString
```

# Snippet 2 - Create secure string from plain text string
```powershell
$String = "password01"
$SecureString = ConvertTo-SecureString $String -AsPlainText -Force
$SecureString
```
```
System.Security.SecureString
```

# Snippet 3 - Create credential with Get-Credential
```powershell
$Credential = Get-Credential
```

# Snippet 4 - Create credential by combining two strings
```powershell
$Username = 'Contoso\BGates'
$Password = 'P@ssword'
$SecureString = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential $Username, $SecureString
```

# Snippet 5 - Create network credential
```powershell
$Username = 'Contoso\BGates'
$Password = ConvertTo-SecureString 'Password' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential $Username, $Password
$NetCred = $Credential.GetNetworkCredential()
$NetCred
```
```
UserName    Domain
--------    ------
BGates      Contoso
```

# Snippet 6 - Install SecretManagement and SecretStore modules
```powershell
Install-Module Microsoft.PowerShell.SecretStore
Install-Module Microsoft.PowerShell.SecretManagement
```

# Snippet 7 - Setting up the SecretStore
```powershell
Get-SecretStoreConfiguration
```
```
Creating a new Microsoft.PowerShell.SecretStore vault. A password is required by the current store configuration.
Enter password:
********
Enter password again for verification:
********
      Scope Authentication PasswordTimeout Interaction
      ----- -------------- --------------- -----------
CurrentUser       Password             900      Prompt
```

# Snippet 8 - Setting up the SecretStore to be non-interactive
```powershell
Set-SecretStoreConfiguration -Authentication None -Interaction None
```
```
Confirm
Are you sure you want to perform this action?
Performing the operation "Changes local store configuration" on target "SecretStore module local store".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
A password is no longer required for the local store configuration.
To complete the change please provide the current password.
Enter password:
********
```

# Snippet 9 - Registering the SQLHealthCheck SecretStore
```powershell
Register-SecretVault -ModuleName Microsoft.PowerShell.SecretStore -Name SQLHealthCheck
```

# Snippet 10 - Install KeePass extension
```powershell
Install-Module SecretManagement.KeePass
```

# Snippet 11 - Register the SmtpKeePass KeePass vault
```powershell
$ModuleName = 'SecretManagement.KeePass'
Register-SecretVault -Name 'SmtpKeePass' -ModuleName $ModuleName -VaultParameters @{
    Path = " \\ITShare\Automation\SmtpKeePass.kdbx"
    UseMasterPassword = $false
    KeyPath= "C:\Users\svcacct\SmtpKeePass.keyx"
}
```

# Snippet 12 - Set the SQL secrets in the SQLHealthCheck SecretStore
```powershell
$SQLServer = "$($env:COMPUTERNAME)\SQLEXPRESS"
Set-Secret -Name TestSQL -Secret $SQLServer -Vault SQLHealthCheck
$Credential = Get-Credential
Set-Secret -Name TestSQLCredential -Secret $Credential -Vault SQLHealthCheck
```

# Snippet 13 - Set the SendGrid secrets in the SmtpKeePass KeePass vault
```powershell
$SmtpFrom = Read-Host -AsSecureString
Set-Secret -Name SendGrid -Secret $SmtpFrom -Vault SmtpKeePass
$Credential = Get-Credential
Set-Secret -Name SendGridKey -Secret $Credential -Vault SmtpKeePass
```