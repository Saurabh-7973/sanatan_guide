# Home — "Temple Dawn" Flutter implementation

Drop-in replacement for `home_page.dart` plus six focused widgets. All files live under the existing `presentation/features/home/` tree.

## File layout

```
presentation/features/home/
├── pages/
│   └── home_page.dart              ← replaces existing home_page.dart
└── widgets/
    ├── home_app_bar.dart           ← NEW
    ├── dawn_horizon.dart           ← NEW
    ├── verse_of_day_card.dart      ← replaces existing verse_of_day_card.dart
    ├── almanac_tiles.dart          ← NEW
    ├── festival_banner.dart        ← NEW  (replaces _UpcomingFestivalRow)
    ├── path_card.dart              ← NEW  (replaces LearningProgressSummary usage)
    └── streak_line.dart            ← NEW  (replaces _StreakFooter)
```

`learning_progress_summary.dart` can remain for other screens or be retired — `path_card.dart` encapsulates the home version.

## What is preserved (no behaviour change)

| Concern | Provider / service used |
|---|---|
| Verse of the day | `verseOfDayProvider` — unchanged |
| Panchang | `PanchangUtils.getVaraForDate`, `getTithiForDate`, `getHinduDate` — unchanged |
| Festivals | `festivalsProvider` + `festivals2026` fallback — unchanged |
| Learning path | `modulesProvider` — unchanged (PathCard reads length + `isCompleted`) |
| Continue reading | `lastReadVerseProvider` — unchanged |
| Streak | `currentStreakProvider`, `StreakBadge.forStreak` — unchanged |
| App-open ad | `AppOpenAdService.instance.showIfReady()` — unchanged in `initState` |
| Navigation | All GoRouter routes (`AppRoutes.search`, `AppRoutes.settings`, `AppRoutes.festivals`, `AppRoutes.learningPath`, `/browse/:code/verse/:id`) — unchanged |
| Refresh | `RefreshIndicator` invalidates the same two providers as before |

## What changed visually

- **Scaffold** uses `extendBodyBehindAppBar: true` with no `AppBar`. The greeting is now a scrolling header so the dawn glow reaches the top edge.
- **Dawn background** — palette-safe radial gradient (saffron-on-dark 0x38 → 0) that works in both modes. Replaces the dark-only glow.
- **DawnHorizon** — CustomPainter sun-disc + 5 rays under the verse card.
- **Verse card** — translucent warm surface (`surface`/`surfaceDark` at reduced alpha), saffron-tinted 22%-alpha border, centered Sanskrit, diamond divider, italic translation.
- **Almanac tiles** — three equal-width tiles for vāra / tithi / parva, each with a CustomPainter icon (sun, live lunar phase, mandala). The lunar phase reads from `getTithiForDate(now)` and fills the shaded portion accordingly.
- **Festival banner** — warm horizontal gradient wash, no left-border accent (avoiding the "color bar" trope).
- **Path card** — progress bar is a `FractionallySizedBox` 3-px-tall gradient over a 15%-alpha track; continue row uses a saffron play bullet.
- **Streak line** — italic, accent color, `🪔 N day(s) of practice — keep the lamp burning`.

## Token usage — nothing new added

All colors come from `AppColors`:
- `saffron`, `saffronOnDark` (with `.withValues(alpha: …)` for translucency)
- `surface`, `surfaceDark`, `cream`, `bgDark`
- `textOnDark`, `textSecondaryOnDark`, `warmGrey50`, `warmGrey80`, `textSecondary`
- `sanskritText`, `sanskritTextOnDark`
- `border`, `borderDark`, `saffronFaint`

All spacing uses `AppSpacing` constants. All text styles extend existing `AppTypography` via `context.ts.*` with only `.copyWith(...)` for size/weight/letterSpacing — no `TextStyle(...)` inline.

## A couple of small judgment calls — worth confirming

1. **`lunar phase mapping`** in `almanac_tiles.dart` is a best-effort mapping from `tithi.tithiName` strings. If your `PanchangUtils` already exposes a phase fraction or tithi index, wire that in and drop `_tithiPhase`.
2. **`modulesProvider` shape**: `path_card.dart` assumes each module has `isCompleted`. If the existing `LearningProgressSummary` reads a different field, mirror that here.
3. **Removed `AppBar`**: if you rely on the Material back button / theming hooks from `AppBar` elsewhere (you don't in this page), we're fine. If the tabbed shell supplies the app bar, nothing to do.

## Performance notes

- All CustomPainters implement `shouldRepaint` correctly (only repaint on color/phase change).
- No shadows, no saturated blurs — purely solid fills + tiny strokes.
- `CustomScrollView` + slivers keeps list virtualization semantics identical to the previous `ListView`.
