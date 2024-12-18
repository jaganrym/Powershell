#----------------Operators------------------------#
#Arithemetic Operators +,-,*,/.%(Returns Remeider)
#Comparision operators -eq, -ne,-gt,-ge,-lt,-le
#Logical Operator AND,OR,NOT
#Filter Operators -eq, -ne,-gt,-ge,-lt,-le,-AND,-OR,-NOT,-like,-notlike,-approx 

Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,SamAccountName | select employeeID,SamAccountName | Export-csv c:\Data\Active.csv 
Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,SamAccountName

Get-ADUser -filter {(Enabled -eq "True") -and (name -like "test*") } | select name

Get-ADUser -Filter {(Enabled -eq "True") -and (name -like "hear*") } -SearchBase "OU=users,OU=celsis-IL,OU=Americas,DC=CR,DC=Local" | select Name

Get-ADUser -Filter {(Enabled -eq "True") -and (name -like "hear*") } -SearchBase "OU=users,OU=celsis-IL,OU=Americas,DC=CR,DC=Local" | select Name
get-aduser -filter {(enabled -ne "False") -and (name -like "*andre")} | select name

Get-ADUser -filter {Enabled -eq "True"} -LDAPFilter “(employeeid = 39462)”

Get-ADUser -Filter {(Enabled -eq "True") -and (name -like "jag*")} -Properties employeeid,name | where employeeid -ne $null
Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,name | where employeeid -eq $null | select name,employeeID | Export-csv c:\Activeus2.csv -NoTypeInformation