#lines 125-128 commented out until Scott E looks at PPS values for "OFFICE" for Harlow, Chesterford, and possibly others

#start logging
$logfile="E:\AutomationJobs\Logs\Update_AD_From_PS.log"
Start-Transcript -path $logfile

#get start time
$start=get-date

#make sure we have AD cmdlets available
import-module ActiveDirectory

#initialization
$expectedfields=31
$sourcefile="E:\AutomationJobs\Input\peoplesoft_ad.txt"
$notfound=@()
$termnotfound=@()
$nomgr=get-aduser nomanager
$totalchanges=0

#read the file and confirm it has correct field count
$sourcerecords=import-csv -delimiter "`t" -path $sourcefile
$total=$sourcerecords.count
$fields=($sourcerecords[0]|get-member).count - 4
if($fields -ne $expectedfields){
    ("The source file, peoplesoft_ad.txt, has $fields fields instead of $expectedfields!`n")|write-output
    ("Processing will terminate...`n")|write-output
}else{
    ("The source file, peoplesoft_ad.txt, has $fields fields as expected.`n")|write-output
    ("Processing will continue...`n")|write-output

#trim off leading and trailing spaces
    for($i=0;$i -lt ($sourcerecords.count);$i++){
        $sourcerecords[$i].c=$sourcerecords[$i].c.trim()                                                                                                 
        $sourcerecords[$i].crlbenefitsLocation=$sourcerecords[$i].crlbenefitsLocation.trim()                                                           
        $sourcerecords[$i].crlBnsCode=$sourcerecords[$i].crlBnsCode.trim()                                                                                              
        $sourcerecords[$i].crlbusinessSegment=$sourcerecords[$i].crlbusinessSegment.trim()                                                                          
        $sourcerecords[$i].crlbusinessUnitDescription=$sourcerecords[$i].crlbusinessUnitDescription.trim()                                               
        $sourcerecords[$i].crlCostCenter=$sourcerecords[$i].crlCostCenter.trim()                                                                                 
        $sourcerecords[$i].crlgeographicLocationCode=$sourcerecords[$i].crlgeographicLocationCode.trim()                                              
        $sourcerecords[$i].crlgeographicLocationDesc=$sourcerecords[$i].crlgeographicLocationDesc.trim()                                     
        $sourcerecords[$i].crlLTIElig=$sourcerecords[$i].crlLTIElig.trim()                                                                                         
        $sourcerecords[$i].department=$sourcerecords[$i].department.trim()                                                                           
        $sourcerecords[$i].departmentNumber=$sourcerecords[$i].departmentNumber.trim()                                                                       
        $sourcerecords[$i].displayNameX=$sourcerecords[$i].displayNameX.trim()                                                                         
        $sourcerecords[$i].distinguishedName=$sourcerecords[$i].distinguishedName.trim().replace("Θ","é")          
        $sourcerecords[$i]."employee Type"=$sourcerecords[$i]."employee Type".trim()                                                           
        $sourcerecords[$i].employeeID=$sourcerecords[$i].employeeID.trim()                                                                                   
        $sourcerecords[$i].givenNameX=$sourcerecords[$i].givenNameX.trim()                                                                                 
        $sourcerecords[$i].initialsX=$sourcerecords[$i].initialsX.trim()                                                                                           
        $sourcerecords[$i].l=$sourcerecords[$i].l.trim().replace("ß","á")                                                                                                     
        $sourcerecords[$i].managerID=$sourcerecords[$i].managerID.trim()                                                                                         
        $sourcerecords[$i].office=$sourcerecords[$i].office.trim()                                                                     
        $sourcerecords[$i].physicalDeliveryOfficeName=$sourcerecords[$i].physicalDeliveryOfficeName.trim().replace("Æ","'")                                               
        $sourcerecords[$i].postalCode=$sourcerecords[$i].postalCode.trim()                                                                                        
        $sourcerecords[$i].preferredLanguage=$sourcerecords[$i].preferredLanguage.trim()                                                                            
        $sourcerecords[$i].snX=$sourcerecords[$i].snX.trim()                                                                                                     
        $sourcerecords[$i].st=$sourcerecords[$i].st.trim()                                                                                                          
        $sourcerecords[$i].streetAddress=$sourcerecords[$i].streetAddress.trim()                                                                  
        $sourcerecords[$i].telephoneNumber=$sourcerecords[$i].telephoneNumber.trim()                                                                    
        $sourcerecords[$i].termDate=$sourcerecords[$i].termDate.trim()                                                                                               
        $sourcerecords[$i].title=$sourcerecords[$i].title.trim()
        $sourcerecords[$i].crlBusinessUnit=$sourcerecords[$i].crlBusinessUnit.trim()
        $sourcerecords[$i]."crl Functional Seg"=$sourcerecords[$i]."crl Functional Seg".trim()
    }

#start processing records
    $sourcerecords|%{
        $dn=$_.distinguishedname
	if($dn -ne $null){
	        ("Processing $dn...")|write-output
#skip admin accounts
        	if(!($dn -match "ou=admin,dc=cr,dc=local")){
	            if(!(($dn -eq "") -or ($dn -eq $null))){
        	        $user=get-aduser -filter {distinguishedname -eq $dn} -properties *
                	if($user -eq $null){
                    	("  user not found...")|write-output
                    	$notfound+=$_
                    	if($_."employee type" -eq "term employee"){
                        	$termnotfound+=$_
	                    }
        	        }else{
                	    if($_."employee type" -eq "term employee"){
                        	("  user will be terminated...")|write-output
                        	if($_.employeeID -eq $user.employeeID){
                            	("    employeeID matches...")|write-output
                            	if($_.description -contains "override"){
                                	("    Override in place, no updates will be made...")
	                            }else{
        	                        ("    no Override in place, proceeding with updates...")|write-output
                	                set-aduser $user -manager $nomgr -replace @{description=("Employee terminated on: "+$_.termdate);employeetype=($_."employee type")}
                        	        ("    user updated...")|write-output
	                            }
        	                }
                	    }else{
                        	$updates=@()
				$site=((($_.distinguishedname) -split ",*..=")[3])+", "+$user.co
	                        if($user.extensionattribute6 -ne $site){
              	                    ("    extensionattribute6 updated from """+$user.extensionattribute6+""" to """+$site+"""")|write-output
                        	    $updates+="extensionattribute6="""+$site+""""
	                        }
	                        if(($_."employee type" -eq "") -or ($_."employee type" -eq $null)){
        	                    if($user.employeetype -ne $null){
                	                ("    employeetype updated from """+$user.employeetype+""" to """"")|write-output
                        	        $updates+="employeetype="""""
	                            }
        	                }elseif($_."employee type" -ne $user.employeetype){
                	            ("    employeetype updated from """+$user.employeetype+""" to """+$_."employee type"+"""")|write-output
                        	    $updates+="employeetype="""+$_."employee type"+""""
	                        }
        	                if(($_.employeeid -eq "") -or ($_.employeeid -eq $null)){
                	            if($user.employeeid -ne $null){
                        	        ("    employeeid updated from """+$user.employeeid+""" to """"")|write-output
                                	$updates+="employeeid="""""
	                            }
        	                }elseif($_.employeeid -ne $user.employeeid){
                	            ("    employeeid updated from """+$user.employeeid+""" to """+$_.employeeid+"""")|write-output
                        	    $updates+="employeeid="""+$_.employeeid+""""
	                        }
        	                if(($_.crlgeographiclocationcode -eq "") -or ($_.crlgeographiclocationcode -eq $null)){
                	            if($user.crlgeographiclocationcode -ne $null){
                        	        ("    crlgeographiclocationcode updated from """+$user.crlgeographiclocationcode+""" to """"")|write-output
                                	$updates+="crlgeographiclocationcode="""""
	                            }
        	                }elseif($_.crlgeographiclocationcode -ne $user.crlgeographiclocationcode){
                	            ("    crlgeographiclocationcode updated from """+$user.crlgeographiclocationcode+""" to """+$_.crlgeographiclocationcode+"""")|write-output
                        	    $updates+="crlgeographiclocationcode="""+$_.crlgeographiclocationcode+""""
	                        }
	                        if(($_.office -eq "") -or ($_.office -eq $null)){
#       	                     if($user.physicaldeliveryofficename -ne $null){
#               	                 ("    physicaldeliveryofficename updated from """+$user.physicaldeliveryofficename+""" to """"")|write-output
#                       	         $updates+="physicaldeliveryofficename="""""
#	                            }
        	                }elseif(("419357","419358") -contains $_.departmentnumber){
                	            if($_.office -ne $user.division){
                        	        ("    physicaldeliveryofficename updated from """+$user.physicaldeliveryofficename+""" to """+$user.division+"""")|write-output
                                	$updates+="physicaldeliveryofficename="""+$user.division+""""
	                            }
        	                }elseif($_.office -ne $user.physicaldeliveryofficename){
                	            ("    physicaldeliveryofficename updated from """+$user.physicaldeliveryofficename+""" to """+$_.office+"""")|write-output
                        	    $updates+="physicaldeliveryofficename="""+$_.office+""""
	                        }
        	                if(($_.crlgeographiclocationdesc -eq "") -or ($_.crlgeographiclocationdesc -eq $null)){
                	            if($user.crlgeographiclocationdesc -ne $null){
                        	        ("    crlgeographiclocationdesc updated from """+$user.crlgeographiclocationdesc+""" to """"")|write-output
                                	$updates+="crlgeographiclocationdesc="""""
	                            }
        	                }elseif($_.crlgeographiclocationdesc -ne $user.crlgeographiclocationdesc){
                	            ("    crlgeographiclocationdesc updated from """+$user.crlgeographiclocationdesc+""" to """+$_.crlgeographiclocationdesc+"""")|write-output
                        	    $updates+="crlgeographiclocationdesc="""+$_.crlgeographiclocationdesc+""""
	                        }
        	                if(($_.streetaddress -eq "") -or ($_.streetaddress -eq $null)){
                	            if($user.streetaddress -ne $null){
                        	        ("    streetaddress updated from """+$user.streetaddress+""" to """"")|write-output
                                	$updates+="streetaddress="""""
	                            }
        	                }elseif($_.streetaddress -ne $user.streetaddress){
                	            ("    streetaddress updated from """+$user.streetaddress+""" to """+$_.streetaddress+"""")|write-output
                        	    $updates+="streetaddress="""+$_.streetaddress+""""
	                        }
        	                if(($_.l -eq "") -or ($_.l -eq $null)){
                	            if($user.l -ne $null){
                        	        ("    l updated from """+$user.l+""" to """"")|write-output
                                	$updates+="l="""""
	                            }
        	                }elseif($_.l -ne $user.l){
                	            ("    l updated from """+$user.l+""" to """+$_.l+"""")|write-output
                        	    $updates+="l="""+$_.l+""""
	                        }
        	                if(($_.st -eq "") -or ($_.st -eq $null)){
                	            if($user.st -ne $null){
                        	        ("    st updated from """+$user.st+""" to """"")|write-output
                                	$updates+="st="""""
	                            }
        	                }elseif($_.st -ne $user.st){
                	            ("    st updated from """+$user.st+""" to """+$_.st+"""")|write-output
                        	    $updates+="st="""+$_.st+""""
	                        }
        	                if(($_.postalcode -eq "") -or ($_.postalcode -eq $null)){
                	            if($user.postalcode -ne $null){
                        	        ("    postalcode updated from """+$user.postalcode+""" to """"")|write-output
                                	$updates+="postalcode="""""
	                            }
        	                }elseif($_.postalcode -ne $user.postalcode){
                	            ("    postalcode updated from """+$user.postalcode+""" to """+$_.postalcode+"""")|write-output
                        	    $updates+="postalcode="""+$_.postalcode+""""
	                        }
        	                if(($_.c -eq "us") -or ($_.c -eq "united states") -or ($_.c -eq "philippines")){
                	            $c="us"
                        	}elseif(($_.c -eq "sco") -or ($_.c -eq "uk") -or ($_.c -eq "united kingdom")){
	                            $c="gb"
        	                }elseif($_.c -eq "canada"){
                	            $c="ca"
                        	}elseif($_.c -eq "italy"){
	                            $c="it"
        	                }elseif($_.c -eq "germany"){
                	            $c="de"
                        	}elseif($_.c -eq "france"){
	                            $c="fr"
        	                }elseif($_.c -eq "spain"){
                	            $c="es"
                        	}elseif($_.c -eq "japan"){
	                            $c="jp"
        	                }elseif($_.c -eq "ireland"){
                	            $c="ie"
                        	}elseif($_.c -eq "india"){
        	                    $c="in"
	                        }elseif($_.c -eq "germany"){
                	            $c="de"
                        	}elseif($_.c -eq "netherlands"){
	                            $c="nl"
        	                }elseif($_.c -eq "china"){
                	            $c="cn"
                        	}elseif($_.c -eq "finland"){
	                            $c="fi"
        	                }elseif($_.c -match "korea"){
                	            $c="kr"
                        	}elseif($_.c -eq "singapore"){
	                            $c="sg"
        	                }elseif($_.c -eq "belgium"){
                	            $c="be"
                        	}elseif($_.c -eq "australia"){
        	                    $c="au"
	                        }elseif($_.c -eq "sweden"){
                	            $c="se"
                        	}elseif($_.c -eq "israel"){
	                            $c="il"
        	                }elseif($_.c -eq "poland"){
                	            $c="pl"
                        	}elseif($_.c -eq "brazil"){
	                            $c="br"
        	                }elseif($_.c -eq "mexico"){
                	            $c="mx"
                        	}else{
	                            $c=$_.c
        	                }
                	        if($c -ne $user.c){
                        	    ("    c updated from """+$user.c+""" to """+$c+"""")|write-output
	                            $updates+="c="""+$c+""""
        	                }
                	        if(($_.crlbenefitslocation -eq "") -or ($_.crlbenefitslocation -eq $null)){
                        	    if($user.crlbenefitslocation -ne $null){
                                	("    crlbenefitslocation updated from """+$user.crlbenefitslocation+""" to """"")|write-output
	                                $updates+="crlbenefitslocation="""""
        	                    }
                	        }elseif($_.crlbenefitslocation -ne $user.crlbenefitslocation){
                        	    ("    crlbenefitslocation updated from """+$user.crlbenefitslocation+""" to """+$_.crlbenefitslocation+"""")|write-output
        	                    $updates+="crlbenefitslocation="""+$_.crlbenefitslocation+""""
	                        }
                	        if(($_.departmentnumber -eq "") -or ($_.departmentnumber -eq $null)){
                        	    if($user.departmentnumber -ne $null){
                                	("    departmentnumber updated from """+$user.departmentnumber+""" to """"")|write-output
	                                $updates+="departmentnumber="""""
        	                    }
                	        }elseif($_.departmentnumber -ne $user.departmentnumber){
                        	    ("    departmentnumber updated from """+$user.departmentnumber+""" to """+$_.departmentnumber+"""")|write-output
	                            $updates+="departmentnumber="""+$_.departmentnumber+""""
        	                }
                	        if(($_.department -eq "") -or ($_.department -eq $null)){
                        	    if($user.department -ne $null){
                                	("    department updated from """+$user.department+""" to """"")|write-output
	                                $updates+="department="""""
        	                    }
                	        }elseif($_.department -ne $user.department){
                        	    ("    department updated from """+$user.department+""" to """+$_.department+"""")|write-output
	                            $updates+="department="""+$_.department+""""
        	                }
                	        if(($_.title -eq "") -or ($_.title -eq $null)){
                        	    if($user.title -ne $null){
                                	("    title updated from """+$user.title+""" to """"")|write-output
        	                        $updates+="title="""""
	                            }
                	        }elseif($_.title -ne $user.title){
                        	    ("    title updated from """+$user.title+""" to """+$_.title+"""")|write-output
	                            $updates+="title="""+$_.title+""""
        	                }
                	        if(($_.crlbusinesssegment -eq "") -or ($_.crlbusinesssegment -eq $null)){
                        	    if($user.crlbusinesssegment -ne $null){
                                	("    crlbusinesssegment updated from """+$user.crlbusinesssegment+""" to """"")|write-output
	                                $updates+="crlbusinesssegment="""""
        	                    }
                	        }elseif($_.crlbusinesssegment -ne $user.crlbusinesssegment){
                        	    ("    crlbusinesssegment updated from """+$user.crlbusinesssegment+""" to """+$_.crlbusinesssegment+"""")|write-output
	                            $updates+="crlbusinesssegment="""+$_.crlbusinesssegment+""""
        	                }
                	        if(($_.crlbusinessunitdescription -eq "") -or ($_.crlbusinessunitdescription -eq $null)){
                        	    if($user.crlbusinessunitdescription -ne $null){
                                	("    crlbusinessunitdescription updated from """+$user.crlbusinessunitdescription+""" to """"")|write-output
	                                $updates+="crlbusinessunitdescription="""""
        	                    }
                	        }elseif($_.crlbusinessunitdescription -ne $user.crlbusinessunitdescription){
                        	    ("    crlbusinessunitdescription updated from """+$user.crlbusinessunitdescription+""" to """+$_.crlbusinessunitdescription+"""")|write-output
	                            $updates+="crlbusinessunitdescription="""+$_.crlbusinessunitdescription+""""
        	                }
                	        if(($_.preferredlanguage -eq "") -or ($_.preferredlanguage -eq $null)){
                        	    if($user.preferredlanguage -ne $null){
                                	("    preferredlanguage updated from """+$user.preferredlanguage+""" to """"")|write-output
	                                $updates+="preferredlanguage="""""
        	                    }
                	        }elseif($_.preferredlanguage -ne $user.preferredlanguage){
                        	    ("    preferredlanguage updated from """+$user.preferredlanguage+""" to """+$_.preferredlanguage+"""")|write-output
	                            $updates+="preferredlanguage="""+$_.preferredlanguage+""""
        	                }
                	        if(($_.telephonenumber -eq "") -or ($_.telephonenumber -eq $null)){
                        	    if($user.telephonenumber -ne $null){
                                	("    telephonenumber updated from """+$user.telephonenumber+""" to """"")|write-output
	                                $updates+="telephonenumber="""""
        	                    }
                	        }elseif($_.telephonenumber -ne $user.telephonenumber){
                        	    ("    telephonenumber updated from """+$user.telephonenumber+""" to """+$_.telephonenumber+"""")|write-output
	                            $updates+="telephonenumber="""+$_.telephonenumber+""""
        	                }
                	        if(($_.crlcostcenter -eq "") -or ($_.crlcostcenter -eq $null)){
                        	    if($user.crlcostcenter -ne $null){
                                	("    crlcostcenter updated from """+$user.crlcostcenter+""" to """"")|write-output
	                                $updates+="crlcostcenter="""""
        	                    }
                	        }elseif($_.crlcostcenter -ne $user.crlcostcenter){
                        	    ("    crlcostcenter updated from """+$user.crlcostcenter+""" to """+$_.crlcostcenter+"""")|write-output
	                            $updates+="crlcostcenter="""+$_.crlcostcenter+""""
        	                }
                	        if($_.manager -ne (get-aduser $user.manager).employeeid){
                        	    ("    manager updated from """+$user.manager+""" to """+$_.manager+"""")|write-output
	                            $updates+="manager="""+$_.manager+""""
        	                }
                	        if($user.otherhomephone -eq $null){
                        	    $ohp="99"+$_.employeeid
	                            ("    otherhomephone updated from """" to """+$ohp+"""")|write-output
        	                    $updates+="otherhomephone="""+$ohp+""""
                	        }
                        	if(($_.crlltielig -eq "") -or ($_.crlltielig -eq $null)){
	                            if($user.extensionattribute1 -ne $null){
        	                        ("    extensionattribute1 updated from """+$user.extensionattribute1+""" to """"")|write-output
                	                $updates+="extensionattribute1="""""
                        	    }
	                        }elseif($_.crlltielig -ne $user.extensionattribute1){
        	                    ("    extensionattribute1 updated from """+$user.extensionattribute1+""" to """+$_.crlltielig+"""")|write-output
                	            $updates+="extensionattribute1="""+$_.crlltielig+""""
                        	}
	                        if(($_.crlbnscode -eq "") -or ($_.crlbnscode -eq $null)){
        	                    if($user.extensionattribute2 -ne $null){
                	                ("    extensionattribute2 updated from """+$user.extensionattribute2+""" to """"")|write-output
                        	        $updates+="extensionattribute2="""""
	                            }
        	                }elseif($_.crlbnscode -ne $user.extensionattribute2){
                	            ("    extensionattribute2 updated from """+$user.extensionattribute2+""" to """+$_.crlbnscode+"""")|write-output
                        	    $updates+="extensionattribute2="""+$_.crlbnscode+""""
	                        }
        	                if(($_.crlBusinessUnit -eq "") -or ($_.crlBusinessUnit -eq $null)){
                	            if($user.crlBusinessUnitCode -ne $null){
                        	        ("    crlBusinessUnitCode updated from """+$user.crlBusinessUnitCode+""" to """"")|write-output
                                	$updates+="crlBusinessUnitCode="""""
	                            }
        	                }elseif($_.crlBusinessUnit -ne $user.crlBusinessUnitCode){
                	            ("    crlBusinessUnitCode updated from """+$user.crlBusinessUnitCode+""" to """+$_.crlBusinessUnit+"""")|write-output
                        	    $updates+="crlBusinessUnitCode="""+$_.crlBusinessUnit+""""
	                        }
        	                if(($_."crl Functional Seg" -eq "") -or ($_."crl Functional Seg" -eq $null)){
                	            if($user.extensionAttribute3 -ne $null){
                        	        ("    extensionAttribute3 updated from """+$user.extensionAttribute3+""" to """"")|write-output
                                	$updates+="extensionAttribute3="""""
	                            }
        	                }elseif($_."crl Functional Seg" -ne $user.extensionAttribute3){
                	            ("    extensionAttribute3 updated from """+$user.extensionAttribute3+""" to """+$_."crl Functional Seg"+"""")|write-output
                        	    $updates+="extensionAttribute3="""+$_."crl Functional Seg"+""""
	                        }
                            
#separate updates and clears
	                        $clears=@()
        	                $changes=@()
                	        foreach($update in $updates){
                        	    $parts=$update.split("=")
	                            if($parts[1] -eq """"""){
        	                        $clears+=$parts[0]
                	            }else{
                        	        $changes+=$update
	                            }
        	                }
#perform updates
	                        if($changes.count -gt 0){
        	                    invoke-expression ("set-aduser "+$user.samaccountname+" -replace @{"+($changes -join ";")+"}")
                	        }
#perform clears
	                        if($clears.count -gt 0){
        	                    invoke-expression ("set-aduser "+$user.samaccountname+" -clear "+($clears -join ","))
                	        }
#add number of changes and clears to grand total
	                        $totalchanges+=$changes.count
        	                $totalchanges+=$clears.count
                	    }
	                }
        	    }
	            ("processing complete.`n")|write-output
        	}
	}
    }
}

#write out start and stop times
("UpdateEmloyeeInfo started at $start.`n")|write-output
$end=get-date
("UpdateEmployeeInfo finished at $end.`n")|write-output

#write out grand total
("$totalchanges changes made.`n")|write-output

#stop logging
stop-transcript

#send completion email
send-mailmessage -to adscripts@crl.com -from "UpdateEmployeeInfo@crl.com" -subject ("UpdateEmployeeInfo") -attachments $logfile -body ("run on ent-pr-uad-01<br><br>UpdateEmployeeInfo script completed") -bodyashtml -smtpserver smtp.cr.local
