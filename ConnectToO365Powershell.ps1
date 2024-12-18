$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication basic -AllowRedirection
Import-PSSession $Session

Connect-MsolService -Credential $LiveCred

$LiveCred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Kerberos -AllowRedirection
Import-PSSession $Session 


Get-ExecutiogetnPolicy