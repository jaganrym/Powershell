Remove-Item E:\AutomationJobs\Output\Win10Sites.csv
Remove-Item E:\AutomationJobs\Output\win10All.csv
$Win10Sites = "E:\AutomationJobs\Output\Win10Sites.csv"
$Win10all = "E:\AutomationJobs\Output\win10All.csv"
#Declares Variables
$totalwin10count = 0
$totalothercount = 0 
$conts = "AMERICAS","EMEIA","APAC"
#Lists all sites under each continent
foreach($cont in $conts) {
                          $sites = Get-ADOrganizationalUnit -Filter * -SearchScope OneLevel -SearchBase "ou=$cont,dc=cr,dc=local" | select -ExpandProperty distinguishedname
                        #Gets all OUs named non-regulated or standard from each site
                        foreach ($site in $sites) { 
                                                     $ous = Get-ADOrganizationalUnit -SearchScope OneLevel -Filter "name -like '*non-regulated*' -or name -like '*standard*'" -SearchBase "$site" | select -ExpandProperty distinguishedname
                                                     #resets variables 
                                                     $percentage = 0
                                                     $sitewin10count = 0
                                                     $siteothercount = 0
                                                     $sitecomputers = 0
                                                   #Gets all computers per OU
                                                   $ous | % { $computers = Get-ADComputer -Filter * -SearchBase "$_" -Properties name, operatingsystem, description | select @{l="site";e={$site}}, name, operatingsystem, description
                                                            #Exports computer information to excel
                                                            $computers | Export-Csv $Win10all -Append
                                                            #counts for percentages
                                                            $sitecomputers += ($computers).count
                                                            #If computer is WIN 10 add to WIN10 count, else add to other count
                                                            $computers | % { if($_.operatingsystem -like "*10 Enterprise*" -or $_.operatingsystem -like "*10 entreprise*"){ $sitewin10count=$sitewin10count+1
                                                                                                                          $totalwin10count=$totalwin10count+1 
                                                                                                                        }
                                                                             elseif($_.operatingsystem -like "*mac os x*" -or $_.operatingsystem -like "*server*" -or $_.operatingsystem -like $null){}
                                                                             else{ $siteothercount=$siteothercount+1
                                                                                   $totalothercount=$totalothercount+1 
                                                                                 }
                                                                           }
                                   

                                                            }  
                                                            #Calculate site percentage, create table and export to CSV
                                                            $percentage = ($sitewin10count / $sitecomputers) * 100
                                                            $obj = new-object psobject -Property @{
                                                                                                   Site = $site
                                                                                                   Win10 = $sitewin10count
                                                                                                   Other = $siteothercount
                                                                                                   Complete = [int]$percentage
                                                                                                  }
                                                        $obj | select site,win10,other,complete | Export-Csv $Win10Sites -NoClobber -NoTypeInformation -Append
                                                   }
                        }
    #Calculate CRL totals, email info to team
    $totalcomputers = $totalwin10count + $totalothercount
    $totalpercent = ($totalwin10count / $totalcomputers) *100
    $newtotal = [int]$totalpercent
    Send-MailMessage -to adscripts@crl.com,Ayham.Helwani@crl.com -from Win10Stats@crl.com -subject "Windows 10 Deployment Stats" -BodyAsHtml "$newtotal percent completed <br> $totalwin10count WIN10 computers <br> $totalothercount Other computers" -smtpserver smtp.cr.local -Attachments $Win10Sites,$Win10all