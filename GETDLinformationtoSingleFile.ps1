$groups = Get-Content C:\PshInput\ITDLS.txt

foreach($Group in $Groups)
{
try
{
Get-DistributionGroup -Id $Group | Select name,displayname,alias,samaccountname,acceptmessagesonlyfrom,grouptype,emailaddresses,grantsendonbehalfto,primarysmtpaddress,RequireSenderAuthenticationEnabled,AcceptMessagesOnlyFromDLMembers,AcceptMessagesOnlyFromSendersOrMembers | out-file C:\PshoutPut\ITDLs.csv -Append -NoTypeInformation
} 
catch 
{
"$Group, NotFound." | out-file "C:\PshoutPut\result.csv" -Append -NoClobber
}
}