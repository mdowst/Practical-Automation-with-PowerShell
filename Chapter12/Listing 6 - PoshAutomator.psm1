# Listing 6 - PoshAutomator.psm1
# Create a temporary file to capture command outputs
$gitResults = New-TemporaryFile
# Set the default parameters to use when executing the Git command
$Process = @{
	FilePath               = 'git.exe'
	WorkingDirectory       = $PSScriptRoot
	RedirectStandardOutput = $gitResults
	Wait                   = $true
	NoNewWindow            = $true
}
# Get the current branch
$Argument = 'branch --show-current'
Start-Process @Process -ArgumentList $Argument
$content = Get-Content -LiteralPath $gitResults -Raw

# Check if the current branch is main
if($content.Trim() -ne 'main'){
    # Set branch to main
    $Argument = 'checkout main'
    Start-Process @Process -ArgumentList $Argument
}
# Update the metadata for the main branch on GitHub
$Argument = 'fetch'
Start-Process @Process -ArgumentList $Argument
# Compare the local version of main against the remote version
$Argument = 'diff main origin/main --compact-summary'
Start-Process @Process -ArgumentList $Argument
$content = Get-Content -LiteralPath $gitResults -Raw

# If a difference is detected, force the module to download the newest version
if($content){
    Write-Host "A module update was detected. Downloading new code base..."
    $Argument = 'reset origin/main'
    Start-Process @Process -ArgumentList $Argument
    $content = Get-Content -LiteralPath $gitResults
    Write-Host $content
    Write-Host "It is recommended that you reload your PowerShell window."
}

# Delete the temporary file
if(Test-Path $gitResults){
    Remove-Item -Path $gitResults -Force
}

# Get all the ps1 files in the Public folder
$Path = Join-Path $PSScriptRoot 'Public'
$Functions = Get-ChildItem -Path $Path -Filter '*.ps1'

# Loop through each ps1 file
Foreach ($import in $Functions) {
    Try {
        Write-Verbose "dot-sourcing file '$($import.fullname)'"
        # Execute each ps1 file to load the function into memory
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.name)"
    }
}