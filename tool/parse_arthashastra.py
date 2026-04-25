#!/usr/bin/env python3
# tool/parse_arthashastra.py
# Usage: python3 tool/parse_arthashastra.py

import re, sqlite3, os, sys
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
    from indic_transliteration import sanscript
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 indic-transliteration requests"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')
URL = "https://gretil.sub.uni-goettingen.de/gretil/corpustei/transformations/html/sa_kauTilya-arthazAstra.htm"

LABELS = {
    1:  'Book I — Concerning Discipline',
    2:  'Book II — The Duties of Government Superintendents',
    3:  'Book III — Concerning Law',
    4:  'Book IV — The Removal of Thorns',
    5:  'Book V — The Conduct of Courtiers',
    6:  'Book VI — The Source of Sovereign States',
    7:  'Book VII — The End of the Six-Fold Policy',
    8:  'Book VIII — Concerning Vices and Calamities',
    9:  'Book IX — The Work of an Invader',
    10: 'Book X — Relating to War',
    11: 'Book XI — The Conduct of Corporations',
    12: 'Book XII — Concerning a Powerful Enemy',
    13: 'Book XIII — Strategic Means to Capture a Fort',
    14: 'Book XIV — Secret Means',
    15: 'Book XV — The Plan of a Treatise',
}

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Arthashastra Parser (Kautilya)")
    print("   Sanskrit : GRETIL TEI (IAST → Devanagari)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    print("   Fetching GRETIL...")
    r = requests.get(URL, timeout=60); r.raise_for_status(); r.encoding = "utf-8"
    soup = BeautifulSoup(r.text, 'html.parser')
    text = soup.get_text(separator='\n')

    # Pattern: KAZ01.19.30ab/ text
    pattern = re.compile(r'KAZ(\d+)\.(\d+)\.(\d+)[a-z]*/\s*(.+?)(?=KAZ\d|\Z)', re.DOTALL)

    raw_halves = {}
    for m in pattern.finditer(text):
        book    = int(m.group(1))
        chapter = int(m.group(2))
        verse   = int(m.group(3))
        half    = re.sub(r'\s+', ' ', m.group(4)).strip()
        half    = re.sub(r'\[.*?\]', '', half).strip()
        key = (book, chapter, verse)
        if key not in raw_halves:
            raw_halves[key] = []
        raw_halves[key].append(half)

    verses = {}
    for key, halves in raw_halves.items():
        verses[key] = ' '.join(halves)

    by_book = {}
    for (b, c, v) in verses:
        by_book[b] = by_book.get(b, 0) + 1
    for b in sorted(by_book):
        print(f"   Book {b:2d}: {by_book[b]} verses")
    print(f"   Total: {len(verses)} verses")

    if not os.path.exists(DB_PATH):
        print("❌ DB not found"); sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'arthashastra'")
    now_ms = int(datetime.now().timestamp() * 1000)
    inserted = 0

    for (book, chapter, verse), iast in sorted(verses.items()):
        dev = sanscript.transliterate(iast, sanscript.IAST, sanscript.DEVANAGARI)
        cur.execute('''INSERT OR REPLACE INTO verses (
            id, scripture, chapter_num, verse_num, sanskrit, english,
            chapter_label, translation, is_bookmarked, read_count, created_at
        ) VALUES (?, 'arthashastra', ?, ?, ?, '', ?, 'kautilya', 0, 0, ?)''',
        [f"KAS.{book}.{chapter}.{verse}", chapter, verse, dev,
         LABELS.get(book, f'Book {book}'), now_ms])
        inserted += 1

    con.commit(); con.close()
    print(f"   Inserted: {inserted}")
    print("✅ Arthashastra seeding complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__': main()
