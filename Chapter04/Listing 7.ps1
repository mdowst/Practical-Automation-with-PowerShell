# Listing 7 - Connect to Azure REST API
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
	ResourceUrl = "https://management.core.windows.net"
}
$Token = Get-AzAccessToken @AzAccessToken

# Create authorization header with the access token
$Headers = @{ 
    Authorization = "Bearer " + $Token.Token 
}
# Connect to Azure REST API
$RestApiUrl = "https://management.azure.com/" +
    "subscriptions/" + $context.Subscription.Id +
    "/resourcegroups?api-version=2020-10-01"
$RestMethod = @{
	Method  = 'Get'
	Uri     = $RestApiUrl
	Headers = $Headers
}
$resource = Invoke-RestMethod @RestMethod