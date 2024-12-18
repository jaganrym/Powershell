$groups = Get-Content C:\PshInput\onpremiseDLS.txt

foreach($Group in $Groups)
{
Get-DistributionGroupMember $Group  | Measure-Object
}