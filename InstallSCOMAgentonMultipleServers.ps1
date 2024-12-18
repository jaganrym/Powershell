    
#Import PowerShell Modules 


import-module OperationsManager



#Variables


#$InstallAccount = Get-Credential CR\jr39462
$PrimaryMgmtServer = Get-SCOMManagementserver -Name "ops-pr-mgt-03.cr.local"



#Connect to OpsMgr Management Group
Start-OperationsManagerClientShell -ManagementServerName: "ops-pr-mgt-03.cr.local" -PersistConnection: $true -Interactive: $true;


$list = Import-Csv -Path 'E:\Input\servers.csv'


foreach ($entry in $list)
    {
$computer = $entry.ServerName


    try
{
    Install-SCOMAgent -Name $computer -PrimaryManagementServer $PrimaryMgmtServer -ErrorAction Stop
#Write Success message into file
"$computer, Success." | out-file "E:\Ouput\result.csv" -Append -NoClobber
        }


    Catch
{
#just write a failure message into file
        "$computer, Failed." | out-file "E:\Ouput\result.csv" -Append -NoClobber
}


}


