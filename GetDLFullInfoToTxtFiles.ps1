$groups = Get-Content C:\PshInput\ITDLS.txt

foreach($Group in $Groups)
{
Get-DistributionGroup -Id $Group | FL >> C:\PshoutPut\$group.txt
}