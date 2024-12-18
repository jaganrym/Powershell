$mailboxes = Get-Content C:\input\ITDLSbatch2input.csv

foreach($mbx in $mailboxes)
{
Get-MailboxPermission -id $mbx | select name,user accessrights | Export-CSV C:\output\Srdmbxpermissions.csv -NoTypeInformation -Append
}


Get-MailboxPermission -Identity john@contoso.com | Format-List

Get-MailboxPermission form_Tox | GM

