<#Powershell Classes and Objects-get-date example#>
$GM = get-date | GM
$GM | Out-GridView
$now = get-date
$now.addyears(-37)
$now.year
$now.Millisecond
