<#
.SYNOPSIS
Script to modify VMware VM settings to enhance stealth
and change the main VM MAC address (ethernet0).
#>

# Prompt for the path to the .vmx file
$vmxPath = Read-Host "Enter the full path to the .vmx file"

if (-not (Test-Path $vmxPath)) {
    Write-Error "VMX file not found: $vmxPath"
    exit
}

# Create a backup of the original .vmx
$backupPath = "$vmxPath.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
Copy-Item $vmxPath $backupPath
Write-Host "Backup created: $backupPath"

# Define all "stealth" keys
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

# Read the .vmx file content
$vmxContent = Get-Content $vmxPath

# Function to add or replace a key
function Set-VmxKey {
    param(
        [string]$key,
        [string]$value,
        [ref]$content
    )
    $pattern = "^$key\s*="
    $found = $false
    for ($i = 0; $i -lt $content.Value.Count; $i++) {
        if ($content.Value[$i] -match $pattern) {
            $content.Value[$i] = "$key = `"$value`""
            $found = $true
            break
        }
    }
    if (-not $found) {
        $content.Value += "$key = `"$value`""
    }
}

# Apply all stealth keys
foreach ($key in $vmxSettings.Keys) {
    Set-VmxKey -key $key -value $vmxSettings[$key] -content ([ref]$vmxContent)
}

# Modify only the main MAC address (ethernet0)
$macRandom = "00:20:{0:X2}:{1:X2}:{2:X2}:{3:X2}" -f (Get-Random 0..255),(Get-Random 0..255),(Get-Random 0..255),(Get-Random 0..255)
Set-VmxKey -key "ethernet0.address" -value $macRandom -content ([ref]$vmxContent)
Write-Host "New MAC address for ethernet0: $macRandom"

# Save the modified .vmx file
Set-Content -Path $vmxPath -Value $vmxContent -Encoding UTF8
Write-Host "Modifications applied successfully."