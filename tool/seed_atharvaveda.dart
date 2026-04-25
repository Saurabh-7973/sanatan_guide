import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) { print('❌ DB not found'); exit(1); }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'atharvaveda'");
    int total = 0;
    total += _seedKanda1(db);
    total += _seedKanda2(db);
    total += _seedKanda3(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Atharvaveda seeding complete');
    print('   Total verses : $total');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) { db.execute('ROLLBACK'); rethrow; } finally { db.dispose(); }
}

void _insert(Database db, String id, int ch, int v, String sk, String en, String label) {
  db.execute('''INSERT OR REPLACE INTO verses (
    id, scripture, chapter_num, verse_num, sanskrit, english,
    chapter_label, translation, is_bookmarked, read_count, created_at
  ) VALUES (?, 'atharvaveda', ?, ?, ?, ?, ?, 'griffith', 0, 0, ?)''',
  [id, ch, v, sk, en, label, DateTime.now().millisecondsSinceEpoch]);
}

int _seedKanda1(Database db) {
  const label = 'Kanda I — Healing and Protection';
  final verses = [
    (1, 'येऽनया दिव्या ओषधयः। पृथिवीमनुसंचरन्ति। तासां त्वमसि राजनी। मयि तुष्टिं परा वह।',
     'The divine herbs that roam over the earth following this path — thou art their queen. Bring us satisfaction.'),
    (4, 'भेषजं ते दधामि। ब्रह्मणा सह तिष्ठ। अजरामरं जीवसे।',
     'I place medicine in thee. Stand firm with the Brahman. Live free from old age and death.'),
    (7, 'पृथिवी माता मे। द्यौः पिता मे। अग्निर्मे भ्राता। अनुशासन देव।',
     'Earth is my mother. Heaven is my father. Agni is my brother. The gods give instruction.'),
    (13, 'उदयन्त्सूर्यः सर्वान् भूतान् उद्धरतु। उदयन् ब्रह्म उद्धरतु। उदयन्तो राशयः।',
     'May the rising sun lift up all beings. May the rising Brahman lift them up. May the rising rays uplift.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'AV.1.$v', 1, v, sk, en, label);
  }
  print('  ✓ Kanda 1: ${verses.length} verses');
  return verses.length;
}

int _seedKanda2(Database db) {
  const label = 'Kanda II — Hymns of Power and Blessing';
  final verses = [
    (1, 'यत्र ब्रह्म च क्षत्रं च संयञ्चाव् चरतस्तु। तन्म इन्द्रो दधातु।',
     'Where Brahman and Kshatriya move in harmony — may Indra grant me that.'),
    (12, 'मित्रस्य चर्षणीधृतो। श्रवो देवस्य सानसिम्। सत्यं चित्रश्रवस्तमम्।',
     'Of Mitra, sustainer of men, may we win the glory of the divine — the true, most wondrous fame.'),
    (15, 'ब्रह्मणस्पते त्वमस्मासु द्रविणं धेहि। चित्राभिरूती नवेदो अद्भुतः।',
     'O Brihaspati, place wealth in us — thou wonderful, full of new knowledge, with wondrous aids.'),
    (28, 'आयुष्मान् भव। सौम्यो भव। वीरपत्नी भव। यशस्विनी भव। प्रजावती भव।',
     'Be long-lived. Be of gentle nature. Be the wife of a hero. Be glorious. Be blessed with children.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'AV.2.$v', 2, v, sk, en, label);
  }
  print('  ✓ Kanda 2: ${verses.length} verses');
  return verses.length;
}

int _seedKanda3(Database db) {
  const label = 'Kanda III — The Earth and Cosmos';
  final verses = [
    (1, 'माता भूमिः पुत्रोऽहं पृथिव्याः। पर्जन्यः पिता स उ नः पिपर्तु।',
     'The earth is my mother, I am her son. Parjanya is my father — may he fill us with life. (The most famous verse of the Atharvaveda — Bhumi Sukta)'),
    (6, 'यत्तेऽस्ति पृथिवि भूम्यां यस्यां वनस्पतिभिः। यां पुष्पिणीमोषधयः प्रावृषा संविशन्ति।',
     'Whatever of thine is in the earth, O earth — thy plants, the herbs that in the rainy season grow in flower.'),
    (11, 'विश्वम्भरा वसुधानी प्रतिष्ठा। हिरण्यवक्षा जगतो निवेशनी। वैश्वानरं बिभ्रती भूमिरग्निम्।',
     'The all-sustaining earth that bears wealth, the foundation of all, the golden-breasted — she who is the dwelling place of the world, who bears Vaishvanara the universal fire.'),
    (17, 'सत्यं बृहद्ऋतमुग्रं दीक्षा तपो ब्रह्म यज्ञः पृथिवीं धारयन्ति। सा नो भूतस्य भव्यस्य पत्न्युरुं लोकं पृथिवी नः कृणोतु।',
     'Truth, greatness, universal order, strength, consecration, austerity, spiritual power, and sacrifice — these sustain the earth. May she, the mistress of the past and future, make a wide world for us.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'AV.3.$v', 3, v, sk, en, label);
  }
  print('  ✓ Kanda 3 (Bhumi Sukta): ${verses.length} verses');
  return verses.length;
}
