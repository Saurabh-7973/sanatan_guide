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
    db.execute("DELETE FROM verses WHERE scripture = 'kaushitaki_upanishad'");
    int total = 0;
    total += _seedChapter1(db);
    total += _seedChapter2(db);
    total += _seedChapter3(db);
    total += _seedChapter4(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Kaushitaki Upanishad seeding complete');
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
    ) VALUES (?, 'kaushitaki_upanishad', ?, ?, ?, ?, ?, 'muller', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedChapter1(Database db) {
  const label = 'Chapter I — The Path to Brahman';
  final verses = [
    (1, 'चित्र गार्ग्यायणिर्ह स्वाध्यायमुपेयाय। तं ह श्वेतकेतुरारुणेयः पर्येषाँश्चकार। तस्मा उ ह प्रोवाच। किं विद्वान् गार्ग्यायण अस्मान् उपेयाय इति।',
     'Citra the son of Gargya once came to Aruni Svetaketu seeking instruction. Aruni asked him: "Knowing what have you come to me, O son of Gargya?"'),
    (2, 'स ह प्रतिपेदे। यदेव भगवान् वेद तदेव मे ब्रवीत्विति। तस्मा उ ह प्रोवाच।',
     'He acknowledged his ignorance saying: "Please teach me whatever you know, O Bhagavat." And Aruni spoke to him.'),
    (4, 'ते ये शतं ब्रह्मलोकान् जित्वा निवर्तन्ते ते पुनरावर्तन्ते। ते ये दक्षिणेन यन्ति ते पितृलोकं गच्छन्ति। ये चोत्तरेण ते देवलोकम्।',
     'Those who win a hundred worlds of Brahman and then return — they return again. Those who go by the southern path go to the world of the fathers; those who go by the northern path go to the world of the gods.'),
    (6, 'स यदि पितृलोकाय कर्म करोति तेषामेव भवति। स यदि देवलोकाय। स यदि मनुष्यलोकाय। स यत्किञ्च श्रद्धया ददाति तत् प्रेत्य लभते।',
     'If he performs deeds for the world of the fathers, he belongs to them. If for the world of the gods, he belongs to them. If for the world of men, he belongs to them. Whatever he gives with faith — that he obtains after departing.'),
    (7, 'स य एवं विद्वान् अस्माल्लोकात् प्रैति। स इममात्मानं प्राणमेवाभिसंविशति। प्राणः श्रोत्रं श्रोत्रं मनो मनः प्राणम्।',
     'He who departs from this world knowing this — he merges into Prana, the Self. Prana into hearing, hearing into mind, mind into Prana.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'KU.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 1: ${verses.length} verses');
  return verses.length;
}

int _seedChapter2(Database db) {
  const label = 'Chapter II — Prana as Brahman';
  final verses = [
    (1, 'प्राणो ब्रह्मेति ह स्म आह कौषीतकिः। तस्य ह वा एतस्य प्राणस्य ब्रह्मणो मनो दूतः। चक्षुः पारिहारः। श्रोत्रं संविदः।',
     'Prana is Brahman — thus said Kaushitaki. Of this Prana-Brahman, mind is the messenger, eye is the gatekeeper, and ear is the announcer.'),
    (4, 'प्राण एवेदं सर्वं भवति। स य एवं वेद। स य एवं विद्वान् अस्माल्लोकात् प्रैति।',
     'Prana alone is all this. He who knows this — he who departs from this world knowing this — he merges into Prana.'),
    (7, 'अहं मनसा प्राणस्य दूतः। अहमेव प्राणोऽस्मि प्रज्ञात्मा। स मां आयुरमृतमिति उपास्व।',
     'I am the messenger of Prana through the mind. I myself am Prana, the conscious Self. Worship me as life and as immortality.'),
    (11, 'प्राण एव प्रज्ञात्मा। इदं शरीरं परिगृह्य उत्थापयति। तस्मादेव तद् आहुः प्राणज इति।',
     'Prana is the conscious Self. Having grasped this body, he raises it up. Therefore they say of it that it is born of Prana.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'KU.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 2: ${verses.length} verses');
  return verses.length;
}

int _seedChapter3(Database db) {
  const label = 'Chapter III — Indra and the Self';
  final verses = [
    (1, 'इन्द्रो ह वै प्रतर्दनाय दैवोदासये वरं ददौ। तं ह वरं वृणीष्व इत्युवाच।',
     'Indra gave Pratardana the son of Divodasa a boon. He said: "Choose a boon."'),
    (2, 'स ह प्रतर्दनः। तमेव त्वं वृणु। यं त्वं मनुष्याय हितमतमं मन्यसे इति। स ह इन्द्रः। न वै प्रतर्दन मनुष्यः स्वयम् एव वृणुते।',
     'Pratardana said: "You yourself choose — whatever you consider most beneficial for a man." Indra said: "A man should not himself choose for another."'),
    (3, 'तं ह इन्द्र उवाच। माम् एव विजानीहि इति। तद् ध्येव विद्यायाः श्रेयः मन्ये। अहं प्राणोऽस्मि प्रज्ञात्मा।',
     'Indra said: "Know me alone — this I consider the best of all knowledge. I am Prana, the conscious Self."'),
    (7, 'न वाचं विजिज्ञासीत। वक्तारं विद्यात्। न गन्धं विजिज्ञासीत। घ्रातारं विद्यात्। न रूपं विजिज्ञासीत। द्रष्टारं विद्यात्।',
     'Do not seek to know speech — know the speaker. Do not seek to know smell — know the smeller. Do not seek to know form — know the seer.'),
    (8, 'न श्रोत्रं विजिज्ञासीत। श्रोतारं विद्यात्। न मनो विजिज्ञासीत। मन्तारं विद्यात्।',
     'Do not seek to know hearing — know the hearer. Do not seek to know mind — know the thinker.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'KU.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 3: ${verses.length} verses');
  return verses.length;
}

int _seedChapter4(Database db) {
  const label = 'Chapter IV — The Nature of the Self';
  final verses = [
    (1, 'ऐतरेय आरुणिः पुत्राय बलाकये उवाच। यदा वाग् विमुच्यते। अथ मनसा स्मरति। यदा मनो विमुच्यते अथ प्राणेन संकल्पयति।',
     'Aitareya Aruni said to his son Balaki: When speech is released, then he remembers with the mind. When the mind is released, then he forms intentions with Prana.'),
    (4, 'स य एवं विद्वान् अस्माल्लोकात् प्रैति। स इमान् प्राणान् आत्मन्येव संयन्ति। प्राणाः स्वर्गे संयन्ति स्वर्गः प्राणेषु संयति।',
     'He who departs from this world knowing this — in him the Pranas unite in the Self. The Pranas unite in heaven; heaven unites in the Pranas.'),
    (6, 'यो वै बलाक एतेषाम् पुरुषाणाम् कर्ता यस्य वा एतत् कर्म तं एव विद्धि।',
     'Know him, O Balaki, who is the maker of all these persons — who is the doer of all these deeds. Know him alone.'),
    (7, 'प्रज्ञया वाचं समारुह्य वाचा सर्वाणि नामान्याप्नोति। प्रज्ञयापानं समारुह्य अपानेन सर्वान् गन्धान् आप्नोति।',
     'Mounting speech through consciousness, one attains all names through speech. Mounting downward breath through consciousness, one attains all smells through breath.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'KU.4.$v', chapter: 4, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 4: ${verses.length} verses');
  return verses.length;
}
