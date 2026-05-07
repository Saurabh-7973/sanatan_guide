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
    this.bookNum,
  });

  final int chapterNum;
  final int? bookNum;
  final String? devaTitle;
  final String enTitle;
  final String? subtitle;
  final int? verseCount;
}

/// Returns hard-coded chapter metadata for the given scripture, or null when
/// chapters should be loaded from the DB outline provider instead.
List<ChapterMeta>? scriptureChaptersFor(String scriptureId) =>
    _chapters[scriptureId];

const Map<String, List<ChapterMeta>> _chapters = {
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
    ChapterMeta(chapterNum: 1, enTitle: 'Creation', subtitle: 'Origin of the world, nature of Brahman, and sources of dharma.', verseCount: 119),
    ChapterMeta(chapterNum: 2, enTitle: 'Education', subtitle: 'Initiation, the student, study of the Veda, twice-born duties.', verseCount: 249),
    ChapterMeta(chapterNum: 3, enTitle: 'Marriage', subtitle: 'Marriage laws, the householder, and the five great sacrifices.', verseCount: 286),
    ChapterMeta(chapterNum: 4, enTitle: 'Livelihood', subtitle: 'Occupations, private morals, and the conduct of virtuous men.', verseCount: 260),
    ChapterMeta(chapterNum: 5, enTitle: 'Purification', subtitle: 'Dietary laws, purification rites, and the status of women.', verseCount: 169),
    ChapterMeta(chapterNum: 6, enTitle: 'Ascetic', subtitle: 'The forest dweller, the wandering ascetic, and the path to liberation.', verseCount: 97),
    ChapterMeta(chapterNum: 7, enTitle: 'Governance', subtitle: 'The duties of the king, ministers, councils, and the conduct of war.', verseCount: 226),
    ChapterMeta(chapterNum: 8, enTitle: 'Civil Law', subtitle: 'The eighteen grounds of litigation, evidence, punishments, and contracts.', verseCount: 420),
    ChapterMeta(chapterNum: 9, enTitle: 'Family Law', subtitle: 'Inheritance, property, the duties of husband and wife, and the king\'s justice.', verseCount: 336),
    ChapterMeta(chapterNum: 10, enTitle: 'Mixed Castes', subtitle: 'Origins of mixed castes, their occupations, and the summary of all dharma.', verseCount: 131),
    ChapterMeta(chapterNum: 11, enTitle: 'Penances', subtitle: 'Sins, expiations, atonements, and the power of Japa.', verseCount: 265),
    ChapterMeta(chapterNum: 12, enTitle: 'Liberation', subtitle: 'Transmigration of souls, the three qualities, supreme good, and final liberation.', verseCount: 126),
  ],
  'mahanirvana_tantra': [
    ChapterMeta(chapterNum: 1, enTitle: 'Hymn to Brahman', subtitle: 'Salutation to Brahman as Sat-Chit-Ānanda, and to the Devī as supreme Śakti.'),
    ChapterMeta(chapterNum: 2, enTitle: 'Brahman and Śakti', subtitle: 'Śiva declares the supreme eternal knowledge. Brahman is real, the world is illusion.'),
    ChapterMeta(chapterNum: 3, enTitle: 'Qualifications of Disciples', subtitle: 'The marks of an excellent aspirant, the ideal Guru, and the devoted disciple.'),
    ChapterMeta(chapterNum: 4, enTitle: 'Brahma Mantra and Initiation', subtitle: 'OM, the Gāyatrī, and the eternal Brahma Mantra. The necessity of initiation.'),
    ChapterMeta(chapterNum: 5, enTitle: 'Rules for Brahma Sādhana', subtitle: 'Rising in Brahma Muhūrta, Japa, compassion, purity, and truthful conduct.'),
    ChapterMeta(chapterNum: 6, enTitle: 'Worship and Purification', subtitle: 'Purity of feeling is the foundation of all worship, Japa, and sacred rites.'),
    ChapterMeta(chapterNum: 7, enTitle: 'Pañcatattva and Worship', subtitle: 'The five M\'s and their symbolic interpretation. Knowledge is supreme liberation.'),
    ChapterMeta(chapterNum: 8, enTitle: 'Kulācāra', subtitle: 'The highest Āgama. The Kulīna sees Self in all beings equally, beyond all rules.'),
    ChapterMeta(chapterNum: 9, enTitle: 'Hymn to Ādyā Kālī', subtitle: 'The great hymn to Kālī — Mother of creation, preservation, and dissolution.'),
    ChapterMeta(chapterNum: 10, enTitle: 'The Ten Saṃskāras', subtitle: 'The ten purificatory rites from birth to marriage that make a man twice-born.'),
    ChapterMeta(chapterNum: 11, enTitle: 'Funeral Rites', subtitle: 'Death is certain for all. The eternal Self is never born and never dies.'),
    ChapterMeta(chapterNum: 12, enTitle: 'Prāyaścitta', subtitle: 'Expiation through Brahma Jñāna. Varṇāśrama conduct as the path to Vishnu.'),
    ChapterMeta(chapterNum: 13, enTitle: 'Duties of Householder', subtitle: 'The guest is Nārāyaṇa. The king rules for subjects, not for himself.'),
    ChapterMeta(chapterNum: 14, enTitle: 'Liberation', subtitle: '"I am Brahman." The knower of Brahman becomes Brahman. OM TAT SAT.'),
  ],
  'brahma_sutras': [
    ChapterMeta(chapterNum: 1, enTitle: 'Samanvaya', subtitle: 'Reconciliation — Brahman is the sole cause of the universe.', verseCount: 134),
    ChapterMeta(chapterNum: 2, enTitle: 'Avirodha', subtitle: 'Non-conflict — Refutation of Sāṅkhya, Vaiśeṣika, and other opposing schools.', verseCount: 157),
    ChapterMeta(chapterNum: 3, enTitle: 'Sādhana', subtitle: 'Means of Attainment — The nature of the soul, meditation, and the path to Brahman.', verseCount: 186),
    ChapterMeta(chapterNum: 4, enTitle: 'Phala', subtitle: 'Fruits of Knowledge — Liberation, the path after death, and non-return of the liberated soul.', verseCount: 78),
  ],
  'samaveda': [
    ChapterMeta(chapterNum: 1, enTitle: 'Prapāṭhaka I — Agni', subtitle: 'Hymns to Agni, the sacred fire. The opening verses sung at every Soma sacrifice.'),
    ChapterMeta(chapterNum: 2, enTitle: 'Prapāṭhaka II — Soma and Indra', subtitle: 'The Soma hymns sung for Indra. OM — the lord of truth comes to the feast.'),
    ChapterMeta(chapterNum: 3, enTitle: 'Prapāṭhaka III — Soma Pavamāna', subtitle: 'Purified Soma flows for Indra. Svāhā — all divine.'),
    ChapterMeta(chapterNum: 4, enTitle: 'Prapāṭhaka IV — Songs of Praise', subtitle: 'Songs of praise to Indra. Wondrous gifts and the king of immortality.'),
    ChapterMeta(chapterNum: 5, enTitle: 'Prapāṭhaka V — The OM Invocation', subtitle: 'OM — the supreme invocation. Soma pressed for the All-Divine.'),
  ],
  'yajurveda': [
    ChapterMeta(chapterNum: 1, enTitle: 'Kāṇḍa I — Sacrificial Formulas', subtitle: 'For food, for strength. From falsehood I step to truth. The sacred waters.'),
    ChapterMeta(chapterNum: 2, enTitle: 'Kāṇḍa II — Soma Sacrifice', subtitle: 'King Soma called for shelter. Agni is head of heaven and lord of earth.'),
    ChapterMeta(chapterNum: 3, enTitle: 'Kāṇḍa III — The Śatarudriya', subtitle: 'The 108 names of Rudra. Reverence to the blue-throated, to Paśupati, to Śiva.'),
  ],
  'vishnu_purana': [
    ChapterMeta(chapterNum: 1, enTitle: 'Aṃśa I — Creation', subtitle: 'Parāśara teaches Maitreya. From Vishnu the universe arises and into Vishnu it dissolves.'),
    ChapterMeta(chapterNum: 2, enTitle: 'Aṃśa II — Cosmology', subtitle: 'Seven continents and seven seas. Bhāratavarṣa — the land of action where karma bears fruit.'),
    ChapterMeta(chapterNum: 3, enTitle: 'Aṃśa III — Dharma and Vedas', subtitle: 'Vyāsa divides the Vedas fourfold. Vishnu alone is all the world and the supreme state.'),
    ChapterMeta(chapterNum: 4, enTitle: 'Aṃśa IV — Dynasties of Kings', subtitle: 'The Solar dynasty from Manu through Ikṣvāku to Raghu, Aja, Daśaratha, and Rāmacandra.'),
    ChapterMeta(chapterNum: 5, enTitle: 'Aṃśa V — Life of Krishna', subtitle: 'Birth in Mathurā, childhood in Gokula, slaying of Kaṃsa, and the Bhagavad Gītā at Kurukṣetra.'),
    ChapterMeta(chapterNum: 6, enTitle: 'Aṃśa VI — Liberation', subtitle: 'Signs of Kali Yuga. Hari\'s name alone is the way. All the world is pervaded by Vishnu.'),
  ],
  'devi_bhagavata_purana': [
    ChapterMeta(chapterNum: 1, enTitle: 'Skanda I — Supremacy of the Devī', subtitle: 'She alone is Māyā, Vidyā, and supreme Nature. The gods act only by her power.'),
    ChapterMeta(chapterNum: 3, enTitle: 'Skanda III — Slaying of Mahiṣāsura', subtitle: 'The Devī slays Mahiṣāsura. The gods praise her as consciousness in all beings.'),
    ChapterMeta(chapterNum: 5, enTitle: 'Skanda V — Devī Gītā', subtitle: '"I alone am Brahman." The Devī teaches the supreme knowledge of her own nature.'),
    ChapterMeta(chapterNum: 7, enTitle: 'Skanda VII — Durgā Saptaśatī', subtitle: 'The great hymn to Durgā — refuge for the poor, destroyer of suffering and fear.'),
    ChapterMeta(chapterNum: 12, enTitle: 'Skanda XII — Liberation', subtitle: 'Daily recitation grants liberation. All the world is full of Śakti.'),
  ],
  'markandeya_purana': [
    ChapterMeta(chapterNum: 1, enTitle: 'Jaimini and the Birds', subtitle: 'Jaimini questions the birds in the Vindhyas. The four Puruṣārthas declared.'),
    ChapterMeta(chapterNum: 2, enTitle: 'Dharma and the Yugas', subtitle: 'Dharma declines across the four ages. In Kali, kīrtan and Vishnu\'s name alone suffice.'),
    ChapterMeta(chapterNum: 3, enTitle: 'Devī Māhātmya', subtitle: 'Namo Devi Mahādevi. Sarva-maṅgala-māṅgalye. The great hymns of Caṇḍī.'),
    ChapterMeta(chapterNum: 4, enTitle: 'Mārkaṇḍeya and Śiva', subtitle: 'The Mahā Mṛtyuñjaya Mantra. Śiva-bhakti conquers death and opens the door to liberation.'),
  ],
};
