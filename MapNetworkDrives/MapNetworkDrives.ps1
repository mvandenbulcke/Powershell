# Name: MapNetworkDrives.ps1
# Usage: MapNetworkDrives.ps1
# Description: 
#	Will check different AD parameters and bassed on that will add certain drives.
#

# Variables
$UserName = $env:username 
$Filter = "(&(objectCategory=User)(samAccountName=$UserName))" 
$Searcher = New-Object System.DirectoryServices.DirectorySearcher 
$Searcher.Filter = $Filter 
$ADUserPath = $Searcher.FindOne() 
$ADUser = $ADUserPath.GetDirectoryEntry() 
$ADCompany = $ADUser.company
$ADDepartment = $ADUser.department
$ADGroup = $ADUser.memberOf

# If the user has "COMPANY" in the Company field in AD, this part will run and add \\SERVER\EXAMPLE$ as a K drive.
if ( $ADCompany -eq "COMPANY") {
	net use k: /d /y
	net use	K: \\SERVER\COMPANY$
	
	# If the path exists this part will run and add \\SERVER\EXAMPLE$\%username% as a V drive.
	if ( Test-Path "\\SERVER\EXAMPLE$\%username%" -eq true) {
		net use V: /d /y
		net use V: \\SERVER\EXAMPLE$\%username%
	}
	
	# If the user has "DEPARTMENT" in the DEPARTMENT field in AD, this part will run and add \\SERVER\DEPARTMENT$ as a M drive.
    if ( $ADDepartment -eq "DEPARTMENT") {
        net use M: /d /y
        net use	M: \\SERVER\DEPARTMENT$
    }
	
	# If the user is part of a security group named Domain Users this part will run and add \\SERVER\GROUP$ as the L drive.
    if ( $ADGroup -eq "CN=Domain Users,CN=Users,DC=contoso,DC=local") {
        net use L: /d /y
        net use	L: \\SERVER\GROUP$
    }
	
	# if the user has a specific username this part will run and add \\SERVER\USERNAME$ as the R drive.
	if ( $AUser -eq "USERNAME") {
		net use r: /d /y
		net use	R: \\SERVER\USERNAME$
	}
}