#Put one server in maintenance mode
$class = Get-SCOMClass -displayname "windows server"
Start-SCOMMaintenanceMode -Instance (Get-SCOMClassInstance -Class $class | Where-Object {$_.DisplayName -like "*myserver*"}) -endtime (get-date).AddMinutes(10) -Reason "PlannedOther" -Comment "In maintenance mode"


#Put a group of computers in maintenance mode
Get-SCOMGroup "Windows Server 2012 R2 Full Computer Group" | Get-SCOMClassInstance | Start-SCOMMaintenanceMode -EndTime (get-date).AddMinutes(10) -Comment "Maintenance on the way" -Reason "plannedother"


#Start a maintenance schedule..  kind of... Without setting the time it will start. 
#In short get all computers/objects in the schedule and start maintenance mode on them.
Get-SCOMMaintenanceScheduleList | Where-Object {$_.schedulename -eq "my schedule"} | ForEach-Object {$_.scheduleid.guid} | 
Get-SCOMMaintenanceSchedule | select monitoringobjects -ExpandProperty monitoringobjects | Get-SCOMClassInstance | 
Start-SCOMMaintenanceMode -EndTime (get-date).AddMinutes(10) -Reason "plannedother" -Comment "Maintenance window"
