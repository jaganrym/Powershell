


Import-Module GroupPolicy
Import-Module activedirectory

$ous=("Americas","APAC","EMEIA")
$selection = Get-ADOrganizationalUnit -SearchBase "ou=americas,dc=cr,dc=local" -SearchScope OneLevel -f * | select -ExpandProperty name
$regionpath = "ou=americas,dc=cr,dc=local"
function get-Response ($question,$answers){
    write-host $question,"`n"
    for ($loop=1;$loop -le $answers.count;++$loop){
        write-host "[$loop] ",$answers[$loop-1]
    }
    write-host
    do{
        $response = read-host "Please select a number between 1 and",$answers.count
    }until (($response -ge 1) -and ($response -le $answers.count))
    return $response
}

while ($selection -ne "Create OU Here"){

if($count -eq 1){$selection = $selection, "Create OU Here"
$selection = $selection[(get-response "Select the site for the new ou"($selection))-1]}
elseif($count -eq 0){$selection = "Create OU Here"
$selection = $selection[(get-response "Select the site for the new ou"($selection))-1]
}
else{
$selection
$selection = $selection[(get-response "Select the site for the new ou"($selection))-1]
if($newselection -eq $null){
$newselection = "ou=$selection,"
$path = $newselection+$regionpath
$selection = Get-ADOrganizationalUnit -SearchBase $path -SearchScope OneLevel -f * | select -ExpandProperty name
}
else{
$newselection = "ou=$selection," + $newselection
$path = $newselection+$regionpath
$selection = Get-ADOrganizationalUnit -SearchBase $path -SearchScope OneLevel -f * | select -ExpandProperty name
$count = $selection.count
}
}
}
 
#mainline
cls
$credential = get-credential 
$region = $ous[(get-response "Select the Region for the new site" ("Americas","APAC","EMEIA"))-1]
if ($region -eq "americas"){
$site = $americas[(get-response "Select the site for the new ou"($americas))-1]
$site = read-host "Enter the site name, for example Edinburgh-UK"
$language=$languages[(get-Response "Are French GPOs required" ("Yes","No"))-1]
 
$regionpath = "ou=$region,dc=cr,dc=local"
$sitepath = "ou=$site,"+$regionpath
$dlpath = "ou=$region,ou=distribution lists,dc=cr,dc=local"
$resourcepath = "ou=$region,ou=resource accounts,dc=cr,dc=local"
$resourcesitepath = "ou=$site,"+$resourcepath
$serverpath = "ou=servers,dc=cr,dc=local"
$serversitepath = "ou=$site,"+$serverpath