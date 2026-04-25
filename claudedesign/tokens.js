// Sanatan Guide design tokens — mirrored from app_colors.dart / app_typography.dart / app_spacing.dart.
// Values verbatim. Do not invent new ones.

window.TOKENS = (() => {
  const C = {
    // Brand
    saffron: '#E8820C',
    saffronOnDark: '#F4A830',
    deepRed: '#8B0000',
    gold: '#FFD700',

    // Light surfaces
    cream: '#FDFAF6',
    surface: '#F7F2EC',
    surfaceVariant: '#EDE8E2',

    // Dark surfaces
    bgDark: '#0F0F0F',
    surfaceDark: '#1C1816',
    surfaceElevated: '#221E1B',
    surfaceHighest: '#2A2520',

    // Text
    textPrimary: '#1A1210',
    textSecondary: '#6B6360',
    textHint: '#9E9A97',
    textOnDark: '#F0EBE5',
    textSecondaryOnDark: '#9B9390',

    // Sanskrit
    sanskritText: '#2D1B00',
    sanskritTextOnDark: '#E8D9C0',
    translitText: '#5A3E28',

    // Dividers
    divider: '#E0D9CF',
    border: '#CCC5BB',
    dividerDark: '#2E2A27',
    borderDark: '#3A3531',

    // Saffron ladder
    saffronFaint: 'rgba(232,130,12,0.08)',
    saffronMuted: 'rgba(232,130,12,0.12)',
    saffronLight: 'rgba(232,130,12,0.15)',
    saffronBorder: 'rgba(232,130,12,0.30)',

    // Warm grey
    warmGrey10: '#F2EDE6',
    warmGrey50: '#8A7968',
    warmGrey80: '#3A322B',
  };

  const S = {
    xs: 4, sm: 8, md: 12, lg: 16, xl: 24, xxl: 32, xxxl: 48, huge: 64,
    cardPadding: 16, pagePadding: 24, sectionGap: 32, listItemSpacing: 12,
    radiusRow: 4, radiusChip: 8, radiusCard: 16, radiusHero: 24, radiusSheet: 20,
  };

  // Type styles — converted to CSS
  const T = {
    sanskritLarge: { fontFamily: '"Tiro Devanagari Sanskrit", serif', fontSize: 32, lineHeight: 2.4, letterSpacing: '0.8px' },
    sanskritMedium: { fontFamily: '"Tiro Devanagari Sanskrit", serif', fontSize: 22, lineHeight: 2.0, letterSpacing: '0.3px' },
    sanskritSmall: { fontFamily: '"Tiro Devanagari Sanskrit", serif', fontSize: 18, lineHeight: 2.0, letterSpacing: '0.2px' },
    transliteration: { fontFamily: '"Lora", serif', fontSize: 15, fontStyle: 'italic', lineHeight: 1.6, letterSpacing: '0.3px' },
    hindiLarge: { fontFamily: '"Noto Sans Devanagari", sans-serif', fontSize: 18, lineHeight: 1.6 },
    hindiBody: { fontFamily: '"Noto Sans Devanagari", sans-serif', fontSize: 16, lineHeight: 1.6 },
    displayLarge: { fontFamily: '"Lora", serif', fontSize: 32, fontWeight: 600, lineHeight: 1.3, letterSpacing: '-0.5px' },
    displayMedium: { fontFamily: '"Lora", serif', fontSize: 24, fontWeight: 600, lineHeight: 1.3 },
    titleLarge: { fontFamily: '"Lora", serif', fontSize: 20, fontWeight: 600, lineHeight: 1.35 },
    titleMedium: { fontFamily: '"Lora", serif', fontSize: 17, fontWeight: 600, lineHeight: 1.4 },
    bodyLarge: { fontFamily: '"Lora", serif', fontSize: 18, lineHeight: 1.6 },
    bodyMedium: { fontFamily: '"Lora", serif', fontSize: 16, lineHeight: 1.6 },
    labelLarge: { fontFamily: '"Outfit", sans-serif', fontSize: 16, fontWeight: 600, letterSpacing: '0.1px', lineHeight: 1.3 },
    labelXLarge: { fontFamily: '"Outfit", sans-serif', fontSize: 15, fontWeight: 500, lineHeight: 1.4 },
    labelMedium: { fontFamily: '"Outfit", sans-serif', fontSize: 14, fontWeight: 500, letterSpacing: '0.1px', lineHeight: 1.3 },
    labelSmall: { fontFamily: '"Outfit", sans-serif', fontSize: 12, fontWeight: 500, letterSpacing: '0.1px', lineHeight: 1.3 },
    caption: { fontFamily: '"Outfit", sans-serif', fontSize: 13, lineHeight: 1.3 },
    sectionLabel: { fontFamily: '"Outfit", sans-serif', fontSize: 11, fontWeight: 700, letterSpacing: '1.5px', lineHeight: 1.3, textTransform: 'uppercase' },
    cardLabel: { fontFamily: '"Outfit", sans-serif', fontSize: 12, fontWeight: 600, letterSpacing: '0.5px', lineHeight: 1.3 },
  };

  return { C, S, T };
})();

// Sample verse data — Bhagavad Gita 2.47
window.VERSE_BG_2_47 = {
  scripture: 'Bhagavad Gita',
  chapter: 2,
  verse: 47,
  label: 'Chapter 2 · Verse 47',
  sanskrit: [
    'कर्मण्येवाधिकारस्ते',
    'मा फलेषु कदाचन।',
    'मा कर्मफलहेतुर्भूर्',
    'मा ते सङ्गोऽस्त्वकर्मणि॥२-४७॥',
  ],
  // pādas as half-verse pairs (for caesura)
  pada: [
    ['कर्मण्येवाधिकारस्ते', 'मा फलेषु कदाचन।'],
    ['मा कर्मफलहेतुर्भूर्', 'मा ते सङ्गोऽस्त्वकर्मणि॥'],
  ],
  transliteration: [
    'karmaṇy evādhikāras te',
    'mā phaleṣu kadācana ।',
    'mā karmaphalahetur bhūr',
    'mā te saṅgo \u2019stv akarmaṇi ॥2-47॥',
  ],
  english: 'You have the right to action alone, never to its fruits. Let not the fruits of action be your motive, nor let your attachment be to inaction.',
  hindi: 'कर्म करने में ही तुम्हारा अधिकार है, फल की प्राप्ति में नहीं। तुम कर्मों के फल का हेतु मत बनो, और न तुम्हारी आसक्ति अकर्म में हो।',
  words: [
    { sa: 'कर्मणि', en: 'in action' },
    { sa: 'एव', en: 'alone' },
    { sa: 'अधिकारः', en: 'right' },
    { sa: 'ते', en: 'your' },
    { sa: 'मा', en: 'never' },
    { sa: 'फलेषु', en: 'in fruits' },
    { sa: 'कदाचन', en: 'at any time' },
    { sa: 'मा', en: 'not' },
    { sa: 'कर्मफलहेतुः', en: 'cause-of-fruit' },
    { sa: 'भूः', en: 'be' },
    { sa: 'ते', en: 'your' },
    { sa: 'सङ्गः', en: 'attachment' },
    { sa: 'अस्तु', en: 'let it be' },
    { sa: 'अकर्मणि', en: 'in inaction' },
  ],
};
