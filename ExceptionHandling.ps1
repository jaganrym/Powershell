#------------         Erroraction example     -----------------------------------
#Erroraction switch termiates the further execution in case of error in the command 
#You can also set the default action of all errors to stop by setting the variable $ErrorActionPreference to “stop”

$ErrorActionPreference = stop 
$UpdatedCoolList = Get-Content \\FileShare\Location\CoolPeople.csv 
Write-host $error[0] -BackgroundColor DarkCyan -ForegroundColor red 

$UpdatedCoolList = Get-Content \\FileShare\Location\CoolPeople.csv 
if Error[0] 
Write-host $error[0] -BackgroundColor DarkCyan -ForegroundColor DarkBlue
Write-Host hello 


