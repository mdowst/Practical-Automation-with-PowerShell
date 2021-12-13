# Listing 1 - Install Microsoft Monitoring Agent
# Set the parameters for your workspace
$WorkspaceID = 'YourId'
$WorkSpaceKey = 'YourKey'

# URL for the agent installer
$agentURL = 'https://download.microsoft.com/download' +
    '/3/c/d/3cd6f5b3-3fbe-43c0-88e0-8256d02db5b7/MMASetup-AMD64.exe'

# Download the agent
$FileName = Split-Path $agentURL -Leaf
$MMAFile = Join-Path -Path $env:Temp -ChildPath $FileName
Invoke-WebRequest -Uri $agentURL -OutFile $MMAFile | Out-Null

# Install the agent
$ArgumentList = '/C:"setup.exe /qn ' +
    'ADD_OPINSIGHTS_WORKSPACE=0 ' +
    'AcceptEndUserLicenseAgreement=1"'
$Install = @{
    FilePath     = $MMAFile
    ArgumentList = $ArgumentList
    ErrorAction  = 'Stop'
}
Start-Process @Install -Wait | Out-Null

# Load the agent config com object
$Object = @{
	ComObject = 'AgentConfigManager.MgmtSvcCfg'
}
$AgentCfg = New-Object @Object

# Set the workspace ID and key
$AgentCfg.AddCloudWorkspace($WorkspaceID, 
    $WorkspaceKey)

# Restart the agent for the changes to take effect
Restart-Service HealthService