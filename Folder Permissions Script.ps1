$AllFolders = Get-ChildItem -Directory -Path "D:\" -Recurse -Force | where-object {($_.PsIsContainer)}
$Results = @()
Foreach ($Folder in $AllFolders) {
    $Acl = Get-Acl -Path $Folder.FullName
    foreach ($Access in $acl.Access) {
        if ($Access.IdentityReference -notlike "BUILTIN\Administrators" -and $Access.IdentityReference -notlike "domain\Domain Admins" -and $Access.IdentityReference -notlike "CREATOR OWNER" -and $access.IdentityReference -notlike "NT AUTHORITY\SYSTEM" -and $Access.FileSystemRights -notlike "-536805376" ) {
            $Properties = [ordered]@{'FolderName'=$Folder.FullName;'AD Group'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}
            $Results += New-Object -TypeName PSObject -Property $Properties
        }
    }
}

$Results | Export-Csv -path "C:\Users\ramaswamy.reddy\Ddrive- $(Get-Date -format ddMMyyyy).csv" -NoTypeInformation


