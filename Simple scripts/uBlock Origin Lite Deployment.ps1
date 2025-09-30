#	uBlock Origin Lite Deployment aka BOLD
#  	Installs & Enables Ublock Origin Lite on Edge + Chrome
#  	Disable First run Wizard on Edge - Optional
#	Version 2 - Added variable for $edgeExtensionId in $edgeExtensionKeyPath
#		Added visibility to the extension in Edge for end user

# Define the extension IDs 
$chromeExtensionId = "ddkjiahejlhfcafbddmgiahcphecmpfh"
$edgeExtensionId = "cimighlppcgcoapaliogpjjdehbnofhn"

# Create the registry keys if they don't exist
if (-not (Test-Path "$chromePolicyPath\ExtensionInstallForcelist")) {
    New-Item -Path "$chromePolicyPath\ExtensionInstallForcelist" -Force
}
if (-not (Test-Path "$edgePolicyPath\ExtensionInstallForcelist")) {
    New-Item -Path "$edgePolicyPath\ExtensionInstallForcelist" -Force
}

# Define the registry path for the Edge extension settings
$edgeExtensionKeyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\ExtensionSettings\$edgeExtensionId"

# Create the registry key if it doesn't exist
if (-not (Test-Path $edgeExtensionKeyPath)) {
    New-Item -Path $edgeExtensionKeyPath -Force
}

# Set the required values
Set-ItemProperty -Path $edgeExtensionKeyPath -Name "installation_mode" -Value "force_installed"
Set-ItemProperty -Path $edgeExtensionKeyPath -Name "toolbar_state" -Value "force_shown"
Set-ItemProperty -Path $edgeExtensionKeyPath -Name "update_url" -Value "https://edge.microsoft.com/extensionwebstorebase/v1/crx"

# Set the policies to force install the extensions
Set-ItemProperty -Path "$chromePolicyPath\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtensionId;https://clients2.google.com/service/update2/crx"
Set-ItemProperty -Path "$edgePolicyPath\ExtensionInstallForcelist" -Name "1" -Value "$edgeExtensionId;https://edge.microsoft.com/extensionwebstorebase/v1/crx"

# Disable first run experience for Edge
#Set-ItemProperty -Path $edgePolicyPath -Name "HideFirstRunExperience" -Value 1
#Set-ItemProperty -Path $edgePolicyPath -Name "HideFirstRunShortcut" -Value 1
Write-Output "uBlock Origin Lite has been configured to install and enable automatically in Chrome and Edge, and the first run experience has been disabled."
