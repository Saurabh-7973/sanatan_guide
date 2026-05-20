# AI Chat — General Mode (S6)

> **Status:** built 2026-05-20. The roadmap referenced a `2026-05-17-ai-chat-general.md`
> that was never written; this is it.
> **Source of truth:** `New Design/screen-14-missing-flows.html` § "AI CHAT —
> GENERAL MODE" (the only mockup for general chat — `09_ai_chat_spec.md` is the
> *verse-anchored* chat, a separate, still-pending rewrite).

## Scope

Replace the `/chat` `ComingSoonPage` stub with a working **general-mode**
"Ask the Pandit" chat: no verse anchor, ॐ topbar, empty state with 4
verse-agnostic suggestion chips, message conversation, Gemini-backed replies
gated by the existing daily rate limit. The verse-anchored chat
(`verse_chat_page.dart`) is untouched — its spec-09 rewrite is a separate item.

**Deferred (not in this build):** inline citation leaf-cards. The screen-14
mockup shows them, but `GeminiService.ask` returns a plain `String` with no
structured citation output; spec-09 §160 itself flags citation parsing as an
open build-phase question. AI replies render as plain serif prose. Revisit
when the LLM call returns structured citations.

## Decisions

- **New screen, not a verse_chat_page param.** `verse_chat_page.dart` is the
  old (pre-heritage) verse-anchored page; bolting a no-verse mode onto it
  before its own spec-09 rewrite would entangle two rewrites. New file
  `lib/presentation/features/chat/pages/pandit_chat_page.dart`. "Single chat
  surface" (MASTER_CONTEXT §268) is honoured in spirit — general + verse are
  two *modes* of one Pandit; unify when the verse chat is rewritten.
- **Session state is ephemeral** — held in the `State`, discarded on pop.
  No transcript persistence (matches spec-09 §161 intent).
- **AI prose is italic serif** per the screen-14 mockup (`.msg-ai-prose`).
  Spec-09's verse-anchored chat uses *non-italic* reply prose — deliberate
  divergence, commented in-file so it isn't "fixed" later.
- **Key-gated.** When `GeminiService.isEnabled` is false the input shell is
  replaced by a muted "not available in this build" strip — no fake send.

## Build steps

1. **`pandit_chat_page.dart`** — `ConsumerStatefulWidget` at `/chat`.
   - `extendBodyBehindAppBar`, transparent `Scaffold`, `WarmBackdrop`,
     `resizeToAvoidBottomInset: true`.
   - Topbar Row: `MockupBackChevron` back · centred ॐ + `ASK THE PANDIT` ·
     right slot = empty (no messages) / "+" new-conversation button (clears
     messages → empty state).
   - Empty state: ॐ 60px · "What would you like to ask?" · sub · `TRY ASKING`
     + 4 chips (verbatim from mockup). Chip tap → fill input + send.
   - Conversation: `ListView` — user bubbles (right, sans, `18/18/4/18`,
     saffron-glow) · AI prose (left, italic serif) · `AIThinkingDots` while
     awaiting.
   - Input shell: rounded field (`Ask anything about the texts…`) + paper-
     plane send circle. Disabled when empty / in-flight / quota 0. Quota-0
     and no-key → muted strip instead.
   - Gemini: `GeminiService.ask` with a general (no-verse) system prompt;
     `GeminiRateLimit.remaining()/.consume()` gate; `GeminiException` → inline
     error.
2. **Route:** `/chat` → `PanditChatPage` (was `ComingSoonPage`).
3. **Delete `coming_soon_page.dart`** — `/chat` was its last user.
4. **Search:** `_PanditCta.onPandit` → `context.push('/chat')` (was: focus the
   search field). Completes "reachable from Search".
5. **Widget test** — empty state + 4 chips, chip tap fills input, key-gated
   strip when `isEnabled` false, send-enable rules, both themes.
6. analyze clean · full suite green · commit · finish branch.
