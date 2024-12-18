$Servers = Get-Content "c:\servers.txt"
$Servers | ForEach-Object {get-smbshare  -CimSession $_ | Select name,path,description,PScomputer Name} | Export-CSV -path C:\shares.csv 
