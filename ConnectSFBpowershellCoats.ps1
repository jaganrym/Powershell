$credential = Get-Credential "1adjreddy@coats.com"
$session = New-PSSession -ConnectionUri "https://atvilyncfe.coatsad.com/OcsPowershell" -Credential $credential
Import-PsSession $session 