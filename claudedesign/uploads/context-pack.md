# Sanatan Guide — App Context

## What the app is
Flutter Android app (v1.0.0+1). Hindu scripture reader with 133,600+ verses across 30+ scriptures. Fully offline SQLite. AI chat per verse (Gemini 2.5 Flash).

## Design philosophy
Sacred, spiritual, premium. Temple-like warmth meets modern reading app. Ancient manuscript aesthetic.

## Current tech stack
- Flutter 3.19+
- Riverpod 3 (state management)
- Drift/SQLite (DB)
- GoRouter (navigation)
- Firebase Analytics + Crashlytics
- AdMob
- Gemini 2.5 Flash for AI

## Fonts already bundled
- TiroDevanagariSanskrit — for Sanskrit verse display
- NotoSansDevanagari — for Hindi translations
- Lora — English body text (serif)
- Outfit — UI labels (sans-serif)

## Color palette
- Saffron primary: #E8820C
- Dark scaffold: #0F0F0F (warm near-black)
- Dark card: #1C1816 (saffron-tinted)
- Light scaffold: #FDFAF6 (warm cream)
- Light card: #F7F2EC
- Warm white text on dark: #F0EBE5
- Warm near-black text on ligh

## Spacing system (4pt grid)
xs=4, sm=8, md=12, lg=16, xl=24, xxl=32, xxxl=48
Card radius: 16. Chip radius: 8. Row radius: 4. Hero radius: 24.

## Typography scale
Display: 32/24. Body: 18/16. Caption: 13.
Sanskrit: 22/18 with 2.0 line height.
Labels: 16/14/12 with 1.3 line height.

## What I want
I want to redesign every screen to feel premium, sacred, and intentional. Currently the screens work functionally but feel generic. I want distinctive, memorable design that doesn't look like a typical AI-generated app.

## Constraints
- Must work in both light and dark mode
- Must preserve all existing functionality
- Must use the color palette and fonts above (no new colors/fonts)
- Must remain performant (60fps, list virtualization preserved)
