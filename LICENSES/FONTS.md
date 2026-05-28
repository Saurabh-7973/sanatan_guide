# Bundled Font Licenses

All four font families shipped under `assets/fonts/` use the SIL Open Font
License 1.1 (OFL-1.1). Bundling, redistribution within the APK / AAB, and
inclusion in derived works is permitted under that license; the only
restrictions are (a) the fonts cannot be sold by themselves, and
(b) reserved names cannot be reused for modified versions.

## Tiro Devanagari Sanskrit

- **Files:** `TiroDevanagariSanskrit-Regular.ttf`, `-Italic.ttf`
- **Designer:** Tiro Typeworks (John Hudson)
- **License:** SIL Open Font License, Version 1.1
- **Source:** https://fonts.google.com/specimen/Tiro+Devanagari+Sanskrit
- **Use:** Sanskrit / IAST display — the only family that consistently
  renders dot-diacritics (ṛ, ṣ, ṭ, ṇ) and Vedic accent marks without
  tofu. Reserved as `Fonts.deva` across the app.

## Noto Sans Devanagari

- **Files:** `NotoSansDevanagari-Regular.ttf`, `-Medium.ttf`, `-SemiBold.ttf`,
  `-Bold.ttf`
- **Designer:** Google Fonts
- **License:** SIL Open Font License, Version 1.1
- **Source:** https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari
- **Use:** Hindi UI body text — broader Unicode coverage than Tiro.
  Fallback chain when Tiro can't render a specific codepoint.

## Lora

- **Files:** `Lora-Regular.ttf`, `-Medium.ttf`, `-SemiBold.ttf`, `-Bold.ttf`,
  `-Italic.ttf`
- **Designer:** Cyreal
- **License:** SIL Open Font License, Version 1.1
- **Source:** https://fonts.google.com/specimen/Lora
- **Use:** English body / commentary / translations. Serif tone matches the
  "ancient manuscript" reading aesthetic.

## Outfit

- **Files:** `Outfit-Regular.ttf`, `-Medium.ttf`, `-SemiBold.ttf`, `-Bold.ttf`
- **Designer:** Smith Holdings & Rodrigo Fuenzalida
- **License:** SIL Open Font License, Version 1.1
- **Source:** https://fonts.google.com/specimen/Outfit
- **Use:** UI labels, buttons, navigation. Modern sans for chrome.

## SIL Open Font License 1.1 — full text

The full OFL-1.1 text is included as a sibling file
[`SIL-OFL-1.1.txt`](./SIL-OFL-1.1.txt) for distribution compliance. Each
font's TTF also embeds the license metadata internally.
