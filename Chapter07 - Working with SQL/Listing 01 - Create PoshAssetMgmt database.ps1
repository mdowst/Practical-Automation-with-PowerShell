# Listing 1 - Create PoshAssetMgmt database
$SqlInstance = "$($env:COMPUTERNAME)\SQLEXPRESS"
$DatabaseName = 'PoshAssetMgmt'
$DbaDatabase = @{
	SqlInstance   = $SqlInstance
	Name          = $DatabaseName
	RecoveryModel = 'Simple'
}
New-DbaDatabase @DbaDatabase