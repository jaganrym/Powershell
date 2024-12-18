Get-NetIPAddress | select IPaddress
Get-NetIPConfiguration | select IPv4Address,DNSServer
Get-NetIPConfiguration -InterfaceAlias "wi-fi" | FL DnsServer
Get-DnsClientServerAddress -InterfaceAlias "Wi-fi" -AddressFamily IPv4
