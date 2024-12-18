<# Where or Where object Selects objects from a collection based on their property values.#>

#Where object Examples
import-csv "C:\My Data\DL Migration Project\ITDLs".csv
#Displays DLs Starting with IT
$list = Get-DistributionGroup -ResultSize 10000 | where{$_.name -like "IT*"}
#Displays DLs ends with offshore
$list = Get-DistributionGroup -ResultSize 10000 | where{$_.name -like "*offshore"}

Get-Service | Where-Object {$_.Status -eq "Stopped"}

