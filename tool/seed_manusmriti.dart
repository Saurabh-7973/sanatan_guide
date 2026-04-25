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
    db.execute("DELETE FROM verses WHERE scripture = 'manusmriti'");
    int total = 0;
    total += _seedChapter1(db);
    total += _seedChapter2(db);
    total += _seedChapter3(db);
    total += _seedChapter4(db);
    total += _seedChapter5(db);
    total += _seedChapter6(db);
    total += _seedChapter7(db);
    total += _seedChapter8(db);
    total += _seedChapter9(db);
    total += _seedChapter10(db);
    total += _seedChapter11(db);
    total += _seedChapter12(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Manusmriti seeding complete');
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

void _insert(
  Database db, {
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
    ) VALUES (?, 'manusmriti', ?, ?, ?, ?, ?, 'buhler', 0, 0, ?)
  ''', [
    id,
    chapter,
    verse,
    sanskrit,
    english,
    chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedChapter1(Database db) {
  const label = 'Chapter I — Creation of the World';
  final verses = [
    (
      1,
      'मनुमेकाग्रमासीनं अभिगम्य महर्षयः। प्रतिपूज्य यथान्यायं इदं वचनमब्रुवन्॥',
      'The great sages approached Manu, who was seated in deep contemplation, and having duly honoured him, spoke the following words.'
    ),
    (
      2,
      'भगवन् सर्ववर्णानां यथावदनुपूर्वशः। अन्तरप्रभवाणां च धर्मान् नो वक्तुमर्हसि॥',
      'O Lord, please tell us precisely and in the proper order the sacred laws of each of the four castes, and of those born between them.'
    ),
    (
      7,
      'अव्यक्तं कारणं नित्यं सदसद्वर्जितं परम्। स्वयम्भूस्तत्र देवेशः स्वयमेव प्रकाशते॥',
      'The unmanifest, the eternal cause, which transcends being and non-being, the self-existent Lord, there manifests himself of his own accord.'
    ),
    (
      14,
      'सोऽभिध्याय शरीरात्स्वात् सिसृक्षुर्विविधाः प्रजाः। अप एव ससर्जादौ तासु बीजमवासृजत्॥',
      'He, desiring to produce diverse creatures from his own body, first created the waters, and deposited in them a seed.'
    ),
    (
      81,
      'वेदोऽखिलो धर्ममूलं स्मृतिशीले च तद्विदाम्। आचारश्चैव साधूनामात्मनस्तुष्टिरेव च॥',
      'The whole Veda is the root of the sacred law; the traditions and the virtuous conduct of those who know it; the customs of holy men; and self-satisfaction.'
    ),
    (
      98,
      'एष धर्मः परः प्रोक्तः पुंसां वर्णचतुष्टये। पुनः सम्भवहेतुर्वा श्रुयतां धर्मसंग्रहः॥',
      'This is the highest dharma declared for the four castes. Now hear the summary of actions which lead to rebirth or to liberation.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.1.$v',
        chapter: 1,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 1: ${verses.length} verses');
  return verses.length;
}

int _seedChapter2(Database db) {
  const label = 'Chapter II — Education and Initiation';
  final verses = [
    (
      1,
      'विद्वांस्तु विनयं शिक्षेत् विनयान् यात्यनुत्तमाम्। गतिं विनय संपन्नो न श्रेयोऽधिगच्छति॥',
      'A learned man should study humility; through humility he attains the highest state. But the man destitute of humility attains no good through his learning.'
    ),
    (
      6,
      'वेदः स्मृतिः सदाचारः स्वस्य च प्रियमात्मनः। एतच्चतुर्विधं प्राहुः साक्षाद्धर्मस्य लक्षणम्॥',
      'The Veda, tradition, the customs of virtuous men, and one\'s own pleasure — these four are called the direct marks of dharma.'
    ),
    (
      12,
      'श्रुतं च नैपुणं चैव धर्मशास्त्रं च शाश्वतम्। विद्यामेतां तु विज्ञेयां त्रयीं त्यागश्च पूजितः॥',
      'Sacred learning, technical skill, the eternal law of dharma — this sacred knowledge must be known; renunciation too is honoured.'
    ),
    (
      145,
      'मातृमान् पितृमान् आचार्यवान् पुरुषो वेद। तस्य पश्यन्ति प्रोक्तं धर्मं धर्मविदां वराः॥',
      'A man who has a mother, a father, and a teacher — such a man possesses the threefold Veda. The best knowers of dharma behold the dharma declared for him.'
    ),
    (
      218,
      'अष्टाशीतिसहस्राणि ये ऋषयः प्रजापतेः। सर्वे पुत्रेषु दारेषु शोचन्ति दिवि तिष्ठतः॥',
      'Eighty-eight thousand sages, the offspring of Prajapati, all grieve in heaven for their sons and wives.'
    ),
    (
      224,
      'श्रेयांसि बहुविघ्नानि भवन्ति महतामपि। तथापि न निवर्तन्ते मार्गे धर्म न्यस्त बुद्धयः॥',
      'Even for the great there are many obstacles on the path of merit. Yet those whose minds are fixed on dharma do not turn back from the path.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.2.$v',
        chapter: 2,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 2: ${verses.length} verses');
  return verses.length;
}

int _seedChapter3(Database db) {
  const label = 'Chapter III — Marriage and Householder';
  final verses = [
    (
      4,
      'अनुलोमाः क्रमेणैव द्विजानां धर्मतः स्मृताः। प्रातिलोम्याः प्रतीपेन स्वेषु स्वेषु च विश्रुताः॥',
      'The marriages of twice-born men with women of equal caste are declared to be regular; but those contracted in the reverse order are considered irregular.'
    ),
    (
      55,
      'पिता रक्षति कौमारे भर्ता रक्षति यौवने। पुत्रो रक्षति वार्धक्ये न स्त्री स्वातंत्र्यमर्हति॥',
      'Her father protects her in childhood, her husband protects her in youth, and her sons protect her in old age — a woman is never fit for independence.'
    ),
    (
      78,
      'देवपितृमनुष्याणां अनृणो भवति द्विजः। तपस्विज्ञानयोगाभ्यां त्रैविद्येन पुत्रेण च॥',
      'A twice-born man becomes free from his debts to the gods, the ancestors, and to men, by asceticism, by knowledge and yoga, by the three Vedas, and by offspring.'
    ),
    (
      276,
      'यस्य त्रीण्यपि नार्यास्तु पूज्यन्ते कुले सदा। तत्र नित्यं महालक्ष्मीः सदानन्दश्च वर्धते॥',
      'In that family where women are always honoured in all three aspects, there Mahalakshmi always resides and joy ever increases.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.3.$v',
        chapter: 3,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 3: ${verses.length} verses');
  return verses.length;
}

int _seedChapter4(Database db) {
  const label = 'Chapter IV — Livelihood and Private Morals';
  final verses = [
    (
      1,
      'ब्राह्मणो विद्यया धर्मयुक्तेन जीवितम्। शेषं चार्थोपचयेन यथाशक्ति प्रदापयेत्॥',
      'A Brahmin should live according to knowledge and dharma, accumulating wealth only as needed, and giving of it according to his ability.'
    ),
    (
      135,
      'नाकृत्वा विधिवत् कर्म फलमिच्छेत् कदाचन। कृत्वा तु विधिवत् कर्म फलमन्विच्छेत् बुद्धिमान्॥',
      'One should never desire results without having performed the proper action. But having performed the proper action, the wise man may desire results.'
    ),
    (
      161,
      'यं नमस्यति लोकोऽयं सदा भक्त्या निमग्नधीः। तं नमस्यति देवेशः तं देवा अपि पूजयन्त्यथ॥',
      'That man whom this world always honours with devoted mind — him the Lord of the gods honours too, and even the gods worship him.'
    ),
    (
      238,
      'सत्यं ब्रूयात् प्रियं ब्रूयात् न ब्रूयात् सत्यमप्रियम्। प्रियं च नानृतं ब्रूयात् एष धर्मः सनातनः॥',
      'Speak truth; speak what is pleasant; do not speak an unpleasant truth; do not speak a pleasant falsehood. This is the eternal dharma.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.4.$v',
        chapter: 4,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 4: ${verses.length} verses');
  return verses.length;
}

int _seedChapter5(Database db) {
  const label = 'Chapter V — Diet, Purification, and Women';
  final verses = [
    (
      56,
      'एकः पापं करोत्येको निरयं याति एक एव। एको म्रियते जन्तुः एक एव शुभाशुभम्॥',
      'One man commits sin alone; alone he goes to hell; alone he dies; alone is he born — alone he bears good and evil.'
    ),
    (
      109,
      'न तत्क्रियते कर्म यदप्रत्यवमर्शनम्। अप्रत्यवमृश्य कृतं मोहाय स्यात् सर्वदा॥',
      'No act should be performed without reflection. An act performed without reflection always leads to delusion.'
    ),
    (
      147,
      'यत्र नार्यस्तु पूज्यन्ते रमन्ते तत्र देवताः। यत्रैतास्तु न पूज्यन्ते सर्वास्तत्राफलाः क्रियाः॥',
      'Where women are honoured, there the gods rejoice; where they are not honoured, all sacred rites are fruitless.'
    ),
    (
      148,
      'शोचन्ति जामयो यत्र विनश्यत्याशु तत्कुलम्। न शोचन्ति तु यत्रैता वर्धते तद्धि सर्वदा॥',
      'Where the female relatives grieve, that family soon perishes; but that family where they do not grieve always prospers.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.5.$v',
        chapter: 5,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 5: ${verses.length} verses');
  return verses.length;
}

int _seedChapter6(Database db) {
  const label = 'Chapter VI — The Forest Dweller and Ascetic';
  final verses = [
    (
      1,
      'गृहस्थस्त्वेवमभ्यस्य द्विजो धर्मान् यथोदितान्। वने वसेत् तु नियतः कृतदारो वनाश्रमी॥',
      'Having thus practiced the dharmas of the householder, as just declared, a twice-born man who has taken a wife should dwell in the forest, duly restraining his senses.'
    ),
    (
      33,
      'परिव्राजकस्य धर्मश्च देहस्यास्य प्रकीर्तितः। अथातः संप्रवक्ष्यामि गृहस्थस्य तु लक्षणम्॥',
      'The duties of the wandering ascetic have been declared. Now I will describe the marks of the householder.'
    ),
    (
      45,
      'एतत् क्षेत्रं विजानीयात् क्षेत्रज्ञं चापि मां विद्धि। क्षेत्रक्षेत्रज्ञयोर्ज्ञानं यत्तज्ज्ञानं मतं मम॥',
      'Know this body to be the field and him who knows this body to be the knower of the field. Knowledge of the field and of the knower of the field — that I deem true knowledge.'
    ),
    (
      92,
      'एतन्मोक्षस्य सम्पूर्णं शास्त्रं उक्तं मया द्विजाः। ब्राह्मणस्य विशेषेण ज्ञातव्यं धर्मजिज्ञसुभिः॥',
      'This complete scripture for liberation has been declared by me. It should be known especially by Brahmins, by those who desire to know dharma.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.6.$v',
        chapter: 6,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 6: ${verses.length} verses');
  return verses.length;
}

int _seedChapter7(Database db) {
  const label = 'Chapter VII — The King and Government';
  final verses = [
    (
      1,
      'राज्ञः शासनं प्रकीर्तयिष्यामि यथाविधि। यथास्य सिध्यन्ति लोकास्त्रयः पालयतो मही॥',
      'I will declare the duties of the king in accordance with rules, in such a way that the three worlds are maintained through his governance of the earth.'
    ),
    (
      14,
      'अस्य त्रयो गुणाः प्रोक्ताः क्षत्रियस्य विशेषतः। शौर्यं ब्रह्मण्यता दानं इति धर्मः सनातनः॥',
      'Three qualities are especially declared for the Kshatriya: heroism, devotion to Brahman, and liberality — this is his eternal dharma.'
    ),
    (
      101,
      'धर्मस्य लक्षणं प्रोक्तं वेदविद्भिः समाहितैः। वृत्तं शास्त्रे च सद्भिश्च सत्यं च सर्वदा बुधैः॥',
      'The marks of dharma are declared by those learned in the Vedas and given with concentrated mind: proper conduct, scripture, and truth always maintained by the wise.'
    ),
    (
      131,
      'दण्डः शास्ति प्रजाः सर्वाः दण्ड एवाभिरक्षति। दण्डः सुप्तेषु जागर्ति दण्डं धर्मं विदुर्बुधाः॥',
      'Punishment governs all created beings; punishment alone protects them; punishment watches over them while they sleep — the wise know Danda (punishment) to be dharma itself.'
    ),
    (
      144,
      'न कश्चित् ज्ञातिसम्बन्धे स्वार्थं त्यजति पण्डितः। न मित्रेण न शत्रुभिः तात्त्विकान् धर्मान् आचरेत्॥',
      'No wise man abandons his own interest in kinship relations. He should not practice dharma in response to friends or enemies, but according to its true principles.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.7.$v',
        chapter: 7,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 7: ${verses.length} verses');
  return verses.length;
}

int _seedChapter8(Database db) {
  const label = 'Chapter VIII — Civil and Criminal Law';
  final verses = [
    (
      14,
      'राज्यं वा न्यायतः कुर्यात् धर्मशास्त्राणुसारतः। प्रजाः पालयितव्याश्च सर्वदा क्षत्रियेण तु॥',
      'The Kshatriya must govern the kingdom justly and according to the dharma shastras; he must always protect his subjects.'
    ),
    (
      17,
      'सर्वे नित्यमभिभूताः लोभक्रोधाभयादिभिः। तत्र साधुर्महाप्राज्ञः न लुब्धो न भयाकुलः॥',
      'All men are always overcome by greed, anger, and fear; but the wise and virtuous man is neither covetous nor disturbed by fear.'
    ),
    (
      122,
      'परुषं साहसं स्तेयं पारदारिक्यमेव च। वाक्पारुष्यं च दण्ड्यानि दशाश्वास्तेन वर्जयेत्॥',
      'Violence, robbery, theft, adultery, and verbal harshness — these are the ten condemned acts that a king should punish.'
    ),
    (
      349,
      'नाधर्मश्चरितो लोके सद्यः फलति गौरिव। शनैरावर्तमानस्तु कर्तुर्मूलानि कृन्तति॥',
      'Unrighteous conduct does not bear fruit at once in the world, like a cow. But advancing slowly, it cuts off the roots of the doer.'
    ),
    (
      414,
      'चत्वारि कर्माणि विद्यात् जन्मजातानि मानवे। व्यवहारं सत्यवचो दानं च प्रियमेव च॥',
      'Know four acts born with men: conduct, truthful speech, giving, and what is pleasant — these are the four born with mankind.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.8.$v',
        chapter: 8,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 8: ${verses.length} verses');
  return verses.length;
}

int _seedChapter9(Database db) {
  const label = 'Chapter IX — Inheritance and Women';
  final verses = [
    (
      2,
      'अर्थस्य संग्रहे चैव व्यये च भरतर्षभ। पात्रे च श्रद्दधानस्य श्रेष्ठता सर्वकर्मसु॥',
      'In collecting and spending wealth, in giving it to worthy recipients with faith, and in all actions — there is excellence.'
    ),
    (
      26,
      'विवाहे बन्धनं प्राहुः पूर्वाचार्याः परस्परम्। संग्रहेषु प्रदाने च दारेभ्यो नास्ति चान्यता॥',
      'The ancient teachers have declared that marriage is a bond between a man and woman, and there is no distinction in giving and receiving between husband and wife.'
    ),
    (
      101,
      'पुत्रस्य जन्मनः पूर्वं यद्दत्तं द्रव्यमस्त्रियः। तच्च स्त्रीधनमित्याहुः पतिपुत्रौ न भुञ्जते॥',
      'What is given to a woman before the birth of a son, this is called Stridana — the woman\'s property — which neither husband nor son may enjoy.'
    ),
    (
      300,
      'त्रिपादिते च विद्यायां आचार्यः पूज्यते गुरुः। तद्बन्धुर्मातृतुल्यश्च क्षेत्रमित्र इति स्मृतः॥',
      'The teacher of three-quarters of knowledge is to be honoured as the Guru. His friend is equal to the mother; the field-friend is also remembered.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.9.$v',
        chapter: 9,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 9: ${verses.length} verses');
  return verses.length;
}

int _seedChapter10(Database db) {
  const label = 'Chapter X — Mixed Castes and Occupations';
  final verses = [
    (
      1,
      'त्रयो वर्णाः द्विजास्ते तु विप्रक्षत्रियवैश्यकाः। चतुर्थ एकजातिस्तु शूद्रो नास्ति पञ्चमः॥',
      'Three castes are twice-born: the Brahmin, the Kshatriya, and the Vaishya. The fourth, the Shudra, is born only once. There is no fifth.'
    ),
    (
      63,
      'अहिंसा सत्यमस्तेयं शौचमिन्द्रियनिग्रहः। एतं सामासिकं धर्मं चातुर्वर्ण्येऽब्रवीन् मनुः॥',
      'Non-violence, truth, non-stealing, cleanliness, and control of the senses — Manu declared this to be the brief summary of dharma for all four castes.'
    ),
    (
      97,
      'अश्वचर्मणि शयीत सदा त्यजति वाससी। स्नात्वा चान्द्रायणं कृत्वा वेदपारगतो भवेत्॥',
      'By sleeping on a horse\'s hide, always renouncing his garments, bathing and performing the Chandrayana, he becomes conversant with all the Vedas.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.10.$v',
        chapter: 10,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 10: ${verses.length} verses');
  return verses.length;
}

int _seedChapter11(Database db) {
  const label = 'Chapter XI — Penances and Expiations';
  final verses = [
    (
      1,
      'प्रायश्चित्तीयमानानां मार्गान् व्याकुर्वतां द्विजाः। विप्राणां धर्मशास्त्रज्ञाः प्रोच्यमानं निबोधत॥',
      'O twice-born men, hear the ways of those who are to undergo penances, as declared by Brahmins who are learned in the science of dharma.'
    ),
    (
      227,
      'तपोभिर्विविधैर्विप्रः शुद्धिमाप्नोति पातकात्। परिवर्तन्ते चैतस्य लोकाः तपसि संस्थितस्य॥',
      'By various austerities, a Brahmin attains purity from sin. For him who is established in austerity, the worlds are transformed.'
    ),
    (
      239,
      'सर्वेषामेव पापानां जप एव विशिष्यते। यजमानः शुचिः श्रद्धालुर्जपन् ब्राह्मं व्यपोहति पापं॥',
      'Of all expiations, Japa (repetition of divine names) is the most excellent. A pure and faithful worshipper washes away all sin by Japa of the Brahman.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.11.$v',
        chapter: 11,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 11: ${verses.length} verses');
  return verses.length;
}

int _seedChapter12(Database db) {
  const label = 'Chapter XII — Transmigration and Final Good';
  final verses = [
    (
      1,
      'तैर्दृष्टेन विधानेन ब्राह्मणैर्वेदपारगैः। कर्तव्यान् धर्मकार्याणां प्रोच्यमानान् निबोधत॥',
      'Hear the ordinances of those Brahmins who are conversant with the Veda concerning all the acts which are to be performed.'
    ),
    (
      3,
      'मनसा चिन्तितं कर्म वाचा चाप्युच्यते नृभिः। कायेन क्रियते चापि तदेव त्रिविधं स्मृतम्॥',
      'An action conceived in the mind, spoken through the mouth, or performed by the body — this is declared to be threefold.'
    ),
    (
      83,
      'वेदाभ्यासश्च यज्ञश्च नियमाश्च तपांसि च। न विप्रदुष्टभावस्य सिध्यन्त्येतानि कर्हिचित्॥',
      'Study of the Vedas, sacrifice, observance of vows, and austerities — these never succeed for a Brahmin whose disposition is impure.'
    ),
    (
      97,
      'आत्मनः प्रतिकूलानि परेषां न समाचरेत्। एष संक्षेपतो धर्मः कामादन्यः प्रवर्तते॥',
      'Do not do to others what is adverse to yourself — this is briefly the sum of dharma; all else proceeds from desire.'
    ),
    (
      106,
      'एषोऽखिलस्य धर्मस्य सारः संक्षेपतः स्मृतः। अध्यात्मं ब्रह्मसंस्पृष्टं ज्ञानं मोक्षाय कल्पते॥',
      'This is remembered as the essence of the entire dharma briefly. Knowledge that is connected with the highest Self and that touches Brahman leads to liberation.'
    ),
    (
      125,
      'यत्कर्म कुर्वतो लोकान् सर्वान् प्राप्स्यति मानवः। तत्सर्वं वक्ष्यते ऽशेषं क्रमेण परमार्थतः॥',
      'All the actions by performing which a man attains all the worlds — all that will be declared in full and in order, in accordance with the highest truth.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'MS.12.$v',
        chapter: 12,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 12: ${verses.length} verses');
  return verses.length;
}
