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
    db.execute("DELETE FROM verses WHERE scripture = 'yoga_sutras'");

    int total = 0;
    total += _seedPada1(db);
    total += _seedPada2(db);
    total += _seedPada3(db);
    total += _seedPada4(db);

    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Yoga Sutras seeding complete');
    print('   Total sutras : $total');
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
  required int pada,
  required int sutra,
  required String sanskrit,
  required String english,
  required String chapterLabel,
}) {
  db.execute('''
    INSERT OR REPLACE INTO verses (
      id, scripture, chapter_num, verse_num,
      sanskrit, english, chapter_label, translation,
      is_bookmarked, read_count, created_at
    ) VALUES (?, 'yoga_sutras', ?, ?, ?, ?, ?, 'vivekananda', 0, 0, ?)
  ''', [
    id,
    pada,
    sutra,
    sanskrit,
    english,
    chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

// ── Pada 1 — Samadhi Pada (51 sutras) ────────────────────────────────────
// On the nature of yoga and the states of the mind
int _seedPada1(Database db) {
  const label = 'Samadhi Pada — On Contemplation';
  final sutras = [
    (1, 'अथ योगानुशासनम्', 'Now begins the instructions on Yoga.'),
    (
      2,
      'योगश्चित्तवृत्तिनिरोधः',
      'Yoga is the restraint of the modifications of the mind-stuff.'
    ),
    (
      3,
      'तदा द्रष्टुः स्वरूपेऽवस्थानम्',
      'Then the Seer rests in his own nature.'
    ),
    (
      4,
      'वृत्तिसारूप्यमितरत्र',
      'At other times the Seer is identified with the modifications.'
    ),
    (
      5,
      'वृत्तयः पञ्चतय्यः क्लिष्टाक्लिष्टाः',
      'The modifications of the mind-stuff are five, and are either painful or not painful.'
    ),
    (
      6,
      'प्रमाणविपर्ययविकल्पनिद्रास्मृतयः',
      'They are — right knowledge, indiscrimination, verbal delusion, sleep, and memory.'
    ),
    (
      7,
      'प्रत्यक्षानुमानागमाः प्रमाणानि',
      'Direct perception, inference, and competent evidence are proofs.'
    ),
    (
      8,
      'विपर्ययो मिथ्याज्ञानमतद्रूपप्रतिष्ठम्',
      'Indiscrimination is false knowledge not established in real nature.'
    ),
    (
      9,
      'शब्दज्ञानानुपाती वस्तुशून्यो विकल्पः',
      'Verbal delusion follows from words having no corresponding reality.'
    ),
    (
      10,
      'अभावप्रत्ययालम्बना वृत्तिर्निद्रा',
      'Sleep is a modification of the mind-stuff which has for its substratum nothingness.'
    ),
    (
      11,
      'अनुभूतविषयासम्प्रमोषः स्मृतिः',
      'Memory is when the perceived subject is not forgotten.'
    ),
    (
      12,
      'अभ्यासवैराग्याभ्यां तन्निरोधः',
      'Their restraint is brought about by practice and non-attachment.'
    ),
    (
      13,
      'तत्र स्थितौ यत्नोऽभ्यासः',
      'Practice is the effort to secure steadiness.'
    ),
    (
      14,
      'स तु दीर्घकालनैरन्तर्यसत्कारासेवितो दृढभूमिः',
      'This practice becomes well-grounded when continued for a long time, without interruption, and with devoted earnestness.'
    ),
    (
      15,
      'दृष्टानुश्रविकविषयवितृष्णस्य वशीकारसंज्ञा वैराग्यम्',
      'Non-attachment is the consciousness of mastery in one who is free from craving for objects seen or heard about.'
    ),
    (
      16,
      'तत्परं पुरुषख्यातेर्गुणवैतृष्ण्यम्',
      'That is highest — the non-thirst for the qualities of Purusha.'
    ),
    (
      17,
      'वितर्कविचारानन्दास्मितारूपानुगमात्सम्प्रज्ञातः',
      'Samprajnata Samadhi is accompanied by reasoning, reflection, bliss, and sense of pure being.'
    ),
    (
      18,
      'विरामप्रत्ययाभ्यासपूर्वः संस्कारशेषोऽन्यः',
      'The other is preceded by the practice of the cessation of all mental activity, in which only the impressions remain.'
    ),
    (
      19,
      'भवप्रत्ययो विदेहप्रकृतिलयानाम्',
      'Those who have merged in nature without the body, and those who are absorbed in nature, have this Samadhi.'
    ),
    (
      20,
      'श्रद्धावीर्यस्मृतिसमाधिप्रज्ञापूर्वक इतरेषाम्',
      'For others this Samadhi comes through faith, energy, memory, concentration, and discrimination.'
    ),
    (
      21,
      'तीव्रसंवेगानामासन्नः',
      'Success is speedy for the extremely energetic.'
    ),
    (
      22,
      'मृदुमध्याधिमात्रत्वात्ततोऽपि विशेषः',
      'The success of Yogis differs according to whether the means adopted are mild, medium, or intense.'
    ),
    (23, 'ईश्वरप्रणिधानाद्वा', 'Or by devotion to Ishvara.'),
    (
      24,
      'क्लेशकर्मविपाकाशयैरपरामृष्टः पुरुषविशेष ईश्वरः',
      'Ishvara is a particular Purusha untouched by misery, actions, their results, and desires.'
    ),
    (
      25,
      'तत्र निरतिशयं सर्वज्ञबीजम्',
      'In Him is the highest limit of omniscience.'
    ),
    (
      26,
      'स एष पूर्वेषामपि गुरुः कालेनानवच्छेदात्',
      'He is the Teacher of even the ancient teachers, being not limited by time.'
    ),
    (27, 'तस्य वाचकः प्रणवः', 'His name is Om.'),
    (
      28,
      'तज्जपस्तदर्थभावनम्',
      'The repetition of Om and meditating on its meaning is the way.'
    ),
    (
      29,
      'ततः प्रत्यक्चेतनाधिगमोऽप्यन्तरायाभावश्च',
      'From this comes the knowledge of the individual self and the removal of obstacles.'
    ),
    (
      30,
      'व्याधिस्त्यानसंशयप्रमादालस्याविरतिभ्रान्तिदर्शनालब्धभूमिकत्वानवस्थितत्वानि चित्तविक्षेपास्तेऽन्तरायाः',
      'Disease, dullness, doubt, carelessness, laziness, worldliness, false perception, non-attainment, and instability are the obstacles.'
    ),
    (
      31,
      'दुःखदौर्मनस्याङ्गमेजयत्वश्वासप्रश्वासा विक्षेपसहभुवः',
      'Grief, despondency, trembling of the body, irregular breathing accompany the obstacles.'
    ),
    (
      32,
      'तत्प्रतिषेधार्थमेकतत्त्वाभ्यासः',
      'To remove these obstacles, one truth should be practiced constantly.'
    ),
    (
      33,
      'मैत्रीकरुणामुदितोपेक्षाणां सुखदुःखपुण्यापुण्यविषयाणां भावनातश्चित्तप्रसादनम्',
      'Friendliness, mercy, gladness, and indifference — toward the happy, miserable, virtuous, and wicked — makes the mind-stuff serene.'
    ),
    (
      34,
      'प्रच्छर्दनविधारणाभ्यां वा प्राणस्य',
      'Or by expulsion and retention of breath.'
    ),
    (
      35,
      'विषयवती वा प्रवृत्तिरुत्पन्ना मनसः स्थितिनिबन्धनी',
      'Or those forms of concentration that bring extraordinary sense-perceptions make the mind steady.'
    ),
    (
      36,
      'विशोका वा ज्योतिष्मती',
      'Or the state of experiencing the effulgent light within — sorrowless.'
    ),
    (
      37,
      'वीतरागविषयं वा चित्तम्',
      'Or the mind fixed on those who are free from attachment.'
    ),
    (
      38,
      'स्वप्ननिद्राज्ञानालम्बनं वा',
      'Or the mind fixed on the knowledge that comes in dreams and sleep.'
    ),
    (
      39,
      'यथाभिमतध्यानाद्वा',
      'Or by meditation on anything that appeals to the devotee as good.'
    ),
    (
      40,
      'परमाणुपरममहत्त्वान्तोऽस्य वशीकारः',
      'The Yogi\'s mind thus meditating becomes unobstructed from the very small to the very great.'
    ),
    (
      41,
      'क्षीणवृत्तेरभिजातस्येव मणेर्ग्रहीतृग्रहणग्राह्येषु तत्स्थतदञ्जनता समापत्तिः',
      'The Yogi of well-trained mind, like a crystal taking color from what is near, becomes identified with knower, knowledge, and known.'
    ),
    (
      42,
      'तत्र शब्दार्थज्ञानविकल्पैः संकीर्णा सवितर्का समापत्तिः',
      'When mixing with word, meaning, and knowledge, this is Samadhi with deliberation.'
    ),
    (
      43,
      'स्मृतिपरिशुद्धौ स्वरूपशून्येवार्थमात्रनिर्भासा निर्वितर्का',
      'When the memory is purified and the mind shines alone as the object, Samadhi without deliberation.'
    ),
    (
      44,
      'एतयैव सविचारा निर्विचारा च सूक्ष्मविषया व्याख्याता',
      'By this, Samadhi with and without reflection on subtle objects is also explained.'
    ),
    (
      45,
      'सूक्ष्मविषयत्वं चालिङ्गपर्यवसानम्',
      'The subtle objects end with the primary matter.'
    ),
    (46, 'ता एव सबीजः समाधिः', 'These Samadhis are with seed.'),
    (
      47,
      'निर्विचारवैशारद्येऽध्यात्मप्रसादः',
      'On attaining the utmost purity of the state without reflection, there is the dawning of the spiritual light.'
    ),
    (
      48,
      'ऋतम्भरा तत्र प्रज्ञा',
      'The intellect there is called truth-bearing.'
    ),
    (
      49,
      'श्रुतानुमानप्रज्ञाभ्यामन्यविषया विशेषार्थत्वात्',
      'This knowledge is different from the knowledge of testimony and inference, for it relates to particulars.'
    ),
    (
      50,
      'तज्जः संस्कारोऽन्यसंस्कारप्रतिबन्धी',
      'The impression produced by this knowledge stands in the way of other impressions.'
    ),
    (
      51,
      'तस्यापि निरोधे सर्वनिरोधान्निर्बीजः समाधिः',
      'With the restraint of even that knowledge, all being restrained, comes seedless Samadhi.'
    ),
  ];
  for (final (s, sk, en) in sutras) {
    _insert(db,
        id: 'YS.1.$s',
        pada: 1,
        sutra: s,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Pada 1 — Samadhi Pada: ${sutras.length} sutras');
  return sutras.length;
}

// ── Pada 2 — Sadhana Pada (55 sutras) ────────────────────────────────────
// On practice — the Kriya Yoga and the eight limbs
int _seedPada2(Database db) {
  const label = 'Sadhana Pada — On Practice';
  final sutras = [
    (
      1,
      'तपःस्वाध्यायेश्वरप्रणिधानानि क्रियायोगः',
      'Mortification, study, and surrendering fruits of work to God — are called Kriya Yoga.'
    ),
    (
      2,
      'समाधिभावनार्थः क्लेशतनूकरणार्थश्च',
      'They are for the purpose of bringing Samadhi to fruition and attenuating the afflictions.'
    ),
    (
      3,
      'अविद्यास्मितारागद्वेषाभिनिवेशाः क्लेशाः',
      'The afflictions are — ignorance, egoism, attachment, aversion, and the will to live.'
    ),
    (
      4,
      'अविद्या क्षेत्रमुत्तरेषां प्रसुप्ततनुविच्छिन्नोदाराणाम्',
      'Ignorance is the cause of all the others, whether they are in a dormant, attenuated, overpowered, or expanded state.'
    ),
    (
      5,
      'अनित्याशुचिदुःखानात्मसु नित्यशुचिसुखात्मख्यातिरविद्या',
      'Ignorance is taking the non-eternal, the impure, the evil, and the non-Self for the eternal, the pure, the good, and the Self.'
    ),
    (
      6,
      'दृग्दर्शनशक्त्योरेकात्मतेवास्मिता',
      'Egoism is the identification of the Seer with the power of seeing.'
    ),
    (7, 'सुखानुशयी रागः', 'Attachment is the clinging to pleasure.'),
    (8, 'दुःखानुशयी द्वेषः', 'Aversion is the dwelling on pain.'),
    (
      9,
      'स्वरसवाही विदुषोऽपि तथारूढोऽभिनिवेशः',
      'The will to live is self-sustaining even in the wise.'
    ),
    (
      10,
      'ते प्रतिप्रसवहेयाः सूक्ष्माः',
      'These, the subtle ones, are to be avoided by resolving back into their cause.'
    ),
    (
      11,
      'ध्यानहेयास्तद्वृत्तयः',
      'Their modifications are to be avoided by meditation.'
    ),
    (
      12,
      'क्लेशमूलः कर्माशयो दृष्टादृष्टजन्मवेदनीयः',
      'The reservoir of Karma has its root in afflictions and is experienced in present and future lives.'
    ),
    (
      13,
      'सति मूले तद्विपाको जात्यायुर्भोगाः',
      'So long as the root is there, it will bear fruit — species, life, and experience.'
    ),
    (
      14,
      'ते ह्लादपरितापफलाः पुण्यापुण्यहेतुत्वात्',
      'They bear fruits of pleasure and pain, caused by virtue and vice.'
    ),
    (
      15,
      'परिणामतापसंस्कारदुःखैर्गुणवृत्तिविरोधाच्च दुःखमेव सर्वं विवेकिनः',
      'To the discriminating, all is pain — from the sufferings of change, anxiety, and impressions, and from the conflict of the activities of the qualities.'
    ),
    (16, 'हेयं दुःखमनागतम्', 'Pain which has not yet come is to be avoided.'),
    (
      17,
      'द्रष्टृदृश्ययोः संयोगो हेयहेतुः',
      'The cause of pain is the identification of the Seer with the seen.'
    ),
    (
      18,
      'प्रकाशक्रियास्थितिशीलं भूतेन्द्रियात्मकं भोगापवर्गार्थं दृश्यम्',
      'The seen is of the nature of illumination, activity, and inertia; it consists of the elements and the senses, and its purpose is experience and liberation.'
    ),
    (
      19,
      'विशेषाविशेषलिङ्गमात्रालिङ्गानि गुणपर्वाणि',
      'The stages of the qualities are — the defined, the undefined, the indicated only, and the signless.'
    ),
    (
      20,
      'द्रष्टा दृशिमात्रः शुद्धोऽपि प्रत्ययानुपश्यः',
      'The Seer is pure consciousness — though pure, he appears to see through the mind.'
    ),
    (
      21,
      'तदर्थ एव दृश्यस्यात्मा',
      'The nature of the seen is for the sake of the Seer alone.'
    ),
    (
      22,
      'कृतार्थं प्रति नष्टमप्यनष्टं तदन्यसाधारणत्वात्',
      'Although destroyed for him who has attained liberation, it is not destroyed for others, being common to them.'
    ),
    (
      23,
      'स्वस्वामिशक्त्योः स्वरूपोपलब्धिहेतुः संयोगः',
      'The union of the Seer with the seen is for the purpose of realizing the nature of both.'
    ),
    (24, 'तस्य हेतुरविद्या', 'Its cause is ignorance.'),
    (
      25,
      'तदभावात्संयोगाभावो हानं तद्दृशेः कैवल्यम्',
      'With the disappearance of ignorance, the union disappears — this is the independence of the Seer.'
    ),
    (
      26,
      'विवेकख्यातिरविप्लवा हानोपायः',
      'The means of liberation is unceasing discriminative knowledge.'
    ),
    (
      27,
      'तस्य सप्तधा प्रान्तभूमिः प्रज्ञा',
      'His knowledge is sevenfold — in the last stages.'
    ),
    (
      28,
      'योगाङ्गानुष्ठानादशुद्धिक्षये ज्ञानदीप्तिराविवेकख्यातेः',
      'By the practice of the limbs of Yoga, on the destruction of impurity comes knowledge, culminating in discriminative enlightenment.'
    ),
    (
      29,
      'यमनियमासनप्राणायामप्रत्याहारधारणाध्यानसमाधयोऽष्टावङ्गानि',
      'Yama, Niyama, Asana, Pranayama, Pratyahara, Dharana, Dhyana, and Samadhi are the eight limbs of Yoga.'
    ),
    (
      30,
      'अहिंसासत्यास्तेयब्रह्मचर्यापरिग्रहा यमाः',
      'Non-killing, truthfulness, non-stealing, continence, and non-receiving are the Yamas.'
    ),
    (
      31,
      'जातिदेशकालसमयानवच्छिन्नाः सार्वभौमा महाव्रतम्',
      'These, unbroken by time, place, purpose, and caste rules, are the universal great vow.'
    ),
    (
      32,
      'शौचसंतोषतपःस्वाध्यायेश्वरप्रणिधानानि नियमाः',
      'Cleanliness, contentment, mortification, study, and surrender to God are the Niyamas.'
    ),
    (
      33,
      'वितर्कबाधने प्रतिपक्षभावनम्',
      'To obstruct thoughts which are inimical to Yoga, contrary thoughts should be brought.'
    ),
    (
      34,
      'वितर्का हिंसादयः कृतकारितानुमोदिता लोभक्रोधमोहपूर्वका मृदुमध्याधिमात्रा दुःखाज्ञानानन्तफला इति प्रतिपक्षभावनम्',
      'The obstacles — killing etc., whether done, caused to be done, or approved — whether preceded by lust, anger, or delusion — whether small, medium, or great — result in infinite pain and ignorance. Thus the method of producing contrary thought.'
    ),
    (
      35,
      'अहिंसाप्रतिष्ठायां तत्सन्निधौ वैरत्यागः',
      'When non-killing is established, all enmity ceases in his presence.'
    ),
    (
      36,
      'सत्यप्रतिष्ठायां क्रियाफलाश्रयत्वम्',
      'When truth is established, the action and its fruits depend on him.'
    ),
    (
      37,
      'अस्तेयप्रतिष्ठायां सर्वरत्नोपस्थानम्',
      'When non-stealing is established, all jewels come to the Yogi.'
    ),
    (
      38,
      'ब्रह्मचर्यप्रतिष्ठायां वीर्यलाभः',
      'When continence is established, virility is gained.'
    ),
    (
      39,
      'अपरिग्रहस्थैर्ये जन्मकथन्तासम्बोधः',
      'When non-receiving is established, knowledge of past and future births comes.'
    ),
    (
      40,
      'शौचात्स्वाङ्गजुगुप्सा परैरसंसर्गः',
      'From cleanliness comes disgust for one\'s own body and non-intercourse with others.'
    ),
    (
      41,
      'सत्त्वशुद्धिसौमनस्यैकाग्र्येन्द्रियजयात्मदर्शनयोग्यत्वानि च',
      'Purification of the mind, cheerfulness, concentration, conquest of the organs, and fitness for the realization of the Self.'
    ),
    (42, 'संतोषादनुत्तमः सुखलाभः', 'From contentment comes supreme happiness.'),
    (
      43,
      'कायेन्द्रियसिद्धिरशुद्धिक्षयात्तपसः',
      'By mortification, on the destruction of impurity, come powers to body and organs.'
    ),
    (
      44,
      'स्वाध्यायादिष्टदेवतासम्प्रयोगः',
      'By study comes communion with the desired deity.'
    ),
    (
      45,
      'समाधिसिद्धिरीश्वरप्रणिधानात्',
      'By surrender to Ishvara comes Samadhi.'
    ),
    (46, 'स्थिरसुखमासनम्', 'Posture is that which is firm and pleasant.'),
    (
      47,
      'प्रयत्नशैथिल्यानन्तसमापत्तिभ्याम्',
      'By lessening the natural tendency and meditating on the infinite, posture becomes firm and pleasant.'
    ),
    (
      48,
      'ततो द्वन्द्वानभिघातः',
      'Thenceforth the Yogi is not disturbed by the pairs of opposites.'
    ),
    (
      49,
      'तस्मिन्सति श्वासप्रश्वासयोर्गतिविच्छेदः प्राणायामः',
      'When posture is mastered, Pranayama is the regulation of the inhalation and exhalation.'
    ),
    (
      50,
      'बाह्याभ्यन्तरस्तम्भवृत्तिर्देशकालसंख्याभिः परिदृष्टो दीर्घसूक्ष्मः',
      'Its modifications are external, internal, and motionless — regulated by place, time, and number — prolonged and subtle.'
    ),
    (
      51,
      'बाह्याभ्यन्तरविषयाक्षेपी चतुर्थः',
      'The fourth is the Pranayama that goes beyond the external and internal.'
    ),
    (
      52,
      'ततः क्षीयते प्रकाशावरणम्',
      'Thence the covering of the light is destroyed.'
    ),
    (53, 'धारणासु च योग्यता मनसः', 'And the mind becomes fit for Dharana.'),
    (
      54,
      'स्वविषयासम्प्रयोगे चित्तस्वरूपानुकार इवेन्द्रियाणां प्रत्याहारः',
      'Pratyahara is the drawing in of the organs by disjoining them from their objects — as it were, following the nature of the mind.'
    ),
    (
      55,
      'ततः परमा वश्यतेन्द्रियाणाम्',
      'Thence arises the supreme mastery over the organs.'
    ),
  ];
  for (final (s, sk, en) in sutras) {
    _insert(db,
        id: 'YS.2.$s',
        pada: 2,
        sutra: s,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Pada 2 — Sadhana Pada: ${sutras.length} sutras');
  return sutras.length;
}

// ── Pada 3 — Vibhuti Pada (55 sutras) ────────────────────────────────────
// On powers and attainments
int _seedPada3(Database db) {
  const label = 'Vibhuti Pada — On Powers';
  final sutras = [
    (
      1,
      'देशबन्धश्चित्तस्य धारणा',
      'Dharana is holding the mind on to some particular object.'
    ),
    (
      2,
      'तत्र प्रत्ययैकतानता ध्यानम्',
      'An unbroken flow of knowledge in that object is Dhyana.'
    ),
    (
      3,
      'तदेवार्थमात्रनिर्भासं स्वरूपशून्यमिव समाधिः',
      'When the same Dhyana shines as the object alone, and the mind has, as it were, lost its own nature, that is Samadhi.'
    ),
    (
      4,
      'त्रयमेकत्र संयमः',
      'The three together — Dharana, Dhyana, Samadhi — is called Samyama.'
    ),
    (
      5,
      'तज्जयात्प्रज्ञालोकः',
      'By the conquest of that comes the light of knowledge.'
    ),
    (6, 'तस्य भूमिषु विनियोगः', 'Its application is by stages.'),
    (
      7,
      'त्रयमन्तरङ्गं पूर्वेभ्यः',
      'These three are more internal than the preceding ones.'
    ),
    (
      8,
      'तदपि बहिरङ्गं निर्बीजस्य',
      'Even that is external to the seedless Samadhi.'
    ),
    (
      9,
      'व्युत्थाननिरोधसंस्कारयोरभिभवप्रादुर्भावौ निरोधक्षणचित्तान्वयो निरोधपरिणामः',
      'The suppression of the rising impressions and the rise of the suppression-impressions — the moment of suppression and the mind become connected — this is the transformation of suppression.'
    ),
    (
      10,
      'तस्य प्रशान्तवाहिता संस्कारात्',
      'By constant practice of this, the mind has a steady flow.'
    ),
    (
      11,
      'सर्वार्थतैकाग्रतयोः क्षयोदयौ चित्तस्य समाधिपरिणामः',
      'The destruction of all-pointedness and the rise of one-pointedness of the mind is the transformation of Samadhi.'
    ),
    (
      12,
      'ततः पुनः शान्तोदितौ तुल्यप्रत्ययौ चित्तस्यैकाग्रतापरिणामः',
      'When the past and present becoming similar, there is the transformation of one-pointedness.'
    ),
    (
      13,
      'एतेन भूतेन्द्रियेषु धर्मलक्षणावस्थापरिणामा व्याख्याताः',
      'By these three are explained the transformations of character, time, and state in elements and organs.'
    ),
    (
      14,
      'शान्तोदिताव्यपदेश्यधर्मानुपाती धर्मी',
      'The substratum is that which follows the past, present, and future natures.'
    ),
    (
      15,
      'क्रमान्यत्वं परिणामान्यत्वे हेतुः',
      'Difference in succession is the reason for difference in transformations.'
    ),
    (
      16,
      'परिणामत्रयसंयमादतीतानागतज्ञानम्',
      'By making Samyama on the three transformations comes knowledge of past and future.'
    ),
    (
      17,
      'शब्दार्थप्रत्ययानामितरेतराध्यासात्संकरस्तत्प्रविभागसंयमात्सर्वभूतरुतज्ञानम्',
      'By making Samyama on word, meaning, and knowledge — which are ordinarily confused — comes knowledge of all animal sounds.'
    ),
    (
      18,
      'संस्कारसाक्षात्करणात्पूर्वजातिज्ञानम्',
      'By perceiving impressions comes knowledge of previous births.'
    ),
    (
      19,
      'प्रत्ययस्य परचित्तज्ञानम्',
      'By making Samyama on the signs of others, knowledge of their minds is obtained.'
    ),
    (
      20,
      'न च तत्सालम्बनं तस्याविषयीभूतत्वात्',
      'But not its contents, that not being the object of the Samyama.'
    ),
    (
      21,
      'कायरूपसंयमात्तद्ग्राह्यशक्तिस्तम्भे चक्षुःप्रकाशासम्प्रयोगेऽन्तर्धानम्',
      'By making Samyama on the form of the body, its power of perceptibility being checked and light not reaching the eyes, comes invisibility.'
    ),
    (
      22,
      'एतेन शब्दाद्यन्तर्धानमुक्तम्',
      'By this the disappearance of sound and the rest is explained.'
    ),
    (
      23,
      'सोपक्रमं निरुपक्रमं च कर्म तत्संयमादपरान्तज्ञानमरिष्टेभ्यो वा',
      'Karma is of two kinds — soon-operative and later-operative. By making Samyama on these, or on the signs called Arishtas, the Yogi knows the time of death.'
    ),
    (
      24,
      'मैत्र्यादिषु बलानि',
      'By making Samyama on friendliness and other such qualities, powers are obtained.'
    ),
    (
      25,
      'बलेषु हस्तिबलादीनि',
      'By making Samyama on the strength of elephants and other animals, their strength is obtained.'
    ),
    (
      26,
      'प्रवृत्त्यालोकन्यासात्सूक्ष्मव्यवहितविप्रकृष्टज्ञानम्',
      'By making Samyama on the effulgent light comes knowledge of the fine, the hidden, and the remote.'
    ),
    (
      27,
      'भुवनज्ञानं सूर्ये संयमात्',
      'By making Samyama on the sun, knowledge of the worlds.'
    ),
    (
      28,
      'चन्द्रे ताराव्यूहज्ञानम्',
      'On the moon, knowledge of the cluster of stars.'
    ),
    (
      29,
      'ध्रुवे तद्गतिज्ञानम्',
      'On the pole-star, knowledge of the movements of the stars.'
    ),
    (
      30,
      'नाभिचक्रे कायव्यूहज्ञानम्',
      'On the navel circle, knowledge of the constitution of the body.'
    ),
    (
      31,
      'कण्ठकूपे क्षुत्पिपासानिवृत्तिः',
      'On the hollow of the throat, cessation of hunger and thirst.'
    ),
    (32, 'कूर्मनाड्यां स्थैर्यम्', 'On the nerve called Kurma, fixity.'),
    (
      33,
      'मूर्धज्योतिषि सिद्धदर्शनम्',
      'On the light at the top of the head, the vision of the Siddhas.'
    ),
    (34, 'प्रातिभाद्वा सर्वम्', 'Or by the power of Pratibha, all knowledge.'),
    (35, 'हृदये चित्तसंवित्', 'On the heart, knowledge of the mind.'),
    (
      36,
      'सत्त्वपुरुषयोरत्यन्तासंकीर्णयोः प्रत्ययाविशेषो भोगः परार्थत्वात्स्वार्थसंयमात्पुरुषज्ञानम्',
      'Experience is the result of the inability to distinguish between the Purusha and the Sattva though they are totally different. By making Samyama on the Purusha comes knowledge of the Purusha.'
    ),
    (
      37,
      'ततः प्रातिभश्रावणवेदनादर्शास्वादवार्ता जायन्ते',
      'Thence are born the powers of hearing, touching, seeing, tasting, and smelling belonging to Pratibha.'
    ),
    (
      38,
      'ते समाधावुपसर्गा व्युत्थाने सिद्धयः',
      'These are obstacles to Samadhi but powers in the worldly state.'
    ),
    (
      39,
      'बन्धकारणशैथिल्यात्प्रचारसंवेदनाच्च चित्तस्य परशरीरावेशः',
      'By the relaxation of the cause of bondage and by knowledge of its channels, the mind can enter another\'s body.'
    ),
    (
      40,
      'उदानजयाज्जलपङ्ककण्टकादिष्वसङ्ग उत्क्रान्तिश्च',
      'By conquering the Udana nerve, the Yogi does not sink in water or swamp, can walk on thorns, and can leave the body at will.'
    ),
    (
      41,
      'समानजयाज्ज्वलनम्',
      'By conquering the Samana nerve, the Yogi blazes like fire.'
    ),
    (
      42,
      'श्रोत्राकाशयोः संबन्धसंयमाद्दिव्यं श्रोत्रम्',
      'By making Samyama on the relation between akasha and the ear comes divine hearing.'
    ),
    (
      43,
      'कायाकाशयोः संबन्धसंयमाल्लघुतूलसमापत्तेश्चाकाशगमनम्',
      'By making Samyama on the relation between the body and akasha, and by becoming light as cotton, the Yogi can travel through the air.'
    ),
    (
      44,
      'बहिरकल्पिता वृत्तिर्महाविदेहा ततः प्रकाशावरणक्षयः',
      'The state called Mahavideha is when the modification is outside the body. Thence the veil of light is destroyed.'
    ),
    (
      45,
      'स्थूलस्वरूपसूक्ष्मान्वयार्थवत्त्वसंयमाद्भूतजयः',
      'By making Samyama on the gross, self-limited, subtle, all-pervading, and functional nature of the elements, comes mastery over the elements.'
    ),
    (
      46,
      'ततोऽणिमादिप्रादुर्भावः कायसम्पत्तद्धर्मानभिघातश्च',
      'Thence come powers of minuteness and the rest, perfection of the body, and non-obstruction of its characteristics by the elements.'
    ),
    (
      47,
      'रूपलावण्यबलवज्रसंहननत्वानि कायसम्पत्',
      'Loveliness, beauty, strength, adamantine hardness — these constitute bodily perfection.'
    ),
    (
      48,
      'ग्रहणस्वरूपास्मितान्वयार्थवत्त्वसंयमादिन्द्रियजयः',
      'By making Samyama on the power of perception, the essential nature, egoism, all-pervasiveness, and functions of the organs, comes mastery over them.'
    ),
    (
      49,
      'ततो मनोजवित्वं विकरणभावः प्रधानजयश्च',
      'Thence come to the body the power of rapid movement as the mind, the faculty of independent action of the organs, and the conquest of nature.'
    ),
    (
      50,
      'सत्त्वपुरुषान्यताख्यातिमात्रस्य सर्वभावाधिष्ठातृत्वं सर्वज्ञातृत्वं च',
      'By making Samyama on the discrimination between Sattva and Purusha come omnipotence and omniscience.'
    ),
    (
      51,
      'तद्वैराग्यादपि दोषबीजक्षये कैवल्यम्',
      'By giving up even these powers comes the destruction of the seed of evil — and Kaivalya.'
    ),
    (
      52,
      'स्थान्युपनिमन्त्रणे सङ्गस्मयाकरणं पुनरनिष्टप्रसङ्गात्',
      'The Yogi should not feel pride or attachment on being invited by the gods of high places, as there is danger of evil arising.'
    ),
    (
      53,
      'जातिलक्षणदेशैरन्यतानवच्छेदात्तुल्ययोस्ततः प्रतिपत्तिः',
      'By making Samyama on single moments and their succession comes discriminative knowledge.'
    ),
    (
      54,
      'तारकं सर्वविषयं सर्वथाविषयमक्रमं चेति विवेकजं ज्ञानम्',
      'The knowledge born of discrimination is transcendent, includes the all, relates to all periods and is non-successive.'
    ),
    (
      55,
      'सत्त्वपुरुषयोः शुद्धिसाम्ये कैवल्यमिति',
      'When the Sattva and the Purusha become equally pure, Kaivalya — independence — is the result.'
    ),
  ];
  for (final (s, sk, en) in sutras) {
    _insert(db,
        id: 'YS.3.$s',
        pada: 3,
        sutra: s,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Pada 3 — Vibhuti Pada: ${sutras.length} sutras');
  return sutras.length;
}

// ── Pada 4 — Kaivalya Pada (34 sutras) ───────────────────────────────────
// On independence and liberation
int _seedPada4(Database db) {
  const label = 'Kaivalya Pada — On Liberation';
  final sutras = [
    (
      1,
      'जन्मौषधिमन्त्रतपःसमाधिजाः सिद्धयः',
      'Powers are attained by birth, chemical means, power of words, mortification, or by concentration.'
    ),
    (
      2,
      'जात्यन्तरपरिणामः प्रकृत्यापूरात्',
      'The transformation into another species is by the overflow of nature.'
    ),
    (
      3,
      'निमित्तमप्रयोजकं प्रकृतीनां वरणभेदस्तु ततः क्षेत्रिकवत्',
      'Good and bad deeds are not the direct cause of transformation — they act as breakers of obstacles, as a farmer breaks down obstacles to irrigate a field.'
    ),
    (
      4,
      'निर्माणचित्तान्यस्मितामात्रात्',
      'Created minds proceed from egoism alone.'
    ),
    (
      5,
      'प्रवृत्तिभेदे प्रयोजकं चित्तमेकमनेकेषाम्',
      'One mind is the director of many created minds in their different activities.'
    ),
    (
      6,
      'तत्र ध्यानजमनाशयम्',
      'Of these, the mind born of meditation is free from impressions.'
    ),
    (
      7,
      'कर्माशुक्लाकृष्णं योगिनस्त्रिविधमितरेषाम्',
      'The Karma of the Yogi is neither white nor black — of others it is threefold.'
    ),
    (
      8,
      'ततस्तद्विपाकानुगुणानामेवाभिव्यक्तिर्वासनानाम्',
      'From these, only those impressions come to fruition which are appropriate to their consequences.'
    ),
    (
      9,
      'जातिदेशकालव्यवहितानामप्यान्तर्यं स्मृतिसंस्कारयोरेकरूपत्वात्',
      'There is immediate sequence in desires even though separated by species, place, and time, because memory and impressions are the same.'
    ),
    (
      10,
      'तासामनादित्वं चाशिषो नित्यत्वात्',
      'These desires are eternal, the desire to live being eternal.'
    ),
    (
      11,
      'हेतुफलाश्रयालम्बनैः संगृहीतत्वादेषामभावे तदभावः',
      'Being held together by cause, effect, refuge, and support — when these cease, the desires cease.'
    ),
    (
      12,
      'अतीतानागतं स्वरूपतोऽस्त्यध्वभेदाद्धर्माणाम्',
      'Past and future exist in reality — they differ in the way characteristics manifest.'
    ),
    (
      13,
      'ते व्यक्तसूक्ष्मा गुणात्मानः',
      'They are manifest or fine, being of the nature of the qualities.'
    ),
    (
      14,
      'परिणामैकत्वाद्वस्तुतत्त्वम्',
      'The unity of things is from the unity of changes.'
    ),
    (
      15,
      'वस्तुसाम्ये चित्तभेदात्तयोर्विभक्तः पन्थाः',
      'The two — object and perception — are different, for the same object is perceived differently by different minds.'
    ),
    (
      16,
      'न चैकचित्ततन्त्रं वस्तु तदप्रमाणकं तदा किं स्यात्',
      'Nor does an object depend on one mind — for then what would become of it when not perceived?'
    ),
    (
      17,
      'तदुपरागापेक्षित्वाच्चित्तस्य वस्तु ज्ञाताज्ञातम्',
      'An object is known or unknown depending on whether the mind is colored by it or not.'
    ),
    (
      18,
      'सदा ज्ञाताश्चित्तवृत्तयस्तत्प्रभोः पुरुषस्यापरिणामित्वात्',
      'The modifications of the mind are always known to the Purusha — the lord — because of his unchangeability.'
    ),
    (
      19,
      'न तत्स्वाभासं दृश्यत्वात्',
      'The mind is not self-luminous, because it is an object of perception.'
    ),
    (
      20,
      'एकसमये चोभयानवधारणम्',
      'Nor can the mind perceive both subject and object simultaneously.'
    ),
    (
      21,
      'चित्तान्तरदृश्ये बुद्धिबुद्धेरतिप्रसङ्गः स्मृतिसंकरश्च',
      'If the mind could be perceived by another mind, there would be an infinite regress of minds — and confusion of memory.'
    ),
    (
      22,
      'चितेरप्रतिसंक्रमायास्तदाकारापत्तौ स्वबुद्धिसंवेदनम्',
      'The consciousness of its own intelligence is through not transmigrating from mind to mind — taking the form of intellect.'
    ),
    (
      23,
      'द्रष्टृदृश्योपरक्तं चित्तं सर्वार्थम्',
      'The mind being colored by both the Seer and the seen is all-comprehensive.'
    ),
    (
      24,
      'तदसंख्येयवासनाभिश्चित्रमपि परार्थं संहत्यकारित्वात्',
      'The mind, though colored by innumerable desires, acts for another — for it acts in combination.'
    ),
    (
      25,
      'विशेषदर्शिन आत्मभावभावनानिवृत्तिः',
      'For the discriminating, the desire to know the nature of the Purusha ceases.'
    ),
    (
      26,
      'तदा विवेकनिम्नं कैवल्यप्राग्भारं चित्तम्',
      'Then the mind is inclined toward discrimination and gravitates toward liberation.'
    ),
    (
      27,
      'तच्छिद्रेषु प्रत्ययान्तराणि संस्कारेभ्यः',
      'In the intervals arise other thoughts from impressions.'
    ),
    (
      28,
      'हानमेषां क्लेशवदुक्तम्',
      'They are to be removed like the afflictions, as previously described.'
    ),
    (
      29,
      'प्रसंख्यानेऽप्यकुसीदस्य सर्वथा विवेकख्यातेर्धर्ममेघः समाधिः',
      'He who, even in the state of highest realization, is not interested in that — due to constant discriminative knowledge — attains Dharmamegha Samadhi.'
    ),
    (
      30,
      'ततः क्लेशकर्मनिवृत्तिः',
      'Thence come cessation of afflictions and Karma.'
    ),
    (
      31,
      'तदा सर्वावरणमलापेतस्य ज्ञानस्यानन्त्याज्ज्ञेयमल्पम्',
      'Then, all the coverings and impurities of knowledge being removed, little remains to be known because of the infinity of knowledge.'
    ),
    (
      32,
      'ततः कृतार्थानां परिणामक्रमसमाप्तिर्गुणानाम्',
      'Thence come the resolution of the successive transformations of the qualities — their purpose fulfilled.'
    ),
    (
      33,
      'क्षणप्रतियोगी परिणामापरान्तनिर्ग्राह्यः क्रमः',
      'The succession corresponding to moments is comprehensible at the end of the last transformation.'
    ),
    (
      34,
      'पुरुषार्थशून्यानां गुणानां प्रतिप्रसवः कैवल्यं स्वरूपप्रतिष्ठा वा चितिशक्तिरिति',
      'The resolution of the qualities, empty of purpose for the Purusha, is Kaivalya — the establishment in the Purusha\'s own nature, which is pure consciousness itself.'
    ),
  ];
  for (final (s, sk, en) in sutras) {
    _insert(db,
        id: 'YS.4.$s',
        pada: 4,
        sutra: s,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Pada 4 — Kaivalya Pada: ${sutras.length} sutras');
  return sutras.length;
}
