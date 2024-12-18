function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Configuring" -Status "Please wait..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}


Import-Module GroupPolicy
Import-Module activedirectory
$ous=("Americas","APAC","EMEIA")
$types=("New","Existing")
$languages=("Yes","No")
function get-Response ($question,$answers){
    write-host $question,"`n"
    for ($loop=1;$loop -le $answers.count;++$loop){
        write-host "[$loop] ",$answers[$loop-1]
    }
    write-host
    do{
        $response = read-host "Please select a number between 1 and",$answers.count
    }until (($response -ge 1) -and ($response -le $answers.count))
    return $response
}
 
#mainline
$credential = get-credential 
Get-Content -Path c:\temp\sites.txt | % {


cls

$type='existing'
$region = 'americas'
$site = $($_)
$language= 'no'
 
$regionpath = "ou=$region,dc=cr,dc=local"
$sitepath = "ou=$site,"+$regionpath
$dlpath = "ou=$region,ou=distribution lists,dc=cr,dc=local"
$resourcepath = "ou=$region,ou=resource accounts,dc=cr,dc=local"
$resourcesitepath = "ou=$site,"+$resourcepath
$serverpath = "ou=servers,dc=cr,dc=local"
$serversitepath = "ou=$site,"+$serverpath
 
#if new site create all OUs
if ($type -eq "new"){

Write-Host "Creating New OUs..."

#create main site OU
new-adorganizationalunit -path $regionpath -name $site -credential $credential 

#standard OUs
new-adorganizationalunit -path $sitepath -name "Standard" -credential $credential 
new-adorganizationalunit -path "ou=standard,$sitepath" -name "Desktops" -credential $credential 
new-adorganizationalunit -path "ou=desktops,ou=standard,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=standard,$sitepath" -name "Laptops" -credential $credential 
new-adorganizationalunit -path "ou=laptops,ou=standard,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=standard,$sitepath" -name "Tablets" -credential $credential 
new-adorganizationalunit -path "ou=tablets,ou=standard,$sitepath" -name "WIN10" -credential $credential 

#regulated OUs
new-adorganizationalunit -path $sitepath -name "Regulated" -credential $credential 
new-adorganizationalunit -path "ou=regulated,$sitepath" -name "Desktops" -credential $credential 
new-adorganizationalunit -path "ou=desktops,ou=regulated,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=regulated,$sitepath" -name "Laptops" -credential $credential 
new-adorganizationalunit -path "ou=laptops,ou=regulated,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=regulated,$sitepath" -name "Tablets" -credential $credential 
new-adorganizationalunit -path "ou=tablets,ou=regulated,$sitepath" -name "WIN10" -credential $credential 

#security group and users OU
new-adorganizationalunit -path $sitepath -name "Security_Groups" -credential $credential 
new-adorganizationalunit -path $sitepath -name "Users" -credential $credential 

#create distributin list OU
new-adorganizationalunit -path $dlpath -name $site -credential $credential 
 
#create resource OUs
new-adorganizationalunit -path $resourcepath -name $site -credential $credential 
new-adorganizationalunit -path $resourcesitepath -name "Projects" -credential $credential 
new-adorganizationalunit -path $resourcesitepath -name "Resources" -credential $credential 
new-adorganizationalunit -path $resourcesitepath -name "Shared" -credential $credential 

#create server OUs
New-ADOrganizationalUnit -Path $serverpath -Name $site -Credential $credential 
New-ADOrganizationalUnit -Path $serversitepath -Name "Non-Regulated" -Credential $credential 
New-ADOrganizationalUnit -Path $serversitepath -Name "Regulated" -Credential $credential 
New-ADOrganizationalUnit -Path $serversitepath -Name "Terminal Servers" -Credential $credential 


#GPO Block Inheritence on Regulated OUs
Set-GPinheritance -Target "ou=regulated,$sitepath" -IsBlocked Yes 
Set-GPinheritance -Target "ou=Regulated,$serversitepath" -IsBlocked Yes 
Set-GPinheritance -Target "ou=Terminal Servers,$serversitepath" -IsBlocked Yes

Start-Sleep -Seconds 15

#Add default GPOs
#Adds default GPOs for sites in Americas
If ($region -eq "Americas")
    {

        #region > Site 
        New-GPLink -Name "MultiOU-Certificate Autoenrollment User" -Target $sitepath
        New-GPLink -Name "MultiOU-EventForwarding-America" -Target $sitepath -Enforced Yes
        #New-GPLink -Name "MultiOU-SSID8021xemployees" -Target "$sitepath"
        #French version required, yes/no
        if ($language -eq "Yes"){
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-French and English" -Target "$sitepath" 
            }
            Else {
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-English" -Target "$sitepath" 
            }    

            #region > Site > Standard

            #region > Site > Standard > Desktops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=desktops,ou=standard,$sitepath"

                #region > Site > Standard > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=desktops,ou=standard,$sitepath"

            #region > Site > Standard > Laptops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=laptops,ou=standard,$sitepath"

                #region > Site > Standard > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=laptops,ou=standard,$sitepath"

            #region > Site > Standard > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=standard,$sitepath"

                #region > Site > Standard > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=tablets,ou=standard,$sitepath"

        #region > Site > Regulated
        #New-GPLink -Name "MultiOU-Computer Block Internet" -Target "ou=regulated,$sitepath"

            #region > Site > Regulated > Desktops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=desktops,ou=regulated,$sitepath"

                #region > Site > Regulated > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=desktops,ou=regulated,$sitepath"

            #region > Site > Regulated > Laptops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=laptops,ou=regulated,$sitepath"

                #region > Site > Regulated > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=laptops,ou=regulated,$sitepath"

            #region > Site > Regulated > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=regulated,$sitepath"

                #region > Site > Regulated > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=tablets,ou=regulated,$sitepath"

        #Servers > Site
        New-GPLink -Name "MultiOU-NA-Servers WSUS Configuration" -Target $serversitepath 

        #Servers > Site > Non-Regulated
        New-GPLink -Name "TS/RDS Config For Citrix -US ,Canada" -Target "ou=Non-Regulated,$serversitepath" 

        #Servers > Site > Regulated
        New-GPLink -Name "TS/RDS Config For Citrix -US ,Canada" -Target "ou=Regulated,$serversitepath" 
        New-GPLink -Name "Global-Server Config" -Target "ou=regulated,$serversitepath" -Enforced Yes

        #Servers > Site > Terminal Servers 
        New-GPLink -Name "Global-Trusted Sites" -Target "ou=Terminal Servers,$serversitepath" 
        New-GPLink -Name "TS/RDS Config For Citrix -US ,Canada" -Target "ou=Terminal Servers,$serversitepath" 
        New-GPLink -Name "Global-Server Citrix Terminal Services Session Timeouts" -Target "ou=Terminal Servers,$serversitepath"
    }

#Adds default GPOs for sites in APAC or EMEI
Else{

        #region > Site 
        New-GPLink -Name "MultiOU-Certificate Autoenrollment User" -Target $sitepath
        New-GPLink -Name "MultiOU-EventForwarding-EMEIA" -Target $sitepath -Enforced Yes
        #New-GPLink -Name "MultiOU-SSID8021xemployees" -Target "$sitepath"

        #French version required, yes/no
        if ($language -eq "Yes"){
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-French and English" -Target "$sitepath" 
            }
            Else {
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-English" -Target "$sitepath" 
            }         

            #region > Site > Standard

            #region > Site > Standard > Desktops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=desktops,ou=standard,$sitepath"

                #region > Site > Standard > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=desktops,ou=standard,$sitepath"

            #region > Site > Standard > Laptops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=laptops,ou=standard,$sitepath"

                #region > Site > Standard > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=laptops,ou=standard,$sitepath"

            #region > Site > Standard > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=standard,$sitepath"

                #region > Site > Standard > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=tablets,ou=standard,$sitepath"

        #region > Site > Regulated
        #New-GPLink -Name "MultiOU-Computer Block Internet" -Target "ou=regulated,$sitepath"

            #region > Site > Regulated > Desktops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=desktops,ou=regulated,$sitepath"

                #region > Site > Regulated > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=desktops,ou=regulated,$sitepath"

            #region > Site > Regulated > Laptops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=laptops,ou=regulated,$sitepath"

                #region > Site > Regulated > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=laptops,ou=regulated,$sitepath"

            #region > Site > Regulated > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=regulated,$sitepath"

                #region > Site > Regulated > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=tablets,ou=regulated,$sitepath"
         
        #Servers > Site
        New-GPLink -Name "MultiOU-EU-Servers WSUS Configuration" -Target $serversitepath 

        #Servers > Site > Non-Regulated
        New-GPLink -Name "TS/RDS Config for Citrix EDI" -Target "ou=Non-Regulated,$serversitepath" 

        #Servers > Site > Regulated
        New-GPLink -Name "TS/RDS Config for Citrix EDI" -Target "ou=Regulated,$serversitepath" 
        New-GPLink -Name "Global-Server Config" -Target "ou=regulated,$serversitepath" -Enforced Yes 

        #Servers > Site > Terminal Servers 
        New-GPLink -Name "Global-Trusted Sites" -Target "ou=Terminal Servers,$serversitepath"
        New-GPLink -Name "TS/RDS Config for Citrix EDI" -Target "ou=Terminal Servers,$serversitepath" 
        New-GPLink -Name "Global-Server Citrix Terminal Services Session Timeouts" -Target "ou=Terminal Servers,$serversitepath"
}



}

#Creates OUs and GPOs if OU already exists
else {
#standard OUs
Write-Host "Creating New OUs..."
new-adorganizationalunit -path $sitepath -name "Standard" -credential $credential 
new-adorganizationalunit -path "ou=standard,$sitepath" -name "Desktops" -credential $credential 
new-adorganizationalunit -path "ou=desktops,ou=standard,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=standard,$sitepath" -name "Laptops" -credential $credential 
new-adorganizationalunit -path "ou=laptops,ou=standard,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=standard,$sitepath" -name "Tablets" -credential $credential 
new-adorganizationalunit -path "ou=tablets,ou=standard,$sitepath" -name "WIN10" -credential $credential 

#regulated OUs
new-adorganizationalunit -path $sitepath -name "Regulated" -credential $credential 
new-adorganizationalunit -path "ou=regulated,$sitepath" -name "Desktops" -credential $credential 
new-adorganizationalunit -path "ou=desktops,ou=regulated,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=regulated,$sitepath" -name "Laptops" -credential $credential 
new-adorganizationalunit -path "ou=laptops,ou=regulated,$sitepath" -name "WIN10" -credential $credential 
new-adorganizationalunit -path "ou=regulated,$sitepath" -name "Tablets" -credential $credential 
new-adorganizationalunit -path "ou=tablets,ou=regulated,$sitepath" -name "WIN10" -credential $credential 

Start-Sleep -Seconds 15

#Block Inheritance
Set-GPinheritance -Target "ou=regulated,$sitepath" -IsBlocked Yes

#Add default GPOs
#Adds default GPOs for sites in Americas
If ($region -eq "Americas")
    {
        #region > Site 
        New-GPLink -Name "MultiOU-Certificate Autoenrollment User" -Target $sitepath
        New-GPLink -Name "MultiOU-EventForwarding-America" -Target $sitepath -Enforced Yes
        #New-GPLink -Name "MultiOU-SSID8021xemployees" -Target "$sitepath"

        #French version required, yes/no
        if ($language -eq "Yes"){
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-French and English" -Target "$sitepath" 
            }
            Else {
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-English" -Target "$sitepath" 
            }         

            #region > Site > Standard

            #region > Site > Standard > Desktops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=desktops,ou=standard,$sitepath"

                #region > Site > Standard > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=desktops,ou=standard,$sitepath"

            #region > Site > Standard > Laptops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=laptops,ou=standard,$sitepath"

                #region > Site > Standard > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=laptops,ou=standard,$sitepath"

            #region > Site > Standard > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=standard,$sitepath"

                #region > Site > Standard > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=tablets,ou=standard,$sitepath"

        #region > Site > Regulated
        #New-GPLink -Name "MultiOU-Computer Block Internet" -Target "ou=regulated,$sitepath"

            #region > Site > Regulated > Desktops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=desktops,ou=regulated,$sitepath"

                #region > Site > Regulated > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=desktops,ou=regulated,$sitepath"

            #region > Site > Regulated > Laptops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=laptops,ou=regulated,$sitepath"

                #region > Site > Regulated > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=laptops,ou=regulated,$sitepath"

            #region > Site > Regulated > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=regulated,$sitepath"

                #region > Site > Regulated > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=tablets,ou=regulated,$sitepath"
 }

 #Adds default GPOs for sites in APAC or EMEI
Else{

        New-GPLink -Name "MultiOU-Certificate Autoenrollment User" -Target $sitepath
        New-GPLink -Name "MultiOU-EventForwarding-EMEIA" -Target $sitepath -Enforced Yes
        #New-GPLink -Name "MultiOU-SSID8021xemployees" -Target "$sitepath"

        #French version required, yes/no
        if ($language -eq "Yes"){
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-French and English" -Target "$sitepath" 
            }
            Else {
            New-GPLink -Name "MultiOU-InfoSec-PreLogon-English" -Target "$sitepath" 
            }         

            #region > Site > Standard

            #region > Site > Standard > Desktops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=desktops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=desktops,ou=standard,$sitepath"

                #region > Site > Standard > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=desktops,ou=standard,$sitepath"

            #region > Site > Standard > Laptops
            New-GPLink -Name "MultiOU-Windows7" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "Global-CR-ScreenSaverV2" -Target "ou=laptops,ou=standard,$sitepath"
            New-GPLink -Name "MultiOU-PowerOptions" -Target "ou=laptops,ou=standard,$sitepath"

                #region > Site > Standard > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=laptops,ou=standard,$sitepath"

            #region > Site > Standard > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=standard,$sitepath"

                #region > Site > Standard > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10" -Target "ou=win10,ou=tablets,ou=standard,$sitepath"

        #region > Site > Regulated
        #New-GPLink -Name "MultiOU-Computer Block Internet" -Target "ou=regulated,$sitepath"

            #region > Site > Regulated > Desktops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=desktops,ou=regulated,$sitepath"

                #region > Site > Regulated > Desktops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=desktops,ou=regulated,$sitepath"

            #region > Site > Regulated > Laptops
            New-GPLink -Name "MultiOU-Windows7-Regulated" -Target "ou=laptops,ou=regulated,$sitepath"

                #region > Site > Regulated > Laptops > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=laptops,ou=regulated,$sitepath"

            #region > Site > Regulated > Tablets
            New-GPLink -Name "MultiOU-Windows8-Tablets (to delete)" -Target "ou=tablets,ou=regulated,$sitepath"

                #region > Site > Regulated > Tablets > WIN10
                New-GPLink -Name "MultiOU-Windows10-Regulated" -Target "ou=win10,ou=tablets,ou=regulated,$sitepath"
}
}


#LAPS Delegation
Import-Module AdmPwd.PS
("ou=WIN10,ou=desktops,ou=standard,$sitepath",
"ou=WIN10,ou=laptops,ou=standard,$sitepath",
"ou=WIN10,ou=tablets,ou=standard,$sitepath",
"ou=WIN10,ou=desktops,ou=regulated,$sitepath",
"ou=WIN10,ou=laptops,ou=regulated,$sitepath",
"ou=WIN10,ou=tablets,ou=regulated,$sitepath")|%{
Set-AdmPwdComputerSelfPermission -OrgUnit $($_)
Set-AdmPwdReadPasswordPermission -OrgUnit $($_) -AllowedPrincipals “SGG-LAPS-Computers”
Set-AdmPwdResetPasswordPermission -OrgUnit $($_) -AllowedPrincipals “SGG-LAPS-Computers”
}


<# This is not working any more.... Try again with the new GPO Admin Update
#Registers GPOs in Quest GPO Admin

if ($type -eq "new"){
Invoke-Command -ComputerName qga-pr-app-01 -ArgumentList $site,$region,$sitepath,$serversitepath -ScriptBlock {Import-Module 'C:\program files\quest\gpoadmin\gpoadmin.psd1'; cd vcroot:; New-container -Name $($args[0]) -Parent "VCRoot:\CR.LOCAL\$($args[1])" ; $newpath = Join-Path -Path "VCRoot:\CR.LOCAL\$($args[1])" -ChildPath $($args[0]); Select-RecursiveRegistration -DistinguishedName $($args[2]) -TypeToRegister All -Container $newpath; select-recursiveregistration -distinguishedname $($args[3]) -typetoregister all -container "VCRoot:\cr.local\Servers"} -Credential $credential
}
Else {
Invoke-Command -ComputerName qga-pr-app-01 -ArgumentList $site,$region,$sitepath,$serversitepath -ScriptBlock {Import-Module 'C:\program files\quest\gpoadmin\gpoadmin.psd1'; cd vcroot:; $newpath = Join-Path -Path "VCRoot:\CR.LOCAL\$($args[1])" -ChildPath $($args[0]); Select-RecursiveRegistration -DistinguishedName $($args[2]) -TypeToRegister All -Container $newpath} -Credential $credential 
}
#>


}

