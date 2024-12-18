#Get Date global

$start = [datetime]::Today.AddDays(-7)
$end = [datetime]::Today

#Set file location and variable for said file
$File = "E:\AutomationJobs\Output\WLM-APMailStats.csv"

#Connect to Office 365
$username = "newuserscript@charlesriverlabs.onmicrosoft.com"
$pwd = ConvertTo-SecureString -AsPlainText -string "p@ssw0rd" -Force
$livecred = New-Object system.Management.Automation.PSCredential -ArgumentList $username, $PWD
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell/" -Credential $livecred -Authentication Basic -AllowRedirection  
Import-PSSession $session -AllowClobber 

#Get messages
Get-MessageTrace -pagesize 5000 -RecipientAddress accounts.payable@crl.com -StartDate $start -EndDate $end | Select Received,SenderAddress,RecipientAddress,Subject | Export-Csv $file -NoTypeInformation

Send-MailMessage -to adscripts@crl.com,roger.bergeron@crl.com -from WLM-APMailStats@crl.com -subject "WLM-Accounts Payable Mail Stats" -body "Attached are the WLM-Accounts Payable Mailbox stats.  The timestamps are in UTC time (+5 hours EST)" -smtpserver email.crl.com -Attachments $file
