Get-ADgroup -SearchBase "OU=Ashland-OH,OU=Americas,OU=Distribution Lists,dc=CR,DC=LOCAL" -filter * | Set-adGroup -GroupScope Universal 


Get-ADgroup -filter * -Properties * | Select Name