
Import-Module ActiveDirectory
Set-ExecutionPolicy RemoteSigned -Confirm:$false
$concur = Import-Csv -Path C:\Users\cj46343\Desktop\Concur.csv 

$concur | % { $eid = $_.employeeid

$samaccountname = get-aduser -f {employeeid -like $eid} | select userprincipalname, name

if ($samaccountname -ne $null) {


$_ | Add-Member -MemberType NoteProperty -Name UserPrincipalName -Value $samaccountname.userprincipalname -PassThru | 
Add-Member -MemberType NoteProperty -Name name -Value $samaccountname.name -PassThru | Export-Csv -Path C:\Temp\concur.csv -Append }
else { $_ | Export-Csv -Path C:\Temp\concurno.csv -Append }
}



<#
if ($_.From -like $null){
$Samaccountname = get-aduser $_.to.split("\")[1] -Properties office, emailaddress | select name, office, emailaddress 
$_ | Add-Member -MemberType NoteProperty -Name name -Value $Samaccountname.name -PassThru |
Add-Member -MemberType noteproperty -name office -Value $Samaccountname.office -PassThru |
Add-Member -MemberType NoteProperty -Name emailaddress -Value $Samaccountname.emailaddress -PassThr}
Else {
$Samaccountname = get-aduser $_.from.split("\")[1] -Properties office, emailaddress | select name, office, emailaddress 
$_ | Add-Member -MemberType NoteProperty -Name name -Value $Samaccountname.name -PassThru |
Add-Member -MemberType noteproperty -name office -Value $Samaccountname.office -PassThru |
Add-Member -MemberType NoteProperty -Name emailaddress -Value $Samaccountname.emailaddress -PassThr}
} | Export-Csv C:\temp\UpdatedReport.csv
#>