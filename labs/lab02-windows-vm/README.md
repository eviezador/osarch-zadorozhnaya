# Lab 2 — A Windows guest, and a network between them

Pair: Eva Zadorozhnaya / Shemetova Vitalina              
Machine: partner's laptop, Windows 11 Pro, 24 GB RAM, 512 GB SSD, AMD Ryzen 7 7435HS (8 cores / 16 threads); guests Ubuntu Server + Windows 11 Enterprise eval
Date: <31.10.2026 - 01.11.1016>

## What I did

1. Windows 11 Enterprise evaluation was downloaded on Vitalinas's laptop because Microsoft's evaluation image exists only for Intel and AMD (x64). ( My Mac with Apple Silicon). Licence: https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
2. Created lab02-windows: 2 vCPU, 4 GB, 64 GB thin, UEFI + Secure Boot, vTPM.
3. Network mode: NAT Network, both guests. Why: We cannot choose plain "NAT" because it gives each VM its own private router, as a result the two guests cannot reach each other. So I used NAT Network because both guests can see each other and the internet, and bridged mode(works only at home) is blocked on campus Wi-Fi.
4. Ping Ubuntu → Windows timed out because Windows Defender Firewall blocks ICMP incoming echo requests by default. Fixed with: New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
5. Overcommitment: set 14 GB + 14 GB on a 24 GB host.

## Network diagram 
              Internet
                 |
   Host laptop <192.168.0.3> (Vitalina's Wi-Fi)
                 |
   [VirtualBox NAT Network 10.0.2.0/24]
        /                              \
 lab01-ubuntu                      lab02-windows
 10.0.2.15                         10.0.2.3

```

```

## Result
| | Before | After |
|---|---|---|
| Host RAM in use |12,6 GB| 23,2 GB|
| Available |11,1 GB | 531 MB |
| Committed / Swap used |20,6 GB | 47,2GB |
| What I noticed | everything is fine | the laptop was working with both guests and some background activity running, but the mouse lagged slightly.|

## What did not work the first time

In Step 3 (item 9), copy-paste between the host and the guest did not work after installing Guest Additions. It turned out that in Lab 1 my partner had changed the VirtualBox host key from the right Ctrl to the left Ctrl, because her keyboard does not have a right Ctrl key. We fixed this by changing the host key to the right Shift key, after which copy-paste worked.
## Evidence

- [evidence/](evidence/) — one line per file on what it proves
- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows address
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Ubuntu address
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — both directions and the internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host memory, guests off
- [evidence/host-memory-after.png](evidence/host-memory-after.png) — host memory, both guests overcommitted
