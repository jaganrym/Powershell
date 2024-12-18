# installing import excel module ( one time)
#Install-Module ImportExcel
#Import-Module ImportExcel

Get-Process | Export-Excel C:\PshoutPut\p32.xlsx -TitleFillPattern LightGrid -TitleBackgroundColor Red -TitleBold -Show -IncludePivotTable -PivotRows Company -PivotData @{Handles="sum"} -IncludePivotChart -ChartType PieExploded3D 
    