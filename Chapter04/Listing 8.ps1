# Listing 8 - Connect to Microsoft Graph API
$appName = 'PoshAutomate'
$appId   = 'GUID'
$Tenant  = 'GUID'

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
$AzAccessToken = @{
	TenantId    = $context.tenant.id
	ResourceUrl = "https://graph.microsoft.com"
}
$Token = Get-AzAccessToken @AzAccessToken

# Create authorization header with the access token
$Headers = @{ 
    Authorization = "Bearer " + $Token.Token 
}
# Connect to Azure REST API
$GraphApiUrl = "https://graph.microsoft.com/v1.0/users"
$RestMethod = @{
	Method  = 'Get'
	Uri     = $GraphApiUrl
	Headers = $Headers
}
$users = Invoke-RestMethod @RestMethod