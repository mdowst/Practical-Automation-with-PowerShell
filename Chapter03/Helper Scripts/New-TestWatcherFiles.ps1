# Set directory to create test files in
$Directory = "L:\Watcher"
# Set number of files to create
$fileCount = 90

# create the folder if not found
if(-not (Test-Path $Directory)){
    New-Item -Path $Directory -ItemType Directory
}

# this function creates randomly sized files
Function Set-RandomFileSize {
   param( [string]$FilePath )
    $size = Get-Random -Minimum 1 -Maximum 50
    $size = $size*1024*1024
    $file = [System.IO.File]::Open($FilePath, 4)
    $file.SetLength($Size)
    $file.Close()
    Get-Item $file.Name
}

Function Get-RandomFileName {
    $len = 5..12 | Get-Random
    $string = ''
    for($i = 0; $i -lt $len; $i++){
        0..31 | Get-Random | Format-Hex | ForEach-Object {
            $string += $_.HexBytes.Split()[0]
        }
    }
    $string
}

# loop to create a file for each day back
for($i = 0; $i -lt $fileCount; $i++) {
    $minutes = 0..720 | Get-Random
    # Get Date and create log file
    $Date = (Get-Date).AddMinutes(-$minutes)
    # create unique file name with the date in it
    $FileName = "$(Get-RandomFileName).txt"
    # set the file path
    $FilePath = Join-Path -Path $Directory -ChildPath $FileName
    # write the date inside the file, will override existing files
    $Date | Out-File $FilePath
    # set a random file size
    Set-RandomFileSize -FilePath $FilePath 

    # Set the Creation, Write, and Access time of log file to past date
    Get-Item $FilePath | ForEach-Object { 
        $_.CreationTime = $date
        $_.LastWriteTime = $date
        $_.LastAccessTime = $date 
    }
}
