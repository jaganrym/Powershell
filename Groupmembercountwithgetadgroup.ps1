
$date= Get-Date -Format "yyyy-MM-dd-hhmm"
$outfile = "c:\temp\GroupMemb_$($date).csv"
$errorfile = "c:\temp\ErrorAPSGroupMemb_$($date).log"
#select the nearest DC
$GC =  "GLINHY-SP400004.novartis.net:3268"
#$GC= "GLCHBS-SP400030.novartis.net:3268"
$groups = Get-Content "c:\temp\Group.txt"

$i=0
foreach($group in $groups)
{
    $result =@()
    $i = $i+1
    Write-host "$(get-date): Collecting membership of $($i) of $($groups.Count)"
    $grps = Get-ADGroup -Filter {name -eq $group} -Server $GC
    if($grps)
    {
        foreach($grp in $grps)
        {
        $domain = (($grp.DistinguishedName)  -split ("DC=",2) -replace ",DC=", ".")[1]
        $GroupName = $group
        $Rep = Get-ADGroup -Filter {name -eq $GroupName} -Server $domain -Properties name, SamAccountName, groupcategory, groupscope, CanonicalName, extensionAttribute15, members,whenChanged, whenCreated |`
        select @{l='domain';e={$($domain)}},Name,SamAccountName, 
@{Expression={$Group};Label=”Group Name”},groupcategory, groupscope, CanonicalName, extensionAttribute15,whenChanged, whenCreated, @{name='MembersCount';expression={$_.members.count}}
        $Rep | Export-Csv -NoTypeInformation -Append $outfile
        }
        
    }
    else
    {
        Add-Content -Path $errorfile -Value "$($group)"
    }
}
    Write-host "$(get-date): Finished collecting Group details" 
