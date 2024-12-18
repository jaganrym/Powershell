$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ent-pr-xch-13/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

#step1-  remove remote mailbox
disable-remotemailbox AtlbstnzrTestUser1
disable-remotemailbox CtxlabstnzrTestUser2


Install-Module -Name AzureAD
#install the 64-bit version of the Microsoft Online Services Sign-in Assistant: Microsoft Online Services Sign-in Assistant for IT Professionals RTW. 2. Install the Microsoft Azure Active Directory Module for Windows Powershell with folling steps
Install-Module MSOnline 

$credential = Get-Credential
Connect-AzureAD -Credential $credential
Connect-MsolService -Credential $credential


#step2:- remove msoluser and then from recycling bin 
remove-msoluser –user g_vallieres@charlesriverlabs.com –removefromrecyclebin

remove-msoluser –user g_vallieres@charlesriverlabs.com –removefromrecyclebin

#step3 - Enable/create remote mailbox
enable-remotemailbox g_vallieres –remoteroutingaddress g_vallieres@charlesriverlabs.mail.onmicrosoft.com
