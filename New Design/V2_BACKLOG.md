# V2 Backlog — DO NOT BUILD IN V1

This document lists features that are **explicitly out of scope for v1.** Even if they look easy or obvious from a screen, do not implement them.

If a user requests one of these in feedback after v1 launch, that's a v2 input.

---

## 1. Content & translation

- **Hindi translation layer.** Corpus not yet seeded. v1 ships English only. Settings shows "English" without a chevron (no language picker).
- **Tamil/Telugu/Bengali translations.** v2+.
- **Sanskrit grammatical analysis (anvaya, sandhi-split).** Word-tap shows English meaning + grammar tag in v1. Anvaya parsing is v2+.
- **Multiple commentary sources (Śaṅkara, Rāmānuja, Madhva).** v1 has AI-generated commentary only. Traditional commentaries are v2.

## 2. Audio

- **Verse recitation playback.** No audio files licensed, no playback infrastructure. **Remove the Listen icon from Verse Detail bottom bar in v1.**
- **Background audio with notification controls.** v2.
- **Speed control, loop, A/B repeat.** v2.

## 3. Sharing

- **Share-as-image card.** v1 ships text + deep link only. The Instagram-friendly visual card (with deity colors, decorated borders, etc.) is v2.
- **Custom share templates.** v2.
- **Share to specific platforms (WhatsApp, Telegram, Twitter) with platform-specific formatting.** v2.

## 4. Bookmarks & notes

- **Bookmark cross-device sync.** No backend in v1. The saffron dot indicator on the Bookmark icon stays in the design but never lights up.
- **Bookmark collections / folders / tags.** v1 filter is "Recent / By scripture" only.
- **Multiple notes per verse.** v1 has one note per verse, 200 char limit.
- **Note search.** v2.
- **Export notes as PDF / Markdown.** v1 can export bookmarks (basic). Notes export is v2.

## 5. Search

- **Semantic search via embeddings.** v1 search is text-matching + coordinate detection only. The AI chat is the semantic surface for v1.
- **Search filters (by translator, by year, by scripture family).** Premature filtering. v1 results are grouped by scripture, that's enough.
- **Search history sync.** Local only in v1.

## 6. AI Chat

- **Persisted chat history.** v1 AI chat is per-session. "New conversation" clears it. No long-term storage.
- **Multi-turn conversation summarization on token-limit hit.** v1 soft-limits at 20 turns and shows "Start a new conversation" hint.
- **Voice input.** v2.
- **Voice output (read AI reply aloud).** v2.

## 7. Reading flow

- **Verse history scroll.** Progress rail on Verse Detail is enough for v1.
- **Side-by-side translation comparison.** Single translation in v1.
- **Annotation highlighting (highlight text within a verse).** v2.
- **Reading goals beyond streak.** v1 has streak only. Weekly/monthly goals are v2.

## 8. Practice / curriculum

- **Streak rescue / freeze tokens.** v1 streak breaks on missed day, no mitigation.
- **Streak share.** No social features in v1.
- **Quiz mode after a module.** v1 modules are read-only.
- **Custom paths.** v1 has fixed Foundations → Deepening → Mastery sequence.

## 9. Festivals

- **Push notification for festival day.** v1 has daily verse reminder only.
- **Festival reminders independent of daily reminder.** v2.
- **Add festival to system calendar.** v2.
- **Regional festival customization.** v1 shows all major festivals. Per-region filtering is v2.

## 10. Notifications

- **Verse-of-the-day in notification body.** Local notification character limits + design complexity. v1 notification is plain reminder; user opens app to see verse.
- **Custom reminder times beyond once-daily.** v1 supports one daily reminder.
- **Notification action buttons (read now, snooze).** v2.

## 11. Monetization

- **Pro/paid tier.** No payment integration in v1. App is free with existing AdMob.
- **Remove ads as IAP.** v2.
- **Donation flow.** v2.

## 12. Settings

- **Cloud backup of preferences.** v1 is SharedPreferences only.
- **Onboarding replay from Settings.** v2.
- **Reading reminders by scripture (e.g., "remind me about Gītā specifically").** v2.

## 13. UI extras

- **Multi-language UI (Hindi UI strings).** v1 UI is English only.
- **Custom themes beyond Auto/Light/Dark.** v2.
- **Reading background presets (sepia, manuscript, etc.).** v1 has Light/Dark only.
- **Custom font upload.** v2.

## 14. Social

- **User accounts.** No auth in v1.
- **Following other users.** Never.
- **Verse discussion threads.** Never.
- **Community curation.** Never.

This app is a personal reader, not a social platform.

---

## How to handle v2 requests

When a user asks for a v2 feature in feedback:

1. Receive it gracefully (the feedback flow handles this — Bug / Idea / Text error / Something else)
2. Acknowledge in the response that it's a thoughtful request
3. Add to internal v2 tracker (post-launch)
4. Do not promise a timeline

The right answer to "why doesn't this app have X" is sometimes "because X would make this a different app, and I didn't want to build that one."

---

**End of v2 backlog.** If it's not in this list AND it's not in the v1 build brief, ask Saurabh before building.
