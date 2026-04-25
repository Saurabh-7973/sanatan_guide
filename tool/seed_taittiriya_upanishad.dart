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
    db.execute("DELETE FROM verses WHERE scripture = 'taittiriya_upanishad'");
    int total = 0;
    total += _seedValli1(db);
    total += _seedValli2(db);
    total += _seedValli3(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Taittiriya Upanishad seeding complete');
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
    ) VALUES (?, 'taittiriya_upanishad', ?, ?, ?, ?, ?, 'muller', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedValli1(Database db) {
  const label = 'Valli I — Siksha (On Education)';
  final verses = [
    (1, 'ॐ शीक्षां व्याख्यास्यामः। वर्णः स्वरः। मात्रा बलम्। साम सन्तानः। इत्युक्तः शीक्षाध्यायः।',
     'We will explain Siksha — phonetics. Letter, accent, quantity, force, modulation, and connection — thus the chapter on Siksha is stated.'),
    (2, 'सह नौ यशः। सह नौ ब्रह्मवर्चसम्। अथातः संहिताया उपनिषदं व्याख्यास्यामः। पञ्चस्वधिकरणेषु।',
     'May glory be ours together. May Brahmic splendor be ours together. Now we shall explain the Upanishad of the Samhita in five sections.'),
    (11, 'सत्यं वद। धर्मं चर। स्वाध्यायान्मा प्रमदः। आचार्याय प्रियं धनमाहृत्य प्रजातन्तुं मा व्यवच्छेत्सीः।',
     'Speak the truth. Practice dharma. Do not neglect the study of the Veda. Having brought agreeable wealth to the teacher, cut not off the thread of progeny.'),
    (12, 'सत्यान्न प्रमदितव्यम्। धर्मान्न प्रमदितव्यम्। कुशलान्न प्रमदितव्यम्। भूत्यै न प्रमदितव्यम्। स्वाध्यायप्रवचनाभ्यां न प्रमदितव्यम्।',
     'Do not swerve from truth. Do not swerve from dharma. Do not neglect welfare. Do not neglect prosperity. Do not neglect the study and teaching of the Veda.'),
    (13, 'देवपितृकार्याभ्यां न प्रमदितव्यम्। मातृदेवो भव। पितृदेवो भव। आचार्यदेवो भव। अतिथिदेवो भव।',
     'Do not neglect the duties to gods and fathers. Let your mother be a god to you. Let your father be a god to you. Let your teacher be a god to you. Let your guest be a god to you.'),
    (3, 'यान्यनवद्यानि कर्माणि। तानि सेवितव्यानि। नो इतराणि। यान्यस्माकं सुचरितानि। तानि त्वयोपास्यानि। नो इतराणि।',
     'Whatever actions are blameless — those are to be performed, not others. Whatever good works have been done by us — those are to be observed by you, not others.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'TU.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Valli 1 — Siksha: ${verses.length} verses');
  return verses.length;
}

int _seedValli2(Database db) {
  const label = 'Valli II — Brahmananda (On Brahman and Bliss)';
  final verses = [
    (1, 'ब्रह्मविदाप्नोति परम्। तदेषाऽभ्युक्ता। सत्यं ज्ञानमनन्तं ब्रह्म। यो वेद निहितं गुहायां परमे व्योमन्। सोऽश्नुते सर्वान् कामान् सह। ब्रह्मणा विपश्चितेति।',
     'The knower of Brahman attains the highest. On this there is the following verse: Brahman is Truth, Knowledge, Infinite. He who knows it as hidden in the cave, in the highest ether — he, being one with the all-knowing Brahman, enjoys all desires.'),
    (2, 'तस्माद्वा एतस्मादात्मन आकाशः सम्भूतः। आकाशाद्वायुः। वायोरग्निः। अग्नेरापः। अद्भ्यः पृथिवी। पृथिव्या ओषधयः। ओषधिभ्योऽन्नम्। अन्नात्पुरुषः।',
     'From that Self, space was produced. From space, air. From air, fire. From fire, water. From water, earth. From earth, plants. From plants, food. From food, man.'),
    (5, 'अन्नाद्भवन्ति भूतानि। पर्जन्यादन्नसम्भवः। यज्ञाद्भवति पर्जन्यो यज्ञः कर्मसमुद्भवः।',
     'From food, creatures are born. By rain, food arises. By sacrifice, rain arises. Sacrifice arises from action.'),
    (6, 'अन्नं न निन्द्यात्। तद्व्रतम्। प्राणो वा अन्नम्। शरीरमन्नादम्। प्राणे शरीरं प्रतिष्ठितम्। शरीरे प्राणः प्रतिष्ठितः।',
     'Do not despise food — that is the vow. Prana is indeed food. The body eats food. The body is established in Prana. Prana is established in the body.'),
    (7, 'अन्नमयं हि सोम्य मनः। आपोमयः प्राणः। तेजोमयी वाक् इति।',
     'The mind, dear friend, is made of food. Prana is made of water. Speech is made of fire.'),
    (8, 'रसो वै सः। रसꣳहि एवायं लब्ध्वानन्दी भवति। को ह्येवान्यात्कः प्राण्यात्। यदेष आकाश आनन्दो न स्यात्।',
     'He is indeed Rasa — the essence of bliss. For truly, one who has obtained this Rasa becomes blissful. Who indeed would breathe, who would live, if this bliss were not in the ether?'),
    (9, 'सैषाऽऽनन्दस्य मीमाꣳसा भवति। युवा स्यात् साधु युवाध्यायकः। आशिष्ठो दृढिष्ठो बलिष्ठः।',
     'This is the inquiry into bliss. Let him be a young man, of good education, very diligent, firm, and strong.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'TU.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Valli 2 — Brahmananda: ${verses.length} verses');
  return verses.length;
}

int _seedValli3(Database db) {
  const label = 'Valli III — Bhrigu (On the Bliss of Brahman)';
  final verses = [
    (1, 'भृगुर्वै वारुणिः। वरुणं पितरमुपससार। अधीहि भगवो ब्रह्मेति। तस्मा एतत्प्रोवाच। अन्नं प्राणं चक्षुः श्रोत्रं मनो वाचमिति।',
     'Bhrigu the son of Varuna approached his father Varuna saying: "O Bhagavat, teach me Brahman." To him he said this: "Food, Prana, eye, ear, mind, and speech."'),
    (2, 'तपो ब्रह्मेति व्यजानात्। अन्नाद्ध्येव खल्विमानि भूतानि जायन्ते। अन्नेन जातानि जीवन्ति। अन्नं प्रयन्त्यभिसंविशन्तीति।',
     'He understood: Austerity is Brahman. For from food alone all creatures are born. Having been born by food, they live by food. When they depart, they enter into food.'),
    (3, 'प्राणो ब्रह्मेति व्यजानात्। प्राणाद्ध्येव खल्विमानि भूतानि जायन्ते। प्राणेन जातानि जीवन्ति। प्राणं प्रयन्त्यभिसंविशन्तीति।',
     'He understood: Prana is Brahman. For from Prana all creatures are born. Having been born through Prana, they live by Prana. When they depart, they enter into Prana.'),
    (4, 'मनो ब्रह्मेति व्यजानात्। मनसो ह्येव खल्विमानि भूतानि जायन्ते। मनसा जातानि जीवन्ति। मनः प्रयन्त्यभिसंविशन्तीति।',
     'He understood: Mind is Brahman. For from Mind all creatures are born. Having been born through Mind, they live by Mind. When they depart, they enter into Mind.'),
    (5, 'विज्ञानं ब्रह्मेति व्यजानात्। विज्ञानाद्ध्येव खल्विमानि भूतानि जायन्ते। विज्ञानेन जातानि जीवन्ति। विज्ञानं प्रयन्त्यभिसंविशन्तीति।',
     'He understood: Vijnana — knowledge — is Brahman. From knowledge all creatures are born. Having been born through knowledge, they live by knowledge. When they depart, they enter into knowledge.'),
    (6, 'आनन्दो ब्रह्मेति व्यजानात्। आनन्दाद्ध्येव खल्विमानि भूतानि जायन्ते। आनन्देन जातानि जीवन्ति। आनन्दं प्रयन्त्यभिसंविशन्तीति।',
     'He understood: Ananda — bliss — is Brahman. From bliss all creatures are born. Having been born through bliss, they live by bliss. When they depart, they enter into bliss.'),
    (10, 'अहमन्नमहमन्नमहमन्नम्। अहमन्नादोऽहमन्नादोऽहमन्नादः। अहꣳ श्लोककृदहꣳ श्लोककृदहꣳ श्लोककृत्।',
     'I am food, I am food, I am food. I am the eater of food, I am the eater of food, I am the eater of food. I am the maker of verses, I am the maker of verses, I am the maker of verses. (The great triumphant declaration of the liberated Self.)'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'TU.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Valli 3 — Bhrigu: ${verses.length} verses');
  return verses.length;
}
