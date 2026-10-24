# Sanatan Guide — Build & Run Commands

## ENVIRONMENT VARIABLES (required for every build)

Save these in your shell — add to `~/.zshrc`:

```bash
export GEMINI_API_KEY="<your-gemini-api-key>"  # Get one at https://aistudio.google.com/app/apikey — restrict by Android package + SHA-1
export AD_NATIVE_ID="<your-admob-native-unit-id>"
export AD_INTERSTITIAL_ID="<your-admob-interstitial-unit-id>"
export AD_APP_OPEN_ID="<your-admob-app-open-unit-id>"
```

> **Never commit real keys to this file.** Keep them in `~/.zshrc` or
> `~/.bashrc` (or a gitignored `.env.local`) and reference via `$GEMINI_API_KEY`
> in the build commands below.

Then `source ~/.zshrc` once. After that, every terminal will have these.

---

## DAILY DEV — Run on emulator (no ads, no Gemini key needed)

```bash
flutter run --device-id emulator-5554 \
  --dart-define=ADS_ENABLED=false
```

---

## DAILY DEV — Run on emulator WITH Gemini AI working

```bash
flutter run --device-id emulator-5554 \
  --dart-define=ADS_ENABLED=false \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

---

## DAILY DEV — Run on phone (debug, ads enabled)

```bash
# Find phone ID first
flutter devices

# (replace device ID if changed)
flutter run --device-id 00116646S010149 \
  --dart-define=ADS_ENABLED=true \
  --dart-define=NATIVE_AD_UNIT_ID=$AD_NATIVE_ID \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=$AD_INTERSTITIAL_ID \
  --dart-define=APP_OPEN_AD_UNIT_ID=$AD_APP_OPEN_ID \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

---

## RELEASE BUILD — APK (for direct install/testing)

```bash
flutter build apk --release \
  --dart-define=ADS_ENABLED=true \
  --dart-define=NATIVE_AD_UNIT_ID=$AD_NATIVE_ID \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=$AD_INTERSTITIAL_ID \
  --dart-define=APP_OPEN_AD_UNIT_ID=$AD_APP_OPEN_ID \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## RELEASE BUILD — AAB (for Play Store submission)

```bash
flutter clean && \
flutter pub get && \
dart run build_runner build --delete-conflicting-outputs && \
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=ADS_ENABLED=true \
  --dart-define=NATIVE_AD_UNIT_ID=$AD_NATIVE_ID \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=$AD_INTERSTITIAL_ID \
  --dart-define=APP_OPEN_AD_UNIT_ID=$AD_APP_OPEN_ID \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

# Output: build/app/outputs/bundle/release/app-release.aab
# Upload this .aab file to Play Console
```

---

## INSTALL latest release APK on phone

```bash
flutter install --device-id 00116646S010149 --release
```

---

## DEBUGGING — Watch logs

```bash
# Find phone ID
flutter devices

# Watch logs (filter Flutter only)
adb -s 00116646S010149 logcat | grep -E "🟢|🔴|➡️|⬅️|GoRouter|flutter|Error|Exception"
```

For emulator replace `00116646S010149` with `emulator-5554`.

---

## TESTS

```bash
# Run all tests
flutter test

# Run specific file
flutter test test/verse_label_test.dart

# Analyze code
flutter analyze lib --fatal-infos
dart analyze
```

---

## DB UTILITIES

```bash
# Fix DB version (forces re-copy on next install)
dart run tool/fix_db_version.dart

# Check DB content
python3 <<'PYEOF'
import sqlite3
db = sqlite3.connect('assets/db/sanatan_guide.db')
cur = db.cursor()
cur.execute("SELECT scripture, COUNT(*) FROM verses GROUP BY scripture ORDER BY COUNT(*) DESC")
total = 0
for s, c in cur.fetchall():
    print(f"  {s:<35} {c:>8}")
    total += c
print(f"  {'TOTAL':<35} {total:>8}")
db.close()
PYEOF

# Re-add DB indexes (after re-seeding)
python3 -c "
import sqlite3
db = sqlite3.connect('assets/db/sanatan_guide.db')
for s in [
    'CREATE INDEX IF NOT EXISTS idx_verses_scripture ON verses(scripture)',
    'CREATE INDEX IF NOT EXISTS idx_verses_scripture_chapter ON verses(scripture, chapter_num)',
    'CREATE INDEX IF NOT EXISTS idx_verses_id ON verses(id)',
    'CREATE INDEX IF NOT EXISTS idx_verses_scripture_id ON verses(scripture, id)',
    'CREATE INDEX IF NOT EXISTS idx_verses_bookmarked ON verses(is_bookmarked)',
]:
    db.execute(s)
db.commit()
print('Indexes created')
"
```

---

## SHOREBIRD (OTA updates)

```bash
# First-time login
shorebird login

# Initialize project (only run once)
shorebird init

# Release new version (replaces flutter build appbundle)
shorebird release android \
  --dart-define=ADS_ENABLED=true \
  --dart-define=NATIVE_AD_UNIT_ID=$AD_NATIVE_ID \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=$AD_INTERSTITIAL_ID \
  --dart-define=APP_OPEN_AD_UNIT_ID=$AD_APP_OPEN_ID \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

# Push patch (OTA update — no Play Store re-submission)
shorebird patch android \
  --dart-define=ADS_ENABLED=true \
  --dart-define=NATIVE_AD_UNIT_ID=$AD_NATIVE_ID \
  --dart-define=INTERSTITIAL_AD_UNIT_ID=$AD_INTERSTITIAL_ID \
  --dart-define=APP_OPEN_AD_UNIT_ID=$AD_APP_OPEN_ID \
  --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY
```

---

## GET GEMINI API KEY

1. Go to https://aistudio.google.com/app/apikey
2. Click "Create API Key" → "Create API key in new project"
3. Copy the key (starts with `AIza...`)
4. Add to `~/.zshrc`:
```bash
   export GEMINI_API_KEY="AIza..."
```
5. Run `source ~/.zshrc`

The key is FREE for `gemini-2.5-flash` (10 req/min, 500/day).

---

## TYPICAL DAILY WORKFLOW

```bash
# 1. Pull latest (if working with git)
git pull

# 2. Get dependencies
flutter pub get

# 3. Run codegen if you changed .freezed/.g.dart files
dart run build_runner build --delete-conflicting-outputs

# 4. Run on emulator
flutter run --device-id emulator-5554 --dart-define=ADS_ENABLED=false --dart-define=GEMINI_API_KEY=$GEMINI_API_KEY

# 5. Hot reload as you code (press 'r' in terminal)
# 6. Hot restart (press 'R' in terminal)
# 7. Quit (press 'q' in terminal)
```

---

## PRE-PLAY-STORE CHECKLIST

Before uploading new AAB to Play Console:

- [ ] Bumped `version:` in pubspec.yaml (e.g. 1.0.1+2)
- [ ] `flutter analyze lib --fatal-infos` — 0 issues
- [ ] `flutter test` — all pass
- [ ] DB version bumped if schema changed (`tool/fix_db_version.dart`)
- [ ] Tested release APK on real phone for 10 minutes — no crashes
- [ ] Updated CHANGELOG.md
- [ ] Wrote release notes for Play Console "What's new"
