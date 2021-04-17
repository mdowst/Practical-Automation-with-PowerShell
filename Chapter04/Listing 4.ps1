# Listing 4 - Create Service Principal with certificate
# Set the application name
$appName = 'PoshAutomate'

# Connect to AzureAD interactively
Connect-AzureAD

# Check if the AD App exists and create if it doesn't
$AppFilter = @{
    Filter = "DisplayName eq '$($appName)'"
}
$myApp = Get-AzureADApplication @AppFilter
if(-not $myApp){
    # Create the Azure AD App 
    $newApp = @{
        DisplayName = $appName
        ReplyUrls   = "http://$appName" 
    }
    $myApp = New-AzureADApplication @newApp
}

# Check if the Service Principal exists and create if it doesn't
$mySP = Get-AzureADServicePrincipal @AppFilter
if(-not $mySP){
    # Create the Service Principal
    $newSp = @{
        AppID = $myApp.AppID
    }
    $mySP = New-AzureADServicePrincipal @newSp
}

# create the self-signed certificate
$certParams = @{
    CertStoreLocation = "cert:\CurrentUser\My"
    Subject           = "CN=$($appName)"
    KeySpec           = 'KeyExchange'
}
$cert = New-SelfSignedCertificate @certParams

# get the certificate values for the service principal
$bin = $cert.GetRawCertData()
$base64Value = [System.Convert]::ToBase64String($bin)
$bin = $cert.GetCertHash()
$base64Thumbprint = [System.Convert]::ToBase64String($bin)

# add the certificate to the service principal
$CertCredParameters = @{ 
    ObjectId            = $myApp.ObjectId
    CustomKeyIdentifier = $base64Thumbprint
    Type                = 'AsymmetricX509Cert'
    Usage               = 'Verify'
    Value               = $base64Value
    StartDate           = (Get-Date)
    EndDate             = (Get-Date $cert.GetExpirationDateString())
}
New-AzureADApplicationKeyCredential @CertCredParameters | Out-Null

# output the application id and tenant
$tenant = Get-AzureADTenantDetail
Write-Output "AppId: $($mySP.AppID)"
Write-Output "Tenant: $($tenant.ObjectID)"