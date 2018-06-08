 $User = (get-wmiobject Win32_ComputerSystem).UserName.Split('\')[1]
 $G = "\\Shared\Folder" 
 $U = "\\User_Folder\$User"

(New-Object -Com WScript.Network).MapNetworkDrive("G:" , "$G")
(New-Object -Com WScript.Network).MapNetworkDrive("U:" , "$U") 

