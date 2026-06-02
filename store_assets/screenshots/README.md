# Screenshot plan

Capture 8 screens. Play Console accepts 2-8; 8 covers everything.

## Captured status (2026-06-02)

7 of 8 captured on emulator-5554 (Medium_Phone, 1080×2400), current `main`
debug build. Demo-mode status bar (clock 9:00, full battery, no notif icons).

| # | File | Status |
|---|------|--------|
| 1 Home | `01_home.png` | ✅ |
| 2 Verse detail (BG 12.17) | `02_verse_detail.png` | ✅ (Listen action gone, current build) |
| 3 Pandit chat + citation chips | — | ⏳ **needs Gemini-keyed build** — chat returns no AI reply without `--dart-define=GEMINI_API_KEY`. Capture from the keyed `release.sh` build. |
| 4 Library grid | `04_library.png` | ✅ |
| 5 Chapter list (Ṛgveda maṇḍalas) | `05_chapter_list.png` | ✅ |
| 6 Search "dharma" | `06_search.png` | ✅ |
| 7 Bookmarks + note | `07_bookmarks.png` | ✅ (seeded BG 12.17 bookmark + note) |
| 8 Festivals / pañcāṅga | `08_festivals.png` | ✅ |

**Two output sets:**
- Root `0N_*.png` — raw 1080×2400 device captures.
- `play_ready/0N_*.png` — **padded to 1200×2400** (cream `#F5EDE0` side bars).
  Play rejects screenshots where the long side is > 2× the short side; raw
  1080×2400 is 2.22:1 and would bounce. Padded set is exactly 2:1. **Upload the
  `play_ready/` set.**

Clean status bar: another app on the emulator (`com.example.bigul_app`) runs
a foreground service whose ONGOING|NO_CLEAR notification icon demo-mode can't
hide. Before capturing (incl. shot 3 later), disable it:
`adb shell pm disable-user --user 0 com.example.bigul_app`, then re-enable
after with `adb shell pm enable com.example.bigul_app`.

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
| 4 | **Library — scripture grid** | "32 classical texts" | bottom-nav Library |
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
