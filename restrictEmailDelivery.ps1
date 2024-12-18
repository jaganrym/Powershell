$groups = Get-Content C:\input\ITDLSbatch2input.csv

foreach($Group in $Groups)
{
Set-Mailbox $Group -AcceptMessagesOnlyFromDLMembers "it-dcops-offshore@crl.com"
} 
