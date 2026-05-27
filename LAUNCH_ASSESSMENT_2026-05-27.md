# Sanatan Guide — Full Launch Assessment (2026-05-27)

## Headline: ~75% to Play Store launch

| Dimension | % | Gap |
|-----------|---|-----|
| Core features complete | 95 | Yajurveda completion · §10 chat redo · §3 word-gloss key gating |
| Visual design fidelity | 72 | §1 loading/error · §6 search polish · §9 time picker/sheet · §10 redo |
| Code quality | 92 | 268 tests, analyzer-clean, strict lints; 0 TODO/FIXME |
| Architecture | 90 | Clean separation (data/domain/presentation/core); feature folders |
| Security | 78 | Need Firebase Rules audit + Gemini key Cloud restriction |
| Performance | 82 | DB on assets = boot decompress; some N+1 provider chains |
| Legal compliance | 45 | Privacy/Terms are bare gists; Data Safety form not started |
| Store readiness | 50 | No screenshots/listing/feature graphic; AdMob account unverified |

**Composite ≈ 75%.** The riskiest gaps are *legal/store* and *AdMob/Gemini key restriction*, not code.

---

## 1. Security

### Status now
| Check | State |
|-------|-------|
| `usesCleartextTraffic="false"` | ✓ AndroidManifest line 17 |
| Minify + R8 shrink + ProGuard rules | ✓ build.gradle.kts release block |
| Signing config wired to `key.properties` | ✓ |
| `allowBackup` flag | ✗ NOT SET → defaults to `true` (data export risk on rooted devices). **Set `android:allowBackup="false"` in manifest.** |
| `networkSecurityConfig` | ✗ Not declared. With `usesCleartextTraffic=false` this is fine but a tighter NSC pinning Gemini + Firebase hosts is best-practice. |
| `print()` usage in lib | 3 occurrences — review (lint already enforces `avoid_print`). |
| `TODO/FIXME/HACK` | 0 in `lib/` — clean |
| Firebase API keys hardcoded in `firebase_options.dart` | ✓ This is *expected* — Firebase keys are public identifiers; security is via Firebase Rules. **VERIFY rules** (next item). |
| Gemini API key | Read via `String.fromEnvironment('GEMINI_API_KEY')`. In release the literal is baked into the APK and *is extractable* by anyone. **Mitigation:** restrict the key in Google Cloud Console (Android-app-only + package name + SHA-1 fingerprint + quota cap). Memory `project_launch_readiness` already flags this. |
| Drift DB file location | `assets/db/sanatan_guide.db.gz` (read-only seed) + per-user writable DB in app dir. Verify mutable DB is not in shared storage. |

### Action items (security)
1. Add `android:allowBackup="false"` + `android:fullBackupContent="@xml/backup_rules"` (empty rules file) to `AndroidManifest <application>`.
2. **Restrict Gemini API key in Google Cloud Console:** Android app restriction, package `com.Saurabh7973.sanatan_guide`, SHA-1 of release keystore, quota: ~1k req/day. Without this any APK extraction can hijack your billing.
3. Audit **Firebase Security Rules** for:
   - Firestore (if any) — should be locked except for app-only writes.
   - Storage — same.
   - Remote Config — readable by anyone with the keys (default), which is fine here.
4. Search for hardcoded credentials beyond Firebase (none found this pass, but rerun before submit).
5. Add a `network_security_config.xml` pinning `*.googleapis.com` + `generativelanguage.googleapis.com` to system trust roots (no MITM via user-installed certs).
6. Verify `.gitignore` excludes `key.properties` + `*.jks` + `local.properties` — these MUST NOT enter git.
7. Crashlytics is currently disabled in debug; verify release sends fatal-only (already does — `recordFlutterFatalError`).

---

## 2. Performance

### Status now
| Check | State |
|-------|-------|
| Impeller rendering | Currently opted-out per manifest meta — Flutter warns this opt-out is deprecated and will be removed. **Re-enable Impeller** (drop the opt-out meta), since Skia path is going away. |
| R8 + resource shrink | ✓ on |
| Tree-shake icons | ✓ (98% reduction observed for MaterialIcons) |
| Heavy isolate work | None obvious. Drift queries run on isolates by default. |
| `compute()` for parsing | Not used; JSON parsing is small (verse-of-day, panchanga) |
| `ListView.builder` for long lists | ✓ used in verse-list, chapter-list |
| `const` constructors | Widespread (sampled) |
| Memory: image caching | google_fonts caches to local FS — verify cache size limit |
| Cold-start time | Splash + DB extraction + Firebase init + Crashlytics + AdService init + AppOpenAdService preload — *measure on real device*. May hit 2-3s. |
| Database boot | `sanatan_guide.db.gz` (14MB) decompresses on first launch to app docs dir. One-time. Verify on slow devices. |
| Provider over-rebuild | `chapterReadCountProvider(scriptureCode, chapterNum, bookNum)` is family-keyed and called per chapter in `_LoadedBody` — N+1 watches. For BG (18 chapters) it's fine, but Mahābhārata (18 parvas → many chapters) could rebuild a lot. Consider a single GROUP-BY query like `scriptureReadCountsProvider`. |
| `withValues(alpha:)` vs deprecated `withOpacity` | Code uses new API ✓ |
| RxStreams / `ChangeNotifier` leaks | Riverpod 3 manages lifecycle |

### Action items (perf)
1. **Remove Impeller opt-out** from `AndroidManifest.xml` so the next Flutter upgrade doesn't break.
2. Profile cold start on a Pixel 5-class device — target <2s to first frame.
3. Convert per-chapter `chapterReadCountProvider` into a single per-scripture `Map<int, int>` provider analogous to `scriptureReadCountsProvider` you already shipped (same GROUP BY pattern). Saves N watches on long-scripture chapter lists.
4. Audit AnimatedSwitcher / `flutter_animate` chains in long lists — these can compound.

---

## 3. App size

| Item | Size | Notes |
|------|------|-------|
| Release APK | **47.7 MB** | universal — split per ABI to reduce |
| Debug APK | 117 MB | irrelevant |
| `assets/` total | 18 MB | dominated by DB |
| `sanatan_guide.db.gz` | 14 MB | bundled gzip; decompressed at runtime |
| Lib code | 159 Dart files | |

### Action items (size)
1. **Build split APKs by ABI**: `flutter build apk --split-per-abi` → ships 3 APKs (~20 MB each) instead of a 47 MB fat APK. Or use **App Bundle (`flutter build appbundle`)** for Play Store — Play serves device-specific APK (~18-22 MB).
2. **Move DB out of the APK** to Firebase Storage / CDN, download on first launch with progress. Drops APK ~14 MB. Trade-off: first-launch network req. Probably *not* worth it for v1.
3. Audit `assets/` — fonts pre-cached vs google_fonts runtime fetch; you have both. Pick one.
4. Drop `google_mobile_ads` (5.3 MB) until you actually enable ads — `ADS_ENABLED=false` doesn't strip the lib. Consider a build-flavor split: free vs ads.
5. `font-asset` warning from §15a fixed last session (cupertino_icons dep added).
6. `flutter build apk --analyze-size` → produces a size-by-package report. Run it.

---

## 4. Code quality + architecture

| Check | State |
|-------|-------|
| Lint config | `flutter_lints` + **40+ explicit rules** + strict-casts + strict-inference + strict-raw-types |
| Analyzer | Clean (0 issues) |
| Test count | 268 passing (units + widgets + integration) |
| TODO/FIXME/HACK | 0 in `lib/` |
| File count | 159 Dart files in `lib/` |
| Folder layout | `lib/{core,data,domain,presentation,l10n}` — clean architecture |
| Feature folders | `presentation/features/{home,bookmarks,scripture_reader,settings,festivals,search,chat,onboarding,learning_path}` — feature-based |
| Repository pattern | `IScriptureRepository` (domain interface) + `ScriptureRepository` (data impl) ✓ |
| Riverpod codegen | Used (`@riverpod` annotations) ✓ |
| Drift codegen | Used ✓ |
| freezed / json_serializable | Used ✓ |

### Action items (quality)
1. Test coverage report: `flutter test --coverage` + open `coverage/lcov.info` — confirm key paths (verse-detail, notification-service, search) hit ≥80%.
2. Run `dart fix --apply` once to pick up any quick wins.
3. Add a CI workflow (`.github/workflows/flutter.yml`) running `analyze + test` on PR. None currently in repo.
4. Replace 3 remaining `print()` calls with `AppLogger` (lint already enforces — those 3 are probably in tests or generated).

### Notable strengths
- Lint config is **stricter than most production Flutter apps**: explicit rules + strict-casts catches a lot.
- Zero TODOs is rare. Indicates discipline.
- 268 tests across all major features.
- Clean separation: domain knows nothing about Riverpod or Drift.

---

## 5. Dependencies — outdated

| Dep | Current | Latest | Risk |
|-----|---------|--------|------|
| `flutter_local_notifications` | 17.2 | 21.0 | **HIGH** — 4 majors behind. Each had breaking changes. Your delivery path depends on this. |
| `google_mobile_ads` | 5.3 | 8.0 | Medium — deprecated API warning already in build log |
| `firebase_*` family | 11/4 | 12/5 | Low — usually compatible |
| `go_router` | 14 | 17 | **Medium** — breaking changes between 14→17 |
| `share_plus` | 10 | 13 | Low |
| `google_fonts` | 6 | 8 | Low |

### Action items (deps)
1. **Plan a deps-bump sprint** *after* v1 ships. Don't churn before launch.
2. If FCM push or fancy notif features ever needed, you must bump `flutter_local_notifications` first.
3. Run `flutter pub outdated --mode=null-safety` periodically.

---

## 6. Legal + Privacy + Compliance

| Item | State |
|------|-------|
| Privacy Policy URL | Bare gist (`gist.github.com/.../96cf...`) |
| Terms of Service URL | Bare gist (`gist.github.com/.../04966...`) |
| Privacy/Terms tone matches app | NO — gists look amateurish |
| Data Safety form (Play Console) | Not started |
| Content rating | Not done — IARC questionnaire pending |
| Target-audience questionnaire | Not done — AI chat is user-generated content |
| Cookie consent / GDPR | Not relevant for Android-only app w/o personal accounts |
| AdMob account verification | Not done (ads gated `false` anyway) |
| In-App-Review prompt timing | Implemented (`review_service.dart`) — verify it follows Play guidelines (no rate-limit violation) |
| AI disclosure | Verse Detail mentions Gemini in tiny copy ("AI-suggested gloss · verify before relying on it"). For Play Data Safety: disclose Gemini sends prompts to Google. |
| AI moderation | None — user could submit anything to Pandit chat. Gemini has its own safety filters, but Play's content rating will ask about UGC + AI. |
| User-content storage | Bookmarks + notes stored locally only (no cloud sync). Verify Play Data Safety reflects "no personal data collected by us." |
| Analytics + Crashlytics | Firebase Analytics + Crashlytics enabled. Disclose to user OR offer opt-out. Currently NO opt-out. |
| Permissions disclosure | Manifest requests: INTERNET, NOTIFICATIONS, BOOT, EXACT_ALARM, VIBRATE, WAKE_LOCK, IGNORE_BATTERY_OPTIMIZATIONS. Each needs justification in Play Listing. |

### Action items (legal)
1. **Rewrite Privacy Policy** as a proper, hosted page (not a gist). Cover: data we store (bookmarks/notes — local only), data we send (Gemini prompts, Analytics events), no personal accounts, no third-party data sale.
2. **Rewrite Terms of Service** matching app tone.
3. Fill Play Console **Data Safety form**. Declarations:
   - Collected: Analytics + Crash logs (Firebase). Linked to user? Probably no.
   - Shared: Gemini prompts → Google.
   - Local-only: Bookmarks, notes, reading history.
4. Complete **IARC content rating questionnaire** — UGC chat is the risk.
5. Add an **AI consent screen** on first launch OR Settings toggle ("Send prompts to Gemini" on/off).
6. Add an **Analytics opt-out** toggle in Settings (set `firebase.analytics.collection_enabled` per user pref).
7. **Pre-prompt for permissions:** Android exact-alarm + battery-opt requests look hostile from native dialogs. Show a tasteful in-app screen first ("To deliver your daily verse on time, we need...") then trigger native dialog.

---

## 7. Store listing (Play Console)

| Asset | State |
|-------|-------|
| App name / title | Set in manifest |
| Short description (≤80 chars) | Not drafted |
| Full description (≤4000 chars) | Not drafted |
| Feature graphic 1024×500 | Missing |
| Phone screenshots (≥2, ≤8) | Missing |
| 7" tablet screenshots | Missing (optional) |
| App icon 512×512 hi-res | Verify `flutter_launcher_icons` output meets 512px |
| Promo video | Optional |
| App category | Choose: "Books & Reference" or "Lifestyle" |
| Content rating | See §6 |
| Pricing | Free + AdMob (gated off in v1) |
| Countries | Choose target — India + worldwide? |
| Contact email | Required |
| Website | Optional but bumps trust |

### Action items (store)
1. Draft listing copy (1 hr).
2. Capture 5–8 phone screenshots in light AND dark mode (Home, Library, Verse Detail, Bookmarks, Settings, Festivals).
3. Generate 1024×500 feature graphic.
4. Verify 512px icon export.

---

## 8. Things you may have missed

1. **App signing key backup** — losing the .jks means you can't push updates. Back up offline + offsite.
2. **Versioning strategy** — currently `versionName/versionCode` driven by `flutter.versionName/versionCode`. Pick semantic versioning (1.0.0 → 1.0.1 patch, 1.1.0 minor).
3. **Internal testing track** — push to Play Console internal track first, get 5-10 testers, then Production.
4. **Bundle ID immutability** — `com.Saurabh7973.sanatan_guide` is your forever identifier. Once published, can't change. Confirm spelling/branding.
5. **CI/CD** — no GitHub Actions workflow yet. Worth adding `analyze + test + build appbundle` on `main` push.
6. **Crashlytics dSYM / mapping** — verify proguard mapping is uploaded automatically by Firebase Gradle plugin (it is, by default).
7. **Deep link verification** — Play has a Digital Asset Links check for `https://` deep links. You only use custom-scheme (`sanatanguide://...`) so probably skip, but verify.
8. **Onboarding language locale** — `flutter_localizations` wired; en + hi ARBs exist. Locale-switching code OK?
9. **Right-to-left** — Sanskrit/Devanagari is LTR but Tamil is also LTR. No RTL exposure. Confirm Hindi UI strings respect the locale.
10. **Accessibility** — TalkBack semantic labels on icon-only buttons (LAUNCH_READINESS flagged this). Run TalkBack pass once.
11. **App Open Ad on splash** — currently disabled by `ADS_ENABLED=false`. Confirm release ships ads-disabled if monetization deferred.
12. **`build` directory** committed? — verify `.gitignore` excludes `/build`, `/.dart_tool`, generated `.freezed.dart` (if intended to be committed, fine).
13. **Database migration strategy** — if scripture data updates, current bundled-gz approach requires APK update. Firebase Remote Config covers festival JSON; same path for verse content? Decide now.
14. **Onboarding skip** — first-launch flow must be skippable. Verify.
15. **Battery + doze test** — leave the app in background for 24h, then check daily notif still fires. Doze can kill alarms silently on Samsung/MIUI.

---

## 9. Recommended sequence to ship

**Week 1 (cheapest, highest impact):**
1. Add `allowBackup=false` (1 min)
2. Restrict Gemini key in GCP Console (15 min)
3. Remove Impeller opt-out from manifest (5 min)
4. Switch to App Bundle (`flutter build appbundle`) — drops user-visible APK ~30% (10 min)
5. Run `--analyze-size` and document (10 min)
6. Verify Firebase Security Rules (20 min)
7. Backup release keystore offsite (5 min)

**Week 2 (legal + store):**
8. Rewrite Privacy + Terms as hosted pages (3 hr)
9. Capture screenshots both themes (2 hr)
10. Draft Play listing copy + feature graphic (3 hr)
11. Fill Data Safety + IARC content rating (1 hr)
12. Add Analytics opt-out + AI consent screen (3 hr)

**Week 3 (polish + ship):**
13. Address remaining audit doc items (§6 search, §9 settings sheets, §10 chat redo selectively)
14. Internal testing track upload (1 hr)
15. Sit on it for 3 days, run on real devices
16. Promote to Production

**Total: ~3 weeks of focused work to launch.**
