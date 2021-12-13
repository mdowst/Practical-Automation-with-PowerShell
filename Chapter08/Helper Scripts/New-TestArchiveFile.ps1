# Set directory to create logs in
$Directory = "L:\Logs"
$ZipPath = "L:\Archives\"

# Create the zip file name and full path
$ZipName = "LogArchive-$((Get-Date).ToFileTime()).zip"
$ZipFile = Join-Path $ZipPath $ZipName

# Set number of test files to create
$days = 30

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

[System.Collections.Generic.List[PSObject]] $FilesCreated = @()
# loop to create a file for each day back
for($i = 0; $i -lt $days; $i++) {
    # Get Date and create log file
    $Date = (Get-Date).AddDays(-$i)
    # create unique file name with the date in it
    $FileName = "u_ex$($date.ToString('yyyyMMdd')).log"
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
        # Add the path to the array for zipping later
        $FilesCreated.Add($_)
    }
}

# Create archive will all the files
$FilesCreated | Compress-Archive -DestinationPath $ZipFile

# Remove the temp files
$FilesCreated | Remove-Item -Force

$ZipFile