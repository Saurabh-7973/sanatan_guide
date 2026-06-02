# Production Readiness Audit (April 2026) — Response Ledger

Walks the audit section by section. **CODE** = fixed/already-satisfied in this
repo. **MANUAL** = requires a person (Play Console, account, device, a
decision, or a verified external resource). Last updated 2026-06-02.

---

## CODE — fixed this pass or already satisfied

| § | Item | Status |
|---|------|--------|
| 1 | App label "Sanatan Guide", package final, version `1.0.0+1` | ✅ already (manifest `android:label`, pubspec) |
| 2/11 | targetSdk / compileSdk ≥ 35 | ✅ already — uses `flutter.targetSdkVersion`/`compileSdkVersion` = **36** (Flutter 3.35.4). minSdk = `flutter.minSdkVersion` = 24. |
| 6 | Permissions block (INTERNET, ACCESS_NETWORK_STATE, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, SCHEDULE/USE_EXACT_ALARM, VIBRATE, WAKE_LOCK) | ✅ already present; AD_ID + AdServices stripped via `tools:node=remove` (ads dropped v1) |
| 6 | `usesCleartextTraffic="false"` | ✅ already + `networkSecurityConfig` |
| 7 | Crashlytics: `FlutterError.onError` + `PlatformDispatcher.onError` + boot `runZonedGuarded` + `recordError` | ✅ already (main.dart) |
| 7/11 | R8 mapping upload (`mappingFileUploadEnabled = true`) | ✅ already (build.gradle.kts) |
| 11 | ProGuard rules (Flutter, Firebase, Drift, Riverpod, GSON/notifications, line numbers) | ✅ already |
| 12 | Signing config reads `key.properties`; release signed | ✅ already (build.gradle.kts) |
| 13 | HTTPS-only Gemini calls; friendly network errors; circuit breaker; offline banner | ✅ already (gemini_service.dart) |
| 14 | API key via `--dart-define`, never in source | ✅ already |
| 14 | Client rate limit 10/day (chat) | ✅ already (`GeminiRateLimit`) |
| 4/14 | **AI-generated label on every AI response** | ✅ FIXED — `AiMessage` footer |
| 4/14 | **Disclaimer "AI responses may contain errors. Always refer to traditional commentaries."** | ✅ FIXED |
| 4/14 | **Report/flag button on every AI message** → Crashlytics + analytics + AppLogger + confirm toast | ✅ FIXED |
| 4 | **Crisis interception scaffold** (narrow first-person self-harm only; no Gemini call, no quota burn) + system-prompt hardening | ✅ FIXED (mechanism; resource content is MANUAL — see below) |
| 8 | `ai_chat_message` analytics event | ✅ FIXED — wired in both chat dispatches |
| 8 | User properties `streak_days` / `preferred_theme` / `font_size` | ✅ FIXED — `setUserProperty` wired at streak/theme/font change points |
| 15 | `flutter analyze lib --fatal-infos` = 0 issues; no `print()`; no hardcoded keys | ✅ verified |

---

## MANUAL — requires you

### Decisions (code could change, but shouldn't be flipped silently)
- **§6 `allowBackup`** — currently **`false`** (deliberate, with `dataExtractionRules`/`fullBackupContent=false`). Audit suggests `true`. Flipping it makes Android auto-backup the Drift DB **including users' bookmarks + personal notes**. That's a data-safety/UX call (good: notes survive reinstall; risk: schema-mismatch on restore). Decide, then I'll set it.
- **§14 model name** — primary is `gemini-3.5-flash` (speculative, dated comment), fallback `gemini-2.5-flash`. Can't verify `3.5-flash` resolves without the live key. If it 404s, every uncached call eats a wasted round-trip before falling back. **Verify against the live API**; if it doesn't exist, make `gemini-2.5-flash` primary (one-line change).

### Crisis resource content (§4) — content, not code
- The crisis interception **mechanism** ships now, but with a **generic fallback** message only ("please reach out to local emergency services or a crisis line"). **Do not** ship a hardcoded helpline number from me — a wrong/defunct/region-mismatched number is active harm. Supply a verified resource (org + number + region, e.g. India Tele-MANAS 14416 if you confirm it) and I'll wire it into `crisis_support.dart`.

### Recommended, but native deps / accounts / devices (do not auto-add)
- **§9 Shorebird** — `shorebird login` / `init` / `release android`; needs account. Note: can't patch the SQLite DB or assets.
- **§10 `in_app_update`** — adds a native plugin; needs Play context + on-device test of the update flow. Not added blind.

### Play Console / account / device (cannot be done from code)
- **§3 Closed testing** — 12+ testers opted-in 14 continuous days (account post-2023-11-13).
- **§5 Data Safety form** — declare Analytics/Crashlytics data, Gemini messages (sent, not stored), Android ID. (Note: AD_ID permission is stripped — answer Device IDs accordingly.)
- **§7** — `firebase login`, note Android App ID, run `crashlytics:symbols:upload` after each release build; force a test crash to confirm.
- **§8** — verify events in DebugView; mark conversion events.
- **§12** — keystore backup in 2 locations; enable Play App Signing.
- **§16** — profile-mode perf pass (cold start, frame times, AAB < 100 MB).
- **§17** — TalkBack pass, 200% font, contrast, touch targets.
- **§18** — host Privacy Policy at a **permanent URL (GitHub Pages, not gist)**; current links are gists.
- **§19** — feature graphic (run `store_assets/feature_graphic/prompt.md`); shot 3 (Pandit chat) needs a Gemini-keyed build; content rating; target audience 13+.
- **§20/21/22/23** — pre-launch report, real-device matrix (A13/14/15, low-end, tablet), staged rollout, post-launch alerts.

### Data flags found earlier (open)
- Listing says "35+ texts" but Library shows **32 scriptures** — reconcile.
- Ṛgveda count mismatch: Library card "9,508 mantras" vs chapter-list header "10,552 verses".
