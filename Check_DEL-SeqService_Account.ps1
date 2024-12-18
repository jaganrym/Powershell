################################################################################
#Author: Joshua Colbert
#Date Authored: 30-AUG-2018
#Purpose: Check if DEL-SeqService account is locked out and unlock it
################################################################################


if ((Get-ADUser DEL-SeqService -properties lockedout).lockedout -eq $false) {
    Write-Host "DEL-SeqService is not locked out"
    }
    Else {
    Write-Host "DEL-SeqService is locked out"
    Unlock-ADAccount DEL-SeqService
    Send-MailMessage -to adscripts@crl.com -from CheckQuestAdminAccount@crl.com -subject "Alert - DEL-SeqService in CR was locked out and has been unlocked" -body "run on ent-pr-uad-01<br><br>Alert - DEL-SeqService in CR was locked out and has been unlocked." -bodyashtml -smtpserver smtp.cr.local               
    }