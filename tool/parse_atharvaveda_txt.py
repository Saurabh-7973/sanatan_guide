#!/usr/bin/env python3
# tool/parse_atharvaveda_txt.py
#
# Parses the Griffith Atharvaveda plain-text file (e.g. av.txt from sacred-texts)
# into English on rows seeded by parse_atharvaveda.dart (Sanskrit).
#
# USAGE:
#   gunzip -c ~/Downloads/av.txt.gz > /tmp/av.txt
#   python3 tool/parse_atharvaveda_txt.py /tmp/av.txt

import os
import re
import sqlite3
import sys
from datetime import datetime
from typing import Dict

DB_PATH = os.path.join("assets", "db", "sanatan_guide.db")


def code_to_row(code: str) -> dict:
    """Griffith 7-digit marker: BB HHH VV (book, hymn, verse)."""
    book = int(code[0:2])
    hymn = int(code[2:5])
    verse = int(code[5:7])
    return {
        "id": f"AV.{book}.{hymn}.{verse}",
        "book": book,
        "hymn": hymn,
        "verse": verse,
    }


def parse(txt_path: str) -> Dict[str, str]:
    with open(txt_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()

    by_id: Dict[str, str] = {}

    # Pass 1: slice between consecutive [NNNNNNN] markers (robust to broken HYMN blocks).
    markers = list(re.finditer(r"\[(\d{7})\]", content))
    for i, m in enumerate(markers):
        code = m.group(1)
        start = m.end()
        end = markers[i + 1].start() if i + 1 < len(markers) else len(content)
        raw = content[start:end]
        raw = re.split(r"\[p\.", raw, maxsplit=1)[0]
        clean = re.sub(r"\s+", " ", raw).strip()
        if not clean:
            continue
        meta = code_to_row(code)
        by_id[meta["id"]] = clean

    # Pass 2: block regex (often cleaner boundaries); overwrites when non-empty.
    verse_pattern = re.compile(
        r"\[(\d{7})\](.*?)(?=\[\d{7}\]|\[p\.|BOOK\s+[IVXL]|$)", re.DOTALL
    )
    for m in verse_pattern.finditer(content):
        code = m.group(1)
        text = re.sub(r"\s+", " ", m.group(2).strip())
        if not text:
            continue
        meta = code_to_row(code)
        by_id[meta["id"]] = text

    return by_id


def seed(by_id: Dict[str, str]) -> None:
    if not os.path.exists(DB_PATH):
        print(f"❌ DB not found at {DB_PATH}")
        sys.exit(1)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    now_ms = int(datetime.now().timestamp() * 1000)
    updated = inserted = 0

    for vid, english in sorted(by_id.items()):
        cur.execute(
            "UPDATE verses SET english=?, translation='griffith' WHERE id=?",
            [english, vid],
        )
        if cur.rowcount:
            updated += 1
        else:
            parts = vid.split(".")
            book = int(parts[1])
            hymn = int(parts[2])
            verse = int(parts[3])
            cur.execute(
                """INSERT OR IGNORE INTO verses (
                id, scripture, chapter_num, verse_num,
                sanskrit, english, chapter_label, translation,
                is_bookmarked, read_count, created_at
            ) VALUES (?, 'atharvaveda', ?, ?, '', ?, ?, 'griffith', 0, 0, ?)""",
                [vid, book, verse, english, f"Kaanda {book} — Sukta {hymn}", now_ms],
            )
            inserted += cur.rowcount

    con.commit()
    con.close()
    print(f"   Updated : {updated} | Inserted : {inserted}")


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python3 tool/parse_atharvaveda_txt.py /tmp/av.txt")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"❌ File not found: {path}")
        sys.exit(1)

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("🕉  Atharvaveda Parser (Griffith)")
    print(f"   Source : {path}")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    by_id = parse(path)
    print(f"   Verses parsed : {len(by_id)}")
    seed(by_id)
    print("✅ Atharvaveda English pass complete")
    print("   Next: dart run tool/verify_atharvaveda_db.dart")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")


if __name__ == "__main__":
    main()
