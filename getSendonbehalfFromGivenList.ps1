$groups = Get-Content C:\input\ITDLSbatch2input.csv

foreach($Group in $Groups)
{
Get-DistributionGroup -id $Group | where {$_.GrantSendOnBehalfTo -ne $null } | select Name,Alias,PrimarySmtpAddress,GrantSendOnBehalfTo | Export-CSV C:\output\itDLBatch2sendonbehalf.csv -NoTypeInformation -Append
}
