Get-GPO -All -Domain "sales.contoso.com" | Get-GPOReport $._ -ReportType html -Path "C:\GPOReports\GPORep.html
