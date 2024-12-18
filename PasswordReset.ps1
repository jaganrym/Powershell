$date = get-date 02/01/2020

("Global-PasswordReset-Group8","Global-PasswordReset-Group8 - OQLF") | % `
    { Get-ADGroupMember $_ | select -ExpandProperty samaccountname | % `
        { $pwls = get-aduser $_ -Properties passwordlastset | select -ExpandProperty passwordlastset
            if($pwls -lt $date)
                {Set-ADUser -Identity $_ -ChangePasswordAtLogon $true}
            else 
                {}
        }
    }