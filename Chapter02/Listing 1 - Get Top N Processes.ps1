# Listing 1 - Get Top N Processes
# Declare your function
Function Get-TopProcess{
    # Define the parameters
    param(
        [int]$TopN
    )
    # Run the command
    Get-Process | Sort-Object CPU -Descending |
        Select-Object -First $TopN -Property ID,
        ProcessName, @{l='CPU';e={'{0:N}' -f $_.CPU}}
}
