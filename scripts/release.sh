#!/usr/bin/env bash
#
# Canonical release build for Play Store upload.
#
#   ./scripts/release.sh <GEMINI_API_KEY> [--apk]
#
# Defaults to App Bundle (smaller user-facing download — Play serves a
# device-specific APK ~18-22 MB vs. the universal 47 MB fat APK).
# Pass --apk if you need a sideloadable artifact for QA.
#
# Requirements:
#   - GEMINI_API_KEY arg (or env var) — baked into the build via
#     String.fromEnvironment. Restrict it in Google Cloud Console
#     (Android-app-only + SHA-1 + quota cap) before shipping.
#   - android/key.properties must exist (release signing config).
#   - The release keystore (.jks) must be backed up offsite — losing it
#     means no future updates.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "${1:-}" == "" && "${GEMINI_API_KEY:-}" == "" ]]; then
  echo "usage: $0 <GEMINI_API_KEY> [--apk]" >&2
  exit 1
fi

if [[ "${1:-}" != "" && "${1}" != --* ]]; then
  GEMINI_API_KEY="$1"
  shift
fi

MODE="appbundle"
if [[ "${1:-}" == "--apk" ]]; then
  MODE="apk"
fi

if [[ ! -f android/key.properties ]]; then
  echo "ERROR: android/key.properties is missing. Cannot sign release." >&2
  exit 2
fi

echo "→ verify bundled DB sanity (PRAGMA user_version + verses table)"
# Drift tracks schema via SQLite's PRAGMA user_version, not a __schema_version
# table. The bundled DB ships at user_version=6 today; runtime migrations
# (6→7 FTS5, 7→8 verse_explanations, 8→9 commentaries) bring it up to 9
# on first launch. Guardrails below catch the two ways this can break:
#   1. user_version drifts backwards (bundled DB regenerated incorrectly).
#   2. The core verses table is empty (a corrupted DB would still pass the
#      schema check otherwise).
EXPECTED_USER_VERSION=6
MIN_VERSES=20000  # current shipping count is ~70k; pad against truncation.
DB_GZ="assets/db/sanatan_guide.db.gz"
if [[ ! -f "$DB_GZ" ]]; then
  echo "ERROR: bundled DB $DB_GZ is missing." >&2
  exit 3
fi
TMP_DB="$(mktemp)"
trap 'rm -f "$TMP_DB"' EXIT
if ! gunzip -c "$DB_GZ" > "$TMP_DB"; then
  echo "ERROR: $DB_GZ failed to decompress." >&2
  exit 3
fi
ACTUAL_UV="$(sqlite3 "$TMP_DB" 'PRAGMA user_version' 2>/dev/null || true)"
if [[ "$ACTUAL_UV" != "$EXPECTED_USER_VERSION" ]]; then
  echo "ERROR: bundled DB has PRAGMA user_version=$ACTUAL_UV, expected $EXPECTED_USER_VERSION." >&2
  echo "       Drift onUpgrade is wired for the 6→9 path; a different starting" >&2
  echo "       version means migrations may collide or skip required steps." >&2
  exit 3
fi
ACTUAL_VERSES="$(sqlite3 "$TMP_DB" 'SELECT COUNT(*) FROM verses' 2>/dev/null || echo 0)"
if [[ "$ACTUAL_VERSES" -lt "$MIN_VERSES" ]]; then
  echo "ERROR: bundled DB only has $ACTUAL_VERSES verses (expected >= $MIN_VERSES)." >&2
  exit 3
fi

echo "→ flutter clean"
flutter clean >/dev/null

echo "→ flutter pub get"
flutter pub get >/dev/null

echo "→ codegen (build_runner)"
dart run build_runner build --delete-conflicting-outputs >/dev/null

case "$MODE" in
  appbundle)
    echo "→ flutter build appbundle"
    flutter build appbundle \
      --release \
      --dart-define=ADS_ENABLED=false \
      --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"
    OUT="build/app/outputs/bundle/release/app-release.aab"
    ;;
  apk)
    echo "→ flutter build apk --split-per-abi"
    flutter build apk \
      --release \
      --split-per-abi \
      --dart-define=ADS_ENABLED=false \
      --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"
    OUT="build/app/outputs/flutter-apk"
    ;;
esac

echo
echo "✓ Built: $OUT"
echo
echo "Next:"
echo "  - Upload to Play Console Internal Testing track"
echo "  - Verify Data Safety + IARC content rating already filled"
echo "  - Soak on a real device for 3 days before promoting to Production"
