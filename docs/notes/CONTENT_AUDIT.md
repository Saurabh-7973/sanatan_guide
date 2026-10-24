# Content Audit — Sanatan Guide
> Audited: April 15, 2026
> Method: Direct SQLite queries on `assets/db/sanatan_guide.db`
> Tasks covered: 25 (Gita), 26 (Upanishads), 27 (other scriptures)

---

## Summary

| Status | Count | Meaning |
|--------|-------|---------|
| PASS | 1 | Complete, no issues |
| WARN | 8 | Missing optional fields (transliteration/hindi) |
| FAIL | 2 | Severely incomplete verse count |
| CRITICAL | 1 | All Sanskrit missing |

---

## Task 25 — Bhagavad Gita Audit ✅ PASS

**Verse count:** 700 (correct — 18 chapters)

| Chapter | Expected | Actual | Status |
|---------|----------|--------|--------|
| 1 | 47 | 47 | ✓ |
| 2 | 72 | 72 | ✓ |
| 4 | 42 | 42 | ✓ |
| 7 | 30 | 30 | ✓ |
| 11 | 55 | 55 | ✓ |
| 15 | 20 | 20 | ✓ |
| 18 | 78 | 78 | ✓ |

**Field quality:**
- Sanskrit: ✓ Present for all 700 verses, proper Devanagari
- English: ✓ Present for all 700 verses, readable sentences
- Transliteration: ✓ Present for all 700 verses, IAST with diacritics (e.g. `karmaṇyevādhikāraste`)
- Hindi: ✓ Present for all 700 verses

**Minor note:** English verses include a verse-reference prefix (e.g. `"2.47 Thy right is to work only..."`) — visible in UI but acceptable.

**Verdict: No action needed. Gita content is complete and correct.**

---

## Task 26 — Upanishad Audit ⚠️ ISSUES FOUND

### Overview

| Scripture | Expected | Actual | Sanskrit | English | Transliteration | Hindi |
|-----------|----------|--------|----------|---------|-----------------|-------|
| Isha | 18 | 18 | ✓ | ✓ | ✗ | ✗ |
| Kena | 35 | 9 | ✓ | ✓ | ✗ | ✗ |
| **Katha** | **119** | **7** | ✓ | ✓ | ✗ | ✗ |
| **Mundaka** | **64** | **7** | ✓ | ✓ | ✗ | ✗ |
| Mandukya | 12 | 12 | ✓ | ✓ | ✗ | ✗ |
| Prashna | 56 | 28 | ✓ | ✓ | ✗ | ✗ |
| Taittiriya | 20 | 20 | ✓ | ✓ | ✗ | ✗ |
| Aitareya | 15 | 15 | ✓ | ✓ | ✗ | ✗ |
| Chandogya | 629 | 623 | ✓ | ✗ | ✗ | ✗ |
| Brihadaranyaka | 432 | 432 | ✓ | ✗ | ✗ | ✗ |
| Shvetashvatara | 113 | 28 | ✓ | ✓ | ✗ | ✗ |

### Issues

**FAIL — Katha Upanishad: Only 7 of 119 verses present**
- The 7 verses that exist are famous highlights (Nachiketa story, "smaller than smallest")
- This makes the full scripture navigation look broken (only 7 verses across 2 chapters)
- **Fix options:** (a) label as "Selected Highlights" sampler, or (b) seed full data
- Recommended: mark as sampler in `_samplerIds` in scripture_library_page.dart

**FAIL — Mundaka Upanishad: Only 7 of 64 verses present**
- Same situation — famous highlights only
- **Fix:** same as Katha — add to `_samplerIds`

**WARN — Kena Upanishad: 9 of 35 verses present**
- Partial sampler, not labeled as such
- **Fix:** add to `_samplerIds`

**WARN — Prashna Upanishad: 28 of 56 verses (50%)**
- Could be intentional sampler
- **Fix:** add to `_samplerIds` or verify source data

**WARN — Shvetashvatara Upanishad: 28 of 113 verses**
- **Fix:** add to `_samplerIds`

**WARN — All 11 Upanishads: No transliteration or Hindi**
- Reading Mode toggle for "Sanskrit with Transliteration" will show blank for all Upanishads
- This is a UX gap — user taps transliteration mode, gets nothing
- **Fix options:** (a) hide transliteration toggle when no data, or (b) seed transliteration
- Short-term fix: guard the transliteration widget visibility on field presence

---

## Task 27 — Other Scriptures ⚠️ ISSUES FOUND

### Yoga Sutras (195 verses)
- Sanskrit: ✓ | English: ✓ | Transliteration: ✗ | Hindi: ✗
- Loads fine, verse count seems reasonable (Patanjali has ~196 sutras)
- **Status: WARN** — missing transliteration/hindi

### Brahma Sutras (30 verses)
- Sanskrit: ✓ | English: ✓ | Transliteration: ✗ | Hindi: ✗
- Only 30 verses (Brahma Sutras have 555) — clearly a sampler
- **Status: WARN** — should be labeled "Selected Highlights"

### Hatha Yoga Pradipika (60 verses)
- Sanskrit: ✓ | English: ✓ | Transliteration: ✗ | Hindi: ✗
- 60 verses (HYP has ~389) — sampler
- **Status: WARN** — should be labeled "Selected Highlights"

### Vishnu Sahasranama (118 verses)
- Sanskrit: ✓ | English: ✓ | Transliteration: ✗ | Hindi: ✗
- 118 names — close to complete (1000 names poem = ~108 verses)
- **Status: WARN** — missing transliteration

### Manusmriti (54 verses)
- Sanskrit: ✓ | English: ✓ | Transliteration: ✗ | Hindi: ✗
- 54 of 2685 verses — small sampler
- **Status: WARN** — should be labeled "Selected Highlights"

### Mahanirvana Tantra (60 verses)
- Sanskrit: ✓ | English: ✓ | Transliteration: ✗ | Hindi: ✗
- 60 of 2165 verses — small sampler
- **Status: WARN** — should be labeled "Selected Highlights"

---

## Veda Content Issues (informational — not in sprint scope)

| Scripture | Total | Missing Sanskrit | Missing English |
|-----------|-------|-----------------|-----------------|
| Samaveda | 1719 | **1719 (ALL)** | 0 |
| Atharvaveda | 5627 | 4861 (86%) | 25 |
| Yajurveda | 1977 | 29 | 64 |
| Rigveda | 9508 | 539 | 0 |

**Samaveda CRITICAL:** All 1719 verses missing Sanskrit. The Samaveda Sanskrit reading mode will be fully blank. This should be fixed or the Sanskrit toggle disabled for Samaveda.

---

## Action Items (Task 28)

### Priority 1 — Code fixes (no data change needed)

- [ ] **28a.** Add Katha, Mundaka, Kena, Prashna, Shvetashvatara, Brahma Sutras, HYP, Manusmriti, Mahanirvana Tantra to `_samplerIds` in [scripture_library_page.dart](lib/presentation/features/scripture_library/pages/scripture_library_page.dart)
- [ ] **28b.** In verse_detail_page, guard transliteration section — only show if transliteration field is non-empty (prevents blank section when user picks "Sanskrit + Transliteration" mode for Upanishads)
- [ ] **28c.** Same guard for Hindi section

### Priority 2 — Data fixes (need seed script updates)

- [ ] **28d.** Samaveda: investigate why Sanskrit is missing — check `tool/parse_samaveda_html.py`
- [ ] **28e.** Yajurveda: fix 64 verses with no English (chapters 6, 7, 8, 12 affected)
- [ ] **28f.** Atharvaveda: decide whether to source Sanskrit or document as English-only sampler

### Not blocking v1
- Upanishad transliteration (seeding IAST for all Upanishads is significant work)
- Hindi translations for non-Gita scriptures
