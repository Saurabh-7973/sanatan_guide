#!/usr/bin/env python3
# tool/parse_ramayana.py
# Usage: python3 tool/parse_ramayana.py
# Verify: dart run tool/verify_ramayana_db.dart

import re, sqlite3, os, sys
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
    from indic_transliteration import sanscript
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 indic-transliteration requests"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')
URL = "https://gretil.sub.uni-goettingen.de/gretil/corpustei/transformations/html/sa_rAmAyaNa.htm"

LABELS = {
    1: 'Balakanda — Childhood of Rama',
    2: "Ayodhyakanda — Rama's Exile",
    3: 'Aranyakanda — Forest Life',
    4: 'Kishkindhakanda — Alliance with Vanaras',
    5: "Sundarakanda — Hanuman's Journey",
    6: 'Yuddhakanda — The War',
    7: 'Uttarakanda — Epilogue',
}

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Valmiki Ramayana Parser")
    print("   Sanskrit : GRETIL TEI (IAST → Devanagari)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    print("   Fetching GRETIL (large file, please wait)...")
    r = requests.get(URL, timeout=180); r.raise_for_status(); r.encoding = "utf-8"
    soup = BeautifulSoup(r.text, 'html.parser')

    verses = {}
    # Each verse is a <p id="R_K.SSS.VVV"> (zero-padded sarga/verse in source)
    for p in soup.find_all('p', id=re.compile(r'^R_\d+\.\d+\.\d+$')):
        pid = p.get('id', '')
        m = re.match(r'^R_(\d+)\.(\d+)\.(\d+)$', pid)
        if not m:
            continue
        kanda = int(m.group(1))
        sarga = int(m.group(2))
        verse = int(m.group(3))

        for span in p.find_all('span', class_='ref'):
            span.decompose()
        raw = p.get_text(separator=' ')
        clean = re.sub(r'\s+', ' ', raw).strip()
        if not clean:
            continue

        verses[(kanda, sarga, verse)] = clean

    by_kanda = {}
    for (k, s, v) in verses:
        by_kanda[k] = by_kanda.get(k, 0) + 1
    for k in sorted(by_kanda):
        print(f"   Kanda {k}: {by_kanda[k]} verses")
    print(f"   Total: {len(verses)} verses")

    if not os.path.exists(DB_PATH):
        print("❌ DB not found"); sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'ramayana'")
    now_ms = int(datetime.now().timestamp() * 1000)
    inserted = 0

    for (kanda, sarga, verse), iast in sorted(verses.items()):
        dev = sanscript.transliterate(iast, sanscript.IAST, sanscript.DEVANAGARI)
        # book_num = kanda; chapter_num = sarga; verse_num = śloka (per verses_table)
        cur.execute('''INSERT OR REPLACE INTO verses (
            id, scripture, book_num, chapter_num, verse_num, sanskrit, english,
            chapter_label, translation, is_bookmarked, read_count, created_at
        ) VALUES (?, 'ramayana', ?, ?, ?, ?, '', ?, 'valmiki', 0, 0, ?)''',
        [f"RAM.{kanda}.{sarga}.{verse}", kanda, sarga, verse, dev,
         LABELS.get(kanda, f'Kanda {kanda}'), now_ms])
        inserted += 1

    con.commit(); con.close()
    print(f"   Inserted: {inserted}")
    print("✅ Ramayana seeding complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__':
    main()
