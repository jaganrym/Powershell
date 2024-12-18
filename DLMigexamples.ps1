

Import-Csv "C:\Users\v-9soaway\Desktop\groups.csv" | foreach {New-DistributionGroup -Name $_.name -DisplayName $_.displayname –Alias $_.alias -PrimarySmtpAddress $_.PrimarySmtpAddress -RequireSenderAuthenticationEnabled:([bool]([int] $_.RequireSenderAuthenticationEnabled))} -Enabled:([bool]([int]$_.Enabled ))

Import-Csv “C:\CSG\addmem1.csv” | foreach{Set-distributiongroup -Identity $_.identity -EmailAddress $_.emailaddresses}

Set-Mailbox Angelina -EmailAddress Angelina-Alias02@o365info.com,Angelina-Alias03@o365info.com,SMTP:Angelina-NEW01@o365info.com,X500:

$CSV = Import-CSV "C:\Temp\Distrosx500.csv"

$CSV | foreach {Set-DistributionGroup -identity $_.Name -EmailAddresses @{Add = "X500:$($_.X500)"}}



$groups = Get-Content C:\PshInput\ITDLS.txt
Import-Csv C:\somefile.csv | ForEach-Object{
    $Identity = $_.Identity
    $Primaryemail = $_.Primaryemail
    $Secondemail = $_.Secondemail
    Set-DistributionGroup -Identity $Identity -EmailAddresses SMTP:$primaryemail, smtp:$secondemail
}