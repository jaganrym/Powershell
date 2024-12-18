import-pssession (new-pssession -configurationname microsoft.exchange -connectionuri https://ps.outlook.com/powershell/ -authentication basic -allowredirection -credential (get-credential))

$grps=("email retention policy","email retention policy - oqlf")
$users=@()
$grps|%{$users+=((get-adgroup $_ -properties members).members|get-aduser)}

$count=0
$total=$users.count

$users|%{
    $count+=1
    $percent = [math]::round(100*$count/$total,2)
    write-progress -activity "Applying Email Retention Policy..." -percentcomplete $percent -currentoperation "$percent% complete" -status "$count of $total users processed"
    set-mailbox $_.userprincipalname -retentionpolicy "CRL - Standard Retention Policy"
}
write-progress -activity "Applying Email Retention Policy..." -completed
