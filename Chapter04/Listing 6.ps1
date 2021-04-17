# Listing 6 - Connect to Azure AD from existing Azure connection
$appName = 'PoshAutomate'
$appId   = '493bdd5d-897c-48eb-8a65-c831329b6b56'
$Tenant  = 'f4a5feeb-b3ed-405d-9237-679f750a30ff'

# connect to Azure the same way as before
$cert = Get-ChildItem -Path "cert:\CurrentUser\My" | 
    Where-Object{ $_.Subject -eq "CN=$($appName)" }
$AzAccount = @{
	CertificateThumbprint = $cert.Thumbprint
	ApplicationId         = $appId
	Tenant                = $Tenant
}
Connect-AzAccount @AzAccount

# Get the context for the connection
$context = Get-AzContext
# get the access token from the current Azure session
$Token = Get-AzAccessToken -TenantId $context.tenant.id

# connect to Azure AD using the current Azure context
$AzureAD = @{
	AadAccessToken       = $Token.Token
	AccountId            = $context.Account.Id
	TenantId             = $context.tenant.id
	AzureEnvironmentName = $context.Environment.Name
}
Connect-AzureAD @AzureAD