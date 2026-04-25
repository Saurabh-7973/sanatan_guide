import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) { print('❌ DB not found'); exit(1); }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'samaveda'");
    int total = 0;
    total += _seedPrapathaka1(db);
    total += _seedPrapathaka2(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Samaveda seeding complete');
    print('   Total verses : $total');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) { db.execute('ROLLBACK'); rethrow; } finally { db.dispose(); }
}

void _insert(Database db, String id, int ch, int v, String sk, String en, String label) {
  db.execute('''INSERT OR REPLACE INTO verses (
    id, scripture, chapter_num, verse_num, sanskrit, english,
    chapter_label, translation, is_bookmarked, read_count, created_at
  ) VALUES (?, 'samaveda', ?, ?, ?, ?, ?, 'griffith', 0, 0, ?)''',
  [id, ch, v, sk, en, label, DateTime.now().millisecondsSinceEpoch]);
}

int _seedPrapathaka1(Database db) {
  const label = 'Prapathaka I — Agni';
  final verses = [
    (1, 1, 'अग्न आ याहि वीतये गृणानो हव्यदातये। नि होता सत्सि बर्हिषि॥',
     'Come, Agni, praised with song, to feast and solemn rite. Sit as Hotar on the sacred grass.'),
    (1, 2, 'स नो वेदभिरा गहि स्मद्दिष्टिभिरुत्तमः। अग्ने विश्वेभिः स्वाध्वरः॥',
     'Come to us, O Agni, with thy knowledge and with thy best gifts. Thou art skilled in every rite.'),
    (1, 3, 'रायस्पोषं सुवीर्यं दिवो न स्तनयित्नुना। वाजस्य नो मघवत्तम॥',
     'As thunder from the sky, bring us abundance and heroic strength. Thou art the most bounteous for wealth.'),
    (2, 1, 'उप त्वाग्ने दिवेदिवे दोषावस्तर्धिया वयम्। नमो भरन्त एमसि॥',
     'Day after day to thee, O Agni, we approach with reverent thought. Bringing obeisance we draw near.'),
    (2, 2, 'राजन्तमध्वराणां गोपामृतस्य दीदिविम्। वर्धमानं स्वे दमे॥',
     'The King of sacrifice, the guardian of truth, the bright one, growing in his own dwelling.'),
    (2, 3, 'स नः पितेव सूनवेऽग्ने सूपायनो भव। सचस्वा नः स्वस्तये॥',
     'Be easy of approach to us as a father to his son. Agni, be with us for our good.'),
  ];
  for (final (ch, v, sk, en) in verses) {
    _insert(db, 'SV.1.$ch.$v', ch, v, sk, en, label);
  }
  print('  ✓ Prapathaka 1: ${verses.length} verses');
  return verses.length;
}

int _seedPrapathaka2(Database db) {
  const label = 'Prapathaka II — Soma and Indra';
  final verses = [
    (3, 1, 'इन्द्राय सोमं पिबतु। इन्द्रस्य सोमः पीतये। इन्द्रो वृत्रं जघान।',
     'Let Indra drink the Soma. Soma is to be drunk by Indra. Indra slew Vritra.'),
    (3, 2, 'पवस्व सोम धारया। इन्द्राय पिबतु। स्वाहा।',
     'Flow, Soma, with thy stream. Let Indra drink. Svaha.'),
    (4, 1, 'सोम देव पिबतु। इन्द्रो वृद्धश्रवास्तव। अमृतस्य च राजसि।',
     'Let the divine Soma drink. Indra of growing fame is thine. Thou art the king of immortality.'),
    (4, 2, 'आ त्वा ससृज्महे गिरः। इन्द्र ज्येष्ठं न आ वह। वाजेषु चित्रं राधसे।',
     'We send these songs to thee. O Indra bring the best to us. Thou art wondrous in thy gifts.'),
    (5, 1, 'ओ३म् आ नो नियुद्भिः सत्पतिर्मदाय। सुतस्य पीतये।',
     'OM — may the lord of truth come to our joy and to the drinking of the pressed Soma.'),
    (5, 2, 'इमे सोमाः सुताः। इन्द्राय पातवे। स्वाहा विश्वे देवाः।',
     'These Somas are pressed. For Indra to drink. Svaha — all-divine.'),
  ];
  for (final (ch, v, sk, en) in verses) {
    _insert(db, 'SV.2.$ch.$v', ch, v, sk, en, label);
  }
  print('  ✓ Prapathaka 2: ${verses.length} verses');
  return verses.length;
}
