
$mailboxes = Get-Content C:\input\srdmbx.csv

foreach($mbx in $mailboxes)
{
Get-ADPermission -id form_tox  | where {($_.ExtendedRights -like "*Send-As*") -and ($_.IsInherited -eq $false) -and -not ($_.User -like "NT AUTHORITY\SELF") -and -not ($_.user -like "AUTORITE NT\SELF")} | Select Identity,User | Export-Csv -NoTypeInformation C:\Output\MailboxSendAsAccess-LocalExchange.csv

 }