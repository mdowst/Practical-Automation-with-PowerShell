# Listing 6 - Get the Path and External Switch
# Get the VM host to determine the VM Path
$VmHost = Get-VMHost -ComputerName $VMHostName

# Confirm the script can access the VM Path
$TestPath = Test-Path -Path $VmHost.VirtualMachinePath
if($TestPath -eq $false){
    throw "Unable to access path '$($VmHost.VirtualMachinePath)'"
}

# Set the path for the VM's virtual hard disk
$Path = @{
	Path      = $VmHost.VirtualMachinePath
	ChildPath = "$VMName\$VMName.vhdx"
}
$NewVHDPath = Join-Path @Path

# Set the new VM parameters
$VMParams = @{
    Name            = $VMName
    NewVHDPath      = $NewVHDPath
    NewVHDSizeBytes = 40GB
    Path            = $VmHost.VirtualMachinePath
    Generation      = 2
}

# Determine the switch to use
$VmSwitch = Get-VMSwitch -SwitchType External | 
    Select-Object -First 1
if (-not $VmSwitch) {
    $VmSwitch = Get-VMSwitch -Name 'Default Switch' 
}

# If the switch is found, add it to the VM parameters
if ($VmSwitch) {
    $VMParams.Add('SwitchName',$VmSwitch.Name)
}
