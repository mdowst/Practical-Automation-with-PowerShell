# Listing 2 - Send email from Automation Account
param (
    [Parameter(Mandatory = $true)]
    [string]$To
)

$Credential = Get-AutomationPSCredential -Name 'Office 365 Email'
$SmtpServer = Get-AutomationVariable -Name 'SMTP-Address'

# Email body
$Body = @"
This is a test from Azure Automation
"@

# Configuration
$MailMessageParams = @{
    To         = $To
    From       = $Credential.UserName
    Subject    = "Automation Test"
    SmtpServer = $SmtpServer
    Credential = $Credential
    Port       = 587
    Body       = $Body
    BodyAsHtml = $true
    UseSsl     = $true
}
# Send the email 
Send-MailMessage @MailMessageParams

