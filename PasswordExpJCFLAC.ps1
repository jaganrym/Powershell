################################################################################
#Author: Mark Cerra     Date Authored: 02-SEP-2014
#Purpose: Query AD for JCF and LAC, compare their PasswordLastSet
# date and send password reminders to Gus, Tony, Mark if needed.
################################################################################

Function NotifyUsers { param ($users)

		Foreach ($u in $users) {
               $PWD = $u.PasswordLastSet
               $Exp = $pwd.adddays(90)
               $Alert = $Exp - $D
               $Days = $Alert.days
			   $Today = Get-Date
			   $sAMAccountName = $u.sAMAccountName
               $mail = "gus.ochoa@crl.com","anthony.degregorio@crl.com","adscripts@crl.com"
                     
				Write-Host $u
									   
			   If (($Alert.days -eq 25) -or ($Alert.days -eq 15) -or ($Alert.days -lt 8)) {
					  $body = "run on ent-pr-uad-01<br><br>Warning: $sAMAccountName password is going to expire in $Days days.<br><br>Thank you."
                 	  Send-MailMessage -to $mail -from password_expire_warning@crl.com -subject "Warning: Password for $sAMAccountname will expire in $Days days" -body $body -bodyashtml -smtpserver smtp.cr.local
      			   }   
			   Elseif ($Today -gt $Exp) {               
					  $body = "run on ent-pr-uad-o1<br><br>Warning: $sAMAccountName password is passed expiration.<br><br>Thank you."
                 	  Send-MailMessage -to $mail -from password_expire_warning@crl.com -subject "Warning: Password for $sAMAccountname is passed the 90 days expiration." -body $body -bodyashtml -smtpserver smtp.cr.local
                   }
			   Else {
                      Write-host "Password for $sAMAccountname doesn't match a reminder yet - $Exp"
                    } 
	}
}

#Main Process
CLS
import-module ActiveDirectory -ErrorAction SilentlyContinue

$D = Get-Date

$Users = @(get-aduser -Identity JCFOSTER  -Properties * | Select sAMAccountName, PasswordLastSet)
NotifyUsers $users

$Users = @(get-aduser -Identity LCORRENTI -Properties * | Select sAMAccountName, PasswordLastSet)
NotifyUsers $users

# Send an email to Mark Cerra for completion.
$body = "run on ent-pr-uad-01<br><br>JCF or LAC password expiration warning script completed.<br><br>Thank you."
Send-MailMessage -to adscripts@crl.com -from password_expire_reminder@crl.com -subject "Password Reminder Script for JCF Completed." -body $body -bodyashtml -smtpserver smtp.cr.local               