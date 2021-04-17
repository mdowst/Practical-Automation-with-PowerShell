# Listing 5 - Connect to Azure with service principal
$appName = 'PoshAutomate'
$appId   = '493bdd5d-897c-48eb-8a65-c831329b6b56'
$Tenant  = 'f4a5feeb-b3ed-405d-9237-679f750a30ff'

# Get the certificate from your local store
$cert = Get-ChildItem -Path "cert:\CurrentUser\My" | 
    Where-Object{ $_.Subject -eq "CN=$($appName)" }

# connect to Azure
$AzAccount = @{
	CertificateThumbprint = $cert.Thumbprint
	ApplicationId         = $appId
	Tenant                = $Tenant
}
Connect-AzAccount @AzAccount