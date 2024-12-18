Import-Csv 'C:\PshInput\pending users unhidegal.csv' | ForEach-Object {
$samaccountname = $_."samaccountname"
Set-remoteMailbox -Identity $samaccountname -HiddenFromAddressListsEnabled $false
}

Import-Csv 'C:\PshInput\pending users unhidegal.csv' | ForEach-Object {
$samaccountname = $_."samaccountname"
get-remoteMailbox -Identity $samaccountname | select name,HiddenFromAddressListsEnabled
}

get-remoteMailbox -Identity cr201659 | GM

Import-Csv 'C:\PshInput\lavalcrIds.csv' | ForEach-Object {
$samaccountname = $_."samaccountname"
get-remoteMailbox -Identity $samaccountname | select name,HiddenFromAddressListsEnabled,ForwardingsmtpAddress,city
} | export-csv C:\PshoutPut\lavalforwardingaddress1.csv

get-remoteMailbox -Identity cr201659 | select name,ForwardingAddress