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


$acl = Get-Acl $folder
$access = $acl.Access



#$acl.AddAccessRule($a)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$user","ReadAndExecute","ContainerInherit, objectinherit", "none", "Allow")
$acl.SetAccessRule($AccessRule)


Set-Acl -path $Folder -aclObject $acl | Out-Null



}


$totals = Get-Content -Path C:\Temp\ODNTFS.csv | Measure-Object -Line
$total = $totals.Lines
$count = 1

$content = Import-Csv -Path C:\Temp\ODNTFS.csv
$content | % {
 $count += 1
    $percent = [math]::round(100*$count/$total,2)
    Write-Progress -Activity "Processing User Accounts..." -PercentComplete $percent -CurrentOperation "$percent% complete" -status "$count of $total users processed"
Remove-Folderperm -Folder $_.FolderPath -user $_.Account}



