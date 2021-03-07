# Listing 12 - Action Script with Logging and Error Handling
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$LogPath
)

Function Move-ItemAdvanced {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$File,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    $DestinationFile = Join-Path -Path $Destination -ChildPath $File.Name

    if(Test-Path $DestinationFile){
        $FileMatch = $true
        $check = Get-Item $DestinationFile
        if($check.Length -ne $file.Length){
            $FileMatch = $false
        }
        if($check.LastWriteTime -ne $file.LastWriteTime){
            $FileMatch = $false
        }

        $SrcHash = Get-FileHash -Path $file.FullName
        $DstHash = Get-FileHash -Path $check.FullName
        if($DstHash.Hash -ne $SrcHash.Hash){
            $FileMatch = $false
        }

        if($FileMatch -eq $false){
            $ts = (Get-Date).ToFileTimeUtc()
            $name = $file.BaseName + "_" + $ts + $file.Extension
            $DestinationFile = Join-Path -Path $Destination -ChildPath $name
            Write-Verbose "File will be renamed '$($name)'"
        }
        else{
            Write-Verbose "File will be overwritten"
        }
    }
    else {
        $FileMatch = $false
    }
    
    $moveParams = @{
        Path = $file.FullName
        Destination = $DestinationFile
    }
    
    if($FileMatch -eq $true){
        $moveParams.Add('Force',$true)
    }
    Move-Item @moveParams
}

# Test that the file is found. If not write to log and stop processing
if(-not (Test-Path $FilePath)){
    "$(Get-Date) : File not found" | Out-File $LogPath -Append
    break
}

$file = Get-Item $FilePath

$Arguments = @{
    File = $file
    Destination = $Destination
}

# wrap the move command in a try/catch with error action set to stop
try{
    Move-ItemAdvanced @Arguments -ErrorAction Stop
}
# catch will only run if an error is returned from within the try block
catch{
    # create custom message that includes the file patch and the failure reason captured as $_
    $message = "Error moving '$($FilePath)' : $($_)"
    "$(Get-Date) : $message" | Out-File $LogPath -Append
}
