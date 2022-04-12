# Listing 9 - Update VM settings
# Set the VM memory
$VMMemory = @{
	DynamicMemoryEnabled = $true
	MinimumBytes         = 512MB
	MaximumBytes         = 2048MB
	Buffer               = 20
	StartupBytes         = 1024MB
}
$VM | Set-VMMemory @VMMemory

# Disable automatic checkpoints
$VM | Set-VM -AutomaticCheckpointsEnabled $false

# Add the Windows installation ISO
if(-not $VM.DVDDrives){
    $VM | Add-VMDvdDrive -Path $ISO
}
else{
    $VM | Set-VMDvdDrive -Path $ISO
}

# Set the boot order to use the DVD drive first
$BootOrder = @(
    $VM.DVDDrives[0]
    $VM.HardDrives[0]
)
$VM | Set-VMFirmware -BootOrder $BootOrder