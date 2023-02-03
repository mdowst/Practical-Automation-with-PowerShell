# These will do nothing
Write-Host "Write-Host does not work in Azure Automation runbooks"

Write-Progress -Activity "Running" -Status "Write-Progress does not work" -PercentComplete 50

# These will work in Azure Automation
Write-Output "Write-Output shows in the All Logs and Output tabs"

Write-Verbose "Write-Verbose only shows in All Logs when it is turned on"

Write-Warning "Write-Warning shows in the All Logs and Warnings tabs"

Write-Error "Write-Error does shows in the All Logs and Errors tabs"

"Writing directly to the stream works, but can be unreliable. It is best to use Write-Output"

throw "Any terminating error will write to the Exception tab"