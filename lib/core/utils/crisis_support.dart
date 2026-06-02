// lib/core/utils/crisis_support.dart
//
// Narrow self-harm interception for the AI chat input. Play's AI policy
// requires the app not give self-harm guidance; we intercept BEFORE the
// prompt reaches Gemini and respond with a supportive message instead.
//
// DESIGN — precision over recall, by deliberate choice:
//   * Match ONLY first-person self-harm intent ("I want to die", "kill
//     myself"). Never topical tokens — this app's core content is the
//     Bhagavad Gītā (Arjuna refusing to kill his kin on a battlefield),
//     the Mahābhārata (a war), and Upaniṣads (preoccupied with death). A
//     keyword filter on "kill"/"death"/"suicide"/"war" would gate the
//     scripture itself. We accept missing paraphrases; we never accept
//     blocking "why won't Arjuna fight?".
//   * The crisis RESOURCE (a real helpline number/region) is intentionally
//     NOT hardcoded here — a wrong or defunct number is active harm and is
//     a product decision. [crisisSupportMessage] ships a conservative
//     generic fallback. Wire a verified resource in when one is supplied.

/// First-person self-harm intent patterns. Each requires a self-referential
/// marker (myself/me/my life/my own) or an unambiguous intent phrase, so
/// scriptural questions about death, war, or killing don't trip it.
final List<RegExp> _selfHarmPatterns = [
  RegExp(r'\b(kill|killing|hurt|hurting|harm|harming)\s+(myself|me)\b'),
  RegExp(r'\bend(ing)?\s+(my|this)\s+life\b'),
  RegExp(r'\b(want|wanna|going|trying)\s+to\s+die\b'),
  RegExp(r'\bwant\s+to\s+end\s+(it|my\s+life|everything)\b'),
  RegExp(r"\b(don'?t|do\s+not|no\s+longer)\s+want\s+to\s+(live|be\s+alive)\b"),
  RegExp(r'\bno\s+(reason|point)\s+(to|in)\s+(live|living|life)\b'),
  RegExp(r"\bi\s+can'?t\s+(go\s+on|do\s+this\s+anymore|take\s+it\s+anymore)\b"),
  RegExp(r'\bcommit(ting)?\s+suicide\b'),
  RegExp(r'\b(thinking|think)\s+about\s+(suicide|killing\s+myself|ending\s+it)\b'),
  RegExp(r'\bself[\s-]?harm(ing)?\b'),
];

/// True when [text] expresses first-person self-harm intent and the AI call
/// should be intercepted. Case-insensitive; trims and normalises whitespace.
bool isSelfHarmIntent(String text) {
  final t = text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.isEmpty) return false;
  return _selfHarmPatterns.any((re) => re.hasMatch(t));
}

/// Supportive message shown in place of an AI reply when [isSelfHarmIntent]
/// fires. No Gemini call is made and no rate-limit budget is spent.
///
/// Deliberately resource-generic: ship a verified region-specific helpline
/// only once one is confirmed (see file header). Until then this points to
/// the universally-correct action.
const String crisisSupportMessage =
    'It sounds like you may be going through something very painful, and '
    'I want you to be safe. I can’t help with this the way you deserve — '
    'please reach out right now to someone who can: contact your local '
    'emergency services, or a crisis / suicide helpline in your country. '
    'If someone is with you, let them know how you’re feeling. You matter, '
    'and you don’t have to carry this alone.';
