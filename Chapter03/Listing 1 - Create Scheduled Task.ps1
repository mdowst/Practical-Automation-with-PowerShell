# Listing 1 - Create Scheduled Task
# Create Scheduled Task trigger
$Trigger = New-ScheduledTaskTrigger -Daily -At 8am

# Set Action execution path
$Execute = "C:\Program Files\PowerShell\7\pwsh.exe"
# Set Action arguments
$Argument = '-File ' +
    '"C:\Scripts\Export-DiskSpaceInfo.ps1"' +
    ' -CsvPath "C:\Logs\DiskSpaceMonitor.csv"'

# Create the Scheduled Task Action
$ScheduledTaskAction = @{
    Execute = $Execute 
    Argument = $Argument
}
$Action = New-ScheduledTaskAction @ScheduledTaskAction

# Combine the trigger and action to create the Scheduled Task
$ScheduledTask = @{
    TaskName = "PoSHAutomation\DiskSpaceMonitor"
    Trigger  = $Trigger
    Action   = $Action
    User     = 'NT AUTHORITY\SYSTEM'
}
Register-ScheduledTask @ScheduledTask