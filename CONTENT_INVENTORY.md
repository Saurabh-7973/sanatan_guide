# Content Inventory — Ground Truth

Audit of the **actual readable scripture content** in the shipping build, for Play
Store listing accuracy. Counts are real row counts queried from the bundled
database — not from comments, docs, or variable names.

**Method**
- Shipping DB is `assets/db/sanatan_guide.db.gz` (the `.db` is a 0-byte
  placeholder, decompressed at runtime). Decompressed and queried directly.
- Verse counts: `SELECT scripture, COUNT(*) FROM verses GROUP BY scripture`.
- Defined set: `Scripture` enum in `lib/domain/entities/scripture.dart` (32 entries).
- Reachability: traced the Library UI (`scripture_library_page.dart`) catalogue +
  `_openScripture()` + routes in `lib/core/router/`.

Audit date: 2026-06-14. DB grand total verified: **133,613 rows** across **32** codes.

---

## Table

| Text (display name) | Defined (enum) | Seeded (≥1 row) | Verse count | Reachable in UI |
|---|---|---|---|---|
| Mahābhārata | ✅ | ✅ | 72,770 | ✅ |
| Rāmāyaṇa | ✅ | ✅ | 18,761 | ✅ |
| Bhāgavata Purāṇa | ✅ | ✅ | 14,031 | ✅ |
| Ṛgveda | ✅ | ✅ | 9,508 | ✅ |
| Atharvaveda | ✅ | ✅ | 5,627 | ✅ |
| Arthaśāstra | ✅ | ✅ | 5,371 | ✅ |
| Yajurveda | ✅ | ✅ | 1,978 | ✅ |
| Sāmaveda | ✅ | ✅ | 1,719 | ✅ |
| Tirukkuṟaḷ | ✅ | ⚠️ broken | 1,326 (half-couplets) | ❌ DISABLED v1 |
| Bhagavad Gītā | ✅ | ✅ | 700 | ✅ |
| Chāndogya Upaniṣad | ✅ | ✅ | 623 | ❌ data present, no UI path |
| Bṛhadāraṇyaka Upaniṣad | ✅ | ✅ | 432 | ❌ data present, no UI path |
| Yoga Sūtras | ✅ | ✅ | 195 | ✅ |
| Viṣṇu Sahasranāma | ✅ | ✅ | 118 | ✅ |
| Haṭha Yoga Pradīpikā | ✅ | ✅ | 60 | ✅ |
| Mahānirvāṇa Tantra | ✅ | ✅ | 60 | ✅ |
| Manusmṛti | ✅ | ✅ | 54 | ✅ |
| Brahma Sūtras | ✅ | ✅ | 30 | ✅ |
| Praśna Upaniṣad | ✅ | ✅ | 28 | ❌ data present, no UI path |
| Śvetāśvatara Upaniṣad | ✅ | ✅ | 28 | ❌ data present, no UI path |
| Viṣṇu Purāṇa | ✅ | ✅ | 28 | ✅ |
| Maitrāyaṇī Upaniṣad | ✅ | ✅ | 24 | ❌ data present, no UI path |
| Devī Bhāgavata Purāṇa | ✅ | ✅ | 20 | ✅ |
| Taittirīya Upaniṣad | ✅ | ✅ | 20 | ❌ data present, no UI path |
| Īśa Upaniṣad | ✅ | ✅ | 18 | ✅ (Mukhya card opens this one) |
| Kauṣītaki Upaniṣad | ✅ | ✅ | 18 | ❌ data present, no UI path |
| Mārkaṇḍeya Purāṇa | ✅ | ✅ | 16 | ✅ |
| Aitareya Upaniṣad | ✅ | ✅ | 15 | ❌ data present, no UI path |
| Māṇḍūkya Upaniṣad | ✅ | ✅ | 12 | ❌ data present, no UI path |
| Kena Upaniṣad | ✅ | ✅ | 9 | ❌ data present, no UI path |
| Kaṭha Upaniṣad | ✅ | ✅ | 7 | ❌ data present, no UI path |
| Muṇḍaka Upaniṣad | ✅ | ✅ | 7 | ❌ data present, no UI path |

**Defined:** 32 · **Seeded:** 32 · **Enum-only stubs (defined, 0 rows):** 0 ·
**Data present but unreachable:** 12 · **UI rows with no data:** 0.

---

## 1. Defined vs. Seeded
All **32** texts in the `Scripture` enum are seeded with real content (≥1 row).
There are **no** enum-only stubs and **no** UI entries that lack data. The enum
codes map 1:1 to the 32 distinct `scripture` values in the `verses` table.

## 2. Verse counts
Exact row counts are in the table above. **Grand total = 133,613 verses.**
Structure (from `chapter_num` / `book_num`): the large texts are multi-book —
Mahābhārata 17 books / 354 chapters, Rāmāyaṇa 7 / 116, Bhāgavata Purāṇa 12 / 90,
Arthaśāstra 15 / 36; the Vedas use a flat chapter index (Ṛgveda 10 maṇḍalas,
Sāmaveda 439, Yajurveda 40, Atharvaveda 20). Several smaller texts are
**curated selections**, not complete editions (e.g. Manusmṛti 54 of ~2,685;
Viṣṇu Purāṇa 28; Mārkaṇḍeya 16) — the counts above are what actually ships.

## 3. User-reachable
Reader routes exist and work: `/browse/:id` → `/browse/:id/chapter/:n` →
`/browse/:id/verse/:verseId`. The Library lists 20 openable cards (each routes by
its DB `id`).

**⚠️ Reachability gap — 12 Upaniṣads have data but no way to open them.**
The 13 Mukhya Upaniṣads are collapsed into a single "Mukhya Upaniṣads" card whose
`onTap` calls `_openScripture('isha_upanishad')` — it opens **only Īśa Upaniṣad**.
A code comment claims a `/library/upanishads` collection page exists; it does
**not** (no route, no page file). The chapter/verse reader is scoped to one
scripture and offers no cross-text navigation, and in-library search only surfaces
the single Mukhya card. So these 12 are dark content today:
Chāndogya (623), Bṛhadāraṇyaka (432), Praśna (28), Śvetāśvatara (28),
Maitrāyaṇī (24), Taittirīya (20), Kauṣītaki (18), Aitareya (15), Māṇḍūkya (12),
Kena (9), Kaṭha (7), Muṇḍaka (7) = **1,223 verses unreachable via the UI.**

No text appears in the UI without backing data.

## 4. Summary (after Tirukkuṟaḷ disabled, 2026-06-14)

**Tirukkuṟaḷ content audit:** 1,325 of 1,326 rows are ≤4 words; 1,296 are exactly
3 words = only the **second line** of each kural. Zero rows have a full 6–8 word
couplet, and there is no English translation. The text is unfit to display, so it
was **disabled** for v1 (Tamil family removed from the library catalogue +
search; data left in the DB; daily verse is Bhagavad-Gītā-only so it can't leak).
Re-enable when full couplets + translation are seeded.

- **X = 19** texts a user can actually open and read today.
- **Y = 131,064** verses actually readable through the UI
  (133,613 present − 1,223 unreachable Upaniṣads − 1,326 disabled Tirukkuṟaḷ).
- The **19 readable texts** (by display name):
  Bhagavad Gītā, Ṛgveda, Sāmaveda, Yajurveda, Atharvaveda, Īśa Upaniṣad,
  Yoga Sūtras, Brahma Sūtras, Haṭha Yoga Pradīpikā, Rāmāyaṇa, Mahābhārata,
  Viṣṇu Purāṇa, Devī Bhāgavata Purāṇa, Bhāgavata Purāṇa, Mārkaṇḍeya Purāṇa,
  Viṣṇu Sahasranāma, Arthaśāstra, Manusmṛti, Mahānirvāṇa Tantra.
- The Library hero now computes **31** (was 32) since the Tamil family is gone;
  note this still counts 13 Mukhya Upaniṣads of which only Īśa is openable.

### Listing-accuracy implications
- "**32 scriptures**" — 32 are *bundled*, but only **20 are openable**. Claiming 32
  as browsable/readable is currently inaccurate. Either fix the Upaniṣad card to
  open a collection (unlocks all 13 → 32 honest) or phrase as "32 texts included".
- "**1,33,613 verses**" — all present in the build, but only **132,390 are
  reachable**. The difference (1,223) is the 12 dark Upaniṣads.
- Recommended fix (small, high value): make the Mukhya Upaniṣads card open a
  collection listing all 13, each routing to `/browse/<code>`. That makes both the
  "32" and the full verse count truthful with no data work.
