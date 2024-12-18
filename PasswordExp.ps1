################################################################################
#Author: Nick Maddux
#Date Authored: 19-MAR-2013
#Purpose: Query AD for all enabled users, compare their PasswordLastSet
#date and determine if password is going to expire with 2 weeks
#Updated: 29 Apr 2020 - Joshua Colbert - Modified $body text
################################################################################


Function NotifyUsers { param ($users, $p)

		Foreach ($u in $users) {
               $PWD = $u.PasswordLastSet
               $Exp = $pwd.adddays(90)
               $TWEEK = $Exp.adddays(-14)
               $OWEEK = $Exp.adddays(-7)
               $TDays = $Exp.adddays(-3)
			   $TWDays = $Exp.adddays(-2)
               $ODays = $Exp.adddays(-1)
               $sAMAccountName = $u.sAMAccountName
               $mail = $u.mail
			   $bcc = "adscripts@crl.com"
                     
				Write-Host $u
    
                If (($mail -eq "james.c.foster@crl.com") -or ($mail -eq "leeann.correnti@crl.com"))  {
                     $mail = $bcc
                   }
         #$mail = "testPS@crl.com"
									 
            If ($p -eq 0) {   
			   If ($D.date -eq $TWEEK.date){
                  $body="Your password is going to expire in 2 weeks. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
       	  		  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 2 weeks" -body $body -bodyashtml -smtpserver smtp.cr.local
      			   }
               Elseif ($D.date -eq $OWEEK.date) {
				  $body="Your password is going to expire in 1 week. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
				  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 1 week" -body $body -bodyashtml -smtpserver smtp.cr.local                   
               	   }
			   Elseif ($D.date -eq $TDAYS.date) {               
					$body="Your password is going to expire in 3 days. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 3 days" -body $body -bodyashtml -priority High -smtpserver smtp.cr.local                   
                   }
               Elseif ($D.date -eq $TWDays.date) {			   
					$body="Your password is going to expire in 2 days. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 2 days" -body $body -bodyashtml -priority High -smtpserver smtp.cr.local				   
			   	   }
			   Elseif ($D.date -eq $ODAYS.date) {               
					$body="Your password is going to expire TOMORROW. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 1 day" -body $body -bodyashtml -priority High -smtpserver smtp.cr.local
				   }
			   Else {
                      Write-host "Password for $sAMAccountname doesn't match a reminder yet - $Exp"
                  } 
				}
			If ($p -eq 1 ) {
			   If ($D.date -eq $TWEEK.date){
					  $body = "Your password is going to expire in 2 weeks. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
                 	  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 2 weeks" -body $body -bodyashtml -smtpserver smtp.cr.local
      			   }
               Elseif ($D.date -eq $OWEEK.date) {
					  $body = "Your password is going to expire in 1 week. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 1 week" -body $body -bodyashtml -smtpserver smtp.cr.local                   
               	   }
			   Elseif ($D.date -eq $TDAYS.date) {               
					  $body = "Your password is going to expire in 3 Days. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 3 days" -body $body -bodyashtml -priority High -smtpserver smtp.cr.local                   
                   }
               Elseif ($D.date -eq $TWDays.date) {			   
					  $body = "Your password is going to expire in 2 Days. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 2 days" -body $body -bodyashtml -priority High -smtpserver smtp.cr.local				   
			   	   }
			   Elseif ($D.date -eq $ODAYS.date) {               
					  $body = "Your password is going to expire in TOMORROW. Please consider changing it at your earliest convenience.<br><br>You can change your password by going to https://password.criver.com<br>Please Note:  you will also need to update your password on your company phone if you have one.<br><br>Thank you."
					  Send-MailMessage -to $mail -from password_expire_reminder@crl.com -subject "Reminder, password for $sAMAccountname will expire in 1 day" -body $body -bodyashtml -priority High -smtpserver smtp.cr.local
				   }
			   Else {
                      Write-host "Password for $sAMAccountname doesn't match a reminder yet - $Exp"
                  } 
				}
			    }
	}

#Main Process

CLS
import-module ActiveDirectory -ErrorAction SilentlyContinue

$mail = " "
$D = Get-Date
$p = 0

$Users = @(get-aduser -Filter * -SearchBase "OU=Americas,DC=CR,DC=LOCAL"  -Properties * | where {($_.Enabled -eq 'True') -and ($_.EmailAddress -ne $null) -and ($_.PasswordLastSet -ne $null) -and ($_.passwordneverexpires -eq $false)} | sort PasswordLastSet | Select sAMAccountName, PasswordLastSet, Mail)
NotifyUsers $users $p

$Users = @(get-aduser -Filter * -SearchBase "OU=APAC,DC=CR,DC=LOCAL"  -Properties * | where {($_.Enabled -eq 'True') -and ($_.EmailAddress -ne $null) -and ($_.PasswordLastSet -ne $null) -and ($_.passwordneverexpires -eq $false)} | sort PasswordLastSet | Select sAMAccountName, PasswordLastSet, Mail)
NotifyUsers $users $p

$Users = @(get-aduser -Filter * -SearchBase "OU=EMEIA,DC=CR,DC=LOCAL"  -Properties * | where {($_.Enabled -eq 'True') -and ($_.EmailAddress -ne $null) -and ($_.PasswordLastSet -ne $null) -and ($_.passwordneverexpires -eq $false)} | sort PasswordLastSet | Select sAMAccountName, PasswordLastSet, Mail)
NotifyUsers $users $p

#The code below is for sites where we want a different email message to go out.... used for acquisitions
#$Users = @(get-aduser -Filter {(physicalDeliveryOfficeName -ne 'canterbury') -and (physicalDeliveryOfficeName -ne 'saffwald') -and (physicalDeliveryOfficeName -ne 'harlow') -and (physicalDeliveryOfficeName -ne 'leiden') -and (physicalDeliveryOfficeName -ne 'oxford') -and (physicalDeliveryOfficeName -ne 'wellwyn')} -SearchBase "OU=EMEIA,DC=CR,DC=LOCAL"  -Properties * | where {($_.Enabled -eq 'True') -and ($_.EmailAddress -ne $null) -and ($_.PasswordLastSet -ne $null) -and ($_.passwordneverexpires -eq $false)} | sort PasswordLastSet | Select sAMAccountName, PasswordLastSet, Mail)
#NotifyUsers $users $p

#$Users = @(get-aduser -Filter { (physicalDeliveryOfficeName -eq 'canterbury') -or (physicalDeliveryOfficeName -eq 'saffwald') -or (physicalDeliveryOfficeName -eq 'harlow') -or (physicalDeliveryOfficeName -eq 'leiden') -or (physicalDeliveryOfficeName -eq 'oxford') -or (physicalDeliveryOfficeName -eq 'wellwyn')} -SearchBase "OU=EMEIA,DC=CR,DC=LOCAL"  -Properties * | where {($_.Enabled -eq 'True') -and ($_.EmailAddress -ne $null) -and ($_.PasswordLastSet -ne $null) -and ($_.passwordneverexpires -eq $false)} | sort PasswordLastSet | Select sAMAccountName, PasswordLastSet, Mail)
#$p = 1
#NotifyUsers $users $p

# Send an email for completion.
$body = "password expiration reminder script 'PasswordExp' has completed<br><br>run on ent-pr-uad-01"
Send-MailMessage -to adscripts@crl.com -from password_expire_reminder@crl.com -subject "Password Expiration Reminders" -body $body -bodyashtml -smtpserver smtp.cr.local               