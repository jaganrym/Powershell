Get-ChildItem \\cr.local\SYSVOL\CR.LOCAL\scripts\*.bat | Select-Object Name,@{Expression={Get-Content $_};Label="Content"} | Export-Csv E:\mappings_for_jagan.csv

Get-ChildItem \\cr.local\SYSVOL\CR.LOCAL\scripts\*.bat | ForEach-Object {"`n"+$_.Name;Get-Content $_} 




Get-ChildItem \\trasfile03\c$\FS-TRASFILE03\Trasfile03_A\UserData | select name,pspath 
