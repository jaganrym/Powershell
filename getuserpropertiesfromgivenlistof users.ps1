$users = Get-Content C:\PshInput\Users.txt
$users | ForEach-Object {Get-ADUser -Identity $_ -properties * -server 'DEABGDCO12.d400.mh.grp' | Select samaccountname,mail,GivenName,city,surname,Department,enabled} | Export-CSV -path C:\pshoutput\userprop.csv
