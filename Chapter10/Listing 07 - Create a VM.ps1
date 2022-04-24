# Listing 7 - Create a VM
$VMParams = @{
	Name            = $VMName
	NewVHDPath      = $NewVHDPath
	NewVHDSizeBytes = 40GB
	SwitchName      = $VmSwitch.Name
	Path            = $VmHost.VirtualMachinePath
	Generation      = 2
	ErrorAction     = 'Stop'
}
$VM = New-VM @VMParams