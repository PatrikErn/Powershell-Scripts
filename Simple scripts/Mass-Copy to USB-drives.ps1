# Mass-Copy to USB-drives v1.0
# Made by Patrik Ernholdt

# Description 
# 
# Formats all connected USB-drives for the purpose of making USB-sticks with set content for distrobution
# Work Flow : 
# Clear any Read-Only flags , 
# Formats all USB-connected drives,
# Copy folder and files to the root of all USB-drives
# Sets the Read-Only flag



$Label = 'Yourlabelhere'  # USB Label
$volume = Get-Disk | Where BusType -eq 'USB';
$item ="Path\to\files\*"    # Files to be copied
$Outfile = 'path\to\Workfolder\drives.txt'; # TXT for all drives with some trimming


Write-Host "All USB-drives connected to computer will be erased ,Ctrl-C`" to cancel" -ForegroundColor red -BackgroundColor blue
Start-Sleep -Seconds 10
Write-Host " Unlocking USB-drive for job" -ForegroundColor red -BackgroundColor white
Get-Disk | Where BusType -eq 'USB'| Set-Disk -isReadOnly $false -verbose
# Clean ! will clear any plugged-in USB stick!!
Write-Host " Cleaning and prtioning drives " 
$volume | 
Clear-Disk -RemoveData -Confirm:$true -PassThru -verbose
Start-Sleep -Seconds 20


Write-Host " Create partition primary and format to NTFS " -ForegroundColor red -BackgroundColor white
# Create partition primary and format to NTFS
$volume = Get-Disk | Where BusType -eq 'USB' | 
New-Partition -UseMaximumSize -AssignDriveLetter | 
Format-Volume -FileSystem NTFS -NewFileSystemLabel $Label

# Some trimming and Outputs for 
$wmiquery = 'select * from win32_logicaldisk where drivetype = 2'
$dest = Get-Content $Outfile|? {$_}
Get-WmiObject -namespace root\cimv2 -query  $wmiquery |Select-Object DeviceId | Out-file -FilePath $Outfile
(Get-Content $Outfile |   Select-Object -Skip 3 ) | Set-Content $Outfile
$content = Get-Content $Outfile
$content | Foreach {$_.TrimEnd()} | Set-Content $Outfile

foreach ($destination in $dest) {
    Copy-Item -Path $item -Destination "$destination" -Verbose
}


Write-Host " Locking USB-drives for further editing" -ForegroundColor red -BackgroundColor white
Get-Disk | Where BusType -eq 'USB'| Set-Disk -isReadOnly $true 
