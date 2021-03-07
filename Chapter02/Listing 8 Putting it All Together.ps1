# Listing 8 Putting it All Together
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

Function Set-ArchiveFilePath{
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

    if(-not (Test-Path -Path $ZipPath)){
        New-Item -Path $ZipPath -ItemType Directory | Out-Null
        Write-Verbose "Created folder '$ZipPath'"
    }
    
    $ZipName = "$($ZipPrefix)$($Date.ToString('yyyyMMdd')).zip"
    $ZipFile = Join-Path $ZipPath $ZipName
    
    if(Test-Path -Path $ZipFile){
        throw "The file '$ZipFile' already exists"
    }

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

    $AssemblyName = 'System.IO.Compression.FileSystem'
    Add-Type -AssemblyName $AssemblyName | Out-Null
    
    
    $OpenZip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)
    $ZipFileEntries = $OpenZip.Entries

    foreach($file in $FilesToDelete){
        $check = $ZipFileEntries | Where-Object{ $_.Name -eq $file.Name -and
            $_.Length -eq $file.Length }
        if($null -ne $check){
            $file | Remove-Item -Force -WhatIf:$WhatIf
        }
        else {
            Write-Error "'$($file.Name)' was not find in '$($ZipFile)'"
        }
    }
}

$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File | 
    Where-Object{ $_.LastWriteTime -lt $Date}


$ZipParameters = @{
    ZipPath = $ZipPath 
    ZipPrefix = $ZipPrefix 
    Date = $Date
}
$ZipFile = Set-ArchiveFilePath @ZipParameters

$files | Compress-Archive -DestinationPath $ZipFile

Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files