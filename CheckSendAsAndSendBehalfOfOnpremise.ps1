
$groups = Get-Content C:\input\ITDLSbatch2input.csv


foreach($Group in $Groups)
{
Get-DistributionGroup -Id $Group | Get-ADPermission | ? { $_.ExtendedRights -like "*send*" } | select @{Expression={$Group};Label=”Group Name”},User,ExtendedRights | Export-CSV C:\output\ITDLBatch2dlsendas.csv -NoTypeInformation -Append
}