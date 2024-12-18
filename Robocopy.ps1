$SP = "<SourcePath>"
$DP = "<DestinationPatch>"
$LogFile = "<LogFilePatch>"
robocopy $SP $DP /E /ZB /Dcopy:DAT /Copyall /R:5 /W:10 /Log:$logFile 
robocopy <Source> <Destination> /E /copyall /XO /LOG:"robolog.txt" /Z /R:3 /W:6