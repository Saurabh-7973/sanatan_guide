# Awesome Resources for Sanatan Guide

> A curated collection of "awesome" lists and high-quality resource repositories,
> evaluated for relevance to the Sanatan Guide project.
>
> **Legend:**
> - **INTEGRATE** — Directly useful; reference regularly during development
> - **REFERENCE** — Useful for specific tasks or future phases
> - **SKIP** — Not relevant enough to our stack or scope

---

## 1. Flutter & Dart (Core Stack)

| # | Resource | Stars | Verdict | Why |
|---|----------|-------|---------|-----|
| 1 | [awesome-flutter](https://github.com/solido/awesome-flutter) | 54k+ | **INTEGRATE** | The single best meta-resource for Flutter. Covers libraries, architecture patterns, tutorials, UI kits, state management, and open-source apps. Bookmark this permanently. |
| 2 | [Flutter Gems](https://fluttergems.dev/) | — | **INTEGRATE** | Visual, categorized directory of Dart/Flutter packages. Better than raw pub.dev browsing for discovery. Use when evaluating new packages. |
| 3 | [awesome-open-source-flutter-apps](https://github.com/fluttergems/awesome-open-source-flutter-apps) | 4k+ | **INTEGRATE** | 750+ open-source Flutter apps. Study similar apps (religious/educational/reader apps) for architecture and UX patterns. |
| 4 | [Awesome-Flutter-Packages](https://github.com/Hamed233/Awesome-Flutter-Packages) | 1k+ | **INTEGRATE** | Categorized by functionality — has sections for Architecture, Testing, Animations, and State Management that map directly to our needs. |
| 5 | [awesome-flutter (nepaul)](https://github.com/nepaul/awesome-flutter) | 2k+ | **REFERENCE** | Alternative Flutter list with different curation. Good second opinion when the main list doesn't cover something. |
| 6 | [Flutter Gallery](https://gallery.flutter.dev/) | — | **REFERENCE** | Official widget showcase. Useful when implementing Material 3 components to see correct patterns. |

---

## 2. UI/UX Design

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 7 | [Awesome-Design-Resources-List](https://github.com/darelova/Awesome-Design-Resources-List) | **INTEGRATE** | The list you saw on Instagram (or similar). Covers inspiration (Dribbble, Behance), UI kits, AI design tools, Figma resources. Essential for our design phase. |
| 8 | [Mobbin](https://mobbin.com/) | **INTEGRATE** | Real-world mobile app screenshots searchable by pattern. Search "reading app", "religious app", "meditation app" for direct inspiration for our screens. |
| 9 | [Checklist Design](https://www.checklist.design/) | **INTEGRATE** | UI component checklists (onboarding, settings, search, etc.). Use as a QA checklist for every screen we build. |
| 10 | [Laws of UX](https://lawsofux.com/) | **INTEGRATE** | Psychological principles for interface design. Short, actionable. Especially relevant: Hick's Law (scripture navigation), Miller's Law (chapter grouping), Jakob's Law (familiar patterns). |
| 11 | [awesome-material](https://github.com/sachin1092/awesome-material) | **REFERENCE** | Material Design libraries across frameworks. We're using Material 3 in Flutter so less directly needed, but good for icon/color/animation resources. |
| 12 | [awesome-ui](https://github.com/Edovalm/awesome-ui) | **REFERENCE** | General UI principles and design systems. Useful background reading. |
| 13 | [Muzli](https://muz.li/) | **REFERENCE** | Daily design inspiration feed. Install the Chrome extension for passive inspiration. |
| 14 | [Awesome-Resources (re50urces)](https://github.com/re50urces/Awesome-Resources) | **REFERENCE** | Broad design resources including Apple/Google/Microsoft design guidelines. |

---

## 3. State Management (Riverpod)

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 15 | [Riverpod Official Docs](https://riverpod.dev) | **INTEGRATE** | Primary reference. We're using Riverpod with code generation — the docs cover every provider type, testing, and architecture. |
| 16 | [Flutter Riverpod 2.0 Ultimate Guide (Code With Andrea)](https://codewithandrea.com/articles/flutter-state-management-riverpod/) | **INTEGRATE** | The most comprehensive Riverpod tutorial. Covers real-world patterns: dependency overrides for testing, provider scoping, and app architecture with Riverpod. |
| 17 | [Riverpod Examples (Official Repo)](https://github.com/rrousselGit/riverpod/tree/master/examples) | **REFERENCE** | Official example apps. Good for verifying correct usage patterns. |

---

## 4. Backend — Firebase

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 18 | [awesome-firebase](https://github.com/jthegedus/awesome-firebase) | **INTEGRATE** | Comprehensive list: docs, tools, articles for all Firebase services. We use Analytics, Crashlytics, and Remote Config — all covered here. |
| 19 | [FlutterFire (Official Plugins)](https://github.com/firebase/flutterfire) | **INTEGRATE** | The official Flutter+Firebase integration. We already use this but the repo has migration guides, examples, and troubleshooting that we should reference. |
| 20 | [afonsopacifer/awesome-firebase](https://github.com/afonsopacifer/awesome-firebase) | **REFERENCE** | Alternative Firebase list. Has SDK-level documentation links and boilerplate starters. |

---

## 5. Backend — Supabase (Future / Alternative)

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 21 | [awesome-supabase (Official)](https://github.com/lyqht/awesome-supabase) | **REFERENCE** | Official awesome list: starters, DX tools, community tools. Relevant if we migrate to or add Supabase for auth/storage. |
| 22 | [supabase-community/sql-examples](https://github.com/supabase-community/sql-examples) | **REFERENCE** | Useful SQL scripts. Relevant if we use Supabase Postgres for server-side data. |

---

## 6. Offline-First & SQLite (Critical — Our Core Pattern)

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 23 | [awesome-local-first](https://github.com/alexanderop/awesome-local-first) | **INTEGRATE** | Comprehensive local-first/offline-first resources. Covers sync engines, CRDTs, and architectural patterns. Directly relevant since our app ships a bundled SQLite DB and works offline. |
| 24 | [awesome-sqlite](https://github.com/Airsequel/awesome-sqlite) | **INTEGRATE** | SQLite tools, extensions, and production patterns. We use Drift/SQLite heavily — this list has performance tips, FTS resources, and tools we should know about. |
| 25 | [Flutter Offline-First Docs](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) | **INTEGRATE** | Official Flutter guidance on offline-first. Repository pattern with stream-based sync — matches our architecture. |
| 26 | [offline-first](https://github.com/arn4v/offline-first) | **REFERENCE** | Projects in the offline-first sync space. More relevant if we add cloud sync later. |

---

## 7. Localization & Indian Languages (Critical — Sanskrit/Hindi/IAST)

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 27 | [awesome-i18n](https://github.com/oh-jon-paul/awesome-i18n) | **INTEGRATE** | Comprehensive i18n/l10n resources. We need this for Hindi, Sanskrit, and potentially 12+ Indian language store listings. Covers tools, libraries, and translation management. |
| 28 | [India Localization Standards (BIS)](https://egovstandards.gov.in/sites/default/files/2023-05/Localization%20and%20Language%20Technology%20Standards.pdf) | **INTEGRATE** | Government standards for Indian language support. Covers INSCRIPT keyboards, Unicode compliance, and Indic font requirements. We already use Tiro Devanagari and Noto Sans Devanagari — this validates our approach. |
| 29 | [How to Localize Your App for India (AppTweak)](https://www.apptweak.com/en/aso-blog/how-to-localize-your-app-in-india) | **INTEGRATE** | Practical guide for India market. Key insight: mix English + transliterated Hindi in store listing. Covers regional language prioritization. |
| 30 | [awesome-i18n (mrhota)](https://github.com/mrhota/awesome-i18n) | **REFERENCE** | Alternative i18n list. Has Unicode/ICU references useful for script handling. |

---

## 8. App Store Optimization (ASO) & Launch

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 31 | [Awesome-ASO](https://github.com/rafaecheve/Awesome-ASO) | **INTEGRATE** | Dedicated ASO resources and tools. We're prepping for Play Store launch — keyword research, screenshot optimization, and metadata strategy are all covered. |
| 32 | [Appfigures ASO Checklist](https://appfigures.com/resources/guides/app-store-optimization-checklist) | **INTEGRATE** | Step-by-step ASO checklist. Use this before our Play Store submission as a final review. |
| 33 | [ASO in 2026 Guide (ASOMobile)](https://asomobile.net/en/blog/aso-in-2026-the-complete-guide-to-app-optimization/) | **INTEGRATE** | Updated 2026 strategies: Custom Product Pages, AI impact on store discovery, retention-based ranking. Very current and relevant. |

---

## 9. Testing & Quality

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 34 | [awesome-testing](https://github.com/TheJambo/awesome-testing) | **REFERENCE** | General testing resources, books, blogs. Good for learning testing strategy but not Flutter-specific. |
| 35 | [awesome-testing (awesomelistsio)](https://github.com/awesomelistsio/awesome-testing) | **REFERENCE** | Testing frameworks and tools across all levels (unit, integration, E2E). |
| 36 | [Awesome-Flutter-Packages (Testing Section)](https://github.com/Hamed233/Awesome-Flutter-Packages#testing) | **INTEGRATE** | Flutter-specific testing tools: `flutter_test`, `mocktail` (we already use this), `golden_toolkit` for screenshot testing. |

---

## 10. Accessibility

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 37 | [awesome-a11y](https://github.com/brunopulis/awesome-a11y) | **INTEGRATE** | Comprehensive accessibility resources. Our app serves a wide demographic including elderly users reading scriptures — accessibility is not optional. Covers screen readers, contrast, font sizing. |
| 38 | [awesome-accessibility](https://github.com/lukeslp/awesome-accessibility) | **REFERENCE** | Focused on inclusive design principles and testing tools. |

---

## 11. Privacy, Security & Compliance

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 39 | [awesome-privacy-engineering](https://github.com/mplspunk/awesome-privacy-engineering) | **INTEGRATE** | Privacy engineering resources. We need a privacy policy, Play Store Data Safety declaration, and proper data handling. Covers GDPR/data mapping/threat modeling. |
| 40 | [OWASP MASVS - Privacy](https://mas.owasp.org/MASVS/12-MASVS-PRIVACY/) | **INTEGRATE** | Industry-standard mobile app security and privacy requirements. Use as a checklist before launch. |
| 41 | [awesome-privacy](https://github.com/pluja/awesome-privacy) | **SKIP** | Focused on privacy-respecting alternatives to common apps. Not directly useful for building our app. |

---

## 12. Analytics & Performance

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 42 | [awesome-analytics](https://github.com/oxnr/awesome-analytics) | **REFERENCE** | Curated analytics platforms. We're already committed to Firebase Analytics, but useful if we want to evaluate alternatives or add product analytics (Mixpanel, Amplitude). |
| 43 | [FlutterFire Crashlytics Usage](https://firebase.flutter.dev/docs/crashlytics/usage) | **INTEGRATE** | Official docs for our crash reporting setup. Covers non-fatal errors, custom keys, and test crashes. |

---

## 13. Architecture & Patterns

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 44 | [Flutter Architecture Guide (Official)](https://docs.flutter.dev/app-architecture) | **INTEGRATE** | Official Flutter architecture recommendations. Our app follows clean architecture (domain/data/presentation layers) — this validates and extends our approach. |
| 45 | [Awesome-Flutter-Packages (Architecture Section)](https://github.com/Hamed233/Awesome-Flutter-Packages#architecture--design-patterns) | **INTEGRATE** | Packages for clean architecture, DI, and design patterns. Includes `get_it`, `injectable`, `stacked`. |
| 46 | [Roadmap.sh/flutter](https://roadmap.sh/flutter) | **REFERENCE** | Structured Flutter learning path. Useful for onboarding if we bring on contributors. |

---

## 14. The Meta-List

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 47 | [sindresorhus/awesome](https://github.com/sindresorhus/awesome) | **REFERENCE** | The original "awesome" list of awesome lists. 300k+ stars. If you ever need to find an awesome-X for anything, start here. |
| 48 | [project-awesome.org](https://project-awesome.org/) | **REFERENCE** | Searchable web interface for all awesome lists. |

---

## 15. AI Development Workflow & Tooling

| # | Resource | Verdict | Why |
|---|----------|---------|-----|
| 49 | [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | **INTEGRATE** | Curated skills, hooks, slash-commands, and plugins for Claude-powered coding. We use Cursor (runs Claude) — this list has workflow improvements, MCP servers, and orchestration patterns we can adopt. |
| 50 | [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) | **INTEGRATE** | Reusable procedural skills for Claude. Includes the `superpowers` library and community skill packs. Browse for Flutter/mobile-relevant skills. |
| 51 | [UI/UX Pro Max Skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | **INTEGRATE** | AI skill providing design intelligence: 50+ styles, 161 palettes, 57 font pairings, 99 UX guidelines, Flutter-specific guidance, WCAG checks. Install via `uipro init`. Replaces/upgrades our basic ui-review skill. |
| 52 | [claude-mem](https://github.com/thedotmack/claude-mem) | **REFERENCE** | Persistent memory plugin for Claude Code CLI — captures session context in local SQLite, injects into future sessions. NOT compatible with Cursor directly. Our CLAUDE.md + planning docs serve a similar purpose. Revisit if we switch to Claude Code CLI. |
| 53 | [n8n MCP Server](https://docs.n8n.io/advanced-ai/accessing-n8n-mcp-server/) | **REFERENCE** | Open-source automation platform with native MCP support. AI agents can trigger workflows (auto-post daily verses, monitor reviews, run flutter analyze on schedule). Requires hosting. Useful post-launch for Phase 2+ automation. |
| 54 | [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) | **REFERENCE** | Master list of MCP servers. Browse for: Supabase MCP, Firebase MCP, SQLite MCP, GitHub MCP — any of which could extend our Cursor capabilities. |
| 55 | [Claude Code Tips (40+)](https://github.com/ykdojo/claude-code-tips) | **REFERENCE** | Practical tips for Claude-powered development: status line scripts, conversation cloning, containerized workflows. |

---

## Summary: What to Integrate Now vs Later

### Use Now (V1 / Play Store Launch)
1. **awesome-flutter** — package discovery, architecture patterns
2. **Awesome-Design-Resources-List** + **Mobbin** + **Laws of UX** — UI/UX design phase
3. **Checklist Design** — screen-by-screen QA
4. **awesome-firebase** + **FlutterFire** — our backend stack
5. **awesome-local-first** + **awesome-sqlite** — our offline-first core
6. **awesome-i18n** + **India Localization Standards** — Sanskrit/Hindi/IAST support
7. **Awesome-ASO** + **ASO 2026 Guide** — Play Store launch prep
8. **awesome-a11y** — accessibility compliance
9. **awesome-privacy-engineering** + **OWASP MASVS** — privacy policy & data safety
10. **Riverpod docs** + **Code With Andrea guide** — state management patterns
11. **UI/UX Pro Max Skill** — install for design-intelligent code generation during UI work
12. **awesome-claude-code** + **awesome-claude-skills** — improve our AI-assisted dev workflow

### Use Later (Post-Launch / Growth Phases)
- **awesome-supabase** — if we add Supabase
- **awesome-analytics** — if we evaluate analytics alternatives
- **awesome-testing (general)** — for scaling test coverage
- **Roadmap.sh/flutter** — for onboarding contributors
- **n8n MCP** — post-launch automation (daily verse posts, review monitoring, CI alerts)
- **claude-mem** — if we switch from Cursor to Claude Code CLI
- **awesome-mcp-servers** — browse for Firebase/SQLite/GitHub MCP integrations

---

*Last updated: April 14, 2026*
