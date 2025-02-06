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
        
    # Determine the correct silent install parameter based on the executable name
    $installArgs = if ($FilePath -match "WINUPTP64.EXE") { "-s" } elseif ($FilePath -match "wFlashGUIX64.exe") { "/quit" } else { "-s" }
    
    # Run BIOS update
    Start-Process $FilePath -ArgumentList $installArgs -Wait
    

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
    @{ Family = "ThinkPad T490s"; Version = "N2JET77W (1.55 )"; Path = ".\BIOSUpdates\ThinkPad T490s\WINUPTP64.EXE" }, # Updated 12/12/2024
    @{ Family = "ThinkPad T480s"; Version = "N22ET52W (1.29 )"; Path = ".\BIOSUpdates\ThinkPad T480s\WINUPTP64.EXE" }, # Updated 22/01/2025
    @{ Family = "ThinkPad T14s Gen 1"; Version = "N2YET25W (1.14 )"; Path = ".\BIOSUpdates\ThinkPad T14s Gen 1\WINUPTP64.EXE" }, # Updated 22/01/2025
    @{ Family = "ThinkPad T14s Gen 2i"; Version = "N35ET51W (1.51 )"; Path = ".\BIOSUpdates\ThinkPad T14s Gen 2i\WINUPTP64.EXE" }, # Updated 27/01/2025
    @{ Family = "ThinkPad T14s Gen 5"; Version = "N46ET19W (1.09 )"; Path = ".\BIOSUpdates\ThinkPad T14s Gen 5\WINUPTP.EXE" }, # Updated 05/12/2024
    @{ Family = "ThinkPad P52s"; Version = "N27ET32W (1.18 )"; Path = ".\BIOS Update\ThinkPad P15 Gen 2 1.36\WINUPTP64.EXE" }, # Updated 16/12/2024
    @{ Family = "ThinkPad P15s Gen 2i"; Version = "N34ET53W (1.53 )"; Path = ".\BIOSUpdates\ThinkPad P15s Gen 2i\WINUPTP64.EXE" }, # Updated 16/12/2024
    @{ Family = "ThinkPad P16s Gen 3"; Version = "R2DET30W (1.15 )"; Path = ".\BIOSUpdates\ThinkPad P16s Gen 3\WINUPTP.EXE" }, # Updated 09/12/2024
    @{ Family = "ThinkCentre M920s"; Version = "M1UKT50A"; Path = ".\BIOSUpdates\ThinkCentre M920s\wFlashGUIX64.exe" }, # Updated 25/04/2024
    @{ Family = "ThinkCentre M920q"; Version = "M1UKT33A"; Path = ".\BIOSUpdates\ThinkCentre M920q\wFlashGUIX64.exe" }, # Updated 25/04/2024
    @{ Family = "ThinkCentre M80s Gen 3"; Version = "M40KT32A"; Path = ".\BIOSUpdates\ThinkCentre M80s Gen 3\wFlashGUIX64.exe" }, # Updated 01/11/2024
    @{ Family = "ThinkCentre M80q"; Version = "M2WKT57A"; Path = ".\BIOSUpdates\ThinkCentre M80q\wFlashGUIX64.exe" } # Updated 17/12/2024
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