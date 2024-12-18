$Computers = Get-Content "C:\temp\AVRegFix\ServerNames.txt" | Sort

$ErrorActionPreference= 'silentlycontinue'


Start-Transcript -path "C:\temp\AVRegFix\serverlog.txt" -append

foreach ($Computer in $Computers){

	write-output "Working on $Computer"

    Invoke-Command -computername $Computer -ScriptBlock {

    New-Item -Name "QualityCompat"  -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"  -type Directory

    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Value "0" -PropertyType "DWord"


}

 Sleep -Seconds 3

}

Stop-Transcript