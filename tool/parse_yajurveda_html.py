#!/usr/bin/env python3
# tool/parse_yajurveda_html.py
#
# Adds Griffith English translations to Yajurveda rows already seeded by
# parse_yajurveda.dart (which seeds Sanskrit from DharmicData).
#
# WORKFLOW:
#   1. dart run tool/parse_yajurveda.dart   ← seeds Sanskrit first
#   2. python3 tool/parse_yajurveda_html.py /path/to/wyv_html_dir/  ← adds English
#
# SETUP:  pip3 install beautifulsoup4
# USAGE:  python3 tool/parse_yajurveda_html.py /path/to/folder/
#
# Save pages wyvbk01.htm → wyvbk40.htm from sacred-texts.com into one folder.

import sys, re, sqlite3, os
from pathlib import Path
from datetime import datetime

try:
    from bs4 import BeautifulSoup
except ImportError:
    print("❌ Run: pip3 install beautifulsoup4"); sys.exit(1)

DB_PATH = os.path.join('assets', 'db', 'sanatan_guide.db')

def book_num_from_filename(filename: str) -> None:
    m = re.search(r'bk(\d+)', filename, re.IGNORECASE)
    if m: return int(m.group(1))
    m = re.search(r'Book[_ ]([IVXLCDM]+)', filename)
    if m:
        roman_map = {'I':1,'II':2,'III':3,'IV':4,'V':5,'VI':6,'VII':7,'VIII':8,
                     'IX':9,'X':10,'XI':11,'XII':12,'XIII':13,'XIV':14,'XV':15,
                     'XVI':16,'XVII':17,'XVIII':18,'XIX':19,'XX':20,'XXI':21,
                     'XXII':22,'XXIII':23,'XXIV':24,'XXV':25,'XXVI':26,'XXVII':27,
                     'XXVIII':28,'XXIX':29,'XXX':30,'XXXI':31,'XXXII':32,'XXXIII':33,
                     'XXXIV':34,'XXXV':35,'XXXVI':36,'XXXVII':37,'XXXVIII':38,
                     'XXXIX':39,'XL':40}
        return roman_map.get(m.group(1).upper())
    return None

def parse_book_file(filepath: str) -> tuple[int, list[dict]]:
    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    soup = BeautifulSoup(content, 'html.parser')
    book_num = book_num_from_filename(os.path.basename(filepath))
    if not book_num:
        # Try from HTML content
        m = re.search(r'BOOK\s+THE\s+(\w+)', content, re.IGNORECASE)
        ordinals = {'FIRST':1,'SECOND':2,'THIRD':3,'FOURTH':4,'FIFTH':5,'SIXTH':6,
                    'SEVENTH':7,'EIGHTH':8,'NINTH':9,'TENTH':10,'ELEVENTH':11,
                    'TWELFTH':12,'THIRTEENTH':13,'FOURTEENTH':14,'FIFTEENTH':15,
                    'SIXTEENTH':16,'SEVENTEENTH':17,'EIGHTEENTH':18,'NINETEENTH':19,
                    'TWENTIETH':20,'TWENTYFIRST':21,'TWENTYSECOND':22,'TWENTYTHIRD':23,
                    'TWENTYFOURTH':24,'TWENTYFIFTH':25,'TWENTYSIXTH':26,'TWENTYSEVENTH':27,
                    'TWENTYEIGHTH':28,'TWENTYNINTH':29,'THIRTIETH':30,'THIRTYFIRST':31,
                    'THIRTYSECOND':32,'THIRTYTHIRD':33,'THIRTYFOURTH':34,'THIRTYFIFTH':35,
                    'THIRTYSIXTH':36,'THIRTYSEVENTH':37,'THIRTYEIGHTH':38,'THIRTYNINTH':39,
                    'FORTIETH':40}
        if m:
            book_num = ordinals.get(m.group(1).upper().replace('-',''))
    if not book_num:
        return 0, []

    paras = soup.find_all('p')
    content_paras = []
    for p in paras:
        text = p.get_text(separator=' ', strip=True)
        if (len(text) < 10 or text.startswith('p.')
                or 'sacred-texts.com' in text.lower()
                or text.startswith('Next:') or text.startswith('Previous:')):
            continue
        content_paras.append(text)

    all_verses = []
    verse_num = 0
    for para_text in content_paras:
        segments = re.split(r'\s+(?=\d{1,3}\s+[A-Z])', para_text)
        for seg in segments:
            seg = seg.strip()
            if not seg: continue
            m = re.match(r'^(\d{1,3})\s+(.*)', seg, re.DOTALL)
            if m:
                v_num = int(m.group(1))
                v_text = ' '.join(m.group(2).split())
                all_verses.append({'verse': v_num, 'english': v_text})
                verse_num = v_num
            elif verse_num == 0:
                verse_num = 1
                v_text = ' '.join(seg.split())
                if v_text:
                    all_verses.append({'verse': 1, 'english': v_text})

    return book_num, all_verses

def collect_files(path_arg: str) -> list[str]:
    p = Path(path_arg)
    if p.is_file(): return [str(p)]
    if p.is_dir():
        files = list(p.glob('*.htm')) + list(p.glob('*.html'))
        book_files = [f for f in files if
                      re.search(r'(wyv|yajur|book)', f.name, re.IGNORECASE)
                      and not any(x in f.name.lower() for x in
                                  ['preface','index','title','content','xref','corr','pref'])]
        return sorted(str(f) for f in book_files)
    return []

def seed_db(all_book_verses: dict) -> None:
    if not os.path.exists(DB_PATH):
        print(f"❌ DB not found at {DB_PATH}"); sys.exit(1)
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    now_ms = int(datetime.now().timestamp() * 1000)
    updated = inserted = 0

    for book_num in sorted(all_book_verses.keys()):
        for v in all_book_verses[book_num]:
            verse_id = f"YV.{book_num}.{v['verse']}"
            # UPDATE existing row (Sanskrit already there from Dart tool)
            cur.execute(
                "UPDATE verses SET english=?, translation='griffith' WHERE id=?",
                [v['english'], verse_id])
            if cur.rowcount:
                updated += 1
            else:
                # Row doesn't exist yet — insert with empty Sanskrit
                cur.execute('''INSERT OR IGNORE INTO verses (
                    id, scripture, chapter_num, verse_num,
                    sanskrit, english, chapter_label, translation,
                    is_bookmarked, read_count, created_at
                ) VALUES (?, 'yajurveda', ?, ?, '', ?, ?, 'griffith', 0, 0, ?)''',
                [verse_id, book_num, v['verse'], v['english'],
                 f"Adhyaya {book_num}", now_ms])
                inserted += 1

    con.commit(); con.close()
    print(f"   Updated : {updated} | Inserted : {inserted}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 tool/parse_yajurveda_html.py <dir-with-book-files>")
        sys.exit(1)
    files = collect_files(sys.argv[1])
    if not files:
        print(f"❌ No book files found at: {sys.argv[1]}"); sys.exit(1)

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  White Yajurveda HTML Parser (Griffith 1899)")
    print(f"   Files : {len(files)}")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    all_book_verses = {}
    for filepath in files:
        book_num, verses = parse_book_file(filepath)
        if book_num and verses:
            all_book_verses[book_num] = verses
            print(f"   ✓ Adhyaya {book_num:2d}: {len(verses):3d} verses")
        else:
            print(f"   ⚠️  Skipped: {os.path.basename(filepath)}")

    total = sum(len(v) for v in all_book_verses.values())
    print(f"\n   Total: {len(all_book_verses)} adhyayas, {total} verses")
    seed_db(all_book_verses)
    print("✅ Yajurveda English added")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == '__main__':
    main()
