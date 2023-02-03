# Listing 2 - Deleting Archived Files
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
    # Load the System.IO.Compression.FileSystem assembly so you can use dot sourcing later
    $AssemblyName = 'System.IO.Compression.FileSystem'
    Add-Type -AssemblyName $AssemblyName | Out-Null

    $OpenZip = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)
    # Get the information on the files inside the zip
    $ZipFileEntries = $OpenZip.Entries

    # Confirm each file to delete has a match in the zip file
    foreach($file in $FilesToDelete){
        $check = $ZipFileEntries | Where-Object{ $_.Name -eq $file.Name -and
            $_.Length -eq $file.Length }
        # If $check does not equal null, you know the file was found and can be deleted
        if($null -ne $check){
            # Add WhatIf to allow for testing without actually deleting the files
            $file | Remove-Item -Force -WhatIf:$WhatIf
        }
        else {
            Write-Error "'$($file.Name)' was not find in '$($ZipFile)'"
        }
    }
}
