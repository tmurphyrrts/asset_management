Import-Module SnipeitPS

$apikey = Get-Content -Path C:\Windows\Temp\snipeitapikey.txt
$url = Get-Content -Path C:\Windows\Temp\snipeiturl.txt

$serialNumber = (Get-WmiObject -Class win32_bios).SerialNumber
 
$assetExists = Get-Asset -search $serialNumber -url $url -apikey $apikey
if(([string]::IsNullOrEmpty($assetExists)))
{
    $computerName = $env:COMPUTERNAME #Get computer name
    $modelno = (Get-WmiObject -Class Win32_ComputerSystem).Model #Get machine model number

    $cpu = ((Get-WmiObject -Class Win32_Processor).Name) -split "\sCPU.*" -replace "\(R\)|\(TM\)" #Get CPU name, remove (R) and (TM) and CPU speed from string
    
    $memory = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory #Get Memory amount
    $memoryAmount = (([math]::Ceiling($memory / 1024 / 1024 / 1024).ToString()) + "GB") #Round up to nearest GB
    
    $storage = Get-Volume -DriveLetter C | Select-Object -ExpandProperty Size #Get Storage amount
    $storageAmount = ([math]::Ceiling($storage / 1024 / 1024 / 1024)) #Round up to nearest GB
    if (($storageAmount -gt 200) -and ($storageAmount -lt 260) ) {
        $storageAmount = "256GB" #If total storage is between 200 and 260GB, set the amount to 256GB
    } elseif (($storageAmount -gt 100) -and ($storageAmount -lt 130)) {
        $storageAmount = "128GB" #If total storage is between 100 and 130GB, set the amount to 128GB
    } elseif (($storageAmount -gt 470) -and ($storageAmount -lt 520)) {
        $storageAmount = "512GB" #If total storage is between 470 and 520GB, set the amount to 512GB
    }

    $customFields = @{
        "serial" = "$serialNumber"
        "_snipeit_cpu_2" = "$cpu"
        "_snipeit_memory_3" = "$memoryAmount"
        "_snipeit_storage_4" = "$storageAmount"
    }

    $modelSelection = Get-Model -url $url -apikey $apikey | Where-Object {$_.name -like "*$modelno*"}
 
    New-Asset -Name $computerName -tag $computerName -Model_id $modelSelection.id -Status "2" -customfields $customFields -url $url -apikey $apikey
}
else {
    exit
}