# Hashtable for manufacturer codes and names
# Written by Patrik Ernholdt 2024-11-15
# Inspiration from https://www.gavsto.com/ninja-powershell-script-add-monitors-to-custom-field/ for help with output
$Manufacturer = @{
    "AAC" =    "AcerView";
    "ACR" = "Acer";
    "AOC" = "AOC";
    "AIC" = "AG Neovo";
    "APP" = "Apple Computer";
    "AST" = "AST Research";
    "AUO" = "Asus";
    "BNQ" = "BenQ";
    "CMO" = "Acer";
    "CPL" = "Compal";
    "CPQ" = "Compaq";
    "CPT" = "Chunghwa Pciture Tubes, Ltd.";
    "CTX" = "CTX";
    "DEC" = "DEC";
    "DEL" = "Dell";
    "DPC" = "Delta";
    "DWE" = "Daewoo";
    "EIZ" = "EIZO";
    "ELS" = "ELSA";
    "ENC" = "EIZO";
    "EPI" = "Envision";
    "FCM" = "Funai";
    "FUJ" = "Fujitsu";
    "FUS" = "Fujitsu-Siemens";
    "GSM" = "LG Electronics";
    "GWY" = "Gateway 2000";
    "HEI" = "Hyundai";
    "HIT" = "Hyundai";
    "HSL" = "Hansol";
    "HTC" = "Hitachi/Nissei";
    "HWP" = "HP";
    "IBM" = "IBM";
    "ICL" = "Fujitsu ICL";
    "IVM" = "Iiyama";
    "KDS" = "Korea Data Systems";
    "LEN" = "Lenovo";
    "LGD" = "Asus";
    "LPL" = "Fujitsu";
    "MAX" = "Belinea"; 
    "MEI" = "Panasonic";
    "MEL" = "Mitsubishi Electronics";
    "MS_" = "Panasonic";
    "NAN" = "Nanao";
    "NEC" = "NEC";
    "NOK" = "Nokia Data";
    "NVD" = "Fujitsu";
    "OPT" = "Optoma";
    "PHL" = "Philips";
    "REL" = "Relisys";
    "SAN" = "Samsung";
    "SAM" = "Samsung";
    "SBI" = "Smarttech";
    "SGI" = "SGI";
    "SNY" = "Sony";
    "SRC" = "Shamrock";
    "SUN" = "Sun Microsystems";
    "SEC" = "Hewlett-Packard";
    "TAT" = "Tatung";
    "TOS" = "Toshiba";
    "TSB" = "Toshiba";
    "VSC" = "ViewSonic";
    "ZCM" = "Zenith";
    "UNK" = "Unknown";
    "_YV" = "Fujitsu";
    # Add other manufacturers as needed
   
}

$ComputerName = $env:ComputerName
$Monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID

$ParsedMonitors = ForEach ($Monitor in $Monitors) {
    $ManufacturerCode = [System.Text.Encoding]::ASCII.GetString($Monitor.ManufacturerName).TrimEnd([char]0)
    $ManufacturerName = if ($Manufacturer.ContainsKey($ManufacturerCode)) { $Manufacturer[$ManufacturerCode] } else { $ManufacturerCode }
    $Name = if ($Monitor.UserFriendlyName) { [System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName).TrimEnd([char]0) } else { "Unknown" }
    $Serial = if ($Monitor.SerialNumberID) { [System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID).TrimEnd([char]0) } else { "Unknown" }
    $YearOfManufacture = $Monitor.YearOfManufacture

    # Query WMI for connection input type used
    $QueryConn = Get-CimInstance -Query "Select * from WmiMonitorConnectionParams" -Namespace root\wmi | where {$_.InstanceName -eq $Monitor.InstanceName}
    Switch ($QueryConn.VideoOutputTechnology) {
        -1  {$ConnectionType = "OTHER"}
        0   {$ConnectionType = "HD15 (VGA)"}
        4   {$ConnectionType = "DVI"}
        5   {$ConnectionType = "HDMI"}
        10  {$ConnectionType = "Displayport"}
        15  {$ConnectionType = "Miracast"}
        Default {$ConnectionType = "Notebook or unknown"}
    }

    $FriendlyName = "$ManufacturerName $Name"
    
    "Manufacturer: $ManufacturerName`nModel: $Name`nSerial Number: $Serial`nConnection Type: $ConnectionType`nFriendly Name: $FriendlyName`nYear of Manufacture: $YearOfManufacture`nAttached Computer: $ComputerName`n------------------------`n"
}

# Join the array into a single string with newlines
$MonitorInfoString = $ParsedMonitors -join "`n"

# Output the monitor information to the custom field
Ninja-Property-Set attachedMonitors $MonitorInfoString
