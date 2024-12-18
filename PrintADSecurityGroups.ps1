################################################################################
#Author: Joshua Colbert
#Date Authored: 30-AUG-2018
#Purpose: Send High Level Group Membership Email
################################################################################

$when = Get-Date
$Groups = "Schema Admins", "Enterprise Admins", "Domain Admins", "Administrators"
$outfile = "E:\AutomationJobs\Output\PrintADSecurity.txt"
"ACTIVE DIRECTORY SECURITY GROUPS REVIEW" | Out-File $outfile
"$when" | Out-File $outfile -Append

foreach ($group in $groups) {
    echo " " | Out-File $outfile -Append
    echo "----------------------------------------------------" | Out-File $outfile -Append
    echo "Members in $group" | Out-File $outfile -Append
    echo "----------------------------------------------------" | Out-File $outfile -Append
    Get-ADGroupMember $group | select @{l="group name";e={"$group"}}, name, samaccountname | Out-File $outfile -Append
    $total = (Get-ADGroupMember $Group).count
    echo "**$total members in $group**" | Out-File $outfile -Append
    echo " " | Out-File $outfile -Append
}

$when = Get-Date
Send-MailMessage -To "adscripts@crl.com", "IT-ActiveDirectory@crl.com" -From "PrintADSecurityGroups@crl.com" -Subject "Monthly AD Security Group Listing - $when" -Body "Run on ENT-PR-UAD-01<br><br>Monthly AD Security Group Listing" -BodyAsHtml -Attachments $outfile -SmtpServer smtp.cr.local