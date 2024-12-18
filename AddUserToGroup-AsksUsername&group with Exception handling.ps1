import-Module Activedirectory
$GName = Read-Host -Prompt "Group Name"
$UName = Read-Host -Prompt "Enter Login Name(CR ID) of user you want to add to group"

try
{
Add-ADGroupMember -Identity $GName -Members $Uname -ErrorAction stop
}
Catch
{
#Write-host 'There is some error, Check if group and user name are entered correctly There could be some other problem' -BackgroundColor Yellow -ForegroundColor Red
Write-host $error[0] -BackgroundColor yellow -ForegroundColor red
break 
}

Write-Host User $Uname added to group $Gname -nonewline -background "Yellow" -foreground "Red"

#$UpdatedCoolList = Get-Content \\FileShare\Location\CoolPeople.csv -ErrorAction stop
#Write-host $error[0] -BackgroundColor DarkCyan -ForegroundColor DarkBlue
#Get-ADGroup -filter {name -like "test*"} | select name

