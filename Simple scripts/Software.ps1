#Written by Patrik Ernholdt
#Simple Script to list software installed on device
#Displays a .txt with everything and saves it to location from where you run the script. 

#Path
$selfPath = (Get-Item -Path "." -Verbose).FullName
$dllRelativePath = "........"
$dllAbsolutePath = Join-Path $selfPath $dllRelativePath
#Script and Output
  Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize > $selfPath\Software.txt 
#View result 
Invoke-Item $selfPath\Software.txt 
