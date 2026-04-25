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
    db.execute("DELETE FROM verses WHERE scripture = 'aitareya_upanishad'");
    int total = 0;
    total += _seedChapter1(db);
    total += _seedChapter2(db);
    total += _seedChapter3(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Aitareya Upanishad seeding complete');
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
    ) VALUES (?, 'aitareya_upanishad', ?, ?, ?, ?, ?, 'muller', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedChapter1(Database db) {
  const label = 'Chapter I — Creation of the World';
  final verses = [
    (1, 'ॐ आत्मा वा इदमेक एवाग्र आसीत्। नान्यत्किञ्चन मिषत्। स ईक्षत लोकान्नु सृजा इति।',
     'In the beginning this was the Self alone, one only. There was nothing else that winked. He thought: Let me create the worlds.'),
    (2, 'स इमाँल्लोकानसृजत। अम्भो मरीचीर्मरमापोऽदोऽम्भः परेण दिवं द्यौः प्रतिष्ठान्तरिक्षं मरीचयः।',
     'He created these worlds — the water, the rays of light, death, and the waters. The sky is beyond the heaven. Heaven is the support. The atmosphere is the rays. The earth is death. The waters are below.'),
    (3, 'स ईक्षत इमे नु लोकाः। लोकपालान्नु सृजा इति। सोऽद्भ्य एव पुरुषं समुद्धृत्य अमूर्च्छयत्।',
     'He thought: These are the worlds indeed. Let me create guardians of the worlds. He then drew forth a Person from the waters, and gave him a shape.'),
    (4, 'तमभ्यतपत्। तस्याभितप्तस्य मुखं निरभिद्यत यथाऽण्डं। मुखाद्वाक्। वाचोऽग्निः।',
     'He brooded over him. From him, thus brooded over, the mouth was separated — like an egg. From the mouth came speech. From speech, fire.'),
    (8, 'अशनायापिपासे परिणी। ते देवाः प्रत्यब्रुवन्। ध्रुवमेव नौ प्रतिपादय। यस्मिन्प्रतिष्ठितयोरशिष्याम इति।',
     'Hunger and thirst said: For us too provide an abode. The gods said to him: Provide for us also an abode — for these two who are assigned to us, in whom we may live.'),
    (11, 'तदेतदनुव्याख्यास्यामः। अन्नं ह वा इदꣳ सर्वं भूतानाम्। तस्मान्मातरिश्वा इत्याचक्षते।',
     'This we shall explain. Food is indeed all this — all beings. Therefore they call it the breath in the mother (Matarishvan). All this depends on food.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'AU.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 1: ${verses.length} verses');
  return verses.length;
}

int _seedChapter2(Database db) {
  const label = 'Chapter II — The Three Births of Man';
  final verses = [
    (1, 'पुरुष एवेदꣳ सर्वं विश्वं कर्म तपो ब्रह्म परामृतम्। एतदयमभिजयति यो वेद।',
     'The Person is all this — the world, action, austerity, Brahman, and the highest immortality. He who knows this conquers all this.'),
    (4, 'स एष ब्रह्मणः प्रथमं सम्भव इति। एष हि पुरुषः पूर्वो ब्रह्म न जायते।',
     'This is indeed the first birth of Brahman. For this Person was born before as Brahman — he is not born again.'),
    (5, 'तस्मादेव च गर्भमेति। सोऽयं द्वितीयो जन्मा। अयं लोकं पालयति वाग्भिर्बाहुभ्यां च।',
     'From him alone a being enters the womb. This is his second birth. This man rules the world with his speech and his arms.'),
    (6, 'अयं तृतीयो जन्मा — यदा म्रियते। स एव पुनर्जायते। तस्मादुक्तम् — त्रिर्जायते अयं पुरुष इति।',
     'This is his third birth — when he dies. He is born again. Therefore it is said: This Person is born three times.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'AU.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 2: ${verses.length} verses');
  return verses.length;
}

int _seedChapter3(Database db) {
  const label = 'Chapter III — The Nature of Brahman';
  final verses = [
    (1, 'को न्वयमात्मा यमहमुपास्स इति। कतर एष आत्मा। येन वा पश्यति येन वा शृणोति येन वा गन्धाञ्जिघ्रति येन वा वाचं व्याकरोति येन वा स्वाद्वस्वादु विजानाति।',
     'Which of these is the Self that I worship? Is the Self that by which one sees, by which one hears, by which one smells odors, by which one speaks speech, by which one tastes the sweet and the not-sweet?'),
    (2, 'यदेतद्धृदयं मनश्चैतत्। संज्ञानमाज्ञानं विज्ञानं प्रज्ञानं मेधा दृष्टिर्धृतिर्मतिः।',
     'That which is heart, that is mind — perception, command, understanding, knowledge, wisdom, seeing, holding, thinking —'),
    (3, 'मनिषा जूतिः स्मृतिः संकल्पः क्रतुरसुः कामो वश इति। सर्वाण्येवैतानि प्रज्ञानस्य नामधेयानि भवन्ति।',
     'Resolve, purpose, life, desire, and control — all these are names of intelligence (Prajna). This Brahman, this Indra, this Prajapati — all these gods, and these five great elements — all this is guided by intelligence.'),
    (4, 'एष ब्रह्म। एष इन्द्रः। एष प्रजापतिः। एते सर्वे देवाः। इमानि च पञ्च महाभूतानि।',
     'This is Brahman. This is Indra. This is Prajapati. All these gods, and these five great elements — earth, air, ether, water, and fire —'),
    (5, 'प्रज्ञानं ब्रह्म। प्रज्ञानेन युक्ताः स्वर्गं लोकमुत्क्रामन्ति। सोऽहं विद्यया क्षयं नेष्यामि।',
     'Intelligence is Brahman. By intelligence united, they ascend to the heavenly world. "I shall not lead this to decay by knowledge." This is the immortal, the fearless. This is Brahman.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'AU.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 3: ${verses.length} verses');
  return verses.length;
}
