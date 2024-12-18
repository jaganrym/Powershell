$Groups = Import-Csv E:\Input\Groups.csv

foreach ($group in $Groups)
{
Try
{
Set-DistributionGroup  -id $group.name  -AcceptMessagesOnlyFrom  "abc@novartis.net" -ErrorAction Stop
$grp = $group.name
"$Grp.name, Email delivery Restricted." | out-file "E:\Output\result.csv" -Append -NoClobber}
catch
{
"could not restrict email delivery to $Grp.name." | out-file "E:\Output\result.csv" -Append -NoClobber
}
}
