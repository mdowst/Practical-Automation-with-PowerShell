# Listing 4 - SQL health check through Jenkins
# Replace Get-Secret call with Jenkins environment variables and recreate the credential object
$secure = @{
    String = $ENV:sqlpassword
    AsPlainText = $true
    Force = $true
}
$Password = ConvertTo-SecureString @secure
$SqlCredential = New-Object System.Management.Automation.PSCredential `
    ($ENV:sqlusername, $Password)

# Replace Get-Secret call with Jenkins environment variables
$SQLServer = $ENV:sqlserver

$DbaDiagnosticQuery = @{
    SqlInstance   = $SQLServer
    SqlCredential = $SqlCredential
    QueryName     = 'DatabaseProperties'
}
$HealthCheck = Invoke-DbaDiagnosticQuery @DbaDiagnosticQuery
$failedCheck = $HealthCheck.Result | 
    Where-Object { $_.'Recovery Model' -ne 'SIMPLE' }

if ($failedCheck) {
    # Replace Get-Secret call with Jenkins environment variables
    $From = $ENV:sendgrid
    # Replace Get-Secret call with Jenkins environment variables and recreate the credential object
    $secure = @{
        String = $ENV:sendgridusername
        AsPlainText = $true
        Force = $true
    }
    $Password = ConvertTo-SecureString @secure
    $Credential = New-Object System.Management.Automation.PSCredential `
        ($ENV:sendgridpassword, $Password)
    
    $Body = $failedCheck | ConvertTo-Html -As List | 
        Out-String

    $EmailMessage = @{
        From       = $From
        To         = $SendTo
        Credential = $EmailCredentials
        Body       = $Body
        Priority   = 'High'
        Subject    = "SQL Health Check Failed for $($SQLServer)"
        SendGrid   = $true
    }
    Send-EmailMessage @EmailMessage
}