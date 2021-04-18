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

# Snippet 8 - Setting up the SecretStore
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

# Snippet 9 - Registering the SecretStore
```powershell
Register-SecretVault -ModuleName Microsoft.PowerShell.SecretStore -Name PoshAutomate
```

# Snippet 10 - Create secrets to store examples
```powershell
$Secret = Read-Host -AsSecureString
Set-Secret -Name 'APIKey' -Secret $Secret -Vault PoshAutomate
$Credential = Get-Credential
Set-Secret -Name AzureCreds -Secret $Credential -Vault PoshAutomate
```

# Snippet 11 - Install KeePass extension
```powershell
Install-Module SecretManagement.KeePass
```

# Snippet 12 - Register the KeePass vault
```powershell
Register-SecretVault -Name 'MyKeepass' -ModuleName SecretManagement.Keepass -VaultParameters @{
```
```
    Path = "D:\Automation\PoshAutomate.kdbx"
    UseMasterPassword = $false
    KeyPath= "C:\Users\svcacct\\PoshAutomate.keyx"
}
```

# Snippet 13 - Retrieve secrets
```powershell
Get-Secret -Name 'Sample1' -Vault 'MyKeepass'
```

# Snippet 14 - Retrieve secrets as plain text
```powershell
Get-Secret -Name 'Sample1' -Vault PoshAutomate -AsPlainText
```

# Snippet 15 - Create certificate
```powershell
$$certParams = @{
    CertStoreLocation = "cert:\CurrentUser\My"
    Subject           = "CN=PoshAutomate"
    KeySpec           = 'KeyExchange'
}
$cert = New-SelfSignedCertificate $certParams
```

# Snippet 16 - Install AzureAD module
```powershell
Install-Module AzureAd -Scope CurrentUser
```

# Snippet 17 - Install Az module
```powershell
Install-Module Az
```