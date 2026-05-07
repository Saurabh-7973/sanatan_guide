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
        Scripture.bhagavadGita => 'Bhagavad Gita',
        Scripture.rigveda => 'Rigveda',
        Scripture.samaveda => 'Samaveda',
        Scripture.yajurveda => 'Yajurveda',
        Scripture.atharvaveda => 'Atharvaveda',
        Scripture.ishaUpanishad => 'Isha Upanishad',
        Scripture.kenaUpanishad => 'Kena Upanishad',
        Scripture.kathaUpanishad => 'Katha Upanishad',
        Scripture.prasnaUpanishad => 'Prashna Upanishad',
        Scripture.mundakaUpanishad => 'Mundaka Upanishad',
        Scripture.mandukyaUpanishad => 'Mandukya Upanishad',
        Scripture.taittiriyaUpanishad => 'Taittiriya Upanishad',
        Scripture.aitareyaUpanishad => 'Aitareya Upanishad',
        Scripture.chandogyaUpanishad => 'Chandogya Upanishad',
        Scripture.brihadaranyakaUpanishad => 'Brihadaranyaka Upanishad',
        Scripture.shvetashvataraUpanishad => 'Shvetashvatara Upanishad',
        Scripture.kaushitakiUpanishad => 'Kaushitaki Upanishad',
        Scripture.maitrayaniUpanishad => 'Maitrayani Upanishad',
        Scripture.yogaSutras => 'Yoga Sutras',
        Scripture.brahmasutras => 'Brahma Sutras',
        Scripture.hathaYogaPradipika => 'Hatha Yoga Pradipika',
        Scripture.ramayana => 'Ramayana',
        Scripture.mahabharata => 'Mahabharata',
        Scripture.vishnuPurana => 'Vishnu Purana',
        Scripture.deviBhagavataPurana => 'Devi Bhagavata Purana',
        Scripture.bhagavataPurana => 'Bhagavata Purana',
        Scripture.markandeya => 'Markandeya Purana',
        Scripture.vishnuSahasranama => 'Vishnu Sahasranama',
        Scripture.arthashastra => 'Arthashastra',
        Scripture.tirukkural => 'Tirukkural',
        Scripture.manusmriti => 'Manusmriti',
        Scripture.mahanirvana => 'Mahanirvana Tantra',
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
        Scripture.rigveda || Scripture.atharvaveda => 'maṇḍalas',
        Scripture.samaveda || Scripture.yajurveda => 'kāṇḍas',
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
        Scripture.rigveda || Scripture.atharvaveda => 'MD',
        Scripture.samaveda || Scripture.yajurveda => 'KN',
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
