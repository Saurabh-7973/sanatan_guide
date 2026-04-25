/// Metadata for a single Bhagavad Gita chapter.
/// Hardcoded — these never change and require no DB query.
final class BgChapter {
  final int number;
  final String sanskritName; // Devanagari
  final String transliteration; // IAST Roman
  final String englishName; // Common English name
  final String theme; // One-line description of the chapter's core teaching
  final int verseCount;

  const BgChapter({
    required this.number,
    required this.sanskritName,
    required this.transliteration,
    required this.englishName,
    required this.theme,
    required this.verseCount,
  });
}

/// All 18 chapters of the Bhagavad Gita.
/// verseCount matches the seeded DB (some recensions count 700, some 701 —
/// chapter 13 has 35 verses in our dataset).
abstract final class BhagavadGitaChapters {
  static const List<BgChapter> all = [
    BgChapter(
      number: 1,
      sanskritName: 'अर्जुनविषादयोग',
      transliteration: 'Arjuna Viṣāda Yoga',
      englishName: 'The Yoga of Arjuna\'s Grief',
      theme:
          'Arjuna sees his kinsmen on the battlefield and is overcome with grief and despair.',
      verseCount: 47,
    ),
    BgChapter(
      number: 2,
      sanskritName: 'सांख्ययोग',
      transliteration: 'Sāṅkhya Yoga',
      englishName: 'The Yoga of Knowledge',
      theme:
          'Krishna begins his teaching — the immortal soul, duty, and the nature of action.',
      verseCount: 72,
    ),
    BgChapter(
      number: 3,
      sanskritName: 'कर्मयोग',
      transliteration: 'Karma Yoga',
      englishName: 'The Yoga of Action',
      theme:
          'Action without attachment — why one must act and how to act rightly.',
      verseCount: 43,
    ),
    BgChapter(
      number: 4,
      sanskritName: 'ज्ञानकर्मसंन्यासयोग',
      transliteration: 'Jñāna Karma Sannyāsa Yoga',
      englishName: 'The Yoga of Knowledge and Renunciation',
      theme:
          'The eternal cycle of divine incarnation and the fire of knowledge that burns all karma.',
      verseCount: 42,
    ),
    BgChapter(
      number: 5,
      sanskritName: 'कर्मसंन्यासयोग',
      transliteration: 'Karma Sannyāsa Yoga',
      englishName: 'The Yoga of Renunciation',
      theme:
          'Renunciation and selfless action are both paths — the wise see them as one.',
      verseCount: 29,
    ),
    BgChapter(
      number: 6,
      sanskritName: 'आत्मसंयमयोग',
      transliteration: 'Ātma Saṁyama Yoga',
      englishName: 'The Yoga of Self-Mastery',
      theme: 'Meditation, discipline of the mind, and the practice of yoga.',
      verseCount: 47,
    ),
    BgChapter(
      number: 7,
      sanskritName: 'ज्ञानविज्ञानयोग',
      transliteration: 'Jñāna Vijñāna Yoga',
      englishName: 'The Yoga of Knowledge and Wisdom',
      theme:
          'Krishna reveals his divine nature — the manifest and unmanifest aspects of the Supreme.',
      verseCount: 30,
    ),
    BgChapter(
      number: 8,
      sanskritName: 'अक्षरब्रह्मयोग',
      transliteration: 'Akṣara Brahma Yoga',
      englishName: 'The Yoga of the Imperishable Brahman',
      theme:
          'The nature of Brahman, the cosmic cycle, and what one thinks of at the moment of death.',
      verseCount: 28,
    ),
    BgChapter(
      number: 9,
      sanskritName: 'राजविद्याराजगुह्ययोग',
      transliteration: 'Rāja Vidyā Rāja Guhya Yoga',
      englishName: 'The Yoga of Royal Knowledge',
      theme:
          'The most secret knowledge — devotion, worship, and the all-pervading divine.',
      verseCount: 34,
    ),
    BgChapter(
      number: 10,
      sanskritName: 'विभूतियोग',
      transliteration: 'Vibhūti Yoga',
      englishName: 'The Yoga of Divine Glories',
      theme:
          'Krishna describes his infinite manifestations — wherever excellence exists, he is there.',
      verseCount: 42,
    ),
    BgChapter(
      number: 11,
      sanskritName: 'विश्वरूपदर्शनयोग',
      transliteration: 'Viśvarūpa Darśana Yoga',
      englishName: 'The Vision of the Cosmic Form',
      theme:
          'Arjuna is granted divine sight and witnesses the infinite cosmic form of Krishna.',
      verseCount: 55,
    ),
    BgChapter(
      number: 12,
      sanskritName: 'भक्तियोग',
      transliteration: 'Bhakti Yoga',
      englishName: 'The Yoga of Devotion',
      theme:
          'The path of loving devotion — qualities of the devotee most dear to Krishna.',
      verseCount: 20,
    ),
    BgChapter(
      number: 13,
      sanskritName: 'क्षेत्रक्षेत्रज्ञविभागयोग',
      transliteration: 'Kṣetra Kṣetrajña Vibhāga Yoga',
      englishName: 'The Field and the Knower',
      theme:
          'The distinction between the body (field), the soul (knower), and ultimate reality.',
      verseCount: 35,
    ),
    BgChapter(
      number: 14,
      sanskritName: 'गुणत्रयविभागयोग',
      transliteration: 'Guṇatraya Vibhāga Yoga',
      englishName: 'The Three Qualities of Nature',
      theme:
          'The three guṇas — tamas, rajas, sattva — and how they bind the soul.',
      verseCount: 27,
    ),
    BgChapter(
      number: 15,
      sanskritName: 'पुरुषोत्तमयोग',
      transliteration: 'Puruṣottama Yoga',
      englishName: 'The Supreme Person',
      theme:
          'The cosmic tree, the two kinds of beings, and Krishna as Puruṣottama — beyond both.',
      verseCount: 20,
    ),
    BgChapter(
      number: 16,
      sanskritName: 'दैवासुरसम्पद्विभागयोग',
      transliteration: 'Daivāsura Sampad Vibhāga Yoga',
      englishName: 'The Divine and Demonic Natures',
      theme:
          'Two types of human nature — divine qualities that lead to liberation, demonic to bondage.',
      verseCount: 24,
    ),
    BgChapter(
      number: 17,
      sanskritName: 'श्रद्धात्रयविभागयोग',
      transliteration: 'Śraddhātraya Vibhāga Yoga',
      englishName: 'The Threefold Faith',
      theme:
          'How the three guṇas shape faith, food, sacrifice, austerity, and charity.',
      verseCount: 28,
    ),
    BgChapter(
      number: 18,
      sanskritName: 'मोक्षसंन्यासयोग',
      transliteration: 'Mokṣa Sannyāsa Yoga',
      englishName: 'Liberation through Renunciation',
      theme:
          'The final synthesis — renunciation, duty, devotion, and the supreme secret of all secrets.',
      verseCount: 78,
    ),
  ];

  /// Returns a chapter by number (1-indexed). Throws if out of range.
  static BgChapter byNumber(int number) {
    assert(number >= 1 && number <= 18, 'Chapter number must be 1–18');
    return all[number - 1];
  }
}
