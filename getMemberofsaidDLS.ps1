
$groups = Get-Content C:\input\ITDLSbatch2input.csv

foreach($Group in $Groups)
{
get-adgroup $Group -Properties * | select name, @{ name = "MemberOf"; expression = { $_.memberof -join ";" } } | Export-csv C:\output\ITDLbatch2membreoffinal.csv -append -NoTypeInformation
} 