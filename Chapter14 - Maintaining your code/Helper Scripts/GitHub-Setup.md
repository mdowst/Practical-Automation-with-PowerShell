You will need a GitHub account. A free account will do. 

# Scripted Install
Run the script Install-GitHubCli.ps1 to install Git and GitHub CLI

# Manual Install
Download and install Git from git-scm.com/downloads 
Download and install GitHub CLI from cli.github.com

# Config Git
After the install open a new PowerShell prompt and enter the commands below

```PowerShell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
gh auth login –web
```


Invoke-Expression -Command 'git init'
Invoke-Expression -Command 'git add .'
Invoke-Expression -Command 'git commit -m "initial commit"'
Invoke-Expression -Command "gh repo create ""PoshAutomator.$(Get-Date -Format o)"" --private --source=. --remote=upstream"
$url = Select-String -Path .\.git\config -Pattern 'url' | ForEach-Object{ $_.Line.Split('=')[-1] }
Invoke-Expression -Command "git remote add origin $url"
Invoke-Expression -Command "git push -u origin main"