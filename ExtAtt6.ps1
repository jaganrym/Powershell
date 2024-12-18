#get all users with correct attributes
$users = ("Americas","EMEIA","APAC") | % { get-aduser -f * -SearchBase "ou=$_,dc=cr,dc=local" -Properties extensionattribute6, co }

#if extensionattribute6 needs to be added or updated it will be, otherwise nothing happens    
$users | % {
    $site=((($_.distinguishedname) -split ",*..=")[3])+", "+$_.co
    if ($_.extensionattribute6 -ne $site){set-aduser $_.samaccountname -clear "extensionattribute6"
    start-sleep -s 2
    Set-ADUser $_.samAccountName -add @{ExtensionAttribute6 = "$($site)"}} 
    }

#the end