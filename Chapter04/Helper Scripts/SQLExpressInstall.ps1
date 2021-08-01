#Requires -RunAsAdministrator

Write-Host "Execute the initial machine setup to download source code and setup PowerShell 7"
Set-ExecutionPolicy Bypass -Scope Process -Force; 
$SetupScript = 'https://raw.githubusercontent.com/mdowst/Practical-Automation-with-PowerShell/main/LabSetup/DevelopmentMachineSetup.ps1'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($SetupScript))

Write-Host "Starting SQL Express install and setup"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
$listInstalls = choco list --local-only
if($listInstalls | Where-Object{ $_ -like 'sql-server-express*' }){
    Write-Host "SQL Server Express is already installed"
}
else{
    Write-Host "Install SQL Server Express (this may take a few minutes)"
    choco install sql-server-express -y
}

Write-Host "Load SQL Server PowerShell Module"
try{
    Import-Module sqlps -ErrorAction Stop
}
catch{
    $SQLPath = Join-Path ${env:ProgramFiles(x86)} 'Microsoft SQL Server'
    if(-not(Test-Path $SQLPath)){
        throw "Unable to find SQL install path"
    }
    $sqlps = Get-ChildItem $SQLPath -Recurse -Filter 'sqlps.psd1' | Sort-Object LastWriteTime |
        Select-Object -ExpandProperty FullName -Last 1
    if([string]::IsNullOrEmpty($sqlps)){
        throw "Unable to find SQLPS module path"
    }
    Import-Module $sqlps -ErrorAction Stop
}

Write-Host "Enable mixed login"
$SetLoginMixed = "EXECUTE master..xp_instance_regwrite 'HKEY_LOCAL_MACHINE','Software\Microsoft\MSSQLServer\MSSQLServer\','LoginMode','REG_DWORD', 2"
Invoke-Sqlcmd -Query $SetLoginMixed -ServerInstance "$($env:COMPUTERNAME)\SQLEXPRESS"

# Enable TCP and Named Pipes
Write-Host "Enable TCP and Named Pipes"
$smo = 'Microsoft.SqlServer.Management.Smo.'  
$wmi = new-object ($smo + 'Wmi.ManagedComputer')

# Enable the TCP protocol on the default instance
$uri = "ManagedComputer[@Name='$($env:COMPUTERNAME)']/ ServerInstance[@Name='SQLEXPRESS']/ServerProtocol[@Name='Tcp']"  
$Tcp = $wmi.GetSmoObject($uri)  
$Tcp.IsEnabled = $true  
$Tcp.Alter()

# Enable the named pipes protocol for the default instance.  
$uri = "ManagedComputer[@Name='$($env:COMPUTERNAME)']/ ServerInstance[@Name='SQLEXPRESS']/ServerProtocol[@Name='Np']"  
$Np = $wmi.GetSmoObject($uri)  
$Np.IsEnabled = $true  
$Np.Alter() 

# Enable services
Write-Host "Enable Services"
Set-Service -Name 'SQLAgent$SQLEXPRESS' -StartupType Automatic
Set-Service -Name 'SQLBrowser' -StartupType Automatic

# Start services
Write-Host "Start Services"
#Start-Service -Name 'SQLAgent$SQLEXPRESS'
Start-Service -Name 'SQLBrowser'
Restart-Service -Name 'MSSQL$SQLEXPRESS'

Write-Host "Create PoshTestDB database"
$createDB = @'
IF EXISTS 
   (
     SELECT name FROM master.dbo.sysdatabases 
    WHERE name = N'PoshTestDB'
    )
BEGIN
    SELECT 'Database PoshTestDB already Exist' AS Message
END
ELSE
BEGIN
    CREATE DATABASE [PoshTestDB]
	ALTER DATABASE [PoshTestDB] SET RECOVERY FULL 
    SELECT 'PoshTestDB Database is Created'
END
'@
Invoke-Sqlcmd -Query $createDB -ServerInstance "$($env:COMPUTERNAME)\SQLEXPRESS"

# Create health check account
Write-Host "Create health check account"
$AddSqlUserQuery = @'
USE [master]
IF NOT EXISTS
    (SELECT loginname
     FROM syslogins
     WHERE name = 'sqlhealth')
BEGIN
    CREATE LOGIN [sqlhealth] WITH PASSWORD=N'P@55w9rd', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
END


DECLARE @dbname VARCHAR(50)   
DECLARE @statement NVARCHAR(max)

DECLARE db_cursor CURSOR 
LOCAL FAST_FORWARD
FOR  
SELECT name
FROM MASTER.dbo.sysdatabases

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbname  
WHILE @@FETCH_STATUS = 0  
BEGIN  

SELECT @statement = 'use '+ @dbname +';'+ 
'IF NOT EXISTS
    (SELECT name
     FROM sys.database_principals
     WHERE name = ''sqlhealth'')
BEGIN
    CREATE USER [sqlhealth] FOR LOGIN [sqlhealth]; 
	EXEC sp_addrolemember N''db_datareader'', [sqlhealth];
END'

exec sp_executesql @statement

FETCH NEXT FROM db_cursor INTO @dbname  
END  
CLOSE db_cursor  
DEALLOCATE db_cursor 
'@

Invoke-Sqlcmd -Query $AddSqlUserQuery -ServerInstance "$($env:COMPUTERNAME)\SQLEXPRESS"

$GrantServerState = 'GRANT VIEW SERVER STATE TO sqlhealth'
Invoke-Sqlcmd -Query $GrantServerState -ServerInstance "$($env:COMPUTERNAME)\SQLEXPRESS"

Restart-Service -Name 'MSSQL$SQLEXPRESS'

Write-Host "Install dbatools and Mailozaurr"
$ModuleInstall = 'If(-not(Get-Module {0} -ListAvailable))' +
    '{{Write-Host "Installing {0}...";' +
    '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;' +
    'Set-PSRepository PSGallery -InstallationPolicy Trusted;' +
    'Install-Module {0} -Confirm:$False -Force}}' +
    'else{{Write-Host "{0} is already installed";' +
    'Start-Sleep -Seconds 3}}'

foreach($module in 'dbatools','Mailozaurr'){
    $InstallCommand = $ModuleInstall -f $module
    $Arguments = '-Command "& {' + $InstallCommand +'}"'
    Start-Process -FilePath 'pwsh' -ArgumentList $Arguments -Wait
    Start-Process -FilePath 'powershell' -ArgumentList $Arguments -Wait
}
