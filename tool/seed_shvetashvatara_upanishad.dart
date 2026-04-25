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
    db.execute("DELETE FROM verses WHERE scripture = 'shvetashvatara_upanishad'");
    int total = 0;
    total += _seedChapter1(db);
    total += _seedChapter2(db);
    total += _seedChapter3(db);
    total += _seedChapter4(db);
    total += _seedChapter5(db);
    total += _seedChapter6(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Shvetashvatara Upanishad seeding complete');
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
    ) VALUES (?, 'shvetashvatara_upanishad', ?, ?, ?, ?, ?, 'muller', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedChapter1(Database db) {
  const label = 'Chapter I — The Question of Brahman';
  final verses = [
    (1, 'ब्रह्मवादिनो वदन्ति। किं कारणं ब्रह्म कुतः स्म जाताः। जीवाम केन क्व च सम्प्रतिष्ठाः। अधिष्ठिताः केन सुखेतरेषु वर्तामहे ब्रह्मविदो व्यवस्थाम्॥',
     'Students of Brahman ask: What is the cause? Is it Brahman? From where are we born? By what do we live? On what are we established? By whom are we governed — in pleasures and otherwise? Knowers of Brahman discuss this.'),
    (3, 'ये ध्यानयोगानुगताः पश्यन्त्यात्मशक्तिं स्वगुणैर्निगूढाम्। एक एव देवः सर्वभूतेषु गूढः। सर्वव्यापी सर्वभूतान्तरात्मा।',
     'Those who follow the path of meditation and yoga perceive the power of God hidden by its own qualities. He is one God hidden in all beings, all-pervading, the inner Soul of all creatures.'),
    (6, 'एकैव माया गुणसङ्गजीवभूतेन मायिना प्रसूता। एकः स्वयंभूः सर्वतः प्रतिष्ठः।',
     'There is one Maya — bound to the qualities — producing the bound soul through the Maya-holder. He alone is self-existent, established on all sides.'),
    (8, 'ज्ञाज्ञौ द्वावजावीशनीशौ। अजा ह्येका भोक्तृभोग्यार्थयुक्ता। अनन्तश्चात्मा विश्वरूपो ह्यकर्ता।',
     'Two — knower and non-knower, both unborn — the lord and non-lord. There is one unborn who is connected with the enjoyer and the enjoyed. The Self is infinite, universal in form, non-agent.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'SU.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 1: ${verses.length} verses');
  return verses.length;
}

int _seedChapter2(Database db) {
  const label = 'Chapter II — Yoga and Meditation';
  final verses = [
    (1, 'युञ्जानः प्रथमं मनस्तत्त्वाय सविता धियः। अग्नेर्ज्योतिर्निचाय्य पृथिव्या अध्याभरत्॥',
     'Savita first controls the mind for truth. Then he brings the light of Agni onto the earth.'),
    (8, 'सम कायशिरोग्रीवं धारयन्नचलं स्थिरः। सम्प्रेक्ष्य नासिकाग्रं स्वं दिशश्चानवलोकयन्॥',
     'Holding the body, head, and neck erect, motionless and still, gazing at the tip of one\'s own nose, and not looking in any direction —'),
    (15, 'एको हंसो भुवनस्यास्य मध्ये। स एवाग्निः सलिले संनिविष्टः। तमेव विदित्वा अति मृत्युमेति। नान्यः पन्था विद्यतेऽयनाय॥',
     'The one swan in the middle of this world — he it is who has entered the fire and the water. Having known him alone, one passes beyond death. There is no other path to go.'),
    (16, 'स विश्वकृद्विश्वविदात्मयोनिः ज्ञः कालकारो गुणी सर्वविद्यः। प्रधानक्षेत्रज्ञपतिर्गुणेशः संसारमोक्षस्थितिबन्धहेतुः॥',
     'He is the maker of all, the knower of all, the Self-source, the knowing one, the creator of time, full of qualities, omniscient. He is the lord of Pradhana and the knower of the field, the lord of qualities, the cause of bondage, existence, and liberation.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'SU.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 2: ${verses.length} verses');
  return verses.length;
}

int _seedChapter3(Database db) {
  const label = 'Chapter III — Rudra as Supreme Brahman';
  final verses = [
    (1, 'यो देवोऽग्नौ योऽप्सु यो विश्वं भुवनमाविवेश। य ओषधीषु यो वनस्पतिषु तस्मै देवाय नमो नमः॥',
     'To the god who is in the fire, who is in the waters, who has entered into the whole world, who is in plants, who is in trees — to that god be salutation, salutation.'),
    (2, 'यः सृष्टिकर्ता विश्वस्य गोप्ता। यो भूतपतिर्गुहाशयः। यः सर्वभूतेष्वात्मा। तस्मै देवाय नमोऽस्तु॥',
     'Salutation to that God who is the creator of the universe, its protector, the lord of beings, who dwells in the cave of the heart, who is the Self in all beings.'),
    (8, 'वेदाहमेतं पुरुषं महान्तमादित्यवर्णं तमसः परस्तात्। तमेव विदित्वाति मृत्युमेति नान्यः पन्था विद्यते अयनाय॥',
     'I know this great Person, of the color of the sun, beyond darkness. He who knows him passes beyond death. There is no other path to go.'),
    (11, 'विभुश्चित्तः सर्वगतः स्वयंभूः। स योऽग्निमन्तः प्रविष्टः। स एवैको नित्यः शिवः।',
     'All-pervading, intelligent, omnipresent, self-existent — he who has entered the fire within — he alone is the one, the eternal, the auspicious Shiva.'),
    (13, 'नित्यो नित्यानां चेतनश्चेतनानामेको बहूनां यो विदधाति कामान्। तत्कारणं साङ्ख्ययोगाधिगम्यं ज्ञात्वा देवं मुच्यते सर्वपाशैः॥',
     'The eternal among eternals, the conscious among the conscious, the one among the many who grants their desires — that cause, knowable through Sankhya and Yoga — knowing God, one is freed from all fetters.'),
    (19, 'अपाणिपादो जवनो ग्रहीता। पश्यत्यचक्षुः स शृणोत्यकर्णः। स वेत्ति वेद्यं न च तस्यास्ति वेत्ता। तमाहुरग्र्यं पुरुषं महान्तम्॥',
     'Without hands and feet he is swift and grasps; without eyes he sees; without ears he hears. He knows what is to be known, but no one knows him. They call him the primal great Person.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'SU.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 3: ${verses.length} verses');
  return verses.length;
}

int _seedChapter4(Database db) {
  const label = 'Chapter IV — The One God';
  final verses = [
    (1, 'यो देवः सर्वदेवेषु। सर्वेषां हृदये स्थितः। सर्वव्यापी च तद्भावात्। तस्मै देवाय नमो नमः॥',
     'The god who is in all the gods, who stands in the heart of all beings, who pervades all — salutation to that God.'),
    (3, 'त्वमग्निस्त्वं वायुस्त्वं सूर्यस्त्वं चन्द्रमाः। त्वमेव शुक्रं त्वमापस्त्वं पृथिवी त्वं प्रजापतिः॥',
     'Thou art fire, thou art wind, thou art the sun, thou art the moon. Thou art the bright star, thou art the water, thou art the earth, thou art Prajapati.'),
    (5, 'द्वे अक्षरे ब्रह्मपरे त्वनन्ते। विद्याविद्ये निहिते यत्र गूढे। क्षरं त्वविद्या ह्यमृतं तु विद्या। विद्याविद्ये ईशत एव देवः॥',
     'There are two syllables, two that are imperishable — hidden in the infinite Brahman. One is knowledge, the other is ignorance. Ignorance is perishable, knowledge is immortal. The God who rules both knowledge and ignorance is different from them.'),
    (9, 'नैनमूर्ध्वं न तिर्यञ्चं न मध्ये परिजग्रभत्। न तस्य प्रतिमा अस्ति यस्य नाम महद्यशः॥',
     'He is not grasped above, nor across, nor in the middle. There is no image of him whose name is great glory.'),
    (10, 'न संदृशे तिष्ठति रूपमस्य। न चक्षुषा पश्यति कश्चनैनम्। हृदा मनीषा मनसाभिक्लृप्तो। य एतद्विदुरमृतास्ते भवन्ति॥',
     'His form does not stand within the range of vision; no one sees him with the eye. Those who know him by heart and mind — by the thought that illumines — they become immortal.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'SU.4.$v', chapter: 4, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 4: ${verses.length} verses');
  return verses.length;
}

int _seedChapter5(Database db) {
  const label = 'Chapter V — The Individual Soul';
  final verses = [
    (1, 'द्वे अजे ईशनीशे अभिशस्ते। एका विमुक्ता आ भोगमोक्षार्थं। अनन्तश्चात्मा विश्वरूपो ह्यकर्ता।',
     'Two unborn ones — lord and non-lord — are praised and blamed. One released soul attains the goal of enjoyment and liberation. The Self is infinite, universal in form, non-agent.'),
    (4, 'अजां एकां लोहितशुक्लकृष्णां। बह्वीः प्रजाः सृजमानां सरूपाः। अजो ह्येको जुषमाणोऽनुशेते जहात्येनां भुक्तभोगामजोऽन्यः॥',
     'The one unborn — red, white, and black — who produces many creatures of the same nature. One unborn male rests delighting in her; another unborn male leaves her after having enjoyed her.'),
    (6, 'एषा देव विश्वस्य कर्ता। एष हि ब्रह्म एष इशान एष परः सर्वः। एवं विद्वान् जहाति सर्वपाशान्॥',
     'This God is the maker of all the universe. He is Brahman, he is Ishana, he is supreme over all. He who knows him thus leaves all fetters.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'SU.5.$v', chapter: 5, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 5: ${verses.length} verses');
  return verses.length;
}

int _seedChapter6(Database db) {
  const label = 'Chapter VI — Liberation Through Knowledge of God';
  final verses = [
    (1, 'ये चेमे स्वर्गे लोके इष्टापूर्ते क्षितिक्षये। पुनरेति त्रिषु लोकेषु एकोऽयं देवः सर्वभूतेषु गूढः।',
     'Whatever world is here or beyond — by sacrifices and deeds comes one God hidden in all beings, pervading all, the inner Self of all beings, the watcher of all actions.'),
    (6, 'एकः स्वयंभूः सर्वतः प्रतिष्ठः। यो ब्रह्माणमीशत ईशनीभिः। योऽग्नि मन्तः प्रविष्टः। तस्मै देवाय नमो नमः॥',
     'The one self-existent, established everywhere, who governs Brahma through his ruling powers, who has entered the fire within — to that God be salutation, salutation.'),
    (11, 'एको देवः सर्वभूतेषु गूढः। सर्वव्यापी सर्वभूतान्तरात्मा। कर्माध्यक्षः सर्वभूताधिवासः। साक्षी चेता केवलो निर्गुणश्च॥',
     'The one God hidden in all beings, all-pervading, the inner Self of all beings, the overseer of all actions, the dwelling of all beings, the witness, the animator — the one, free from qualities.'),
    (13, 'नित्यो नित्यानां चेतनश्चेतनानाम्। एको बहूनां यो विदधाति कामान्। तमात्मस्थं येऽनुपश्यन्ति धीराः। तेषां शान्तिः शाश्वती नेतरेषाम्॥',
     'The eternal among eternals, the conscious among the conscious — the one who grants desires to the many. He who is perceived by the wise as dwelling in the Self — to them belongs eternal peace, to no others.'),
    (20, 'यत्रैकं देवं परं वेद सर्वभूतान्तरात्मनम्। तत्र देवाधिगम्यमात्मतत्त्वमवेदयत्। ज्ञानेन शुद्धो दर्शनेन ब्रह्म प्राप्नोति सनातनम्॥',
     'When one knows the one God, the inner Self of all beings — purified by knowledge, purified by vision — he attains the eternal Brahman.'),
    (23, 'यस्य देवे परा भक्तिः यथा देवे तथा गुरौ। तस्यैते कथिता ह्यर्थाः प्रकाशन्ते महात्मनः॥',
     'He who has the highest devotion to God, and as to God so also to the Guru — to that high-souled one these truths which have been declared will shine forth.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'SU.6.$v', chapter: 6, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 6: ${verses.length} verses');
  return verses.length;
}
