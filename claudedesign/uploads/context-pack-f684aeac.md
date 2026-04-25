# Sanatan Guide — App Context (v1.0.0+1)

## What the app is
Flutter Android app. Hindu scripture reader with 133K+ verses across 30+ scriptures (Gita, Vedas, Upanishads, Puranas, Arthashastra, Manusmriti, etc.). Fully offline SQLite (Drift). AI chat per verse (Gemini 2.5 Flash, rate-limited to 10/day).

## Design philosophy
Sacred, spiritual, premium. Temple warmth meets modern reading app. NOT generic AI-app aesthetic. Avoid glassmorphism, gradient bubbles, neon saffron. Think: illuminated manuscript, printed Gita commentary, Japanese tea-ceremony restraint.

## Tech stack
- Flutter 3.19+, Dart 3.x
- Riverpod 3 for state (codegen via riverpod_generator)
- Drift/SQLite for DB
- GoRouter for navigation
- Firebase Analytics + Crashlytics
- AdMob (native, interstitial, app-open — real IDs via --dart-define)
- Gemini 2.5 Flash for verse AI

## Fonts (bundled, offline-safe)
- `TiroDevanagari` — Sanskrit display (scholarly, Vedic diacritic support)
- `NotoSansDevanagari` — Hindi UI
- `Lora` — English body (serif, literary)
- `Outfit` — UI labels (sans-serif, modern)

## Color palette (exact hex, do NOT invent new)

### Brand
- `saffron`          #E8820C  — primary accent (light mode)
- `saffronOnDark`    #F4A830  — brighter on dark
- `deepRed`          #8B0000  — anchor/auspicious accent
- `gold`             #FFD700  — rare, for hero moments only

### Light mode surfaces
- `cream`            #FDFAF6  — scaffold (never pure white)
- `surface`          #F7F2EC  — cards
- `surfaceVariant`   #EDE8E2  — input fields

### Dark mode surfaces (tonal ladder, no harsh shadows)
- `bgDark`           #0F0F0F  — scaffold (warm near-black)
- `surfaceDark`      #1C1816  — cards (saffron-tinted)
- `surfaceElevated`  #221E1B  — modals, sheets
- `surfaceHighest`   #2A2520  — chips, interactive

### Text
- Light: `textPrimary` #1A1210 (warm near-black), `textSecondary` #6B6360, `textHint` #9E9A97
- Dark: `textOnDark` #F0EBE5 (warm white), `textSecondaryOnDark` #9B9390
- Sanskrit: `sanskritText` #2D1B00 (light), `sanskritTextOnDark` #E8D9C0

### Saffron opacity ladder (important — use these, not `.withOpacity`)
- `saffronFaint`  8%  — chip/icon backgrounds
- `saffronMuted` 12%  — badges, hover
- `saffronLight` 15%  — card fill
- `saffronBorder` 30% — accent borders

### Warm grey ladder (replaces saffron in non-sacred UI)
- `warmGrey10` #F2EDE6 — hover/selected bg on cream
- `warmGrey50` #8A7968 — meta text
- `warmGrey80` #3A322B — primary text on cream (softer than textPrimary)

### Scripture category accents (left-border color per category chip)
- `catItihasa`   #C45C2A  — Ramayana, Mahabharata
- `catVeda`      #B85C1C  — Rig, Yajur, Sama, Atharva
- `catUpanishad` #6B5B95  — Upanishads
- `catDarshana`  #9B7928  — Yoga sutras, philosophies
- `catStotra`    #B56576  — devotional hymns
- `catShastra`   #8D6E63  — Arthashastra, Manusmriti
- `catTantra`    #7B5B8A
- `catTamil`     #9B5E3A

## Spacing (4pt grid, from AppSpacing)
- xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48, huge=64
- Aliases: cardPadding=16, pagePadding=24, sectionGap=32, listItemSpacing=12

## Tiered border radius (critical — same radius everywhere = SaaS look)
- `radiusRow`   4   — list rows (manuscript page feel)
- `radiusChip`  8   — chips, badges
- `radiusCard`  16  — content cards
- `radiusHero`  24  — featured/VoD hero cards
- `radiusSheet` 20  — share cards, bottom sheets

## Typography scale (from AppTypography)

### Sanskrit
- `sanskritLarge`  32sp, height 2.4, letterSpacing 0.8
- `sanskritMedium` 22sp, height 2.0, letterSpacing 0.3
- `sanskritSmall`  18sp, height 2.0

### Transliteration
- `transliteration` Lora italic 15sp, italic, height 1.6 (translitText color)

### Hindi/Devanagari
- `hindiLarge` 18sp, height 1.6
- `hindiBody`  16sp

### English display
- `displayLarge`  32/600 Lora, height 1.3
- `displayMedium` 24/600 Lora
- `titleLarge`    20/600 Lora
- `titleMedium`   17/600 Lora

### Body
- `bodyLarge`  Lora 18sp, height 1.6
- `bodyMedium` Lora 16sp, height 1.6

### UI labels
- `labelLarge`  Outfit 16/600
- `labelXLarge` Outfit 15/500
- `labelMedium` Outfit 14/500
- `labelSmall`  Outfit 12/500
- `caption`     Outfit 13
- `sectionLabel` Outfit 11/700, letterSpacing 1.5, UPPERCASE in usage
- `cardLabel`    Outfit 12/600, saffron
- `captionHighlight` Outfit 13/600, saffron

## Non-negotiable rules
1. NEVER hardcode colors — use `AppColors.*` only
2. NEVER hardcode sizes/padding — use `AppSpacing.*` only
3. NEVER use inline TextStyle — use `AppTypography.*` only
4. Both light and dark mode must work (check with `Theme.of(context).brightness`)
5. All text must support 200% font scaling without overflow
6. All interactive elements ≥ 48×48dp
7. Sanskrit MUST use `TiroDevanagari` — never substitute
8. 60fps — use `ListView.builder`, avoid expensive work in `build()`
9. Preserve all existing Riverpod providers + state flow

## What I want
Redesigns that feel sacred, premium, intentional — NOT generic AI-slop spiritual-app aesthetic. Distinctive and memorable. Ancient manuscript meets 2026 reading app. Use the palette/typography/spacing above — do not invent new tokens.
