$scriptPath = "C:\ProgramData\Snipe-IT\Get-AssetInfo.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 11am -RandomDelay 00:00:30
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $scriptPath"
Register-ScheduledTask -TaskName "Send asset info to Snipe-IT" -Trigger $trigger -Action $action -RunLevel Highest -Force