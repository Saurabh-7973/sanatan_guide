#!/usr/bin/env python3
# tool/parse_mahabharata.py
# Usage: python3 tool/parse_mahabharata.py
# Verify: dart run tool/verify_mahabharata_db.dart
#
# Downloads all 18 Parvas from GRETIL, parses verse text,
# converts IAST → Devanagari, seeds DB.

import re, sqlite3, os, sys, time
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
    from indic_transliteration import sanscript
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 indic-transliteration requests"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')

BASE_URL = "https://gretil.sub.uni-goettingen.de/gretil/1_sanskr/2_epic/mbh/mbh_{:02d}_u.htm"

PARVA_LABELS = {
    1:  'Adi Parva — The Book of Beginnings',
    2:  'Sabha Parva — The Book of the Assembly Hall',
    3:  'Vana Parva — The Book of the Forest',
    4:  'Virata Parva — The Book of Virata',
    5:  'Udyoga Parva — The Book of the Effort',
    6:  'Bhishma Parva — The Book of Bhishma',
    7:  'Drona Parva — The Book of Drona',
    8:  'Karna Parva — The Book of Karna',
    9:  'Shalya Parva — The Book of Shalya',
    10: 'Sauptika Parva — The Book of the Sleeping Warriors',
    11: 'Stri Parva — The Book of the Women',
    12: 'Shanti Parva — The Book of Peace',
    13: 'Anushasana Parva — The Book of Instructions',
    14: 'Ashvamedhika Parva — The Book of the Horse Sacrifice',
    15: 'Ashramavasika Parva — The Book of the Hermitage',
    16: 'Mausala Parva — The Book of the Clubs',
    17: 'Mahaprasthanika Parva — The Book of the Great Journey',
    18: 'Svargarohana Parva — The Book of the Ascent to Heaven',
}

def parse_parva(html: str, parva_num: int) -> dict:
    soup = BeautifulSoup(html, 'html.parser')
    text = soup.get_text(separator='\n')

    # Format: 01,001.001a     text<BR>
    # Parva,Chapter.Versehalfverse   text
    pattern = re.compile(
        r'^\s*\d+,(\d+)\.(\d+)[a-z*_\d]*\s+(.+?)(?:<BR>|$)',
        re.MULTILINE
    )

    raw_halves = {}
    for m in pattern.finditer(text):
        chapter = int(m.group(1))
        verse   = int(m.group(2))
        half    = m.group(3).strip()
        # Skip variant readings (lines with * in marker handled already)
        # Clean up
        half = re.sub(r'\[.*?\]', '', half).strip()
        half = re.sub(r'\s+', ' ', half).strip()
        if not half or half in ('.', '*'): continue
        key = (chapter, verse)
        if key not in raw_halves:
            raw_halves[key] = []
        raw_halves[key].append(half)

    verses = {}
    for key, halves in raw_halves.items():
        verses[key] = ' '.join(halves)
    return verses

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Mahabharata Parser (Tokunaga/Smith)")
    print("   Sanskrit : GRETIL (IAST → Devanagari)")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    if not os.path.exists(DB_PATH):
        print(f"❌ DB not found: {DB_PATH}"); sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'mahabharata'")
    con.commit()

    now_ms = int(datetime.now().timestamp() * 1000)
    total_inserted = 0

    for parva in range(1, 19):
        url = BASE_URL.format(parva)
        print(f"   Fetching Parva {parva:2d}...", end=' ', flush=True)
        try:
            r = requests.get(url, timeout=60); r.encoding = "utf-8"
            r.raise_for_status()
        except Exception as e:
            print(f"❌ {e}")
            continue

        verses = parse_parva(r.text, parva)
        label = PARVA_LABELS.get(parva, f'Parva {parva}')
        inserted = 0

        for (chapter, verse), iast in sorted(verses.items()):
            dev = sanscript.transliterate(iast, sanscript.IAST, sanscript.DEVANAGARI)
            cur.execute('''INSERT OR REPLACE INTO verses (
                id, scripture, chapter_num, verse_num, sanskrit, english,
                chapter_label, translation, is_bookmarked, read_count, created_at
            ) VALUES (?, 'mahabharata', ?, ?, ?, '', ?, 'vyasa', 0, 0, ?)''',
            [f"MBH.{parva}.{chapter}.{verse}", chapter, verse, dev, label, now_ms])
            inserted += 1

        con.commit()
        total_inserted += inserted
        print(f"{inserted} verses")
        time.sleep(0.5)  # be polite to GRETIL server

    con.close()
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"   Total inserted: {total_inserted}")
    print(f"✅ Mahabharata seeding complete")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__': main()
