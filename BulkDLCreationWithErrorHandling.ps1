$Groups = Import-Csv E:\Input\BatchTestgrpinfo1.csv


foreach ($group in $Groups)
{
Try
{
New-DistributionGroup -Name $group.name -DisplayName $group.displayname –Alias $group.alias -PrimarySmtpAddress $group.PrimarySmtpAddress -RequireSenderAuthenticationEnabled:([bool]([int]$group.RequireSenderAuthenticationEnabled)) -ErrorAction Stop  
$grp = $group.name
"$Grp.name, Created." | out-file "E:\Output\result.csv" -Append -NoClobber}
catch
{
"$Grp, is not Created." | out-file "E:\Output\result.csv" -Append -NoClobber
}
}
