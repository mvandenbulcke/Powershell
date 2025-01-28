<#
.SYNOPSIS
	Check BIOS and update.
.DESCRIPTION
	Checks if the BIOS is up-to-date and updates it if necessary.
.PARAMETER message
	N/A
.EXAMPLE
	PS> ./UpdateBIOS.ps1
.LINK
	https://github.com/mvandenbulcke/Powershell
.NOTES
	Author: Michaël Vandenbulcke | License: CC0
#>

# Ensure script runs as Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Function to suspend BitLocker
function Suspend-BitLockerIfNeeded {
    param([string]$DriveLetter)
    $volume = Get-WmiObject win32_EncryptableVolume `
        -Namespace root\CIMv2\Security\MicrosoftVolumeEncryption `
        -Filter "DriveLetter = '$DriveLetter'"

    if ($volume.ProtectionStatus -eq 1) {
        Suspend-BitLocker -MountPoint $DriveLetter -RebootCount 2
    }
}

# Function to update BIOS
function Update-BIOS {
    param(
        [string]$SystemFamily,
        [string]$ExpectedVersion,
        [string]$FilePath
    )

    $currentVersion = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion
    if (-not($currentVersion -eq $ExpectedVersion)) {
        Write-Host "Updating BIOS for $SystemFamily from version $currentVersion to $ExpectedVersion"

        # Suspend BitLocker
        Suspend-BitLockerIfNeeded -DriveLetter "C"

        # Run BIOS update
        Start-Process $FilePath -ArgumentList '-r -s' -Wait

        # Prompt for restart
        $restart = Read-Host "BIOS update complete for $SystemFamily. Restart is required. Restart now? (Y/N)"
        if ($restart -eq 'Y') {
            Restart-Computer
        }
    } else {
        Write-Host "BIOS for $SystemFamily is already up-to-date (Version: $currentVersion)"
    }
}

# BIOS Configuration Dictionary for Lenovo SystemFamily
$biosUpdates = @(
    @{ Family = "ThinkPad X1"; Version = "1.42"; Path = ".\BIOS Update\ThinkPad X1 Carbon Gen 10 1.42\X1CarbonGen10_1.42.exe" },
    @{ Family = "ThinkPad T Series"; Version = "1.23"; Path = ".\BIOS Update\ThinkPad T14s Gen 3 1.23\T14sGen3_1.23.exe" },
    @{ Family = "ThinkPad P Series"; Version = "1.36"; Path = ".\BIOS Update\ThinkPad P15 Gen 2 1.36\P15Gen2_1.36.exe" },
    @{ Family = "ThinkCentre M Series"; Version = "M1AKT42A"; Path = ".\BIOS Update\ThinkCentre M720q Tiny M1AKT42A\M720qTiny_M1AKT42A.exe" },
    @{ Family = "ThinkCentre M Series"; Version = "M1AKT42A"; Path = ".\BIOS Update\ThinkCentre M920s SFF M1AKT42A\M920sSFF_M1AKT42A.exe" },
    @{ Family = "ThinkPad E Series"; Version = "1.21"; Path = ".\BIOS Update\ThinkPad E14 Gen 2 1.21\E14Gen2_1.21.exe" }
    # Add more entries as needed
)

# Main Script Logic
$systemFamily = (Get-WmiObject -Class Win32_ComputerSystem).SystemFamily
Write-Host "Detected System Family: $systemFamily"

foreach ($bios in $biosUpdates) {
    if ($bios.Family -eq $systemFamily) {
        Update-BIOS -SystemFamily $bios.Family -ExpectedVersion $bios.Version -FilePath $bios.Path
    }
}