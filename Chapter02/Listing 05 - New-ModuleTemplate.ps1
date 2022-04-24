# Listing 5 - New-ModuleTemplate
Function New-ModuleTemplate {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$ModuleVersion,
        [Parameter(Mandatory = $true)]
        [string]$Author,
        [Parameter(Mandatory = $true)]
        [string]$PSVersion,
        [Parameter(Mandatory = $false)]
        [string[]]$Functions
    )
    $ModulePath = Join-Path .\ "$($ModuleName)\$($ModuleVersion)"
    # Creates a folder with the same name as the module
    New-Item -Path $ModulePath -ItemType Directory
    Set-Location $ModulePath
    # Creates the public folder to store your ps1 scripts
    New-Item -Path .\Public -ItemType Directory

    $ManifestParameters = @{
        ModuleVersion     = $ModuleVersion
        Author            = $Author
        # Sets the path to the psd1 file
        Path              = ".\$($ModuleName).psd1"
        # Sets the path to the psm1 file
        RootModule        = ".\$($ModuleName).psm1"
        PowerShellVersion = $PSVersion
    }
    # Creates the module manifest psd1 file with the settings supplied in the parameters
    New-ModuleManifest @ManifestParameters

    # Creates a blank psm1 file
    $File = @{
        Path     = ".\$($ModuleName).psm1"
        Encoding = 'utf8'
    }
    Out-File @File

    # Create a blank ps1 for each function
    $Functions | ForEach-Object {
        Out-File -Path ".\Public\$($_).ps1" -Encoding utf8
    }
}

# Set the parameters to pass to the function
$module = @{
    # The name of your module
    ModuleName    = 'FileCleanupTools'
    # The version of your module
    ModuleVersion = "1.0.0.0"
    # Your name
    Author        = "YourNameHere"
    # The minimum PowerShell version this module supports
    PSVersion     = '7.0'
    # The functions to create blank files for in the Public folder
    Functions     =  'Remove-ArchivedFiles',
                     'Set-ArchiveFilePath'
}
# Execute the function to create the new module
New-ModuleTemplate @module