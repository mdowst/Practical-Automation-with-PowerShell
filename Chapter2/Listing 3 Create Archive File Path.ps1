# Listing 3 Create Archive File Path
if(-not (Test-Path -Path $ZipPath)){    #A
    New-Item -Path $ZipPath -ItemType Directory | Out-Null
    Write-Verbose "Created folder '$ZipPath'"
}

$ZipName = "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
$ZipFile = Join-Path $ZipPath $ZipName    #B

if(Test-Path -Path $ZipFile){    #C
    throw "The file '$ZipFile' already exists"
}
#A check if the folder path exists and create it if it doesn't
#B Set the full path of the zip file
#C confirm the file doesn't already exist. Throw a terminating error if it does