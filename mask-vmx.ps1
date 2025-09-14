<#
.SYNOPSIS
Script to modify a VMware .vmx (stealth keys + ethernet0 MAC).
This version ensures both ethernet0.address and ethernet0.generatedAddress are set.
#>

$ErrorActionPreference = 'Stop'

# Prompt for the path to the .vmx file
$vmxPath = Read-Host "Enter the full path to the .vmx file"

# normalize input (trim quotes/spaces)
$vmxPath = $vmxPath.Trim().Trim('"').Trim("'")

if (-not (Test-Path -LiteralPath $vmxPath)) {
    Write-Error "VMX file not found: $vmxPath"
    exit 1
}

# Try to create a timestamped backup next to the original file; if that fails, fallback to $env:TEMP
try {
    $vmxFile = Get-Item -LiteralPath $vmxPath -ErrorAction Stop
    $vmxDir  = $vmxFile.DirectoryName
    $vmxBase = $vmxFile.Name
    $timestamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $backupName = "$vmxBase.bak_$timestamp"
    $backupPath = Join-Path $vmxDir $backupName

    Copy-Item -LiteralPath $vmxPath -Destination $backupPath -Force -ErrorAction Stop
    Write-Host "Backup created: $backupPath"
} catch {
    Write-Warning "Failed to create backup next to VMX ($backupPath) : $($_.Exception.Message)"
    try {
        $tempBackup = Join-Path $env:TEMP $backupName
        Copy-Item -LiteralPath $vmxPath -Destination $tempBackup -Force -ErrorAction Stop
        Write-Host "Fallback backup created in TEMP: $tempBackup"
        $backupPath = $tempBackup
    } catch {
        Write-Error "Failed to create any backup: $($_.Exception.Message)"
        throw
    }
}

# Define stealth keys
$vmxSettings = @{
    "hypervisor.cpuid.v0" = "FALSE"
    "board-id.reflectHost" = "TRUE"
    "hw.model.reflectHost" = "TRUE"
    "serialNumber.reflectHost" = "TRUE"
    "smbios.reflectHost" = "TRUE"
    "SMBIOS.noOEMStrings" = "TRUE"
    "isolation.tools.getPtrLocation.disable" = "TRUE"
    "isolation.tools.setPtrLocation.disable" = "TRUE"
    "isolation.tools.setVersion.disable" = "TRUE"
    "isolation.tools.getVersion.disable" = "TRUE"
    "monitor_control.disable_directexec" = "TRUE"
    "monitor_control.disable_chksimd" = "TRUE"
    "monitor_control.disable_ntreloc" = "TRUE"
    "monitor_control.disable_selfmod" = "TRUE"
    "monitor_control.disable_reloc" = "TRUE"
    "monitor_control.disable_btinout" = "TRUE"
    "monitor_control.disable_btmemspace" = "TRUE"
    "monitor_control.disable_btpriv" = "TRUE"
    "monitor_control.disable_btseg" = "TRUE"
    "monitor_control.restrict_backdoor" = "TRUE"
}

# Read the .vmx file using .NET to better preserve encoding
try {
    $vmxLines = [System.IO.File]::ReadAllLines($vmxPath)
} catch {
    Write-Error "Failed to read VMX file (maybe locked or insufficient permissions): $($_.Exception.Message)"
    throw
}

# Convert to arraylist for easy modification
$vmxContent = [System.Collections.ArrayList]::new()
$vmxContent.AddRange($vmxLines) | Out-Null

# Function to add or replace a key (handles literal dots in key names)
function Set-VmxKey {
    param(
        [string]$Key,
        [string]$Value,
        [ref]$Content
    )
    $escapedKey = [regex]::Escape($Key)
    $pattern = "^\s*$escapedKey\s*="
    $found = $false
    for ($i = 0; $i -lt $Content.Value.Count; $i++) {
        if ($Content.Value[$i] -match $pattern) {
            $Content.Value[$i] = "$Key = `"$Value`""
            $found = $true
            break
        }
    }
    if (-not $found) {
        $Content.Value.Add("$Key = `"$Value`"") | Out-Null
    }
}

# Apply stealth keys
foreach ($k in $vmxSettings.Keys) {
    Set-VmxKey -Key $k -Value $vmxSettings[$k] -Content ([ref]$vmxContent)
}

# --- MAC address modification section ---

# Generate 4 random bytes (0..255)
$bytes = 1..4 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }
$macRandom = "00:20:{0:X2}:{1:X2}:{2:X2}:{3:X2}" -f $bytes[0], $bytes[1], $bytes[2], $bytes[3]

# Ensure ethernet0.addressType is static
Set-VmxKey -Key "ethernet0.addressType" -Value "static" -Content ([ref]$vmxContent)

# Set ethernet0.address (will add if absent)
Set-VmxKey -Key "ethernet0.address" -Value $macRandom -Content ([ref]$vmxContent)

# IMPORTANT: set ethernet0.generatedAddress as well so the recorded generated address matches
# Some VMX only have generatedAddress initially; update or add it so VMware metadata is consistent.
Set-VmxKey -Key "ethernet0.generatedAddress" -Value $macRandom -Content ([ref]$vmxContent)

# Optionally clear generatedAddressOffset if you want (uncomment to set to 0)
# Set-VmxKey -Key "ethernet0.generatedAddressOffset" -Value "0" -Content ([ref]$vmxContent)

Write-Host "New MAC address for ethernet0: $macRandom"

# Atomic write: write to temp file on same folder then replace original
try {
    $tempFile = Join-Path $vmxDir ("$($vmxBase).tmp_$timestamp")
    [System.IO.File]::WriteAllLines($tempFile, $vmxContent.ToArray(), [System.Text.Encoding]::UTF8)

    # Replace original file
    Remove-Item -LiteralPath $vmxPath -Force -ErrorAction Stop
    Move-Item -LiteralPath $tempFile -Destination $vmxPath -Force -ErrorAction Stop

    Write-Host "Modifications applied successfully to $vmxPath"
} catch {
    Write-Warning "Failed to replace VMX in place: $($_.Exception.Message)"
    if (Test-Path $tempFile) { Remove-Item $tempFile -Force -ErrorAction SilentlyContinue }
    Write-Error "Changes not saved. Original VMX left intact at $vmxPath (backup: $backupPath)."
    throw
}