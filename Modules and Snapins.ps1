<#Modules and Snap-ins
A module is a package of commands and other items that you can use in Windows PowerShell. After you run the setup program or save the module to disk, 
you can import the module into your Windows PowerShell session and use the commands and items
A Windows PowerShell snap-in (PSSnapin) is a dynamic link library (.dll) that implements cmdlets and providers. 
When you receive a snap-in, you need to install it, and then you can add the cmdlets and providers in the snap-in to your Windows PowerShell session #>

Import-Module activeDirectory # Import Active directory Module

New-ADServiceAccount svc_db_lenel -DisplayName "svc_DB_Lenel" -DNSHostName svc_db_lenel.cr.local

Test-ADServiceAccount svc_db_lenel |fl

install-ADServiceAccount svc_db_lenel

Get-ADGroupMember "TRASFILE03 REPPROD$ RO"

