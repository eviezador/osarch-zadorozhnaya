#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 to UTF-8 (with BOM, LF line endings)
# Run from lab05-encoding/:  sh scripts/fix.sh
# Python is used because the iconv shipped with macOS may not know RK1048.
python3 - evidence/staff-broken.csv evidence/staff-fixed.csv <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, 'rb').read().decode('kz1048')                # 1. encoding: KZ-1048
text = text.replace('\r\n', '\n')                             # 2. line endings: CRLF -> LF
open(dst, 'w', encoding='utf-8-sig', newline='').write(text)  # 3. UTF-8 with BOM (EF BB BF)
PY
