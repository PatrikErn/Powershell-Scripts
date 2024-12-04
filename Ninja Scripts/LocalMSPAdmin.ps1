# 	Written by Patrik Ernholdt
#	Date: 2024-12-03
# Local MSPAdmin Script
# Add specified local admin and also sets domain admins in Local Administrators group.
# System Language is not a factor since it targets the SID for local group.
# Domain independant , checks for conected domain.
# 

# Variables
$userName = "Loc.AD" # Local User = Set to what you want | 
$password = ConvertTo-SecureString "CHANGEME!" -AsPlainText -Force  # Super strong plain text password here (yes this isn't secure at all)
$SID = "S-1-5-32-544"  # Local Administrators SID
$domainAdminGroup = "Domain Admins" # domainAdminGroup is dynamic
$domainName = "$env:USERDOMAIN"  # You can replace this with the FQDN if necessary


# 		Functions
# Function to check for local account and create it if it doesn't exist
Function LocalMSPAdmin {
    $userExist = (Get-LocalUser).Name -Contains $userName
    if ($userExist) { 
        Write-Host "$userName exists" 
        # Update password and set it to never expire
        Set-LocalUser -Name $userName -Password $password -PasswordNeverExpires $true
    } else {
        Write-Host "$userName does not exist, creating account"
        # Creating the user
        New-LocalUser -Name $userName -Password $password -FullName $userName -Description "WorkStation Administrator" -UserMayNotChangePassword -PasswordNeverExpires
        # Add user to Local Administrators group
        Add-LocalGroupMember -SID $SID -Member $userName
    }
}

# Function to check and install PowerShell 5.1 if not present
Function Install-PS5.1 {
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
        Write-Host "PowerShell 5.1 is not installed. Installing now..."
        $installerPath = "$env:TEMP\Win7AndW2K8R2-KB3191566-x64.msu"
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/1/1/11111111-1111-1111-1111-111111111111/Win7AndW2K8R2-KB3191566-x64.msu" -OutFile $installerPath
        Start-Process -FilePath "wusa.exe" -ArgumentList "$installerPath /quiet /norestart" -Wait
        Write-Host "PowerShell 5.1 installation completed. Please restart the computer and re-run the script."
        exit
    } else {
        Write-Host "PowerShell 5.1 is already installed."
    }
}

# Check and install PowerShell 5.1 if necessary
Install-PS5.1

# Ensure the Microsoft.PowerShell.LocalAccounts module is available and imported
if (-not (Get-Module -ListAvailable -Name Microsoft.PowerShell.LocalAccounts)) {
    Write-Host "Installing Microsoft.PowerShell.LocalAccounts module..."
    Install-Module -Name Microsoft.PowerShell.LocalAccounts -Force -Confirm:$false -ErrorAction SilentlyContinue
}
Import-Module Microsoft.PowerShell.LocalAccounts -ErrorAction SilentlyContinue

# Check if the computer is connected to the domain
if ((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain) {
    try {
        # Add domain admins to local administrators group using Add-LocalGroupMember
        Add-LocalGroupMember -SID 'S-1-5-32-544' -Member "$domainName\$domainAdminGroup"
        Write-Host "Successfully added $domainAdminGroup to local administrators group."
    } catch {
        Write-Host "Failed to add $domainAdminGroup to local administrators group. Error: $_"
    }

    # Call the function to check and create local admin
    LocalMSPAdmin

    # Disable the local administrator account by SID
    Get-LocalUser | Where-Object { $_.SID -like "*-500" } | Disable-LocalUser
} else {
    Write-Output "This computer is not connected to a domain."
}
