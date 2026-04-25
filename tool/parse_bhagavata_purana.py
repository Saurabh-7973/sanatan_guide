#!/usr/bin/env python3
# tool/parse_bhagavata_purana.py
# Usage: python3 tool/parse_bhagavata_purana.py
# Verify: dart run tool/verify_bhagavata_purana_db.dart

import re, sqlite3, os, sys
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
    from indic_transliteration import sanscript
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 indic-transliteration requests"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')
URL = "https://gretil.sub.uni-goettingen.de/gretil/corpustei/transformations/html/sa_bhAgavatapurANa.htm"

LABELS = {
    1: 'Skanda I — Creation and the Birth of Devotion',
    2: 'Skanda II — The Cosmic Form and Liberation',
    3: 'Skanda III — Maitreya and Vidura',
    4: 'Skanda IV — The Dynasty of Manu',
    5: 'Skanda V — The World System',
    6: 'Skanda VI — Ajamila and the Vishnu Dutas',
    7: 'Skanda VII — Prahlada and Narasimha',
    8: 'Skanda VIII — The Churning of the Ocean',
    9: 'Skanda IX — The Dynasties of the Sun and Moon',
    10: 'Skanda X — The Life of Krishna',
    11: 'Skanda XI — The Uddhava Gita',
    12: 'Skanda XII — The End of the Age',
}

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Bhagavata Purana Parser")
    print("   Sanskrit : GRETIL TEI (IAST → Devanagari)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    print("   Fetching GRETIL (large file, please wait)...")
    r = requests.get(URL, timeout=120); r.raise_for_status(); r.encoding = "utf-8"
    soup = BeautifulSoup(r.text, 'html.parser')
    text = soup.get_text(separator='\n')

    # Pattern: text // BhP_SS.CC.VVV //
    # Also matches BhP_SS.CC.VVV* (variant readings marked with *)
    pattern = re.compile(
        r'([^/\n]+?)\s*//\s*BhP_(\d+)\.(\d+)\.(\d+)\*?\s*//',
        re.DOTALL
    )

    verses = {}
    for m in pattern.finditer(text):
        raw = re.sub(r'\s+', ' ', m.group(1)).strip()
        # Remove leading // or % or speaker labels like "ṛṣaya ūcuḥ"
        raw = re.sub(r'^[/%]\s*', '', raw).strip()
        # Remove BhP_ cross-references at start
        raw = re.sub(r'^BhP_[\d\.]+\s*/\d+\s*\S+\s*', '', raw).strip()
        if not raw or len(raw) < 5:
            continue
        skanda = int(m.group(2))
        chapter = int(m.group(3))
        verse   = int(m.group(4))
        key = (skanda, chapter, verse)
        if key not in verses:
            verses[key] = raw

    by_skanda = {}
    for (sk, ch, v) in verses:
        by_skanda[sk] = by_skanda.get(sk, 0) + 1
    for sk in sorted(by_skanda):
        print(f"   Skanda {sk:2d}: {by_skanda[sk]} verses")
    print(f"   Total: {len(verses)} verses")

    if not os.path.exists(DB_PATH):
        print(f"❌ DB not found"); sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'bhagavata_purana'")
    now_ms = int(datetime.now().timestamp() * 1000)
    inserted = 0

    for (sk, ch, v), iast in sorted(verses.items()):
        dev = sanscript.transliterate(iast, sanscript.IAST, sanscript.DEVANAGARI)
        # book_num = skanda; chapter_num = adhyāya within skanda; verse_num = śloka
        cur.execute('''INSERT OR REPLACE INTO verses (
            id, scripture, book_num, chapter_num, verse_num, sanskrit, english,
            chapter_label, translation, is_bookmarked, read_count, created_at
        ) VALUES (?, 'bhagavata_purana', ?, ?, ?, ?, '', ?, 'pending', 0, 0, ?)''',
        [f"BP.{sk}.{ch}.{v}", sk, ch, v, dev,
         LABELS.get(sk, f'Skanda {sk}'), now_ms])
        inserted += 1

    con.commit(); con.close()
    print(f"   Inserted: {inserted}")
    print("✅ Bhagavata Purana seeding complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__': main()
