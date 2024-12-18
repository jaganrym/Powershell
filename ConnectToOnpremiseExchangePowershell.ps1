$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ent-pr-xch-16/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

Enable-RemoteMailbox evr-cuisine 
Enable-RemoteMailbox "evr-cuisine" -RemoteRoutingAddress "evr-cuisine@charlesriverlabs.mail.onmicrosoft.com"

get-distributiongroup |? {!(get-distributiongroupmember $_.PrimarySMTPAddress).count}


$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ca1svpmbx02.lab.int/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

 get-ADUser -identity CR219534 -Properties *  |select name,ExtensionAttribute1,ExtensionAttribute2,legacyexchangedn

 Enable-DistributionGroup -Identity "IT-SQL Server-DBA Yash" -DomainController ent-pr-adc-40

 Get-DistributionGroup | select name,groupType,RecipientTypeDetails,RecipientType | export-csv leftoverdistgroups.csv