$cred=get-credential dougthompson@charlesriverlabs.onmicrosoft.com
import-pssession (new-pssession -configurationname microsoft.exchange -connectionuri https://ps.outlook.com/powershell/ -credential $cred -authentication basic -allowredirection)
connect-msolservice

$termedusers = get-ADUser -filter * -searchbase "ou=termuserskeep,ou=resource accounts,dc=cr,dc=local" -searchscope subtree -properties *
$termedusers | select samaccountname,employeeid,emailaddress,userprincipalname | export-csv -path "c:\temp\termedusers.csv" -notypeinformation

function NewObject($User) {
    $Object = new-object psobject
    $Object | add-member -membertype noteproperty -name "Username" -value $User.Name
    $Object | add-member -membertype noteproperty -name "Account" -value $user.samaccountname
    $Object | add-member -membertype noteproperty -name "Email" -value $user.userprincipalname
    $Object
}

$NoMailbox = @()
$Unlicensed = @()
$KioskLicense = @()
$ExchangeLicense = @()
$E3License = @()
$E4License = @()

foreach($user in $termedusers){
    if ($user.userprincipalname -match "@charlesriverlabs.com"){
        $MSOLUser = get-msoluser -userprincipalname ($user.userprincipalname)
        if ($MSOLUser.islicensed){
            $user.samaccountname
            "   converting to shared"
            set-mailbox $user.samaccountname -type shared
                $msoluser.licenses.accountskuid|%{
                "   removing $_"
                set-msoluserlicense -userprincipalname $msoluser.userprincipalname -removelicenses $_
            }
        }
    }
}



$users=@();("APAC","Americas","EMEIA")|%{$users+=get-aduser -filter * -properties * -searchbase "ou=$_,dc=cr,dc=local"}




$i=0
$deletedusers|%{
    ++$i
    if($_.islicensed){
        $x=$_.userprincipalname
        $x
        restore-msoluser -userprincipalname $x
        $_.licenses.accountskuid|%{
            "   $_"
            set-msoluserlicense -userprincipalname $x -removelicenses $_
        }
        remove-msoluser -userprincipalname $x -force
    }
}
$i