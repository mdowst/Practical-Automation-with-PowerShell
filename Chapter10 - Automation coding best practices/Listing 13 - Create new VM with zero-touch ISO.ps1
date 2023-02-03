# Listing 13 - Create new VM with zero-touch ISO
<#
.SYNOPSIS
Create new VM with zero-touch ISO

.DESCRIPTION
Part of the zero-touch install automation. Use the create
zero-touch ISO script to create the ISO for use with this
script.

.PARAMETER VMName
The name for the new VM

.PARAMETER ISO
The full path to the zero-touch ISO

.PARAMETER VMHostName
The name of the Hyper-V host to create the new VM on. Defaults
to localhost if not provided.

.PARAMETER OsInstallTimeLimit
The number of minutes to wait for the operating system
to finish installing. Defaults to 30 minutes.

.EXAMPLE
.\New-ZeroTouchVM.ps1 -VMName 'VM01' -ISO 'D:\WinSrv2022.iso'

Creates a new VM named VM01 using the ISO file D:\WinSrv2022.iso.
VMHostName and OsInstallTimeLimit are set to the default values.

.EXAMPLE
.\New-ZeroTouchVM.ps1 -VMName 'VM01' -ISO 'D:\Win11.iso' -VMHostName 'Hv02'

Creates a new VM named VM01 using the ISO file D:\Win11.iso on
the Hyper-V host Hv02.

.EXAMPLE
$ZeroTouchVM = @{
	VMName             = 'VM01'
	ISO                = 'D:\WinSrv2022.iso'
	VMHostName         = 'Hv02'
	OsInstallTimeLimit = 60
}
.\New-ZeroTouchVM.ps1 @ZeroTouchVM

Creates a new VM named VM01 using the ISO file D:\WinSrv2022.iso on
the Hyper-V host Hv02 and gives the OS 60 minutes to install before 
throwing an error.

.EXAMPLE
$ZeroTouchVM = @{
	VMName             = 'VM01'
	ISO                = 'D:\WinSrv2022.iso'
	OsInstallTimeLimit = 60
}
.\New-ZeroTouchVM.ps1 @ZeroTouchVM

Creates a new VM named VM01 using the ISO file D:\WinSrv2022.iso on
the local hyper-v host and gives the OS 60 minutes to install before 
throwing an error.

.NOTES
Created for chapter 10
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [Parameter(Mandatory = $true)]
    [string]$ISO,
    [Parameter(Mandatory = $false)]
    [string]$VMHostName = 'localhost',
    [Parameter(Mandatory = $false)]
    [int]$OsInstallTimeLimit = 30
)

#region Functions
Function Get-IsoCredentials {
    <#
    .SYNOPSIS
    Extracts the credenitals from a zero-touch ISO
    
    .DESCRIPTION
    The ISO must have an autounattend.xml configured
    with a default administrator password. If not found
    user will be prompted to provide credentials.
    
    .PARAMETER ISO
    Parameter description
    
    .EXAMPLE
    Get-IsoCredentials -ISO 'C:\Win10.iso'
    
    .NOTES
    Created for use with the zero-touch automation
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ISO
    )
    
    # Mount the ISO image
    $DiskImage = @{
        ImagePath = $ISO
        PassThru  = $true
    }
    $image = Mount-DiskImage @DiskImage

    # Get the new drive letter
    $drive = $image | 
    Get-Volume | 
    Select-Object -ExpandProperty DriveLetter

    # Attempt to find the autounattend.xml in the ISO image
    $ChildItem = @{
        Path   = "$($drive):"
        Filter = "autounattend.xml"
    }
    $AutounattendXml = Get-ChildItem @ChildItem

    # If autounattend.xml is found attempt to extract the password
    if ($AutounattendXml) {
        [xml]$Autounattend = Get-Content $AutounattendXML.FullName
        $object = $Autounattend.unattend.settings | 
        Where-Object { $_.pass -eq "oobeSystem" }
        $AdminPass = $object.component.UserAccounts.AdministratorPassword
        if ($AdminPass.PlainText -eq $false) {
            $encodedpassword = $AdminPass.Value
            $base64 = [system.convert]::Frombase64string($encodedpassword)
            $decoded = [system.text.encoding]::Unicode.GetString($base64)
            $AutoPass = ($decoded -replace ('AdministratorPassword$', ''))
        }
        else {
            $AutoPass = $AdminPass.Value
        }
    }

    # dismount the ISO
    $image | Dismount-DiskImage | Out-Null

    # If the password is returned create a credential object, owerwise prompt the user for the credentials
    $user = "administrator"
    if ([string]::IsNullOrEmpty($AutoPass)) {
        $parameterHash = @{
            UserName = $user
            Message  = 'Enter administrator password'
        }
        $credential = Get-Credential @parameterHash
    }
    else {
        $pass = ConvertTo-SecureString $AutoPass -AsPlainText -Force
        $Object = @{
            TypeName     = 'System.Management.Automation.PSCredential'
            ArgumentList = ( $user , $pass )
        }
        $credential = New-Object @Object
    }

    $credential
}

Function New-VmFromIso {
    <#
    .SYNOPSIS
    Creates a new VM
    
    .DESCRIPTION
    Will create VM in the default Virtual Machine Path
    configured in the host and selects the first 
    available external switch.
    
    .PARAMETER VMName
    The name for the new VM
    
    .PARAMETER VMHostName
    The name of the hyper-v host machine
    
    .EXAMPLE
    New-VmFromIso -VMName 'VM01' -VMHostName 'HV-Host01'
    
    .NOTES
    Created for use with the zero-touch automation
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$VMName,
        [Parameter(Mandatory = $true)]
        [string]$VMHostName
    )

    # Get the VM host to determine the VM Path
    $VmHost = Get-VMHost -ComputerName $VMHostName

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

    # If the switch is found add it to the VM parameters
    if ($VmSwitch) {
        $VMParams.Add('SwitchName',$VmSwitch.Name)
    }

    # Create the VM
    New-VM @VMParams

    # Get the VM
    $VM = Get-VM -Name $VMName

    $VM
}

Function Set-VmSettings {
    <#
    .SYNOPSIS
    Updates the virtual machine with the default settings
    
    .DESCRIPTION
    Set the memory to dynamic
    Disables automatic checkpoints
    Adds the OS installation ISO
    Set the boot order
    
    .PARAMETER VM
    The virtual machine object to update the settings on

    .PARAMETER ISO
    The full path of the ISO file to attach for installing the OS
    
    .EXAMPLE
    $ISO = 'D:\ISO\Windows11.iso'
    $VM = Get-VM -Name $VMName
    Set-VmSettings -VM $VM -ISO $ISO
    
    .NOTES
    Created for use with the zero-touch automation
    Updated on 1/15/2022 to include dyanmic memory
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]    
        [object]$VM,
        [Parameter(Mandatory = $true)]    
        [string]$ISO
    )
    
    # Set the VM memory
    $VMMemory = @{
        DynamicMemoryEnabled = $true
        MinimumBytes         = 512MB
        MaximumBytes         = 2048MB
        Buffer               = 20
        StartupBytes         = 1024MB
    }
    $VM | Set-VMMemory @VMMemory

    # Disbale automatic checkpoints
    $VM | Set-VM -AutomaticCheckpointsEnabled $false

    # Add the Windows installation ISO
    if (-not $VM.DVDDrives) {
        $VM | Add-VMDvdDrive -Path $ISO
    }
    else {
        $VM | Set-VMDvdDrive -Path $ISO
    }

    # Set the boot order to use the DVD drive first
    $BootOrder = @(
        $VM.DVDDrives[0]
        $VM.HardDrives[0]
    )
    $VM | Set-VMFirmware -BootOrder $BootOrder
}

Function Add-VmDataDrive {
    <#
    .SYNOPSIS
    Adds a second data disk to a VM
    
    .DESCRIPTION
    Adds a 10 GB data disk to a VM if it doesn't already exists
    
    .PARAMETER VM
    The virtual machine object to add a VHD to
    
    .EXAMPLE
    $VM = Get-VM -Name $VMName
    Add-VmDataDrive -VM $VM
    
    .NOTES
    Created for use with the zero-touch automation
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]    
        [object]$VM
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
#endregion Functions

#region Create VM
# Attempt to see if the virtual machine already exists
try {
    $VM = Get-VM -Name $VMName -ErrorAction Stop
}
catch {
    # if the catch is triggered then set $VM to null to ensure that any previous data is cleared out
    $VM = $null
    
    # If the error is not the expected one for a VM not being there, then throw a terminating error
    if ($_.FullyQualifiedErrorId -ne 
        'InvalidParameter,Microsoft.HyperV.PowerShell.Commands.GetVM') {
        throw $_
    }
}

# If the VM is not found then create it
if ($null -eq $VM) {
    # Create the VM
    $VmFromIso = @{
        VMName      = $VMName
        VMHostName  = $VMHostName
        ErrorAction = 'Stop'
    }
    $VM = New-VmFromIso @VmFromIso
}

# Check if the VM is running
if ($VM.State -ne 'Running') {
    # Set the default settings
    Set-VmSettings -VM $VM

    # Start the VM
    $VM | Start-VM -ErrorAction Stop

    # open the vmconnect to the newly created VM
    vmconnect $VMHostName $VMName
}
#endregion Create VM

#region Wait for OS install
$Credential = Get-IsoCredentials -ISO $ISO

# Command to return the VM guest host name. Will be used to determine that the OS install has completed
$Command = @{
    VMId        = $VM.Id
    ScriptBlock = { $env:COMPUTERNAME }
    Credential  = $Credential
    ErrorAction = 'Stop'
}

# Include a timer or counter to ensure that your script doesn't end after so many minutes
$timer = [system.diagnostics.stopwatch]::StartNew()

# Set the variable the while loop to $null to ensure that past variables are not causing false positives
$Results = $null
while ([string]::IsNullOrEmpty($Results)) {
    try {
        # Run the command to get the host name
        $Results = Invoke-Command @Command
    }
    catch {
        # If the timer exceeds the number of minutes than throw a terminating error
        if ($timer.Elapsed.TotalMinutes -gt 
            $OsInstallTimeLimit) {
            throw "Failed to provision virtual machine after 10 minutes."
        }
    }
}

# Remove the ISO image
$VM | Get-VMDvdDrive | Set-VMDvdDrive -Path $null

#endregion Wait for OS install

#region Add second hard drive

# Add data drive to the VM
Add-VmDataDrive -VM $VM

# Script block to initalize, partition, and format the new drive inside the guest OS
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
#endregion Add second hard drive