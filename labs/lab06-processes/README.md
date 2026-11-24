# Lab 6 — Live processes and memory pressure

Pair: Eva Zadorozhnaya + Vitalina Shemetova· Date: 24.11.2026 · Guests: Ubuntu 26.04.1 LTS (VMware Fusion on Apple Silicon), 3.3 GiB RAM, no swap / Windows: my partner's machine (Python 3.13, x64)

## Part 1 — One process, three tools
Process chosen: **Python** — `python3 -m http.server 8000` on Ubuntu, `python.exe` on Windows. The recommended `VBoxService` does not exist on my VMware guest, and my partner uses VirtualBox, so the only program we both have is Python; we started it ourselves on each side.

| | Task Manager | Process Explorer | htop / ps |
|---|---|---|---|
| PID | 47580 | 47580 | 156605 |
| Parent (name and PID) | — (not shown) | powershell.exe (29592) | bash (1826) — the shell I started it from |
| "Memory" as shown by default | 54 780 K (private working set) | Private Bytes 56 500 K | RES 22 908 K |
| Private memory | 54 780 K | WS Private 54 748 K | no column (RES − SHR ≈ 13 620 K is the closest) |
| Working set / RES | — (column not added) | Working Set 62 312 K | RES / RSS 22 908 K |
| Virtual size | — (no column) | 4 312 700 K (≈4.1 GB) | VIRT 37 064 K / VSZ 37 064 K (≈36 MB) |
| Handles / file descriptors | 78 | 78 | 4 file descriptors |
| Threads | 1 | 1 | 1 (`ps` NLWP) |

Evidence: [htop.png](evidence/htop.png), [ps.png](evidence/ps.png) · Windows: [task-manager.jpg](evidence/task-manager.jpg), [process-explorer.jpg](evidence/process-explorer.jpg)

The 4 file descriptors on Linux are 0, 1, 2 → `/dev/pts/0` (the terminal it was started in: input, output, errors) and 3 → a socket (the server listening on port 8000).

### Where the tools disagree
- **Task Manager's "Memory" leaves out shared memory; Working Set and RES include it.** In Process Explorer, Working Set 62 312 K = WS Private 54 748 K + WS Shareable 7 528 K. Task Manager's default column shows only the private part (54 780 K). htop's RES is like Working Set — it includes shared libraries (SHR 9 288 K of RES 22 908 K). So "memory" in the two default views is not the same quantity.
- **Commit size ≈ Private Bytes; htop has no column for it.** Process Explorer's Private Bytes (56 500 K) is the memory the process has committed; Linux tools only show what is resident (RES) or reserved (VIRT).
- **Virtual size is not memory in use.** Process Explorer shows a virtual size of ≈4.1 GB for a Python process whose working set is 61 MB: a 64-bit Windows process reserves a large address space. On Linux VIRT is 36 MB. Neither number is RAM in use.
- **Handles ≠ file descriptors.** Windows counts 78 handles, Linux 4 file descriptors. A Windows handle can point to many kinds of kernel objects (files, registry keys, events, threads, sections), while a Linux file descriptor is only an open file, pipe or socket — the two counts measure different things.
- **Task Manager does not show the parent at all;** Process Explorer (tree and Image tab) and htop (tree) / `ps` (PPID) do.
- Note: the two Python processes ran different scripts (`-c "import …"` on Windows, `-m http.server` on Linux) and different Python versions, so part of the memory difference is the workload itself, not only how the tools count.

## Part 2 — Memory pressure
Guest RAM: 3.3 GiB · swap: none (`swapon --show` prints nothing, `free -h` shows Swap 0B). RAM was below 4 GB, so I did not lower it.
Snapshot taken first in VMware Fusion (24.11.2026, 09:11 local), with the guest powered off.
The guest clock is UTC; Almaty is UTC+5 (06:26 UTC = 11:26 local).

Steps, in order:
1. Recording in a second SSH session: `free -h` every 3 s into `memory-pressure.txt` (Step 7 command).
2. `stress-ng --vm 2 --vm-bytes 70% --timeout 60s` — used 847 MB, passed.
3. `stress-ng --vm 2 --vm-bytes 90% --timeout 60s` — used 1.07 GB, passed.
4. `stress-ng --vm 2 --vm-bytes 120% --timeout 90s` — used 1.53 GB, passed.
5. `stress-ng --vm 2 --vm-bytes 150% --timeout 90s` (as the brief suggests) — used 2.69 GB, passed.
6. `stress-ng --vm 2 --vm-bytes 4G --timeout 90s` — more than the guest's RAM; **this one triggered the OOM killer**.

| | Before (06:09:09) | During (worst) | After (06:34:25) |
|---|---|---|---|
| Available | 2.8Gi | 149Mi (06:21:19, 150 % run); 273Mi (06:26:44, 4 G run) | 2.9Gi |
| Swap used | 0B (no swap) | 0B | 0B |

What happened:
- **Available near zero:** at 150 % available fell from 2.8 GiB to 149 MiB at 06:21:13–06:21:25; `used` was 3.2 of 3.3 GiB and buff/cache was squeezed from 1.8 GiB to 232 MiB — the kernel dropped the page cache to make room.
- **Swap:** never grew, because there is no swap. With nowhere to page out, the system did not slow down into thrashing; when RAM ran out the kernel went straight to the OOM killer.
- **Responsiveness:** the recording kept its 3-second rhythm through every run (e.g. 06:26:41, :44, :47), and the terminals kept responding — no freeze.
- **The process:** `stress-ng` always reported `passed: 2, failed: 0`, even in the 4 G run. It silently restarts a worker that gets killed, so its own summary hides the kills — only the kernel log shows them.

Evidence: [memory-pressure.txt](evidence/memory-pressure.txt)

### What the kernel did
From [kernel-log-extract.txt](evidence/kernel-log-extract.txt) (`journalctl -k … | grep -B3 -A8`):

```
Nov 24 06:26:49 lab01-zadorozhnaya kernel: stress-ng-vm invoked oom-killer: gfp_mask=0x440dc0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_COMP), order=0, oom_score_adj=1000
Nov 24 06:26:49 lab01-zadorozhnaya kernel: oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),cpuset=/,mems_allowed=0,global_oom,task_memcg=/user.slice/user-1000.slice/session-5.scope,task=stress-ng-vm,pid=155870,uid=1000
Nov 24 06:26:49 lab01-zadorozhnaya kernel: Out of memory: Killed process 155870 (stress-ng-vm) total-vm:2124296kB, anon-rss:2098084kB, file-rss:580kB, shmem-rss:64kB, UID:1000 pgtables:4184kB oom_score_adj:1000
```

- **Which process:** `stress-ng-vm`, the memory worker of stress-ng (first PID 155870, then 155871, 155872, …).
- **Why that one:** it held `anon-rss: 2098084 kB` ≈ 2.0 GB — about two thirds of the guest's RAM, the biggest process by far — and stress-ng marks its workers `oom_score_adj: 1000`, the maximum, so the kernel picks them first. `global_oom` means the whole system was out of memory.
- **When:** first kill at 06:26:49 UTC (11:26:49 local), during the 4 G run. In total the log has **141** `Killed process` lines: stress-ng kept restarting workers and the kernel kept killing them.
- **Matching `memory-pressure.txt`:** the 4 G run is at 06:26; available dropped to 273 MiB at 06:26:44. The recording samples only every 3 seconds, so it cannot catch the exact instant of a kill — the kernel log can.
- The 150 % run (06:21) has **no** OOM lines in the log: memory got down to 149 MiB, but the kernel managed by dropping the cache.

### Windows
Run on my partner's Windows machine (PowerShell):

```powershell
Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ProviderName = 'Microsoft-Windows-Resource-Exhaustion-Detector'
} -MaxEvents 10 | Format-List TimeCreated, Id, Message
```

Result:

```
Get-WinEvent : Не удалось найти события, соответствующие указанному условию выбора.
    + FullyQualifiedErrorId : NoMatchingEventsFound,Microsoft.PowerShell.Commands.GetWinEventCommand
```

No events were found ("NoMatchingEventsFound"): this Windows machine has never run low on memory, so the System log has no Resource-Exhaustion-Detector entries. That is a valid result.

What I would expect if it had: Windows does **not** kill processes the way the Linux OOM killer does. When the commit charge (RAM + page file) gets close to the commit limit, Windows first warns the user ("Your computer is low on memory"), then new memory allocations start to fail inside programs, and the Resource-Exhaustion-Detector writes **event ID 2004** to the System log, naming the processes that were using the most memory. Closing a program is left to the user or the program, not decided by the kernel. On Linux, by contrast, the kernel chose a victim by itself and killed it 141 times (see above).

Clean-up: guest RAM was not changed; after the test available memory was back to 2.9 GiB, so the snapshot did not need restoring.

## What did not work the first time
- **The first process did not exist on both sides.** I first chose `vmtoolsd` (VMware Tools), but my partner uses VirtualBox, where it does not exist, so we switched to Python on both machines and I redid the Linux measurements.
- **The percentages did not create pressure.** `stress-ng` takes `--vm-bytes 70%` as a share of *free* memory (≈1.2 GB), not of all RAM, because most RAM was page cache. 70–150 % never triggered the OOM killer, so I gave an absolute size, `--vm-bytes 4G`, larger than the guest's 3.3 GiB.
- **Taking the snapshot.** After I deleted old snapshots, Take Snapshot stayed greyed out in VMware Fusion; it worked only after I powered the guest off.
- **htop function keys on a Mac.** F2/F3/F5 did not reach htop through the macOS Terminal; I used the letter keys or clicked the labels at the bottom (F5Tree, F3Search).
- **SSH dropped** when the guest received a new IP address; I checked it with `hostname -I` and reconnected.
