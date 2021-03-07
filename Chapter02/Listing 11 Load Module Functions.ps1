# Listing 11 Load Module Functions
$Path = Join-Path $PSScriptRoot 'Public'
$Public = Get-ChildItem -Path $Path -Filter '*.ps1'    #A

Foreach ($import in $Public) {    #B
    Try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        . $import.fullname    #C
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}
#A Get all the ps1 files in the Public folder
#B Loop through each ps1 file
#C Execute each ps1 file to load the function into memory