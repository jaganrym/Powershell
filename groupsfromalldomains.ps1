foreach ($domain in $domains) {

$Groups = Get-ADGroup -Filter { Name -like "*remote*"  } -Server $domain 
 }