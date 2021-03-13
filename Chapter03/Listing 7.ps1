# Listing 7 - File Watcher Move Item Advanced
param(
    $Source = '.\CH03\Watcher\Source',
    $Destination = '.\CH03\Watcher\Destination'
)

# Add new function to perform file checks if duplicate is found
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

        # they don't all match then create a unique filename with the timestamp
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
    # if the two file matched force an overwrite on the move
    if($FileMatch -eq $true){
        $moveParams.Add('Force',$true)
    }
    Move-Item @moveParams
}

$files = Get-ChildItem -Path $Source

# Sort the files based on created time ensuring files are processed in the order they are received
$sorted = $files | Sort-Object -Property CreationTime

# call your new function for each file found
foreach($file in $sorted){
    Move-ItemAdvanced -File $file -Destination $Destination -Verbose
}
