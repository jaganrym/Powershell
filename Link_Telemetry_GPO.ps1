# Links Telemetry GPO to all Non-Regulated Computer OUs
Import-Module activedirectory

$OUs = Get-ADOrganizationalUnit -f {(name -like '*non-regulated*')} | select -ExpandProperty distinguishedname

foreach ($OU in $OUs)
    {
        if($OU -notlike '*servers*')
            {
                new-GPLink -name "MultiOU-TelemetryAgent_LoopBack" -Target $OU
            }
    }
