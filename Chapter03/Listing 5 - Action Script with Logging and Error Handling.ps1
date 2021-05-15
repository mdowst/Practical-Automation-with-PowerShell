# Listing 5 - Action Script with Logging and Error Handling
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [Parameter(Mandatory = $true)]
    [string]$LogPath
)

# Add new function to perform file checks when a duplicate is found
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

    # check if file exists
    if(Test-Path $DestinationFile){
        $FileMatch = $true
        # get the matching file
        $check = Get-Item $DestinationFile
        if($check.Length -ne $file.Length){
            # check if they have the same length
            $FileMatch = $false
        }
        if($check.LastWriteTime -ne $file.LastWriteTime){
            # check if they have the same last write time
            $FileMatch = $false
        }
        # check if they have the same hash
        $SrcHash = Get-FileHash -Path $file.FullName
        $DstHash = Get-FileHash -Path $check.FullName
        if($DstHash.Hash -ne $SrcHash.Hash){
            $FileMatch = $false
        }

        # If they don't all match, then create a unique filename with the timestamp
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
    # If the two files matched force an overwrite on the move
    if($FileMatch -eq $true){
        $moveParams.Add('Force',$true)
    }
    Move-Item @moveParams -PassThru
}

# Test that the file is found. If not, write to log and stop processing
if(-not (Test-Path $FilePath)){
    "$(Get-Date) : File not found" | Out-File $LogPath -Append
    break
}

# Get the file object
$file = Get-Item $FilePath

$Arguments = @{
    File = $file
    Destination = $Destination
}

# Wrap the move command in a try/catch with an error action set to stop
try{
    $moved = Move-ItemAdvanced @Arguments -ErrorAction Stop
    $message = "Moved '$($FilePath)' to '$($moved.FullName)'"
}
# Catch will only run if an error is returned from within the try block
catch{
    # Create a custom message that includes the file path and the failure reason captured as $_
    $message = "Error moving '$($FilePath)' : $($_)"
}
# write to the log file using the finally block
finally{
    "$(Get-Date) : $message" | Out-File $LogPath -Append
}