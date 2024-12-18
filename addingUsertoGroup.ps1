# Import active directory module for running AD cmdlets
Import-module ActiveDirectory

#Store the data from UserList.csv in the $List variable
$List = Import-CSV C:\UserList.csv

#Loop through user in the CSV
ForEach ($User in $List)
{

#Add the user to the TestGroup1 group in AD
Add-ADGroupMember -Identity TestGroup1 -Member $User.username
}

