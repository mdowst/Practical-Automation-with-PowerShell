param(
    [Parameter(Mandatory = $true)]
    [string]$LogPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPrefix,
    
    [Parameter(Mandatory = $false)]
    [double]$NumberOfDays = 30
)

Function Set-ArchiveFilePath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPrefix,

    [Parameter(Mandatory = $false)]
    [datetime]$Date = (Get-Date)
    )

    # check if the folder path exists and create it if it doesn't
    if(-not (Test-Path -Path $ZipPath)){
        New-Item -Path $ZipPath -ItemType Directory | Out-Null
        Write-Verbose "Created folder '$ZipPath'"
    }
    
    # Set the full path of the zip file
    $ZipFile = Join-Path $ZipPath "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"

    # confirm the file doesn't already exist. Throw a terminating error if it does
    if(Test-Path -Path $ZipFile){
        throw "The file '$ZipFile' already exists"
    }

    # Return the file path
    $ZipFile
}

Function Remove-ArchivedFiles {
    [CmdletBinding()]
    [OutputType()]
    param(
    [Parameter(Mandatory = $true)]
    [string]$ZipFile,

    [Parameter(Mandatory = $true)]
    [object]$FilesToDelete,

    [Parameter(Mandatory = $false)]
    [switch]$WhatIf = $false
    )

    # Load the System.IO.Compression.FileSystem assembly so we can use dot sourcing later
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem' | Out-Null
    
    # Get the information on the files inside the zip
    $ZipFileEntries = [IO.Compression.ZipFile]::OpenRead($ZipFile).Entries

    # Confirm each file to delete has a match in the zip file
    foreach($file in $FilesToDelete){
        $check = $ZipFileEntries | Where-Object{ $_.Name -eq $file.Name -and $_.Length -eq $file.Length }
        # if $check does not equal null then you know the file was found and can be deleted
        if($null -ne $check){
            $file | Remove-Item -Force -WhatIf:$WhatIf
        }
        else {
            Write-Error "Reference for file '$($file.Name)' was not find in the archive '$($ZipFile)'"
        }
    }

}

# Collect the old files and save them to variable
$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File | 
    Where-Object{ $_.LastWriteTime -lt $Date}

# Set the zip file path
$ZipFile = Set-ArchiveFilePath -ZipPath $ZipPath -ZipPrefix $ZipPrefix -Date $Date

# Compress the old files
$files | Compress-Archive -DestinationPath $ZipFile

# Delete the old files
Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files -WhatIf