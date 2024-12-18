$users=(get-adgroupmember "email retention policy").distinguishedname
$mgrs=(get-adgroupmember "email retention policy - managers").distinguishedname
$mgrs|%{
    $mgr=get-aduser $_ -properties directreports,emailaddress
    $mgrDRs=(get-aduser $_ -properties directreports).directreports
    $msg="Hello "+$mgr.givenname+",<br><br>As a follow-up to the email sent on Monday, 26 Nov, please find below the specific individuals on your team who will have the email retention policy applied to their mailboxes on 1 January 2019:<br><br>"
    $mgrDRs|%{
        if($users -contains $_){
            $user=get-aduser $_
            $msg+=$user.surname+", "+$user.givenname+"<br>"
        }
    }
    $msg+="<br><br>Thank You"
    "message sent to "+$mgr.emailaddress
    send-mailmessage -to ($mgr.emailaddress) -from it.communications@crl.com -subject "Email Retention Policy - Affected Staff" -bodyashtml -body $msg -smtpserver smtp.cr.local -usessl:$false
#    send-mailmessage -to doug.thompson@crl.com -from it.communications@crl.com -subject "Email Retention Policy - Affected Staff" -bodyashtml -body $msg -smtpserver smtp.cr.local -usessl:$false
}


$users=(get-adgroupmember "email retention policy - oqlf").distinguishedname
$mgrs=(get-adgroupmember "email retention policy - managers - oqlf").distinguishedname
$mgrs|%{
    $mgr=get-aduser $_ -properties directreports,emailaddress
    $mgrDRs=(get-aduser $_ -properties directreports).directreports
    $msg="Bonjour "+$mgr.givenname+",<br><br>Suite à l’e-mail envoyé le lundi 26 novembre, veuillez trouver ci-dessous les personnes spécifiques de votre équipe qui se verront appliquer la politique de conservation des e-mails à leur boîtes aux lettres le 1er janvier 2019:<br><br>"
    $mgrDRs|%{
        if($users -contains $_){
            $user=get-aduser $_
            $msg+=$user.surname+", "+$user.givenname+"<br>"
        }
    }
    $msg+="<br><br>Merci"
    "message sent to "+$mgr.emailaddress
    send-mailmessage -to ($mgr.emailaddress) -from it.communications@crl.com -subject "Email Retention Policy - Affected Staff" -bodyashtml -body $msg -smtpserver smtp.cr.local -usessl:$false -encoding ([system.text.encoding]::utf8)
#    send-mailmessage -to doug.thompson@crl.com -from it.communications@crl.com -subject "Email Retention Policy - Affected Staff" -bodyashtml -body $msg -smtpserver smtp.cr.local -usessl:$false -encoding ([system.text.encoding]::utf8)
}
