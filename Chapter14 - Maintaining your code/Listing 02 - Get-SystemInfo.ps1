# Listing 2 - Get-SystemInfo.ps1
Function Get-SystemInfo{
    [CmdletBinding()]
    param()
    # Check if the machine is running a Linux-based OS
    if(Get-Variable -Name IsLinux -ValueOnly){
        # Get the data from the os-release file, and convert it to a PowerShell object
        $OS = Get-Content -Path /etc/os-release | 
            ConvertFrom-StringData

        # Search the meminfo file for the MemTotal line and extract the number
        $search = @{
            Path    = '/proc/meminfo'
            Pattern = 'MemTotal'
        }
        $Mem = Select-String @search | 
            ForEach-Object{ [regex]::Match($_.line, "(\d+)").value}

        # Run the stat command, parse the output for the Birth line, and then extract the date
        $stat = Invoke-Expression -Command 'stat /'
        $InstallDate = $stat | Select-String -Pattern 'Birth:' | 
            ForEach-Object{
            Get-Date $_.Line.Replace('Birth:','').Trim()
        }
        
        # Run the df and uname commands, and save the output as is
        $boot = Invoke-Expression -Command 'df /boot'
        $OSArchitecture = Invoke-Expression -Command 'uname -m'
        $CSName = Invoke-Expression -Command 'uname -n' 

        # Build the results into a PowerShell object that matches the same properties as the existing Windows output
        [pscustomobject]@{
            Caption                 = $OS.PRETTY_NAME.Replace('"',"")
            InstallDate             = $InstallDate
            ServicePackMajorVersion = $OS.VERSION.Replace('"',"")
            OSArchitecture          = $OSArchitecture
            BootDevice              = $boot.Split("`n")[-1].Split()[0]
            BuildNumber             = $OS.VERSION_ID.Replace('"',"")
            CSName                  = $CSName
            Total_Memory            = [math]::Round($Mem/1MB)
        }
    }
    else{
        # Original Windows system information commands
        Get-CimInstance -Class Win32_OperatingSystem | 
            Select-Object Caption, InstallDate, ServicePackMajorVersion, 
            OSArchitecture, BootDevice, BuildNumber, CSName, 
            @{l='Total_Memory';
                e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
    }
}