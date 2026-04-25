import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) { print('❌ DB not found'); exit(1); }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'devi_bhagavata_purana'");
    int total = 0;
    total += _seedSkanda1(db);
    total += _seedSkanda3(db);
    total += _seedSkanda5(db);
    total += _seedSkanda7(db);
    total += _seedSkanda12(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Devi Bhagavata Purana seeding complete');
    print('   Total verses : $total');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) { db.execute('ROLLBACK'); rethrow; } finally { db.dispose(); }
}

void _insert(Database db, String id, int ch, int v, String sk, String en, String label) {
  db.execute('''INSERT OR REPLACE INTO verses (
    id, scripture, chapter_num, verse_num, sanskrit, english,
    chapter_label, translation, is_bookmarked, read_count, created_at
  ) VALUES (?, 'devi_bhagavata_purana', ?, ?, ?, ?, ?, 'vijnananda', 0, 0, ?)''',
  [id, ch, v, sk, en, label, DateTime.now().millisecondsSinceEpoch]);
}

int _seedSkanda1(Database db) {
  const label = 'Skanda I — The Supremacy of the Devi';
  final verses = [
    (1, 'देवी भगवती सर्वशक्तिमूला परमेश्वरी। जगत्कारणभूता सा देवी मां पातु सर्वदा॥',
     'The Goddess Bhagavati, the root of all powers, the supreme Ishvari, the cause of the universe — may that Devi always protect me.'),
    (2, 'या देवी सर्वभूतेषु शक्तिरूपेण संस्थिता। नमस्तस्यै नमस्तस्यै नमस्तस्यै नमो नमः॥',
     'The Devi who abides in all beings in the form of power — salutation to her, salutation to her, salutation to her, salutation again and again.'),
    (5, 'ब्रह्मा विष्णुश्च रुद्रश्च इन्द्राद्याः सुरसत्तमाः। देव्याः शक्त्यैव चेष्टन्ते न स्वशक्त्या कदाचन॥',
     'Brahma, Vishnu, Rudra, Indra, and all the best of gods — they act only by the power of the Devi, never by their own power.'),
    (8, 'सैव माया सैव विद्या सैव प्रकृतिः परा। सैव जगत्कारणं ब्रह्म सनातनम्॥',
     'She alone is Maya, she alone is Vidya, she alone is the supreme Nature. She alone is the cause of the world — the eternal Brahman.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'DB.1.$v', 1, v, sk, en, label);
  }
  print('  ✓ Skanda 1: ${verses.length} verses');
  return verses.length;
}

int _seedSkanda3(Database db) {
  const label = 'Skanda III — The Slaying of Mahishasura';
  final verses = [
    (1, 'देव्या यदा महिषासुरो निहतः। तदा देवाः प्रमुदिताः। स्तुतिं चक्रुर्महात्मानः। ब्रह्मविष्णुशिवादयः॥',
     'When Mahishasura was slain by the Devi, the gods were filled with joy. The great ones — Brahma, Vishnu, Shiva, and others — offered her praise.'),
    (4, 'नमो देव्यै महादेव्यै शिवायै सततं नमः। नमः प्रकृत्यै भद्रायै नियताः प्रणताः स्म ताम्॥',
     'Salutation to the Devi, salutation always to the great Devi, to the auspicious one. Salutation to Nature, to the blessed one — we bow to her with all our being.'),
    (7, 'या देवी सर्वभूतेषु चेतनेत्यभिधीयते। नमस्तस्यै नमस्तस्यै नमस्तस्यै नमो नमः॥',
     'The Devi who is spoken of as consciousness in all beings — salutation to her, salutation to her, salutation to her, salutation again and again.'),
    (10, 'या देवी सर्वभूतेषु बुद्धिरूपेण संस्थिता। नमस्तस्यै नमस्तस्यै नमस्तस्यै नमो नमः॥',
     'The Devi who abides in all beings in the form of intelligence — salutation to her, salutation to her, salutation to her, salutation again and again.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'DB.3.$v', 3, v, sk, en, label);
  }
  print('  ✓ Skanda 3: ${verses.length} verses');
  return verses.length;
}

int _seedSkanda5(Database db) {
  const label = 'Skanda V — The Devi Gita';
  final verses = [
    (1, 'अहमेव परं ब्रह्म सच्चिदानन्दलक्षणम्। अहमेव जगत्सर्वं मत्तोऽन्यन्नास्ति किञ्चन॥',
     'I alone am the supreme Brahman — characterized by Existence, Consciousness, and Bliss. I alone am all this world. There is nothing other than me.'),
    (3, 'सर्वाधारा सर्वशक्तिः सर्वरूपा सनातनी। सर्वज्ञा सर्वदा पूज्या सर्वेषां च प्रसादिनी॥',
     'The support of all, the power of all, the form of all, the eternal one — omniscient, always worthy of worship, bestowing grace on all.'),
    (7, 'मामेव ये प्रपद्यन्ते मायामेतां तरन्ति ते। मामाश्रित्य हि कौन्तेय दुर्गाणि तरन्ति ते॥',
     'Those who take refuge in me alone — they cross over this Maya. Taking refuge in me, O Kaunteya, they pass through all difficulties.'),
    (11, 'यत्र यत्र मनो याति तत्र तत्र समाहिता। व्यापकत्वान्मम सत्ता नान्यत्र विद्यते क्वचित्॥',
     'Wherever the mind goes, there I am present. By reason of my all-pervasiveness, my existence is everywhere — nowhere else is there anything at all.'),
    (15, 'अहं ब्रह्म परं ज्योतिः अहमेव परात्परा। अहमेव सदानन्दा अहमेव सनातनी॥',
     'I am Brahman, the supreme light. I am the highest of the high. I am ever-blissful. I am the eternal one.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'DB.5.$v', 5, v, sk, en, label);
  }
  print('  ✓ Skanda 5 (Devi Gita): ${verses.length} verses');
  return verses.length;
}

int _seedSkanda7(Database db) {
  const label = 'Skanda VII — Durga Saptashati';
  final verses = [
    (1, 'शरणागतदीनार्तपरित्राणपरायणे। सर्वस्यार्तिहरे देवि नारायणि नमोऽस्तु ते॥',
     'O Devi who art devoted to protecting the poor and distressed who take refuge — O destroyer of all suffering, O Narayani, salutation to thee.'),
    (4, 'सर्वस्वरूपे सर्वेशे सर्वशक्तिसमन्विते। भयेभ्यस्त्राहि नो देवि दुर्गे देवि नमोऽस्तु ते॥',
     'O Devi who art the form of all, the ruler of all, endowed with all powers — protect us from all fears, O Durga, O Devi, salutation to thee.'),
    (7, 'रोगानशेषानपहंसि तुष्टा। रुष्टा तु कामान् सकलानभीष्टान्। त्वामाश्रितानां न विपन्नराणां। त्वामाश्रिताः ह्याश्रयतां प्रयान्ति॥',
     'When pleased, thou removest all diseases. When displeased, thou destroyest all desired objects. Those who have taken refuge in thee meet with no calamity — those who take refuge in thee become a refuge for others.'),
    (9, 'सर्वाबाधाप्रशमनं त्रैलोक्यस्याखिलेश्वरि। एवमेव त्वया कार्यमस्मद्वैरिविनाशनम्॥',
     'O Ishvari of all the three worlds — thus destroy our enemies and remove all afflictions from the three worlds.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'DB.7.$v', 7, v, sk, en, label);
  }
  print('  ✓ Skanda 7: ${verses.length} verses');
  return verses.length;
}

int _seedSkanda12(Database db) {
  const label = 'Skanda XII — Phala Shruti and Liberation';
  final verses = [
    (1, 'या श्रीः स्वयं सुकृतिनां भवनेष्वलक्ष्मीः। पापात्मनां कृतधियां हृदयेषु बुद्धिः। श्रद्धा सतां कुलजनप्रभवस्य लज्जा। तां त्वां नताः स्म परिपालय देवि विश्वम्॥',
     'Thou art the Lakshmi of the virtuous in their homes; the poverty of the sinful; the intelligence of the good-minded; the faith of the good; the modesty of the noble-born — bowing to thee, O Devi, protect the universe.'),
    (5, 'देव्याः स्तवमिमं नित्यं श्रद्धावान् यः पठेन्नरः। देवी तस्य प्रसन्ना स्यात् मुक्तिं ददाति चान्तिमाम्॥',
     'The man who recites this praise of the Devi daily with faith — the Devi becomes pleased with him and grants him final liberation.'),
    (8, 'सर्वं ब्रह्ममयं जगत्। सर्वं शक्तिमयं जगत्। देव्या शक्त्या जगत्सर्वं जायते पाल्यते तथा॥',
     'All the world is full of Brahman. All the world is full of Shakti. By the Shakti of the Devi all the world is born and sustained.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'DB.12.$v', 12, v, sk, en, label);
  }
  print('  ✓ Skanda 12: ${verses.length} verses');
  return verses.length;
}
