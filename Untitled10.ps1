$group = 'RG-000000_CConf_AddAcronisLocalAdminGroup-R'

Get-ADGroupMember -server 'DEABGDCO12.d400.mh.grp' -Id $Group | select @{Expression={$Group};Label=”Group Name”},samaccountname,type,name