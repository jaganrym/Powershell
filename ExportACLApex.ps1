
$AllFolders = Get-ChildItem -Directory -Path "\\vmadt002\123\" -Recurse -Force

$Results = @()

$TotalItems=$allfolders.Count

$CurrentItem = 0

$PercentComplete = 0

Foreach ($Folder in $AllFolders) {

Write-Progress -Activity "Collecting Folder Permission" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete

$a = $Folder.FullName

$c = $a.Substring(2)

$b = "\\?\unc\$c"

$Acl = Get-Acl -Path "$b"

    foreach ($Access in $acl.Access) {

        if ($Access.IdentityReference -notlike "BUILTIN\Administrators" -and $Access.IdentityReference -notlike "domain\Domain Admins" -and $Access.IdentityReference -notlike "CREATOR OWNER" -and $access.IdentityReference -notlike "NT AUTHORITY\SYSTEM" -and $Access.FileSystemRights -notlike "-536805376" ) {

            $Properties = [ordered]@{'FolderName'=$b;'AD Group'=$Access.IdentityReference;'Permissions'=$Access.FileSystemRights;'Inherited'=$Access.IsInherited}

            $Results += New-Object -TypeName PSObject -Property $Properties

        }

    }

$CurrentItem++

$PercentComplete = [int](($CurrentItem / $TotalItems) * 100)

}

$results | export-csv c:\users\------------\filename.csv -NoTypeInformation