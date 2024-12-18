

Get-ADUser -server 'DEABGDCO12.d400.mh.grp' -SearchBase "OU=Users,dc=d400,dc=mh,DC=GRP" -Filter * -ResultSet
Size 8000 -properties * | Export-Csv c:\Data\EmpData2.csv 



Get-ADUser -server 'DEABGDCO12.d400.mh.grp' -SearchBase "OU=Users,dc=d400,dc=mh,DC=GRP" -Filter * -ResultSet
Size 8000 -properties * | select name,firstname,lastname,mail,employeeID,UserPrincipalName,samaccountname | Export-Csv c:\Data\EmpData2.csv 
