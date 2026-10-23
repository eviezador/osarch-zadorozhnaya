# Lab 1 — Your first virtual machine

Pair:  By myself                   Driver first half:
Machine: MacBook, macOS, guest Ubuntu Server 24.04 LTS
Date: 15.10.2026-22.10.2026

## What I did 

1. Installed VMware Fusion. Licence: Personal
2. Created VM lab01-ubuntu: 2 vCPU, 4 GB RAM, 25 GB dynamic disk, NAT.
3. Installed Ubuntu Server, took snapshot clean-install.
4. Broke it: cat /etc/hostname ;sudo rm /etc/hostname; cat /etc/hostname 
5. Rolled back to clean-install: cat /etc/hostname

## Resource justification 
I gave the VM 4 GB of my 16 GB total RAM. macOS uses about 5-6 GB when idle, which leaves plenty of free resources for the host system and potential future guests. The 25 GB allocation for the dynamic virtual disk is well justified as it leaves enough free storage on my laptop for daily tasks. 

## Result
The VM boots; the break-and-rollback cycle is shown in the evidence below.


## What did not work the first time

Firstly, I had a problem with controlling my VM because because VM did not see by actions on keyboard (I could not move from language selection page , enter did not react). I restarted my machine numerous times to solve this problem.
Secondly, I did not fully understand step 7. Instead of using SSH, I took screenshots directly from the VM.



## Evidence

- [evidence/vm-settings-processor.png](evidence/vm-settings-processor.png) — CPU and memory as configured
- [evidence/vm-settings.png](evidence/vm-settings.png) - Hard disk size as configured
- [evidence/guest-release.png](evidence/guest-release.png) - Ubuntu Server is running in the guest
- [evidence/broken.png](evidence/broken.png) - the guest in its broken state
- [evidence/snapshot-list.png](evidence/snapshot-list.png) - the snapshot, after the rollback
