// Shared verse data + tiny icon primitives for all three design directions.
// Exposed on window so the main HTML can reference them.

const VERSE = {
  id: 'BG.2.47',
  scripture: 'Bhagavad Gita',
  scriptureCode: 'BG',
  label: 'Chapter 2 · Verse 47',
  chapter: 2,
  verseNum: 47,
  sanskrit: 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन ।\nमा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि ॥',
  transliteration: 'karmaṇy-evādhikāras te mā phaleṣu kadācana\nmā karma-phala-hetur bhūr mā te saṅgo ’stv akarmaṇi',
  english: 'You have a right to perform your prescribed duties, but never to the fruits of action. Never consider yourself the cause of the results of your activities, nor be attached to inaction.',
  hindi: 'तुम्हारा अधिकार केवल कर्म करने में है, उसके फलों में कभी नहीं। कर्मफल का हेतु भी तुम मत बनो, और तुम्हारी आसक्ति अकर्म में भी न हो।',
  wordMeanings: [
    { word: 'कर्मणि', meaning: 'in prescribed duties' },
    { word: 'एव', meaning: 'certainly' },
    { word: 'अधिकारः', meaning: 'right' },
    { word: 'ते', meaning: 'of you' },
    { word: 'मा फलेषु', meaning: 'never in the fruits' },
    { word: 'कदाचन', meaning: 'at any time' },
    { word: 'मा', meaning: 'never' },
    { word: 'कर्म-फल', meaning: 'fruits of work' },
    { word: 'हेतुः', meaning: 'cause' },
    { word: 'भूः', meaning: 'become' },
    { word: 'सङ्गः', meaning: 'attachment' },
    { word: 'अकर्मणि', meaning: 'in inaction' },
  ],
  note: 'The instruction I keep returning to: do the work without the transaction.',
  hasAi: true,
  isBookmarked: true,
};

// ── Tiny icon set — Material outline style ───────────────────
const Icon = {
  back: (c = 'currentColor') => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M19 12H6M11 6l-5 6 5 6" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  bookmark: (c = 'currentColor', filled = false) => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill={filled ? c : 'none'}>
      <path d="M6 3h12v18l-6-4-6 4V3z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/>
    </svg>
  ),
  sparkles: (c = 'currentColor') => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M12 3l1.8 4.7L18.5 9.5 13.8 11.3 12 16l-1.8-4.7L5.5 9.5l4.7-1.8L12 3z" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>
      <path d="M19 15l.7 1.8L21.5 17.5l-1.8.7L19 20l-.7-1.8L16.5 17.5l1.8-.7L19 15z" stroke={c} strokeWidth="1.4" strokeLinejoin="round"/>
    </svg>
  ),
  share: (c = 'currentColor') => (
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
      <path d="M12 3v13M12 3l-4 4M12 3l4 4M5 13v6a2 2 0 002 2h10a2 2 0 002-2v-6" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  edit: (c = 'currentColor') => (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
      <path d="M4 20h4L20 8l-4-4L4 16v4z" stroke={c} strokeWidth="1.8" strokeLinejoin="round"/>
      <path d="M14 6l4 4" stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
    </svg>
  ),
  chevL: (c = 'currentColor', s = 24) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M15 6l-6 6 6 6" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  chevR: (c = 'currentColor', s = 24) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M9 6l6 6-6 6" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  chevD: (c = 'currentColor', s = 18) => (
    <svg width={s} height={s} viewBox="0 0 24 24" fill="none">
      <path d="M6 9l6 6 6-6" stroke={c} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  translate: (c = 'currentColor') => (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
      <path d="M3 5h10M8 3v2M8 5c0 4-2 7-4 8M5 9c0 3 3 5 5 6M13 20l4-10 4 10M15 17h4" stroke={c} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  ),
  dot: (c = 'currentColor', s = 4) => (
    <svg width={s} height={s} viewBox="0 0 4 4"><circle cx="2" cy="2" r="2" fill={c}/></svg>
  ),
};

// Ornamental glyph — stylized vegetal flourish, used between sections.
function Ornament({ color = 'currentColor', opacity = 0.5 }) {
  return (
    <svg width="60" height="12" viewBox="0 0 60 12" fill="none" style={{ opacity }}>
      <path d="M2 6h14" stroke={color} strokeWidth="0.8" strokeLinecap="round"/>
      <path d="M44 6h14" stroke={color} strokeWidth="0.8" strokeLinecap="round"/>
      <path d="M30 2c-3 0-5 2-5 4s2 4 5 4 5-2 5-4-2-4-5-4z" stroke={color} strokeWidth="0.9"/>
      <circle cx="30" cy="6" r="1" fill={color}/>
      <path d="M20 6l3 -2M20 6l3 2" stroke={color} strokeWidth="0.8" strokeLinecap="round"/>
      <path d="M40 6l-3 -2M40 6l-3 2" stroke={color} strokeWidth="0.8" strokeLinecap="round"/>
    </svg>
  );
}

// Small diamond/bindu divider
function Bindu({ color = 'currentColor', opacity = 0.4 }) {
  return (
    <svg width="10" height="10" viewBox="0 0 10 10" fill="none" style={{ opacity }}>
      <path d="M5 1l4 4-4 4-4-4 4-4z" stroke={color} strokeWidth="0.8"/>
      <circle cx="5" cy="5" r="1" fill={color}/>
    </svg>
  );
}

Object.assign(window, { VERSE, Icon, Ornament, Bindu });
