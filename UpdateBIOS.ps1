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

# Define log file
$hostname = $env:COMPUTERNAME
$logFile = ".\\LOGS\BIOSUpdate_$hostname.log"
Function Write-Log {
    param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Ensure UNC path exists before writing (optional but recommended)
    $uncPath = Split-Path -Path $logFile -Parent
    if (!(Test-Path -Path $uncPath)) {
        New-Item -Path $uncPath -ItemType Directory -Force | Out-Null
    }

    Add-Content -Path $logFile -Value "$timestamp - $hostname - $Message"
    Write-Host "$timestamp - $hostname - $Message"
}

# Function to suspend BitLocker
function Suspend-BitLockerIfNeeded {
    param([string]$DriveLetter)
    $volume = Get-WmiObject win32_EncryptableVolume `
        -Namespace root\CIMv2\Security\MicrosoftVolumeEncryption `
        -Filter "DriveLetter = '$DriveLetter'"

    if ($volume.ProtectionStatus -eq 1) {
        Write-Log "Suspending BitLocker on $DriveLetter"
        Suspend-BitLocker -MountPoint $DriveLetter -RebootCount 2
    }
}

# Function to copy BIOS update files to a local directory and execute
function Update-BIOS {
    param(
        [string]$SystemFamily,
        [string]$ExpectedVersion,
        [string]$RemotePath
    )

    # Get current BIOS version
    $currentVersion = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion
    Write-Log "Current BIOS version: $currentVersion"

    if (-not($currentVersion -eq $ExpectedVersion)) {
        Write-Log "Updating BIOS for $SystemFamily from version $currentVersion to $ExpectedVersion"

        # Define local directory
        $localDir = "C:\\Temp\\BIOSUpdate"
        if (!(Test-Path -Path $localDir)) {
            New-Item -Path $localDir -ItemType Directory | Out-Null
        }

        # Ensure RemotePath exists
        if (!(Test-Path -LiteralPath $RemotePath)) {
            Write-Log "ERROR: Remote path does not exist: $RemotePath"
            return
        }

        # Clear local directory before copying
        Write-Log "Clearing local directory: $localDir"
        Remove-Item -Path "$localDir\\*" -Recurse -Force -ErrorAction SilentlyContinue

        # Copy BIOS update files (including subfolders)
        Write-Log "Copying BIOS update files from $RemotePath to $localDir..."
        Copy-Item -Path "$RemotePath\\*" -Destination $localDir -Recurse -Force

        # Identify the correct BIOS update executable
        $exeFile = Get-ChildItem -Path $localDir -Filter "WINUPTP64.EXE" -Recurse | Select-Object -First 1
        if (-not $exeFile) {
            $exeFile = Get-ChildItem -Path $localDir -Filter "WINUPTP.EXE" -Recurse | Select-Object -First 1
        }
        if (-not $exeFile) {
            $exeFile = Get-ChildItem -Path $localDir -Filter "wFlashGUIX64.exe" -Recurse | Select-Object -First 1
        }
        if (-not $exeFile) {
            Write-Log "ERROR: BIOS update executable not found in $localDir"
            return
        }

        # Confirm execution is from the local directory
        Write-Log "Found BIOS update executable: $($exeFile.FullName)"

        # Normalize paths to avoid formatting mismatches
        $expectedPath = (Resolve-Path "C:\Temp\BIOSUpdate").Path
        $actualPath = (Resolve-Path $exeFile.FullName).Path

        Write-Log "Expected execution path: $expectedPath"
        Write-Log "Actual execution path: $actualPath"

        # Check if the executable is inside the expected directory
        if ($actualPath -notmatch [regex]::Escape($expectedPath)) {
           Write-Log "ERROR: Executable is not in the expected local directory!"
           return
        }

        # Determine the correct silent install parameter
        $installArgs = if ($exeFile.Name -eq "WINUPTP64.EXE") { "-sr" } 
                       elseif ($exeFile.Name -eq "WINUPTP.EXE") { "-sr" } 
                       elseif ($exeFile.Name -eq "wFlashGUIX64.exe") { "/q" } 
                       else { "-s" }

        # Suspend BitLocker
        Suspend-BitLockerIfNeeded -DriveLetter "C"

        # Run BIOS update from local directory
        Write-Log "Executing BIOS update: $($exeFile.FullName) with arguments: $installArgs"
        Start-Process -FilePath "$($exeFile.FullName)" -ArgumentList "$installArgs" -WorkingDirectory "C:\Temp\BIOSUpdate" -Passthru -Wait

        # Prompt for restart
        #$restart = Read-Host "BIOS update complete for $SystemFamily. Restart is required. Restart now? (Y/N)"
        #if ($restart -eq 'Y') {
        #    Write-Log "Restarting system"
        #    Restart-Computer
        #}

        # Clean up files (optional)
        Write-Log "Cleaning up local BIOS update files"
        Remove-Item -Path "$localDir\\*" -Recurse -Force
    } else {
        Write-Log "BIOS for $SystemFamily is already up-to-date (Version: $currentVersion)"
    }
}

# BIOS Configuration Dictionary for Lenovo SystemFamily
$biosUpdates = @(
    @{ Family = "ThinkPad T490s"; Version = "N2JETA7W (1.85 )"; Path = ".\\ThinkPad T490s" }, # Updated 12/12/2024, BIOS version confirmed
    @{ Family = "ThinkPad T14s Gen 1"; Version = "N2YET25W (1.14 )"; Path = ".\\ThinkPad T14s Gen 1" }, # Updated 22/01/2025 -> pending confirmation
    @{ Family = "ThinkPad T14s Gen 2i"; Version = "N35UJ17W (1.54 )"; Path = ".\\ThinkPad T14s Gen 2i 1.54" }, # Updated 18/10/2023, weird issue with trying to upgrade to 1.60 
    #@{ Family = "ThinkPad T14s Gen 2i"; Version = "N35ET60W (1.60 )"; Path = ".\\ThinkPad T14s Gen 2i" }, # Updated 27/01/2025, BIOS version confirmed
    @{ Family = "ThinkPad T14s Gen 5"; Version = "N46ET19W (1.09 )"; Path = ".\\ThinkPad T14s Gen 5" }, # Updated 05/12/2024, BIOS version confirmed
    @{ Family = "ThinkPad P15s Gen 2i"; Version = "N34ET64W (1.64 )"; Path = ".\\ThinkPad P15s Gen 2i" }, # Updated 16/12/2024, BIOS version confirmed
    @{ Family = "ThinkPad P16s Gen 3"; Version = "R2DET35W (1.20 )"; Path = ".\\ThinkPad P16s Gen 3" }, # Updated 09/12/2024, BIOS version confirmed
    @{ Family = "ThinkCentre M920s"; Version = "M1UKT77A"; Path = ".\\ThinkCentre M920s" }, # Updated 25/04/2024, BIOS version confirmed
    @{ Family = "ThinkCentre M920q"; Version = "M1UKT77A"; Path = ".\\ThinkCentre M920q" }, # Updated 25/04/2024, BIOS version confirmed
    @{ Family = "ThinkCentre M80s Gen 3"; Version = "M40KT57A"; Path = ".\\ThinkCentre M80s Gen 3" }, # Updated 01/11/2024, BIOS version confirmed
    @{ Family = "ThinkCentre M80q"; Version = "M2WKT61A"; Path = ".\\ThinkCentre M80q" } # Updated 17/12/2024, BIOS version confirmed
)

# Main Script Logic
$systemFamily = (Get-WmiObject -Class Win32_ComputerSystem).SystemFamily
Write-Host "Detected System Family: $systemFamily"

foreach ($bios in $biosUpdates) {
    if ($bios.Family -eq $systemFamily) {
        Update-BIOS -SystemFamily $bios.Family -ExpectedVersion $bios.Version -RemotePath $bios.Path
    }
}
