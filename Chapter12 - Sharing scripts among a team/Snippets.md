# Snippet 1 - Initial configuration of Git and authenticating
```powershell
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
gh auth login –-web
```

# Snippet 2 - Setting default editor to VS Code
```powershell
gh config set editor "code -w"
```

# Snippet 3 - Create a private Gist and open in the web browser
```powershell
gh gist create Get-SystemInfo.ps1 -–web
```
```
- Creating gist Get-SystemInfo.ps1
✓ Created gist Get-SystemInfo.ps1
Opening gist.github.com/2d0f590c7dde480fba8ac0201ce6fe0f in your browser.
```

# Snippet 4 - List all Gists in your profile
```powershell
gh gist list
```
```
0d0188e13b8c1be453cf1  Autounattend.xml    1 file  secret  about 25 days ago
116626205476f1df63fe3  AzureVM-Log4j.ps1   1 file  public  about 7 days ago
a1a9a69c0790d06eb8a53  Get-SystemInfo.ps1  1 file  secret  about 1 month ago
e0a176f34e2384212a3c1  PoshAutomator.ps1   1 file  secret  about 1 month ago
a7e6af4038444ff7db54d  Get-OSData.ps1      1 file  secret  about 1 month ago
ffc62944a5a429375460a  NewDevServer        1 file  secret  about 4 months ago
3aafcd16557f952e58c6f  Out-GridViewCode    1 file  public  about 3 months ago
```

# Snippet 5 - Open a remote Gist in your local editor
```powershell
gh gist edit <Your ID>
```

# Snippet 6 - Create a public Gist
```powershell
gh gist create --public Get-SystemInfo.ps1
```

# Snippet 7 - Import a Gist to your local PowerShell session
```powershell
Invoke-RestMethod -Uri 'The Gist Raw URL'
```
```
# Listing 1 - Get-SystemInfo.ps1
Get-CimInstance -Class Win32_OperatingSystem | 
    Select-Object Caption, InstallDate, ServicePackMajorVersion, 
    OSArchitecture, BootDevice, BuildNumber, CSName, 
    @{l='Total_Memory';e={[math]::Round($_.TotalVisibleMemorySize/1MB)}}
```

# Snippet 8 - Import a Gist to your local PowerShell session and execute it
```powershell
Invoke-Expression (Invoke-RestMethod -Uri 'The Gist Raw URL')
```
```
Caption                 : Microsoft Windows 11 Enterprise
InstallDate             : 10/21/2021 5:09:00 PM
ServicePackMajorVersion : 0
OSArchitecture          : 64-bit
BootDevice              : \Device\HarddiskVolume1
BuildNumber             : 22000
CSName                  : DESKTOP-6VBP512
Total_Memory            : 32
```

# Snippet 9 - Test the PoshAutomator module
```powershell
Import-Module .\PoshAutomator.psd1
Get-SystemInfo
```
```
Caption                 : Microsoft Windows 11 Enterprise
InstallDate             : 10/21/2021 5:09:00 PM
ServicePackMajorVersion : 0
OSArchitecture          : 64-bit
BootDevice              : \Device\HarddiskVolume1
BuildNumber             : 22000
CSName                  : DESKTOP-6VBP512
Total_Memory            : 32
```

# Snippet 10 - Initilize the local repository
```powershell
git init
```
```
Initialized empty Git repository in C:/PoshAutomatorB/.git/
```
# Snippet 11 - Add the files and folder in the current directory to the repository
```powershell
git add .
```

# Snippet 12 - Commit the files and folders
```powershell
git commit -m "first commit"
```
```
[master (root-commit) cf2a211] first commit
 4 files changed, 261 insertions(+)
 create mode 100644 Install-PoshAutomator.ps1
 create mode 100644 PoshAutomator.psd1
 create mode 100644 PoshAutomator.psm1
 create mode 100644 Public/Get-SystemInfo.ps1
```
# Snippet 13 - Create the main branch and save your commit to it
```powershell
git branch -M main
```

# Snippet 14 - Create a private repository on GitHub named PoshAutomator
```powershell
gh repo create PoshAutomator --private --source=. --remote=upstream
```
```
✓ Created repository mdowst/PoshAutomator on GitHub
✓ Added remote https://github.com/mdowst/PoshAutomator.git
```

# Snippet 15 - Attach the local the local repository to the remote repository
```powershell
git remote add origin https://github.com/<yourProfile>/PoshAutomator.git
```

# Snippet 16 - Push the local files to the remote repository in GitHub
```powershell
git push -u origin main
```
```
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Compressing objects: 100% (6/6), done.
Writing objects: 100% (7/7), 3.56 KiB | 3.56 MiB/s, done.
Total 7 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/mdowst/PoshAutomator.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

# Snippet 17 - Reload the Path environment variable
```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

# Snippet 18 - Upload the PoshAutomator install script to a GitHub Gist
```powershell
gh gist create Install-PoshAutomator.ps1 --web
```

# Snippet 19 - Create a new branch named develop
```powershell
git checkout -b develop
```
```
Switched to a new branch 'develop'
```

# Snippet 20 -  Pull all files from the main branch on GitHub to your local branch
```powershell
git pull origin main
```
```
From https://github.com/mdowst/PoshAutomatorB
 * branch            main       -> FETCH_HEAD
Already up to date.
```

# Snippet 21 - Commit your local changes and sync them to GitHub creating a new remote branch
```powershell
git add .
git commit -m "versioned PoshAutomator.psd1"
```
```
[develop 6d3fb8e] versioned PoshAutomator.psd1
 1 file changed, 1 insertion(+), 1 deletion(-)
```

# Snippet 22 - Push your changes to the remote develop branch in GitHub
```powershell
git push origin develop
```
```
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 322 bytes | 322.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
remote:
remote: Create a pull request for 'develop' on GitHub by visiting:
remote:      https://github.com/mdowst/PoshAutomator/pull/new/develop
remote:
To https://github.com/mdowst/PoshAutomator.git
 * [new branch]      develop -> develop
```

# Snippet 23 - Commit your local changes and sync them to GitHub updating the remote branch
```powershell
git checkout develop
git add .
git commit -m "added self-updating to PoshAutomator.psm1"
git push origin develop
```

# Snippet 24 - Create a pull request
```powershell
gh pr create --title "Develop to Main" --body "This is my first pull request"
```
```
? Where should we push the develop' branch? mdowst/PoshAutomator

Creating pull request for develop into main in mdowst/PoshAutomator

Branch 'develop' set up to track remote branch 'develop' from 'upstream'.
Everything up-to-date
https://github.com/mdowst/PoshAutomator/pull/1
```

# Snippet 25 - Install and test the PoshAutomator module from GitHub
```powershell
Invoke-Expression (Invoke-RestMethod -Uri 'Your Gist Raw URL')
Import-Module PoshAutomator
Get-SystemInfo
```

# Snippet 26 - Force the PoshAutomator to reload and pick up any code changes
```powershell
Import-Module PoshAutomator -Force
```

