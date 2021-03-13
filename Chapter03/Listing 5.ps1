# Listing 5 - File Watcher Basic
$Source = '.\CH03\Watcher\Source'
$Destination = '.\CH03\Watcher\Destination'

# Get all the source files
$files = Get-ChildItem -Path $Source

# Loop through each file and move to the destination folder
foreach($file in $files){
    Move-Item -Path $file.FullName -Destination $Destination
}
