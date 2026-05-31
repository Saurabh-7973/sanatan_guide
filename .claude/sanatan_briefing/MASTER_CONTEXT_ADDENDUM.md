# MASTER CONTEXT ADDENDUM — Navigation deep-dive

Supplementary navigation context. The brief §3 has the canonical route map and entry matrix; this file explains the rationale.

---

## Why 3 tabs, not 5

Most reader apps have Library / Bookmarks / Settings / Profile / Search bottom tabs. We chose **Today · Practice · Texts** because they reflect three distinct user intents:

1. **Today** = "What should I read right now?" (passive consumption)
2. **Practice** = "I want to learn something structured" (active learning)
3. **Texts** = "I want to find a specific thing" (purposeful navigation)

Bookmarks, Search, Settings, Festivals, AI Chat — these are **destinations users go to from somewhere**, not destinations users go to as a default. They live in topbar icons and overflow menus, not bottom tabs.

This decision was deliberate. The bottom tab bar is precious real estate. We don't squander it on features users access infrequently.

---

## Why Bookmarks isn't a tab

Bookmarks aren't a daily destination. A user opens Bookmarks when they:
- Want to revisit a saved verse
- Want to share or unsave something

This is occasional behavior, not landing behavior. Bookmark icon in the topbar (Home + Library) is enough.

The only counterargument is "users will look for it." We solve that by putting the icon in the topbar where users instinctively look for an action button, not a navigation tab.

---

## Why Search isn't a tab

Same reasoning. Users search when they have a specific intent. They don't open the app to "go to Search." The search icon (Home topbar) and the inline search field (Library topbar) handle this.

The inline search field on Library is especially important — it conveys "you can search the texts directly from here without going to a separate Search screen if you know what you want."

---

## Why Settings isn't a tab

Settings is a once-or-twice-a-month destination. Burying it in the overflow ⋯ menu is appropriate. This is standard practice (Twitter, Instagram, every well-designed reader app).

---

## Why Festivals isn't a tab

Festivals is content adjacent to reading, not a primary mode. We surface festivals two ways:
1. **Upcoming Parva card on Home** — primary, visible, contextual
2. **Overflow menu item** — secondary, stable, always reachable

If a user wants to plan around Diwali, they can find Festivals. If they don't, they're not nagged by it.

---

## Why AI Chat (general) isn't a tab

AI Chat is a destination users reach with intent — they have a question. Putting it as a tab would imply "this is a primary way to use the app," which would shift the app from "a reader with AI help" toward "an AI chatbot with scripture access."

We're the former, not the latter. The texts are the product. AI is a tool to help users engage with the texts.

---

## The overflow menu — why these 5 items in this order

```
1. Settings
2. Festivals & Calendar
3. Ask the Pandit
4. Send feedback
5. About this app
```

**Rationale:**
- Settings first — most common destination
- Festivals second — content-y, second most common
- Ask the Pandit third — the AI surface, needs to be reachable but not too prominent
- Send feedback fourth — user-initiated communication
- About this app fifth — credits, attributions, philosophical "what is this"

**Why not more items?** Discoverability tradeoff. Users scan a menu and choose; longer menus get scanned less carefully. Five is the comfortable upper bound.

**Why not separate "Help" or "How to use"?** Because the app should be self-evident. If users need a help guide, the UX has failed.

---

## Drill-down convention

Every screen reached from a tab root is a "drill-down" and follows these rules:

1. **Back button only on the left.** No global Search/Bookmark/⋯ icons.
2. **Context in the center or aligned left.** What you're looking at (scripture name, chapter number, verse number, etc.).
3. **Optional scoped actions on the right.** Bookmark + Share for Verse Detail. Nothing for most others.
4. **No bottom navigation.** Once you've drilled in, you can't switch tabs without going back up.

This last point is deliberate. If a user is reading the Gītā and accidentally taps Practice in the bottom tab bar, they lose their place. The drill-down stack should be a focused tunnel, not a confused intersection.

---

## Modal vs drill-down decision rule

**Use a modal (bottom sheet) when:**
- The action is verse-scoped or selection-scoped (e.g., Notes for this verse, Share this verse)
- Dismissing should return to the exact prior screen state
- The action is short (filling a small form, picking a value)

**Use a drill-down (full screen) when:**
- The destination is its own meaningful surface (Verse Detail, AI Chat, Festivals)
- The user might spend significant time there
- The user might want to navigate further from there

**Examples:**
- Notes → modal (verse-scoped, short)
- Share → modal (verse-scoped, short)
- Time picker → modal (selection, short)
- Reset dialog → modal (confirmation, short)
- Word callout → floating modal (anchored to a word, immediate dismissal)
- AI Chat → drill-down (own surface, long engagement)
- Festival detail → drill-down (own content)
- Module reader → drill-down (long engagement, multi-step)

---

## Back-stack design

The back stack is the user's mental thread. It should never lose them.

**Specific behaviors:**

1. **Tab roots** — back exits the app on first tab, otherwise returns to previous tab (handled by GoRouter).
2. **Verse Detail → AI Chat citation → another Verse Detail** — back returns through this chain in reverse. User can trace their reading thought.
3. **Module reader** — back asks confirmation if user is mid-module (we don't want them to accidentally lose progress). Confirmed back exits to Practice.
4. **Modals** — back dismisses the modal only, never the underlying screen.
5. **Home overflow → Settings → back** — returns to Home, not to the overflow menu (which has already been dismissed).
6. **Deep link arrival** — pushes a single Verse Detail; back goes to Home (synthesized parent).

---

## Why we put the inline search field on Library, not Home

Two reasons:

1. **Library is where users go to find a specific text.** Search is the most natural action there. An inline field signals "you can search right here, you don't have to drill into a separate Search screen."

2. **Home is for passive consumption.** Verse of Day, Continue, Upcoming Parva — Home is curated. A prominent search field on Home would shift the mental model toward "this is a search app," which it isn't.

Search is still reachable from Home (topbar icon), just not as the primary action.

---

## Why the bottom-nav doesn't show on the Module Reader

A module is a focused learning environment. Showing the bottom nav would invite the user to tap away from a module mid-progress, losing context.

The same reasoning applies to:
- Onboarding (focused setup flow)
- AI Chat (focused conversation)
- Verse Detail (focused reading)

The bottom nav appears ONLY on the three tab roots. This is the canonical rule.

---

**End of addendum.** Refer back to the brief §3 for the route map and entry matrix.
