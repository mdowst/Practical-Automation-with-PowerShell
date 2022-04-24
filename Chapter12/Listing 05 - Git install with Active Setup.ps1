# Listing 5 - Git install with Active Setup
Function New-ActiveSetup {
    <#
    Code from listing 4
    #>
}

# Install Git
choco install git.install -y

# Set an alias to the full path of git.exe
$alias = @{
    Name = 'git'
    Value = (Join-Path $Env:ProgramFiles 'Git\bin\git.exe')
}
New-Alias @alias -force

# Enable Auto CRLF to LF conversion
git config --system core.autocrlf true

# Set the default branch at the user level using Active Setup
$ScriptBlock = {
    git config --global init.defaultBranch main
    git config --global --list
}

New-ActiveSetup -Name 'Git' -ScriptBlock $ScriptBlock -Version '1.0'
