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
    db.execute("DELETE FROM verses WHERE scripture = 'rigveda'");
    int total = 0;
    for (var i = 1; i <= 10; i++) {
      total += _seedMandala(db, i);
    }
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Rigveda seeding complete');
    print('   Total hymns : $total');
    print('   Output      : $dbPath');
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
  required int mandala,
  required int hymn,
  required String sanskrit,
  required String english,
  required String chapterLabel,
}) {
  db.execute('''
    INSERT OR REPLACE INTO verses (
      id, scripture, chapter_num, verse_num,
      sanskrit, english, chapter_label, translation,
      is_bookmarked, read_count, created_at
    ) VALUES (?, 'rigveda', ?, ?, ?, ?, ?, 'griffith', 0, 0, ?)
  ''', [
    id, mandala, hymn, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedMandala(Database db, int m) {
  final label = 'Mandala $m';
  final hymns = _hymns[m]!;
  for (final (h, sk, en) in hymns) {
    _insert(db, id: 'RV.$m.$h', mandala: m, hymn: h,
      sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Mandala $m: ${hymns.length} hymns');
  return hymns.length;
}

final Map<int, List<(int, String, String)>> _hymns = {
  1: [
    (1, 'अग्निमीळे पुरोहितं यज्ञस्य देवमृत्विजम्। होतारं रत्नधातमम्॥',
     'I laud Agni, the chosen Priest, God, minister of sacrifice, the Hotar, lavishest of wealth.'),
    (89, 'आ नो भद्राः क्रतवो यन्तु विश्वतोऽदब्धासो अपरीतास उद्भिदः। देवा नो यथा सदमिद्वृधे असन्नप्रायुवो रक्षितारो दिवेदिवे॥',
     'May powers auspicious come to us from every side, never deceived, unhindered, and victorious. May the gods be ever with us for our gain, our guardians day by day unceasing in their care.'),
    (164, 'को ददर्श प्रथमं जायमानमस्थन्वन्तं यदनस्था बिभर्ति। भूम्या असुरासृगात्मा क्व स्वित् को विद्वांसमुप गात् प्रष्टुमेतत्॥',
     'Who hath beheld him as he sprang to being, seen how the boneless one supports the bony? Where is the blood, the life, the self of nature? Who may approach the knower to ask this?'),
  ],
  2: [
    (1, 'त्वमग्ने द्युभिस्त्वमाशुशुक्षणिस्त्वमद्भ्यस्त्वमश्मनस्परि। त्वं वनेभ्यस्त्वमोषधीभ्यस्त्वं नृणां नृपते जायसे शुचिः॥',
     'Thou, Agni, shinest from the sky; thou, bright one, from the rock; thou comest forth pure from the waters, from the trees, from the herbs — thou, lord of men, art born in purity.'),
    (12, 'यो जात एव प्रथमो मनस्वान् देवो देवान् क्रतुना पर्यभूषत्। यस्य शुष्माद् रोदसी अभ्येति। स जनास इन्द्रः॥',
     'He who was born the first, the mighty-minded god who by his power encompassed the gods — he at whose roaring the two worlds trembled — he, O men, is Indra.'),
    (33, 'आ त इशान शंतम राधसोऽविवासन्तोऽविवासन्तः। रुद्र मृळय ह्वयामसि शर्म यच्छ द्विपदे चतुष्पदे।॥',
     'O Rudra, bring us from thy treasure the remedy most excellent. O Ishana, bestow on us thy most auspicious grace. Grant us shelter, shelter for the biped and the quadruped.'),
  ],
  3: [
    (1, 'इळस्पदे सुदिनत्वे अह्नां मनामहे चारु देवस्य नाम। श्रिये कृपीटयुः श्रेणिः यजत्रः। सोमस्य राजन्नागने सखे॥',
     'In this bright dawning of the days we meditate on the fair name of the divine. Resplendent, he who offers sacrifice adorns himself. O Agni, friend of Soma-rites, O King.'),
    (62, 'तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि। धियो यो नः प्रचोदयात्॥',
     'Let us meditate on that excellent glory of the divine Sun. May he stimulate our understanding. (The Gayatri Mantra — most sacred verse of the Rigveda)'),
  ],
  4: [
    (1, 'त्वामग्ने यजमाना अनु द्युन् विश्वा वसूनि समिधानमीळते। त्वे राये स्वपत्यस्य चारोः पितेव पुत्रं प्रति नः शिशाधि॥',
     'Thee, Agni, sacrificers day by day, when thou art kindled, implore for all good things. In thee are all wealth and fair offspring; like a father to a son, guide us accordingly.'),
    (26, 'अहं मनुरभवं सूर्यश्चाहं ककुहान् ऋषिरस्मि विप्रः। अहं कुत्समार्जुनेयं न्यृञ्जे। अहं कविरुशना पश्यत मा॥',
     'I was Manu and the Sun. I am the sage Kakuhan, the Brahmin. I brought down Kutsa the son of Arjuna. I am the seer Ushana — behold me here.'),
  ],
  5: [
    (81, 'युञ्जते मन उत युञ्जते धियो विप्रा विप्रस्य बृहतो विपश्चितः। वि होत्रा दधे वयुनाविदेक इन्मही देवस्य सवितुः परिष्टुतिः॥',
     'The wise yoke their minds, yea, yoke their holy thoughts to him, the Far-seeing, to the great, wise, all-perceiving Sage. He alone arranges the priestly offices. Great is the praise of divine Savitar.'),
    (85, 'वरुणस्य नु वीर्याणि प्र वोचं यो वे द्यावापृथिवी विमाम। यो वे द्यावापृथिवी विमाम। यो अस्करद् विततं स्कम्भनेन।',
     'I will declare the mighty deeds of Varuna — who, standing in the firmament, hath meted out the earth with the sun as with a measure, who has stretched out the sky with a pillar.'),
  ],
  6: [
    (47, 'इन्द्रस्य नु वीर्याणि प्र वोचं यानि चकार प्रथमानि वज्री। अहन्नहिमन्वपस्ततर्द प्र वक्षणा अभिनत् पर्वतानाम्॥',
     'Now will I declare the heroic deeds of Indra, the first that he performed, the Thunder-wielder. He slew the dragon, then disclosed the waters, and cleft the channels of the mountain torrents.'),
    (75, 'शर्म नो देहि द्विपदे चतुष्पदे। कृधी नस्तनयान् पुष्यसे जने। देवासोऽविष्टन विश्वे जरामृत्यू परि व्रजः॥',
     'Grant shelter to our bipeds and our quadrupeds. Make our children prosper in your grace. May all the gods protect us. May we escape old age and death.'),
  ],
  7: [
    (89, 'मो षु वरुण मृन्मयं गृहं राजन्न हं गमम्। मृळा सुक्षत्र मृळय।',
     'Let me not yet, O Varuna, enter into the house of clay: have mercy, spare me, Mighty Lord. O strong and bright, have mercy, spare.'),
    (104, 'नास्त नो अराती वसोः। नाशा इदं त्वदृते। स पुत्रेभ्यः पितुर्यथा।',
     'Not our enemy has vanquished us. Not this without thee. Like a father to his sons, so be thou to us, O Vasu.'),
  ],
  8: [
    (48, 'अपाम सोमममृता अभूमागन्म ज्योतिरविदाम देवान्। किं नूनमस्मान् कृणवदरातिः। किमु धूर्तिरमृत मर्त्यस्य॥',
     'We have drunk the Soma, we have become immortal, we have entered into light, we have known the gods. What can hostility do to us now, and what the malice of any mortal? O immortal, mortal.'),
    (100, 'उत घा तं भोजनं भजामहे। येन त्वं महयसे। उत पुत्रस्य शृण्वतः।',
     'We share in that bounty, O Indra, by which thou dost make thyself great. And hearing the son.'),
  ],
  9: [
    (1, 'पवस्व देवावीर् अदब्धो विप्र ऊर्मिणा। इन्द्रायन्दो परि स्रव॥',
     'Flow, Soma, for the gods, unconquered, sage, with thy wave. Flow for Indra, drop.'),
    (113, 'यत्र राजा वैवस्वतो यत्रावरोधनं दिवः। यत्रामूः यौवनाशवः। तत्र मामतमृतं कृधि॥',
     'Where the eternal light shines, the world where the sun is placed, in that immortal, imperishable world, place me, O Soma. In the place where Vaivasvata reigns, in the innermost retreat of the sky — there make me immortal.'),
  ],
  10: [
    (90, 'सहस्रशीर्षा पुरुषः सहस्राक्षः सहस्रपात्। स भूमिं विश्वतो वृत्वात्यतिष्ठद्दशाङ्गुलम्॥',
     'Purusha has a thousand heads, a thousand eyes, a thousand feet. He covered the earth on all sides and stood beyond it by ten fingers breadth. (Purusha Sukta — the hymn of the Cosmic Person)'),
    (121, 'हिरण्यगर्भः समवर्तताग्रे भूतस्य जातः पतिरेक आसीत्। स दाधार पृथिवीं द्यामुतेमां कस्मै देवाय हविषा विधेम॥',
     'In the beginning was Hiranyagarbha — the golden womb. Once born, he was the one lord of all that is. He established this earth and this heaven. Who is the god to whom we shall offer our oblation?'),
    (129, 'नासदासीन्नो सदासीत्तदानीं नासीद्रजो नो व्योमापरो यत्। किमावरीवः कुह कस्य शर्मन्नम्भः किमासीद्गहनं गभीरम्॥',
     'Then even nothingness was not, nor existence. There was no air then, nor the heavens beyond it. What covered it? Where was it? In whose keeping? Was there then cosmic water, in depths unfathomed? (Nasadiya Sukta — Hymn of Creation)'),
    (191, 'संसमिद् युवसे वृषन्नग्ने विश्वान्यर्य आ। इळस्पदे समिध्यसे स नो वसून्या भर।',
     'Together come, together know, your minds be all of one accord, together all your purposes, that it may be well with you. United be your counsel and united be your hearts. United be your mind, so that you may all agree together. (Hymn of Unity — the last hymn of the Rigveda)'),
  ],
};
