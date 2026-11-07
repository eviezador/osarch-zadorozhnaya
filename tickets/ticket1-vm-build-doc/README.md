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

## Resources calculated from the host

Host: 24 GB RAM, 512 GB SSD (teammate's laptop). Before the guests were started, the host already used 12.6 GB of RAM and 11.1 GB was available (see `evidence/host-memory-before.png`).

| Resource | Calculation |
|---|---|
| RAM | 11.1 GB available − 4 GB (Windows guest) − 4 GB (Ubuntu guest) = 3.1 GB left for the host. This is enough to keep working, but not much, so I did not give the guests more than 4 GB each. |
| CPU | 2 vCPU for Windows + 2 vCPU for Ubuntu = 4 vCPU. A guest should never get more than half of the host's cores, and 2 vCPU per guest stays within that rule. |
| Disk | 64 GB Windows disk (thin, grows only as needed) + the Ubuntu disk , out of 512 GB SSD. Even with a generous Ubuntu disk, most of the SSD stays free. |

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

### Resources calculated from the host

Host: 24 GB RAM, 512 GB SSD (teammate's laptop). Before the guests were started, Windows on the host already used 12.6 GB of RAM and 11.1 GB was available (see `host-memory-before.png`).



## 4. Evidence

## 5. What I would do differently

At least one thing. "Nothing, it all went well" is not an answer.
