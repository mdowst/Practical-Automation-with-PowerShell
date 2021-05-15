# Listing 3 - Importing Multiple a Scheduled Tasks
$Share = "\\srv01\PoSHAutomation\"
# Get all the XML files in the folder path
$TaskFiles = Get-ChildItem -Path $Share -Filter "*.xml"

# parse through each file and import the job
foreach($task in $TaskFiles){
    $xml = Get-Content $FilePath -Raw
    [xml]$xmlObject = $xml
    $TaskName = $xmlObject.Task.RegistrationInfo.URI
    Register-ScheduledTask -Xml $xml -TaskName $TaskName
}