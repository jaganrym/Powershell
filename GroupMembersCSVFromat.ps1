 Get-ADGroupMember "AGG-VDI Floating Pool" | select name,email | Export-csv -path C:\Groupmembers.csv -NoTypeInformation
 #get email address and name of members or groups
 Get-ADGroupMember "AGG-VDI Floating Pool" | foreach {get-aduser -Identity $_.distinguishedname -Properties * | select Name,Emailaddress} | Export-csv -path C:\AGG-VDIFPMembers.csv -NoTypeInformation

Get-ADGroupMember "AGG-VDI Floating Pool" | Foreach { get-aduser -Identity $_.samAccountName -Properties * | select name,DisplayName,country,City,Lastlogondate,Emailaddress} | Export-csv -path C:\AGG-VDIFPMembers1.csv -NoTypeInformation
 get-aduser cr201659