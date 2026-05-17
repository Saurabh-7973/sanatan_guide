// lib/core/constants/content_credits.dart
//
// Translation sources and license status for all scriptures in the app.
// Used by CreditsPage to display attribution.

enum ContentLicense { publicDomain, creativeCommons, custom }

/// Library grouping for the credits screen (matches scripture taxonomy).
enum CreditCatalogSection {
  itihasaPurana,
  veda,
  upanishad,
  darshanaYoga,
  stotra,
  dharmashastraNiti,
  tantra,
  tamilClassic,
}

extension CreditCatalogSectionX on CreditCatalogSection {
  /// Short section title (settings-style, no special punctuation).
  String get catalogTitle => switch (this) {
        CreditCatalogSection.itihasaPurana => 'Itihasa & Purana',
        CreditCatalogSection.veda => 'Veda',
        CreditCatalogSection.upanishad => 'Upanishads',
        CreditCatalogSection.darshanaYoga => 'Darshana & Yoga',
        CreditCatalogSection.stotra => 'Stotra',
        CreditCatalogSection.dharmashastraNiti => 'Dharmashastra & Niti',
        CreditCatalogSection.tantra => 'Tantra',
        CreditCatalogSection.tamilClassic => 'Tamil classics',
      };
}

class ScriptureCredit {
  const ScriptureCredit({
    required this.section,
    required this.scriptureId,
    required this.displayName,
    required this.translators,
    required this.source,
    required this.license,
    this.licenseNote,
  });

  final CreditCatalogSection section;
  final String scriptureId;
  final String displayName;
  final List<String> translators;
  final String source;
  final ContentLicense license;
  final String? licenseNote;

  String get licenseLabel {
    switch (license) {
      case ContentLicense.publicDomain:
        return 'Public Domain';
      case ContentLicense.creativeCommons:
        return 'Creative Commons';
      case ContentLicense.custom:
        return 'Custom / Original';
    }
  }
}

const List<ScriptureCredit> contentCredits = [
  // ── Itihasa & Purana ─────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'bhagavad_gita',
    displayName: 'Bhagavad Gita',
    translators: ['Swami Sivananda', 'A.C. Bhaktivedanta Swami Prabhupada'],
    source: 'vedicscriptures.github.io, sacred-texts.com',
    license: ContentLicense.publicDomain,
    licenseNote: 'Multiple public-domain translations compiled.',
  ),
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'mahabharata',
    displayName: 'Mahabharata',
    translators: ['Kisari Mohan Ganguli (1883–1896)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'ramayana',
    displayName: 'Ramayana',
    translators: ['Ralph T.H. Griffith (1870–1874)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'bhagavata_purana',
    displayName: 'Bhagavata Purana',
    translators: ['A.C. Bhaktivedanta Swami Prabhupada'],
    source: 'vedabase.io',
    license: ContentLicense.publicDomain,
    licenseNote: 'Purport text not included. Verse translations only.',
  ),
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'vishnu_purana',
    displayName: 'Vishnu Purana',
    translators: ['Horace Hayman Wilson (1840)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'devi_bhagavata_purana',
    displayName: 'Devi Bhagavata Purana',
    translators: ['Swami Vijnanananda (1921)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.itihasaPurana,
    scriptureId: 'markandeya_purana',
    displayName: 'Markandeya Purana',
    translators: ['Frederick Eden Pargiter (1904)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Veda ─────────────────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.veda,
    scriptureId: 'rigveda',
    displayName: 'Rigveda',
    translators: ['Ralph T.H. Griffith (1896)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.veda,
    scriptureId: 'samaveda',
    displayName: 'Samaveda',
    translators: ['Ralph T.H. Griffith (1895)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
    licenseNote: 'English translation only. Sanskrit text not included.',
  ),
  ScriptureCredit(
    section: CreditCatalogSection.veda,
    scriptureId: 'yajurveda',
    displayName: 'Yajurveda (White / Vajasaneyi)',
    translators: ['Ralph T.H. Griffith (1899)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.veda,
    scriptureId: 'atharvaveda',
    displayName: 'Atharvaveda',
    translators: ['Ralph T.H. Griffith (1895–96)', 'Maurice Bloomfield (1897)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Upanishad ────────────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'isha_upanishad',
    displayName: 'Isha Upanishad',
    translators: ['Max Müller (1879)', 'Swami Paramananda'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'kena_upanishad',
    displayName: 'Kena Upanishad',
    translators: ['Swami Nikhilananda'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'katha_upanishad',
    displayName: 'Katha Upanishad',
    translators: ['Max Müller (1884)', 'Swami Paramananda'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'mundaka_upanishad',
    displayName: 'Mundaka Upanishad',
    translators: ['Max Müller (1884)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'mandukya_upanishad',
    displayName: 'Mandukya Upanishad',
    translators: ['Swami Nikhilananda'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'prashna_upanishad',
    displayName: 'Prashna Upanishad',
    translators: ['Max Müller (1884)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'taittiriya_upanishad',
    displayName: 'Taittiriya Upanishad',
    translators: ['Swami Nikhilananda'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'aitareya_upanishad',
    displayName: 'Aitareya Upanishad',
    translators: ['Max Müller (1879)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'chandogya_upanishad',
    displayName: 'Chandogya Upanishad',
    translators: ['Max Müller (1879)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'brihadaranyaka_upanishad',
    displayName: 'Brihadaranyaka Upanishad',
    translators: ['Max Müller (1884)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'shvetashvatara_upanishad',
    displayName: 'Shvetashvatara Upanishad',
    translators: ['Max Müller (1884)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'kaushitaki_upanishad',
    displayName: 'Kaushitaki Upanishad',
    translators: ['Max Müller (1884)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.upanishad,
    scriptureId: 'maitrayani_upanishad',
    displayName: 'Maitrayani Upanishad',
    translators: ['Max Müller (1884)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Darshana & Yoga ──────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.darshanaYoga,
    scriptureId: 'yoga_sutras',
    displayName: 'Yoga Sutras of Patanjali',
    translators: ['Swami Vivekananda (1896)', 'James Haughton Woods (1914)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.darshanaYoga,
    scriptureId: 'hatha_yoga_pradipika',
    displayName: 'Hatha Yoga Pradipika',
    translators: ['Pancham Sinh (1914)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.darshanaYoga,
    scriptureId: 'brahma_sutras',
    displayName: 'Brahma Sutras',
    translators: ['George Thibaut (1890)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Stotra ───────────────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.stotra,
    scriptureId: 'vishnu_sahasranama',
    displayName: 'Vishnu Sahasranama',
    translators: ['Swami Tapasyananda'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Dharmashastra & Niti ─────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.dharmashastraNiti,
    scriptureId: 'manusmriti',
    displayName: 'Manusmriti',
    translators: ['George Bühler (1886)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
  ScriptureCredit(
    section: CreditCatalogSection.dharmashastraNiti,
    scriptureId: 'arthashastra',
    displayName: 'Arthashastra',
    translators: ['R. Shamasastry (1915)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Tantra ───────────────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.tantra,
    scriptureId: 'mahanirvana_tantra',
    displayName: 'Mahanirvana Tantra',
    translators: ['Arthur Avalon (John Woodroffe) (1913)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),

  // ── Tamil Classic ────────────────────────────────────────────────────────
  ScriptureCredit(
    section: CreditCatalogSection.tamilClassic,
    scriptureId: 'tirukkural',
    displayName: 'Tirukkural',
    translators: ['G.U. Pope, W.H. Drew, John Lazarus, F.W. Ellis (1886)'],
    source: 'sacred-texts.com',
    license: ContentLicense.publicDomain,
  ),
];

/// A non-scripture credit: digitisation sources, libraries, fonts, stack.
/// Rendered in the "Tools used in preparing this app" section of Credits.
class AppToolCredit {
  const AppToolCredit({
    required this.title,
    required this.description,
    required this.meta,
    this.linksOut = false,
  });

  final String title;
  final String description;
  final String meta;

  /// Renders the external-link arrow when true (row points to a public site).
  final bool linksOut;
}

const List<AppToolCredit> appToolCredits = [
  AppToolCredit(
    title: 'GRETIL — Göttingen Register of Electronic Texts in Indian Languages',
    description:
        'Source Sanskrit e-texts for several Vedas, Upaniṣads, the '
        'Bhāgavata Purāṇa and the Yoga Sūtras.',
    meta: 'Universität Göttingen · Public domain',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'sacred-texts.com — Ralph T.H. Griffith & others',
    description:
        'Public-domain English Vedic and epic translations digitised by the '
        'Internet Sacred Text Archive.',
    meta: 'sacred-texts.com · Public domain',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'Project Madurai',
    description:
        'Digitised the Tirukkuṛaḷ and other classical Tamil texts.',
    meta: 'projectmadurai.org · Free electronic texts',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'indic-transliteration',
    description:
        'IAST ↔ Devanāgarī transliteration used throughout the reader.',
    meta: 'Open source · MIT',
    linksOut: true,
  ),
  AppToolCredit(
    title: 'Tiro Devanagari Sanskrit · Lora · Outfit · Noto Sans Devanagari',
    description: 'The four typefaces this app is set in.',
    meta: 'SIL Open Font License 1.1',
  ),
  AppToolCredit(
    title: 'Flutter · Riverpod · Drift',
    description: 'The framework, state layer and local database.',
    meta: 'BSD · MIT · Apache 2.0',
  ),
];
