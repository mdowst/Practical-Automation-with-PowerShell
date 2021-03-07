# Listing 8 - Action Script
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $true)]
    [string]$Destination
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

# Get the file object
$file = Get-Item $FilePath

$Arguments = @{
    File = $file
    Destination = $Destination
}
# Run the move command
Move-ItemAdvanced @Arguments -Verbose
