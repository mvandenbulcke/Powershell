<#
.SYNOPSIS
	Checks IP octet and adds printer
.DESCRIPTION
	Checks the IP subnet for a specific octet and will add a printer from a remote printserver.
.PARAMETER message
	N/A
.EXAMPLE
	PS> ./AddPrintersBasedOnIPOctet.ps1
.LINK
	https://github.com/mvandenbulcke/Powershell
.NOTES
	Author: Michaël Vandenbulcke | License: CC0
#>

#Remove printers
Get-Printer -Name "*PREFIX*" | Remove-Printer
 
# Get the IPv4 address of the active Ethernet or Wi-Fi network adapter that received its IP from DHCP
$ipAddress = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -match 'Ethernet|Wi-Fi' -and $_.PrefixOrigin -eq 'Dhcp' } | Select-Object -First 1 -ExpandProperty IPAddress
 
if ($ipAddress) {
    Write-Output "Your DHCP-assigned IP Address is: $ipAddress"
    # Split the IP address into its octets
    $octets = $ipAddress -split '\.'
    # Extract the third octet
    $thirdOctet = $octets[2]
    # Dynamically construct the printer name
    $printerName = "PREFIX-$thirdOctet"
    # Construct the connection name
    $connectionName = "\\PRINTSERVER\" + $printerName
    Write-Output "Attempting to add printer: $connectionName"
    Add-Printer -ConnectionName $connectionName
} else {
    Write-Output "IP Address could not be found."
    }