# V2 Backlog — DO NOT BUILD IN V1

Features explicitly out of scope for v1. Even if they seem easy or obvious from a screen, do not implement them.

If a user requests one of these in feedback after v1 launch, that's a v2 input.

---

## Content & translation
- **Hindi translation layer.** No corpus yet. v1 ships English only.
- **Tamil/Telugu/Bengali translations.** v2+.
- **Sanskrit grammatical analysis** (anvaya, sandhi-split). Word-tap shows English + grammar tag in v1. Anvaya parsing is v2+.
- **Multiple commentary sources** (Śaṅkara, Rāmānuja, Madhva). v1 has AI commentary only.

## Audio
- **Verse recitation playback.** **Remove the Listen icon from Verse Detail in v1.**
- **Background audio with notification controls.** v2.

## Sharing
- **Share-as-image card.** v1 = text + deep link only.
- **Custom share templates.** v2.

## Bookmarks & notes
- **Cross-device sync.** No backend in v1. Saffron dot indicator stays in design but never lights up.
- **Bookmark collections/folders/tags.** Filter is "Recent / By scripture" only.
- **Multiple notes per verse.** One note per verse, 200 char limit.
- **Note search.** v2.

## Search
- **Semantic search via embeddings.** v1 = text-matching + coord detection only. AI chat is the semantic surface.
- **Search filters by translator/year/scripture family.** v1 groups by scripture; that's enough.

## AI Chat
- **Persisted chat history.** Per-session only. "New conversation" clears it.
- **Multi-turn summarization on token-limit hit.** Soft-limit at 20 turns, "Start a new conversation" hint.
- **Voice input/output.** v2.

## Reading flow
- **Side-by-side translation comparison.** Single translation in v1.
- **Annotation highlighting** (highlight text within a verse). v2.
- **Reading goals beyond streak.** v1 has streak only.

## Practice / curriculum
- **Streak rescue / freeze tokens.** v1 streak breaks on missed day.
- **Streak share.** No social features in v1.
- **Quiz mode after a module.** v1 modules are read-only.

## Festivals
- **Push notification for festival day.** v1 has daily verse reminder only.
- **Add festival to system calendar.** v2.

## Notifications
- **Verse-of-day in notification body.** v1 = plain reminder.
- **Custom multi-time reminders.** v1 supports one daily reminder.

## Monetization
- **Pro/paid tier.** v1 is free with AdMob.
- **Remove ads as IAP.** v2.

## UI extras
- **Multi-language UI** (Hindi UI strings). v1 = English UI only.
- **Custom themes** beyond Auto/Light/Dark. v2.

## Social
- **User accounts.** No auth in v1.
- **Following / discussion / community curation.** **Never.** This is a personal reader, not a social platform.

---

## How to handle v2 requests

When a user asks for a v2 feature in feedback:
1. Receive gracefully (feedback flow handles this)
2. Acknowledge it's thoughtful
3. Add to internal v2 tracker
4. Don't promise timeline

The right answer to "why doesn't this app have X" is sometimes "because X would make this a different app."

---

**If not in this list AND not in the v1 build brief, ask Saurabh before building.**
