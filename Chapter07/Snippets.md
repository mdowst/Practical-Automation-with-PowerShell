# Snippet 1 - Setting values to create an identity column
```powershell
$ID = @{
    Name = 'ID';
    Type = 'int';
    MaxLength = $null;
    Nullable = $false;
    Identity = $true;
}
```

# Snippet 2 - Test the Connect-PoshAssetMgmt function
```powershell
Import-Module '.\PoshAssetMgmt.psd1' -Force
Connect-PoshAssetMgmt
```
```
ComputerName Name             ConnectedAs
------------ ----             -----------
SRV01        SRV01\SQLEXPRESS SRV01\Administrator
```

# Snippet 3 - Parameter length validation example
```powershell
Function New-PoshServer {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({$_.Length -le 50 })]
        [string]$Name
    )
    $PSBoundParameters
}
New-PoshServer -Name 'Srv01'
New-PoshServer -Name 'ThisIsAReallyLongServerNameThatWillCertainlyExceed50Characters'
```

# Snippet 4 - Parameter vaildation set example
```powershell
[Parameter(Mandatory=$true)]
[ValidateSet('Active','Depot','Retired')]
[string]$Status,

[Parameter(Mandatory=$true)]
[ValidateSet('Windows','Linux')]
[string]$OSType,

[Parameter(Mandatory=$true)]
[ValidateSet('WSMan','SSH','PowerCLI','HyperV','AzureRemote')]
[string]$RemoteMethod,

[Parameter(Mandatory=$true)]
[ValidateSet('Physical','VMware','Hyper-V','Azure','AWS')]
[string]$Source,
```

# Snippet 5 - Test the New-PoshServer function
```powershell
Import-Module '.\PoshAssetMgmt.psd1' -Force
Connect-PoshAssetMgmt | Out-Null

$testData = @{
    OSType         = 'Windows'
    Status         = 'Active'
    RemoteMethod   = 'WSMan'
    Source         = 'VMware'
    OSVersion      = 'Microsoft Windows Server 2019 Standard'
    SourceInstance = 'Cluster1'
}

New-PoshServer -Name 'Srv01' -UUID '001' @testData
New-PoshServer -Name 'Srv02' -UUID '002' @testData
New-PoshServer -Name 'Srv03' -UUID '003' @testData
```

# Snippet 6 - Get the values in the Servers table
```powershell
$DbaQuery = @{
    SqlInstance = "$($env:COMPUTERNAME)\SQLEXPRESS"
    Database = 'PoshAssetMgmt'
    Query = 'SELECT * FROM Servers'
}
Invoke-DbaQuery @DbaQuery
```

# Snippet 7 - SQL query using a where clause
```powershell
SELECT * FROM Servers WHERE Name = 'Srv01'
```

# Snippet 8 - Using a where clause with the Invoke-DbaQuery cmdlet
```powershell
$DbaQuery = @{
    SqlInstance = "$($env:COMPUTERNAME)\SQLEXPRESS"
    Database = 'PoshAssetMgmt'
    Query = 'SELECT * FROM Servers WHERE Name = @name'
    SqlParameter = @{name = 'Srv01'}
}
Invoke-DbaQuery @DbaQuery
```

# Snippet 9 - Test the Get-PoshServer function
```powershell
Import-Module '.\PoshAssetMgmt.psd1' -Force
Connect-PoshAssetMgmt
Get-PoshServer | Format-Table
Get-PoshServer -Id 1 | Format-Table
Get-PoshServer -Name 'Srv02' | Format-Table
Get-PoshServer -Source 'VMware' -Status 'Active' | Format-Table
```

# Snippet 10 - Parameter sets example
```powershell
[Parameter(ValueFromPipeline = $true,ParameterSetName="Pipeline")]
[object]$InputObject,
[Parameter(Mandatory = $true,ParameterSetName="Id")]
[int]$ID,
```

# Snippet 11 - SQL Update statement with Output showing what changed
```powershell
UPDATE [dbo].[Server]
SET Source = @Source
OUTPUT @ID AS ID, deleted.Source AS Prev_Source,
    inserted.Source AS Source
WHERE ID = @ID
```

# Snippet 12 - Test the Set-PoshServer function
```powershell
Import-Module '.\PoshAssetMgmt.psd1' -Force
Connect-PoshAssetMgmt
Set-PoshServer -Id 1 -Status 'Retired' -Verbose
Get-PoshServer -SourceInstance 'Cluster1' | Set-PoshServer -SourceInstance 'Cluster2'
```

