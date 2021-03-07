# Listing 6 - File Watcher With Rename
param(
    $Source = 'P:\Scripts\CH03\Watcher\Source',
    $Destination = 'P:\Scripts\CH03\Watcher\Destination'
)

# Get all the sort files
$files = Get-ChildItem -Path $Source

# Sort the files based on created time ensuring files are processed in the order they are received
$sorted = $files | Sort-Object -Property CreationTime

# Check that the destination folder exists and created it if it doesn't
if (-not (Test-Path -Path $Destination)) {
    New-Item -Path $Destination -ItemType Directory | Out-Null
    Write-Verbose "Created folder '$Destination'"
}

foreach($file in $sorted){
    $DestinationFile = Join-Path -Path $Destination -ChildPath $file.Name
    $i = 0
    # If file already exists, add underscore and number to the name until you get a unique name
    while(Test-Path $DestinationFile){
        $name = $file.BaseName + "_" + $i + $file.Extension
        $DestinationFile = Join-Path -Path $Destination -ChildPath $name
        $i++
    }
    Move-Item -Path $file.FullName -Destination $DestinationFile
}
