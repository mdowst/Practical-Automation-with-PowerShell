# Listing 12 - Get-IsoCredentials
Function Get-IsoCredentials {
    param($ISO)
    
    # Mount the ISO image
    $DiskImage = @{
	    ImagePath = $ISO
	    PassThru  = $true
    }
    $image = Mount-DiskImage @DiskImage

    # Get the new drive letter
    $drive = $image | 
        Get-Volume | 
        Select-Object -ExpandProperty DriveLetter

    # Attempt to find the autounattend.xml in the ISO image
    $ChildItem = @{
        Path   = "$($drive):"
        Filter = "autounattend.xml"
    }
    $AutounattendXml = Get-ChildItem @ChildItem

    # If the autounattend.xml is found, attempt to extract the password
    if ($AutounattendXml) {
        [xml]$Autounattend = Get-Content $AutounattendXML.FullName
        $object = $Autounattend.unattend.settings | 
            Where-Object { $_.pass -eq "oobeSystem" }
        $AdminPass = $object.component.UserAccounts.AdministratorPassword
        if ($AdminPass.PlainText -eq $false) {
            $encodedpassword = $AdminPass.Value
            $base64 = [system.convert]::Frombase64string($encodedpassword)
            $decoded = [system.text.encoding]::Unicode.GetString($base64)
            $AutoPass = ($decoded -replace ('AdministratorPassword$', ''))
        }
        else {
            $AutoPass = $AdminPass.Value
        }
    }

    # Dismount the ISO
    $image | Dismount-DiskImage | Out-Null

    # If the password is returned, create a credential object; otherwise, prompt the user for the credentials
    $user = "administrator"
    if ([string]::IsNullOrEmpty($AutoPass)) {
        $parameterHash = @{
            UserName = $user
            Message  = 'Enter administrator password'
        }
        $credential = Get-Credential @parameterHash
    }
    else {
        $pass = ConvertTo-SecureString $AutoPass -AsPlainText -Force
        $Object = @{
            TypeName     = 'System.Management.Automation.PSCredential'
            ArgumentList = ( $user , $pass )
        }
        $credential = New-Object @Object
    }

    $credential
}