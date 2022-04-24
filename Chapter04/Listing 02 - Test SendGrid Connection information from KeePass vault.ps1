# Listing 2 - Test SendGrid Connection information from KeePass vault
# Get the email address for the send from in plain text
$Secret = @{
    Name  = 'SendGrid'
    Vault = 'SmtpKeePass'
}
$From = Get-Secret @Secret -AsPlainText
# Get the API key for SendGrid
$Secret = @{
    Name  = 'SendGridKey'
    Vault = 'SmtpKeePass'
}
$EmailCredentials = Get-Secret @Secret

# Send test email with the SendGrid connection information from the KeePass vault.
$EmailMessage = @{
    From       = $From
    To         = $From
    Credential = $EmailCredentials
    Body       = 'This is a test of the SendGrid API'
    Priority   = 'High'
    Subject    = "Test SendGrid"
    SendGrid   = $true
}
Send-EmailMessage @EmailMessage