# Listing 1 - Create Scheduled Task
# Create a Scheduled Task trigger
$Trigger = New-ScheduledTaskTrigger -Daily -At 8am

# Set the Action execution path
$Execute = "C:\Program Files\PowerShell\7\pwsh.exe"
# Set the Action arguments
$Argument = '-File ' +
    '"C:\Scripts\Invoke-LogFileCleanup.ps1"' +
    ' -LogPath "L:\Logs" -ZipPath "L:\Archives"' +
    ' -ZipPrefix "LogArchive-" -NumberOfDays 30'

# Create the Scheduled Task Action
$ScheduledTaskAction = @{
    Execute  = $Execute
    Argument = $Argument
}
$Action = New-ScheduledTaskAction @ScheduledTaskAction

# Combine the trigger and action to create the Scheduled Task
$ScheduledTask = @{
    TaskName = "PoSHAutomation\LogFileCleanup"
    Trigger  = $Trigger
    Action   = $Action
    User     = 'NT AUTHORITY\SYSTEM'
}
Register-ScheduledTask @ScheduledTask