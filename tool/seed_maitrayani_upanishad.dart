import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    print('❌ DB not found at $dbPath');
    exit(1);
  }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'maitrayani_upanishad'");
    int total = 0;
    total += _seedPrapathaka1(db);
    total += _seedPrapathaka2(db);
    total += _seedPrapathaka3(db);
    total += _seedPrapathaka4(db);
    total += _seedPrapathaka5(db);
    total += _seedPrapathaka6(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Maitrayani Upanishad seeding complete');
    print('   Total verses : $total');
    print('   Output       : $dbPath');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) {
    db.execute('ROLLBACK');
    print('❌ Error: $e');
    rethrow;
  } finally {
    db.dispose();
  }
}

void _insert(Database db, {
  required String id,
  required int chapter,
  required int verse,
  required String sanskrit,
  required String english,
  required String chapterLabel,
}) {
  db.execute('''
    INSERT OR REPLACE INTO verses (
      id, scripture, chapter_num, verse_num,
      sanskrit, english, chapter_label, translation,
      is_bookmarked, read_count, created_at
    ) VALUES (?, 'maitrayani_upanishad', ?, ?, ?, ?, ?, 'muller', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedPrapathaka1(Database db) {
  const label = 'Prapathaka I — The Impermanence of the Body';
  final verses = [
    (1, 'ब्रह्मदत्त चैकितानेयः राजा बभूव। सोऽन्नमश्नन् एवमुवाच। आत्मा वा इदमेकमेव अग्र आसीत्। तस्य हायमात्मा शरीरे पापिष्ठो मृत्युरिव।',
     'King Brihadratha, having established his son in his kingdom, went to the forest. There he stood with his arms uplifted, gazing at the sun. After a thousand days a sage named Sakayanya approached him.'),
    (2, 'स होवाच। अनित्यमेतद्यत्किञ्चिदिदं जगत्। क्षणिकमेवेदं सर्वम्। आत्मनो नास्ति नित्यत्वम् इति।',
     'He said: In this foul-smelling, unsubstantial body — a conglomerate of bone, skin, muscle, marrow, flesh, seed, blood, mucus, tears, rheum, bile, and phlegm — what is the good of enjoying pleasures?'),
    (3, 'इह हि ये कामभोगास्तेषां जन्म जरा मृत्युश्चेति। एतावदेवेदं नाशवदनित्यम्। तस्मान्न विषयान् सेवेत योगी।',
     'In this body, subject to desires and pleasures — there is birth, old age, and death. Such is this perishable, impermanent world. Therefore the Yogi should not be attached to sense-objects.'),
    (4, 'स होवाच ऋषिः। हे राजन्! ब्रह्मणि त्वं स्थापय मनः। ब्रह्म हि परमं सत्यम्। ब्रह्मण्येव मनः कुरु।',
     'The sage said: O King, fix your mind on Brahman. Brahman is the highest truth. Make your mind intent on Brahman alone.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MAI.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prapathaka 1: ${verses.length} verses');
  return verses.length;
}

int _seedPrapathaka2(Database db) {
  const label = 'Prapathaka II — The Nature of the Self';
  final verses = [
    (3, 'द्वे वाव ब्रह्मणी वेदितव्ये शब्दब्रह्म परं चेति। तत्र शब्दब्रह्मणि निष्णातः परं ब्रह्माधिगच्छति।',
     'Two Brahmans are to be known — the word-Brahman and the supreme Brahman. One who is well-versed in the word-Brahman attains the supreme Brahman.'),
    (5, 'यो वा एष सुप्तेषु जागर्ति। यो वा एष कामान् कामयते। तदेव शुक्रम् तद् ब्रह्म। तदमृतमुच्यते।',
     'He who is awake while others sleep, who fashions desire after desire — that is the pure one, that is Brahman, that is called the immortal.'),
    (6, 'सर्वाणि भूतानि आत्मन्येवाभिसमाहितानि। यदा ब्रह्म वेद तदा मुक्तो भवति। यदा तद्विद्यते नान्यत्।',
     'All beings are absorbed in the Self alone. When one knows Brahman, then one is liberated. There is nothing other than that.'),
    (7, 'तस्य ह वा एतस्य आत्मनः पञ्च पदानि। यत्र ब्रह्म तत् परं नानाभवति।',
     'Of this Self there are five stations. Where Brahman is — that supreme — there is no diversity.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MAI.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prapathaka 2: ${verses.length} verses');
  return verses.length;
}

int _seedPrapathaka3(Database db) {
  const label = 'Prapathaka III — The Six Causes of Suffering';
  final verses = [
    (1, 'षडिमे श्लोका भवन्ति। अशुचिसंभवत्वात् चिरकालोषितत्वात् कर्मस्वातन्त्र्यात् संसारदोषदर्शनात् आत्मनो विद्यमानत्वात् ब्रह्मणि प्रतिष्ठितत्वाच्च।',
     'These are the six causes — arising from impurity, long residence in the womb, dependence on Karma, the seeing of the faults of worldly life, the knowability of the Self, and the being established in Brahman.'),
    (2, 'इन्द्रियाणि मनोबुद्धिः सत्त्वं तेजस्तथा रयः। एतानि षड् तत्त्वानि। एभ्यो मुक्तः स मुक्त उच्यते।',
     'The senses, mind, intellect, Sattva, Tejas, and Rayi — these are the six principles. He who is liberated from these — he is called the liberated.'),
    (4, 'तस्य ह वा एतस्य आत्मनश्चत्वारि भूतानि। पृथ्वी वायुराकाशमापश्च। तेषु प्रतिष्ठितो देहः।',
     'Of this Self there are four elements — earth, wind, ether, and water. In these the body is established.'),
    (5, 'स यो वेद। यस्मिन् सर्वे कामाः समाहिताः। तस्मिन् सर्वमेव समाहितम्। तं ब्रह्म इत्याचक्षते।',
     'He who knows — in whom all desires are absorbed — in him all this is absorbed. Him they call Brahman.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MAI.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prapathaka 3: ${verses.length} verses');
  return verses.length;
}

int _seedPrapathaka4(Database db) {
  const label = 'Prapathaka IV — The Inner Self';
  final verses = [
    (2, 'अग्निर्वायुरादित्यः कालः प्राणो ह वा अन्नम्। सर्वाणि भूतानि जायन्ते। सर्वाणि च भूतानि यतो जायन्ते।',
     'Fire, wind, sun, time, breath — indeed food. All creatures are born from these. All creatures live by these. Into these all creatures return.'),
    (4, 'तस्माद्वा एतस्मात् ब्रह्मणो जीवः। तस्माद्वा एतस्माज्जीवाद् ब्रह्म।',
     'From that Brahman comes the individual soul. From that individual soul comes Brahman again.'),
    (6, 'यो वा एष हृदये आकाशः। तस्मिन् पुरुषो मनोमयः। अमृतो हिरण्मयः।',
     'He who is in the ether within the heart — that Person made of mind, immortal, golden.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MAI.4.$v', chapter: 4, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prapathaka 4: ${verses.length} verses');
  return verses.length;
}

int _seedPrapathaka5(Database db) {
  const label = 'Prapathaka V — OM and Brahman';
  final verses = [
    (1, 'ओम् इति ब्रह्म। ओम् इत्येतदक्षरमुद्गीथः। ओम् इत्येव ध्यायेत् आत्मानम्।',
     'OM is Brahman. OM is this imperishable syllable, the Udgitha. One should meditate on OM as the Self.'),
    (2, 'स यो ह वा एतमेवमुपास्ते अग्रे संवत्सरेण पापमनपहाय परेण ज्योतिषा संपन्नः सूर्यस्य सायुज्यं गच्छति।',
     'He who meditates on OM thus — first the year washes away his sin. Then, endowed with the supreme light, he attains union with the sun.'),
    (3, 'य एव हि खल्वयमोंकारः स एव परो ब्रह्म। तं जप्त्वा मुच्यते। तमेव विद्यात्।',
     'This very OM is indeed the supreme Brahman. Having repeated it, one is liberated. Know him alone.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MAI.5.$v', chapter: 5, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prapathaka 5: ${verses.length} verses');
  return verses.length;
}

int _seedPrapathaka6(Database db) {
  const label = 'Prapathaka VI — Liberation and Brahman';
  final verses = [
    (1, 'द्वे वाव रूपे ब्रह्मणः। मूर्तं चैवामूर्तं च। मर्त्यं चामृतं च। स्थितं च यच्च। सच्च त्यच्च।',
     'Brahman has two forms — the formed and the formless, the mortal and the immortal, the stationary and the moving, the existent and the beyond.'),
    (7, 'यो ह वा अयमात्मा मनसा प्राप्यते। तमेव विद्यात्। नान्यत् किञ्चन।',
     'That Self which is attained by the mind — know that alone. Nothing else whatsoever.'),
    (10, 'यत्र नान्यत् पश्यति नान्यत् शृणोति नान्यद् विजानाति। स भूमा। यत्रान्यत् पश्यति तदल्पम्।',
     'Where one sees nothing else, hears nothing else, knows nothing else — that is the Infinite. Where one sees something else, that is finite.'),
    (17, 'अथ य एष सम्प्रसादः अस्माच्छरीरात् समुत्थाय परं ज्योतिरुपसंपद्य स्वेन रूपेणाभिनिष्पद्यते। एष आत्मेति।',
     'Now that serene one who, rising up out of this body, reaches the highest light and appears in his own true form — that is the Self.'),
    (28, 'ब्रह्म ज्योतिः। सर्वं ब्रह्म। तदेव परमं ब्रह्म। सोऽहम्।',
     'Brahman is light. All this is Brahman. That alone is the supreme Brahman. I am that.'),
    (34, 'तदेतत् त्रयं सत्यम्। प्राणो ब्रह्म। सत्यं ब्रह्म। यत् सत्यं तत् ब्रह्म।',
     'These three are truth: Prana is Brahman. Truth is Brahman. What is truth — that is Brahman.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MAI.6.$v', chapter: 6, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prapathaka 6: ${verses.length} verses');
  return verses.length;
}
