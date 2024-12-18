$groups = Get-Content C:\PshInput\zeroOnemembers.txt

foreach($Group in $Groups)
{
Get-ADGroupMember -Id $Group | select @{Expression={$Group};Label=”Group Name”},samaccountname,type,name | Export-CSV C:\PshoutPut\ZeroOnemembers.csv -Append -NoTypeInformation
}

Get-ADGroupMember -server 'DEABGDCO12.d400.mh.grp' -Id $Group | select @{Expression={$Group};Label=”Group Name”},samaccountname,objectclass,distinguishedName,name | export-csv C:\output\members.csv -NoTypeInformation