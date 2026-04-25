import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) { print('❌ DB not found'); exit(1); }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'markandeya_purana'");
    int total = 0;
    total += _seedChapter1(db);
    total += _seedChapter2(db);
    total += _seedChapter3(db);
    total += _seedChapter4(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Markandeya Purana seeding complete');
    print('   Total verses : $total');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) { db.execute('ROLLBACK'); rethrow; } finally { db.dispose(); }
}

void _insert(Database db, String id, int ch, int v, String sk, String en, String label) {
  db.execute('''INSERT OR REPLACE INTO verses (
    id, scripture, chapter_num, verse_num, sanskrit, english,
    chapter_label, translation, is_bookmarked, read_count, created_at
  ) VALUES (?, 'markandeya_purana', ?, ?, ?, ?, ?, 'pargiter', 0, 0, ?)''',
  [id, ch, v, sk, en, label, DateTime.now().millisecondsSinceEpoch]);
}

int _seedChapter1(Database db) {
  const label = 'Chapter I — Jaimini and the Birds';
  final verses = [
    (1, 'जैमिनिरुवाच। महाभारतमाख्यानं व्यासेन विरचितं पुरा। तत्र संशयाः केचित् वक्तव्याः भवता मम॥',
     'Jaimini said: The great narrative of the Mahabharata was composed long ago by Vyasa. In it there are certain doubts which you should resolve for me.'),
    (4, 'विन्ध्याचले महारण्ये तुण्डिलाख्ये महातपाः। ऋषिः पक्षिषु चाबद्धः सर्वज्ञानपरायणः॥',
     'In the great forest of the Vindhya mountains, in the region called Tundila, there dwelt a great ascetic sage devoted to all knowledge, who was bound among the birds.'),
    (7, 'धर्मश्चार्थश्च कामश्च मोक्षश्चैव चतुर्विधः। पुरुषार्थसमाख्याता एते स्युर्मानवैः सदा॥',
     'Dharma, Artha, Kama, and Moksha — these four are known as the Purusharthas, always to be pursued by men.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'MP.1.$v', 1, v, sk, en, label);
  }
  print('  ✓ Chapter 1: ${verses.length} verses');
  return verses.length;
}

int _seedChapter2(Database db) {
  const label = 'Chapter II — Dharma and the World Ages';
  final verses = [
    (1, 'कृते सत्ये त्रेतायां च द्वापरे कलियुगे तथा। धर्मः पादैश्चतुर्भिश्च त्रिभिश्चाभ्यधिकस्तथा॥',
     'In the Krita Yuga dharma stands on four legs; in the Treta on three; in the Dvapara on two; in the Kali Yuga it stands on one alone.'),
    (4, 'कलौ पापरता मर्त्याः पापमेव प्रवर्धते। धर्मस्यावसरो नास्ति पापं सर्वत्र दृश्यते॥',
     'In the Kali age, mortals are devoted to sin. Sin alone grows. There is no room for dharma. Sin is seen everywhere.'),
    (7, 'कलौ संकीर्तनं मुख्यं तपसां तपसां परम्। दानं दानं परं चापि विष्णोः स्मरणमेव च॥',
     'In the Kali age, kirtan is primary among austerities. Charity is the supreme. And the remembrance of Vishnu is the highest of all.'),
    (11, 'न देशकालनियमः नाशौचनियमस्तथा। केवलं विष्णुभक्त्यैव मुच्यते संसारतः॥',
     'There is no restriction of place or time, no restriction of purity. By Vishnu-bhakti alone one is freed from worldly existence.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'MP.2.$v', 2, v, sk, en, label);
  }
  print('  ✓ Chapter 2: ${verses.length} verses');
  return verses.length;
}

int _seedChapter3(Database db) {
  const label = 'Chapter III — The Devi Mahatmya (Chandi Path)';
  final verses = [
    (1, 'नमो देव्यै महादेव्यै शिवायै सततं नमः। नमः प्रकृत्यै भद्रायै नियताः प्रणताः स्म ताम्॥',
     'Salutation to the Devi, salutation always to the great Devi, to the auspicious one. Salutation to Nature, to the blessed one — we bow to her with all our being.'),
    (4, 'सर्वमङ्गलमाङ्गल्ये शिवे सर्वार्थसाधिके। शरण्ये त्र्यम्बके गौरि नारायणि नमोऽस्तु ते॥',
     'O thou who art the most auspicious of all auspicious things, O Shiva who accomplishest all objectives, O thou who art the refuge of all, O three-eyed Gauri, O Narayani — salutation to thee.'),
    (7, 'सृष्टिस्थितिविनाशानां शक्तिभूते सनातनि। गुणाश्रये गुणमये नारायणि नमोऽस्तु ते॥',
     'O eternal one, who art the power behind creation, preservation, and destruction — O Narayani who art the abode of the gunas and consistest of the gunas — salutation to thee.'),
    (11, 'शरणागतदीनार्तपरित्राणपरायणे। सर्वस्यार्तिहरे देवि दुर्गे देवि नमोऽस्तु ते॥',
     'O Devi devoted to protecting the poor and afflicted who seek refuge — O Devi who removest all suffering, O Durga, O Devi — salutation to thee.'),
    (15, 'एतत्ते वदनं सौम्यं लोचनत्रयभूषितम्। पातु नः सर्वभीतिभ्यः कात्यायनि नमोऽस्तु ते॥',
     'This thy gentle face adorned with three eyes — may it protect us from all fears, O Katyayani — salutation to thee.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'MP.3.$v', 3, v, sk, en, label);
  }
  print('  ✓ Chapter 3 (Devi Mahatmya): ${verses.length} verses');
  return verses.length;
}

int _seedChapter4(Database db) {
  const label = 'Chapter IV — Markandeya and Immortality';
  final verses = [
    (1, 'मार्कण्डेय उवाच। अहं शिवस्य भक्तोऽस्मि। तेन मृत्युं जितं मया। मृत्युञ्जयो महादेवः रक्षतु मां सदा॥',
     'Markandeya said: I am devoted to Shiva. By that devotion I have conquered death. May Mritunjaya, the great God who conquers death, always protect me.'),
    (4, 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान् मृत्योर्मुक्षीय माऽमृतात्॥',
     'We worship the three-eyed Shiva who is fragrant and who nourishes all beings. May he liberate us from death as a cucumber is cut from its stalk — and not from immortality. (The Maha Mrityunjaya Mantra)'),
    (7, 'मृत्युञ्जयो जगन्नाथः शिवः शम्भुः महेश्वरः। तस्य प्रसादात् मुच्यन्ते भक्ता जन्ममृत्युतः॥',
     'Mritunjaya, lord of the world, Shiva, Shambhu, Maheshvara — by his grace the devoted are freed from birth and death.'),
    (10, 'शिवभक्तिः परा ज्ञेया मोक्षद्वारस्य कारणम्। तया विना न मोक्षोऽस्ति तया युक्तः सुखी नरः॥',
     'Shiva-bhakti is the highest — known as the cause of the door to liberation. Without it there is no liberation. A man endowed with it is happy.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'MP.4.$v', 4, v, sk, en, label);
  }
  print('  ✓ Chapter 4: ${verses.length} verses');
  return verses.length;
}
