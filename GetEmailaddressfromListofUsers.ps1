$users = Get-Content "c:\input.txt"
$users | ForEach-Object {Get-ADUser -Identity $_ -properties mail | Select samaccountname,mail} | Export-CSV -path C:\file.csv 