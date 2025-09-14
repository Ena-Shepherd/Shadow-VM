# StealthVM-Malware-Lab
<img src="img\fish.png" alt="Logo" width="150" align="center">

> Customized FlareVM that looks like a regular machine <br/>
> Runs on VMWare. <br/>

## Disclaimer

This virtual machine contains potentially dangerous tools and malware samples intended only for controlled laboratory use (research, training, analysis).
Do not execute this VM on production networks or connect it to the Internet. The author is not responsible for any misuse.

## Requirements

- VMware Workstation / Fusion / ESXi
- Minimum 8 GB RAM, 65 GB free disk space
- Host OS: Windows, Linux, or macOS
- Optional: RDP client for enhanced VM interaction

## How to use

- Download the Virtual Machine <a href="notyetuploaded">Here</a>
- Verify checksum to ensure the VM has not been tampered with
- Launch the appliance with VMWare
- Connect via RDP to use the clipboard and get smoother performance
    - Default password for VM, RDP, and sample analysis : `infected`
    - Connect to the VM with RDP, or use `Frank.rdp` with the password
- Use the snapshot `Default State` when you're done after analysis or if the VM becomes unstable.

## Security Notes
- ⚠️VMWare tools will not be able to install, and **should not** be installed to keep stealth.
- 💥**DO NOT connect the VM to internet**, or if you absolutely need it, use NAT mode.<br/>
**Always use Host-Only otherwise**.<br/>
- 💡Consider creating additional snapshots before conducting experiments.

## Used Tools
> If you want to build your own VM<br/>

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

## Additional Interesting tools
> I didn't add these tools (yet)
- MitmProxy - Can be used for network analysis
- REMnux VM - Linux environment for malware analysis (set up a VPN for cross-VM analysis)
    - INetSim - Simulates http responses for malware requests
- BurpSuite - Http interception and packet manipulation

## Notes for Custom Builds
If you wish to build your own VM:

> Disable windows defender, or some tools will be deleted
- Clone the project with submodules using either
    - First clone - `git clone --recurse-submodules`
    - Already cloned - `git submodule update --init --recursive`
- Use Flare-VM scripts to set up the environment.
- Include stealth tools like VMwareHardenedLoader and check your detection with PAFish.
- Check other submodules to install in your lab
- Optionally integrate your own tools.

## Additional resources

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