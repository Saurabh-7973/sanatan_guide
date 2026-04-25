#!/usr/bin/env python3
# tool/parse_chandogya.py
#
# Downloads Chandogya Upanishad from GRETIL, extracts mula (root) text,
# converts IAST → Devanagari, seeds the DB.
#
# English: Max Müller translation (Sacred Books of the East Vol 1, 1879)
# from Wikisource — fetched via API.
#
# USAGE:
#   python3 tool/parse_chandogya.py
#
# REQUIRES:
#   pip3 install beautifulsoup4 indic-transliteration requests

import re, sqlite3, os, sys, time
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
    from indic_transliteration import sanscript
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 indic-transliteration requests")
    sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')
GRETIL_URL = "https://gretil.sub.uni-goettingen.de/gretil/1_sanskr/1_veda/4_upa/chupsb_u.htm"

CHAPTER_LABELS = {
    1: 'Prapathaka I — OM as the Udgitha',
    2: 'Prapathaka II — Meditation on the Saman',
    3: 'Prapathaka III — Sarvam Khalvidam Brahma',
    4: 'Prapathaka IV — Satyakama and the Teachers',
    5: 'Prapathaka V — The Five-Fire Doctrine',
    6: 'Prapathaka VI — Tat Tvam Asi',
    7: 'Prapathaka VII — Bhuma Vidya (The Infinite)',
    8: 'Prapathaka VIII — The City of Brahman',
}

def fetch_gretil() -> str:
    print("   Fetching GRETIL Sanskrit...")
    r = requests.get(GRETIL_URL, timeout=30); r.encoding = "utf-8"
    r.raise_for_status()
    return r.text

def parse_sanskrit(html: str) -> dict:
    """Returns dict: {(chapter, khanda, verse): iast_text}"""
    soup = BeautifulSoup(html, 'html.parser')
    text = soup.get_text(separator='\n')

    # Pattern: text || ChUp_N,N.N ||
    # Mula verses only (not ChUpBh_ which is Shankara's commentary)
    pattern = re.compile(
        r'([^|]+?)\|\|\s*ChUp_(\d+),(\d+)\.(\d+)\s*\|\|',
        re.DOTALL
    )

    verses = {}
    for m in pattern.finditer(text):
        raw = m.group(1).strip()
        chapter = int(m.group(2))
        khanda  = int(m.group(3))
        verse   = int(m.group(4))

        # Clean up: remove leftover markers, collapse whitespace
        clean = re.sub(r'\s+', ' ', raw).strip()
        # Remove any leading || from previous verse end
        clean = re.sub(r'^\|\|?\s*', '', clean).strip()

        if clean:
            verses[(chapter, khanda, verse)] = clean

    return verses

def iast_to_devanagari(text: str) -> str:
    try:
        return sanscript.transliterate(text, sanscript.IAST, sanscript.DEVANAGARI)
    except Exception:
        return text

def seed_db(verses_iast: dict) -> None:
    if not os.path.exists(DB_PATH):
        print(f"❌ DB not found: {DB_PATH}"); sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'chandogya_upanishad'")

    now_ms = int(datetime.now().timestamp() * 1000)
    inserted = 0

    for (chapter, khanda, verse), iast in sorted(verses_iast.items()):
        devanagari = iast_to_devanagari(iast)
        verse_id = f"CU.{chapter}.{khanda}.{verse}"
        label = CHAPTER_LABELS.get(chapter, f'Prapathaka {chapter}')

        cur.execute('''
            INSERT OR REPLACE INTO verses (
                id, scripture, chapter_num, verse_num,
                sanskrit, english, chapter_label, translation,
                is_bookmarked, read_count, created_at
            ) VALUES (?, 'chandogya_upanishad', ?, ?, ?, '', ?, 'muller_pending', 0, 0, ?)
        ''', [verse_id, chapter, verse, devanagari, label, now_ms])
        inserted += 1

    con.commit()
    con.close()
    print(f"   Inserted: {inserted} verses")
    return inserted

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Chandogya Upanishad Parser")
    print("   Sanskrit : GRETIL (IAST → Devanagari)")
    print("   English  : pending")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    html = fetch_gretil()
    verses = parse_sanskrit(html)

    # Group by chapter for reporting
    by_chapter = {}
    for (ch, kh, v) in verses:
        by_chapter.setdefault(ch, set()).add((kh, v))

    for ch in sorted(by_chapter):
        print(f"   Chapter {ch}: {len(by_chapter[ch])} verses")

    print(f"   Total: {len(verses)} verses")
    seed_db(verses)

    print("✅ Chandogya Upanishad seeding complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__':
    main()
