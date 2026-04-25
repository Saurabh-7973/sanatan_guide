#!/usr/bin/env python3
# tool/parse_samaveda_html.py
#
# Parses the Griffith Samaveda HTML from sacred-texts.com into the app DB.
#
# USAGE:
#   pip3 install beautifulsoup4
#   python3 tool/parse_samaveda_html.py /path/to/Hymns_of_the_Samaveda.html
#
# The HTML file is the saved page from:
#   https://www.sacred-texts.com/hin/sv.htm  (all hymns in one page)
#
# OUTPUT: writes to assets/db/sanatan_guide.db

import sys
import re
import sqlite3
import os
from datetime import datetime

try:
    from bs4 import BeautifulSoup
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4")
    sys.exit(1)

# ── Config ──────────────────────────────────────────────────────────────────
DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')

# Samaveda is divided into two parts in Griffith's translation
# Part I (Archika) contains hymns addressed to Agni, Indra, Soma etc.
# We label them simply by their sequential number
# ────────────────────────────────────────────────────────────────────────────

def parse_hymns(html_path: str) -> list[dict]:
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()

    soup = BeautifulSoup(content, 'html.parser')
    paras = soup.find_all('p')

    hymn_paras = []
    for p in paras:
        text = p.get_text(separator=' ', strip=True)
        # Hymn paragraphs start with "1." (verse 1)
        if re.match(r'^1\.', text) and len(text) > 30:
            hymn_paras.append(text)

    print(f"   Hymns found : {len(hymn_paras)}")

    verses = []
    hymn_num = 0

    for hymn_text in hymn_paras:
        hymn_num += 1

        # Split into individual verses by "N. " pattern
        # Verse markers: "1. ", "2. ", "3. " etc. at word boundaries
        # Use regex to split: number followed by ". "
        verse_splits = re.split(r'\s+(\d+)\.\s+', hymn_text)

        # verse_splits[0] = text before first number (usually empty or part of verse 1)
        # then alternates: [num, text, num, text, ...]
        # Actually since we split ON "1. " at start, verse_splits may look like:
        # ['', '1', 'text...', '2', 'text...', ...]
        # OR the first element is the verse-1 text without the "1."

        # Let's use findall instead for cleaner parsing
        verse_pattern = re.findall(r'(\d+)\.\s+(.*?)(?=\s+\d+\.\s+|$)', hymn_text, re.DOTALL)

        if not verse_pattern:
            # Fallback: whole block is one verse
            clean = ' '.join(hymn_text.split())
            if clean:
                verses.append({
                    'hymn': hymn_num,
                    'verse': 1,
                    'english': clean,
                })
            continue

        for verse_num_str, verse_text in verse_pattern:
            verse_num = int(verse_num_str)
            clean = ' '.join(verse_text.split()).strip()
            if clean:
                verses.append({
                    'hymn': hymn_num,
                    'verse': verse_num,
                    'english': clean,
                })

    return verses


def seed_db(verses: list[dict]) -> None:
    if not os.path.exists(DB_PATH):
        print(f"❌ DB not found at {DB_PATH}")
        sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    cur.execute("DELETE FROM verses WHERE scripture = 'samaveda'")
    inserted = 0
    now_ms = int(datetime.now().timestamp() * 1000)

    for v in verses:
        verse_id = f"SV.{v['hymn']}.{v['verse']}"
        cur.execute('''
            INSERT OR REPLACE INTO verses (
                id, scripture, chapter_num, verse_num,
                sanskrit, english, chapter_label, translation,
                is_bookmarked, read_count, created_at
            ) VALUES (?, 'samaveda', ?, ?, '', ?, ?, 'griffith', 0, 0, ?)
        ''', [
            verse_id,
            v['hymn'],
            v['verse'],
            v['english'],
            f"Hymn {v['hymn']}",
            now_ms,
        ])
        inserted += 1

    con.commit()
    con.close()
    print(f"   Verses inserted: {inserted}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 tool/parse_samaveda_html.py <path-to-html>")
        sys.exit(1)

    html_path = sys.argv[1]
    if not os.path.exists(html_path):
        print(f"❌ File not found: {html_path}")
        sys.exit(1)

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Samaveda Parser (Griffith 1895)")
    print(f"   Source : {html_path}")
    print(f"   DB     : {DB_PATH}")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    verses = parse_hymns(html_path)
    print(f"   Total verses parsed: {len(verses)}")

    seed_db(verses)

    print("✅ Samaveda seeding complete")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


if __name__ == '__main__':
    main()
