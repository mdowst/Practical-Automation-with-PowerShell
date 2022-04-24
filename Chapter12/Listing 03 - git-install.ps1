# Listing 3 - git-install.ps1
param(
    $branch
)
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

# Set the default branch at the user level
git config --global init.defaultBranch $branch