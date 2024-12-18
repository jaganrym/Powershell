 Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,SamAccountName | select employeeID,SamAccountName | Export-csv c:\Data\Active.csv 
 Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,SamAccountName

Get-ADUser -filter {(Enabled -eq "True") -and (name -like "test*") } | select name

Get-ADUser -Filter {(Enabled -eq "True") -and (name -like "hear*") } -SearchBase "OU=users,OU=celsis-IL,OU=Americas,DC=CR,DC=Local" | select Name
