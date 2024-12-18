import-module skypeonlineconnector
$ppl=get-adgroupmember "global employees - it" -recursive
$cred=get-credential dougthompson@charlesriverlabs.onmicrosoft.com

$session=new-csonlinesession -credential $cred
import-pssession $session

$count=0
$ppl|%{
    write-output $count+"`t"+$_.name
    $user=(get-aduser $_.samaccountname).userprincipalname
    grant-csteamsmeetingpolicy -identity $user -policyname "teams are go"
    grant-csteamsmessagingpolicy -identity $user -policyname "teams are go again"
    grant-csteamscallingpolicy -identity $user -policyname "allowcalling"
    grant-csteamsupgradepolicy -identity $user -policyname "islands"
    $count++
}
