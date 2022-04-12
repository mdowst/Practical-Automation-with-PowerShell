# Listing 8 - Check if the VM exists before creating it
# Attempt to see if the virtual machine already exists
try {
    $VM = Get-VM -Name $VMName -ErrorAction Stop
}
catch {
    # If the catch is triggered, then set $VM to null to ensure that any previous data is cleared out
    $VM = $null
    
    # If the error is not the expected one for a VM not being there, then throw a terminating error
    if ($_.FullyQualifiedErrorId -ne 
        'InvalidParameter,Microsoft.HyperV.PowerShell.Commands.GetVM') {
        throw $_
    }
}

# If the VM is not found, then create it
if ($null -eq $VM) {
    # Create the VM
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
}
