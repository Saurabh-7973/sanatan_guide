import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) { print('❌ DB not found'); exit(1); }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'yajurveda'");
    int total = 0;
    total += _seedKanda1(db);
    total += _seedKanda2(db);
    total += _seedKanda3(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Yajurveda seeding complete');
    print('   Total verses : $total');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) { db.execute('ROLLBACK'); rethrow; } finally { db.dispose(); }
}

void _insert(Database db, String id, int ch, int v, String sk, String en, String label) {
  db.execute('''INSERT OR REPLACE INTO verses (
    id, scripture, chapter_num, verse_num, sanskrit, english,
    chapter_label, translation, is_bookmarked, read_count, created_at
  ) VALUES (?, 'yajurveda', ?, ?, ?, ?, ?, 'griffith', 0, 0, ?)''',
  [id, ch, v, sk, en, label, DateTime.now().millisecondsSinceEpoch]);
}

int _seedKanda1(Database db) {
  const label = 'Kanda I — Sacrificial Formulas';
  final verses = [
    (1, 'इषे त्वोर्जे त्वा वायवस्थ देवो वः सविता प्रार्पयतु श्रेष्ठतमाय कर्मणे।',
     'For food thee, for strength thee. O Vāyu, thou art the lord. May the god Savitar impel you to the most excellent work.'),
    (2, 'देवस्य त्वा सवितुः प्रसवेऽश्विनोर्बाहुभ्यां पूष्णो हस्ताभ्यामाददे।',
     'By the impulse of the divine Savitar, with the arms of the Asvins, with the hands of Pushan, I take thee.'),
    (8, 'अग्ने व्रतपते व्रतं चरिष्यामि तच्छकेयं तन्मे राध्यताम्। इदमहमनृतात् सत्यमुपैमि।',
     'O Agni, lord of vows, I shall observe my vow. May I be able to perform it, may it succeed for me. From falsehood I now step to truth.'),
    (12, 'शन्नो देवीरभिष्टय आपो भवन्तु पीतये। शं योरभि स्रवन्तु नः।',
     'May the divine waters be good for our drinking, flowing for our joy. May they be auspicious and flow for our good.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'YV.1.$v', 1, v, sk, en, label);
  }
  print('  ✓ Kanda 1: ${verses.length} verses');
  return verses.length;
}

int _seedKanda2(Database db) {
  const label = 'Kanda II — Soma Sacrifice';
  final verses = [
    (1, 'सोमं राजानमवसे। हुवेम शर्मयाचिषे। स नः पर्षदति द्विषः।',
     'We call King Soma to our aid for shelter and protection. May he drive away our foes.'),
    (7, 'त्वमग्ने राजसि प्रति। विश्वान् देवान् वश अनु। त्वं यज्ञेषु जागृहि।',
     'Thou, Agni, rulest over all. The gods are in thy power. Be thou wakeful in the sacrifices.'),
    (13, 'अग्निर्मूर्धा दिवः ककुत्। पतिः पृथिव्या अयम्। अपां रेतांसि जिन्वति।',
     'Agni is the head of heaven, the lord of this earth. He quickens the seeds of the waters.'),
    (19, 'यदग्ने स्यामहं त्वं त्वं वा घा स्या अहम्। स्युष्टे सत्या इहाशिषः।',
     'If, O Agni, I were thou, and thou wert I — may thy true blessings be here for me.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'YV.2.$v', 2, v, sk, en, label);
  }
  print('  ✓ Kanda 2: ${verses.length} verses');
  return verses.length;
}

int _seedKanda3(Database db) {
  const label = 'Kanda III — The Satarudriya';
  final verses = [
    (1, 'नमस्ते रुद्र मन्यव उतो त इषवे नमः। बाहुभ्यामुत ते नमः।',
     'Reverence to thy wrath, O Rudra, and to thy arrow reverence. Reverence to thy two arms.'),
    (2, 'या ते रुद्र शिवा तनूरघोराऽपापकाशिनी। तया नस्तनुवा शन्तमया गिरिशन्ताभिचाकशीहि।',
     'That form of thine, O Rudra, which is auspicious, not terrible, showing no evil — with that most benign form, O Lord of the mountain, look upon us.'),
    (5, 'नमो अस्तु नीलग्रीवाय सहस्राक्षाय मीढुषे। अथो ये अस्य सत्वानोऽहं तेभ्योऽकरन्नमः।',
     'Reverence to the blue-throated, thousand-eyed, showerer of blessings. And to those who are his followers I render homage.'),
    (8, 'नमः सोमाय च रुद्राय च। नमस्ताम्राय चारुणाय च। नमः शङ्गाय च पशुपतये च।',
     'Reverence to Soma and to Rudra. Reverence to the copper-red and to the ruddy. Reverence to the blessed one and to the Lord of cattle — Pashupati.'),
    (11, 'नमो भवाय च रुद्राय च। नमः शर्वाय च पशुपतये च। नमो नीलग्रीवाय च शितिकण्ठाय च।',
     'Reverence to Bhava and to Rudra. Reverence to the destroyer and to the Lord of cattle. Reverence to the blue-throated and to the white-throated.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'YV.3.$v', 3, v, sk, en, label);
  }
  print('  ✓ Kanda 3 (Satarudriya): ${verses.length} verses');
  return verses.length;
}
