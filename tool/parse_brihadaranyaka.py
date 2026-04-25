#!/usr/bin/env python3
# tool/parse_brihadaranyaka.py
# Usage: python3 tool/parse_brihadaranyaka.py

import re, sqlite3, os, sys
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
    from indic_transliteration import sanscript
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 indic-transliteration requests"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')
URL = "https://gretil.sub.uni-goettingen.de/gretil/1_sanskr/1_veda/4_upa/brupsb_u.htm"

LABELS = {
    1: 'Adhyaya I — The Horse Sacrifice and Creation',
    2: 'Adhyaya II — Yajnavalkya and Brahman',
    3: 'Adhyaya III — The Forest Dialogues',
    4: 'Adhyaya IV — Yajnavalkya and Janaka',
    5: 'Adhyaya V — Disciplines and Brahman',
    6: 'Adhyaya VI — Panchagni Vidya and Lineage',
}

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Brihadaranyaka Upanishad Parser")
    print("   Sanskrit : GRETIL (IAST → Devanagari)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    print("   Fetching GRETIL...")
    r = requests.get(URL, timeout=30); r.raise_for_status(); r.encoding = "utf-8"
    soup = BeautifulSoup(r.text, 'html.parser')
    text = soup.get_text(separator='\n')

    pattern = re.compile(r'([^|]+?)\|\|\s*BrhUp_(\d+),(\d+)\.(\d+)\s*\|\|', re.DOTALL)
    verses = {}
    for m in pattern.finditer(text):
        raw = re.sub(r'\s+', ' ', m.group(1)).strip()
        raw = re.sub(r'^\|\|?\s*', '', raw).strip()
        if raw:
            verses[(int(m.group(2)), int(m.group(3)), int(m.group(4)))] = raw

    by_ch = {}
    for (ch, br, v) in verses: by_ch.setdefault(ch, 0); by_ch[ch] += 1
    for ch in sorted(by_ch): print(f"   Adhyaya {ch}: {by_ch[ch]} verses")
    print(f"   Total: {len(verses)} verses")

    if not os.path.exists(DB_PATH): print(f"❌ DB not found"); sys.exit(1)
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'brihadaranyaka_upanishad'")
    now_ms = int(datetime.now().timestamp() * 1000)
    inserted = 0
    for (ch, br, v), iast in sorted(verses.items()):
        dev = sanscript.transliterate(iast, sanscript.IAST, sanscript.DEVANAGARI)
        cur.execute('''INSERT OR REPLACE INTO verses (
            id, scripture, chapter_num, verse_num, sanskrit, english,
            chapter_label, translation, is_bookmarked, read_count, created_at
        ) VALUES (?, 'brihadaranyaka_upanishad', ?, ?, ?, '', ?, 'muller_pending', 0, 0, ?)''',
        [f"BAU.{ch}.{br}.{v}", ch, v, dev, LABELS.get(ch, f'Adhyaya {ch}'), now_ms])
        inserted += 1
    con.commit(); con.close()
    print(f"   Inserted: {inserted}")
    print("✅ Brihadaranyaka Upanishad complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__': main()
