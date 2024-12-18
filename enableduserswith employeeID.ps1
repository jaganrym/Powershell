Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,name | where employeeid -ne $null | select name,employeeID | Export-csv c:\Activeus2.csv -NoTypeInformation
Get-ADUser -Filter {Enabled -eq "True"} -Properties employeeid,name | where employeeid -ne $null | select name,employeeID | Measure-Object 
