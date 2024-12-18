$EmailFrom = “jmr@crl.com”
$EmailTo = “jagan.rym@gmail.com”  
$Subject = “Test Email from CRL”
$Body = “This is Test email - We are testing as we are seeing many undeliverable form your deomain. Please reply if you recieve it”
$SMTPServer = "smtp.cr.local”
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)   
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)

#$SMTPClient.EnableSsl = $true    
#$SMTPClient.Credentials = New-Object 
#System.Net.NetworkCredential(“customer@yahoo.com”, “password”)    