$userlist = Get-Content 'C:\your\userlist.txt'

Get-ADUser -Filter '*' -Properties memberof | Where-Object {
  $userlist -contains $_.SamAccountName
} | ForEach-Object {
  $username = $_
  $groups = $_ | Select-Object -Expand memberof |
            ForEach-Object { (Get-ADGroup $_).Name }
  "{0}: {1}" -f $username, ($groups -join ', ')
} | Out-File 'c:\temp\ss.csv'


$users = Get-Content "D:\users.txt"
foreach ($user in $users) {
 $adjob = (Get-ADUser –Identity $user –Properties MemberOf).MemberOf -replace '^CN=([^,]+),OU=.+$','$1'
write-host "$user , $adjob "
}