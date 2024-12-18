import-module activedirectory
Get-ADGroupMember -Recursive "Global-Sales-Client Facing Staff" | Get-ADuser -properties  * | Select Name,@{Name="First Name"; Expression = {$_.GivenName}},@{Name="Last Name"; Expression = {$_.Surname}},@{Name="Email Address"; Expression = {$_.mail}},@{Name="Site Location"; Expression = {$_.office}},@{Name="Country"; Expression = {$_.country}},@{Name="Active"; Expression = {$_.Enabled}} | Export-Csv "C:\PshoutPut\Global-Sales-Client Facing Staff1.csv" -NoTypeInformation
#Get-ADGroupMember -Recursive "Global-Sales-Client Facing Staff" | Get-ADuser -properties * | Select Name,@{Name="First Name"; Expression = {$_.GivenName}},@{Name="Last Name"; Expression = {$_.Surname}},@{Name="Email Address"; Expression = {$_.mail}},@{Name="Site Location"; Expression = {$_.office}},@{Name="Country"; Expression = {$_.country},@{Name="Active"; Expression = {$_.Enabled}} | Export-Csv "C:\PshoutPut\Global-Sales-Client Facing Staffactive.csv" -NoTypeInformation
#Get-ADuser cr201659 -properties * | Select Name,@{Name="First Name"; Expression = {$_.GivenName}},@{Name="Last Name"; Expression = {$_.Surname}},@{Name="Email Address"; Expression = {$_.mail}},@{Name="Site Location"; Expression = {$_.office}},@{Name="Country"; Expression = {$_.country}},@{Name="Active"; Expression = {$_.Enabled}} | Export-Csv "C:\PshoutPut\Global-Sales-Client Facing Staffactive.csv" -NoTypeInformation
$fromaddress = "ADScripts@crl.com" 
#$toaddress = "GSCFScriptRecipients@crl.com"
$toaddress = "jmr@crl.com"
$bccaddress = "jmr@crl.com"
#$CCaddress = "Darci.Helbling@crl.com", "ADScripts@crl.com"
$Subject = "Global-Sales-Client Facing Staff Members" 
$body = "Global-Sales-Client Facing Staff Members" 
$attachment = "C:\PshoutPut\Global-Sales-Client Facing Staff.csv"
$smtpserver = "smtp.cr.local" 
 
#################################### 
 
$message = new-object System.Net.Mail.MailMessage 
$message.From = $fromaddress 
$message.To.Add($toaddress) 
$message.CC.Add($CCaddress) 
$message.Bcc.Add($bccaddress) 
$message.IsBodyHtml = $True 
$message.Subject = $Subject 
$attach = new-object Net.Mail.Attachment($attachment) 
$message.Attachments.Add($attach) 
$message.body = $body 
$smtp = new-object Net.Mail.SmtpClient($smtpserver) 
$smtp.Send($message) 
