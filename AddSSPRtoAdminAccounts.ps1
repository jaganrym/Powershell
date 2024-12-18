<#
Add 4GG-SSPR group to new admin accounts
Enables admin accounts to use SSPR tool

Joshua Colbert 30 Dec 2019
#>


#Get all admin accounts and groups they are a member of
$results = @()
$users = Get-ADUser -SearchBase "ou=admin,dc=cr,dc=local" -Properties memberof -Filter * 
foreach ($user in $users) {
    $groups = $user.memberof -join ';'
    $results += New-Object psObject -Property @{'User'=$user.samaccountname;'Groups'= $groups}
    }

#Select all admin accounts that are not in the Domain Admin group
$admins = $results | Where-Object { $_.groups -notmatch 'Domain Admins' } | Select-Object -ExpandProperty user

#Select all admin accounts 
$alladmins = $results | Select-Object -ExpandProperty user

#Get all current members of 4GG-SSPR
$SSPRmembers = Get-ADGroupMember -Identity 4GG-SSPR -Recursive | select -ExpandProperty samaccountname

#Get all current members of SGG-PSOAdm
$PSOAdmmembers = Get-ADGroupMember -Identity SGG-PSOAdm -Recursive | select -ExpandProperty samaccountname

#Adds 4GG-SSPR group to accounts that are not a member and are not a domain admin
$admins | % { 
if ($SSPRmembers -contains $_){
    }
    else{
        Add-ADGroupMember -Identity 4gg-sspr -Members $_
    }
    }

#Adds SGG-PSOAdm group to accounts that are not a member and are not a domain admin
$alladmins | % { 
if ($PSOAdmmembers -contains $_){
    }
    else{
        Add-ADGroupMember -Identity SGG-PSOAdm -Members $_
    }
    }