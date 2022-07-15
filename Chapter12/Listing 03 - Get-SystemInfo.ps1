# Listing 3 - Get-SystemInfo
Function Get-SystemInfo{
    Get-CimInstance -Class Win32_OperatingSystem | 
        Select-Object Caption, InstallDate, ServicePackMajorVersion, 
        OSArchitecture, BootDevice, BuildNumber, CSName, 
        @{l='Total_Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
}