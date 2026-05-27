/// Per-scripture chapter metadata used by the canonical Chapter List
/// layout. Anything not listed here falls back to [chapterOutlinesProvider]
/// (DB-driven outlines), which carries chapterNum + bookNum + chapterLabel
/// only — no Sanskrit title, no description.
///
/// Keep this file presentation-data only. Domain layer should not import it.
library;

class ChapterMeta {
  const ChapterMeta({
    required this.chapterNum,
    this.devaTitle,
    required this.enTitle,
    this.subtitle,
    this.verseCount,
    this.chapterCount,
    this.bookNum,
  });

  final int chapterNum;
  final int? bookNum;
  final String? devaTitle;
  final String enTitle;
  final String? subtitle;
  final int? verseCount;
  // Only set for canto/skanda-level rollups (Bhāgavata Purāṇa style) where
  // each row aggregates many chapters. Drives the "{verses} verses ·
  // {chapters} chapters" row meta.
  final int? chapterCount;
}

/// Returns hard-coded chapter metadata for the given scripture, or null when
/// chapters should be loaded from the DB outline provider instead.
List<ChapterMeta>? scriptureChaptersFor(String scriptureId) =>
    _chapters[scriptureId];

const Map<String, List<ChapterMeta>> _chapters = {
  'bhagavata_purana': [
    ChapterMeta(
      chapterNum: 1,
      devaTitle: 'प्रथम स्कन्ध',
      enTitle: 'Creation',
      chapterCount: 19,
      verseCount: 810,
    ),
    ChapterMeta(
      chapterNum: 2,
      devaTitle: 'द्वितीय स्कन्ध',
      enTitle: 'The Cosmic Manifestation',
      chapterCount: 10,
      verseCount: 393,
    ),
    ChapterMeta(
      chapterNum: 3,
      devaTitle: 'तृतीय स्कन्ध',
      enTitle: 'The Status Quo',
      chapterCount: 33,
      verseCount: 1416,
    ),
    ChapterMeta(
      chapterNum: 4,
      devaTitle: 'चतुर्थ स्कन्ध',
      enTitle: 'The Creation of the Fourth Order',
      chapterCount: 31,
      verseCount: 1450,
    ),
    ChapterMeta(
      chapterNum: 5,
      devaTitle: 'पञ्चम स्कन्ध',
      enTitle: 'The Creative Impetus',
      chapterCount: 26,
      verseCount: 668,
    ),
    ChapterMeta(
      chapterNum: 6,
      devaTitle: 'षष्ठ स्कन्ध',
      enTitle: 'Prescribed Duties for Mankind',
      chapterCount: 19,
      verseCount: 855,
    ),
    ChapterMeta(
      chapterNum: 7,
      devaTitle: 'सप्तम स्कन्ध',
      enTitle: 'The Science of God',
      chapterCount: 15,
      verseCount: 750,
    ),
    ChapterMeta(
      chapterNum: 8,
      devaTitle: 'अष्टम स्कन्ध',
      enTitle: 'Withdrawal of the Cosmic Creations',
      chapterCount: 24,
      verseCount: 929,
    ),
    ChapterMeta(
      chapterNum: 9,
      devaTitle: 'नवम स्कन्ध',
      enTitle: 'Liberation',
      chapterCount: 24,
      verseCount: 962,
    ),
    ChapterMeta(
      chapterNum: 10,
      devaTitle: 'दशम स्कन्ध',
      enTitle: 'The Summum Bonum',
      chapterCount: 90,
      verseCount: 3948,
    ),
    ChapterMeta(
      chapterNum: 11,
      devaTitle: 'एकादश स्कन्ध',
      enTitle: 'General History',
      chapterCount: 31,
      verseCount: 1360,
    ),
    ChapterMeta(
      chapterNum: 12,
      devaTitle: 'द्वादश स्कन्ध',
      enTitle: 'The Age of Deterioration',
      chapterCount: 13,
      verseCount: 564,
    ),
  ],
  'yoga_sutras': [
    ChapterMeta(
      chapterNum: 1,
      enTitle: 'Samādhi Pāda',
      subtitle:
          'On Contemplation — the nature of Yoga and the states of the mind.',
      verseCount: 51,
    ),
    ChapterMeta(
      chapterNum: 2,
      enTitle: 'Sādhana Pāda',
      subtitle:
          'On Practice — Kriya Yoga, the five afflictions, and the eight limbs.',
      verseCount: 55,
    ),
    ChapterMeta(
      chapterNum: 3,
      enTitle: 'Vibhūti Pāda',
      subtitle:
          'On Powers — Dhāraṇā, Dhyāna, Samādhi, and the extraordinary attainments.',
      verseCount: 55,
    ),
    ChapterMeta(
      chapterNum: 4,
      enTitle: 'Kaivalya Pāda',
      subtitle:
          'On Liberation — the nature of the mind, Karma, and final independence.',
      verseCount: 34,
    ),
  ],
  'hatha_yoga_pradipika': [
    ChapterMeta(
      chapterNum: 1,
      enTitle: 'Asanas',
      subtitle:
          'The foundation of Hatha Yoga — postures, their benefits, and preparation for higher practice.',
      verseCount: 67,
    ),
    ChapterMeta(
      chapterNum: 2,
      enTitle: 'Prāṇāyāma',
      subtitle:
          'The breath is life. Eight Kumbhakas, Nāḍi purification, and Kuṇḍalinī awakening.',
      verseCount: 78,
    ),
    ChapterMeta(
      chapterNum: 3,
      enTitle: 'Mudras',
      subtitle:
          'Gestures and locks — Mahā Mudrā, Bandhas, and the awakening of Kuṇḍalinī Śakti.',
      verseCount: 130,
    ),
    ChapterMeta(
      chapterNum: 4,
      enTitle: 'Samādhi',
      subtitle:
          'The culmination — Rāja Yoga, Laya, Nāda, and liberation through dissolution of the mind.',
      verseCount: 114,
    ),
  ],
  'manusmriti': [
    ChapterMeta(
        chapterNum: 1,
        enTitle: 'Creation',
        subtitle:
            'Origin of the world, nature of Brahman, and sources of dharma.',
        verseCount: 119),
    ChapterMeta(
        chapterNum: 2,
        enTitle: 'Education',
        subtitle:
            'Initiation, the student, study of the Veda, twice-born duties.',
        verseCount: 249),
    ChapterMeta(
        chapterNum: 3,
        enTitle: 'Marriage',
        subtitle:
            'Marriage laws, the householder, and the five great sacrifices.',
        verseCount: 286),
    ChapterMeta(
        chapterNum: 4,
        enTitle: 'Livelihood',
        subtitle:
            'Occupations, private morals, and the conduct of virtuous men.',
        verseCount: 260),
    ChapterMeta(
        chapterNum: 5,
        enTitle: 'Purification',
        subtitle: 'Dietary laws, purification rites, and the status of women.',
        verseCount: 169),
    ChapterMeta(
        chapterNum: 6,
        enTitle: 'Ascetic',
        subtitle:
            'The forest dweller, the wandering ascetic, and the path to liberation.',
        verseCount: 97),
    ChapterMeta(
        chapterNum: 7,
        enTitle: 'Governance',
        subtitle:
            'The duties of the king, ministers, councils, and the conduct of war.',
        verseCount: 226),
    ChapterMeta(
        chapterNum: 8,
        enTitle: 'Civil Law',
        subtitle:
            'The eighteen grounds of litigation, evidence, punishments, and contracts.',
        verseCount: 420),
    ChapterMeta(
        chapterNum: 9,
        enTitle: 'Family Law',
        subtitle:
            'Inheritance, property, the duties of husband and wife, and the king\'s justice.',
        verseCount: 336),
    ChapterMeta(
        chapterNum: 10,
        enTitle: 'Mixed Castes',
        subtitle:
            'Origins of mixed castes, their occupations, and the summary of all dharma.',
        verseCount: 131),
    ChapterMeta(
        chapterNum: 11,
        enTitle: 'Penances',
        subtitle: 'Sins, expiations, atonements, and the power of Japa.',
        verseCount: 265),
    ChapterMeta(
        chapterNum: 12,
        enTitle: 'Liberation',
        subtitle:
            'Transmigration of souls, the three qualities, supreme good, and final liberation.',
        verseCount: 126),
  ],
  'mahanirvana_tantra': [
    ChapterMeta(
        chapterNum: 1,
        enTitle: 'Hymn to Brahman',
        subtitle:
            'Salutation to Brahman as Sat-Chit-Ānanda, and to the Devī as supreme Śakti.'),
    ChapterMeta(
        chapterNum: 2,
        enTitle: 'Brahman and Śakti',
        subtitle:
            'Śiva declares the supreme eternal knowledge. Brahman is real, the world is illusion.'),
    ChapterMeta(
        chapterNum: 3,
        enTitle: 'Qualifications of Disciples',
        subtitle:
            'The marks of an excellent aspirant, the ideal Guru, and the devoted disciple.'),
    ChapterMeta(
        chapterNum: 4,
        enTitle: 'Brahma Mantra and Initiation',
        subtitle:
            'OM, the Gāyatrī, and the eternal Brahma Mantra. The necessity of initiation.'),
    ChapterMeta(
        chapterNum: 5,
        enTitle: 'Rules for Brahma Sādhana',
        subtitle:
            'Rising in Brahma Muhūrta, Japa, compassion, purity, and truthful conduct.'),
    ChapterMeta(
        chapterNum: 6,
        enTitle: 'Worship and Purification',
        subtitle:
            'Purity of feeling is the foundation of all worship, Japa, and sacred rites.'),
    ChapterMeta(
        chapterNum: 7,
        enTitle: 'Pañcatattva and Worship',
        subtitle:
            'The five M\'s and their symbolic interpretation. Knowledge is supreme liberation.'),
    ChapterMeta(
        chapterNum: 8,
        enTitle: 'Kulācāra',
        subtitle:
            'The highest Āgama. The Kulīna sees Self in all beings equally, beyond all rules.'),
    ChapterMeta(
        chapterNum: 9,
        enTitle: 'Hymn to Ādyā Kālī',
        subtitle:
            'The great hymn to Kālī — Mother of creation, preservation, and dissolution.'),
    ChapterMeta(
        chapterNum: 10,
        enTitle: 'The Ten Saṃskāras',
        subtitle:
            'The ten purificatory rites from birth to marriage that make a man twice-born.'),
    ChapterMeta(
        chapterNum: 11,
        enTitle: 'Funeral Rites',
        subtitle:
            'Death is certain for all. The eternal Self is never born and never dies.'),
    ChapterMeta(
        chapterNum: 12,
        enTitle: 'Prāyaścitta',
        subtitle:
            'Expiation through Brahma Jñāna. Varṇāśrama conduct as the path to Vishnu.'),
    ChapterMeta(
        chapterNum: 13,
        enTitle: 'Duties of Householder',
        subtitle:
            'The guest is Nārāyaṇa. The king rules for subjects, not for himself.'),
    ChapterMeta(
        chapterNum: 14,
        enTitle: 'Liberation',
        subtitle:
            '"I am Brahman." The knower of Brahman becomes Brahman. OM TAT SAT.'),
  ],
  'brahma_sutras': [
    ChapterMeta(
        chapterNum: 1,
        enTitle: 'Samanvaya',
        subtitle: 'Reconciliation — Brahman is the sole cause of the universe.',
        verseCount: 134),
    ChapterMeta(
        chapterNum: 2,
        enTitle: 'Avirodha',
        subtitle:
            'Non-conflict — Refutation of Sāṅkhya, Vaiśeṣika, and other opposing schools.',
        verseCount: 157),
    ChapterMeta(
        chapterNum: 3,
        enTitle: 'Sādhana',
        subtitle:
            'Means of Attainment — The nature of the soul, meditation, and the path to Brahman.',
        verseCount: 186),
    ChapterMeta(
        chapterNum: 4,
        enTitle: 'Phala',
        subtitle:
            'Fruits of Knowledge — Liberation, the path after death, and non-return of the liberated soul.',
        verseCount: 78),
  ],
  'samaveda': [
    ChapterMeta(
        chapterNum: 1,
        enTitle: 'Prapāṭhaka I — Agni',
        subtitle:
            'Hymns to Agni, the sacred fire. The opening verses sung at every Soma sacrifice.'),
    ChapterMeta(
        chapterNum: 2,
        enTitle: 'Prapāṭhaka II — Soma and Indra',
        subtitle:
            'The Soma hymns sung for Indra. OM — the lord of truth comes to the feast.'),
    ChapterMeta(
        chapterNum: 3,
        enTitle: 'Prapāṭhaka III — Soma Pavamāna',
        subtitle: 'Purified Soma flows for Indra. Svāhā — all divine.'),
    ChapterMeta(
        chapterNum: 4,
        enTitle: 'Prapāṭhaka IV — Songs of Praise',
        subtitle:
            'Songs of praise to Indra. Wondrous gifts and the king of immortality.'),
    ChapterMeta(
        chapterNum: 5,
        enTitle: 'Prapāṭhaka V — The OM Invocation',
        subtitle:
            'OM — the supreme invocation. Soma pressed for the All-Divine.'),
  ],
  // Yajurveda: the previous curated list claimed 3 "kāṇḍas" but the DB
  // holds 40 flat chapter_nums. With curated taking precedence the chapter
  // list rendered only the first 3 entries and chapterReadCount(chapter=1)
  // never matched a user-perceived "Kāṇḍa 1" completion (user complaint
  // 2026-05-27). Dropping the curated entries lets chapterOutlinesProvider
  // drive all 40 from the DB so reads + completion line up.
  'vishnu_purana': [
    ChapterMeta(
      chapterNum: 1,
      devaTitle: 'प्रथम अंश',
      enTitle: 'Creation',
      subtitle:
          'Parāśara teaches Maitreya. From Vishnu the universe arises and into Vishnu it dissolves.',
      chapterCount: 22,
      verseCount: 1500,
    ),
    ChapterMeta(
      chapterNum: 2,
      devaTitle: 'द्वितीय अंश',
      enTitle: 'Cosmology',
      subtitle:
          'Seven continents and seven seas. Bhāratavarṣa — the land of action where karma bears fruit.',
      chapterCount: 16,
      verseCount: 1100,
    ),
    ChapterMeta(
      chapterNum: 3,
      devaTitle: 'तृतीय अंश',
      enTitle: 'Dharma and the Vedas',
      subtitle:
          'Vyāsa divides the Vedas fourfold. Vishnu alone is all the world and the supreme state.',
      chapterCount: 18,
      verseCount: 700,
    ),
    ChapterMeta(
      chapterNum: 4,
      devaTitle: 'चतुर्थ अंश',
      enTitle: 'Dynasties of Kings',
      subtitle:
          'The Solar dynasty from Manu through Ikṣvāku to Raghu, Aja, Daśaratha, and Rāmacandra.',
      chapterCount: 24,
      verseCount: 700,
    ),
    ChapterMeta(
      chapterNum: 5,
      devaTitle: 'पञ्चम अंश',
      enTitle: 'Life of Krishna',
      subtitle:
          'Birth in Mathurā, childhood in Gokula, slaying of Kaṃsa, and the Bhagavad Gītā at Kurukṣetra.',
      chapterCount: 38,
      verseCount: 1500,
    ),
    ChapterMeta(
      chapterNum: 6,
      devaTitle: 'षष्ठ अंश',
      enTitle: 'Liberation',
      subtitle:
          'Signs of Kali Yuga. Hari\'s name alone is the way. All the world is pervaded by Vishnu.',
      chapterCount: 8,
      verseCount: 500,
    ),
  ],
  'devi_bhagavata_purana': [
    ChapterMeta(
      chapterNum: 1,
      devaTitle: 'प्रथम स्कन्ध',
      enTitle: 'Creation and the Greatness of the Devī',
      chapterCount: 20,
      verseCount: 700,
    ),
    ChapterMeta(
      chapterNum: 2,
      devaTitle: 'द्वितीय स्कन्ध',
      enTitle: 'Vyāsa and the Bhārata Lineage',
      chapterCount: 12,
      verseCount: 360,
    ),
    ChapterMeta(
      chapterNum: 3,
      devaTitle: 'तृतीय स्कन्ध',
      enTitle: 'Manifestation of the Devī',
      chapterCount: 30,
      verseCount: 1500,
    ),
    ChapterMeta(
      chapterNum: 4,
      devaTitle: 'चतुर्थ स्कन्ध',
      enTitle: 'The Births of Krishna',
      chapterCount: 25,
      verseCount: 960,
    ),
    ChapterMeta(
      chapterNum: 5,
      devaTitle: 'पञ्चम स्कन्ध',
      enTitle: 'Slaying of Mahiṣāsura',
      subtitle:
          'The Devī slays Mahiṣāsura. The gods praise her as consciousness in all beings.',
      chapterCount: 35,
      verseCount: 3500,
    ),
    ChapterMeta(
      chapterNum: 6,
      devaTitle: 'षष्ठ स्कन्ध',
      enTitle: 'Glories of the Devī',
      chapterCount: 31,
      verseCount: 1820,
    ),
    ChapterMeta(
      chapterNum: 7,
      devaTitle: 'सप्तम स्कन्ध',
      enTitle: 'Devī Gītā',
      subtitle:
          '"I alone am Brahman." The Devī teaches the supreme knowledge of her own nature.',
      chapterCount: 40,
      verseCount: 2200,
    ),
    ChapterMeta(
      chapterNum: 8,
      devaTitle: 'अष्टम स्कन्ध',
      enTitle: 'The Worlds of Bhuvana',
      chapterCount: 24,
      verseCount: 1290,
    ),
    ChapterMeta(
      chapterNum: 9,
      devaTitle: 'नवम स्कन्ध',
      enTitle: 'Prakṛti — The Goddess Forms',
      chapterCount: 50,
      verseCount: 3470,
    ),
    ChapterMeta(
      chapterNum: 10,
      devaTitle: 'दशम स्कन्ध',
      enTitle: 'The Manvantaras',
      chapterCount: 13,
      verseCount: 700,
    ),
    ChapterMeta(
      chapterNum: 11,
      devaTitle: 'एकादश स्कन्ध',
      enTitle: 'Rules of Conduct',
      chapterCount: 24,
      verseCount: 1280,
    ),
    ChapterMeta(
      chapterNum: 12,
      devaTitle: 'द्वादश स्कन्ध',
      enTitle: 'Liberation and the Devī\'s Abode',
      subtitle:
          'Daily recitation grants liberation. All the world is full of Śakti.',
      chapterCount: 14,
      verseCount: 1230,
    ),
  ],
  'rigveda': [
    ChapterMeta(
      chapterNum: 1,
      devaTitle: 'प्रथम मण्डल',
      enTitle: 'The First Maṇḍala',
      subtitle:
          'Various seers — Madhuchchandas, Medhātithi, Śunaḥśepa. Hymns to Agni, Indra, the Aśvins.',
      chapterCount: 191,
      verseCount: 2006,
    ),
    ChapterMeta(
      chapterNum: 2,
      devaTitle: 'द्वितीय मण्डल',
      enTitle: 'Family of Gṛtsamada',
      chapterCount: 43,
      verseCount: 429,
    ),
    ChapterMeta(
      chapterNum: 3,
      devaTitle: 'तृतीय मण्डल',
      enTitle: 'Family of Viśvāmitra',
      subtitle: 'Includes the Gāyatrī Mantra — Tat savitur vareṇyam.',
      chapterCount: 62,
      verseCount: 617,
    ),
    ChapterMeta(
      chapterNum: 4,
      devaTitle: 'चतुर्थ मण्डल',
      enTitle: 'Family of Vāmadeva',
      chapterCount: 58,
      verseCount: 589,
    ),
    ChapterMeta(
      chapterNum: 5,
      devaTitle: 'पञ्चम मण्डल',
      enTitle: 'Family of Atri',
      chapterCount: 87,
      verseCount: 727,
    ),
    ChapterMeta(
      chapterNum: 6,
      devaTitle: 'षष्ठ मण्डल',
      enTitle: 'Family of Bharadvāja',
      chapterCount: 75,
      verseCount: 765,
    ),
    ChapterMeta(
      chapterNum: 7,
      devaTitle: 'सप्तम मण्डल',
      enTitle: 'Family of Vasiṣṭha',
      chapterCount: 104,
      verseCount: 841,
    ),
    ChapterMeta(
      chapterNum: 8,
      devaTitle: 'अष्टम मण्डल',
      enTitle: 'Family of Kāṇva',
      chapterCount: 103,
      verseCount: 1716,
    ),
    ChapterMeta(
      chapterNum: 9,
      devaTitle: 'नवम मण्डल',
      enTitle: 'The Pavamāna Soma Hymns',
      chapterCount: 114,
      verseCount: 1108,
    ),
    ChapterMeta(
      chapterNum: 10,
      devaTitle: 'दशम मण्डल',
      enTitle: 'Various Seers — Philosophical Hymns',
      subtitle:
          'The Nāsadīya Sūkta on creation, the Puruṣa Sūkta, the Hiraṇyagarbha Sūkta.',
      chapterCount: 191,
      verseCount: 1754,
    ),
  ],
  'atharvaveda': [
    ChapterMeta(
        chapterNum: 1,
        devaTitle: 'प्रथम काण्ड',
        enTitle: 'Healing and Long Life',
        chapterCount: 35),
    ChapterMeta(
        chapterNum: 2,
        devaTitle: 'द्वितीय काण्ड',
        enTitle: 'Charms Against Disease',
        chapterCount: 36),
    ChapterMeta(
        chapterNum: 3,
        devaTitle: 'तृतीय काण्ड',
        enTitle: 'Prosperity and Protection',
        chapterCount: 31),
    ChapterMeta(
        chapterNum: 4,
        devaTitle: 'चतुर्थ काण्ड',
        enTitle: 'Charms for Power and Glory',
        chapterCount: 40),
    ChapterMeta(
        chapterNum: 5,
        devaTitle: 'पञ्चम काण्ड',
        enTitle: 'Hymns for Various Ends',
        chapterCount: 31),
    ChapterMeta(
        chapterNum: 6,
        devaTitle: 'षष्ठ काण्ड',
        enTitle: 'Short Charms',
        chapterCount: 142),
    ChapterMeta(
        chapterNum: 7,
        devaTitle: 'सप्तम काण्ड',
        enTitle: 'Miscellaneous Hymns',
        chapterCount: 123),
    ChapterMeta(
        chapterNum: 8,
        devaTitle: 'अष्टम काण्ड',
        enTitle: 'Long Speculative Hymns',
        chapterCount: 10),
    ChapterMeta(
        chapterNum: 9,
        devaTitle: 'नवम काण्ड',
        enTitle: 'Ritual and Mystical Hymns',
        chapterCount: 10),
    ChapterMeta(
        chapterNum: 10,
        devaTitle: 'दशम काण्ड',
        enTitle: 'Cosmogonic Hymns',
        chapterCount: 10),
    ChapterMeta(
        chapterNum: 11,
        devaTitle: 'एकादश काण्ड',
        enTitle: 'Brahmaudana and Vrātya',
        chapterCount: 10),
    ChapterMeta(
        chapterNum: 12,
        devaTitle: 'द्वादश काण्ड',
        enTitle: 'Pṛthivī Sūkta — Hymn to Earth',
        chapterCount: 5),
    ChapterMeta(
        chapterNum: 13,
        devaTitle: 'त्रयोदश काण्ड',
        enTitle: 'Rohita — The Sun God',
        chapterCount: 4),
    ChapterMeta(
        chapterNum: 14,
        devaTitle: 'चतुर्दश काण्ड',
        enTitle: 'Marriage Hymns',
        chapterCount: 2),
    ChapterMeta(
        chapterNum: 15,
        devaTitle: 'पञ्चदश काण्ड',
        enTitle: 'The Vrātya Books',
        chapterCount: 18),
    ChapterMeta(
        chapterNum: 16,
        devaTitle: 'षोडश काण्ड',
        enTitle: 'Imprecations and Spells',
        chapterCount: 9),
    ChapterMeta(
        chapterNum: 17,
        devaTitle: 'सप्तदश काण्ड',
        enTitle: 'A Single Long Hymn',
        chapterCount: 1),
    ChapterMeta(
        chapterNum: 18,
        devaTitle: 'अष्टादश काण्ड',
        enTitle: 'Funeral Hymns',
        chapterCount: 4),
    ChapterMeta(
        chapterNum: 19,
        devaTitle: 'एकोनविंशति काण्ड',
        enTitle: 'Supplementary Hymns',
        chapterCount: 72),
    ChapterMeta(
        chapterNum: 20,
        devaTitle: 'विंशति काण्ड',
        enTitle: 'Sāmavedic Borrowings',
        chapterCount: 143),
  ],
  'mahabharata': [
    ChapterMeta(
        chapterNum: 1,
        devaTitle: 'आदिपर्व',
        enTitle: 'Ādi Parva — The Beginning',
        subtitle:
            'Origins of the Kuru lineage. The births of Bhīṣma, Pāṇḍu, Dhṛtarāṣṭra, and the Pāṇḍavas.',
        chapterCount: 236,
        verseCount: 7898),
    ChapterMeta(
        chapterNum: 2,
        devaTitle: 'सभापर्व',
        enTitle: 'Sabhā Parva — The Hall',
        chapterCount: 81,
        verseCount: 2701),
    ChapterMeta(
        chapterNum: 3,
        devaTitle: 'वनपर्व',
        enTitle: 'Vana Parva — The Forest',
        chapterCount: 313,
        verseCount: 11664),
    ChapterMeta(
        chapterNum: 4,
        devaTitle: 'विराटपर्व',
        enTitle: 'Virāṭa Parva — The Year of Disguise',
        chapterCount: 67,
        verseCount: 2050),
    ChapterMeta(
        chapterNum: 5,
        devaTitle: 'उद्योगपर्व',
        enTitle: 'Udyoga Parva — Preparation for War',
        chapterCount: 199,
        verseCount: 6998),
    ChapterMeta(
        chapterNum: 6,
        devaTitle: 'भीष्मपर्व',
        enTitle: 'Bhīṣma Parva — The Fall of Bhīṣma',
        subtitle: 'Contains the Bhagavad Gītā (chapters 23–40).',
        chapterCount: 117,
        verseCount: 5884),
    ChapterMeta(
        chapterNum: 7,
        devaTitle: 'द्रोणपर्व',
        enTitle: 'Droṇa Parva — The Death of Droṇa',
        chapterCount: 173,
        verseCount: 8909),
    ChapterMeta(
        chapterNum: 8,
        devaTitle: 'कर्णपर्व',
        enTitle: 'Karṇa Parva — The Death of Karṇa',
        chapterCount: 69,
        verseCount: 4964),
    ChapterMeta(
        chapterNum: 9,
        devaTitle: 'शल्यपर्व',
        enTitle: 'Śalya Parva — The Death of Śalya',
        chapterCount: 64,
        verseCount: 3220),
    ChapterMeta(
        chapterNum: 10,
        devaTitle: 'सौप्तिकपर्व',
        enTitle: 'Sauptika Parva — The Night Massacre',
        chapterCount: 18,
        verseCount: 870),
    ChapterMeta(
        chapterNum: 11,
        devaTitle: 'स्त्रीपर्व',
        enTitle: 'Strī Parva — Lamentation of the Women',
        chapterCount: 27,
        verseCount: 775),
    ChapterMeta(
        chapterNum: 12,
        devaTitle: 'शान्तिपर्व',
        enTitle: 'Śānti Parva — Counsel of Peace',
        subtitle:
            'Bhīṣma teaches dharma, mokṣa, and rājanīti from his bed of arrows.',
        chapterCount: 365,
        verseCount: 14732),
    ChapterMeta(
        chapterNum: 13,
        devaTitle: 'अनुशासनपर्व',
        enTitle: 'Anuśāsana Parva — Final Teachings',
        chapterCount: 168,
        verseCount: 8000),
    ChapterMeta(
        chapterNum: 14,
        devaTitle: 'अश्वमेधिकपर्व',
        enTitle: 'Aśvamedhika Parva — The Horse Sacrifice',
        chapterCount: 96,
        verseCount: 2743),
    ChapterMeta(
        chapterNum: 15,
        devaTitle: 'आश्रमवासिकपर्व',
        enTitle: 'Āśramavāsika Parva — Retirement to the Forest',
        chapterCount: 47,
        verseCount: 1062),
    ChapterMeta(
        chapterNum: 16,
        devaTitle: 'मौसलपर्व',
        enTitle: 'Mausala Parva — The End of the Yādavas',
        chapterCount: 9,
        verseCount: 273),
    ChapterMeta(
        chapterNum: 17,
        devaTitle: 'महाप्रस्थानिकपर्व',
        enTitle: 'Mahāprasthānika Parva — The Great Journey',
        chapterCount: 3,
        verseCount: 106),
    ChapterMeta(
        chapterNum: 18,
        devaTitle: 'स्वर्गारोहणपर्व',
        enTitle: 'Svargārohaṇa Parva — Ascent to Heaven',
        chapterCount: 5,
        verseCount: 200),
  ],
  'ramayana': [
    ChapterMeta(
        chapterNum: 1,
        devaTitle: 'बालकाण्ड',
        enTitle: 'Bāla Kāṇḍa — Childhood',
        subtitle:
            'Birth of Rāma. The breaking of Śiva\'s bow and the marriage to Sītā.',
        chapterCount: 77,
        verseCount: 2272),
    ChapterMeta(
        chapterNum: 2,
        devaTitle: 'अयोध्याकाण्ड',
        enTitle: 'Ayodhyā Kāṇḍa — The Exile',
        chapterCount: 119,
        verseCount: 3800),
    ChapterMeta(
        chapterNum: 3,
        devaTitle: 'अरण्यकाण्ड',
        enTitle: 'Araṇya Kāṇḍa — The Forest',
        subtitle: 'Sītā\'s abduction by Rāvaṇa. The death of Jaṭāyu.',
        chapterCount: 75,
        verseCount: 2440),
    ChapterMeta(
        chapterNum: 4,
        devaTitle: 'किष्किन्धाकाण्ड',
        enTitle: 'Kiṣkindhā Kāṇḍa — Alliance with Sugrīva',
        chapterCount: 67,
        verseCount: 2200),
    ChapterMeta(
        chapterNum: 5,
        devaTitle: 'सुन्दरकाण्ड',
        enTitle: 'Sundara Kāṇḍa — Hanumān\'s Leap',
        subtitle:
            'Hanumān crosses the ocean to Laṅkā and finds Sītā in the Aśoka grove.',
        chapterCount: 68,
        verseCount: 2879),
    ChapterMeta(
        chapterNum: 6,
        devaTitle: 'युद्धकाण्ड',
        enTitle: 'Yuddha Kāṇḍa — The Great Battle',
        subtitle:
            'The bridge to Laṅkā, the war with Rāvaṇa, and the return of Rāma.',
        chapterCount: 128,
        verseCount: 3170),
    ChapterMeta(
        chapterNum: 7,
        devaTitle: 'उत्तरकाण्ड',
        enTitle: 'Uttara Kāṇḍa — The Final Chapters',
        chapterCount: 100,
        verseCount: 2000),
  ],
  'markandeya_purana': [
    ChapterMeta(
        chapterNum: 1,
        enTitle: 'Jaimini and the Birds',
        subtitle:
            'Jaimini questions the birds in the Vindhyas. The four Puruṣārthas declared.'),
    ChapterMeta(
        chapterNum: 2,
        enTitle: 'Dharma and the Yugas',
        subtitle:
            'Dharma declines across the four ages. In Kali, kīrtan and Vishnu\'s name alone suffice.'),
    ChapterMeta(
        chapterNum: 3,
        enTitle: 'Devī Māhātmya',
        subtitle:
            'Namo Devi Mahādevi. Sarva-maṅgala-māṅgalye. The great hymns of Caṇḍī.'),
    ChapterMeta(
        chapterNum: 4,
        enTitle: 'Mārkaṇḍeya and Śiva',
        subtitle:
            'The Mahā Mṛtyuñjaya Mantra. Śiva-bhakti conquers death and opens the door to liberation.'),
  ],
};
