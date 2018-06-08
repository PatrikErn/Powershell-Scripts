 $User = (get-wmiobject Win32_ComputerSystem).UserName.Split('\')[1]
 $G = "\\192.168.1.28\Gemensam" 
 $U = "\\192.168.1.28\$User"

(New-Object -Com WScript.Network).MapNetworkDrive("G:" , "$G")
(New-Object -Com WScript.Network).MapNetworkDrive("U:" , "$U") 

