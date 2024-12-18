$Cred = Get-Credential
Connect-AzureAD -Credential $Cred 

$groups = Get-AzureADGroup | Where-Object {$_.DirSyncEnabled -match 'True'}
$Result = @()
$groups | ForEach-Object {
$group = $_
Get-AzureADGroupMember -ObjectId $group.ObjectId | ForEach-Object {
$member = $_
$Result += New-Object PSObject -property @{ 
GroupName = $group.DisplayName
Member = $member.DisplayName
UserPrincipalName = $member.UserPrincipalName
}
}
}
$Result | Select GroupName,Member,UserPrincipalName
$Result | Export-CSV "C:\Users\Microsoft Local\Downloads\UserPrss.csv" -NoTypeInformation -Encoding UTF8 
