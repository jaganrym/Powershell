if ((Get-ADUser Pro -properties lockedout).lockedout -eq $false) {
    Write-Host "Pro is not locked out"
    }
    Else {
    Write-Host "Pro is locked out"
    Unlock-ADAccount Pro
    Send-MailMessage -to adscripts@crl.com -from UnlockPRO@crl.com -subject "pro account" -body "run on ent-pr-uad-01<br><br>pro was locked out but has been unlocked" -bodyashtml -SmtpServer smtp.cr.local
    }

