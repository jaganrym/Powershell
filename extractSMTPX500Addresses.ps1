et-ADUser -Filter * -SearchBase '<OU-Location>' -Properties proxyaddresses | Select-Object Name, @{ L = "ProxyAddresses"; E = { $_.ProxyAddresses -join ";" | Where-Object { ProxyAddresses -eq "*smtp:*" } } } | Export-Csv -Path "<Path>" –NoTypeInformation

{($_.ProxyAddresses | Where-Object {$_ -like "*smtp:*" }) -join ';'}