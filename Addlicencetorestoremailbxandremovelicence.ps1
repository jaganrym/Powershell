#establish connections
Connect-MsolService
Connect-ExchangeOnline

#file with all accounts to modify as UPN
$accounts = gc C:\Temp\accounts.txt

#breaks down the list of accounts into arrays of 100
for ($i = 0; $i -lt $accounts.count; $i += 100) { $array += ,@($accounts[$i..($i+99)]);}

#sets usage location, license and mailbox type one array at a time and then removes the license before doing the next array
while ($count -ne $array.count){
    $array[$count] | % {
                        try{ write-host ("setting things up " + $($_))
                            set-msoluser -userprincipalname $($_) -Usagelocation US;
                            set-msoluserlicense -userprincipalname $($_) -addlicenses "charlesriverlabs:ENTERPRISEPACK";
                            get-mailbox $($_) | set-mailbox -type shared;
                        }
                        catch{
                            $output = ($($account) + " " + $($_))
                            $output | out-file c:\temp\errors.txt -append
                        }
    }
    $array[$count] | % {
                        try{ write-host ("Finishing things up " + $($_))
                            set-msoluserlicense -userprincipalname $($_) -removelicenses "charlesriverlabs:ENTERPRISEPACK"
                        }
                        catch{
                            $output = ($($account) + " " + $($_))
                            $output | out-file c:\temp\errors.txt -append
                        }
    }
$count += 1
}
