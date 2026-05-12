# Screen Spec — AI Chat (verse-anchored)

> **Build order:** #9 (after Verse Detail 08 — depends on verse routing + the explain-card hand-off)
> **Mockup file:** `New Design/screen-10-ai-chat.html`
> **Routes:** `/browse/:scriptureId/verse/:verseId/chat` (push from Verse Detail's "Explain this verse" card follow-up chips, and from Search's "Ask the Pandit → Ask follow-up"). Optional seed question passed via `GoRouterState.extra` (`{'seed': '<question>'}`). **AI Chat is the only place follow-up conversations happen** (MASTER_CONTEXT §6.4) — every other AI surface routes *into* here.
> **Replaces:** `lib/presentation/features/scripture_reader/pages/verse_chat_page.dart` (673 lines — full rewrite to spec)
> **State management:** Riverpod
> - `verseDetailProvider(verseId)` — `AsyncValue<Either<Failure, Verse>>` (the anchored verse — for the sticky anchor strip)
> - **NEW** `verseChatProvider(verseId)` — `AutoDisposeNotifier`/`AsyncNotifier` holding `ChatSession`: `{ verseId, List<ChatTurn> turns, bool awaitingReply, List<String> openingSuggestions, String? openingProse }`. A `ChatTurn` is either `UserTurn(text)` or `AiTurn(List<AiSegment> segments, bool streaming, bool error)`. An `AiSegment` is `ProseSegment(markdownText)` or `CitationSegment(verseRef)` — so an AI reply can interleave prose and inline citation cards.
> - `GeminiService.ask(...)` (exists) — the LLM call. Wrap a streaming variant (`askStream`) if the SDK supports it; else show the typing indicator until the full reply lands, then animate it in.
> - `GeminiRateLimit.remaining()` / `.consume()` (exists) — quota gate.
> - bookmark / "save explanation" persistence (reuse the `VerseExplanation` DAO from Verse Detail for the reply "Save" action).

---

## Purpose

The user is on a verse, asks a question, gets an answer grounded in the offline corpus. **The verse is the personality of the screen, not the AI.** A persistent saffron-anchored verse strip sits at the top; the conversation below is typeset like commentary, not like a generic chatbot. The AI's superpower is that it cites verses *from the user's actual library* — those citations materialize as small palm-leaf cards inline in the reply, tappable to navigate. No avatars, no AI sparkles, no gradient orbs.

The asymmetry carries the meaning: **user messages** are compact right-aligned sans-serif bubbles ("you're asking"); **AI replies** are flowing left-aligned Lora serif prose ("it's delivering thought") — same register as the Commentary card in Verse Detail.

---

## Layout (top to bottom)

1. **Status bar** (system, 44 px). Screen built behind it: `extendBodyBehindAppBar: true`, transparent `Scaffold`, `WarmBackdrop(intensity: 0.6)`. `resizeToAvoidBottomInset: true` (the input bar rides above the keyboard).
2. **Top bar** (`padding: 6px 20px`, flex, `align-items: center, gap: 12px`):
   - **Back chevron** (left, 36 × 36 hit, 20 px stroke `M12 4l-6 6 6 6`). `context.canPop() ? pop() : go(verseDetail route)`.
   - **Spacer** (`flex: 1`).
   - **Overflow** (right, 36 × 36 hit, three vertical dots `r1.4` filled). Menu: `Clear conversation`, `Copy transcript`. (Keep it tiny — this is not a settings hub.)
   - No title in the top bar — the verse anchor strip below *is* the title.
3. **Verse anchor strip** (`flex-shrink: 0`, NOT scrolling; `margin: 0 20px 6px`, `padding: 10px 14px 10px 18px`, `border-radius: 4px`, `border: 1px solid divider`, `background: linear-gradient(90deg, saffron@5%, saffron@1% 70%, transparent)`, flex `align-items: center, gap: 12px`, `:active { opacity: 0.6 }`):
   - **Leaf-thread:** 3 px saffron rule at `left: 0, top: 8px, bottom: 8px`, `border-radius: 2px`. Dark mode: `box-shadow: 0 0 4px saffron@30%`. (Same vocabulary as the Resume rows on Chapter List / Verse List — use the `LeafThread` heritage primitive.)
   - **Coord** (left, flex-shrink 0) — `Fonts.deva` 13 px line-height 1, `saffron`. Pattern: `‖{deva-ch}·{deva-v}‖` using U+2016 daṇḍa bars + Devanāgarī numerals + a middle-dot. Ex: `‖१·१‖`. For single-unit scriptures: `‖{deva-v}‖`.
   - **Text** (`flex: 1, min-width: 0`):
     - **Devanāgarī incipit** — `Fonts.deva` 13 px line-height 1.3, `cream`/`text-1`, single-line ellipsis. First ~32 chars of `verse.sanskrit`.
     - **English incipit** (1 px gap) — `Fonts.serif italic` 11 px line-height 1.3, `text-2`, single-line ellipsis. First ~36 chars of `verse.translation ?? verse.english`.
   - **Return icon** (right, flex-shrink 0, `text-3, opacity 0.5`) — 14 × 14 arrow-into `M2 7h10M8 3l4 4-4 4`.
   - Tap → pop to (or push) the Verse Detail screen for this verse. The chat is preserved on the back stack (per MASTER_CONTEXT §6.4 — "citation cards navigate to Verse Detail; chat preserved on back stack").
4. **Conversation** (`convo` — `flex: 1, overflow-y: auto`, `padding: 14px 20px`, hidden scrollbar; auto-scrolls to bottom on new turns / streamed tokens):
   - **AI opening** (only when `turns` is empty — first entry, no seed yet) — `margin-bottom: 18px`:
     - **Opening prose** — `Fonts.serif italic` 14.5 px line-height 1.65, `text-1`, `padding: 0 4px`. 1–2 sentences orienting the user to this verse + an invitation ("…Ask anything about this verse."). Source: a short LLM-or-templated blurb tied to the verse (build phase: reuse the cached `VerseExplanation` first sentence if present, else a templated `"{scripture} {coord} — {first wordMeaning gloss}. Ask anything about this verse."`).
     - **Label** (`margin: 18px 0 10px`) — `Fonts.sans` 9 px w600 `letter-spacing 0.28em uppercase` `text-3` — `TRY ASKING`.
     - **Suggestion rows** (each: `padding: 12px 16px, border-radius: 4px, border: 1px solid divider-soft, background: surface, margin-bottom: 8px`, flex `align-items: center, gap: 12px`, `:active { opacity: 0.6 }`):
       - **Text** (`flex: 1`) — `Fonts.serif italic` 13.5 px line-height 1.4, `text-1`. Inline Sanskrit terms render `Fonts.deva` (non-italic), `saffron` — see "Sanskrit term highlighting" below.
       - **Arrow** (flex-shrink 0, `saffron`) — 10 × 10 `M2 5h6M5 2l3 3-3 3`.
       - Verse-specific questions, **not generic chips**. Ex for BG 1.1: `Why is Dhṛtarāṣṭra called blind?` · `What does dharmakṣetra mean?` · `Who is Sañjaya?` · `How does this verse set up the entire Gītā?`. 3–4 of them. Source: from the verse's explanation payload `followups`, else a templated set keyed off `wordMeanings` + coord. Tap → fills the input and sends immediately (becomes a `UserTurn`).
   - **User turn** (`msg-user` — flex `justify-content: flex-end, margin: 14px 0 6px`):
     - **Bubble** — `max-width: 80%, padding: 10px 14px, border-radius: 16px 16px 4px 16px` (the bottom-right corner is the "tail"), `background: saffron-glow, border: 1px solid divider, color: cream`/`text-1`. `Fonts.sans` 14 px line-height 1.45, `letter-spacing -0.005em`.
   - **AI turn** (`msg-ai` — `margin: 14px 0, padding: 0 4px`) — a vertical stack of segments, in order:
     - **Prose segment** — `Fonts.serif` (regular, **not** italic — the *opening* prose is italic, but reply prose is regular), 14.5 px line-height 1.7, `text-1`. Paragraphs `p + p { margin-top: 10px }`. Render Markdown-ish: `**bold**` → w600; paragraph breaks on blank lines. Sanskrit terms inline-highlighted (below).
     - **Citation segment** — an inline palm-leaf card (`margin: 14px 0 4px, padding: 14px 16px 12px, border-radius: 4px, border: 1px solid divider, background: surface, position: relative, overflow: hidden`, `:active { opacity: 0.6 }`):
       - **Top binding line** at `left: 16px, right: 16px, top: 6px, height: 8px` — saffron-faded rule + a small 4 × 4 rotated diamond hole at center. (Use a compact `BindingLine` — same primitive, smaller.)
       - **Coord row** (`margin: 8px 0 6px`, flex `align-items: center, gap: 8px`) — `Fonts.sans` 9 px w600 `letter-spacing 0.24em uppercase` `saffron`: a `.dev` part (`Fonts.deva` 11 px `letter-spacing 0.005em`, `cream`/`text-1`) — `‖१३·१‖` — followed by `{Scripture} · Chapter {N}`.
       - **Sanskrit** — `Fonts.deva` 13.5 px line-height 1.45, `cream`/`text-1`, ≤ 2 lines ellipsis. First clause of the cited verse's `sanskrit`.
       - **English** (1 px gap) — `Fonts.serif italic` 12 px line-height 1.4, `text-2`, ≤ 2 lines ellipsis. Wrap in double-quotes if it's a partial clause (`"This body, O son of Kuntī, …"`).
       - Tap → navigate to that verse's Verse Detail (`/browse/{code}/verse/{ref}`); the chat stays on the back stack. The citation `verseRef` comes from the LLM's structured citation output — **validate it against the local corpus** before rendering; if the ref doesn't resolve to a real verse, drop the citation card and keep the prose only (never render a dead link).
     - **Footer** (`margin-top: 10px, padding-top: 8px, border-top: 1px dashed divider-soft`, flex `gap: 16px`) — only on a *completed* AI turn:
       - Each action: `Fonts.sans` 10.5 px w500 `letter-spacing 0.04em`, `text-3, opacity 0.7`, icon + label, `:active { opacity 1 }`.
       - **Save** (bookmark glyph) — persists this AI reply as the verse's `VerseExplanation` (so it shows in Verse Detail's Commentary card). If one already exists, this overwrites with confirm. After saving, the label reads `Saved`.
       - **Share** (three-circle glyph) — system share sheet: the question + the reply prose (plain text; citations rendered as `— {Scripture} {coord}` lines).
       - **Regenerate** (loop glyph) — re-runs the LLM on the same question (consumes quota); replaces this turn's segments. Hidden while another reply is streaming.
   - **Typing indicator** (`typing` — `margin-top: 8px, padding: 0 4px`, inline-flex `gap: 4px`): three 5 × 5 px saffron dots, 1.4 s pulse, 0.2 s phase offsets. **Use the `AIThinkingDots` heritage primitive** — same vocabulary as Verse Detail's "Explain" loading and Search's Pandit-thinking. Shown as the trailing element of an in-flight AI turn (after any already-streamed prose) or as a standalone bubble if nothing has streamed yet.
5. **Input area** (`flex-shrink: 0`, NOT scrolling; `padding: 10px 16px 16px` + safe-area bottom; `background: bg`, `border-top: 1px solid divider-soft`):
   - **Input shell** (flex `align-items: flex-end, gap: 8px`, `border-radius: 22px, padding: 6px 6px 6px 16px, border: 1px solid divider-soft, min-height: 44px, background: surface`):
     - **Text field** (`flex: 1`, transparent, no border, `Fonts.sans` 14 px line-height 1.4, `padding: 8px 0`): multi-line, auto-grows 1→~4 rows then scrolls. Placeholder: **`Ask about this verse…`** — *not* "Type a message…" / "Ask anything…". The chat is bounded; the placeholder says so. When focused, the shell border goes `saffron` (`.active`).
     - **Send button** (32 × 32 circle, flex-shrink 0): paper-plane glyph `M2 7l10-5-3 12-3-5-4-2z`. **Disabled** (`background: surface-2, color: text-3`, no tap) when the field is empty OR an AI reply is in flight OR quota is exhausted. **Enabled**: `background: saffron, color: #1a1208` (dark) / `#fff` (light), glyph filled. Tap → append `UserTurn`, clear field, set `awaitingReply`, fire `GeminiService.ask`/`askStream`, append a streaming `AiTurn`.
   - **Quota-exhausted state:** when `GeminiRateLimit.remaining() == 0`, replace the input shell with a muted strip — `Fonts.sans` 12 px `text-3`, `The Pandit is resting. Daily question limit reached — resets at midnight.` Send disabled. (Don't hide the conversation; the user can still read and tap citations.)
   - **Offline / error on a turn:** the in-flight `AiTurn` flips to `error` — its prose slot shows `Fonts.serif italic` 14 px `text-2`: `The connection slipped. Tap to retry.` + a small `↻` (saffron). Tap retries that turn. (Network is the *only* place AI Chat reaches out — everything else is offline; if offline, fail gracefully here, don't crash.)

---

## States

| State | What renders |
|---|---|
| **Opening** | Verse anchor + AI opening prose + `TRY ASKING` + 3–4 verse-specific suggestion rows. Input enabled, send disabled (empty). |
| **With citation** | User bubble → AI prose → inline citation leaf-card → more AI prose → footer (Save/Share/Regenerate). |
| **AI thinking** | User bubble → AI turn with whatever prose has streamed + `AIThinkingDots` trailing. Send disabled. |
| **Composing** | Input shell `.active` (saffron border), field has text, send enabled & filled. Keyboard up; conversation scrolled so the last turn is visible above the keyboard. |
| **Quota exhausted** | Conversation read-only; input shell replaced by the "Pandit is resting" strip. |
| **Turn error / offline** | The failed AI turn shows the inline retry affordance; other turns untouched; input still enabled (retry consumes quota only on success). |
| **Loading (verse not yet resolved)** | Verse anchor shows a shimmer for the incipit lines (coord may be known from the route); conversation area shows the opening skeleton (prose shimmer + 3 suggestion-row skeletons). Rare — usually the verse is already cached from Verse Detail. |

---

## Animations

- **Message-in:** every new turn (`msg-user`, `msg-ai`, and the `ai-opening` block) animates `.fadeIn(350.ms).slideY(begin: 0.02, end: 0)` (`Curves.easeOut`).
- **Streaming prose:** tokens append into the current `ProseSegment`; the `AIThinkingDots` stay pinned after the last token until the stream closes, then fade out (`.fadeOut(200.ms)`).
- **Citation card-in:** when a `CitationSegment` arrives mid-stream, it `.fadeIn(300.ms).scaleXY(begin: 0.97, end: 1)`.
- **AIThinkingDots:** the heritage primitive — don't re-implement the pulse.
- **Auto-scroll:** on new turn or streamed chunk, animate the `ScrollController` to the bottom (`200.ms, Curves.easeOut`) — but only if the user is already near the bottom (don't yank them away if they've scrolled up to re-read).
- **Tap feedback:** `splashColor: transparent, highlightColor: saffron@4%` on anchor strip, suggestion rows, citation cards, footer actions.
- **Send button:** color/glyph-fill cross-fades (`150.ms`) on enable/disable.

---

## Heritage primitives used

| Primitive | Purpose |
|---|---|
| `LeafThread` | Verse anchor strip's left edge (and its pulse is **off** here — static, like the Verse List resume row). |
| `BindingLine` | Inline citation card's top edge (compact variant — 8 px tall, 4 px diamond). |
| `AIThinkingDots` | The typing indicator + any in-flight AI turn. |
| `WarmBackdrop` | Page background, `intensity: 0.6`. |
| `arabicToDevanagari(int)` | Coord strings (`‖१·१‖`, `‖१३·१‖`) on the anchor + citations. |
| `DandaCoord` | **Not used** — the `‖N·M‖` coords are plain Devanāgarī text built with U+2016 + `arabicToDevanagari`, same as Verse List daṇḍa marks. |

---

## Do / don't

✅ **Do**
- Anchor the screen to the verse — persistent saffron-leaf-thread strip at the top, tappable to return to Verse Detail, chat preserved on the back stack.
- Typeset AI replies as flowing serif prose; keep user messages as compact right-aligned sans bubbles. The asymmetry *is* the labeling.
- Render verse-specific suggested questions (per verse), not generic chips. Teach users what's worth asking.
- Materialize corpus citations as small palm-leaf cards (binding line + ‖coord‖ + Sanskrit + translation), tappable to navigate. **Validate every citation ref against the local DB** before rendering.
- Highlight Sanskrit terms inline in saffron Devanāgarī wherever the AI uses one in English prose ("*dharmakṣetra* means…" → `dharmakṣetra` in Tiro Devanagari, saffron).
- Use the single `AIThinkingDots` vocabulary for the thinking state — same as Verse Detail and Search.
- Make the input placeholder say `Ask about this verse…` — communicate the bound.
- Gate sends on `GeminiRateLimit`; show the "Pandit is resting" strip when exhausted; keep the conversation readable.
- Accept a seed question via `extra` and send it immediately on entry (skip the opening block when seeded).

❌ **Don't**
- No avatars, no "AI" sparkle icons, no gradient orbs, no model-branding chrome beyond the tiny `AI · GEMINI`-style source label inside replies.
- Don't make AI replies bubbles. Don't make user messages serif. The register asymmetry is deliberate.
- Don't render a citation card whose verse ref doesn't resolve in the offline corpus — drop the card, keep the prose.
- Don't open a *second* chat surface anywhere — Verse Detail's "Explain" and Search's "Ask follow-up" both route here.
- Don't show the reply footer (Save/Share/Regenerate) on an in-flight or errored turn.
- Don't auto-scroll the user away from text they've scrolled up to re-read.
- Don't crash or block when offline — the in-flight turn fails gracefully with an inline retry.
- Don't use a generic "Type a message…" placeholder.
- Don't carry over the old 673-line page wholesale — rewrite to this structure.

---

## Acceptance criteria

1. `verse_chat_page.dart` rewritten ≤ ~450 lines; conversation rendered from `verseChatProvider`'s `ChatSession` (turns + segments), no ad-hoc local lists in the widget.
2. Verse anchor strip: `LeafThread` left edge, `‖ch·v‖` Devanāgarī coord, Devanāgarī + English incipits (ellipsised), return icon; tap pops/pushes Verse Detail without losing the chat on the back stack.
3. Opening state shows the orienting prose + `TRY ASKING` + 3–4 *verse-specific* suggestion rows; tapping a suggestion sends it as a user turn.
4. AI replies render as `Fonts.serif` (regular) left-aligned prose; user messages as right-aligned `Fonts.sans` bubbles with the `16/16/4/16` radius and saffron-glow fill.
5. An AI reply containing a citation renders the inline palm-leaf card (binding line + ‖coord‖ + Sanskrit + translation) between prose segments; tapping it navigates to that verse; an unresolvable ref renders no card (prose still shown).
6. Sanskrit terms in AI English prose render in `Fonts.deva` non-italic saffron (verify at least the `**term**`/backtick/`<term>`-tagged spans from the LLM output get the treatment).
7. Thinking state uses `AIThinkingDots`; it disappears when the stream completes; the footer (Save/Share/Regenerate) appears only after completion.
8. Send disabled when: field empty, reply in flight, or quota exhausted; enabled+filled otherwise. Quota-exhausted shows the "Pandit is resting" strip in place of the input shell.
9. A failed/offline turn shows an inline `Tap to retry` affordance on that turn only; retry re-runs it; other turns untouched.
10. "Save" on a reply persists it as the verse's `VerseExplanation` (visible afterward in Verse Detail's Commentary card); label flips to `Saved`.
11. Entering with `extra: {'seed': '...'}` skips the opening block and immediately posts that as the first user turn + fires the reply.
12. Input bar rides above the keyboard (`resizeToAvoidBottomInset`); conversation auto-scrolls to the latest turn on send/stream unless the user has scrolled up.
13. Analyzer clean. Widget test asserts: (a) opening suggestions render & a tap creates a user turn, (b) AI turn renders prose + citation card in order, (c) send disabled while `awaitingReply`, (d) quota-exhausted strip replaces the input, (e) unresolvable citation ref → no card.
14. Screen built behind `extendBodyBehindAppBar: true` + transparent `Scaffold` + `WarmBackdrop(intensity: 0.6)`.

---

## Open questions for build phase

- **Streaming:** does the current `GeminiService` / SDK expose token streaming? If yes, wire `askStream` → append to the live `ProseSegment`. If no, keep `ask` (full reply) and animate the completed prose in with a brief fake-stream or just the message-in fade — but keep the `AIThinkingDots` visible for the whole wait. Decide at build time.
- **Structured citations:** the LLM must return citations in a parseable form (e.g. a JSON tail, or `[[BG.13.1]]` markers in the prose). Pick the convention in the prompt; the parser splits prose ↔ citation segments. Build phase: define the marker syntax, parse it, validate refs against the corpus DAO.
- **`ChatSession` persistence:** does a chat survive backgrounding / navigating away and back? **Default for build #9:** keep it in an `AutoDispose` provider keyed by `verseId` — survives within the navigation stack, discarded when the route is popped. Persisting transcripts to disk is a later feature.
- **Opening prose / suggestions source:** templated for build #9, keyed off `verse.wordMeanings` + coord + (if present) the cached `VerseExplanation.followups`. A curated per-verse question bank is a content follow-up.
- **Search "Ask the Pandit" hand-off:** Search currently shows a single curated answer with an "Ask follow-up" affordance — confirm it routes here with `extra: {'seed': <the follow-up>}` and the original Pandit answer as the first AI turn (so the conversation has context). Wire when building; coordinate with the Search page.
- **"Save" overwrite:** if a `VerseExplanation` already exists for the verse, confirm before overwriting (small dialog), or append as a second commentary? **Default:** overwrite with a confirm dialog — one canonical AI commentary per verse for v1.
