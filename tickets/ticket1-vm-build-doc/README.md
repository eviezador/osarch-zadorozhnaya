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

## 4. Evidence

## 5. What I would do differently

At least one thing. "Nothing, it all went well" is not an answer.
