Get-ADGroupMember  -Identity "Enterprise Admins" -Recursive -Server "DCname" 

Get-ADGroupMember -server 'DEABGDCO12.d400.mh.grp'  -identity 'group name' -Recursive | Export-csv C:\grpmemebers.csv