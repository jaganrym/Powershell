$logfile="E:\AutomationJobs\Logs\GALv8.txt"
#start logging
start-transcript -path $logfile

#AD cmdlets
import-module ActiveDirectory

#exchange cmdlets
import-pssession (new-pssession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ent-pr-xch-16.cr.local/PowerShell/ -Authentication Kerberos)

#hardcoded values and initialization
$dc = "ent-pr-adc-40"
$ous = @("APAC", "Americas", "EMEIA")
$galou="cr.local/Distribution Lists/Global Auto/"
$userfilter = {(ObjectClass -eq "user") -and (enabled -eq $true)}
$userproperties = ("cn","crlBenefitsLocation","crlBusinessUnitDescription","crlGeographicLocationCode","C","co","l","PhysicalDeliveryOfficeName","crlcostcenter","crlBusinessSegment","EmployeeType","CanonicalName","extensionAttribute1","extensionAttribute2","extensionAttribute3","manager","department","departmentnumber","directreports","title","crlbusinessunitcode")
$hashtable = @{}
$users = @()

#grab the start time so we can report it at the end of the script
$starttime = get-date

#get all the users
$ous|%{$users+=get-aduser -filter $userfilter -searchbase ("ou=$_,dc=cr,dc=local") -searchscope subtree -properties $userproperties}

#function to get all staff ultimately reporting to a specified staff member
function get-adindirectreport{
param ($identity)
    $user=get-aduser $identity -properties $userproperties
    if(($user.samaccountname -ne "shardy") -and ($user.distinguishedname -notlike "*ou=admin*")){
        if($user.enabled){
            $user
            $user.directreports|%{
                get-adindirectreport $_
            }
        }
    }
}

#build the new group membership lists

#global All Users
$contingent=$users|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$users|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}
$hashtable.add(@("Global Auto - All","Global Employees - All"),@($permanent|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - All - CONTINGENT","Global Employees - All - CONTINGENT"),@($contingent|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - All - Excluding OQLF","Global Employees - All - Excluding OQLF"),@($permanent|?{$_.c -ne "CA"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - All - Excluding OQLF - CONTINGENT","Global Employees - All - Excluding OQLF - CONTINGENT"),@($contingent|?{$_.c -ne "CA"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - All - OQLF","Global Employees - All - OQLF"),@($permanent|?{$_.c -eq "CA"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - All - OQLF - CONTINGENT","Global Employees - All - OQLF - CONTINGENT"),@($contingent|?{$_.c -eq "CA"}|select -expandproperty samaccountname))

#global auto benefits - lti eligible
$hashtable.add(@("Global Auto Benefits - LTI Eligible","Global Employees - Benefits - LTI Eligible"),@($users|?{$_.extensionattribute1 -eq "y"}|select -expandproperty samaccountname))

#global auto benefits
$usersublist=$users|?{$_.extensionattribute2 -ne $null}
$groups=$usersublist|select -expandproperty extensionattribute2|sort -unique
$groups|%{$group=$_;$hashtable.add(@("Global Auto Benefits - $group","Global Employees - Benefits - $group"),@($usersublist|?{$_.extensionattribute2 -eq $group}|select -expandproperty samaccountname))}

#country
$usersublist=$users|?{$_.co -ne $null}
$contingent=$usersublist|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$usersublist|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}
$groups=$contingent|select -expandproperty co|sort -unique
$groups|%{if($_ -eq "Korea, Republic Of" -or $_ -eq "한국 / 韓國"){$country="Korea"}else{$country=$_};$hashtable.add(@("Global Auto Country - $country - CONTINGENT","Global Employees - $country - CONTINGENT"),@($contingent|?{$_.co -eq $country}|select -expandproperty samaccountname))}
$groups=$permanent|select -expandproperty co|sort -unique
$groups|%{if($_ -eq "Korea, Republic Of" -or $_ -eq "한국 / 韓國"){$country="Korea"}else{$country=$_};$hashtable.add(@("Global Auto Country - $country","Global Employees - $country"),@($permanent|?{$_.co -eq $country}|select -expandproperty samaccountname))}

#special case:  US Except CRIS
$hashtable.add(@("Global Auto Country - United States - Except CRIS - CONTINGENT","Global Employees - United States - Except CRIS - CONTINGENT"),@($contingent|?{($_.c -eq "US") -and !(($_.crlbusinessunitdescription -eq "IS Government") -or ($_.crlbusinessunitdescription -eq "IS Commercial and Academic"))}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Country - United States - Except CRIS","Global Employees - United States - Except CRIS"),@($permanent|?{($_.c -eq "US") -and !(($_.crlbusinessunitdescription -eq "IS Government") -or ($_.crlbusinessunitdescription -eq "IS Commercial and Academic"))}|select -expandproperty samaccountname))

#special case:  CHINA
$usersublist=get-adobject -filter {objectclass -eq "contact"} -searchbase "ou=apac contacts,ou=resource accounts,dc=cr,dc=local"
$hashtable.add(@("Global Auto Country - China","Global Employees - China"),@($usersublist|select -expandproperty distinguishedname))

#region groups - OQLF and Excluding OQLF Safety Assessment
$usersublist=$users|?{($_.crlbusinessunitdescription -eq "Safety Assessment")}
$hashtable.add(@("Global Auto Business - Safety Assessment - Excluding OQLF","Global Employees - Safety Assessment - Excluding OQLF"),@($usersublist|?{($_.c -ne "CA")}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Business - Safety Assessment - OQLF","Global Employees - Safety Assessment - OQLF"),@($usersublist|?{($_.c -eq "CA")}|select -expandproperty samaccountname))

#region groups - OQLF and Excluding OQLF Discovery and Safety Assessment
$usersublist=$users|?{($_.crlbusinessunitdescription -eq "Safety Assessment") -or ($_.crlbusinessunitdescription -eq "discovery services")}
$hashtable.add(@("Global Auto - Discovery and Safety Assessment - Excl OQLF","Global Employees - Discovery and Safety Assessment - Excl OQLF"),@($usersublist|?{($_.c -ne "CA")}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - Discovery and Safety Assessment - OQLF","Global Employees - Discovery and Safety Assessment - OQLF"),@($usersublist|?{($_.c -eq "CA")}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - Discovery and Safety Assessment - ALL","Global Employees - Discovery and Safety Assessment - ALL"),@($usersublist|select -expandproperty samaccountname))

#RMS - need to make updates to get the sub-DLs correct
$usersublist=@(get-adindirectreport cdunn)+@($users|?{($_.extensionattribute3 -eq "rms") -or (@("small animal","large animal","gems","rads") -contains $_.crlbusinessunitdescription)})
$hashtable.add(@("Global Auto RMS - ALL","Global Employees - RMS - ALL"),@($usersublist|select -expandproperty samaccountname))

#DSA - test
$usersublist=@(get-adindirectreport bgirshick)
#+@($users|?{($_.extensionattribute3 -eq "rms") -or (@("small animal","large animal","gems","rads") -contains $_.crlbusinessunitdescription)})
$hashtable.add(@("Global Auto DSA - TEST","Global Employees - DSA - TEST"),@($usersublist|select -expandproperty samaccountname))

#region groups - not APAC or CA
$usersublist=$users|?{($_.canonicalname -notmatch "APAC") -and ($_.c -ne "CA") -and ($_.crlbusinesssegment -ne $null) -and ($_.crlbusinessunitdescription -ne $null)}

#DSA by region
$dsa=$usersublist|?{($_.crlbusinesssegment -eq "DSA") -or ($_.crlbusinessunitdescription.contains("DSA")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$dsa|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$dsa|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}

#US
$hashtable.add(@("Global Auto Region - DSA - US - CONTINGENT","Global Employees - DSA - US - CONTINGENT"),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - DSA - US","Global Employees - DSA - US"),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))

#EMEIA
$hashtable.add(@("Global Auto Region - DSA - EMEIA - CONTINGENT","Global Employees - DSA - EMEIA - CONTINGENT"),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - DSA - EMEIA","Global Employees - DSA - EMEIA"),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))

#RMS by region
$rms=$usersublist|?{($_.crlbusinesssegment -eq "RMS") -or ($_.crlbusinessunitdescription.contains("RMS")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$rms|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$rms|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}

#US
$hashtable.add(@("Global Auto Region - RMS - US - CONTINGENT","Global Employees - RMS - US - CONTINGENT"),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - RMS - US","Global Employees - RMS - US"),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))

#EMEIA
$hashtable.add(@("Global Auto Region - RMS - EMEIA - CONTINGENT","Global Employees - RMS - EMEIA - CONTINGENT"),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - RMS - EMEIA","Global Employees - RMS - EMEIA"),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))

#US & UK
$hashtable.add(@("Global Auto Region - RMS - UK & US - CONTINGENT","Global Employees - RMS - UK & US - CONTINGENT"),@($contingent|?{($_.c -eq "US") -or ($_.c -eq "UK")}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - RMS - UK & US","Global Employees - RMS - UK & US"),@($permanent|?{($_.c -eq "US") -or ($_.c -eq "UK")}|select -expandproperty samaccountname))

#CRP by region
$crp=$usersublist|?{($_.crlbusinesssegment -eq "CRP") -or ($_.crlbusinessunitdescription.contains("CRP")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$crp|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$crp|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}

#US
$hashtable.add(@("Global Auto Region - CRP - US - CONTINGENT","Global Employees - CRP - US - CONTINGENT"),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - CRP - US","Global Employees - CRP - US"),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))

#EMEIA
$hashtable.add(@("Global Auto Region - CRP - EMEIA - CONTINGENT","Global Employees - CRP - EMEIA - CONTINGENT"),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - CRP - EMEIA","Global Employees - CRP - EMEIA"),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))

#MFG by region
$mfg=$usersublist|?{($_.crlbusinesssegment -eq "MFG") -or ($_.crlbusinessunitdescription.contains("MFG")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$mfg|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$mfg|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}

#US
$hashtable.add(@("Global Auto Region - MFG - US - CONTINGENT","Global Employees - MFG - US - CONTINGENT"),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - MFG - US","Global Employees - MFG - US"),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))

#EMEIA
$hashtable.add(@("Global Auto Region - MFG - EMEIA - CONTINGENT","Global Employees - MFG - EMEIA - CONTINGENT"),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Region - MFG - EMEIA","Global Employees - MFG - EMEIA"),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
#business segments
$usersublist=$users|?{($_.crlbusinesssegment -ne $null) -and ($_.crlbusinessunitdescription -ne $null)}
$contingent=$usersublist|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$usersublist|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}
$groups=$contingent|select -expandproperty crlbusinesssegment|sort -unique
$groups|%{$segment=$_;$hashtable.add(@("Global Auto Business - $segment - OQLF - CONTINGENT","Global Employees - $segment - OQLF - CONTINGENT"),@($contingent|?{($_.c -eq "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
$groups|%{$segment=$_;$hashtable.add(@("Global Auto Business - $segment - Excluding OQLF - CONTINGENT","Global Employees - $segment - Excluding OQLF - CONTINGENT"),@($contingent|?{($_.c -ne "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
$groups=$permanent|select -expandproperty crlbusinesssegment|sort -unique
$groups|%{$segment=$_;$hashtable.add(@("Global Auto Business - $segment - OQLF","Global Employees - $segment - OQLF"),@($permanent|?{($_.c -eq "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
$groups|%{$segment=$_;$hashtable.add(@("Global Auto Business - $segment - Excluding OQLF","Global Employees - $segment - Excluding OQLF"),@($permanent|?{($_.c -ne "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}

#geographic locations
#$usersublist=$users|?{($_.crlgeographiclocationcode -ne $null) -and ($_.crlbusinesssegment -ne $null)}
$usersublist=$users|?{$_.crlgeographiclocationcode -ne $null}
$contingent=$usersublist|?{$_.employeetype -eq "Contingent Employee"}
$permanent=$usersublist|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}

#contingent
$groups=$contingent|select -expandproperty crlgeographiclocationcode|sort -unique
$groups|%{$location=$_;$hashtable.add(@("Global Auto Location - $location - CONTINGENT","Global Employees - $location - CONTINGENT"),@($contingent|?{$_.crlgeographiclocationcode -eq $location}|select -expandproperty samaccountname))}

#special cases - Wilmington DSA & RMS
$hashtable.add(@("Global Auto Location - Wilmington DSA - CONTINGENT","Global Employees - Wilmington DSA - CONTINGENT"),@($contingent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("DSA") -or ($_.crlbusinesssegment.contains("CRP") -and $_.crlbusinessunitdescription.contains("DSA")))}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Location - Wilmington RMS - CONTINGENT","Global Employees - Wilmington RMS - CONTINGENT"),@($contingent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("RMS") -or ($_.crlbusinesssegment.contains("CRP") -and ($_.crlbusinessunitdescription.contains("RMS") -or $_.crlbusinessunitdescription.contains("CRIS"))))}|select -expandproperty samaccountname))

#permanent
$groups=$permanent|select -expandproperty crlgeographiclocationcode|sort -unique
$groups|%{$location=$_;$hashtable.add(@("Global Auto Location - $location","Global Employees - $location"),@($permanent|?{$_.crlgeographiclocationcode -eq $location}|select -expandproperty samaccountname))}

#special cases - Wilmington DSA & RMS
$hashtable.add(@("Global Auto Location - Wilmington DSA","Global Employees - Wilmington DSA"),@($permanent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("DSA") -or ($_.crlbusinesssegment.contains("CRP") -and $_.crlbusinessunitdescription.contains("DSA")))}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Location - Wilmington RMS","Global Employees - Wilmington RMS"),@($permanent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("RMS") -or ($_.crlbusinesssegment.contains("CRP") -and ($_.crlbusinessunitdescription.contains("RMS") -or $_.crlbusinessunitdescription.contains("CRIS"))))}|select -expandproperty samaccountname))

#global HR
$usersublist=$permanent|?{$_.extensionattribute3 -ne $null}
$hashtable.add(@("Global Auto HR","Global Employees - HR"),@($usersublist|?{$_.extensionattribute3 -eq "HRS"}|select -expandproperty samaccountname))

#NA HR
$hashtable.add(@("Global Auto HR - North America","Global Employees - HR - North America"),@($usersublist|?{($_.extensionattribute3 -eq "HRS") -and (($_.c -eq "US") -or ($_.c -eq "CA"))}|select -expandproperty samaccountname))

#US HR
$hashtable.add(@("Global Auto HR - US","Global Employees - HR - US"),@($usersublist|?{($_.extensionattribute3 -eq "HRS") -and ($_.c -eq "US")}|select -expandproperty samaccountname))

#WLM HR
$hashtable.add(@("Global Auto HR - Wilmingtom","Global Employees - HR - Wilmington"),@($usersublist|?{($_.extensionattribute3 -eq "HRS") -and ($_.crlgeographiclocationcode -eq "wilmington")}|select -expandproperty samaccountname))

#YASH
$hashtable.add(@("Global Auto YASH","Global Employees - YASH"),@($users|?{@("419355","419357","419358") -contains $_.departmentnumber}|select -expandproperty samaccountname))

#Syntel
$hashtable.add(@("Global Auto - Syntel","Global Employees - Syntel"),@($users|?{$_.title -eq "temporary syntel it"}|select -expandproperty samaccountname))

#Accenture
$hashtable.add(@("Global Auto - Accenture","Global Employees - Accenture"),@($users|?{$_.title -eq "temporary accenture it"}|select -expandproperty samaccountname))

#Insourcing Solutions
$hashtable.add(@("Global Auto - Insourcing Solutions","Global Employees - Insourcing Solutions"),@($users|?{@("NA04","NA05","NA30","EU04","EU05","EU30") -contains $_.crlbusinessunitcode}|select -expandproperty samaccountname))

#global Biologics
$hashtable.add(@("Global Auto - Biologics","Global Employees - Biologics"),@($users|?{@("AS12","EU12","NA12") -contains $_.crlbusinessunitcode}|select -expandproperty samaccountname))
#IT lists

#global IT including contingent staff
$hashtable.add(@("Global Auto - IT - ALL Including CONTINGENT","Global Employees - IT - ALL Including CONTINGENT"),@($users|?{$_.extensionattribute3 -eq "IT"}|select -expandproperty samaccountname))

#global IT
$hashtable.add(@("Global Auto - IT","Global Employees - IT"),@($permanent|?{$_.extensionattribute3 -eq "IT"}|select -expandproperty samaccountname))

#US IT
$hashtable.add(@("Global Auto - IT - US","Global Employees - IT - US"),@($permanent|?{($_.extensionattribute3 -eq "IT") -and ($_.c -eq "US")}|select -expandproperty samaccountname))

#WLM IT
$hashtable.add(@("Global Auto - IT - Wilmington","Global Employees - IT - Wilmington"),@($permanent|?{($_.extensionattribute3 -eq "IT") -and ($_.crlgeographiclocationcode -eq "wilmington")}|select -expandproperty samaccountname))

#WLM Corporate Communications
$hashtable.add(@("Global Auto - Corporate Communications","Global Employees - Corporate Communications"),@($permanent|?{($_.department -eq "Corporate Communications")}|select -expandproperty samaccountname))

#global managers
$hashtable.add(@("Global Auto Managers","Global Employees - Managers"),@($users|?{$_.directreports -ne $null}|select -expandproperty samaccountname))

#US managers
$hashtable.add(@("Global Auto Managers - US","Global Employees - Managers - US"),@($users|?{($_.directreports -ne $null) -and ($_.c -eq "US")}|select -expandproperty samaccountname))

#SAP Managers
$usersublist=@(get-adgroup -server $dc -filter{name -like "global apps - sap*"}|get-adgroupmember -server $dc|get-aduser -properties $userproperties)|sort samaccountname -unique
$hashtable.add(@("Global Auto - SAP Managers - OQLF","Global Employees - SAP - Managers - OQLF"),@($usersublist|?{($_.directreports -ne $null) -and ($_.c -eq "CA")}|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto - SAP Managers - Excluding OQLF","Global Employees - SAP - Managers - Excluding OQLF"),@($usersublist|?{($_.directreports -ne $null) -and ($_.c -ne "CA")}|select -expandproperty samaccountname))

#safety assessment managers
$hashtable.add(@("Global Auto - Safety Assessment - Managers","Global Employees - Safety Assessment - Managers"),@($users|?{($_.directreports -ne $null) -and ($_.crlbusinessunitdescription -eq "Safety Assessment")}|select -expandproperty samaccountname))

#PAI groups
$groups=get-adgroup -filter {name -like "global auto location*pai"}|select -expandproperty samaccountname
$hashtable.add(@("Global Auto - All - PAI","Global Employees - All - PAI"),$groups)

#global discovery
$hashtable.add(@("Global Auto - Global Discovery","Global Employees - Global Discovery"),@($users|?{$_.crlbusinessunitdescription -eq "discovery services"}|select -expandproperty samaccountname))

#global legal
$hashtable.add(@("Global Auto - Legal","Global Employees - Legal"),@($users|?{$_.extensionattribute3 -eq "LEG"}|select -expandproperty samaccountname))

#global procurement
$usersublist1=get-adindirectreport cr208232
$usersublist2=get-adindirectreport BC33113
$usersublist3=get-adindirectreport dgold
$usersublist=$usersublist1+$usersublist2+$usersublist3 | select -Unique
$hashtable.add(@("Global Auto - Procurement Team","Global Employees - Procurement Team"),@($usersublist|?{($_.employeetype -eq "Full Time Employee") -or ($_.employeetype -eq "Part Time Employee")}|select -expandproperty samaccountname))

#finance
#David Smith - DRS35298
$usersublist=get-adindirectreport drs35298

#Business Unit Controllers
#Andrea Romoli - cr212905
$usersublist1=get-adindirectreport cr212905
#David Hagerman - cr209687
$usersublist2=get-adindirectreport cr209687
#Brent Greetham - cr209680
$usersublist3=get-adindirectreport cr209680
#Kevin Wasley - cr209408
$usersublist4=get-adindirectreport cr209408
#Kevin Finn - cr213161
$usersublist5=get-adindirectreport cr213161

#controllers
$hashtable.add(@("Global Auto Finance - Controller - ARomoli","Global Employees - Finance - Controller - ARomoli"),@($usersublist1|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Finance - Controller - DHagerman","Global Employees - Finance - Controller - DHagerman"),@($usersublist2|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Finance - Controller - BGreetham","Global Employees - Finance - Controller - BGreetham"),@($usersublist3|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Finance - Controller - KWasley","Global Employees - Finance - Controller - KWasley"),@($usersublist4|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Finance - Controller - KFinn","Global Employees - Finance - Controller - KFinn"),@($usersublist5|select -expandproperty samaccountname))

#all finance
$usersublist+=$usersublist1+$usersublist2+$usersublist3+$usersublist4+$usersublist5|select -unique

#all employees
$hashtable.add(@("Global Auto Finance","Global Employees - Finance"),@($usersublist|select -expandproperty samaccountname))

#US only
$hashtable.add(@("Global Auto Finance - US","Global Employees - Finance - US"),@($usersublist|?{$_.c -eq "us"}|select -expandproperty samaccountname))

#WLM only
$hashtable.add(@("Global Auto Finance - Wilmington","Global Employees - Finance - Wilmington"),@($usersublist|?{$_.l -eq "Wilmington"}|select -expandproperty samaccountname))

#Lab Science Shrewsbury / Stats_DataScience
$usersublist=get-adindirectreport cr208690
$hashtable.add(@("Global Auto Business - Lab Sci - Shrewsbury","Global Employees - Lab Sci - Shrewsbury"),@($usersublist|select -expandproperty samaccountname))
$hashtable.add(@("Global Auto Business - Lab Sci - Stats_Data Science","Global Employees - Lab Sci - Stats_Data Science"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Montreal/Sherbrooke
$usersublist=get-adindirectreport s_lavallee
$hashtable.add(@("Global Auto Business - Lab Sci - Montreal_Sherbrooke","Global Employees - Lab Sci - Montreal_Sherbrooke"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Ashland
$usersublist=get-adindirectreport cr201919
$hashtable.add(@("Global Auto Business - Lab Sci - Ashland","Global Employees - Lab Sci - Ashland"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Skokie
$usersublist=get-adindirectreport cr201950
$hashtable.add(@("Global Auto Business - Lab Sci - Skokie","Global Employees - Lab Sci - Skokie"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Lyon
$usersublist=get-adindirectreport cr203576
$hashtable.add(@("Global Auto Business - Lab Sci - Lyon","Global Employees - Lab Sci - Lyon"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Den Bosch
$usersublist1=get-adindirectreport cr202902
$usersublist2=get-adindirectreport cr202935
$usersublist=$usersublist1+$usersublist2 | select -Unique
$hashtable.add(@("Global Auto Business - Lab Sci - Den Bosch","Global Employees - Lab Sci - Den Bosch"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Reno
$usersublist=get-adindirectreport cr210048
$hashtable.add(@("Global Auto Business - Lab Sci - Reno","Global Employees - Lab Sci - Reno"),@($usersublist|select -expandproperty samaccountname))

#Lab Science MWN
$usersublist0=get-adindirectreport cr212574
$usersublist1=get-adindirectreport cr211138
$usersublist2=get-adindirectreport cr212610
$usersublist3=get-adindirectreport cr210869
$usersublist=$usersublist0+$usersublist1+$usersublist2+$usersublist3
$hashtable.add(@("Global Auto Business - Lab Sci - MWN","Global Employees - Lab Sci - MWN"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Spencerville
$usersublist=get-adindirectreport gclemons
$hashtable.add(@("Global Auto Business - Lab Sci - Spencerville","Global Employees - Lab Sci - Spencerville"),@($usersublist|select -expandproperty samaccountname))

#Lab Science CR-MA
$usersublist=get-adindirectreport cr205180
$hashtable.add(@("Global Auto Business - Lab Sci - CR-MA","Global Employees - Lab Sci - CR-MA"),@($usersublist|select -expandproperty samaccountname))

#Lab Science Horsham
$usersublist=get-adindirectreport SLL33969
$hashtable.add(@("Global Auto Business - Lab Sci - Horsham","Global Employees - Lab Sci - Horsham"),@($usersublist|select -expandproperty samaccountname))

#Lab Science EDI
$usersublist=get-adindirectreport GBurns
$hashtable.add(@("Global Auto Business - Lab Sci - EDI","Global Employees - Lab Sci - EDI"),@($usersublist|select -expandproperty samaccountname))

#Lab Sciences WOR
$usersublist=get-adindirectreport cr205426
$hashtable.add(@("Global Auto Business - Lab Sci - WOR","Global Employees - Lab Sci - WOR"),@($usersublist|select -expandproperty samaccountname))

#Lab Science All
$LabSciGroup = Get-ADGroup -f {(name -like "Global Auto Business - Lab Sci - *") -and (name -ne "Global Auto Business - Lab Sci - All")} | select -ExpandProperty samaccountname
$hashtable.add(@("Global Auto Business - Lab Sci - All","Global Employees - Lab Sci - All"),$LabSciGroup)





#create/update the lists - correct any errors such as being hidden from the GAL etc
foreach($group in $hashtable.getenumerator()){
    $name=$group.key[0].replace(", ",",").replace(",","-")
    $dist=$group.key[1].replace(", ",",").replace(",","-")
    $members=@($group.value|sort -unique)
#child DL - created/updated and hidden from GAL
    $child=get-adgroup -filter {samaccountname -eq $name} -server $dc
    ("`n`n$name")
    if($child -eq $null){
        ("  will be created.")
        $child=new-distributiongroup -domaincontroller $dc -name $name -organizationalunit $galou -samaccountname $name -members $members -memberdepartrestriction closed
        set-adgroup $child.samaccountname -server $dc -description ("Auto Created - "+(get-date)) -groupcategory security
        ("  has been created at "+(get-date)+".")
        ("  has "+$members.count+" members.")
        set-distributiongroup $child.samaccountname -domaincontroller $dc -hiddenfromaddresslistsenabled $true
        ("  has been hidden from the GAL.")
    }else{
        ("  will be updated.")
        set-adgroup $child -server $dc -description ("Auto Updated - "+(get-date)) -groupcategory security
        if($child.name -eq "global auto country - china"){
            $current=@(((get-adgroup $child -properties members).members)|sort -unique)
            $differences=@(compare-object $current $members)
            if($differences.count -eq 0){
                "  no membership update needed."
            }else{
                $dl=[adsi]"LDAP://CN=Global Auto Country - China,ou=Global Auto,ou=Distribution Lists,DC=cr,dc=local"
                foreach($diff in $differences){
                    $memb=$diff.inputobject
                    switch($diff.sideindicator){
                        "=>"{$dl.member.add("$memb")
                            ("    added "+$diff.inputobject)}
                        "<="{$dl.member.remove("$memb")
                            ("    removed "+$diff.inputobject)}
                    }
                }
                $dl.psbase.commitchanges()
            }
        }else{
            if(($child.name -eq "global auto - all - pai") -or ($child.name -eq "global auto business - lab sci - all")){
                $current=@((get-adgroup $child -properties members).members|%{get-adgroup $_}|select -expandproperty samaccountname)
            }else{
                $current=@((get-adgroup $child -properties members).members|%{get-aduser $_}|select -expandproperty samaccountname)
            }
            $differences=@(compare-object $current $members)
            if($differences.count -eq 0){
                "  no membership update needed."
            }else{
                foreach($diff in $differences){
                    switch($diff.sideindicator){
                        "=>"{add-adgroupmember $child -server $dc -members $diff.inputobject
                             ("    added "+$diff.inputobject)}
                        "<="{remove-adgroupmember $child -server $dc -members $diff.inputobject -confirm:$false
                             ("    removed "+$diff.inputobject)}
                    }
                }
            }
        }
        ("  has been updated at "+(get-date)+".")
        ("  has "+$members.count+" members.")
    }

#parent DL - created, contains child DL, and is visible in GAL
    $parent=get-adgroup -filter {samaccountname -eq $dist}
    ("`n  $dist")
    if($parent -eq $null){
        ("    will be created.")
        $parent=new-distributiongroup -domaincontroller $dc -name $dist -organizationalunit $galou -samaccountname $dist -memberdepartrestriction closed
        set-adgroup $parent.samaccountname -server $dc -description ("Auto Created - "+(get-date)) -groupcategory security
        ("    has been created at "+(get-date)+".")
        set-distributiongroup $parent.samaccountname -domaincontroller $dc -acceptmessagesonlyfromdlmembers "Global SendTo Perms"
        ("    is now restricted.")
    }else{
        set-adgroup $parent.samaccountname -server $dc -description ("Auto Updated - "+(get-date)) -groupcategory security
        if($parent.hiddenfromaddresslistsenabled){
            set-distributiongroup $dist -domaincontroller $dc -hiddenfromaddresslistsenabled $false
            ("    has been unhidden.")
        }else{
            ("    exists and is visible.")
        }
        if((get-distributiongroup $dist -domaincontroller $dc).acceptmessagesonlyfromdlmembers){
            ("    is already restricted.")
        }else{
            set-distributiongroup $dist -domaincontroller $dc -acceptmessagesonlyfromdlmembers "Global SendTo Perms"
            ("    is now restricted.")
        }
    }
    if((get-distributiongroupmember $dist -domaincontroller $dc) -match $name){
        ("    already contains $name.")
    }else{
        ("    does not contain $name.")
        add-adgroupmember $dist -server $dc -members $name
        ("    now contains $name.")
    }
}

("`n`n`nProcessing Started:   " + $StartTime) | write-output
("Processing Finished:  " + (get-date)) | write-output
get-pssession|remove-pssession

#stop logging
Stop-Transcript

#send completion email
$when = get-date
send-mailmessage -to "adscripts@crl.com" -from "GlobalAutoLists@crl.com" -subject ("Global Auto Lists Updated $when") -attachments $logfile -body ("run on ent-pr-uad-01<br><br>Global Auto lists updated $when") -bodyashtml -smtpserver smtp.cr.local
