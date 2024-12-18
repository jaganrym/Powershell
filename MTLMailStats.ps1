#Get Date global

#$start = [datetime]::Today.AddDays(-2).AddHours(+20)  for testing
#$end = [datetime]::Today.AddDays(-1).AddHours(+20)    for testing

$start = [datetime]::today.adddays(-10).addhours(+21)
$end = [datetime]::today.addhours(+21)

#Set file location and variable for said file
$HRFile = "E:\AutomationJobs\Output\MTL-HR.csv"
$PayFile = "E:\AutomationJobs\Output\MTL-Payroll.csv"
$AvaFile = "E:\AutomationJobs\Output\MTL-Avantages-Benefits.csv"

#Connect to Office 365
$username = "newuserscript@charlesriverlabs.onmicrosoft.com"
$pwd = ConvertTo-SecureString -AsPlainText -string "p@ssw0rd" -Force
$livecred = New-Object system.Management.Automation.PSCredential -ArgumentList $username, $PWD
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell/" -Credential $livecred -Authentication Basic -AllowRedirection  
Import-PSSession $session -AllowClobber 

#Get messages
Get-MessageTrace -RecipientAddress MTL-HR@crl.com -StartDate $start -EndDate $end -PageSize 5000 | Select Received,SenderAddress | Export-Csv $HRfile -NoTypeInformation

Get-MessageTrace -RecipientAddress MTL-Payroll@crl.com -StartDate $start -EndDate $end -PageSize 5000| Select Received,SenderAddress | Export-Csv $PayFile -NoTypeInformation

Get-MessageTrace -RecipientAddress MTL-Avantages-Benefits@crl.com -StartDate $start -EndDate $end -PageSize 5000 | Select Received,SenderAddress | Export-Csv $AvaFile -NoTypeInformation

Send-MailMessage -to Rajaa.BnouZaher@crl.com -from MailStats@crl.com -subject "MTL-HR/Payroll/Avantages" -body "Attached are the MTL-HR / MTL-Payroll / MTL-Avantages-Benefits Emails.  The timestamps are in UTC time (+5 hours EST)" -smtpserver smtp.cr.local -Attachments $HRFile,$PayFile,$AvaFile
