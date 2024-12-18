##########################################
# Stale Account Cleanup
# Joshua Colbert 30 Dec 2019
# 
##########################################



##########################################
# Moves computers from Americas, EMIA, APAC to Terminated Standard/Regulated OU if lastlogontimestamp > 74 days (60 days + 14 day variation)
# Updates $compinfo with computer name and status (moved to terminated OU)
##########################################
$computerdaysinactive = 74
$comptime = (get-date).AddDays(-($computerdaysinactive))
New-Item E:\AutomationJobs\Output\stalecomputers.csv -ItemType File -Force
("Americas","EMEIA","APAC") | % { 
            get-adcomputer -SearchBase "ou=$_,dc=CR,dc=LOCAL" -f {lastlogontimestamp -lt $comptime} -properties lastlogontimestamp, lastlogondate | %{
               $compinfo = New-Object psobject -Property @{
                    ComputerName = $_.name
                    DistinguishedName = $_.distinguishedname
                    LastLogonDate = $_.lastlogondate
                    Status = "Moved to termindated OU"
                    }
                $compinfo | Export-Csv -Append -NoTypeInformation -Path E:\AutomationJobs\Output\stalecomputers.csv
                if ($_.distinguishedname -like "*standard*"){
                    Move-ADObject $_.distinguishedname -TargetPath "OU=Terminated STANDARD Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
                }
                else{
                    Move-ADObject $_.distinguishedname -TargetPath "OU=Terminated REGULATED Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
                }
            }
        }




##########################################
# Moves computers from PreStage to Terminated Standard/Regulated OU if lastlogontimestamp > 74 days (60 days + 14 day variation)
# Updates $compinfo with computer name and status (moved to terminated OU)
##########################################
$prestagedaysinactive = 180
$prestageuserlastlogin = 74
$compinactive = (get-date).AddDays(-($prestagedaysinactive))
$userinactive = (Get-Date).AddDays(-($prestageuserlastlogin))
("PreStage-Regulated Win10","PreStage Win10","PreStage Win7") | % {
   get-adcomputer -SearchBase "ou=$_,dc=cr,dc=local" -f {(lastlogontimestamp -lt $userinactive) -and (created -lt $compinactive)} -Properties created,lastlogondate | %{
        $compinfo = New-Object psobject -Property @{
                    ComputerName = $_.name
                    DistinguishedName = $_.distinguishedname
                    LastLogonDate = $_.lastlogondate
                    Status = "Moved to termindated OU"
                    }
                $compinfo | Export-Csv -Append -NoTypeInformation -Path E:\AutomationJobs\Output\stalecomputers.csv
                if ($_.distinguishedname -like "*regulated*"){
                    Move-ADObject $_.distinguishedname -TargetPath "OU=Terminated REGULATED Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
                }
                else{
                    Move-ADObject $_.distinguishedname -TargetPath "OU=Terminated STANDARD Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
                }
        }
}

##########################################
# Disables computers in terminated OU if lastlogontimestamp > 180 days
# Deletes computers in terminated OU if lastlogontimestamp > 180 days
# Updates $compinfo with computer name and status (disabled / deleted)
##########################################
$disabledaysinactive = 180
$deletedaysinactive = 365
$disabletime = (get-date).AddDays(-($disabledaysinactive))
$deletetime = (get-date).AddDays(-($deletedaysinactive))
get-adcomputer -SearchBase "OU=Terminated Computers,DC=CR,DC=LOCAL" -f {(lastlogontimestamp -lt $disabletime) -and (enabled -eq $true)} -Properties lastlogondate | %{
    Set-ADComputer $_.samaccountname -Enabled $false;
                if ($_.distinguishedname -like "*regulated*"){
                    Move-ADObject $_.distinguishedname -TargetPath "OU=Disabled,OU=Terminated REGULATED Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
                }
                else{
                    Move-ADObject $_.distinguishedname -TargetPath "OU=Disabled,OU=Terminated STANDARD Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
                }
    $compinfo = New-Object psobject -Property @{
                    ComputerName = $_.name
                    DistinguishedName = $_.distinguishedname
                    LastLogonDate = $_.lastlogondate
                    Status = "Disabled"
                    }
                $compinfo | Export-Csv -Append -NoTypeInformation -Path E:\AutomationJobs\Output\stalecomputers.csv
}
get-adcomputer -SearchBase "OU=Terminated Computers,DC=CR,DC=LOCAL" -f {(lastlogontimestamp -lt $deletetime) -and (enabled -eq $false)} -Properties lastlogondate | %{
    Remove-ADComputer $_.samaccountname -Confirm:$false
    $compinfo = New-Object psobject -Property @{
                    ComputerName = $_.name
                    DistinguishedName = $_.distinguishedname
                    LastLogonDate = $_.lastlogondate
                    Status = "Deleted"
                    }
                $compinfo | Export-Csv -Append -NoTypeInformation -Path E:\AutomationJobs\Output\stalecomputers.csv
}



##########################################
# Disables all users in Americas, EMEIA, APAC and Admin OU if lastlogontimestamp > 74 days (60 days + 14 day variation)
##########################################
$daysinactive = 74
$time = (get-date).AddDays(-($daysinactive))
$date = get-date -Format ddMMMyyyy

#get all user accounts in the 3 Continent OUs that have not logged in for 73 days, are enabled and do not have extensionattribute7 set
("Americas","EMEIA","APAC","Admin") | % {
    $users = get-aduser -SearchBase "ou=$_,dc=cr,dc=local" -f {(lastlogontimestamp -lt $time) -and (enabled -eq $true) } -properties extensionattribute7 |
    where {$_.extensionattribute7 -ne "NonInteractiveUser"} | select -ExpandProperty samaccountname
        #Disable the AD Account and append description with Stale Account Disabled <date disabled>
        $users | Out-File -FilePath E:\AutomationJobs\Output\staleusers.csv 
        $users | % {
            Disable-ADAccount $_
            $description = get-aduser $_ -Properties description | select -ExpandProperty description
            $newdescription = "Stale Account Disabled $date $description"
            set-aduser $_ -Description $newdescription
        }
    }



##########################################
# Sleeps 30 seconds befour outputing file and before sending message. Can't remember the reason why but it works better this way it seems
# Sends message to Hot Topics Team / Stale Computer and Users channel
##########################################
Start-Sleep -Seconds 30
$outfile1 = "E:\AutomationJobs\Output\stalecomputers.csv"
$outfile2 += "E:\AutomationJobs\Output\staleusers.csv"
Start-Sleep -Seconds 30
$when = Get-Date
Send-MailMessage -To 30b3036d.charlesriverlabs.onmicrosoft.com@amer.teams.ms -From StaleAccounts@crl.com -Subject "Stale Account Cleanup - $when" -Body "To view attachments - please click the attachment menu (...) and select download.<br>If the file is blank, no stale accounts were found<br><br><B>StaleComputers.csv</B> - Moved to terminated OU > 60 days; Disabled > 180 days; Deleted > 365 Days<br>These computers can be moved to the proper site OU if it should remain on the domain.<br>Ensure computer is connected to CR network minimum 2 consecutive hours per month.<br><br><b>StaleUsers.csv</b> - no activity > 60 days<br>Can be enabled after verifying user is an active employee. Please remove (Stale User Disabled) from the description. <br>If user is webmail only user without a CRL device, please submit ticket with username to AD team for exemption from stale account cleanup." -BodyAsHtml -Attachments $outfile1, $outfile2 -SmtpServer smtp.cr.local