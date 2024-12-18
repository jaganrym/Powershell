$comps = Get-Content "C:\PshInput\scomagents.txt"
$Comps | ForEach-Object {Get-ADcomputer -Identity $_ -properties Name, operatingSystem | Select name,operatingSystem} | Export-CSV -path C:\pshoutput\serverplusOS.csv
