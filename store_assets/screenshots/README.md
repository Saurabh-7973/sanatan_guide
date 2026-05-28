# Screenshot plan

Capture 8 screens. Play Console accepts 2-8; 8 covers everything.

## Target spec

- Resolution: **1080 × 1920** (portrait) or **1440 × 2960** (better).
- Format: PNG or JPEG.
- No status bar of carrier/wifi/clock — use Android Studio "demo mode"
  before capturing, OR scrub in post.

## Capture order

| # | Screen | Caption overlay | Capture command |
|---|---|---|---|
| 1 | **Home (Verse of the Day)** | "A new verse every morning" | open app fresh → home |
| 2 | **Verse detail (BG 2.47)** | "Sanskrit · IAST · English · together" | tap verse of day |
| 3 | **Ask the Pandit chat (one Q + reply with citation chips)** | "Ask. Replies cite real verses." | open Pandit → ask "what is dharma" → wait |
| 4 | **Library — scripture grid** | "35+ classical texts in full" | bottom-nav Library |
| 5 | **Chapter list (RV Maṇḍala view) with Continue card** | "Pick up where you left off" | Library → Ṛgveda |
| 6 | **Search results with citation matches** | "Search across every text at once" | bottom-nav Search → "dharma" |
| 7 | **Bookmarks list with one personal note expanded** | "Your notes, side by side with the verse" | bottom-nav Bookmarks |
| 8 | **Festival calendar (today + earlier collapsed)** | "Pañcāṅga + day-of festival alerts" | Settings → Festivals |

## Tips

- Use a real device (Samsung A015 per your test rig) for accuracy of
  font rendering.
- `adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png ./N.png`
- Verify Devanāgarī renders without tofu in the bundled font fallback.
- Capture both light + dark themes if you have time; submit dark for #2
  (verse detail) — heritage tone reads strongest in dark.

## Post-processing

Optional: drop each PNG into a phone frame (Google's Device Art tool at
https://developer.android.com/distribute/marketing-tools/device-art-generator).

Or write captions on top via Figma / Canva — keep type small (24-32px),
sans-serif, saffron #C26A1A on warm ivory background bands.

## Filenames

```
screenshots/
  01_home.png
  02_verse_detail.png
  03_pandit_chat.png
  04_library.png
  05_chapter_list.png
  06_search.png
  07_bookmarks.png
  08_festivals.png
```

Submit in this order — Play presents them left-to-right.
