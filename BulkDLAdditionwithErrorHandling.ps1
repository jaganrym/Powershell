
$Members = Import-Csv E:\Input\Batch2Members.csv

foreach ($Member in $Members)
{
Try
{
Add-DistributionGroupMember -Identity $member.identity -Member $member.members -ErrorAction Stop  
$grp = $member.identity
$user = $member.members
"$User is added to $Grp," | out-file "E:\Output\MemberAdded.csv" -Append -NoClobber}
catch
{
"$User is not added to $Grp," | out-file "E:\Output\Membersnotadded.csv" -Append -NoClobber
}
}
