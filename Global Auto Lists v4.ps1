#start logging
start-transcript -path "c:\temp\GALv4.txt"

#AD cmdlets
import-module ActiveDirectory

#exchange cmdlets
import-pssession (new-pssession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ent-pr-xch-10.cr.local/PowerShell/ -Authentication Kerberos)

#hardcoded values and initialization
$dc = "ent-pr-adc-40"
$ous = @("APAC", "Americas", "EMEIA")
$galou="cr.local/Distribution Lists/Global Auto/"
$userfilter = {(ObjectClass -eq "user") -and (enabled -eq $true)}
$userproperties = ("cn","crlBenefitsLocation","crlBusinessUnitDescription","crlGeographicLocationCode","C","co","l","PhysicalDeliveryOfficeName",
"crlBusinessSegment","EmployeeType","CanonicalName","extensionAttribute1","extensionAttribute2","extensionAttribute3","manager","departmentnumber","directreports","title","crlbusinessunitcode")
$hashtable = @{}
$users = @()

#string abbreviations
$ce="Contingent Employee"
$fte="Full Time Employee"
$pte="Part Time Employee"
$co=" - CONTINGENT"
$ec=" - Except CRIS"
$o=" - OQLF"
$eo=" - Excluding OQLF"
$us=" - US"
$ga="Global Auto"
$ge="Global Employees"
$gaa=@("$ga All","$ge - All")
$gabe=@("$ga Benefits - ","$ge - Benefits - ")
$gac=@("$ga Country - ","$ge - ")
$gar=@("$ga Region - ","$ge - ")
$gab=@("$ga Business - ","$ge - ")
$gal=@("$ga Location - ","$ge - ")
$gah=@("$ga HR","$ge - HR")
$gahu=@("$ga HR$us","$ge - HR$us")
$gay=@("$ga YASH","$ge - YASH")
$gam=@("$ga Managers","$ge - Managers")
$gamu=@("$ga Managers$us","$ge - Managers$us")
$gasm=@("$ga SAP - Managers","$ge - SAP - Managers")
$wd="Wilmington DSA"
$wr="Wilmington RMS"
$dso=@("$ga Finance","$ge - Finance")
$wlm=" - Wilmington"

#grab the start time so we can report it at the end of the script
$starttime = get-date

#get all the users
$ous|%{$users+=get-aduser -filter $userfilter -searchbase ("ou=$_,dc=cr,dc=local") -searchscope subtree -properties $userproperties}

#build the new group membership lists
#global All Users
$contingent=$users|?{$_.employeetype -eq $ce}
$permanent=$users|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
$hashtable.add(@(($gaa[0]),($gaa[1])),@($permanent|select -expandproperty samaccountname))
$hashtable.add(@(($gaa[0]+$co),($gaa[1]+$co)),@($contingent|select -expandproperty samaccountname))
$hashtable.add(@(($gaa[0]+$eo),($gaa[1]+$eo)),@($permanent|?{$_.c -ne "CA"}|select -expandproperty samaccountname))
$hashtable.add(@(($gaa[0]+$eo+$co),($gaa[1]+$eo+$co)),@($contingent|?{$_.c -ne "CA"}|select -expandproperty samaccountname))
$hashtable.add(@(($gaa[0]+$o),($gaa[1]+$o)),@($permanent|?{$_.c -eq "CA"}|select -expandproperty samaccountname))
$hashtable.add(@(($gaa[0]+$o+$co),($gaa[1]+$o+$co)),@($contingent|?{$_.c -eq "CA"}|select -expandproperty samaccountname))
#global auto benefits - lti eligible
$hashtable.add(@(($gabe[0]+"LTI Eligible"),($gabe[1]+"LTI Eligible")),@($users|?{$_.extensionattribute1 -eq "y"}|select -expandproperty samaccountname))
#global auto benefits
$usersublist=$users|?{$_.extensionattribute2 -ne $null}
$groups=$usersublist|select -expandproperty extensionattribute2|sort -unique
$groups|%{$group=$_;$hashtable.add(@(($gabe[0]+$group),($gabe[1]+$group)),@($usersublist|?{$_.extensionattribute2 -eq $group}|select -expandproperty samaccountname))}
#country
$usersublist=$users|?{$_.co -ne $null}
$contingent=$usersublist|?{$_.employeetype -eq $ce}
$permanent=$usersublist|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
$groups=$contingent|select -expandproperty co|sort -unique
$groups|%{$country=$_;$hashtable.add(@(($gac[0]+$country+$co),($gac[1]+$country+$co)),@($contingent|?{$_.co -eq $country}|select -expandproperty samaccountname))}
$groups=$permanent|select -expandproperty co|sort -unique
$groups|%{$country=$_;$hashtable.add(@(($gac[0]+$country),($gac[1]+$country)),@($permanent|?{$_.co -eq $country}|select -expandproperty samaccountname))}
#special case:  US Except CRIS
$hashtable.add(@(($gac[0]+"United States"+$ec+$co),($gac[1]+"United States"+$ec+$co)),($contingent|?{($_.c -eq "US") -and !(($_.crlbusinessunitdescription -eq "IS Government") -or ($_.crlbusinessunitdescription -eq "IS Commercial and Academic"))}|select -expandproperty samaccountname))
$hashtable.add(@(($gac[0]+"United States"+$ec),($gac[1]+"United States"+$ec)),($permanent|?{($_.c -eq "US") -and !(($_.crlbusinessunitdescription -eq "IS Government") -or ($_.crlbusinessunitdescription -eq "IS Commercial and Academic"))}|select -expandproperty samaccountname))
#region groups - OQLF and Excluding OQLF CA Safety Assessment
$usersublist=$users|?{($_.crlbusinessunitdescription -eq "Safety Assessment")}
$hashtable.add(@(($gab[0]+"Safety Assessment"+$eo),($gab[1]+"Safety Assessment"+$eo)),@($usersublist|?{($_.c -ne "CA")}|select -expandproperty samaccountname))
$hashtable.add(@(($gab[0]+"Safety Assessment"+$o),($gab[1]+"Safety Assessment"+$o)),@($usersublist|?{($_.c -eq "CA")}|select -expandproperty samaccountname))
#region groups - not APAC or CA
$usersublist=$users|?{($_.canonicalname -notmatch "APAC") -and ($_.c -ne "CA") -and ($_.crlbusinesssegment -ne $null) -and ($_.crlbusinessunitdescription -ne $null)}
#DSA by region
$dsa=$usersublist|?{($_.crlbusinesssegment -eq "DSA") -or ($_.crlbusinessunitdescription.contains("DSA")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$dsa|?{$_.employeetype -eq $ce}
$permanent=$dsa|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
#US
$hashtable.add(@(($gar[0]+"DSA - US"+$co),($gar[1]+"DSA - US"+$co)),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"DSA - US"),($gar[1]+"DSA - US")),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
#EMEIA
$hashtable.add(@(($gar[0]+"DSA - EMEIA"+$co),($gar[1]+"DSA - EMEIA"+$co)),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"DSA - EMEIA"),($gar[1]+"DSA - EMEIA")),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
#RMS by region
$rms=$usersublist|?{($_.crlbusinesssegment -eq "RMS") -or ($_.crlbusinessunitdescription.contains("RMS")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$rms|?{$_.employeetype -eq $ce}
$permanent=$rms|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
#US
$hashtable.add(@(($gar[0]+"RMS - US"+$co),($gar[1]+"RMS - US"+$co)),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"RMS - US"),($gar[1]+"RMS - US")),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
#EMEIA
$hashtable.add(@(($gar[0]+"RMS - EMEIA"+$co),($gar[1]+"RMS - EMEIA"+$co)),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"RMS - EMEIA"),($gar[1]+"RMS - EMEIA")),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
#US & UK
$hashtable.add(@(($gar[0]+"RMS - UK & US"+$co),($gar[1]+"RMS - UK & US"+$co)),@($contingent|?{($_.c -eq "US") -or ($_.c -eq "UK")}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"RMS - UK & US"),($gar[1]+"RMS - UK & US")),@($permanent|?{($_.c -eq "US") -or ($_.c -eq "UK")}|select -expandproperty samaccountname))
#CRP by region
$crp=$usersublist|?{($_.crlbusinesssegment -eq "CRP") -or ($_.crlbusinessunitdescription.contains("CRP")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$crp|?{$_.employeetype -eq $ce}
$permanent=$crp|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
#US
$hashtable.add(@(($gar[0]+"CRP - US"+$co),($gar[1]+"CRP - US"+$co)),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"CRP - US"),($gar[1]+"CRP - US")),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
#EMEIA
$hashtable.add(@(($gar[0]+"CRP - EMEIA"+$co),($gar[1]+"CRP - EMEIA"+$co)),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"CRP - EMEIA"),($gar[1]+"CRP - EMEIA")),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
#MFG by region
$mfg=$usersublist|?{($_.crlbusinesssegment -eq "MFG") -or ($_.crlbusinessunitdescription.contains("MFG")) -or ($_.crlbusinessunitdescription.contains("CRIS"))}
$contingent=$mfg|?{$_.employeetype -eq $ce}
$permanent=$mfg|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
#US
$hashtable.add(@(($gar[0]+"MFG - US"+$co),($gar[1]+"MFG - US"+$co)),@($contingent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"MFG - US"),($gar[1]+"MFG - US")),@($permanent|?{$_.c -eq "US"}|select -expandproperty samaccountname))
#EMEIA
$hashtable.add(@(($gar[0]+"MFG - EMEIA"+$co),($gar[1]+"MFG - EMEIA"+$co)),@($contingent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
$hashtable.add(@(($gar[0]+"MFG - EMEIA"),($gar[1]+"MFG - EMEIA")),@($permanent|?{$_.c -ne "US"}|select -expandproperty samaccountname))
#business segments
$usersublist=$users|?{($_.crlbusinesssegment -ne $null) -and ($_.crlbusinessunitdescription -ne $null)}
$contingent=$usersublist|?{$_.employeetype -eq $ce}
$permanent=$usersublist|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
$groups=$contingent|select -expandproperty crlbusinesssegment|sort -unique
$groups|%{$segment=$_;$hashtable.add(@(($gab[0]+$segment+$o+$co),($gab[1]+$segment+$o+$co)),@($contingent|?{($_.c -eq "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
$groups|%{$segment=$_;$hashtable.add(@(($gab[0]+$segment+$eo+$co),($gab[1]+$segment+$eo+$co)),@($contingent|?{($_.c -ne "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
$groups=$permanent|select -expandproperty crlbusinesssegment|sort -unique
$groups|%{$segment=$_;$hashtable.add(@(($gab[0]+$segment+$o),($gab[1]+$segment+$o)),@($permanent|?{($_.c -eq "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
$groups|%{$segment=$_;$hashtable.add(@(($gab[0]+$segment+$eo),($gab[1]+$segment+$eo)),@($permanent|?{($_.c -ne "CA") -and (($_.crlbusinesssegment -eq $segment) -or ($_.crlbusinessunitdescription -eq $segment))}|select -expandproperty samaccountname))}
#geographic locations
$usersublist=$users|?{($_.crlgeographiclocationcode -ne $null) -and ($_.crlbusinesssegment -ne $null)}
$contingent=$usersublist|?{$_.employeetype -eq $ce}
$permanent=$usersublist|?{($_.employeetype -eq $fte) -or ($_.employeetype -eq $pte)}
#contingent
$groups=$contingent|select -expandproperty crlgeographiclocationcode|sort -unique
$groups|%{$location=$_;$hashtable.add(@(($gal[0]+$location+$co),($gal[1]+$location+$co)),@($contingent|?{$_.crlgeographiclocationcode -eq $location}|select -expandproperty samaccountname))}
#special cases - Wilmington DSA & RMS
$hashtable.add(@(($gal[0]+$wd+$co),($gal[1]+$wd+$co)),@($contingent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("DSA") -or ($_.crlbusinesssegment.contains("CRP") -and $_.crlbusinessunitdescription.contains("DSA")))}|select -expandproperty samaccountname))
$hashtable.add(@(($gal[0]+$wr+$co),($gal[1]+$wr+$co)),@($contingent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("RMS") -or ($_.crlbusinesssegment.contains("CRP") -and ($_.crlbusinessunitdescription.contains("RMS") -or $_.crlbusinessunitdescription.contains("CRIS"))))}|select -expandproperty samaccountname))
#permanent
$groups=$permanent|select -expandproperty crlgeographiclocationcode|sort -unique
$groups|%{$location=$_;$hashtable.add(@(($gal[0]+$location),($gal[1]+$location)),@($permanent|?{$_.crlgeographiclocationcode -eq $location}|select -expandproperty samaccountname))}
#special cases - Wilmington DSA & RMS
$hashtable.add(@(($gal[0]+$wd),($gal[1]+$wd)),@($permanent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("DSA") -or ($_.crlbusinesssegment.contains("CRP") -and $_.crlbusinessunitdescription.contains("DSA")))}|select -expandproperty samaccountname))
$hashtable.add(@(($gal[0]+$wr),($gal[1]+$wr)),@($permanent|?{($_.crlgeographiclocationcode -eq "Wilmington") -and ($_.crlbusinesssegment.contains("RMS") -or ($_.crlbusinesssegment.contains("CRP") -and ($_.crlbusinessunitdescription.contains("RMS") -or $_.crlbusinessunitdescription.contains("CRIS"))))}|select -expandproperty samaccountname))
#global HR
$usersublist=$users|?{$_.extensionattribute3 -ne $null}
$hashtable.add(@(($gah[0]),($gah[1])),@($usersublist|?{$_.extensionattribute3 -eq "HRS"}|select -expandproperty samaccountname))
#US HR
$hashtable.add(@(($gahu[0]),($gahu[1])),@($usersublist|?{($_.extensionattribute3 -eq "HRS") -and ($_.c -eq "US")}|select -expandproperty samaccountname))
#YASH
$hashtable.add(@(($gay[0]),($gay[1])),@($users|?{($_.departmentnumber -eq "419357") -or ($_.departmentnumber -eq "419358")}|select -expandproperty samaccountname))
#Syntel
$hashtable.add(@("Global Auto - Syntel","Global Employees - Syntel"),@($users|?{$_.title -eq "temporary syntel it"}|select -expandproperty samaccountname))
#Accenture
$hashtable.add(@("Global Auto - Accenture","Global Employees - Accenture"),@($users|?{$_.title -eq "temporary accenture it"}|select -expandproperty samaccountname))
#Insourcing Solutions
$hashtable.add(@("Global Auto - Insourcing Solutions","Global Employees - Insourcing Solutions"),@($users|?{@("NA04","NA05","NA30","EU04","EU05","EU30") -contains $_.crlbusinessunitcode}|select -expandproperty samaccountname))
#global Biologics
$hashtable.add(@("Global Auto - Biologics","Global Employees - Biologics"),@($users|?{@("AS12","EU12","NA12") -contains $_.crlbusinessunitcode}|select -expandproperty samaccountname))
#global managers
$hashtable.add(@(($gam[0]),($gam[1])),@($users|?{$_.directreports -ne $null}|select -expandproperty samaccountname))
#US managers
$hashtable.add(@(($gamu[0]),($gamu[1])),@($users|?{($_.directreports -ne $null) -and ($_.c -eq "US")}|select -expandproperty samaccountname))
#SAP Managers
$usersublist=@(get-adgroup -server $dc -filter{name -like "global apps - sap*"}|get-adgroupmember -server $dc|get-aduser -properties $userproperties)|sort samaccountname -unique
$hashtable.add(@(($gasm[0]+$o),($gasm[1]+$o)),@($usersublist|?{($_.directreports -ne $null) -and ($_.c -eq "CA")}|select -expandproperty samaccountname))
$hashtable.add(@(($gasm[0]+$eo),($gasm[1]+$eo)),@($usersublist|?{($_.directreports -ne $null) -and ($_.c -ne "CA")}|select -expandproperty samaccountname))
#PAI groups
$groups=get-adgroup -filter {name -like "global auto location*pai"}|select -expandproperty samaccountname
$hashtable.add(@(($gaa[0]+" - PAI"),($gaa[1]+" - PAI")),$groups)
#David Smith's organization (DRS35298)
function get-adindirectreport{
param ($identity)
    $user=get-aduser $identity -properties $userproperties
    if($user.enabled){
        $user
        $user.directreports|%{
            get-adindirectreport $_
        }
    }
}
$usersublist=get-adindirectreport drs35298
#all employees
$hashtable.add(@(($dso[0]),($dso[1])),($usersublist|select -expandproperty samaccountname))
#US only
$hashtable.add(@(($dso[0]+$us),($dso[1]+$us)),($usersublist|?{$_.c -eq "us"}|select -expandproperty samaccountname))
#WLM only
$hashtable.add(@(($dso[0]+$wlm),($dso[1]+$wlm)),($usersublist|?{$_.l -eq "Wilmington"}|select -expandproperty samaccountname))

#create/update the lists - correct any errors such as being hidden from the GAL etc
foreach($group in $hashtable.getenumerator()){
    $name=$group.key[0].replace(", ",",").replace(",","-")
    $dist=$group.key[1].replace(", ",",").replace(",","-")
    $members=$group.value
#child DL - created/updated and hidden from GAL
    $child=get-adgroup -filter {samaccountname -eq $name}
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
        if($child.name -eq "Global Auto All - PAI"){
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
            ("  has been updated at "+(get-date)+".")
        }
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
        if((get-distributiongroup $dist).acceptmessagesonlyfromdlmembers){
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
send-mailmessage -to "adscripts@crl.com" -from "GlobalAutoLists@crl.com" -subject ("Global Auto Lists Updated $when") -attachments "c:\temp\galv4.txt" -body ("run on ent-pr-utl-01<br><br>Global Auto lists updated $when") -bodyashtml -smtpserver smtp.cr.local
