# Listing 6 Adding Functions to Scripts
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

Function Set-ArchiveFilePath {    #A
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

$Date = (Get-Date).AddDays(-$NumberOfDays)
$files = Get-ChildItem -Path $LogPath -File | 
    Where-Object{ $_.LastWriteTime -lt $Date}


$ZipParameters = @{    #B
    ZipPath = $ZipPath 
    ZipPrefix = $ZipPrefix 
    Date = $Date
}
$ZipFile = Set-ArchiveFilePath @ZipParameters    #C

$files | Compress-Archive -DestinationPath $ZipFile

$files | Remove-Item -Force
#A Add function to orginal script
#B Set values for function parameters
#C Replace the oringal command(s) with the call to the function