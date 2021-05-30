# Listing 1 - Test SQL Connection information from SecretStore vault
# Retrieve credentials for SQL server connection.
$Secret = @{
	Name  = 'TestSQLCredential'
	Vault = 'SQLHealthCheck'
}
$SqlCredential = Get-Secret @Secret
# Retrieve the SQL server name and convert it to plain text.
$Secret = @{
	Name        = 'TestSQL'
	Vault       = 'SQLHealthCheck'
}
$SQLServer = Get-Secret @Secret -AsPlainText

# Execute query against SQL to test connection information from the SecretStore vault.
$DbaQuery = @{
	SqlInstance   = $SQLServer
	Query         = 'SELECT name FROM sys.databases'
	SqlCredential = $SqlCredential
}
Invoke-DbaQuery @DbaQuery

$SqlName  = 'TestSQL'
$SqlCred  = "$($SqlName)Credential"