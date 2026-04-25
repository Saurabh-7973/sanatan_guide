#!/usr/bin/env python3
# tool/parse_tirukkural.py
# Usage: python3 tool/parse_tirukkural.py
# Verify: dart run tool/verify_tirukkural_db.dart

import re, sqlite3, os, sys
from datetime import datetime

try:
    import requests
    from bs4 import BeautifulSoup
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4 requests"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')
URL = "https://www.projectmadurai.org/pm_etexts/utf8/pmuni0001.html"

# 1330 kurals: 3 Pals, 133 adhikarams of 10 kurals each
def get_pal(verse_num):
    if verse_num <= 380: return 'அறத்துப்பால் (Arathupal — Book of Virtue)'
    if verse_num <= 700: return 'பொருட்பால் (Porutpal — Book of Wealth)'
    return 'காமத்துப்பால் (Kamathupal — Book of Love)'

def main():
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Tirukkural Parser (Project Madurai)")
    print("   Source : Tamil Unicode")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    print("   Fetching...")
    r = requests.get(URL, timeout=60); r.raise_for_status()
    soup = BeautifulSoup(r.text, 'html.parser')
    text = soup.get_text(separator='\n')

    lines = [l.strip() for l in text.splitlines()]

    verses = {}
    pending_lines = []

    for line in lines:
        line = line.replace('\xa0', ' ').strip()
        # Drop stray HTML fragments sometimes left in text
        line = re.sub(r'</?tr>\s*$', '', line, flags=re.I).strip()
        if not line:
            pending_lines = []
            continue

        m = re.search(r'\s+(\d+)\s*$', line)
        if m:
            verse_num = int(m.group(1))
            if 1 <= verse_num <= 1330:
                second = re.sub(r'\s+\d+\s*$', '', line).strip()
                if pending_lines:
                    first = '\n'.join(pending_lines)
                    full = f"{first}\n{second}" if first else second
                else:
                    full = second
                verses[verse_num] = full
                pending_lines = []
                continue

        pending_lines.append(line)
        if len(pending_lines) > 5:
            pending_lines = pending_lines[-5:]

    print(f"   Verses parsed: {len(verses)}")

    if not os.path.exists(DB_PATH):
        print("❌ DB not found"); sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("DELETE FROM verses WHERE scripture = 'tirukkural'")
    now_ms = int(datetime.now().timestamp() * 1000)
    inserted = 0

    for num in sorted(verses):
        adhikaram = ((num - 1) // 10) + 1  # 1–133
        verse_in_adhikaram = ((num - 1) % 10) + 1  # 1–10
        # Tamil primary text in `sanskrit` column (app uses one Indic-text field)
        cur.execute('''INSERT OR REPLACE INTO verses (
            id, scripture, chapter_num, verse_num, sanskrit, english,
            chapter_label, translation, is_bookmarked, read_count, created_at
        ) VALUES (?, 'tirukkural', ?, ?, ?, '', ?, 'tiruvalluvar', 0, 0, ?)''',
        [f"TK.{num}", adhikaram, verse_in_adhikaram, verses[num],
         get_pal(num), now_ms])
        inserted += 1

    con.commit(); con.close()
    print(f"   Inserted: {inserted}")
    print("✅ Tirukkural seeding complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__': main()
