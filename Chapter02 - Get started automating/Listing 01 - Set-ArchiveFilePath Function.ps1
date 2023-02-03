﻿# Listing 1 - Set-ArchiveFilePath Function
# Declare the function and set the required parameters.
Function Set-ArchiveFilePath{
    # Declare CmdletBinding and OutputType.
    [CmdletBinding()]
    [OutputType([string])]
    # Define the parameters.
    param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath,

    [Parameter(Mandatory = $true)]
    [string]$ZipPrefix,

    [Parameter(Mandatory = $true)]
    [datetime]$Date
    )

    # Check whether the folder path exists, and create it if it doesn't.
    if(-not (Test-Path -Path $ZipPath)){
        New-Item -Path $ZipPath -ItemType Directory | Out-Null
        # Include verbose output for testing and troubleshooting.
        Write-Verbose "Created folder '$ZipPath'"
    }

    # Create the timestamp based on the date.
    $timeString = $Date.ToString('yyyyMMdd')
    # Create the file name.
    $ZipName = "$($ZipPrefix)$($timeString).zip"
    # Set the full path of the zip file.
    $ZipFile = Join-Path $ZipPath $ZipName

    # Confirm the file doesn't already exist. Throw a terminating error if it does.
    if(Test-Path -Path $ZipFile){
        throw "The file '$ZipFile' already exists"
    }

    # Return the file path to the script.
    $ZipFile
}
