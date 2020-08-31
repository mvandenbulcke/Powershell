# Name: UpdateBios.ps1
# Usage: UpdateBios.ps1
# Description: 
#	Will check if the BIOS is up to date, if not it will update the BIOS with files from a (network) location.
#
# Elevate to administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
# Get the target system's model. 
$pcModel = (Get-WmiObject -Class:Win32_ComputerSystem).Model
$BiosVersion = (Get-WmiObject -Class:Win32_BIOS).SMBIOSBIOSVersion

# Get the target volume's encryption properties.
$volume = Get-WmiObject win32_EncryptableVolume `
    -Namespace root\CIMv2\Security\MicrosoftVolumeEncryption `
    -Filter "DriveLetter = 'C:'"

# If the model is Latitude 5290 2-in-1 and the BIOS is not up to date. Update it.
if ( $pcModel -eq "Latitude 5290 2-in-1" -and (-not($BiosVersion -eq '1.11.2')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\Dell Latitude 5290 2-in-1 1.11.2\Latitude_5290_2In1_1.11.2.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is Latitude 5300 2-in-1 and the BIOS is not up to date. Update it.
if ( $pcModel -eq "Latitude 5300 2-in-1" -and (-not($BiosVersion -eq '1.8.1')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\Dell Latitude 5300 2-in-1 1.8.1\Latitude_5300_1.8.1.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here., need to add a confirmation window here.
	Restart-Computer
}

# If the model is Latitude 5501 and the BIOS is not up to date. Update it.
if ( $pcModel -eq "Latitude 5501" -and (-not($BiosVersion -eq '1.8.4')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\Dell Latitude 5501 1.8.4\Latitude_5X01_Precision_3541_1.8.4.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is Latitude E7250 and the BIOS is not up to date. Update it.
if ( $pcModel -eq "Latitude E7250" -and (-not($BiosVersion -eq 'A23')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\Dell Latitude E7250 A23\E7250A23.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is Latitude 5590, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "Latitude 5590" -and (-not($BiosVersion -eq '1.12.1')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\Dell Latitute 5590 1.12.1\Latitude_5X90_1.12.1.exe" -ArgumentList '/s /f' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is Latitude 5591, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "Latitude 5591" -and (-not($BiosVersion -eq '1.11.1')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\Dell Latitute 5591 1.11.1\Latitude_5X91_Precision_3530_1.11.1.exe" -ArgumentList '/s /f' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is HP Elite x2 1013 G3, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP Elite x2 1013 G3" -and (-not($BiosVersion -eq '01.10.01')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP Elite x2 1013 G3 01.10.01 Rev.A\HpFirmwareUpdRec64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is HP EliteDesk 800 G2 DM 65W, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP EliteDesk 800 G2 DM 65W" -and (-not($BiosVersion -eq 'N21 Ver. 02.45')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP EliteDesk 800 65W G2 2.45 Rev.A\HPBIOSUPDREC\HPBIOSUPDREC64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is HP EliteDesk 800 G3 SFF, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP EliteDesk 800 G3 SFF" -and (-not($BiosVersion -eq 'P01 Ver. 02.32')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP EliteDesk 800 G3 SFF 02.32 Rev.A\HPBIOSUPDREC\HPBIOSUPDREC64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is ProBook 650 G2, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ProBook 650 G2" -and (-not($BiosVersion -eq 'N76 Ver. 01.45' -or $BiosVersion -eq 'N87 Ver. 01.45')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP ProBook 650 G2 1.45 Rev.A\HPBIOSUPDREC64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is ProBook 650 G4, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ProBook 650 G4" -and (-not($BiosVersion -eq 'Q83 Ver. 01.10.00' -or $BiosVersion -eq 'Q77 Ver. 01.10.00')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP ProBook 650 G4 01.10.00 Rev.A\HpFirmwareUpdRec64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is HP ProDesk 400 G5 SFF, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ProDesk 400 G5 SFF" -and (-not($BiosVersion -eq '02.10.00')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP ProDesk 400 G5 SFF 02.10.00 Rev.A\HpFirmwareUpdRec64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is ZBook 17 G2, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ZBook 17 G2" -and (-not($BiosVersion -eq 'M70 Ver. 01.25')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}
	
	# Update BIOS
	Start-Process ".\BIOS Update\HP ZBook 17 G2 1.25 Rev.A\HPBIOSUPDREC64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is ZBook 17 G3, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ZBook 17 G3" -and (-not($BiosVersion -eq 'N81 Ver. 01.45')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}

	# Update BIOS
	Start-Process ".\BIOS Update\HP ZBook 17 G3 1.45 Rev.A\HPBIOSUPDREC64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is ZBook 17 G4, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ZBook 17 G4" -and (-not($BiosVersion -eq 'P70 Ver. 01.32')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}

	# Update BIOS
	Start-Process ".\BIOS Update\HP ZBook 17 G4 1.32 Rev.A\HPBIOSUPDREC64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}

# If the model is ZBook 17 G5, and the BIOS is not up to date. Update it.
if ( $pcModel -eq "HP ZBook 17 G5" -and (-not($BiosVersion -eq 'Q70 Ver. 01.10.01')) ) {

	# Suspend BitLocker
	if ( $volume.ProtectionStatus -eq 1 -or !$volume ) {
		Suspend-BitLocker -MountPoint "C:" -RebootCount 2
	}

	# Update BIOS
	Start-Process ".\BIOS Update\HP ZBook 17 G5 01.10.01 Rev.A\HpFirmwareUpdRec64.exe" -ArgumentList '-r -s' -Wait
	
	# Restart Computer, need to add a confirmation window here.
	Restart-Computer
}




