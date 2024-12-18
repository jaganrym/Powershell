$Computers = Get-Content "C:\PshInput\Servers.txt" | Sort

$ErrorActionPreference= 'silentlycontinue'

Start-Transcript -path "C:\temp\AVRegFix\serverlog.txt" -append

foreach ($Computer in $Computers){

	write-output "Working on $Computer"

   Invoke-Command -computername $Computer -ScriptBlock {

  #$info = Get-ComputerInfo $Computer
   
  #write-host Computer Information of $Computer $info -background "Yellow" -foreground "Red"
  try 
  {
  #Set-NetAdapterAdvancedProperty -Name Wi-Fi -DisplayName "Roaming Aggressiveness" -DisplayValue "4. Medium-High"
  #Get-NetAdapterAdvancedProperty Wi-Fi -DisplayName Roaming*  
  Get-DnsClientServerAddress
  } 

  catch
 {
 
 write-host $error(0) -ForegroundColor DarkRed -BackgroundColor DarkYellow
 }

}

 Sleep -Seconds 3

} 

Stop-Transcript