import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) { print('❌ DB not found'); exit(1); }
  final db = sqlite3.open(dbPath);
  try {
    db.execute('BEGIN');
    db.execute("DELETE FROM verses WHERE scripture = 'vishnu_purana'");
    int total = 0;
    total += _seedAmsha1(db);
    total += _seedAmsha2(db);
    total += _seedAmsha3(db);
    total += _seedAmsha4(db);
    total += _seedAmsha5(db);
    total += _seedAmsha6(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Vishnu Purana seeding complete');
    print('   Total verses : $total');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } catch (e) { db.execute('ROLLBACK'); rethrow; } finally { db.dispose(); }
}

void _insert(Database db, String id, int ch, int v, String sk, String en, String label) {
  db.execute('''INSERT OR REPLACE INTO verses (
    id, scripture, chapter_num, verse_num, sanskrit, english,
    chapter_label, translation, is_bookmarked, read_count, created_at
  ) VALUES (?, 'vishnu_purana', ?, ?, ?, ?, ?, 'wilson', 0, 0, ?)''',
  [id, ch, v, sk, en, label, DateTime.now().millisecondsSinceEpoch]);
}

int _seedAmsha1(Database db) {
  const label = 'Amsha I — Creation';
  final verses = [
    (1, 'मैत्रेय उवाच। भगवन् सर्वभूतानां यत्कारणं परमम्। यस्मिन्नेव समुत्पन्नं यत्र लीयते जगत्॥',
     'Maitreya said: O Bhagavan, what is the supreme cause of all beings? From what does the world arise? Into what does it dissolve?'),
    (2, 'पराशर उवाच। विष्णोः प्रसादात् सर्वज्ञ श्रृणु तत्त्वेन मैत्रेय। यस्मिन् सर्वमिदं प्रोतं जगद् व्यक्ताव्यक्तात्मकम्॥',
     'Parashara said: By the grace of Vishnu, O all-knowing Maitreya, hear the truth. In him is this entire universe strung — both the manifest and the unmanifest.'),
    (3, 'ॐ नमो भगवते वासुदेवाय। सर्वभूताधिवासाय। विष्णवे परमात्मने।',
     'OM. Salutation to the Bhagavat Vasudeva, the dweller in all beings, Vishnu, the supreme Self.'),
    (4, 'अव्यक्तात् व्यक्तमुत्पन्नं महदादि विशेषान्तम्। एतत् सर्वं जगद् विष्णोः शक्त्या मायया समुत्थितम्॥',
     'From the unmanifest came the manifest — from Mahat down to the specific elements. All this universe arose through the power and Maya of Vishnu.'),
    (5, 'यतो विश्वमिदं सर्वं यत्र चैव प्रलीयते। यस्य शक्तिर्जगत् सर्वं स विष्णुः परमेश्वरः॥',
     'From whom this entire universe proceeds, into whom it dissolves, whose power is all the world — he is Vishnu, the supreme Lord.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'VP.1.$v', 1, v, sk, en, label);
  }
  print('  ✓ Amsha 1: ${verses.length} verses');
  return verses.length;
}

int _seedAmsha2(Database db) {
  const label = 'Amsha II — Cosmology';
  final verses = [
    (1, 'पृथिव्यां सप्त द्वीपानि सप्त सागराः। द्वीपानां वर्षाणि सप्त सप्त पर्वताः।',
     'On the earth are seven continents and seven seas. Each continent has seven regions and seven mountains.'),
    (4, 'भारतं प्रथमं वर्षं ततः किम्पुरुषं स्मृतम्। हरिवर्षं तथैवान्यत् त्रिकूटं मेरुमेव च।',
     'Bharata is the first region, then Kimpurusha, then Harivarsha, then Trikuta, and Meru itself.'),
    (8, 'एतस्मिन् भारतवर्षे कर्मभूमिरियं मता। इह कर्माणि कृत्वैव तत्फलं लभते नरः॥',
     'In this Bharatavarsha, this is known as the land of action. Here a man, having performed actions, obtains their fruits.'),
    (12, 'सप्तद्वीपसमाकीर्णा भूमिर्जम्बूसमन्विता। समुद्रैः सप्तभिश्चापि वेष्टिता परमेश्वर।',
     'The earth is encompassed by seven continents and Jambu-dvipa. It is surrounded by seven oceans, O Supreme Lord.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'VP.2.$v', 2, v, sk, en, label);
  }
  print('  ✓ Amsha 2: ${verses.length} verses');
  return verses.length;
}

int _seedAmsha3(Database db) {
  const label = 'Amsha III — Dharma and the Vedas';
  final verses = [
    (1, 'वेदव्यासः कृतो येन विभक्तो वेदसागरः। चतुर्धा व्यस्तमन्वेव येन वेदार्थदर्शिना॥',
     'By Vedavyasa the ocean of the Vedas was divided. He who saw the meaning of the Vedas divided them fourfold.'),
    (4, 'ऋग्वेदो यजुर्वेदः सामवेदोऽथर्वणः। चत्वारो वेदा इत्येते व्यासेन विहिताः स्वयम्॥',
     'Rigveda, Yajurveda, Samaveda, and Atharvaveda — these four Vedas were arranged by Vyasa himself.'),
    (7, 'धर्मस्य लक्षणं ब्रूहि यस्मिन् विश्वं प्रतिष्ठितम्। किं ज्ञानेन किं तपसा किं यज्ञेन मुच्यते॥',
     'Tell me the mark of Dharma in which the universe is established. By what knowledge, by what austerity, by what sacrifice is one liberated?'),
    (9, 'वेदप्रोक्तो धर्म एव सत्यं ब्रह्म सनातनम्। विष्णुर्एव जगत्सर्वं विष्णुरेव परं पदम्॥',
     'Dharma declared by the Vedas is the eternal truth, the eternal Brahman. Vishnu alone is all the world. Vishnu alone is the supreme state.'),
    (15, 'श्रेयस्कामो मनुष्यः स्यात् सर्वदा विष्णुभक्तिमान्। विष्णुभक्तिः परा ज्ञेया संसारभयनाशिनी॥',
     'A man who desires welfare should always be devoted to Vishnu. Vishnu-bhakti is the highest — known as the destroyer of the fear of worldly existence.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'VP.3.$v', 3, v, sk, en, label);
  }
  print('  ✓ Amsha 3: ${verses.length} verses');
  return verses.length;
}

int _seedAmsha4(Database db) {
  const label = 'Amsha IV — Dynasties of Kings';
  final verses = [
    (1, 'सूर्यवंशे महाराजन् ये भूपा इक्ष्वाकवः। मनोर्वैवस्वतस्यापि पुत्राः षट् षष्टिरेव च॥',
     'In the Solar dynasty, O great king, the Ikshvaku kings — the sons of Manu Vaivasvata — were sixty-six in number.'),
    (2, 'इक्ष्वाकुर्मनुपुत्रोऽभूत् तस्मात् विकुक्षिरुत्तमः। ततः पुरञ्जयश्चाभूत् काकुत्स्थस्तस्य नामतः॥',
     'Ikshvaku was the son of Manu. From him came Vikukshi the Uttama. Then came Puranjaya, who was also known as Kakutstha.'),
    (4, 'ततो रघुः समभवत् रघोस्तु दीर्घबाहुः। रघोस्तु सुदर्शनश्चापि अजस्तस्मात् प्रसूयत॥',
     'From him came Raghu. From Raghu came Dirghabahu. From Raghu came Sudarshana. From him was born Aja.'),
    (6, 'अजस्य दशरथो भूत् दशरथस्य रामचन्द्रः। रामश्चन्द्रः परब्रह्म साक्षाद् विष्णुः सनातनः॥',
     'From Aja came Dasharatha. From Dasharatha came Ramachandra. Ramachandra is the supreme Brahman — Vishnu himself, the eternal one.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'VP.4.$v', 4, v, sk, en, label);
  }
  print('  ✓ Amsha 4: ${verses.length} verses');
  return verses.length;
}

int _seedAmsha5(Database db) {
  const label = 'Amsha V — Life of Krishna';
  final verses = [
    (1, 'वसुदेवस्य देवक्यां जज्ञे विष्णुः स्वयं हरिः। कृष्णनामा जगद्गुरुः सर्वलोकेश्वरः प्रभुः॥',
     'From Vasudeva and Devaki was born Vishnu himself — Hari. Named Krishna, the world-teacher, the lord of all worlds.'),
    (3, 'नन्दस्य गोकुले बालः पालितो यशोदया। गोपीभिः परिवेष्टितो लीलया लोकमोहनः॥',
     'In Nanda\'s Gokula, the child was raised by Yashoda. Surrounded by the Gopis, he enchanted the world with his play.'),
    (6, 'कंसं निहत्य दुर्बुद्धिं उग्रसेनं च मोचयन्। मथुरायां स्थितो देवः कृष्णो लोकहिताय वै॥',
     'Having slain the wicked Kamsa and having freed Ugrasena, the divine Krishna stood in Mathura for the welfare of the world.'),
    (9, 'भगवद्गीतां उपदिश्य अर्जुनाय महात्मने। कुरुक्षेत्रे महायुद्धे पाण्डवानां हिते स्थितः॥',
     'Having taught the Bhagavad Gita to the great-souled Arjuna, he stood for the welfare of the Pandavas in the great battle of Kurukshetra.'),
    (12, 'सर्वधर्मान् परित्यज्य मामेकं शरणं व्रज। अहं त्वां सर्वपापेभ्यो मोक्षयिष्यामि मा शुचः॥',
     'Abandoning all dharmas, take refuge in me alone. I shall liberate thee from all sins — grieve not.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'VP.5.$v', 5, v, sk, en, label);
  }
  print('  ✓ Amsha 5: ${verses.length} verses');
  return verses.length;
}

int _seedAmsha6(Database db) {
  const label = 'Amsha VI — Liberation';
  final verses = [
    (1, 'कलियुगस्य धर्माश्च लक्षणानि च मे शृणु। येन विज्ञातमात्रेण मुच्यते संसारबन्धनात्॥',
     'Hear from me the dharmas and marks of the Kali Yuga. By knowing these alone, one is freed from the bondage of worldly existence.'),
    (5, 'कलौ यज्ञस्तपस्त्यागो दानं विष्णोः स्मरणमेव च। एतानि नित्यं कुर्वाणो मुच्यते संसारतः॥',
     'In the Kali Yuga — sacrifice, austerity, renunciation, charity, and remembrance of Vishnu — performing these always, one is freed from worldly existence.'),
    (7, 'हरेर्नाम हरेर्नाम हरेर्नामैव केवलम्। कलौ नास्त्येव नास्त्येव नास्त्येव गतिरन्यथा॥',
     'The name of Hari, the name of Hari, the name of Hari alone. In the Kali age there is no other way, no other way, no other way.'),
    (8, 'विष्णुभक्तो भवेद् योगी ज्ञानी वैराग्यवान् तथा। एवं भक्त्या परं विष्णुं प्राप्नोति नान्यथा।',
     'Through devotion to Vishnu one becomes a Yogi, a Jnani, and one endowed with renunciation. Thus by bhakti one attains the supreme Vishnu — not otherwise.'),
    (9, 'सर्वं विष्णुमयं जगत्। विष्णुर्ब्रह्म विष्णुः शिवः। विष्णुरेव परं ब्रह्म। नमो विष्णवे नमः।',
     'All the world is pervaded by Vishnu. Vishnu is Brahma, Vishnu is Shiva. Vishnu alone is the supreme Brahman. Salutation to Vishnu, salutation.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, 'VP.6.$v', 6, v, sk, en, label);
  }
  print('  ✓ Amsha 6: ${verses.length} verses');
  return verses.length;
}
