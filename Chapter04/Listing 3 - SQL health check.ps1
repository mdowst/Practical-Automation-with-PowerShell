# Listing 3 - SQL health check
param(
    [string]$SQLVault,
    [string]$SQLInstance,
    [string]$SmtpVault,
    [string]$FromSecret,
    [string]$SendTo
)
# Retrieve credentials for SQL server connection
$Secret = @{
	Name  = "$($SQLInstance)Credential"
	Vault = $SQLVault
}
$SqlCredential = Get-Secret @Secret
# Retrieve the SQL server name and convert it to plain text.
$Secret = @{
	Name        = $SQLInstance
	Vault       = $SQLVault
}
$SQLServer = Get-Secret @Secret -AsPlainText

# Execute the Database Properties diagnostic query against SQL
$DbaDiagnosticQuery = @{
	SqlInstance   = $SQLServer
	SqlCredential = $SqlCredential
	QueryName     = 'Database Properties'
}
$HealthCheck = Invoke-DbaDiagnosticQuery @DbaDiagnosticQuery
$failedCheck = $HealthCheck.Result | 
    Where-Object { $_.'Recovery Model' -ne 'SIMPLE' }

if ($failedCheck) {
    # Get the email address for the send from in plain text
    $Secret = @{
        Name  = $FromSecret
        Vault = $SmtpVault
    }
    $From = Get-Secret @Secret -AsPlainText
    # Get the API key for SendGrid
    $Secret = @{
        Name  = "$($FromSecret)Key"
        Vault = $SmtpVault
    }
    $EmailCredentials = Get-Secret @Secret

    # Create email body by converting failed check results to HTML table
    $Body = $failedCheck | ConvertTo-Html -As List | 
        Out-String

    # Send failure email notification
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