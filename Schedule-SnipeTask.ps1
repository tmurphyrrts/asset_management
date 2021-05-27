#Script paths
$assetScriptPath = "C:\ProgramData\Snipe-IT\Get-AssetInfo.ps1"
$updateScriptPath = "C:\ProgramData\Snipe-IT\Fetch-SnipeUpdate.ps1"

#Create Snipe-IT folder
$scheduleObject = New-Object -ComObject schedule.service
$scheduleObject.connect()
$rootFolder = $scheduleObject.GetFolder("\")
$rootFolder.CreateFolder("Snipe-IT")

#Trigger and Action for 'Update Asset' task
$assetTrigger = New-ScheduledTaskTrigger -Daily -At 12pm -RandomDelay 04:00:00
$assetAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $assetScriptPath"

#Register 'Update Asset' task
Register-ScheduledTask -TaskName "Update Asset" -Description "Send new asset data to Snipe-IT" -Trigger $assetTrigger -Action $assetAction -User "System" -RunLevel Highest -TaskPath "\Snipe-IT" -Force

#Trigger and Action for 'Check for Updates' task
$updateTrigger = New-ScheduledTaskTrigger -Daily -At 12pm -RandomDelay 04:00:00
$updateAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $updateScriptPath"

#Register 'Check for Updates' task
Register-ScheduledTask -TaskName "Check for Updates" -Description "Check for updated version of script" -Trigger $updateTrigger -Action $updateAction -User "System" -RunLevel Highest -TaskPath "\Snipe-IT" -Force
