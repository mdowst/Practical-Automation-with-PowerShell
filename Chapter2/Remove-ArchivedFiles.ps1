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
    $ZipFileEntries = [IO.Compression.ZipFile]::OpenRead($ZipFiles).Entries

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

Remove-ArchivedFiles -ZipFile $ZipFile -FilesToDelete $files


