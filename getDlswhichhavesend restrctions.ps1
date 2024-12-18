$list = Get-DistributionGroup -Resultsize 1000 | where{$_.AcceptMessagesOnlyFrom -ne $null -or $_.AcceptMessagesOnlyFromDLMembers -ne $null -or $_.AcceptMessagesOnlyFromSendersOrMembers -ne $null}

$list = Get-DistributionGroup -ResultSize 100 | where{$_.name -
get-distributiongroup |? {!(get-distributiongroupmember $_.PrimarySMTPAddress).count}

$out = foreach($dl in $list){
"List: $($dl.name)"
if($dl.AcceptMessagesOnlyFrom){"Users:"; $dl.AcceptMessagesOnlyFrom}
if($dl.AcceptMessagesOnlyFromDLMembers){"Groups:"; $dl.AcceptMessagesOnlyFromDLMembers}
""
}

$out | Out-File -FilePath c:\temp\acceptmail.txt -encoding ascii

<#Notes
#Origionally I had AcceptMessagesOnlyFromSendersOrMembers above, but I didn't find any data that wasn't contained in AcceptMessagesOnlyFromDLMembers and AcceptMessagesOnlyFrom
#if($dl.AcceptMessagesOnlyFromSendersOrMembers){"OnlyFrom:"; $dl.AcceptMessagesOnlyFromSendersOrMembers}

#Verification that AcceptMessagesOnlyFromSendersOrMembers is just a concatenation of the other two properties
foreach($dl in $list){
"List: $($dl.name)"
compare ($dl.AcceptMessagesOnlyFromSendersOrMembers) ($dl.AcceptMessagesOnlyFromDLMembers + $dl.AcceptMessagesOnlyFrom)
}
#>