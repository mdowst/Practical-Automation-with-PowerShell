# Listing 11 - Add a second virtual hard disk
Function Add-SecondVHD{
    param(
        $VM
    )
    # Set path for the second hard drive
    $Path = @{
        Path      = $VM.Path
        ChildPath = "$($VM.Name)-Data.vhdx"
    }
    $DataDisk = Join-Path @Path

    # If the VHD does not exist, then create it
    if (-not(Test-Path $DataDisk)) {
        New-VHD -Path $DataDisk -SizeBytes 10GB | Out-Null
    }

    # If the VHD is not attached to the VM, then attach it
    $Vhd = $VM.HardDrives | 
        Where-Object { $_.Path -eq $DataDisk }
    if (-not $Vhd) {
        $VM | Get-VMScsiController -ControllerNumber 0 | 
            Add-VMHardDiskDrive -Path $DataDisk
    }
}

Add-SecondVHD -VM $VM

# Script block to initialize, partition, and format the new drive inside the guest OS
$ScriptBlock = {
    $Volume = @{
        FileSystem         = 'NTFS'
        NewFileSystemLabel = "Data"
        Confirm            = $false
    }
    Get-Disk | Where-Object { $_.PartitionStyle -eq 'raw' } |
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -AssignDriveLetter -UseMaximumSize |
    Format-Volume @Volume
}

# Run command on guest OS to set up the new drive
$Command = @{
    VMId        = $VM.Id
    ScriptBlock = $ScriptBlock
    Credential  = $Credential
    ErrorAction = 'Stop'
}
$Results = Invoke-Command @Command
$Results