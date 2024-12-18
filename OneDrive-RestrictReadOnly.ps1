<#
.Synopsis

   Remove user NTFS permission from the folders

.DESCRIPTION

   Remove user NTFS permission from the folders
 
.EXAMPLE

Remove-Folderperm -Folder c:\temp -user mydomain\user1
   
#>

Function Remove-Folderperm

{

    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Valuefrompipeline = $true,
                   Position=0)]
       
        [string[]]$Folder,

                [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Valuefrompipeline = $true,
                   Position=1)]
       
        [string[]]$user

       
    )


$permission = (Get-Acl $Folder).Access | ?{$_.IdentityReference -like $User} | Select IdentityReference,FileSystemRights
If ($permission){
$permission | % {Write-Host "User $($_.IdentityReference) has '$($_.FileSystemRights)' rights on folder $folder"}

$acl = Get-Acl $folder
$access = $acl.Access

foreach ($a in $access)

{

$ids = $a.IdentityReference.Value

foreach ($id in $ids)

{


if ($id -eq $user) 

{
write-host $user
$acl = Get-Acl $folder
$access = $acl.Access


$f = Convert-Path $acl.PSPath

$acl.RemoveAccessRule($a)
#$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$user","ReadAndExecute","ContainerInherit, objectinherit", "none", "Allow")
$acl.SetAccessRule($AccessRule)


Set-Acl -path $f -aclObject $acl | Out-Null

}
}
}



}
Else {
"$User Doesn't have any permission on $Folder" | Out-File -FilePath C:\Temp\perm.txt -Append
<#
$f = Convert-Path $acl.PSPath

$acl.RemoveAccessRule($a)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$user","ReadAndExecute","ContainerInherit, objectinherit", "none", "Allow")
$acl.SetAccessRule($AccessRule)


Set-Acl -path $f -aclObject $acl | Out-Null
#>
}



}



$content = Import-Csv -Path C:\Temp\ODNTFS.csv
$content | % {
Remove-Folderperm -Folder $_.FolderPath -user $_.Account} 
