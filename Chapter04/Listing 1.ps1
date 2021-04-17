# Listing 1 - SecretManagement Examples

# Retrieve a credential secret from the vault
$Cred = Get-Secret -Name SrvAdmin -Vault PoshAutomate
# Use the credential to start a remote PowerShell session
$PSSession = @{
    ComputerName = 'Srv1'
    Credential   = $Cred
}
$Session = New-PSSession @PSSession

# Retrieve a secure string
$Secret = @{
    Name  = 'Token'
    Vault = 'PoshAutomate'
}
$Token = Get-Secret @Secret
# Use the secure string to authenticate to a RESTful web service
Invoke-RestMethod -Uri $Url -Token $Token

# Retrieve an unsecure string
$Secret = @{
    Name  = 'ApiKey'
    Vault = 'PoshAutomate'
}
$Key = Get-Secret @Secret -AsPlainText
# Add API Key to a URL
$Url = 'https://mywebservice.com/data.json?Key=' + $Key
# Use the key to connect to a RESTful web service
Invoke-RestMethod -Uri $Url 