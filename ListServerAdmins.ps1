#---------------------------------------------------------------
# List Administrator group (recursively) on servers for audit
#
# **NOTE **  If there are any spaces after the server name in the csv file, server will notlist the groups
#---------------------------------------------------------------

$LDAPDomain="cr.local"

#--------------------------
#Main Variables
#--------------------------
$Domain=[ADSI]"$LDAPDomain"
$DomainName = [string]$Domain.name
$DomainName = $DomainName.ToUpper()
$nCurrDepth=0

#--------------------------
#Functions 
#--------------------------
	function Get-ScriptDirectory
	{
		$Invocation = (Get-Variable MyInvocation -Scope 1).Value
		Split-Path $Invocation.MyCommand.Path
	}
	 

	function fn_FindDomainGroup([string]$GroupName)
	{
		$searcher=new-object DirectoryServices.DirectorySearcher([ADSI]"")
		$filter="(&(objectCategory=group)(samAccountName=$GroupName))"
		$searcher.filter=$filter
		$Results = $searcher.findall()
		
		$GroupLdapPath = ""
		
		if ([int32]$Results.Count -gt [int32]0){
	
			$Result = $Results[0]
			$GroupLdapPath=$result.properties['adspath']
		}
		Return $GroupLdapPath	
	}

	function fn_FindDomainGroup([string]$GroupName)
	{
		$arStr = $GroupName.split("\")
		$sGroup = $arStr[1]	
		$sDomain = $arStr[0]	
		$searcher=new-object DirectoryServices.DirectorySearcher([ADSI]"")
		$filter="(&(objectCategory=group)(samAccountName=$sGroup))"
		$searcher.filter=$filter
		$Results = $searcher.findall()
		
		$GroupLdapPath = ""
		
		if ([int32]$Results.Count -gt [int32]0){
	
			$Result = $Results[0]
			$GroupLdapPath=$result.properties['adspath']
		}
		Return $GroupLdapPath	
	}

	function fn_GetLocalGroupMembers([string]$GroupPath)
	{
		
		$MemberNames = @()
		$GroupName = $GroupPath.Replace("\","/")
		$Group= [ADSI]"WinNT://$GroupName,group"
		$Members = @($Group.psbase.Invoke("Members"))
		$Members | ForEach-Object {
			$Member = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
			$Type = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
			$Path = $_.GetType().InvokeMember("AdsPath", 'GetProperty', $null, $_, $null)
			$arPath = $Path.Split("/")
			$Domain = $arPath[$arPath.length - 2]	
			$Domain = [string]$Domain.ToUpper()
			$Member = $Domain + "\" + $Member
			$DisplayString = "`t" + $Type.ToUpper() + ":  " + "`t" + $Member
			$MemberNames += $DisplayString
		}
		Return $MemberNames


	}

	function fn_IsLocalGroup([string]$GroupName)
	{
		$blIsLocalGroup = "false"
		$hostname = hostname
		$arStr = $GroupName.split("\")
		$sGroup = $arStr[1]	
		$sDomain = $arStr[0]	

		if ($hostname.ToUpper() -eq $sGroup.ToUpper()) {
			$blisLocalGroup ="true"
			
		}
		elseif ($sDomain.ToUpper() -eq  $DomainName.ToUpper())
		{
			$blisLocalGroup ="false"
		}else
		{
			$searchresult = fn_FindDomainGroup($sGroup)
			if ($searchresult.length -gt 0) {
				$blisLocalGroup ="false"
			}else{
				$blisLocalGroup ="true"
			}
		}
		return $blIsLocalGroup
	}

	function fn_GetLDAPGroupMembers([string]$GroupLdap)
	{
		$MemberNames = @()
		$ADGroup=[ADSI]"$GroupLdap"
		$GroupSam = $ADGroup.samAccountName
		
		#Get group members		
		$Members = @($ADGroup.psbase.Invoke("Members"))
		$Members | ForEach-Object {
			$Member = $_.GetType().InvokeMember("samAccountName", 'GetProperty', $null, $_, $null)
			$DisplayName = $_.GetType().InvokeMember("displayName", 'GetProperty', $null, $_, $null)
			$Type = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
			$Path = $_.GetType().InvokeMember("AdsPath", 'GetProperty', $null, $_, $null)
			$Member = $DomainName + "\" + $Member
			$DisplayString = "`t" + $Type.ToUpper() + ": " + "`t" + $Member + "`t" + $Path
			$MemberNames += $DisplayString
		} 
		Return $MemberNames
	
	}

	function fn_GetGroupMembers([string]$GroupName, [string]$isLocalGroup, [string]$AdsPath)
	{
		$sTitle = $GroupName
		write-host 
		write-host $sTitle
		write-host "-----------------------------------------------" 

		""  | out-file  -append $OutFile
		"`t" + $sTitle | out-file  -append $OutFile
		"`t" + "-----------------------------------------------"  | out-file  -append $OutFile
		$MemberNames = @()
		if ($isLocalGroup -eq "true"){
			$MemberNames =fn_GetLocalGroupMembers($GroupName)
		}else{
			if ($ADSPath.Contains("LDAP"))
			{	
				$MemberNames = fn_GetLDAPGroupMembers($ADSPath)
			}else
			{
				if (! $GroupName.Contains($DomainName + "\")){
					$MemberNames =fn_GetLocalGroupMembers($GroupName)
				}
			}
		}
		return $MemberNames

	}

#--------------------------
#Main work
#--------------------------

function fn_Main([string]$Groupname){
		
	$sGrouplist=$GroupName + "|"
	$nCurrDepth = 1
	

	for ($nCurrDepth = 1; $nCurrDepth -le $nMaxDepth; $nCurrDepth++) {

		if ($sGroupList.Length -gt 0)
		{
			
			$arGroupList = $sGroupList.split("|")
			$Count = [int32]$arGroupList.Count
			$sGroupList = ""
			for ($a = 0; $a -lt $Count - 1; $a++)
			{

				#on the first pass only, check if the group is a local group
				if ($nCurrDepth -eq 1) 
				{	$Groupname = $arGroupList[$a]
					$blLocalGroup = fn_IsLocalGroup($Groupname)
					#if the group is not a local group, lookup the ADS path
					$ADSPath = ""
					if ($blLocalGroup -eq "false")
					{

						$ADSPath = fn_FindDomainGroup($Groupname)
					}
                    If ($GroupName -notmatch "Domain Admins")
                    {
					    $MemberNames = fn_GetGroupMembers "$Groupname" $blLocalGroup "$ADSPath"
                    }						

				}
				else
				{
					#Check if ADSPath is already resolved, if not, search for it
					$GroupString= $arGroupList[$a]
					if ($GroupString.Contains(";")){
					  $arTemp = $GroupString.Split(";")
					  $GroupName = $arTemp[0]
					  $ADSPath = $arTemp[0]
					}else{
					   $Groupname = $GroupString
					   $ADSPath = ""
					}
					if (! $ADSPath.Contains("LDAP"))
					{
						$ADSPath = fn_FindDomainGroup($Groupname)
					}
                    If ($GroupName -notmatch "Domain Admins")
                    {
					$MemberNames = fn_GetGroupMembers "$Groupname" "false" "$ADSPath"
                    }	
				}

				
				ForEach($member in $MemberNames)
				{
					if ($member.length -gt 0){
						$arTemp = $member.split(";")
						$DisplayString = $arTemp[0]
						write-host $DisplayString
						$DisplayString  | out-file  -append $OutFile
						if ($member.ToLower().contains("group"))
						{
							$sGroup = $member.substring(8,$member.length - 8)
							$sGrouplist = $sGrouplist + $sGroup + "|"	
						}
					}
				}
		
				$MemberNames = ""
			}	
			
		}

	}

}

#Start Processing

#------------------------------------------------------------
#List DataCenter servers and send to DataCenter Mgr
#------------------------------------------------------------
CLS
$OutFile = "E:\AutomationJobs\Output\ServerAdminGroupDetailsDC.csv"
get-date | out-file $OutFile

$nCurrDepth=0
$nMaxDepth=5
"Recursion Depth: " + $nMaxDepth | out-file $OutFile -append

Import-CSV "E:\AutomationJobs\Input\ServerListDataCenter.csv" | ForEach-Object {
$SName = $_.ServerName
""  | out-file  -append $OutFile
"-----------------------------------------------------------------"  | out-file  -append $OutFile
"Server: " + $sName | out-file  -append $OutFile
"-----------------------------------------------------------------"  | out-file  -append $OutFile
fn_Main($SName+"\Administrators") }

# Send email to administrators with exported CSV file
$temail = "steve.matte@crl.com","adscripts@crl.com"
$fromaddress = "ListServerAdmins@crl.com"
$Sub = "Local Administrator Group Details - DataCenter"
$Ebody = "run on ent-pr-uad-01<br><br>Local Administrator Group Details  - DataCenter."
$attachment = $OutFile
Send-MailMessage -To $temail -From $fromaddress -Cc $fromaddress -Subject $Sub -Body $Ebody -bodyashtml -Attachments $attachment -SmtpServer smtp.cr.local	

#------------------------------------------------------------
#List Enterprise Apps servers and send to Enterprise App Mgr
#------------------------------------------------------------
$OutFile = "E:\AutomationJobs\Output\ServerAdminGroupDetailsENT.csv"
get-date | out-file $OutFile

$nCurrDepth=0
$nMaxDepth=5
"Recursion Depth: " + $nMaxDepth | out-file $OutFile -append

Import-CSV "E:\AutomationJobs\Input\ServerListEnterpriseApps.csv" | ForEach-Object {
$SName = $_.ServerName
""  | out-file  -append $OutFile
"-----------------------------------------------------------------"  | out-file  -append $OutFile
"Server: " + $sName | out-file  -append $OutFile
"-----------------------------------------------------------------"  | out-file  -append $OutFile
fn_Main($SName+"\Administrators") }

# Send email to administrators with exported CSV file
$temail = "Trish.Torizzo@crl.com","Maya.Shteynberg@crl.com","kevin.mulholland@crl.com","adscripts@crl.com"
$fromaddress = "ListServerAdmins@crl.com"
$Sub = "Local Administrator Group Details - Enterprise Apps"
$Ebody = "run on ent-pr-uad-01<br><br>Local Administrator Group Details - Enterprise Apps."
$attachment = $OutFile
Send-MailMessage -To $temail -From $fromaddress -Cc $fromaddress -Subject $Sub -Body $Ebody -Attachments $attachment -SmtpServer smtp.cr.local	

#------------------------------------------------------------
#List BPC App servers and send to BPC App Mgr
#------------------------------------------------------------
$OutFile = "E:\AutomationJobs\Output\ServerAdminGroupDetailsBPC.csv"
get-date | out-file $OutFile

$nCurrDepth=0
$nMaxDepth=5
"Recursion Depth: " + $nMaxDepth | out-file $OutFile -append

Import-CSV "E:\AutomationJobs\Input\ServerListBPC.csv" | ForEach-Object {
$SName = $_.ServerName
""  | out-file  -append $OutFile
"-----------------------------------------------------------------"  | out-file  -append $OutFile
"Server: " + $sName | out-file  -append $OutFile
"-----------------------------------------------------------------"  | out-file  -append $OutFile
fn_Main($SName+"\Administrators") }

# Send email to administrators with exported CSV file
$temail = "Graham.Marwick@crl.com","adscripts@crl.com"
$fromaddress = "ListServerAdmins@crl.com"
$Sub = "Local Administrator Group Details - BPC"
$Ebody = "run on ent-pr-uad-01<br><br>Local Administrator Group Details - BPC"
$attachment = $OutFile
Send-MailMessage -To $temail -From $fromaddress -Cc $fromaddress -Subject $Sub -Body $Ebody -Attachments $attachment -SmtpServer smtp.cr.local
