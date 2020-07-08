#Delete any old folders in C:\Windows\Temp
$tempZipPath = "C:\Windows\Temp\Snipe-IT.zip"
$tempFolderPath = "C:\Windows\Temp\Snipe-IT"

if (Test-Path $tempZipPath) {
    Remove-Item -Path $tempZipPath
}

if (Test-Path $tempFolderPath) {
    Remove-Item $tempFolderPath -Recurse
}

#Download current scripts from GitHub repo
$webClient = New-Object System.Net.WebClient
$url = 'https://github.com/tmurphyrrts/asset_management/archive/master.zip'
$downloadPath = "C:\Windows\Temp\Snipe-IT.zip"
$webClient.DownloadFile($url,$downloadPath)

#Extract newly-downloaded archive
Expand-Archive -Path $downloadPath -DestinationPath $tempFolderPath

#Log Information
$timestamp = Get-Date -UFormat "%m/%d/%Y %R"
$logPath = "C:\ProgramData\Snipe-IT\ScriptUpdate.log"

#Compare hashes of existing script and newly-downloaded script
$currentScriptPath = "C:\ProgramData\Snipe-IT\Get-AssetInfo.ps1"
$currentScriptHash = (Get-FileHash -Path $currentScriptPath).Hash
$newScriptPath = "C:\Windows\Temp\Snipe-IT\asset_management-master\Get-AssetInfo.ps1"
$newScriptHash = (Get-FileHash -Path $newScriptPath).Hash
if ($newScriptHash -eq $currentScriptHash) {
    #Write to log file
    $logtxt = ($timestamp + ":   New Script and Current script have the same hash ($currentScriptHash)")
    if (!(Test-Path $logPath)) {
        New-Item -path $logPath
        Add-Content -path $logPath -value $logtxt
    } 
    else {
        Add-Content -path $logPath -value $logtxt
    }
} else {
    Remove-Item -Path $currentScriptPath
    $snipeRootPath = "C:\ProgramData\Snipe-IT"
    Move-Item -Path $newScriptPath -Destination $snipeRootPath
    $logtxt = ($timestamp + ":   New Script and Current script have different hash. `r`n   Current script hash: $currentScriptHash`r`n   New script hash: $newScriptHash`r`n   New script has taken place of the old 'current' script.`r`n")
    if (!(Test-Path $logPath)) {
        New-Item -path $logPath
        Add-Content -path $logPath -value $logtxt
    } 
    else {
        Add-Content -path $logPath -value $logtxt
    }
}

