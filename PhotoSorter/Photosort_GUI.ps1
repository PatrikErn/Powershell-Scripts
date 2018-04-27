#Written by Patrik Ernholdt
#Version 1.1
#This script will copy all your photos in a directory and sort them after year and month by meta data.
#If file does not have any creation date in meta data it will sort them after date created on drive instead.
#Warning: If no directory is specified it will try to sort from running directory.
#This is my GUI-version of Photosort.ps1

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Photo Sorting Script"
$objForm.Size = New-Object System.Drawing.Size(400,300) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$objTextBox.Text;$objTextBox2.Text; $objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

#Paths to enter
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Enter file path to sort:"
$objForm.Controls.Add($objLabel) 

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(10,40) 
$objTextBox.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox) 

$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Size(10,60) 
$objLabel2.Size = New-Object System.Drawing.Size(280,20) 
$objLabel2.Text = "Enter destination path:"
$objForm.Controls.Add($objLabel2) 

$objTextBox2 = New-Object System.Windows.Forms.TextBox 
$objTextBox2.Location = New-Object System.Drawing.Size(10,80) 
$objTextBox2.Size = New-Object System.Drawing.Size(260,20) 
$objForm.Controls.Add($objTextBox2) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()


#Photo Copy Script
$srcFolder = $objTextBox.Text   #Working folder
$targetFolder = $objTextBox2.Text  #Destination folder

$files = Get-ChildItem -Path $srcFolder -include *.* –Recurse 

foreach ($file in $files){
	try{
		$path = $file.FullName
		$shell = New-Object -COMObject Shell.Application
		$folder = Split-Path $path
		$file1 = Split-Path $path -Leaf
		$shellfolder = $shell.Namespace($folder)
		$shellfile = $shellfolder.ParseName($file1)
		
		#0..287 | Foreach-Object { '{0} = {1}' -f $_, $shellfolder.GetDetailsOf($null, $_) }
		#32 CameraMaker,#12 DateTaken,#30 CameraModel
		
		$dateTaken = $shellfolder.GetDetailsOf($shellfile, 12)
			
		if([string]::IsNullOrWhiteSpace($dateTaken)) {    
			$parseDate =[datetime]$file.CreationTime  
		} 	
		else{
			#http://stackoverflow.com/questions/25474023/file-date-metadata-not-displaying-properly
			$dateTaken = ($dateTaken -replace [char]8206) -replace [char]8207
			$parseDate =[datetime]::ParseExact($dateTaken,"g",$null)
		}
		
		$year = $parseDate.Year	
		$monthNr = "{0:MM}" -f $parseDate
		$month = "{0:MMMM}" -f $parseDate		
		
		$fileName = "{0:yyyyMMdd-hhmmss}" -f $parseDate
		$fileExtension = $file.Extension
		$fileGuid = [GUID]::NewGuid()	
		
		$directory = $targetFolder + "\" + $year + "\" + "$monthNr - $month"
		if (!(Test-Path $Directory))
		{
			New-Item $directory -type directory | Out-Null
		}
		
		$newFileName = "$fileName-$fileGuid$fileExtension"
		$targetFile = "$directory\$newFileName"
		
		Copy-Item $file.FullName -Destination $targetFile
	}
	catch{
		Write-Host "Could not copy file $file"
	}
} 
Invoke-item $targetFolder