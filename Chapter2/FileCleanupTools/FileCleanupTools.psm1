$Path = Join-Path $PSScriptRoot 'Public'
$Public = Get-ChildItem -Path $Path -Filter '*.ps1'

Foreach ($import in $Public) {
    Try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}