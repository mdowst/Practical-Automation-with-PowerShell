# Listing 5 - Create FileCleanupTools Module
# The name of your modules
$ModuleName    = 'FileCleanupTools'
# The version of your module
$ModuleVersion = "1.0.0.0"
# Your name
$Author        = "YourNameHere"
# The minimum PowerShell version this module supports
$PSVersion     = '7.0'

$ModulePath = Join-Path .\ "$($ModuleName)\$($ModuleVersion)"
# Creates a folder with the same name as the module
New-Item -Path $ModulePath -ItemType Directory
Set-Location $ModulePath
# Creates the public folder to store your ps1 scripts
New-Item -Path .\Public -ItemType Directory

$ManifestParameters = @{
    ModuleVersion = $ModuleVersion
    Author        = $Author
    # Sets the path to the psd1 file
    Path          = ".\$($ModuleName).psd1"
    # Sets the path to the psm1 file
    RootModule    = ".\$($ModuleName).psm1"
    PowerShellVersion = $PSVersion
}
# Creates the module manifest psd1 file with the settings supplied in the parameters
New-ModuleManifest @ManifestParameters

# Creates a blank psm1 file
Out-File -Path ".\$($ModuleName).psm1" -Encoding utf8
