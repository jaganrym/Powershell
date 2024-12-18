import-module activedirectory 
Get-ADOrganizationalUnit -filter * | select Name,DistinguishedName | Export-csv -path C:\ADOrganizationalUnitsexport.csv -NoTypeInformation 

get-aduse