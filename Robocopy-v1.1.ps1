$SP = get-content D:\fpath.csv
#$DP = get-content D:\Target.txt
$LogFile = "D:\LOG.txt"

foreach($S in $SP ) 
{
    write-host $S 
    #robocopy $S /E  /copy:DAT /R:5 /W:10 /Log:$logFile
    }





#robocopy "D:\A\A1" D:\B\B1 /E /ZB /Dcopy:DAT /Copyall /R:5 /W:10 /Log:$logFile
#robocopy <Source> <Destination> /E /copyall /XO /LOG:"robolog.txt" /Z /R:3 /W:6