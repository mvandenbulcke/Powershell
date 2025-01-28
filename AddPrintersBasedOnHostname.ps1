<#
.SYNOPSIS
	Checks hostname and adds printer(s)
.DESCRIPTION
	Checks the hostname for a prefix, and will add printers based on that prefix.
.PARAMETER message
	N/A
.EXAMPLE
	PS> ./AddPrintersBasedOnHostname.ps1
.LINK
	https://github.com/mvandenbulcke/Powershell
.NOTES
	Author: Michaël Vandenbulcke | License: CC0
#>

# Define variables
$PrinterDriver = "DRIVER1"
$PrinterConfigurations = @(
    @{ Prefix = "PREFIX1"; Printers = @("PRINTER1", 
                                        "PRINTER2") },

    @{ Prefix = "PREFIX2"; Printers = @("PRINTER1", 
                                        "PRINTER2") },

    @{ Prefix = "PREFIX3"; Printers = @("PRINTER1", 
                                        "PRINTER2") }
)

# List of computers with static printer configurations
$SpecialComputerConfigurations = @(
    @{ ComputerName = "PREFIX1-LT214"; Printers = @("PREFIX1-MFP-001", "PREFIX2-MFP-002", "PREFIX3-MFP-003") },
    @{ ComputerName = "PREFIX2-LT011"; Printers = @("PREFIX1-MFP-001", "PREFIX2-MFP-002", "PREFIX3-MFP-003") },
    @{ ComputerName = "PREFIX3-LT365"; Printers = @("PREFIX1-MFP-001", "PREFIX2-MFP-002", "PREFIX3-MFP-003") }
)

# Get the local computer's hostname
$LocalComputer = $env:COMPUTERNAME

# Check if the local computer is in the special configuration list
$SpecialConfig = $SpecialComputerConfigurations | Where-Object { $_.ComputerName -eq $LocalComputer }
if ($SpecialConfig) {
    foreach ($PrinterName in $SpecialConfig.Printers) {
        $PortName = $PrinterName

        Write-Host "Checking for existing printer $PrinterName on $LocalComputer..." -ForegroundColor Yellow

        # Remove existing printer if it exists
        $ExistingPrinters = Get-Printer | Where-Object { $_.Name -like "$PrinterName*" }
        foreach ($ExistingPrinter in $ExistingPrinters) {
            Write-Host "Removing existing printer $($ExistingPrinter.Name)..." -ForegroundColor Cyan
            Remove-Printer -Name $ExistingPrinter.Name
        }

        # Remove existing printer port if it exists
        $ExistingPort = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
        if ($ExistingPort) {
            Write-Host "Removing existing printer port $PortName..." -ForegroundColor Cyan
            Remove-PrinterPort -Name $PortName
        }

        # Add the printer port
        Write-Host "Adding printer port $PortName..." -ForegroundColor Green
        if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
            Add-PrinterPort -Name $PortName -PrinterHostAddress $PortName
        }

        # Add the printer
        Write-Host "Installing printer $PrinterName..." -ForegroundColor Green
        if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
            Add-Printer -Name $PrinterName -DriverName $PrinterDriver -PortName $PortName
        }

        # Set print configuration
        Write-Host "Configuring printer $PrinterName settings..." -ForegroundColor Green
        Set-PrintConfiguration -PrinterName $PrinterName -Color $true -DuplexingMode 'TwoSidedLongEdge'
    }
} else {
    # Determine the printer configuration based on the hostname prefix
    $Config = $PrinterConfigurations | Where-Object { $LocalComputer -like "$($_.Prefix)*" }
    if ($Config) {
        foreach ($PrinterName in $Config.Printers) {
            $PortName = $PrinterName

            Write-Host "Checking for existing printer $PrinterName on $LocalComputer..." -ForegroundColor Yellow

            # Remove existing printer if it exists
            $ExistingPrinters = Get-Printer | Where-Object { $_.Name -like "$PrinterName*" }
            foreach ($ExistingPrinter in $ExistingPrinters) {
                Write-Host "Removing existing printer $($ExistingPrinter.Name)..." -ForegroundColor Cyan
                Remove-Printer -Name $ExistingPrinter.Name
            }

            # Remove existing printer port if it exists
            $ExistingPort = Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue
            if ($ExistingPort) {
                Write-Host "Removing existing printer port $PortName..." -ForegroundColor Cyan
                Remove-PrinterPort -Name $PortName
            }

            # Add the printer port
            Write-Host "Adding printer port $PortName..." -ForegroundColor Green
            if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
                Add-PrinterPort -Name $PortName -PrinterHostAddress $PortName
            }

            # Add the printer
            Write-Host "Installing printer $PrinterName..." -ForegroundColor Green
            if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) {
                Add-Printer -Name $PrinterName -DriverName $PrinterDriver -PortName $PortName
            }

            # Set print configuration
            Write-Host "Configuring printer $PrinterName settings..." -ForegroundColor Green
            Set-PrintConfiguration -PrinterName $PrinterName -Color $true -DuplexingMode 'TwoSidedLongEdge'
        }
    } else {
        Write-Host "No matching prefix found for $LocalComputer. Skipping..." -ForegroundColor Yellow
    }
}

# Remove unused WSD ports after printer operations
Write-Host "Checking for unused WSD ports..." -ForegroundColor Yellow
$WSDPorts = Get-PrinterPort | Where-Object { $_.Name -like "WSD-*" }
foreach ($WSDPort in $WSDPorts) {
    if (-not (Get-Printer | Where-Object { $_.PortName -eq $WSDPort.Name })) {
        Write-Host "Removing unused WSD port: $($WSDPort.Name)" -ForegroundColor Cyan
        Remove-PrinterPort -Name $WSDPort.Name
    }
}
