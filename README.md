# Shadow-VM Malware-Lab
<img src="img\fish.png" alt="Logo" width="150" align="center">

> Malware often checks if it is runnng in a Virtual Machine to prevent investigation during dynamic analysis. <br/>
> This customized Flare-VM is disguised as a regular machine to prevent this behavior on VMWare.<br/>

## Disclaimer

This virtual machine contains potentially dangerous tools and malware samples intended only for controlled laboratory use (research, training, analysis).
Do not execute this VM on production networks or connect it to the Internet. The author is not responsible for any misuse.

## Requirements

- VMware Workstation / Fusion / ESXi
- Minimum 8 GB RAM, 65 GB free disk space
- Host OS: Windows, Linux, or macOS
- Target OS: Windows 11
- Highly recommended: RDP client

## How to use

- Prepare a Windows 11 Virtual Machine
- Make sure your VM is powered off and launch `mask-vmx.ps1`
- Enter your .vmx file location in the prompt, which is located inside your installed VM folders
- Boot your VM up
- Clone the project and put it into the VM
- Disable Windows defender or make an exception folder where the repo is located
- Initialize submodules with `git submodule update --init --recursive`
- Open an admin powershell and launch `preinstall.ps1`, this will get rid of leftover VM traces, Windows defender, and will install a spoofing driver
- Restart your VM to apply changes
- Launch `install.ps1`. It will run tests for VM detection, launch the install menu for Flare-VM and add Malware sample folders to your Desktop
- Open your VM settings and change the network adapter mode to `Host-only`, it will prevent malware to spread on your network

**Highly recommended:**
> You won't be able to install VMWare-Tools because the installer will think you're on a real machine <br/>
> It means you won't have access to file-copy or the clipboard. <br/>
> However, you can bypass this restriction with RDP, and gain smoother UI in bonus. <br/>

- Enable RDP on the virtual machine and make a connection profile on your host

**Finally, take a snapshot of your system to have a clean state reset when you need to**


## Security Notes
- ⚠️VMWare tools will not be able to install, and **should not** be installed.
- 💥**DO NOT connect the VM to internet**, or if you absolutely need it, use NAT mode.<br/>
**Always use Host-Only otherwise**.<br/>
- 💡Consider creating additional snapshots before conducting experiments.

## Used tools

**Environment**
- Flare-VM - Google's environment install script for malware analysis and reverse engineering
- Windows defender remover - Allows the tools and samples to run for dynamic analysis 

**Stealth**
- VmwareHardenedLoader - Driver and VM settings
- PAFish - Check for common VM behaviors

**Samples**
- theZOO - Contains live samples of various malware families
- PMAT-labs - Also contains samples, aimed for learning with courses

**Misc**
- OOShutUp10 - Gets rid of annoying Windows telemetry

## Additional interesting tools
> I didn't add these tools (yet)
- MitmProxy - Can be used for network analysis
- REMnux VM - Linux environment for malware analysis (set up a VPN for cross-VM analysis)
    - INetSim - Simulates http responses for malware requests
- BurpSuite - Http interception and packet manipulation

## Websites for malware analysis

- [Vx-database](https://virus.exchange/) - Samples database
- [VirusTotal](https://www.virustotal.com/gui/home/upload) - Check signatures
- [Malpedia](https://malpedia.caad.fkie.fraunhofer.de/) - Identification ressources

> Thx for the additional links, Humpty :P
- [UnpacMe](https://www.unpac.me/) - Online unpacker service
- [MalAPI.io](https://malapi.io/) - Malicious WinAPI Cheatsheet
- [Unprotect.it](https://unprotect.it/) - Common techniques used by threat actors
- [MagNumDB](https://www.magnumdb.com/) - Magic numbers database

## Special thanks 🎉
- Humpty and the <a href="https://discord.gg/hYa9gvD8vw">IRCC discord server</a>
- Internet Archive for hosting the very large VM files
