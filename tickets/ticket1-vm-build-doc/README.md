# Ticket 1 — VM build document

## 1. What was asked
From: Aigerim T. (Office Manager)
Subject: test machine for new dev

Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks

## 2. What was actually needed
What the request left out but the job requires. 
- She did not mention the operating systems. "A test computer" does not say what the developer works on. I assumed that he needs Linux (Ubuntu Server) and Windows 11, because developers usually test on both, and built one guest of each. 
- She did not give information about the host: how much RAM and disk space it has, or which processor it uses. This matters a lot. If Aigerim's laptop is a Mac with an Apple Silicon chip (M1–M4), the Windows 11 evaluation image will not run on it, because the image exists only for Intel/AMD (x64) processors. The RAM and disk size also decide how much memory each guest can get. I assumed a host like the one I used with the teammate (Shemetova Vitalina): 24 GB RAM and 512 GB SSD.
- Network is left out. A test machine needs the internet  (updates, downloads), and the two guests must see each other, so I chose NAT Network.
- She forgot about license and cost. I downloaded the free Windows 11 Enterprise evaluation (90 days, no product key) and VirtualBox. It saves money.
  
Where the request is wrong or unclear 
- "Without breaking anything". She needs to be more precise. What can break is the host laptop, not the test machine. A virtual machine keeps the developer's experiments inside the guest, and a **snapshot** of the clean install lets Aigerim go back after he breaks the VM. It is like time-machine.
- "Nothing special" This is not true for the host: two guests need a lot of memory and disk, and an overloaded laptop becomes slow for everyone (I saw this in the overcommitment experiment: 98% RAM in use, 531 MB available). Windows 11 may also not install at all on a laptop with too little RAM (it needs at least 4 GB for the guest).
  
What I would have asked 
- Which operating systems does the developer need, and which tools?
- What laptop will host the VMs (RAM, free disk, Intel/AMD or Apple Silicon)?
- Does the test machine need to reach the office network, or only the internet?
  
What I assumed instead 
Linux and Windows, an Intel/AMD host with about 24 GB RAM and 512 GB SSD, internet access only, free software only. Apple Silicon is not covered: the Windows evaluation image exists only for Intel/AMD.


> This section carries 6 of the 20 marks and is the one most often left empty.

## 3. What I did

1. Downloaded the Windows 11 Enterprise evaluation ISO (free, 90 days, no product key): https://www.microsoft.com/en-us/evalcenter/evaluate-windows-11-enterprise
2. Created a VM `lab02-windows` in VirtualBox 7: 2 vCPU, 4 GB RAM, 64 GB dynamic disk, EFI + Secure Boot + virtual TPM 2.0.
3. Installed Windows 11 Enterprise (evaluation) with a local account, then installed Guest Additions so that the screen resizes and copy-paste works.
4. Put both guests (`lab01-ubuntu` and `lab02-windows`) on one NAT Network.
5. Found the addresses with `ipconfig` (Windows, 10.0.2.3) and `ip addr` (Ubuntu, 10.0.2.15).
6. Tested ping in both directions and to ubuntu.com (`evidence/05-ping-between-guests.txt`).
7. Fixed the Ubuntu → Windows ping with a firewall rule (see below).

## Resources calculated from the host

Host: 24 GB RAM, 512 GB SSD (teammate's laptop). Before the guests were started, the host already used 12.6 GB of RAM and 11.1 GB was available (see `evidence/host-memory-before.png`).

| Resource | Calculation |
|---|---|
| RAM | 11.1 GB available − 4 GB (Windows guest) − 4 GB (Ubuntu guest) = 3.1 GB left for the host. This is enough to keep working, but not much, so I did not give the guests more than 4 GB each. |
| CPU | 2 vCPU for Windows + 2 vCPU for Ubuntu = 4 vCPU. A guest should never get more than half of the host's cores, and 2 vCPU per guest stays within that rule. |
| Disk | 64 GB Windows disk (thin) + 25 GB Ubuntu disk (thin) = 89 GB at most, out of 512 GB SSD. Most of the SSD stays free. |

I also tested what happens if this limit is ignored: when the guests were promised more memory than the host has, 98% of RAM was in use and only 531 MB was available (`evidence/host-memory-after.png`).

### Settings that differ from the default

| Setting | Default | Mine | Why |
|---|---|---|---|
| Unattended installation | on | Skip | I install Windows by hand so that each step can be documented |
| Network mode | NAT | NAT Network (both guests) | The guests must see each other and the internet |
| Shared Clipboard | Disabled | Bidirectional | Command output has to be copied from the guest to the host |
| Host key | Right Ctrl | Right Shift | Keyboard without a right Ctrl key; copy-paste did not work otherwise |
| Windows account | Microsoft account | Local account (Domain join instead) | A test machine does not need a Microsoft account |
| Windows firewall | Blocks incoming ping | One rule allowing ICMP echo | The firewall stays on; only ping is opened |

### One thing that went wrong, and how I fixed it
Ping from Ubuntu to Windows timed out, while Windows to Ubuntu worked. The reason: Windows Defender Firewall blocks incoming ICMP echo requests by default, and Ubuntu's firewall is off. I did not turn the firewall off, because that would open the whole machine. I added one rule that allows only ping, in PowerShell as Administrator.

```
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```



## 4. Evidence

## 4. Evidence

Screenshots of the VirtualBox settings and the Windows guest were taken on my teammate's laptop, where both guests ran. Screenshot 06 was taken on my own Mac.

| File | What it proves |
|---|---|
| [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) | The wizard page for `lab02-windows`: 4096 MB memory, 2 CPUs, "Use EFI" ticked. |
| [evidence/01b-new-vm-wizard-ubuntu.png](evidence/01b-new-vm-wizard-ubuntu.png) | The wizard page for `lab01-ubuntu`: VM name and the Ubuntu Server ISO. |
| [evidence/02-disk-settings.png](evidence/02-disk-settings.png) | The Windows disk is 64 GB and "Pre-allocate Full Size" is not ticked, so the disk is thin (dynamically allocated). |
| [evidence/02b-disk-settings-ubuntu.jpg](evidence/02b-disk-settings-ubuntu.jpg) | The Ubuntu disk is 25 GB and also thin. |
| [evidence/03-network-adapter.png](evidence/03-network-adapter.png) | Adapter 1 of the Windows guest is attached to a NAT Network, not to plain NAT. |
| [evidence/03b-network-adapter-ubuntu.png](evidence/03b-network-adapter-ubuntu.png) | Adapter 1 of the Ubuntu guest is attached to the same NAT Network. |
| [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) | The Linux guest runs Ubuntu Server 26.04.1 LTS (`uname`, `lsb_release`), its address is 10.0.2.15, and it reaches ubuntu.com. |
| [evidence/04b-system-info-windows.txt](evidence/04b-system-info-windows.txt) | The Windows guest runs Windows 11 Enterprise Evaluation with about 4 GB of memory, and its address is 10.0.2.3. |
| [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) | Both guests reach each other and the internet (unedited output). |
| [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) | The clean snapshot `clean-install` exists for the Ubuntu VM and can be rolled back to. |
| [evidence/07-windows-vm-settings.png](evidence/07-windows-vm-settings.png) | The Windows guest has UEFI, Secure Boot and TPM 2.0 turned on. |

Note on the Ubuntu version: the wizard screenshot (01b) offers Ubuntu 25.04 in its version list, but that is only the wizard's setting. The version actually installed is Ubuntu Server 26.04.1 LTS, as `04-guest-uname.txt` shows.

## 5. What I would do differently

- **Record the settings of every VM at the moment I create it.** After the build I could not check how much memory the Ubuntu VM on my teammate's laptop had: one screenshot showed 2048 MB, but my teammate said 4096 MB. Next time I will take a screenshot of Settings → System and Storage right after creating each VM, so the numbers in the README come from evidence and not from memory.
- **Take a screenshot at every step while building.** I only have screenshots of the settings and the results, not of the Windows installer or the Guest Additions. Because of that, BUILD.md describes those steps in words, and a reader has no picture to compare with.
- **Check the host key and the shared clipboard before the installation.** Copy-paste between the host and the guest did not work, because the host key had been changed to the left Ctrl and my keyboard has no right Ctrl key. We fixed it by setting the host key to the right Shift, but it cost time in the middle of the build.

  ## AI use

| Work | Tool | What it was used for |
|---|---|---|
| Ticket 1 | Claude (Anthropic) | Explanations, drafts of the README and BUILD.md structure, checking text |
