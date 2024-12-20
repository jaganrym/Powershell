cls

import-module ActiveDirectory

#get list of accounts for EMEIA
$acctList = Get-ADUser -filter {(employeeID -gt "0")} -SearchBase "ou=EMEIA,dc=cr,dc=local"

foreach($account in $AcctList){
    Write-Host $account.sAMAccountName
    $Division = " "
    if ($account.distinguishedName -Match "Arbresle-FR") { $Division = "Arbresle-FR" }
    if ($account.distinguishedName -Match "Ballina-IE") { $Division = "Ballina-IE" }
    if ($account.distinguishedName -Match "Bangalore-IN") { $Division = "Bangalore-IN" }
    if ($account.distinguishedName -Match "Barcelona-ES") { $Division = "Barcelona-ES" }
    if ($account.distinguishedName -Match "Calco-IT") { $Division = "Calco-IT" }
    if ($account.distinguishedName -Match "Canterbury-UK") { $Division = "Canterbury-UK" }
    if ($account.distinguishedName -Match "Chatillon-FR") { $Division = "Chatillon-FR" }
    if ($account.distinguishedName -Match "Cologne-DE") { $Division = "Cologne-DE" }
    if ($account.distinguishedName -Match "Ecully-FR") { $Division = "Ecully-FR" }
    if ($account.distinguishedName -Match "Edinburgh-UK") { $Division = "Edinburgh-UK" }
    if ($account.distinguishedName -Match "Erkrath-DE") { $Division = "Erkrath-DE" }
    if ($account.distinguishedName -Match "Glenamoy-IE") { $Division = "Glenamoy-IE" }
    if ($account.distinguishedName -Match "Kisslegg-DE") { $Division = "Kisslegg-DE" }
    if ($account.distinguishedName -Match "Kuopio-FI") { $Division = "Kuopio-FI" }
    if ($account.distinguishedName -Match "Margate-UK") { $Division = "Margate-UK" }
    if ($account.distinguishedName -Match "Oxford-UK") { $Division = "Oxford-UK" }
    if ($account.distinguishedName -Match "Regional_ Accounts") { $Division = "Regional_ Accounts" }
    if ($account.distinguishedName -Match "Sulzfeld-DE") { $Division = "Sulzfeld-DE" }
    if ($account.distinguishedName -Match "Chesterford-UK") { $Division = "Chesterford-UK" }
    if ($account.distinguishedName -Match "Harlow-UK") { $Division = "Harlow-UK" }
    if ($account.distinguishedName -Match "Leiden-NL") { $Division = "Leiden-NL" }
    if ($account.distinguishedName -Match "Welwyn-UK") { $Division = "Welwyn-UK" }
    if ($account.distinguishedName -Match "Brussels-BE") { $Division = "Brussels-BE"}
    if ($account.distinguishedName -Match "Neuss-DE") { $Division = "Neuss-DE" }
    if($account.distinguishedname -match "Freiburg-DE"){$division="Freiburg-DE"}
    if($account.distinguishedname -match "DenBosch-NL"){$division="DenBosch-NL"}
    if($account.distinguishedname -match "Harrogate-UK"){$division="Harrogate-UK"}
    if($account.distinguishedname -match "Lyon-FR"){$division="Lyon-FR"}
    if($account.distinguishedname -match "Schaijk-NL"){$division="Schaijk-NL"}
    if($account.distinguishedname -match "Hatfield-UK"){$division="Hatfield-UK"}
    if($account.distinguishedname -match "Groningen-NL"){$division="Groningen-NL"}
    if($account.distinguishedname -match "Goettingen-DE"){$division="Goettingen-DE"}
    if($account.distinguishedname -match "Portishead-UK"){$division="Portishead-UK"}
    Set-ADUser -Identity $account.sAMAccountName -Division $Division
} 
	
#get list of accounts for APAC
$acctList = Get-ADUser -filter {(employeeID -gt "0")} -SearchBase "ou=APAC,dc=cr,dc=local"

foreach($account in $AcctList){
    Write-Host $account.sAMAccountName
    $Division = " "
    if ($account.distinguishedName -Match "Atsugi-JP") { $Division = "Atsugi-JP" }
    if ($account.distinguishedName -Match "Beijing-CN") { $Division = "Beijing-CN" }
    if ($account.distinguishedName -Match "Hino-JP") { $Division = "Hino-JP" }
    if ($account.distinguishedName -Match "Osaka-JP") { $Division = "Osaka-JP" }
    if ($account.distinguishedName -Match "Seoul-KR") { $Division = "Seoul-KR" }
    if ($account.distinguishedName -Match "Shanghai-CN") { $Division = "Shanghai-CN" }
    if ($account.distinguishedName -Match "Tsukuba-JP") { $Division = "Tsukuba-JP" }
    if ($account.distinguishedName -Match "Vertex-SG") { $Division = "Vertex-SG" }
    if ($account.distinguishedName -Match "Yokohama-JP") { $Division = "Yokohama-JP" }
    if ($account.distinguishedName -Match "Zhanjiang-CN") { $Division = "Zhanjiang-CN" }	
    Set-ADUser -Identity $account.sAMAccountName -Division $Division
} 
	
#get list of accounts for Americas
$acctList = Get-ADUser -filter {(employeeID -gt "0")} -SearchBase "ou=Americas,dc=cr,dc=local" -properties departmentnumber

foreach($account in $AcctList){
    Write-Host $account.sAMAccountName
    $Division = " "
    if ($account.distinguishedName -Match "Alamogordo-NM") { $Division = "Alamogordo-NM" }
    if ($account.distinguishedName -Match "Catskills-NY") { $Division = "Catskills-NY" }
    if ($account.distinguishedName -Match "Charleston-SC") { $Division = "Charleston-SC" }
    if ($account.distinguishedName -Match "Chicago-IL") { $Division = "Chicago-IL" }
    if ($account.distinguishedName -Match "Cleveland-OH") { $Division = "Cleveland-OH" }
    if ($account.distinguishedName -Match "Celsis-IL") { $Division = "Celsis-IL" }
    if ($account.distinguishedName -Match "Durham-NC") { $Division = "Durham-NC" }
    if ($account.distinguishedName -Match "Frederick-MD") { $Division = "Frederick-MD" }
    if ($account.distinguishedName -Match "Germantown-MD") { $Division = "Germantown-MD" }
    if ($account.distinguishedName -Match "Hollister-CA") { $Division = "Hollister-CA" }
    if ($account.distinguishedName -Match "Horsham-PA") { $Division = "Horsham-PA" }
    if ($account.distinguishedName -Match "Houston-TX") { $Division = "Houston-TX" }
    if ($account.distinguishedName -Match "Malvern-PA") { $Division = "Malvern-PA" }
    if ($account.distinguishedName -Match "Morrisville-NC") { $Division = "Morrisville-NC" }
    if ($account.distinguishedName -Match "Newark-DE") { $Division = "Newark-DE" }
    if ($account.distinguishedName -Match "NorthFranklin-CT") { $Division = "NorthFranklin-CT" }
    if ($account.distinguishedName -Match "Raleigh-NC") { $Division = "Raleigh-NC" }
    if ($account.distinguishedName -Match "Reno-NV") { $Division = "Reno-NV" }
    if ($account.distinguishedName -Match "Roanoke-IL") { $Division = "Roanoke-IL" }
    if ($account.distinguishedName -Match "SanDiego-CA") { $Division = "SanDiego-CA" }
    if ($account.distinguishedName -Match "Seattle-WA") { $Division = "Seattle-WA" }
    if ($account.distinguishedName -Match "Senneville-QC") { $Division = "Senneville-QC" }
    if ($account.distinguishedName -Match "Sherbrooke-QC") { $Division = "Sherbrooke-QC" }
    if ($account.distinguishedName -Match "Shrewsbury-MA") { $Division = "Shrewsbury-MA" }
    if ($account.distinguishedName -Match "Spencerville-OH") { $Division = "Spencerville-OH" }
    if ($account.distinguishedName -Match "StConstant-QC") { $Division = "StConstant-QC" }
    if ($account.distinguishedName -Match "StoneRidge-NY") { $Division = "StoneRidge-NY" }
    if ($account.distinguishedName -Match "Storrs-CT") { $Division = "Storrs-CT" }
    if ($account.distinguishedName -Match "Thetford-VT") { $Division = "Thetford-VT" }
    if($account.distinguishedname –match "Wilmington-MA"){
        if($account.departmentNumber –match "419357"){
            $Division="Hyderabad-IN"
	    Set-ADUser -Identity $account.sAMAccountName -office $Division
        }elseif($account.departmentNumber -match "419358"){
            $Division="Pune-IN"
	    Set-ADUser -Identity $account.sAMAccountName -office $Division
        }else{
            $Division="Wilmington-MA"
        }
    }
    if ($account.distinguishedname -match "Ashland-OH"){$division="Ashland-OH"}
    if ($account.distinguishedname -match "Boothwyn-PA"){$division="Boothwyn-PA"}
    if ($account.distinguishedname -match "Fairfield-NJ"){$division="Fairfield-NJ"}
    if ($account.distinguishedname -match "Hillsborough-NC"){$division="Hillsborough-NC"}
    if ($account.distinguishedname -match "Skokie-IL"){$division="Skokie-IL"}
    if ($account.distinguishedname -match "Woburn-MA"){$division="Woburn-MA"}
    if ($account.distinguishedname -match "WorcesterInnov-MA"){$division="WorcesterInnov-MA"}
    if ($account.distinguishedname -match "WorcesterUnion-MA"){$division="WorcesterUnion-MA"}
    if ($account.distinguishedname -match "Norwich-CT"){$division="NorthFranklin-CT"}
    if ($account.distinguishedname -match "SanFrancisco-CA"){$division="SanFrancisco-CA"}
    if ($account.distinguishedname -match "Mattawan-MI"){$division="Mattawan-MI"}
    Set-ADUser -Identity $account.sAMAccountName -Division $Division
}
 
 Send-MailMessage -to adscripts@crl.com -from ADScripts@crl.com -subject "UpdateDivision Completed" -body "run on ent-pr-uad-01<br><br>UpdateDivision Script Completed" -bodyashtml -SmtpServer smtp.cr.local
