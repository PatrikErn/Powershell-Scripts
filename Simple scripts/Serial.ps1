#Written by Patrik Ernholdt
#Simple script to display your Windows Serial Key and outputs it in a messagebox and then save it to a .txt
# from the scripts run location.

#Path
$selfPath = (Get-Item -Path "." -Verbose).FullName
$dllRelativePath = "........"
$dllAbsolutePath = Join-Path $selfPath $dllRelativePath
#Query and Output
$serial = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey |Out-File  $selfPath\serial.txt 

$Outfile = Get-Content $selfPath\serial.txt
#Messagebox
[System.Windows.MessageBox]::Show("Your Windows OS serial is $Outfile ")
#Display .txt
Invoke-Item $selfPath\serial.txt