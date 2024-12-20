#Update the Wilmington IT and Global IT Distribution lists
CLS

Import-Module ActiveDirectory

Function AddToGroup { param ($users, $Group)
	foreach ($member in $users)
	 {
		$Login = $member.SamAccountName
		Add-ADGroupMember -Identity $Group -Members $Login
	}
}

$Group1 = "myPreclinical - All Users - OQLF"
$Group2 = "myPreclinical - All Users - Excluding OQLF"
$Group3 = "myPreclinical - Admins - OQLF"
$Group4 = "myPreclinical - Admins - Excluding OQLF"

# Clear the groups
$grps = $Group1, $Group2, $Group3, $Group4
foreach ($grp in $grps) { 
Get-ADGroupMember -Identity $grp | %{Remove-ADGroupMember -Identity $grp -Members $_ -Confirm:$false}
Set-ADGroup -Identity $grp -Description "Updated $(Get-Date)"
}

#Build the All Users Group

$AllUsers = @()
$AllOQLF = @()
$AllNonOQLF = @()
$AllUsers = get-adgroupmember -Identity 4gg-Portal_All_Users | SELECT-OBJECT SamAccountName, DistinguishedName

Foreach ($user in $AllUsers) {
    write-host $user.DistinguishedName
	If ($user.DistinguishedName -match 'OU=Terminated')
	{
	write-host "dropping.... "$user.DistinguishedName
	}
	ELSE
	{
		If ($user.DistinguishedName -match '-QC,')
		{
	   	$AllOQLF += $user
    	}
    	Else
    	{
       	$AllNonOQLF += $user
    	}
	}
}    
     
AddToGroup $AllOQLF $Group1
AddToGroup $AllNonOQLF $Group2

#Build the Admin Users Group

$AllUsers = @()
$AllOQLF = @()
$AllNonOQLF = @()
$AllUsers = get-adgroupmember -Identity 4gg-Portal_sysadmins | SELECT-OBJECT SamAccountName, DistinguishedName

write-host "Building Adminn groups"

Foreach ($user in $AllUsers) {
	If ($user.DistinguishedName -match "-QC,")
	{
	   $AllOQLF += $user
    }
    Else
    {
       $AllNonOQLF += $user
    }
}    
     
AddToGroup $AllOQLF $Group3
AddToGroup $AllNonOQLF $Group4