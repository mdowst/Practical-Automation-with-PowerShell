# Listing 3 - Jenkins Credential Test
# Create a PowerShell Credential object
$secure = @{
    String = $ENV:srvpassword 
    AsPlainText = $true
    Force = $true
}
$Password = ConvertTo-SecureString @secure
$Credential = New-Object System.Management.Automation.PSCredential `
    ($ENV:srvusername, $Password)

Write-Output "Running as $($env:Username)"

# Use the credential to start a new PowerShell session
$PSSession = @{
    ComputerName = 'localhost'
    Credential   = $Credential
}
$Session = New-PSSession @PSSession

# Use the session to run the command on a remote server
Invoke-Command -Session $Session -ScriptBlock{
    Write-Output "Now as $($env:Username)"
}

# Disconnect the remote session
Disconnect-PSSession -Session $Session