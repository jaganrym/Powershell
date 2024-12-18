Get-ADUser -Filter * -SearchBase OU=Users,OU=StoneRidge-NY,OU=Americas,DC=CR,DC=LOCAL | Select-Object Name,SamAccountName | select-object ProfilePath,HomeDirectory,homeDrive | Export-Csv c:\Usernames.csv
 

Get-ADUser -Filter * -Properties ProfilePath,HomeDirectory,homeDrive -SearchBase OU=Users,OU=StoneRidge-NY,OU=Americas,DC=CR,DC=LOCAL | Select-Object Name,SamAccountName,ProfilePath,HomeDirectory,homeDrive | Export-Csv c:\Usernames.csv