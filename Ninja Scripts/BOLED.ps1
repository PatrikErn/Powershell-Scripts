#	uBlock Origin Lite Extensions Deployment aka BOLED
#  	Installs & Enables Ublock Origin Lite on Edge + Chrome
#  	Disable First run Wizard on Edge - Optional


# Define the extension IDs and URLs
$chromeExtensionId = "ddkjiahejlhfcafbddmgiahcphecmpfh"
$edgeExtensionId = "cimighlppcgcoapaliogpjjdehbnofhn"

# Define the registry paths for Chrome and Edge policies
$chromePolicyPath = "HKLM:\Software\Policies\Google\Chrome"
$edgePolicyPath = "HKLM:\Software\Policies\Microsoft\Edge"

# Create the registry keys if they don't exist
if (-not (Test-Path "$chromePolicyPath\ExtensionInstallForcelist")) {
    New-Item -Path "$chromePolicyPath\ExtensionInstallForcelist" -Force
}
if (-not (Test-Path "$edgePolicyPath\ExtensionInstallForcelist")) {
    New-Item -Path "$edgePolicyPath\ExtensionInstallForcelist" -Force
}

# Set the policies to force install the extensions , uncomment to enable
#Set-ItemProperty -Path "$chromePolicyPath\ExtensionInstallForcelist" -Name "1" -Value "$chromeExtensionId;https://clients2.google.com/service/update2/crx"
#Set-ItemProperty -Path "$edgePolicyPath\ExtensionInstallForcelist" -Name "1" -Value "$edgeExtensionId;https://edge.microsoft.com/extensionwebstorebase/v1/crx"

# Disable first run experience for Edge , 
Set-ItemProperty -Path $edgePolicyPath -Name "HideFirstRunExperience" -Value 1
Set-ItemProperty -Path $edgePolicyPath -Name "HideFirstRunShortcut" -Value 1
Write-Output "uBlock Origin Lite has been configured to install and enable automatically in Chrome and Edge, and the first run experience has been disabled."
