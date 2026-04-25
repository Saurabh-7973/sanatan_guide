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
    db.execute("DELETE FROM verses WHERE scripture = 'prashna_upanishad'");
    int total = 0;
    total += _seedPrashna1(db);
    total += _seedPrashna2(db);
    total += _seedPrashna3(db);
    total += _seedPrashna4(db);
    total += _seedPrashna5(db);
    total += _seedPrashna6(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Prashna Upanishad seeding complete');
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
    ) VALUES (?, 'prashna_upanishad', ?, ?, ?, ?, ?, 'muller', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedPrashna1(Database db) {
  const label = 'Prashna I — The Origin of Creation';
  final verses = [
    (1, 'सुकेशा च भारद्वाजः शैब्यश्च सत्यकामः सौर्यायणी च गार्ग्यः कौसल्यश्चाश्वलायनो भार्गवो वैदर्भिः कबन्धी कात्यायनस्ते हैते ब्रह्मपरा ब्रह्मनिष्ठाः परं ब्रह्मान्वेषमाणा एष ह वै तत्सर्वं वक्ष्यतीति ते ह समित्पाणयो भगवन्तं पिप्पलादमुपसन्नाः।',
     'Sukesa the son of Bharadvaja, Satyakama the son of Sibi, Sauryayani the son of Garga, Kausalya the son of Asvalayana, Bhargava of Vidarbha, and Kabandhi the son of Katya — all these, devoted to Brahman, intent on Brahman, seeking the highest Brahman, approached the Bhagavat Pippalada with fuel in hand.'),
    (2, 'तान्ह स ऋषिरुवाच भूय एव तपसा ब्रह्मचर्येण श्रद्धया संवत्सरं संवत्स्यथ। यथाकामं प्रश्नान्पृच्छत। यदि विज्ञास्यामः सर्वं ह वो वक्ष्याम इति।',
     'The sage said to them: Dwell with me for a year more, with austerity, chastity, and faith. Then ask whatever questions you wish. If we know, we shall tell you everything.'),
    (4, 'सोऽकामयत। रयिश्च प्राणश्च द्वे इत्यभिध्यायत। प्राणो वा आदित्यः। रयिरेव चन्द्रमाः।',
     'He desired, and meditated on two — Rayi (matter) and Prana (spirit). The sun is indeed Prana; the moon is indeed Rayi.'),
    (8, 'संवत्सरो वा एष प्रजापतिः। तस्य दक्षिणश्च उत्तरश्च मार्गौ। तद्वा एते इष्टापूर्ते कृतमिति दक्षिणं मार्गमनुयन्ति। ते पितृलोकमेवाभिसंपद्यन्ते।',
     'The year is Prajapati. Its southern and northern paths — those who follow the southern path by sacrifices and pious works go to the world of the fathers.'),
    (10, 'अथोत्तरेण तपसा ब्रह्मचर्येण श्रद्धया विद्ययाऽऽत्मानमन्विष्य। आदित्यमभिजयन्ते।',
     'But those who seek the Self by austerity, chastity, faith, and knowledge — they go beyond by the northern path, to the sun — to liberation.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'PU.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prashna 1: ${verses.length} verses');
  return verses.length;
}

int _seedPrashna2(Database db) {
  const label = 'Prashna II — The Supremacy of Prana';
  final verses = [
    (1, 'अथ हैनं भार्गवो वैदर्भिः पप्रच्छ। भगवन् कत्येव देवाः प्रजां विधारयन्ते। कतर एतत्प्रकाशयन्ते। कः पुनरेषां वरिष्ठ इति।',
     'Then Bhargava of Vidarbha asked him: O Bhagavat, how many gods support a creature? Who among them gives light? And who is the greatest of them?'),
    (2, 'तस्मै स होवाच। आकाशो ह वा एष देवो वायुरग्निरापः पृथिवी वाङ्मनश्चक्षुः श्रोत्रं च। ते प्रकाशाभिमानिनः प्राणमूचुः।',
     'He said to him: Ether, wind, fire, water, earth, speech, mind, eye, and ear — all these, being proud of their light, said to Prana —'),
    (3, 'वयमेतद्बाणमवष्टभ्य विधारयामः इति। तान्होवाच प्राणः। मा मोहमापद्यध्वं। अहमेवैतत्पञ्चधाऽऽत्मानं प्रविभज्य एतद्बाणमवष्टभ्य विधारयामीति। ते श्रद्धां न मेनिरे।',
     '"We, supporting this body, hold it up." Prana said to them: "Do not be deluded. I alone, dividing myself fivefold, support this body." They did not believe him.'),
    (6, 'यथा मधुकरराजो उत्क्रामति उत्क्रामन्ते सर्वे यदि नावर्तते। तथैव वाक् तथा चक्षुः तथा श्रोत्रं तथा मनः।',
     'As when a king bee departs all the bees depart with him, so when Prana departs, all the other breaths depart. And when it returns, all return.'),
    (11, 'एष हि वैश्वानरो विश्वरूपः प्राणोऽग्निरुदयते। तदेतदृचाभ्युक्तम्।',
     'For this Prana is Vaishvanara — the universal fire that rises as the sun. Of this the Rik text has spoken.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'PU.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prashna 2: ${verses.length} verses');
  return verses.length;
}

int _seedPrashna3(Database db) {
  const label = 'Prashna III — The Origin and Nature of Prana';
  final verses = [
    (1, 'अथ हैनं कौसल्यश्चाश्वलायनः पप्रच्छ। भगवन् कुत एष प्राणो जायते। कथमायात्यस्मिञ्छरीरे। आत्मानं वा प्रविभज्य कथं प्रतिष्ठते। केनोत्क्रामति। कथं बाह्यमभिधत्ते। कथमध्यात्ममिति।',
     'Then Kausalya the son of Asvalayana asked: O Bhagavat, from where is this Prana born? How does it come into this body? How does it establish itself, dividing itself? How does it depart? How does it support the outer world? How does it support the inner world?'),
    (3, 'आत्मन एष प्राणो जायते। यथाऽऽयैव पुरुषे छायैतस्मिन्नेतदाततं। मनोकृतेनायात्यस्मिञ्छरीरे।',
     'This Prana is born from the Self. As a shadow is cast by a man, so this Prana is spread in the body. By the action of the mind it comes into this body.'),
    (5, 'अपानो गुदोपस्थे। प्राण एव तु चक्षुःश्रोत्रे मुखनासिकाभ्यां। मध्ये तु समानः। एष ह्येव नेता एतं यज्ञं समनयत्येतैश्च हव्यैः।',
     'Apana is in the organs of excretion. Prana itself is in the eye and ear, mouth and nose. In the middle is Samana — it is the carrier that equally distributes what is offered in sacrifice.'),
    (9, 'न हि प्राणो न न अपानः स्वपिति। देवा एवैनं एतस्मिन्पुरे जाग्रन्ति।',
     'In sleep, Prana and Apana do not sleep — the gods alone watch in this city of the body.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'PU.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prashna 3: ${verses.length} verses');
  return verses.length;
}

int _seedPrashna4(Database db) {
  const label = 'Prashna IV — Sleep, Dream, and the Self';
  final verses = [
    (1, 'अथ हैनं सौर्यायणी गार्ग्यः पप्रच्छ। भगवन् एतस्मिन्पुरुषे कानि स्वपन्ति। कान्यस्मिन् जाग्रति। कतर एष देवः स्वप्नान्पश्यति। कस्यैतत्सुखं भवति। कस्मिन्नु सर्वे सम्प्रतिष्ठन्ते इति।',
     'Then Sauryayani the son of Garga asked: O Bhagavat, which powers sleep in this person? Which remain awake? Which god sees dreams? Whose is this happiness? In whom do all things rest?'),
    (2, 'तस्मै स होवाच। यथा गार्ग्य मरीचयोऽर्कस्यास्तं गच्छतः सर्वा एतस्मिन्तेजोमण्डल एकीभवन्ति। ताः पुनः पुनरुदयतः प्रभवन्ति। एवं हु वै तत्सर्वं परे देवे मनस्येकीभवति।',
     'He said: As the rays of the sun, O Garga, at its setting all become one in the disc of light, and they spring forth again when it rises — so all these become one in the supreme god Mind.'),
    (5, 'स यदा तेजसा अभिभूतो भवति अत्र एष देवः स्वप्नान्न पश्यति। अथ यदैतस्मिञ्छरीरे सुखं भवति।',
     'When he is overcome by light — that is, in deep sleep — this god sees no dreams. Then in this body there is happiness.'),
    (6, 'स यथा सोम्य विहंगमः वृक्षं प्रत्यश्रयते। एवं हु वै तत्सर्वं पर आत्मनि प्रत्यवैति।',
     'As a bird, O friend, rests in a tree, so all this rests in the supreme Self.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'PU.4.$v', chapter: 4, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prashna 4: ${verses.length} verses');
  return verses.length;
}

int _seedPrashna5(Database db) {
  const label = 'Prashna V — Meditation on OM';
  final verses = [
    (1, 'अथ हैनं शैब्यः सत्यकामः पप्रच्छ। स यो ह वाव भगवन् मनुष्येषु प्राय आमरणान्तं ओमित्येतदक्षरं ध्यायीत। कतमं हि वावैतेन लोकं जयतीति।',
     'Then Satyakama the son of Sibi asked: O Bhagavat, if among men someone meditates on the syllable OM until the end of his life — which world does he win thereby?'),
    (2, 'तस्मै स होवाच। एतद्वै सत्यकाम परं चापरं च ब्रह्म यदोंकारः। तस्माद्विद्वानेतेनैवायतनेनैकतरमन्वेति।',
     'He said: Satyakama, this syllable OM is indeed both the higher and the lower Brahman. Therefore the knowing man attains either of the two with this support alone.'),
    (5, 'अथ यदि त्रिमात्रेणैव ओमित्येतेनैवाक्षरेण परं पुरुषमभिध्यायीत। स तेजसि सूर्ये संपन्नः। यथा पादोदरस्त्वचा विनिर्मुच्यते। एवं हासौ पाप्मना विनिर्मुक्तः।',
     'But if he meditates on the highest Person with the three-matred OM — he is united with the light of the sun. As a snake is freed from its skin, so he is freed from sin.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'PU.5.$v', chapter: 5, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prashna 5: ${verses.length} verses');
  return verses.length;
}

int _seedPrashna6(Database db) {
  const label = 'Prashna VI — The Person of Sixteen Parts';
  final verses = [
    (1, 'अथ हैनं सुकेशा भारद्वाजः पप्रच्छ। भगवन् हिरण्यनाभः कौसल्यो राजपुत्रो मामुपेत्य एतं प्रश्नमपृच्छत। षोडशकलं भारद्वाज पुरुषं वेत्थेति। तमहं कुमारमब्रुवम्। नाहमिमं वेद। यद्यहमिमं अवेदिषं कथं ते न अवक्ष्यमिति।',
     'Then Sukesa the son of Bharadvaja asked: O Bhagavat, Hiranyabha the prince of Kosala came to me and asked me: "Bharadvaja, do you know the Person of sixteen parts?" I said to the prince: "I do not know him. Had I known him, how should I not have told you?"'),
    (2, 'स मूलमेव वृक्षमभ्यपद्यत। तस्मा एष प्रश्नो नोपसरति इति। एतद्विद्वान्सोऽस्माल्लोकात्प्रैति।',
     'He who does not know the root — he is uprooted. Therefore this question did not come to me. He who knows this departs from this world.'),
    (4, 'तस्मिन्नु भगवन् प्राणाः प्रतिष्ठिताः।',
     'In him, O Bhagavat, the Pranas are established.'),
    (5, 'आकाशो वायुर्ज्योतिरापः पृथिवीन्द्रियं मनोऽन्नं वीर्यं तपो मन्त्राः कर्म लोका नाम च। एता हि षोडशकलाः पुरुषस्येति।',
     'Ether, wind, light, water, earth, sense, mind, food, strength, austerity, mantra, action, world, and name — these are the sixteen parts of the Person.'),
    (6, 'यथा इमाः सर्वाः प्रजाः एकः पुरुषे संयन्ति। एवमेव सर्वाणि भूतानि एकस्मिन्पुरुषे प्रयन्ति। स वा एष सेतुर्विधरणः एषां लोकानामसंभेदाय।',
     'As all rivers flow into the ocean — so all these sixteen parts flow into the one Person. That Person is the bridge, the support — maintaining these worlds without confusion.'),
    (7, 'तं म एतं पुरुषमिति प्रोवाच। इह एव अन्तःशरीरे अयं पुरुषो यस्मिन् एताः षोडशकलाः प्रभवन्ति।',
     'He told me: That Person — here, within the body itself, is that Person in whom these sixteen parts arise.'),
    (8, 'ते देवाः पिप्पलादमभिप्रणम्योचुः। त्वं हि नः पिता। योऽस्माकमविद्याया परं पारं तारयसि।',
     'The gods bowed to Pippalada and said: Thou art our father — thou who ferries us across from ignorance to the further shore.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'PU.6.$v', chapter: 6, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Prashna 6: ${verses.length} verses');
  return verses.length;
}
