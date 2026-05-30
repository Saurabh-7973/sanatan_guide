library;

enum Scripture {
  // Bhagavad Gita
  bhagavadGita,

  // 4 Vedas
  rigveda,
  samaveda,
  yajurveda,
  atharvaveda,

  // 13 Principal Upanishads
  ishaUpanishad,
  kenaUpanishad,
  kathaUpanishad,
  prasnaUpanishad,
  mundakaUpanishad,
  mandukyaUpanishad,
  taittiriyaUpanishad,
  aitareyaUpanishad,
  chandogyaUpanishad,
  brihadaranyakaUpanishad,
  shvetashvataraUpanishad,
  kaushitakiUpanishad,
  maitrayaniUpanishad,

  // Yoga texts
  yogaSutras,
  brahmasutras,
  hathaYogaPradipika,

  // Itihasas
  ramayana,
  mahabharata,

  // Puranas
  vishnuPurana,
  deviBhagavataPurana,
  bhagavataPurana,
  markandeya,
  vishnuSahasranama,

  // Śāstra / Tamil classics
  arthashastra,
  tirukkural,

  // Dharmashastra
  manusmriti,

  // Tantra
  mahanirvana,
}

extension ScriptureX on Scripture {
  String get code => switch (this) {
        Scripture.bhagavadGita => 'bhagavad_gita',
        Scripture.rigveda => 'rigveda',
        Scripture.samaveda => 'samaveda',
        Scripture.yajurveda => 'yajurveda',
        Scripture.atharvaveda => 'atharvaveda',
        Scripture.ishaUpanishad => 'isha_upanishad',
        Scripture.kenaUpanishad => 'kena_upanishad',
        Scripture.kathaUpanishad => 'katha_upanishad',
        Scripture.prasnaUpanishad => 'prashna_upanishad',
        Scripture.mundakaUpanishad => 'mundaka_upanishad',
        Scripture.mandukyaUpanishad => 'mandukya_upanishad',
        Scripture.taittiriyaUpanishad => 'taittiriya_upanishad',
        Scripture.aitareyaUpanishad => 'aitareya_upanishad',
        Scripture.chandogyaUpanishad => 'chandogya_upanishad',
        Scripture.brihadaranyakaUpanishad => 'brihadaranyaka_upanishad',
        Scripture.shvetashvataraUpanishad => 'shvetashvatara_upanishad',
        Scripture.kaushitakiUpanishad => 'kaushitaki_upanishad',
        Scripture.maitrayaniUpanishad => 'maitrayani_upanishad',
        Scripture.yogaSutras => 'yoga_sutras',
        Scripture.brahmasutras => 'brahma_sutras',
        Scripture.hathaYogaPradipika => 'hatha_yoga_pradipika',
        Scripture.ramayana => 'ramayana',
        Scripture.mahabharata => 'mahabharata',
        Scripture.vishnuPurana => 'vishnu_purana',
        Scripture.deviBhagavataPurana => 'devi_bhagavata_purana',
        Scripture.bhagavataPurana => 'bhagavata_purana',
        Scripture.markandeya => 'markandeya_purana',
        Scripture.vishnuSahasranama => 'vishnu_sahasranama',
        Scripture.arthashastra => 'arthashastra',
        Scripture.tirukkural => 'tirukkural',
        Scripture.manusmriti => 'manusmriti',
        Scripture.mahanirvana => 'mahanirvana_tantra',
      };

  String get displayName => switch (this) {
        Scripture.bhagavadGita => 'Bhagavad Gītā',
        Scripture.rigveda => 'Ṛgveda',
        Scripture.samaveda => 'Sāmaveda',
        Scripture.yajurveda => 'Yajurveda',
        Scripture.atharvaveda => 'Atharvaveda',
        Scripture.ishaUpanishad => 'Īśa Upaniṣad',
        Scripture.kenaUpanishad => 'Kena Upaniṣad',
        Scripture.kathaUpanishad => 'Kaṭha Upaniṣad',
        Scripture.prasnaUpanishad => 'Praśna Upaniṣad',
        Scripture.mundakaUpanishad => 'Muṇḍaka Upaniṣad',
        Scripture.mandukyaUpanishad => 'Māṇḍūkya Upaniṣad',
        Scripture.taittiriyaUpanishad => 'Taittirīya Upaniṣad',
        Scripture.aitareyaUpanishad => 'Aitareya Upaniṣad',
        Scripture.chandogyaUpanishad => 'Chāndogya Upaniṣad',
        Scripture.brihadaranyakaUpanishad => 'Bṛhadāraṇyaka Upaniṣad',
        Scripture.shvetashvataraUpanishad => 'Śvetāśvatara Upaniṣad',
        Scripture.kaushitakiUpanishad => 'Kauṣītaki Upaniṣad',
        Scripture.maitrayaniUpanishad => 'Maitrāyaṇī Upaniṣad',
        Scripture.yogaSutras => 'Yoga Sūtras',
        Scripture.brahmasutras => 'Brahma Sūtras',
        Scripture.hathaYogaPradipika => 'Haṭha Yoga Pradīpikā',
        Scripture.ramayana => 'Rāmāyaṇa',
        Scripture.mahabharata => 'Mahābhārata',
        Scripture.vishnuPurana => 'Viṣṇu Purāṇa',
        Scripture.deviBhagavataPurana => 'Devī Bhāgavata Purāṇa',
        Scripture.bhagavataPurana => 'Bhāgavata Purāṇa',
        Scripture.markandeya => 'Mārkaṇḍeya Purāṇa',
        Scripture.vishnuSahasranama => 'Viṣṇu Sahasranāma',
        Scripture.arthashastra => 'Arthaśāstra',
        Scripture.tirukkural => 'Tirukkuṟaḷ',
        Scripture.manusmriti => 'Manusmṛti',
        Scripture.mahanirvana => 'Mahānirvāṇa Tantra',
      };

  /// Devanāgarī (or Tamil for Tirukkural) title used as the editorial
  /// header on Chapter List. Falls back to [displayName] when not set.
  String get devaName => switch (this) {
        Scripture.bhagavadGita => 'भगवद्गीता',
        Scripture.rigveda => 'ऋग्वेद',
        Scripture.samaveda => 'सामवेद',
        Scripture.yajurveda => 'यजुर्वेद',
        Scripture.atharvaveda => 'अथर्ववेद',
        Scripture.ishaUpanishad => 'ईशोपनिषद्',
        Scripture.kenaUpanishad => 'केनोपनिषद्',
        Scripture.kathaUpanishad => 'कठोपनिषद्',
        Scripture.prasnaUpanishad => 'प्रश्नोपनिषद्',
        Scripture.mundakaUpanishad => 'मुण्डकोपनिषद्',
        Scripture.mandukyaUpanishad => 'माण्डूक्योपनिषद्',
        Scripture.taittiriyaUpanishad => 'तैत्तिरीयोपनिषद्',
        Scripture.aitareyaUpanishad => 'ऐतरेयोपनिषद्',
        Scripture.chandogyaUpanishad => 'छान्दोग्योपनिषद्',
        Scripture.brihadaranyakaUpanishad => 'बृहदारण्यकोपनिषद्',
        Scripture.shvetashvataraUpanishad => 'श्वेताश्वतरोपनिषद्',
        Scripture.kaushitakiUpanishad => 'कौषीतक्युपनिषद्',
        Scripture.maitrayaniUpanishad => 'मैत्रायण्युपनिषद्',
        Scripture.yogaSutras => 'योगसूत्र',
        Scripture.brahmasutras => 'ब्रह्मसूत्र',
        Scripture.hathaYogaPradipika => 'हठयोगप्रदीपिका',
        Scripture.ramayana => 'रामायण',
        Scripture.mahabharata => 'महाभारत',
        Scripture.vishnuPurana => 'विष्णुपुराण',
        Scripture.deviBhagavataPurana => 'देवीभागवतपुराणम्',
        Scripture.bhagavataPurana => 'श्रीमद्भागवतम्',
        Scripture.markandeya => 'मार्कण्डेयपुराण',
        Scripture.vishnuSahasranama => 'विष्णुसहस्रनाम',
        Scripture.arthashastra => 'अर्थशास्त्र',
        Scripture.tirukkural => 'திருக்குறள்',
        Scripture.manusmriti => 'मनुस्मृति',
        Scripture.mahanirvana => 'महानिर्वाणतन्त्र',
      };

  /// Italic-serif scholarly subtitle shown beneath the Devanāgarī title
  /// in the Chapter List header (e.g. "Bhagavad Gītā · The Song of God").
  String get scholarlySubtitle => switch (this) {
        Scripture.bhagavadGita => 'Bhagavad Gītā · The Song of God',
        Scripture.rigveda => 'Ṛgveda · The Veda of Hymns',
        Scripture.samaveda => 'Sāmaveda · The Veda of Melodies',
        Scripture.yajurveda => 'Yajurveda · The Veda of Sacrificial Formulas',
        Scripture.atharvaveda => 'Atharvaveda · The Veda of Atharvan',
        Scripture.yogaSutras => 'Yoga Sūtras · Patañjali\'s aphorisms on Yoga',
        Scripture.brahmasutras => 'Brahma Sūtras · The Vedānta aphorisms',
        Scripture.hathaYogaPradipika =>
          'Haṭha Yoga Pradīpikā · Light on the Forceful Path',
        Scripture.ramayana => 'Rāmāyaṇa · The Journey of Rāma',
        Scripture.mahabharata => 'Mahābhārata · The Great Tale of the Bhāratas',
        Scripture.vishnuPurana => 'Viṣṇu Purāṇa · The Story of Viṣṇu',
        Scripture.deviBhagavataPurana =>
          'Devī Bhāgavata Purāṇa · The Glory of the Goddess',
        Scripture.bhagavataPurana => 'Bhāgavata Purāṇa · The Story of the Lord',
        Scripture.markandeya => 'Mārkaṇḍeya Purāṇa · The Purāṇa of Mārkaṇḍeya',
        Scripture.vishnuSahasranama =>
          'Viṣṇu Sahasranāma · The Thousand Names of Viṣṇu',
        Scripture.arthashastra => 'Arthaśāstra · The Treatise on Polity',
        Scripture.tirukkural => 'Tirukkuṟaḷ · The Sacred Couplets',
        Scripture.manusmriti => 'Manusmṛti · The Code of Manu',
        Scripture.mahanirvana =>
          'Mahānirvāṇa Tantra · Tantra of the Great Liberation',
        _ => '$displayName · A principal Upaniṣad',
      };

  /// Two- or three-letter abbreviation used in compact chapter/verse-list
  /// headers (e.g. `BG 1`, `MB 6.25`). Mirrors how scriptures are cited in
  /// scholarly editions.
  String get shortCode => switch (this) {
        Scripture.bhagavadGita => 'BG',
        Scripture.rigveda => 'RV',
        Scripture.samaveda => 'SV',
        Scripture.yajurveda => 'YV',
        Scripture.atharvaveda => 'AV',
        Scripture.ishaUpanishad => 'IśU',
        Scripture.kenaUpanishad => 'KeU',
        Scripture.kathaUpanishad => 'KaU',
        Scripture.prasnaUpanishad => 'PrU',
        Scripture.mundakaUpanishad => 'MuU',
        Scripture.mandukyaUpanishad => 'MāU',
        Scripture.taittiriyaUpanishad => 'TaU',
        Scripture.aitareyaUpanishad => 'AiU',
        Scripture.chandogyaUpanishad => 'ChU',
        Scripture.brihadaranyakaUpanishad => 'BĀU',
        Scripture.shvetashvataraUpanishad => 'ŚvU',
        Scripture.kaushitakiUpanishad => 'KauU',
        Scripture.maitrayaniUpanishad => 'MaiU',
        Scripture.yogaSutras => 'YS',
        Scripture.brahmasutras => 'BS',
        Scripture.hathaYogaPradipika => 'HYP',
        Scripture.ramayana => 'Rām',
        Scripture.mahabharata => 'Mbh',
        Scripture.vishnuPurana => 'ViP',
        Scripture.deviBhagavataPurana => 'DBhP',
        Scripture.bhagavataPurana => 'BhP',
        Scripture.markandeya => 'MkP',
        Scripture.vishnuSahasranama => 'VSN',
        Scripture.arthashastra => 'AŚ',
        Scripture.tirukkural => 'TK',
        Scripture.manusmriti => 'Manu',
        Scripture.mahanirvana => 'MNT',
      };

  /// The label for a single navigable unit beneath this scripture, in
  /// display-ready English plural form. Used as the section header above
  /// chapter rows ("ALL CHAPTERS", "ALL CANTOS", etc.).
  String get unitLabel => switch (this) {
        Scripture.rigveda => 'maṇḍalas',
        Scripture.atharvaveda ||
        Scripture.samaveda ||
        Scripture.yajurveda =>
          'kāṇḍas',
        Scripture.bhagavataPurana ||
        Scripture.deviBhagavataPurana ||
        Scripture.markandeya ||
        Scripture.vishnuPurana =>
          'cantos',
        Scripture.yogaSutras => 'pādas',
        Scripture.hathaYogaPradipika => 'upadeśas',
        Scripture.manusmriti => 'adhyāyas',
        Scripture.brahmasutras => 'adhyāyas',
        Scripture.mahabharata => 'parvas',
        Scripture.ramayana => 'kāṇḍas',
        _ => 'chapters',
      };

  /// The two-letter code prefix for a single navigable unit. Used in the
  /// per-row Arabic fallback ("CH 1", "MD 1", "SK 1", etc.).
  String get unitCode => switch (this) {
        Scripture.rigveda => 'MD',
        Scripture.atharvaveda ||
        Scripture.samaveda ||
        Scripture.yajurveda =>
          'KN',
        Scripture.bhagavataPurana ||
        Scripture.deviBhagavataPurana ||
        Scripture.markandeya ||
        Scripture.vishnuPurana =>
          'SK',
        Scripture.yogaSutras => 'PD',
        Scripture.hathaYogaPradipika => 'UP',
        Scripture.manusmriti || Scripture.brahmasutras => 'AD',
        Scripture.mahabharata => 'PV',
        Scripture.ramayana => 'KN',
        _ => 'CH',
      };

  static Scripture fromCode(String code) {
    return Scripture.values.firstWhere(
      (s) => s.code == code,
      orElse: () => throw ArgumentError('Unknown scripture code: $code'),
    );
  }
}
