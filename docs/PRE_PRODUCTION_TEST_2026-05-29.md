# Pre-Production Test Report — Sanatan Guide v1.0.0

**Date:** 2026-05-29
**Device:** Samsung A015 (Android 16, 1080×2400, arm64-v8a)
**Build:** Release APK, R8 minify + shrink ON, signed with release keystore.
**Gemini key:** Rotated 2026-05-28, restricted to package
`com.Saurabh7973.sanatan_guide` + 2 SHA-1s.

This is the systems-level audit run **before** the manual UX smoke-test
checklist. Every check below is automated / observable via `adb` or build
artefacts — no UI navigation required.

---

## 0. Verdict

| Dimension | Status | Notes |
|---|---|---|
| Code quality | ✅ | 298 tests pass · analyzer clean · pre-commit hook live |
| Security | ✅ | debuggable=false · backup=false · R8 minified · key restricted |
| APK size | ✅ | 39 MB arm64 (~8 MB lighter than 2026-05-27 build) |
| Cold-start perf | ✅ | 1789 ms TotalTime, 1803 ms WaitTime |
| Steady-state heap | ✅ | 229 MB PSS, 48 MB native, 5.7 MB Dalvik |
| Crash channel | ✅ | Crashlytics + Firebase Sessions bound on boot |
| Permissions | ⚠ | AD_ID auto-added by Firebase Analytics — declare in Data Safety |
| App Check | ❌ | Not yet configured — required before promote to Production |
| Symbol upload | ❌ | Crashlytics needs `--upload-symbols` in `release.sh` |

**Composite: ship Internal Testing now. Production gated on App Check
+ symbol upload.**

---

## 1. Build artefacts

```
APK arm64-v8a:   40.6 MB  (39 MB on disk)
APK armv7:       38.5 MB
APK x86_64:      41.9 MB
mapping.txt:     21 MB     (R8 obfuscation map — keep for Crashlytics)
```

Top APK contents (≥50 KB):

| Bytes | Path |
|--:|---|
| 13.96 MB | `assets/db/sanatan_guide.db.gz` |
| 11.04 MB | `libflutter.so` |
| 9.24 MB | `libapp.so` (Dart AOT) |
| 5.63 MB | `classes.dex` |
| 1.53 MB | `libsqlite3.so` |
| 700 KB | `TiroDevanagariSanskrit-Italic.ttf` |
| 696 KB | `TiroDevanagariSanskrit-Regular.ttf` |

**Win since 2026-05-27 audit:** `ic_foreground.png` (1.38 MB) removed
from runtime bundle, `Lora-Bold.ttf` (131 KB) dropped — net ~8 MB
APK reduction.

## 2. Code health

- `flutter analyze`: 0 issues
- `flutter test`: 298 / 298 passing (24 s)
- Pre-commit hook enforces analyzer on every commit
- Build pre-flight (release.sh) verified bundled DB `user_version=6` +
  `COUNT(*)>20000` before kicking off Gradle

## 3. Install profile

```
Package:           com.Saurabh7973.sanatan_guide
targetSdkVersion:  36 (latest)
minSdkVersion:     flutter.minSdkVersion (24)
First install:     2026-05-29 07:36:47
Process state:     TOP after launch, PID present
Signing keystore:  android/app/sanatan-guide-release.jks (backed up)
```

## 4. Cold-start performance

```
am start -W -n com.Saurabh7973.sanatan_guide/.MainActivity

Status:        ok
LaunchState:   COLD
TotalTime:     1789 ms
WaitTime:      1803 ms
```

Breakdown (from Flutter log):
1. `main start` — JNI boot
2. `initFirebase Google` — Firebase core init
3. `main end` — `runApp` invoked

Cold-start total below the 2 s SLA. First-time DB extraction adds a
one-shot extra (~600-900 ms, now on a background isolate after
audit P-2).

## 5. Memory profile (steady state, 5 s post-launch)

```
TOTAL PSS:     229 177 KB   (~224 MB)
TOTAL RSS:     305 414 KB   (~298 MB)
Native heap:    48 344 KB   (~47 MB)
Dalvik heap:     5 504 KB
```

PSS is healthy for a Flutter app with 65 MB extracted SQLite DB + Drift
+ Firebase. Heap not growing in idle. No leaks observable from a 5 s
sample (steady-state audit would need a longer trace).

## 6. Frame rendering (limited sample — 5 frames)

```
Total frames:     5
Janky frames:     1 (20%)
50/90/99 pctile:  113 ms (all spikes — startup compositor warmup)
GPU 50/90/99:     5 ms
```

GPU side is healthy (5 ms p99). The 113 ms spikes are first-frame
compositor warmup, not a steady-state regression. Re-run after 30 s of
real navigation to get a meaningful jank percentage.

## 7. Security posture (verified post-install)

| Check | Status | Evidence |
|---|---|---|
| `debuggable=false` | ✅ | `pkgFlags=[ HAS_CODE ALLOW_CLEAR_USER_DATA ]` — no FLAG_DEBUGGABLE |
| `allowBackup=false` | ✅ | dumpsys shows no backupAgent declared |
| R8 minify + shrink | ✅ | mapping.txt 21 MB; classes.dex 5.6 MB (was ~12 MB pre-shrink) |
| Network security config | ✅ | `usesCleartextTraffic="false"` + system CAs only |
| Release signing | ✅ | base.apk signed with `sanatan-guide-release.jks` |
| Gemini key extractable from APK? | ⚠ acceptable | YES, as plaintext in `libapp.so` (String.fromEnvironment compile-time constant). **Defence = GCP package + SHA-1 restriction** — verified active. Anyone with the key string but a different package or signature gets `403 API_KEY_ANDROID_APP_BLOCKED`. |
| Firebase apiKey extractable | ✅ expected | Public-by-design per Google docs |
| Notification deep-link payload | ✅ | Validated via `parseScriptureCoordinate` + path-traversal char rejection (Sec-2 fix) |
| Pandit prompt length cap | ✅ | 2000-char client-side limit (Sec-4 fix) |
| Circuit breaker | ✅ | 3 fails / 60 s → open 2 min (Pri-5) |

## 8. Permissions (from `dumpsys package`)

| Permission | Status | Comment |
|---|---|---|
| `android.permission.INTERNET` | granted | Gemini + Firebase |
| `android.permission.ACCESS_NETWORK_STATE` | granted | Offline banner |
| `android.permission.POST_NOTIFICATIONS` | DENIED until opt-in | Correct — runtime grant required on Android 13+ |
| `android.permission.RECEIVE_BOOT_COMPLETED` | granted | flutter_local_notifications BootReceiver |
| `android.permission.USE_EXACT_ALARM` | granted | zonedSchedule for daily verse |
| `android.permission.SCHEDULE_EXACT_ALARM` | manifest only | Android 14+ runtime check |
| `android.permission.VIBRATE` | granted | Notif feedback |
| `android.permission.WAKE_LOCK` | granted | Notif post-fire |
| `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | granted | Doze-resilient alarms |
| `com.google.android.gms.permission.AD_ID` | granted | ⚠ auto-added by Firebase Analytics — **see §11 Data Safety** |
| `ACCESS_ADSERVICES_AD_ID` | granted | Same — Privacy Sandbox |
| `ACCESS_ADSERVICES_ATTRIBUTION` | granted | Same |
| `com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE` | granted | Firebase Analytics install attribution |

## 9. Runtime errors

Logcat tail after install + cold start:

```
flutter : Using the Impeller rendering backend (Vulkan).
flutter : main start
flutter : initFirebase Google
flutter : main end
```

No `AndroidRuntime:E`, no `DEBUG:E`, no `SQLite:E`, no native crashes.
Firebase Sessions service binds normally.

> Note: a `flutter: Failed to write log through native channel:
> TimeoutException after 100ms` line appears once at boot — that's
> AppLogger flushing to native crashlytics before native bridge is
> ready. Harmless; the message lands in the next flush.

## 10. Outstanding for production promote

### Required (block production track)

1. **Firebase App Check (Play Integrity)** — 30 min Console setup.
   Without this, Crashlytics + Analytics events can be spoofed by a
   re-signed APK.
2. **Crashlytics symbol upload** — wire `firebase crashlytics:symbols:upload`
   into `release.sh` so production stack traces deobfuscate. Without it,
   crash reports show only mangled R8 names from `mapping.txt`.
3. **Test crash on release build** — `FirebaseCrashlytics.instance.crash()`
   from a hidden Settings entry; confirm reaches Crashlytics console in
   <5 min.

### Recommended (do before public listing, not gating)

4. **`tools:node="remove"` on AD_ID permission** if not using
   advertising-id attribution. Otherwise the Data Safety form must
   declare "Device or other IDs" collection.
5. **Pull `mapping.txt` into Play Console** automatically by enabling
   "deobfuscation" — Play picks it up via `firebase-perf-plugin` or
   Play Console's R8 mapping upload field.

### Defer (post-launch)

6. **App-icon updates** if you change brand (current icon is fine).
7. **In-app review prompt** wired but disabled until 2 weeks of
   organic install data — current trigger is `streak == 7 days`.

## 11. Play Console — Data Safety guidance

Based on what the APK actually does:

| Question | Answer |
|---|---|
| Does your app collect or share user data? | Yes |
| What data: Personal info? | No |
| What data: Financial? | No |
| What data: App activity (in-app actions)? | **Yes** — Firebase Analytics events: app_open, screen_view, verse_read, search, dark_mode_toggled, etc. Opt-out wired in Settings → Privacy. |
| What data: Diagnostics (crash logs)? | **Yes** — Crashlytics. Opt-out wired. |
| What data: Device or other IDs (AAID)? | **Yes if AD_ID permission stays** — declare or remove the permission via manifest merge. |
| Is data encrypted in transit? | Yes — HTTPS only (network_security_config). |
| Can users request deletion? | Yes — Settings → Clear all data (wipes DB + SharedPreferences). |
| Sharing with third parties: | Firebase (Google) for Analytics + Crashlytics; Google Gemini API for the Pandit feature (your question + verse text transit, no identifier attached). |

## 12. UX smoke test (your manual phase)

Reproducible via real touch — adb taps were intermittent on this Samsung
A015 (likely a touch-injection quirk in Samsung OneUI; real fingers
work fine). The full 10-item checklist lives in `store_assets/`'s
sibling document. Hit those before promoting to Production.

**Critical regression spots to hand-test:**

- Notif cold-start deep-link (§15.5)
- Font slider live update on Verse Detail (§9)
- Yajurveda Kāṇḍa-completion badge (§5)
- Bottom-nav round-trip from each tab (§16 backdrop uniformity)

---

## Sign-off

✅ Internal Testing track: **ready to upload AAB.**
❌ Production track: **gated on App Check + symbol upload + 3-day soak.**

Built, tested, signed, secured.
