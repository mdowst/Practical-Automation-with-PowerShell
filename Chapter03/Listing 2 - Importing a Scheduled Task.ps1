# Listing 2 - Importing a Scheduled Task
$FilePath = ".\CH03\Monitor\Export\DiskSpaceMonitor.xml"
# Import the contents of the XML file to a string
$xml = Get-Content $FilePath -Raw
# Convert the XML string to an XML object
[xml]$xmlObject = $xml
# Set the task name based on the value in the XML
$TaskName = $xmlObject.Task.RegistrationInfo.URI
# Import the scheduled task
Register-ScheduledTask -Xml $xml -TaskName $TaskName