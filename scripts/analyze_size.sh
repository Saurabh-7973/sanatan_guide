#!/usr/bin/env bash
#
# Build a release APK with size analysis and open the report.
#
#   ./scripts/analyze_size.sh <GEMINI_API_KEY>
#
# Output:
#   build/app/outputs/snapshots/app-arm64-v8a-release-size-analysis_*.json
#
# Inspect with: flutter pub global run devtools (App size tool).
# Or open snapshots/ manually — flutter prints a hyperlink at the end.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "${1:-}" == "" && "${GEMINI_API_KEY:-}" == "" ]]; then
  echo "usage: $0 <GEMINI_API_KEY>" >&2
  exit 1
fi

if [[ "${1:-}" != "" ]]; then
  GEMINI_API_KEY="$1"
fi

echo "→ flutter clean"
flutter clean >/dev/null

echo "→ flutter pub get"
flutter pub get >/dev/null

echo "→ codegen"
dart run build_runner build --delete-conflicting-outputs >/dev/null

echo "→ flutter build apk --analyze-size --target-platform android-arm64"
flutter build apk \
  --release \
  --analyze-size \
  --target-platform android-arm64 \
  --dart-define=ADS_ENABLED=false \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY"

echo
echo "✓ Open the size-analysis JSON in DevTools → App Size."
echo "  (Flutter printed the absolute path above; copy it into DevTools.)"
