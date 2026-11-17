# Lab 4 — Partition, mirror, fail, recover

Pair: Eva Zadorozhnaya (I get Windows evidence from Vitalins Shemetova) · Date: 17.11.2026 · Hypervisor: VMware Fusion (Ubuntu guest on my Mac)

## Windows
I did not do the Windows part of this lab. The Windows guest from Lab 2 exists only on my teammate's laptop, because my Mac has an Apple Silicon chip and cannot run the Windows 11 evaluation image. I got evidence from team's laptop.

MBR or GPT: I would choose GPT. Windows 11 boots with UEFI, which uses GPT, and GPT keeps a backup copy of the partition table and checksums it, while MBR is limited to 2 TiB and four primary partitions.

## Linux – layout before and after

### Before
```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME                      SIZE TYPE FSTYPE      MOUNTPOINTS
sr0                       2.9G rom  iso9660
nvme0n2                     1G disk
nvme0n1                     1G disk
nvme0n3                    25G disk
├─nvme0n3p1                 1G part vfat        /boot/efi
├─nvme0n3p2                 2G part ext4        /boot
└─nvme0n3p3              21.9G part LVM2_member
  └─ubuntu--vg-ubuntu--lv  11G lvm  ext4        /
nvme0n4                     1G disk
```
The system disk is nvme0n3 (it has partitions and the `/` mount point). The three new 1 GB disks are nvme0n1, nvme0n2 and nvme0n4. The disks of this VM are NVMe, so they are not called sdb, sdc and sdd as in the lab text, and the system disk is not the first one. The original output is in [evidence/lsblk-before.txt](evidence/lsblk-before.txt).

### After
```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME                      SIZE TYPE  FSTYPE            MOUNTPOINTS
sr0                       2.9G rom   iso9660
nvme0n2                     1G disk
└─nvme0n2p1              1022M part  linux_raid_member
nvme0n1                     1G disk
└─nvme0n1p1              1022M part  linux_raid_member
  └─md0                  1021M raid1 ext4              /mnt/mirror
nvme0n3                    25G disk
├─nvme0n3p1                 1G part  vfat              /boot/efi
├─nvme0n3p2                 2G part  ext4              /boot
└─nvme0n3p3              21.9G part  LVM2_member
  └─ubuntu--vg-ubuntu--lv  11G lvm   ext4              /
nvme0n4                     1G disk
└─nvme0n4p1              1022M part  linux_raid_member
  └─md0                  1021M raid1 ext4              /mnt/mirror
```
The mirror md0 is built on nvme0n1p1 and nvme0n4p1 and mounted on /mnt/mirror. The old partition nvme0n2p1 still shows linux_raid_member, because it still carries the RAID label, but it is no longer part of the array.

## What I did
The three new disks (1 GB each, dynamically allocated, NVMe like the system disk) were added to the powered-off VM in VMware Fusion.

```
mkdir -p ~/lab04/evidence
cd ~/lab04
echo '$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS' > evidence/lsblk-before.txt
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS >> evidence/lsblk-before.txt
```

One GPT partition marked for RAID on each of the three new disks:

```
for d in nvme0n1 nvme0n2 nvme0n4; do sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on; done
```

The mirror from two of them, the file system, the mount and the proof files:

```
sudo apt install -y mdadm
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/nvme0n1p1 /dev/nvme0n2p1
cat /proc/mdstat
sudo mkfs.ext4 -L mirror /dev/md0
sudo mkdir -p /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sudo chown $USER: /mnt/mirror
echo "Lab 4 proof file - Eva Zadorozhnaya - $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
cd /mnt/mirror
sha256sum proof.txt random.bin
```

Failing one disk on purpose (with `--fail`, not by detaching it in the settings), then proving that the data survived:

```
sudo mdadm /dev/md0 --fail /dev/nvme0n2p1
sudo mdadm /dev/md0 --remove /dev/nvme0n2p1
cat /mnt/mirror/proof.txt
sha256sum proof.txt random.bin
diff evidence/checksum-before.txt evidence/checksum-after-failure.txt && echo "checksums match"
```

Adding the third disk and rebuilding, then keeping the mirror after a reboot:

```
sudo mdadm /dev/md0 --add /dev/nvme0n4p1
cat /proc/mdstat
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

After every stage I saved the output at once into its own file in `evidence/`, in the form `echo '$ command' > file`, then `command >> file`.

## Three states
| State | What /proc/mdstat showed | File |
|---|---|---|
| Healthy | [2/2] [UU] | [evidence/array-healthy.txt](evidence/array-healthy.txt) |
| Degraded | [2/1] [U_] | [evidence/array-degraded.txt](evidence/array-degraded.txt) |
| Rebuilt | [2/2] [UU], nvme0n4p1 replaced nvme0n2p1 | [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) |

Checksums before and after the failure: match. The files are [evidence/checksum-before.txt](evidence/checksum-before.txt) and [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt), and `diff` printed "checksums match".

## RAID is not a backup
Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No, RAID 1 does not help here. A deletion is written to both disks of the mirror at the same moment, so the second disk has no copy of the file either. RAID protects against the failure of a disk, while a backup is a separate copy made earlier on another device, from which the file can be restored.

## What did not work the first time
- `mkdir -p ~ /lab04/evidence` answered "Permission denied". A space between `~` and `/lab04` made mkdir try to create `/lab04` in the root of the system. I removed the space.
- `lsblk` answered "unknown column: FSTYP". I had left out the last letter of FSTYPE, so the file contained only the command line and no output. I typed the command again.
- `mdadm` answered "unrecognized option '--rapid-devices=2'". The correct option is `--raid-devices=2`. Nothing was created, so I only corrected the word and ran the command again.
- I first wrote the date by hand into proof.txt and got a wrong text, because `$1` inside double quotes is an empty variable. I rewrote the file with `$(date)` and took the checksums only after that, so that the checksums belong to the final file.
- The lab text calls the new disks sdb, sdc and sdd, but on NVMe the system disk was nvme0n3 and the new disks were nvme0n1, nvme0n2 and nvme0n4. I read the names from `lsblk` before every command that destroys data.

## Evidence
- [evidence/lsblk-before.txt](evidence/lsblk-before.txt) – the disk layout before any change
- [evidence/array-healthy.txt](evidence/array-healthy.txt) – the mirror with both disks up, State: clean
- [evidence/array-degraded.txt](evidence/array-degraded.txt) – the mirror with one disk failed, State: clean, degraded
- [evidence/checksum-before.txt](evidence/checksum-before.txt) – checksums of the two files before the failure
- [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt) – the same checksums after the failure, identical
- [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) – the mirror after adding the third disk, State: clean
