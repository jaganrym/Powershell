# Pulls the File Folder information from mentioned folder and send the report to intended recipients.

$report = @()
$now = Get-Date
$myDir = "D:\Output"
$Server = Hostname


#$FileFolderinfo = $(Get-Childitem -path  "D:\U8SOFT" | Select-Object Name,FullName,LastAccessTime,LastWriteTime,@{Name="Size in MBytes";Expression={ "{0:N0}" -f ($_.Length) /1024 }})
$FileFolderinfo = $(Get-Childitem -path  "D:\U8SOFT" | Select-Object Name,FullName,LastAccessTime,LastWriteTime,@{Name="Size";Expression={ "{0:N0}" -f ($_.Length) /1024 }})


foreach ($Fi in $FileFolderinfo)
{
    $reportObj = New-Object PSObject
    $reportObj | Add-Member NoteProperty -Name "FileOrFolderName" -Value $Fi.Name
    $reportObj | Add-Member NoteProperty -Name "ServerName" -Value $Server
    $reportObj | Add-Member NoteProperty -Name "ReportRanTime" -Value $now
    $reportObj | Add-Member NoteProperty -Name "Path" -Value $Fi.FullName
    $reportObj | Add-Member NoteProperty -Name "LastAccessTime" -Value $Fi.LastAccessTime
    $reportObj | Add-Member NoteProperty -Name "LastWriteTime" -Value $Fi.LastWriteTime
    $reportObj | Add-Member NoteProperty -Name "Size in MB" -Value $Fi.size
        
    $report += $reportObj

}

$report | Export-CSV -Path $myDir\File-Folder-reports-at-Vital-River-Ufeda.csv -NoTypeInformation -Encoding UTF8

$fromaddress = "ADScripts@crl.com" 
$toaddress = "jmr@crl.com"
$bccaddress = "jmr@crl.com"
$CCaddress = "jmr@crl.com"
$Subject = "File Folder reports at Vital River for Ufida Server -  BeiHqERPApp2 " 
$body = "File Folder reports at Vital River - Server Name - BeiHqERPApp2" 
$attachment = "D:\Output\File-Folder-reports-at-Vital-River-Ufeda.csv"
$smtpserver = "crl-com.mail.protection.outlook.com" 
 
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