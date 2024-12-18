$Groups = Import-Csv E:\Input\Groups.csv


foreach ($group in $Groups)
{
Try
{
 Set-ADGroup -Name $group.name -GroupCategory Distribution -ErrorAction Stop
$grp = $group.name
"$Grp.name, converted to Distribution." | out-file "E:\Output\result.csv" -Append -NoClobber}
catch
{
"Cou$Grp.name, could not be converted to Distribution." | out-file "E:\Output\result.csv" -Append -NoClobber
}
}
