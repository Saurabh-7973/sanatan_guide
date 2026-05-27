# 🕉 Sanatan Guide
> **Ancient wisdom, beautifully presented.**

Sanatan Guide is a premium, "Sacred Minimalism" Flutter application for exploring the depths of Hindu scriptures. It provides a sanctuary for spiritual growth, featuring over 50+ sacred texts, curated learning paths, and a daily ritual dashboard.

---

## 🏛 The Design: Sacred Minimalism
The app is built on a custom design system that prioritizes focus, breath, and cultural resonance:
- **Temple Dawn UI**: A radiant home experience featuring a custom-painted rising sun ornament and a radial saffron glow.
- **Saffron Economy**: Sparse, intentional use of saffron (#E8820C) for sacred moments and primary actions.
- **Warmth & Texture**: Cream (#FDFAF6) and Dark Saffron-tinted (#0F0F0F) surfaces that mimic ancient manuscripts.
- **Premium Typography**: Tiro Devanagari (Sanskrit), Lora (English), and Outfit (UI).

---

## 📖 Core Features

### 🌅 Temple Dawn Dashboard
The daily entry point into the app:
- **Verse of the Day**: A high-drama hero card centering your daily practice.
- **Celestial Almanac**: Real-time tracking of Vāra (day), Tithi (lunar phase), and upcoming Parvas (festivals).
- **Festival Sanctuary**: Upcoming festivals with countdowns and ritual significance.
- **Path Progress**: A gentle, non-aggressive tracking of your spiritual learning journey.

### 📚 The Infinite Library
Explore over 50+ scriptures including the **Bhagavad Gita**, the **Four Vedas**, **Principal Upanishads**, **Ramayana**, **Mahabharata**, and **Tirukkural**.
- **Categorized Discovery**: Browse by Itihasa, Veda, Upanishad, and more.
- **Immersive Reading**: Breathable Devanagari, transliteration, multiple translations, and word-by-word meanings.

### 🛤 Learning Path (Dharma 101)
A winding journey through curated modules designed for everyone from beginners to scholars.
- **Card-based Wisdom**: Spaced-repetition style learning.
- **Milestone Badges**: Earn sacred badges like *Sadhaka* and *Tapasvi* as you progress.

---

## 🛠 Tech Stack
- **Framework**: Flutter (Material 3)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Persistence**: SQLite (FTS5 Search) via Drift
- **AI**: Gemini 2.5 Flash (verse explanations, word gloss, Pandit chat)
- **Animations**: flutter_animate + Custom Painters

---

## 🚀 Build & Run

```bash
# Dev (debug + ads off)
flutter run --dart-define=ADS_ENABLED=false \
            --dart-define=GEMINI_API_KEY=<your-key>

# Release App Bundle for Play upload (Play splits per-device → ~20MB user APK)
./scripts/release.sh <GEMINI_API_KEY>

# Release universal APK for sideload QA
./scripts/release.sh <GEMINI_API_KEY> --apk

# Size analysis (DevTools App Size tool)
./scripts/analyze_size.sh <GEMINI_API_KEY>
```

### Codegen

`build_runner` drives Drift, Riverpod, Freezed, json_serializable.
After modifying any annotated source:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Tests + analyze

```bash
flutter analyze && flutter test
```

CI runs both on push to `main` (`.github/workflows/flutter.yml`). Install
the local pre-commit hook to catch analyze regressions before pushing:

```bash
./scripts/install_git_hooks.sh
```

---

## 🔒 Release checklist

Before shipping a new version to Play Store:
1. **Restrict the Gemini key in GCP Console** — Android-app-only + SHA-1
   fingerprint + quota cap. Without this, anyone who extracts the APK
   can drain your billing.
2. **Back up the release keystore offsite** — `android/app/sanatan-guide-release.jks`
   and `android/key.properties`. Losing them means no future updates.
3. **Verify Firebase Security Rules** are locked (Firestore + Storage,
   Remote Config is read-only by design).
4. Build via `./scripts/release.sh` (defaults to App Bundle).
5. Upload to Play Console → Internal testing track, soak for 3 days on
   real devices, then promote to Production.

See `LAUNCH_ASSESSMENT_2026-05-27.md` for the full pre-launch audit
(security, performance, app size, code quality, legal/Play store gaps).

---

*Sanatan Guide · Sacred Minimalism · Ancient Wisdom*
