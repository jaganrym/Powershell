
foreach ($group in $Groups)
{
Try
{
Set-ADGroup -Identity $Group -clear authOrig -ErrorAction Stop
$grp = $group.name
"$Grp.name, Email delivery Restricted removed." | out-file "E:\Output\result.csv" -Append -NoClobber}
catch
{
"could not remove restrict email delivery to $Grp.name." | out-file "E:\Output\result.csv" -Append -NoClobber
}