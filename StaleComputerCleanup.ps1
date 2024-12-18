$daysinactive = 74
$time = (get-date).AddDays(-($daysinactive))
$date = Get-Date
$computers = @()
New-Item E:\AutomationJobs\Output\stalecomputers.csv -ItemType File -Force
("Americas","EMEIA","APAC") | % { 
    $DNs = Get-ADOrganizationalUnit -SearchBase "ou=$_,DC=cr,DC=local" -f {name -like "*standard*"} | select -ExpandProperty distinguishedname
        foreach($DN in $DNs) {
            get-adcomputer -SearchBase $DN -f {lastlogontimestamp -lt $time} -properties lastlogontimestamp, lastlogondate | %{
                $compinfo = New-Object psobject -Property @{
                    ComputerName = $_.name
                    DistinguishedName = $_.distinguishedname
                    LastLogonDate = $_.lastlogondate
                    }
                $compinfo | Export-Csv -Append -NoTypeInformation -Path E:\AutomationJobs\Output\stalecomputers.csv
                Move-ADObject $_.distinguishedname -TargetPath "OU=Terminated STANDARD Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -Confirm:$false
#working		
	<#	Disable-ADAccount $_
            	$description = get-adcomputer $_ -Properties description | select -ExpandProperty description
            	$newdescription = "Stale Account Disabled $date $description"
            	set-aduser $_ -Description $newdescription                
		Set-ADComputer $_.samaccountname -Description "Stale Computer, not logged into for 60+ days $date"     #>
            }
        }
    }


$daysinactive = 120
$time = (get-date).AddDays(-($daysinactive))
$date = Get-Date
            get-adcomputer -SearchBase "OU=Terminated STANDARD Computers,OU=Terminated Computers,DC=CR,DC=LOCAL" -f {(lastlogontimestamp -lt $time) -and (enabled -eq $true)} | %{
                Set-ADComputer $_.samaccountname -Enabled $false
            }