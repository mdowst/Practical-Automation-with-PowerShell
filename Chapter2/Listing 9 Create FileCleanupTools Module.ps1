# Listing 9 Create FileCleanupTools Module
$ModuleName    = 'FileCleanupTools'    #A
$ModuleVersion = "1.0.0.0"    #B
$Author        = "YourNameHere"    #C
$PSVersion     = '7.0'    #D

$ModulePath = Join-Path .\ $ModuleName
New-Item -Path $ModulePath -ItemType Directory    #E
Set-Location $ModulePath
New-Item -Path .\Public -ItemType Directory    #F

$ManifestParameters = @{
    ModuleVersion = $ModuleVersion
    Author        = $Author
    Path          = ".\$($ModuleName).psd1"    #G
    RootModule    = ".\$($ModuleName).psm1"    #H
    PowerShellVersion = $PSVersion
}
New-ModuleManifest @ManifestParameters    #I

Out-File -Path ".\$($ModuleName).psm1" -Encoding utf8    #J
#A The name of your modules
#B The version of your module
#C Your name
#D The minimum PowerShell version this module supports
#E Creates a foler with the same name as the module
#F Creates the public folder for to store your ps1 scripts
#G Sets the path to the psd1 file
#H Sets the path to the psm1 file
#I Creates the module manifest psd1 file with the settings supplied in the parameters
#J Creates a blank psm1 file