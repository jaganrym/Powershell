Import-Csv C:\csv\Prodmigbatch2_extnattchange.csv |ForEach-Object {
    Set-ADUser $_.samAccountName -Replace @{
        ExtensionAttribute12 = $_.ExtensionAttribute12
        ExtensionAttribute6 = $_.ExtensionAttribute6
            }
            }