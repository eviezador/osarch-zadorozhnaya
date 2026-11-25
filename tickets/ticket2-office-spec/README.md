# Ticket 2 — Kitting out the new office

## 1. What was asked
> **From:** Daniyar K. (Director) · **Subject:** computers for the new office
>
> We are opening the second office and need four computers — accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed
**Four identical machines is wrong.** The four people put load on different parts of a computer: the accountant needs a big screen, sales needs memory, the developer needs memory and cores, the designer needs a graphics card and an accurate monitor. Identical machines means either every machine is built for the designer (the accountant gets a graphics card she never uses and we run out of money) or every machine is built for the accountant (the designer cannot work). With one fixed budget, money should go where each person's bottleneck is. What *should* be the same is the **platform** (AM5 + DDR5, same board, same SSD) — that keeps spare parts and repairs simple.

**What the request left out:**
- the **operating system** — Windows licences are ~83,000 KZT each, so four of them are almost 11 % of the budget;
- **keyboards and mice**;
- for sales: a **headset and webcam** for four hours of video calls;
- **"a few years"** — how many;
- **software**: 1C for the accountant (Windows only), Adobe for the designer (Windows/macOS only);
- backups, a UPS, network equipment, a printer for the office.

**What I would ask Daniyar → what I assumed instead:**
| Question | Assumption |
|---|---|
| Does 3,000,000 include OS, keyboards and mice? | Yes — "for everything". |
| How many years is "a few"? | 4–5 years, so a current socket (AM5) and DDR5, with one upgrade in between. |
| Which accounting software? | 1C — needs Windows. |
| What does the designer make — print/web or video? | Print and web graphics (sRGB), not video grading. |
| Do people already have headsets/webcams? | Not priced; the 180,602 KZT reserve can cover them. |
| Is there network, printer and backup in the new office? | Out of scope of this request. |

## 3. What I did
1. For each role I wrote the **load → bottleneck → trade-off** first, before choosing any part ([builds.md](builds.md)).
2. Chose **one platform** for all four (AM5, B650 board, DDR5, 1 TB NVMe, 650 W) and moved the remaining money to each bottleneck: 32 GB for sales, developer and designer; a graphics card only for the designer; a 27″ QHD screen for accountant, developer and designer.
3. Took prices in tenge from shops that deliver in Kazakhstan (Shop.kz, Flexcom, Ants, Forcecom, Greenprice, Vendara, Directshop, alfa.kz), each with the date — [budget.csv](budget.csv).
4. Checked compatibility (socket, memory type, M.2, power) — [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md).

| Role | Bottleneck | Total, KZT |
|---|---|---|
| Accountant | screen | 646,718 |
| Sales | memory | 666,528 |
| Web developer | memory, then cores | 597,338 |
| Designer | GPU + colour-accurate monitor | 908,814 |
| **Grand total** | | **2,819,398** (≤ 3,000,000) |

Memory was the hardest part of the budget: DDR5 prices in Kazakhstan rose sharply in 2026 (a 2×16 GB kit is 217,000–310,000 KZT), so 32 GB went only to the roles that really run out of memory.

### Question 1 — Which machine will I upgrade first, in 18 months, and why?
The **web developer's** machine: memory from 32 GB to **64 GB**. Projects grow — more containers, a bigger local database, sometimes a VM — and the developer already uses most of 32 GB. The board has 4 memory slots and only 2 are used, so another 2×16 GB kit can be added without throwing anything away. Second step, if builds are slow: replace the Ryzen 5 7600 with a Ryzen 7/9 on the same AM5 socket.

### Question 2 — Pre-built instead of building?
Pre-built machines from Kazakh shops (taken 2026-11-25):

| Pre-built | Price, KZT | Shop | Compared with |
|---|---|---|---|
| Intel Core i5-14400F, 32 GB, 1 TB SSD, RTX 5060 | 569,990 | alfa.kz — https://alfa.kz/pc/computers/intel/core_i5/all/8277767 | designer tower (my build without monitor, OS, keyboard): 708,692 |
| AMD Ryzen 5 7600X, **DDR4** 32 GB, 1 TB SSD, RTX 5060 | 850,653 | alfa.kz — https://alfa.kz/pc/computers/amd/ryzen_5/all/8547144 | same |

**Gain:** one warranty for the whole box, one shop to call, assembled and tested — no hours of building; and sometimes a lower price (the first one is cheaper than my parts).
**Lose:** control of parts. Cheap pre-builts save money on what is not visible: the second one uses **DDR4**, an old memory type the platform cannot move away from; they often come **without Windows**, with a weak power supply or a slow SSD; the case and board may not take more memory later. So the upgrade path in Question 1 may not exist. For the designer a pre-built is reasonable if the parts list is checked; for the others a pre-built office PC usually has 8–16 GB and would hit the memory bottleneck.

### Question 3 — Who will complain within a month, and about what?
The **web developer**, about **build and container start-up times**. I gave the role a 6-core Ryzen 5 instead of an 8-core Ryzen 7 to keep money for memory. When Docker rebuilds images while the editor indexes the project and a browser runs tests, all 12 threads will be busy and the machine will feel slow for a minute at a time. That is the trade-off I chose — and the reason the CPU is the planned second upgrade.

## 4. Evidence
- [budget.csv](budget.csv) — every part with price in KZT, shop, link and the date I saw the price; total per role and grand total ≤ 3,000,000.
- [builds.md](builds.md) — load, bottleneck and trade-off for each machine.
- [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md) — one PCPartPicker list per build: proves the parts are compatible and the power supply is big enough (PCPartPicker does not price in tenge, it is used only for compatibility and wattage).
- [evidence/vendor-quotes/](evidence/vendor-quotes/) — a screenshot of each price with the shop's site and the date visible, named after the part (e.g. `designer-gpu.png`).

## 5. What I would do differently
- **Check memory prices first.** I planned 32 GB for everybody, then saw that a DDR5 kit costs more than the CPU and had to rebalance the builds. Starting from the most expensive, most volatile part would have saved time.
- **Ask about headsets, webcams and backups before pricing.** Sales cannot work four hours of calls on a desktop without them, and they belong in the budget, not in the reserve.

