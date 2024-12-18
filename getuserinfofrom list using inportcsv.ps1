Import-Csv C:\csv\Prodmigbatch2_extnattchange.csv |ForEach-Object {
    get-ADUser $_.userprincipalname -properties * | select mail,employeeID,UserPrincipalName} | Export-Csv c:\Data\missinglavaluser.csv


   Get-Group - | Where {$_.GroupType -eq "Global"} | Set-Group -Universal 

   
Get-ADgroup -SearchBase  "OU=Security_Groups,OU=Laval-QC,OU=Americas,dc=CR,DC=LOCAL" | Where {$_.GroupType -eq "Global"} | Set-adGroup -Universal 


             