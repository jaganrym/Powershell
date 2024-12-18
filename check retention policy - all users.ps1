import-pssession (new-pssession -configurationname microsoft.exchange -connectionuri https://ps.outlook.com/powershell/ -credential joshuacolbert@charlesriverlabs.onmicrosoft.com -authentication basic -allowredirection)

$users=@()
("Americas","APAC","EMEIA")|%{$users+=get-aduser -filter * -searchbase "ou=$_,dc=cr,dc=local" -properties emailaddress,created}

$nomailbox=@()
$default=@()
$standard=@()
$count = 0
$total =$users.count

$users|%{
    $count += 1
    $percent = [math]::round(100*$count/$total,2)
    Write-Progress -Activity "Processing User Accounts..." -PercentComplete $percent -CurrentOperation "$percent% complete" -status "$count of $total users processed"
    if ($_.emailaddress -eq $null){
        $nomailbox+=$_
    }else{
        if (((get-mailbox $_.userprincipalname).retentionpolicy) -eq "Default MRM Policy"){
            $default+=$_
            Write-Host "DEFAULTTTTTTTTTTTTTTTTTTT"
        }else{
            $standard+=$_
            Write-Host "STANDARD"
        }
    }
}
write-progress -Activity "Processing User Accounts..." -completed

"users with no mailbox: "+$nomailbox.count
"users with default retention policy: "+$default.count
"users with CRL Standard retention policy: "+$standard.count
