# Listing 6 - File Watcher with Rename
param(
    $Source = '.\CH03\Watcher\Source',
    $Destination = '.\CH03\Watcher\Destination'
)

# Get all the source files
$files = Get-ChildItem -Path $Source

# Sort the files based on created time, ensuring files are processed in the order they are received
$sorted = $files | Sort-Object -Property CreationTime

# Check that the destination folder exists and create it if it doesn't
if (-not (Test-Path -Path $Destination)) {
    New-Item -Path $Destination -ItemType Directory | Out-Null
    Write-Verbose "Created folder '$Destination'"
}

foreach($file in $sorted){
    $DestinationFile = Join-Path -Path $Destination -ChildPath $file.Name
    $i = 0
    # If the file already exists, add underscore and number to the name until you get a unique name
    while(Test-Path $DestinationFile){
        $name = $file.BaseName + "_" + $i + $file.Extension
        $DestinationFile = Join-Path -Path $Destination -ChildPath $name
        $i++
    }
    Move-Item -Path $file.FullName -Destination $DestinationFile
}
