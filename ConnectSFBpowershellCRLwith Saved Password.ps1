<# Read-host - Reads a line of input from the console; -assecurestring - Indicates that the cmdlet displays asterisks (*) in place of the characters that the user types as input; ConvertFrom-SecureString - Converts a secure string to an encrypted standard string.#>

read-host -prompt "Enter password to be encrypted in mypassword.txt" -assecurestring | convertfrom-securestring | out-file C:\Pshinput\password.txt
# convertto-securestring Converts encrypted standard strings to secure strings. It can also convert plain text to secure strings. It is used with ConvertFrom-SecureString and Read-Host

$pass = cat C:\pshinput\password.txt | convertto-securestring  
#New-Object - Creates an instance of a Microsoft .NET Framework or COM object.                                                         

$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "jr39462@charlesriverlabs.com",$pass

$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Authentication Basic -AllowRedirection -Credential $mycred

Import-PSSession $O365Session