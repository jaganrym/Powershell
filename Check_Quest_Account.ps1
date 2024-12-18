################################################################################
#Author: Joshua Colbert
#Date Authored: 30-AUG-2018
#Purpose: Check if QuestExAdmin account is locked out and unlock it
################################################################################


if ((Get-ADUser QuestExAdmin -properties lockedout).lockedout -eq $false) {
    Write-Host "QuestExAdmin is not locked out"
    }
    Else {
    Write-Host "QuestExAdmin is locked out"
    Unlock-ADAccount QuestExAdmin
    Send-MailMessage -to adscripts@crl.com -from CheckQuestAdminAccount@crl.com -subject "Alert - QuestExAdmin in CR was locked out and has been unlocked" -body "run on ent-pr-uad-01<br><br>Alert - QuestExAdmin in CR was locked out and has been unlocked." -bodyashtml -smtpserver smtp.cr.local               
    }