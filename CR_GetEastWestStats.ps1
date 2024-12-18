#Get Date global

$start = [datetime]::today.adddays(-1).addhours(+20)
$end = [datetime]::today.addhours(+20)

#Set file location and variable for said file
$GFile = "E:\AutomationJobs\Output\GranteeStats.csv"
$RFile = "E:\AutomationJobs\Output\ResearchStats.csv"
$CFile = "E:\AutomationJobs\Output\CRCanadaStats.csv"

#Connect to Office 365
$username = "newuserscript@charlesriverlabs.onmicrosoft.com"
$pwd = ConvertTo-SecureString -AsPlainText -string "p@ssw0rd" -Force
$livecred = New-Object system.Management.Automation.PSCredential -ArgumentList $username, $PWD
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell/" -Credential $livecred -Authentication Basic -AllowRedirection  
Import-PSSession $session -AllowClobber 

#Get messages
Get-MessageTrace -RecipientAddress granteeorders@crl.com -StartDate $start -EndDate $end -PageSize 5000 | Select Received,SenderAddress,RecipientAddress,Subject | Export-Csv $Gfile -NoTypeInformation

Get-MessageTrace -RecipientAddress researchmodels@crl.com -StartDate $start -EndDate $end -PageSize 5000 | Select Received,SenderAddress,RecipientAddress,Subject | Export-Csv $Rfile -NoTypeInformation

Get-MessageTrace -RecipientAddress crcanadaorders@crl.com -StartDate $start -EndDate $end -PageSize 5000 | Select Received,SenderAddress,RecipientAddress,Subject | Export-Csv $Cfile -NoTypeInformation

Send-MailMessage -to cheryl.zaccardi@crl.com,denise.carpenter@crl.com,Christina.Conceicao@crl.com,ed.curry@crl.com,Amy.Lucas@crl.com,Emily.Giroux@crl.com -from MailStats@crl.com -subject "Mail Stat Granteeorders / ResearchModels / CRCanadaorders" -body "Attached are the Grantee / ResearchModel / CRCanadaOrders Emails.  The timestamps are in UTC time (+5 hours EST)" -smtpserver smtp.cr.local -Attachments $Gfile,$RFile,$Cfile