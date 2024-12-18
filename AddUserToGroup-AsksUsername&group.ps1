import-Module Activedirectory
$GName = Read-Host -Prompt "Group Name"
$UName = Read-Host -Prompt "Enter Login Name(CR ID) of user you want to add to group"
Add-ADGroupMember -Identity $GName -Members $Uname
Write-host $error[0] -BackgroundColor DarkCyan -ForegroundColor DarkBlue
Write-Host User $Uname added to group $Gname -nonewline -background "Yellow" -foreground "Red"

