# Builds — four machines, one platform, different money

All four use the same base: **AMD AM5 socket + DDR5**, MSI PRO B650M-P board, Kingston NV3 1 TB NVMe SSD, 650 W PSU, Zalman M5 case. AM5 is AMD's current socket, so in 2–3 years each machine can take a newer Ryzen without changing board or memory — that is how "last a few years" is met. The same base also means one set of spare parts and one way to fix them.
The money that differs goes to each person's **bottleneck**: memory, GPU, screen.
Prices and links: [budget.csv](budget.csv). Compatibility and power: [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md).

Compatibility (all builds): CPU AM5 ↔ board AM5 · board DDR5 ↔ DDR5 kits · board 2× M.2 ↔ NVMe SSD · micro-ATX board ↔ micro-ATX case. Power: Ryzen 5 7600 65 W; with the RTX 5060 (~150 W, maker recommends ≥ 550 W) the designer's machine draws about 300 W — the 650 W supply has headroom.

---

### Build 1 — accountant
**Load:** accounting software (1C) and Excel all day, a browser with 5–10 tabs, e-government and bank portals; 8 hours, but only 3–4 programs at once.
**Bottleneck:** the **screen**, not CPU or memory. Wide spreadsheets and 1C forms need room; on a small Full HD screen she scrolls all day. Memory: 1C + Excel + a browser fit in ~8–10 GB, so 16 GB leaves room. Reliability matters too: her data is the company's money.
**Trade-off:** 16 GB instead of 32 GB and no graphics card (the Ryzen 5 7600 has built-in graphics). The ~64,000 KZT saved on memory went to a **27″ QHD monitor with height adjustment** instead of a 24″ Full HD. Alternative not taken: 32 GB — it would sit unused in this role. Windows 11 Pro is required because 1C and Kazakh bank/tax tools run on Windows.
**Total:** 646,718 KZT (budget.csv, rows 2–11)

### Build 2 — sales manager
**Load:** CRM in a browser, 30–40 tabs, Excel, about four hours of video calls a day, often all at once.
**Bottleneck:** **memory**. Chrome with forty tabs plus a video call is around 11–12 GB; on 16 GB the system has no room left for Windows and Excel and starts swapping — exactly what I saw in Lab 6: when available memory runs out, everything slows down or a process gets killed, in the middle of a customer call.
**Trade-off:** 32 GB memory, but the cheapest screen in the office (24″ Full HD) and the same 6-core Ryzen 5 — the CPU idles in this role, the memory does not. Alternative not taken: a Ryzen 7, which would cost about the same as the extra 16 GB and help less.
**Total:** 666,528 KZT (budget.csv, rows 12–21)

### Build 3 — web developer
**Load:** code editor, 2–3 browsers with dev tools, Docker with 3–5 containers (app, database, cache), sometimes a virtual machine; all running at the same time for 8 hours.
**Bottleneck:** **memory first**, then CPU cores. Every container and the VM reserve their own memory; with 16 GB the developer would have to stop containers to open a browser. CPU matters only during builds.
**Trade-off:** 32 GB memory and a 27″ QHD screen (more lines of code), but a **6-core Ryzen 5** instead of an 8-core Ryzen 7, and **Ubuntu instead of Windows**. Ubuntu is free and legally licensed (open-source, GPL), Docker runs natively on Linux, and production web servers are Linux too — so it is the better tool, not only the cheaper one. Saved: the 83,410 KZT Windows licence. Alternative not taken: Ryzen 7 7700 (+~58,000 KZT for the boxed version with cooler); AM5 lets me add it later.
**Total:** 597,338 KZT (budget.csv, rows 22–31)

### Build 4 — designer
**Load:** Photoshop and Illustrator with large files (300–1000 MB PSDs with many layers), exports, sometimes short video; 8 hours, 2–3 heavy programs at once.
**Bottleneck:** **GPU and colour accuracy**. Adobe tools use the graphics card for filters, canvas zoom and export; built-in graphics are too slow. And a designer who sees wrong colours produces wrong work, so the monitor is a working tool, not an accessory. Memory comes third — large PSDs need 32 GB.
**Trade-off:** the most expensive machine: RTX 5060, 32 GB and a 27″ QHD IPS screen with ~100 % sRGB. Given up: a factory-calibrated professional monitor (DCI-P3, 300,000+ KZT) and a 16 GB graphics card — fine for print and web design in sRGB, not enough for professional video grading. Windows 11 Pro because Adobe does not run on Linux.
**Total:** 908,814 KZT (budget.csv, rows 32–42)

---

**Grand total: 2,819,398 KZT** — 180,602 KZT under the 3,000,000 limit. The reserve covers what the request did not mention (see README, section 2).
