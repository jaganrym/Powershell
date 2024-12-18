$groups = Get-Content C:\PshInput\ITDLS.txt

foreach($Group in $Groups)
{
Get-ADGroupMember -Id $Group | select @{Expression={$Group};Label=”Group Name”},samaccountname | Export-CSV C:\PshoutPut\$group.txt -NoTypeInformation
}