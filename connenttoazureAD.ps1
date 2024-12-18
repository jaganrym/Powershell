$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication basic -AllowRedirection
Import-PSSession $Session

Connect-MsolService -Credential $LiveCred
Connect-AzureAD

Get-AzureADUserMembership -ObjectId abc6738f-02a9-4948-b9ac-0e1f2244450a
Get-AzureADUser -ObjectId
Get-AzureADGroup -SearchString SP-MS-Employees | GM

