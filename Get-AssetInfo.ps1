Import-Module SnipeitPS

$apikey = Get-Content -Path C:\ProgramData\Snipe-IT\snipeitapikey.txt
$url = Get-Content -Path C:\ProgramData\Snipe-IT\snipeiturl.txt

$serialNumber = (Get-WmiObject -Class win32_bios).SerialNumber #Get machine serial number
$computerName = $env:COMPUTERNAME #Get computer name
$modelno = (Get-WmiObject -Class Win32_ComputerSystem).Model #Get machine model number

$loggedOnUser = Get-WMIObject -class Win32_ComputerSystem | Select-Object -ExpandProperty username #Get logged on user

$OSVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName + " Version " + (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseId #Get Operating system and version number

$internalIP = (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne "Disconnected"}).IPv4Address.IPAddress #Get internal IP address
$externalIP = (Invoke-RestMethod ipinfo.io/ip).Trim() #Get external IP address
$MACAddress = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).MacAddress #Get MAC address

$cpu = ((Get-WmiObject -Class Win32_Processor).Name) -split "\sCPU.*" -replace "\(R\)|\(TM\)" #Get CPU name, remove (R) and (TM) and CPU speed from string
$memory = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory #Get Memory amount
$memoryAmount = (([math]::Ceiling($memory / 1024 / 1024 / 1024).ToString()) + "GB") #Round up to nearest GB

$storage = Get-Volume -DriveLetter C | Select-Object -ExpandProperty Size #Get Storage amount
$storageAmount = ([math]::Ceiling($storage / 1024 / 1024 / 1024)) #Round up to nearest GB

if (($storageAmount -gt 200) -and ($storageAmount -lt 260) ) {
    $storageAmount = "256GB" #If total storage is between 200 and 260GB, set the amount to 256GB
} elseif (($storageAmount -gt 90) -and ($storageAmount -lt 130)) {
    $storageAmount = "128GB" #If total storage is between 90 and 130GB, set the amount to 128GB
} elseif (($storageAmount -gt 460) -and ($storageAmount -lt 520)) {
    $storageAmount = "512GB" #If total storage is between 460 and 520GB, set the amount to 512GB
} elseif (($storageAmount -gt 850) -and ($storageAmount -lt 1030)) {
    $storageAmount = "1TB" #If total storage is between 850 and 1030GB, set the amount to 1TB
} else {
    $storageAmount = $storageAmount.ToString() + "GB" #If storage amount does not fall between above ranges, add GB to the end of the real value
}

#Assign custom fields variables to values
$customFields = @{
    "serial"                            = "$serialNumber"
    "_snipeit_cpu_2"                    = "$cpu"
    "_snipeit_memory_3"                 = "$memoryAmount"
    "_snipeit_storage_4"                = "$storageAmount"
    "_snipeit_operating_system_6"       = "$OSVersion"
    "_snipeit_last_logged_on_user_5"    = "$loggedOnUser"
    "_snipeit_last_known_internal_ip_7" = "$internalIP"
    "_snipeit_last_known_public_ip_8"   = "$externalIP"
    "_snipeit_mac_address_9"            = "$MACAddress"
}

$modelID = (Get-Model -limit 200 -url $url -apikey $apikey | Where-Object {($_.name -like "*$modelno*") -or ($_.model_number -like "*$modelno*")}).id #Get Snipe-IT Model ID based on model number pulled from machine

$snipeAsset = Get-Asset -url $url -apikey $apikey -search $serialNumber #Search for asset in Snipe-IT based on S/N

#If asset does not exist, create new asset
if ([string]::IsNullOrEmpty($snipeAsset)) {
    New-Asset -Name $computerName -Model_id $modelID -Status_id "2" -customfields $customFields -url $url -apikey $apikey #Create new Snipe-IT asset
} else { #If asset already exists, update asset with new information
    Set-Asset -id $snipeAsset.id -Name $computerName -model_id $modelID -status_id $snipeAsset.status_label.id -customfields $customFields -url $url -apikey $apikey #Update existing Snipe-IT asset
}