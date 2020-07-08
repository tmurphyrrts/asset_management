#Delete any old folders in C:\Windows\Temp
$tempZipPath = "C:\Windows\Temp\Snipe-IT.zip"
$tempFolderPath = "C:\Windows\Temp\Snipe-IT"

if (Test-Path $tempZipPath) {
    Remove-Item -Path $tempZipPath
}

if (Test-Path $tempFolderPath) {
    Remove-Item $tempFolderPath -Recurse
}

#Log Information
$timestamp = Get-Date -UFormat "%m/%d/%Y %R"
$logPath = "C:\ProgramData\Snipe-IT\ScriptUpdate.log"

#Download current scripts from GitHub repo
$webClient = New-Object System.Net.WebClient
$url = 'https://github.com/tmurphyrrts/asset_management/archive/master.zip'
$downloadPath = "C:\Windows\Temp\Snipe-IT.zip"
$webClient.DownloadFile($url,$downloadPath)
$logtxt = ($timestamp + ":  Downloaded latest script from $url to $downloadPath")
if (!(Test-Path $logPath)) {
    New-Item -path $logPath
    Add-Content -path $logPath -value $logtxt
} 
else {
    Add-Content -path $logPath -value $logtxt
}

#Extract newly-downloaded archive
Expand-Archive -Path $downloadPath -DestinationPath $tempFolderPath
$logtxt = ($timestamp + ":  Extracted scripts from $downloadPath to $tempFolderPath")
Add-Content -path $logPath -value $logtxt

#Remove current script
$scriptPath = "C:\ProgramData\Snipe-IT\Get-AssetInfo.ps1"
Remove-Item -Path $scriptPath
$logtxt = ($timestamp + ":  Deleted script from $scriptPath")
Add-Content -path $logPath -value $logtxt

#Move newly-downloaded script to proper location
$newScriptPath = "C:\Windows\Temp\Snipe-IT\asset_management-master\Get-AssetInfo.ps1"
Move-Item -Path $newScriptPath -Destination $snipeRootPath
$logtxt = ($timestamp + ":  Moved new script from $newScriptPath to $scriptPath")
Add-Content -path $logPath -value $logtxt