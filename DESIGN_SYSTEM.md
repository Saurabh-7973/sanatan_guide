# Sanatan Guide — Design System Reference

> **Synthesized from:** Reference Design System (reference) audit  
> **Philosophy:** Sacred Minimalism — editorial calm, not corporate polish  
> **Stack:** Flutter · Material 3 · Riverpod · Outfit / Lora / TiroDevanagari

---

## 1. Design Philosophy

The Reference system excels at:
- **Systematic component coverage** — every state designed (default, focused, error, disabled)
- **Tonal elevation** — layers of dark surfaces without harsh shadows
- **Purposeful color** — purple/blue for data, orange for CTAs, green/red for semantics

**Sanatan Guide adapts these structural strengths** while replacing financial aesthetics with warmth, sacred weight, and editorial calm. We borrow the *engineering discipline* of Reference, not its *visual vocabulary*.

---

## 2. Color Tokens (`app_colors.dart`)

### Brand
| Token | Hex | Usage |
|---|---|---|
| `saffron` | `#E8820C` | Primary CTA, selected states |
| `saffronOnDark` | `#F4A830` | Saffron on dark (higher contrast) |
| `deepRed` | `#8B0000` | Secondary, category accents |
| `gold` | `#FFD700` | Streak rewards, special highlights |

### Opacity Variants (pre-computed — never use `.withOpacity()`)
| Token | Alpha | Usage |
|---|---|---|
| `saffronFaint` | 8% | Chip/icon backgrounds |
| `saffronMuted` | 12% | Badges, hover |
| `saffronLight` | 15% | Card fills |
| `saffronBorder` | 30% | Accent borders |

### Light Mode Surfaces
| Token | Hex | Role |
|---|---|---|
| `cream` | `#FDFAF6` | Scaffold (L0) |
| `surface` | `#F7F2EC` | Cards (L1) |
| `surfaceVariant` | `#EDE8E2` | Input fields (L2) |

### Dark Mode Surfaces (tonal elevation — saffron-tinted)
| Token | Hex | Role |
|---|---|---|
| `bgDark` | `#0F0F0F` | Scaffold (L0) |
| `surfaceDark` | `#1C1816` | Cards (L1) |
| `surfaceElevated` | `#221E1B` | Modals, sheets (L2) |
| `surfaceHighest` | `#2A2520` | Chips, interactive (L3) |

> **Reference Lesson:** Reference uses `#12111A → #1C1B29 → #252438` — three distinct tonal steps. We mirror this with *warm* (saffron-tinted) equivalents instead of cool (blue-tinted).

### Text
| Token | Hex | Usage |
|---|---|---|
| `textPrimary` | `#1A1210` | Primary (light mode) |
| `textSecondary` | `#6B6360` | Secondary, meta |
| `textHint` | `#9E9A97` | Placeholder |
| `textOnDark` | `#F0EBE5` | Primary (dark mode) |
| `textSecondaryOnDark` | `#9B9390` | Secondary (dark mode) |

### Semantic
| Token | Hex | Usage |
|---|---|---|
| `success` | `#2E7D32` | Completion, streak |
| `error` | `#B71C1C` | Errors, destructive |
| `warning` | `#F57F17` | Warnings |

### Scripture Category Accents
| Token | Hex | Category |
|---|---|---|
| `catItihasa` | `#C45C2A` | Ramayana, Mahabharata |
| `catVeda` | `#B85C1C` | Vedas |
| `catUpanishad` | `#6B5B95` | Upanishads |
| `catDarshana` | `#9B7928` | Philosophy |
| `catStotra` | `#B56576` | Hymns |
| `catShastra` | `#8D6E63` | Treatises |
| `catTantra` | `#7B5B8A` | Tantra |
| `catTamil` | `#9B5E3A` | Tamil scriptures |

---

## 3. Typography (`app_typography.dart`)

**Three font families — strict role separation:**

| Family | Role |
|---|---|
| `TiroDevanagari` | Sanskrit verse display only |
| `NotoSansDevanagari` | Hindi/Devanagari body text |
| `Lora` | English body, display headings |
| `Outfit` | All UI labels, buttons, captions |

### Type Scale
| Style | Font | Size | Weight | LH | Usage |
|---|---|---|---|---|---|
| `displayLarge` | Lora | 32 | 600 | 1.3 | Page titles |
| `displayMedium` | Lora | 24 | 600 | 1.3 | Section headings, AppBar |
| `titleLarge` | Lora | 20 | 600 | 1.35 | Card titles, chapter names |
| `titleMedium` | Lora | 17 | 600 | 1.4 | Subsection titles |
| `bodyLarge` | Lora | 18 | 400 | 1.6 | Main reading body |
| `bodyMedium` | Lora | 16 | 400 | 1.6 | Secondary body |
| `labelXLarge` | Outfit | 15 | 500 | 1.4 | Primary button text, nav |
| `labelLarge` | Outfit | 16 | 600 | 1.3 | Bold UI labels |
| `labelMedium` | Outfit | 14 | 500 | 1.3 | Secondary UI labels |
| `labelSmall` | Outfit | 12 | 500 | 1.3 | Badges, dense meta |
| `caption` | Outfit | 13 | 400 | 1.3 | Captions, timestamps |
| `sectionLabel` | Outfit | 11 | 700 | 1.3 | Section headers (UPPERCASE, 1.5 tracking) |
| `cardLabel` | Outfit | 12 | 600 | 1.3 | Card type labels (saffron) |

### Sanskrit-Specific
| Style | Font | Size | LH | Notes |
|---|---|---|---|---|
| `sanskritLarge` | TiroDevanagari | 32 | 2.4 | Hero verse display |
| `sanskritMedium` | TiroDevanagari | 22 | 2.0 | Standard verse |
| `sanskritSmall` | TiroDevanagari | 18 | 2.0 | Compact verse |
| `transliteration` | Lora | 15 | 1.6 | Italic, translitText color |

> **Reference Lesson:** Reference uses Inter at 10/12/14/16/18/20/24sp — purely functional. We keep the same *structural discipline* (no skipping steps) but use editorial fonts for content and geometric (Outfit) for UI — creating a sacred/functional duality.

---

## 4. Spacing (`app_spacing.dart`)

### Base Grid (4pt)
| Token | Value | Usage |
|---|---|---|
| `xs` | 4dp | Icon gaps, tight padding |
| `sm` | 8dp | Component internal padding |
| `md` | 12dp | List item spacing |
| `lg` | 16dp | Card padding |
| `xl` | 24dp | Page horizontal padding |
| `xxl` | 32dp | Section gaps |
| `xxxl` | 48dp | Large separators |
| `huge` | 64dp | Hero section spacing |

### Border Radius (tiered — emotional weight)
| Token | Value | Usage |
|---|---|---|
| `radiusRow` | 4dp | List rows — manuscript feel |
| `radiusChip` | 8dp | Chips, small badges |
| `radiusCard` | 16dp | Content cards |
| `radiusHero` | 24dp | Hero cards, featured content |
| `radiusSheet` | 20dp | Bottom sheets |

> **Reference Lesson:** Reference uses consistent 8dp radius throughout. Our tiered system is the key differentiator — giving Sanatan Guide an organic, editorial feel vs. uniform "SaaS" look.

---

## 5. Component Specifications

### 5.1 Buttons

Reference reference shows SM/MD/LG sizes × Primary/Secondary/Ghost/Destructive variants × 4 states.

```
Primary CTA
  Background:  saffron (#E8820C)
  Text:        white, labelLarge (Outfit 16 w600)
  Padding:     horizontal 24dp, vertical 14dp
  Radius:      10dp  [Reference uses 8dp; we soften slightly]
  Elevation:   0

Secondary / Outlined
  Border:      saffron, 1.5dp
  Text:        saffron, labelLarge
  Background:  transparent

Ghost / Text
  Text:        textSecondary, labelMedium

Destructive
  Background:  error (#B71C1C)
  Text:        white

All variants — Disabled state: 38% opacity, no interaction
```

### 5.2 Input Fields

Reference shows: Default → Focused (purple border) → Error (red border) → Disabled → Filled.

```
Default
  Background:  surface (light) / surfaceDark (dark)
  Border:      1dp, border color
  Radius:      10dp

Focused
  Border:      saffron, 2dp
  Label:       floats above, saffron color

Error
  Border:      error, 1.5dp
  Helper text: error color, caption style

Disabled
  Background:  surfaceVariant @ 50%
  Text:        textHint
```

### 5.3 Chips / Tags

Reference shows SM/MD/LG × Normal/Purple/Orange × with/without left+right icons × dismissible.

```
Category Chip (scripture filter)
  Inactive bg:   saffronFaint (8%)
  Inactive border: saffronBorder (30%)
  Selected bg:   saffron
  Selected text: white
  Radius:        radiusChip (8dp)
  Height:        28dp SM / 32dp MD

Semantic Chip
  Success: successMuted bg + success text
  Error:   errorLight bg + error text
```

### 5.4 Bottom Navigation Bar

```
Background (light):  surface (#F7F2EC)
Background (dark):   surfaceDark (#1C1816)
Selected:            saffron icon + text
Unselected:          textSecondary
Height:              60dp + safe area
Top border:          divider, 1dp
```

### 5.5 App Bar / Title Bar

Reference shows: back + title, back + title + subtitle, title + up to 3 action icons.

```
Background:    transparent (scaffold color)
Title:         displayMedium (Lora 24 w600)
Subtitle:      caption (Outfit 13, textSecondary)
Back button:   24dp icon, textPrimary
Action icons:  24dp, textSecondary
Elevation:     0
```

### 5.6 Modals / Bottom Sheets

Reference shows: Info, Form, List picker, Confirmation, Full-screen variants.

```
Background:   surfaceElevated (dark) / surface (light)
Radius (top): radiusSheet (20dp)
Handle:       4dp × 32dp pill, border color, centered
Header:       20dp top + 24dp horizontal padding
Footer:       24dp, dual-button row (outlined + primary CTA)
Max height:   85% of screen
```

### 5.7 Cards

```
Standard card
  Background:  surface / surfaceDark
  Radius:      radiusCard (16dp)
  Border:      border/borderDark, 1dp
  Padding:     cardPadding (16dp)
  Elevation:   0 (tonal only)

Hero card (featured scripture)
  Radius:      radiusHero (24dp)
  May include: gradient overlay for text legibility

List row
  Radius:      radiusRow (4dp)
  Height:      56–72dp
  Divider:     bottom, divider color
```

### 5.8 Snackbars

Reference shows: Success/Normal/Error/Warning × with icon / without icon × with action / without.

```
Background:   surfaceHighest (#2A2520 dark)
Text:         textOnDark, labelMedium
Icon:         16dp, semantic color
Action text:  saffron, labelMedium
Duration:     4s (error: persistent)
Radius:       8dp
Margin:       16dp horizontal, 12dp above nav bar
```

### 5.9 Search Bar

Reference shows: Default → Active (typing) → With filter chip → Multi-token.

```
Background:    surfaceVariant / surfaceHighest
Border:        border 1dp (focused: saffron 2dp)
Radius:        16dp (pill feel)
Height:        48dp
Leading:       search icon, textSecondary
Trailing:      × when text present
Filter tokens: chips inside field for active filters
```

### 5.10 Controls

Reference shows Toggle/Checkbox/Radio at sizes 12/16/20/24dp × On/Off × Enabled/Disabled.

```
Toggle
  Active track:   saffron
  Inactive track: border / borderDark
  Thumb:          white

Checkbox
  Checked:    saffron fill, white check
  Unchecked:  border 2dp stroke
  Radius:     4dp

Radio
  Selected:   saffron ring + saffron dot
  Unselected: border 2dp stroke
```

---

## 6. Interaction Patterns

### States (all interactive elements must have all four)
```
Default → Hover/Focus → Pressed → Disabled
  Hover:    saffronFaint overlay (8%)
  Pressed:  saffronLight overlay (15%) + scale(0.97)
  Focus:    2dp saffron border ring
  Disabled: 38% opacity, no pointer events
```

### Loading States
- **Content lists:** Skeleton loaders (warm shimmer), NOT spinners
- **Progress indicator:** saffron `CircularProgressIndicator`, 2dp stroke
- **Button loading:** spinner replaces text label, button disabled

### Animation Timing
| Type | Duration | Curve |
|---|---|---|
| Micro (icon, color change) | 150ms | easeInOut |
| Component (modal open) | 250ms | easeOut |
| Page transitions | 300ms | easeInOut |
| Celebration (streak) | 600ms | elasticOut |

---

## 7. Elevation & Shadow

Reference uses **zero drop shadows** — pure tonal elevation (surface color shifts). We adopt the same.

```
L0 → L1:  Surface color change only
L1 → L2:  Surface color change + 1dp border
L2 modal:  BoxShadow(offset: (0, -4), blur: 16, color: black@12%)
```

---

## 8. Gap Analysis — Current vs. Target

### ✅ Already Aligned
- Full color token architecture (`app_colors.dart`)
- Three-family typography with complete scale
- 4pt spacing grid with semantic aliases
- Tiered border radius (4/8/16/20/24dp)
- Card/button/input ThemeData for both light + dark
- Tonal elevation in dark mode

### ⚠️ Missing / Needs Work

| Gap | Priority | File to Create/Update |
|---|---|---|
| No `SanatanButton` widget (only ThemeData) | 🔴 HIGH | `shared/widgets/sanatan_button.dart` |
| `outlinedButtonTheme` missing from ThemeData | 🔴 HIGH | `theme/app_theme.dart` |
| No chip/tag widget | 🔴 HIGH | `shared/widgets/sanatan_chip.dart` |
| No snackbar helper | 🟡 MEDIUM | `shared/widgets/sanatan_snackbar.dart` |
| No `SanatanBottomSheet` wrapper | 🟡 MEDIUM | `shared/widgets/sanatan_bottom_sheet.dart` |
| No search bar widget | 🟡 MEDIUM | `shared/widgets/sanatan_search_bar.dart` |
| InputDecorationTheme missing disabled state | 🟢 LOW | `theme/app_theme.dart` |
| Nav label not using `labelXLarge` style | 🟢 LOW | `theme/app_theme.dart` |
| Animation constants not codified | 🟢 LOW | `theme/app_spacing.dart` |

---

## 9. Implementation Roadmap

### Phase 1 — Foundation
1. Add `outlinedButtonTheme` + `filledButtonTheme` to `app_theme.dart`
2. Create `SanatanButton` (primary, outlined, ghost variants)
3. Create `SanatanChip` (category, semantic, dismissible)
4. Create `SnackbarHelper.show()` with 4 semantic variants

### Phase 2 — Navigation & Containers
5. `SanatanBottomSheet.show()` — standard wrapper
6. `SanatanSearchBar` widget
7. Audit all widgets in `shared/widgets/` against this spec

### Phase 3 — Polish
8. Animation timing constants in `app_spacing.dart`
9. Shadow token constant for bottom sheet
10. Full dark/light mode screenshot regression

---

## 10. File Reference Map

```
lib/presentation/theme/
  app_colors.dart        → Section 2 (Color Tokens)
  app_typography.dart    → Section 3 (Typography)
  app_spacing.dart       → Section 4 (Spacing)
  app_theme.dart         → Section 5 (Component ThemeData)

lib/presentation/shared/widgets/
  sacred_card.dart           → Section 5.7 (Cards)
  shimmer_loading.dart       → Section 6 (Loading states)
  scaffold_with_nav_bar.dart → Section 5.4 (Bottom Nav)
  verse_preview_tile.dart    → Section 5.5 (Title Bar pattern)

  [TO CREATE]
  sanatan_button.dart        → Section 5.1
  sanatan_chip.dart          → Section 5.3
  sanatan_snackbar.dart      → Section 5.8
  sanatan_bottom_sheet.dart  → Section 5.6
  sanatan_search_bar.dart    → Section 5.9
```

---

## 11. Design Principles Checklist

Before shipping any new screen, verify:

- [ ] No raw `Color(0xFF...)` in widget files — use `AppColors.*`
- [ ] No inline `TextStyle(...)` — use `AppTypography.*`
- [ ] No hardcoded padding — use `AppSpacing.*`
- [ ] All interactive elements have default/focused/disabled states
- [ ] Dark mode tested (no hardcoded white/black)
- [ ] Saffron used **only** for: selected states, CTAs, spiritual emphasis
- [ ] Sanskrit text → `TiroDevanagari`; UI text → `Outfit`; body → `Lora`
- [ ] Border radius follows tiered system: row=4, chip=8, card=16, hero=24

---

*Last updated: April 2026 | Source: Reference Design System audit (reference) + Sanatan Guide codebase*
