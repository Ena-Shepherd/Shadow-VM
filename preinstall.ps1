<#
.SYNOPSIS
Install VmwareHardenedLoader and rename vmhgfs.sys
#>

$ErrorActionPreference = 'Stop'

function DefenderRemover{
	try {

        Write-Host "[+] Removing Windows Defender..."
		# Path to the batch script relative to the PowerShell script
		$batPath = Join-Path $PSScriptRoot "environment\windows-defender-remover\Script_Run.bat"

		if (-not (Test-Path $batPath)) {
			throw "Batch file not found: $batPath"
		}

		# Launch the batch file as admin and wait for completion
		Start-Process -FilePath $batPath -Verb RunAs -Wait

		Write-Host "Batch script executed successfully."
	} catch {
		Write-Error "Error running the batch script: $_"
		# Log exception if vm.common is imported
		if (Get-Module -Name vm.common -ErrorAction SilentlyContinue) {
			VM-Write-Log-Exception $_
		}
	}
}

function Disable-WindowsDefenderGPO {
    <#
    .SYNOPSIS
        Disable Windows Defender using Local Group Policy (registry method)
    .DESCRIPTION
        Sets registry keys to turn off Windows Defender / Microsoft Defender Antivirus.
        Requires administrator privileges.
    #>

    $ErrorActionPreference = 'Stop'

    try {
        Write-Host "[+] Disabling Windows Defender via Local Group Policy..."

        # Path to Defender Policies in Registry
        $defenderPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"

        # Create key if it doesn't exist
        if (-not (Test-Path $defenderPolicyPath)) {
            New-Item -Path $defenderPolicyPath -Force | Out-Null
            Write-Host "[+] Created registry key: $defenderPolicyPath"
        }

        # Disable Real-Time Protection
        Set-ItemProperty -Path $defenderPolicyPath -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force

        # Disable Real-Time Monitoring
        Set-ItemProperty -Path $defenderPolicyPath -Name "DisableRealtimeMonitoring" -Value 1 -Type DWord -Force

        Write-Host "[+] Windows Defender disabled successfully."
    } catch {
        Write-Error "[ERROR] Failed to disable Windows Defender: $_"
    }
}

Disable-WindowsDefenderGPO
DefenderRemover

try {
    # Path to the batch installer
    $batPath = Join-Path $PSScriptRoot "stealth\VmwareHardenedLoader\bin\install.bat"

    if (-not (Test-Path $batPath)) {
        throw "Batch file not found: $batPath"
    }

    # Path to vmhgfs.sys
    $sysFile = "C:\Windows\System32\drivers\vmhgfs.sys"
    $newSysFile = "C:\Windows\System32\drivers\vimhgfs.sys"

    if (Test-Path $sysFile) {
        Write-Host "[+] Renaming vmhgfs.sys to vimhgfs.sys..."
        Rename-Item -Path $sysFile -NewName "vimhgfs.sys" -Force
        Write-Host "[+] Rename completed."
    } else {
        Write-Warning "File vmhgfs.sys not found in System32\drivers"
    }

    Write-Host "[+] Launching VmwareHardenedLoader installer..."
    Start-Process -FilePath $batPath -Verb RunAs -Wait
    Write-Host "[+] Installer completed."

} catch {
    Write-Error "An error occurred: $_"
}