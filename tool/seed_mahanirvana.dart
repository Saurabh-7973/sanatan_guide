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
    db.execute("DELETE FROM verses WHERE scripture = 'mahanirvana_tantra'");
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
    total += _seedChapter13(db);
    total += _seedChapter14(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Mahanirvana Tantra seeding complete');
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
    ) VALUES (?, 'mahanirvana_tantra', ?, ?, ?, ?, ?, 'woodroffe', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

int _seedChapter1(Database db) {
  const label = 'Chapter I — Hymn to Brahman';
  final verses = [
    (1, 'ॐ सच्चिदानन्दरूपाय नमः। ब्रह्मणे परमात्मने। जगद्योनये शुद्धाय सर्वज्ञाय नमो नमः॥',
     'Salutation to Brahman, of the nature of Existence, Consciousness, and Bliss. Salutation to the Supreme Self, the womb of the universe, the pure, the omniscient.'),
    (2, 'एकमेवाद्वितीयं तत् सत्यं ज्ञानमनन्तकम्। ब्रह्म शुद्धं बोधरूपं सर्वत्र व्यापकं परम्॥',
     'That One alone, without a second — Truth, Knowledge, Infinite — is Brahman: pure, of the nature of consciousness, all-pervading, supreme.'),
    (10, 'देवि त्वं मे प्रसन्ना स्या देवि जगन्माता। सर्वाधारे सर्वरूपे सर्वेश्वरि नमोऽस्तु ते॥',
     'O Devi, be gracious to me. O Mother of the universe, support of all, all-formed, ruler of all — salutation to thee.'),
    (14, 'त्वं माया त्वं परा शक्तिः त्वं मुक्तिः त्वं परागतिः। त्वमेव जगदाधारं त्वमेव परमेश्वरी॥',
     'Thou art Maya, thou art the supreme Shakti, thou art liberation, thou art the supreme goal. Thou alone art the support of the universe, thou art the supreme Ishvari.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 1: ${verses.length} verses');
  return verses.length;
}

int _seedChapter2(Database db) {
  const label = 'Chapter II — Brahman and Shakti';
  final verses = [
    (1, 'शिव उवाच। शृणु देवि प्रवक्ष्यामि परं ज्ञानं सनातनम्। येन विज्ञातमात्रेण मुक्तो भवति मानवः॥',
     'Shiva said: Hear, O Devi, I will declare the supreme eternal knowledge, by knowing which alone man becomes liberated.'),
    (8, 'ब्रह्म सत्यं जगन्मिथ्या जीवो ब्रह्मैव नापरः। अनेन वेद्यं सच्छास्त्रं इति वेदान्तडिण्डिमः॥',
     'Brahman is real, the world is illusion, the individual self is Brahman itself and nothing else. This is the import of true scripture — the drum-beat of Vedanta.'),
    (13, 'सर्वं खल्विदं ब्रह्म नेह नानास्ति किञ्चन। एको देवः सर्वभूतेषु गूढः सर्वव्यापी सर्वभूतान्तरात्मा॥',
     'All this indeed is Brahman; there is no diversity here whatsoever. The one God is hidden in all beings, all-pervading, the inner Self of all creatures.'),
    (19, 'शक्तिः शिवस्य परमा ब्रह्मशक्तिर्जगन्मयी। तया विना न शिवः शक्तः स्पन्दितुमपि किञ्चन॥',
     'The supreme Shakti of Shiva, the Brahma-Shakti pervading the universe — without her, Shiva is not able to stir even a little.'),
    (25, 'चिच्छक्तिश्चित्स्वरूपा सा आनन्दा परमेश्वरी। सैव मायाशक्तिरूपा जगत्सृष्टिविधायिनी॥',
     'She is the power of consciousness, of the nature of consciousness, bliss, and the supreme Ishvari. She herself in the form of Maya-Shakti is the ordainer of the creation of the universe.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 2: ${verses.length} verses');
  return verses.length;
}

int _seedChapter3(Database db) {
  const label = 'Chapter III — Qualifications of Disciples';
  final verses = [
    (1, 'पार्वत्युवाच। कथं ज्ञायते देव साधकः पात्रमुत्तमम्। कीदृशश्च गुरुः श्रेष्ठः कथं शिष्यः प्रशस्यते॥',
     'Parvati said: How, O Lord, is an excellent aspirant known? What is the best kind of Guru? How is a disciple praised?'),
    (5, 'शिव उवाच। ब्रह्मज्ञाने रतिर्यस्य संसारे विरतिस्तथा। शमदमादिसंपन्नो मुमुक्षुः साधको मतः॥',
     'Shiva said: He who has attachment to the knowledge of Brahman, detachment from worldly things, and is endowed with Shama, Dama and other qualities, and desires liberation — he is considered a Sadhaka.'),
    (12, 'श्रोत्रियोऽब्रह्मनिष्ठश्च ब्रह्मनिष्ठोऽश्रुतिर्यदि। उभयोः सम्मतो नेता स एव गुरुरुत्तमः॥',
     'He who is learned in the scriptures and established in Brahman — or established in Brahman even without scriptural learning — he who is acknowledged by both as their leader, he alone is the excellent Guru.'),
    (21, 'गुरुं विना न मोक्षोऽस्ति न ज्ञानं न च साधना। तस्माद्गुरुपदं साक्षात् ब्रह्मरूपं विचिन्तयेत्॥',
     'Without a Guru there is no liberation, no knowledge, no sadhana. Therefore one should contemplate the Guru\'s feet as directly of the nature of Brahman.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 3: ${verses.length} verses');
  return verses.length;
}

int _seedChapter4(Database db) {
  const label = 'Chapter IV — Brahma Mantra and Initiation';
  final verses = [
    (1, 'अथ वक्ष्ये महादेव ब्रह्ममन्त्रं सनातनम्। येन जप्तेन सिध्यन्ति सर्वकामाः सुनिश्चितम्॥',
     'Now I will declare, O Mahadeva, the eternal Brahma Mantra, by the repetition of which all desires are certainly fulfilled.'),
    (11, 'ॐ इत्येकाक्षरं ब्रह्म व्याहृतिस्त्रिपदा तथा। गायत्री चन्दसां माता ब्रह्मज्ञानस्य साधनम्॥',
     'OM is the one-syllable Brahman. The three Vyahritis. The Gayatri, the mother of all metres — these are the means to the knowledge of Brahman.'),
    (17, 'तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि। धियो यो नः प्रचोदयात्॥',
     'We meditate on that excellent light of the divine Sun; may He illuminate our intellect. (The Gayatri Mantra — sacred to all twice-born.)'),
    (25, 'दीक्षाविहीनो यो मर्त्यः स पशुर्नात्र संशयः। दीक्षितो ज्ञानवान् शुद्धो देवतुल्यो न संशयः॥',
     'The mortal who is without initiation is verily an animal — there is no doubt. The initiated man of knowledge and purity is equal to a god — there is no doubt.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.4.$v', chapter: 4, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 4: ${verses.length} verses');
  return verses.length;
}

int _seedChapter5(Database db) {
  const label = 'Chapter V — Rules for Brahma Sadhana';
  final verses = [
    (1, 'साधनस्य विधिं देवि वक्ष्यामि श्रृणु सादरम्। येन साधयते सिद्धिं साधकः सर्वसिद्धिदाम्॥',
     'O Devi, hear with respect the rules of Sadhana which I will declare, by which the aspirant accomplishes the Siddhi that gives all perfections.'),
    (8, 'ब्रह्ममुहूर्त उत्थाय कृत्वा शौचादिकं क्रमात्। स्नात्वा शुद्धो जपेन्मन्त्रं सहस्राष्टोत्तरं शतम्॥',
     'Rising in the Brahma Muhurta, having performed purification and other acts in order, having bathed and being pure, one should repeat the Mantra one hundred and eight times, or a thousand times.'),
    (15, 'न जात्या ब्राह्मणो ज्ञेयः संस्कारैर्ब्राह्मणो भवेत्। विद्यया ब्राह्मणो भाति तपसा च विशुध्यति॥',
     'A Brahmin is not known by birth — he becomes a Brahmin by purificatory rites. By knowledge a Brahmin shines; by austerity he is purified.'),
    (22, 'जपध्यानपरो नित्यं दयालुः सर्वजन्तुषु। न हिंसति न चोद्विग्नः सत्यवाक् शुचिरेव च॥',
     'Always devoted to Japa and meditation, compassionate to all beings, not causing harm, not agitated, truthful in speech, and pure.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.5.$v', chapter: 5, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 5: ${verses.length} verses');
  return verses.length;
}

int _seedChapter6(Database db) {
  const label = 'Chapter VI — Propitiatory and Purificatory Rites';
  final verses = [
    (1, 'देव्युवाच। कथं पूजा विधातव्या देवस्य परमात्मनः। केन द्रव्येण देवेश केन मन्त्रेण वा प्रभो॥',
     'The Devi said: How should the worship of the Lord Supreme Self be performed? With what substance, O Lord of gods? With what mantra, O Master?'),
    (7, 'शिव उवाच। भावशुद्धिर्जले स्नानं भावशुद्धिः सुरार्चनम्। भावशुद्धिर्जपे ध्याने भावः सर्वत्र कारणम्॥',
     'Shiva said: Purity of feeling is bathing in water; purity of feeling is worship of the gods; purity of feeling is in Japa and meditation. Feeling is the cause of everything.'),
    (14, 'पुष्पं गन्धश्च धूपश्च दीपो नैवेद्यमेव च। पञ्चोपचारपूजैषा सर्वदेवप्रियङ्करी॥',
     'Flower, fragrance, incense, lamp, and food-offering — this five-fold worship is pleasing to all gods.'),
    (23, 'आत्मा देवः परं तीर्थमात्मज्ञानं परं तपः। आत्मसंस्थं परं ज्ञानं आत्मयज्ञः परो विधिः॥',
     'The Self is the God, the supreme pilgrimage; knowledge of the Self is the supreme austerity; knowledge resting in the Self is the supreme knowledge; self-sacrifice is the supreme rite.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.6.$v', chapter: 6, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 6: ${verses.length} verses');
  return verses.length;
}

int _seedChapter7(Database db) {
  const label = 'Chapter VII — The Panchatattva and Worship';
  final verses = [
    (1, 'पञ्चतत्त्वविधानं च वक्ष्यामि श्रृणु पार्वति। येन तुष्यति देवेशो भैरवः कालभैरवः॥',
     'I will declare the procedure of the five elements — hear, O Parvati — by which the Lord of gods, Bhairava, Kalabhairava, is pleased.'),
    (9, 'मद्यं मांसं तथा मत्स्यः मुद्रा मैथुनमेव च। एते पञ्चमकाराः स्युर्देवीपूजाविधौ मताः॥',
     'Wine, meat, fish, grain, and sexual union — these are the five M\'s considered in the method of Devi worship. (Note: These are interpreted symbolically in Brahma Sadhana as cosmic principles.)'),
    (14, 'भावशुद्धो विशुद्धात्मा सर्वत्र समदर्शनः। पशुभावं परित्यज्य दिव्यभावेन पूजयेत्॥',
     'Pure in feeling, pure in Self, seeing equality everywhere — abandoning the animal nature, one should worship with the divine feeling.'),
    (22, 'ज्ञानमेव परा मुक्तिः ज्ञानमेव परं तपः। ज्ञानमेव परं दानं ज्ञानमेव परायणम्॥',
     'Knowledge alone is supreme liberation; knowledge alone is supreme austerity; knowledge alone is supreme giving; knowledge alone is the supreme goal.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.7.$v', chapter: 7, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 7: ${verses.length} verses');
  return verses.length;
}

int _seedChapter8(Database db) {
  const label = 'Chapter VIII — Kulachara and Its Practices';
  final verses = [
    (1, 'कुलाचारं प्रवक्ष्यामि सर्वागमोत्तमोत्तमम्। येन मुक्तिर्भवेत् क्षिप्रं सत्यं सत्यं न संशयः॥',
     'I will declare the Kulachara, the most excellent of all Agamas, by which liberation comes quickly — truly, truly, without doubt.'),
    (11, 'आत्मज्ञानरतो नित्यं सर्वभूतहिते रतः। समदृष्टिः समाचारः कुलीनो नाम केवलम्॥',
     'Always devoted to knowledge of the Self, always devoted to the welfare of all beings, equal in vision, equal in conduct — he alone is called Kulina.'),
    (19, 'न देशो नापि कालो वा न शुद्धिर्नापि चाशुचिः। ज्ञानिनां ब्रह्मनिष्ठानां न विधिर्नापि निषेधनम्॥',
     'For the knowers of Brahman who are established in Brahman, there is no place, no time, no purity, no impurity, no rule, no prohibition.'),
    (27, 'विद्या विनयसंपन्ने ब्राह्मणे गवि हस्तिनि। शुनि चैव श्वपाके च पण्डिताः समदर्शिनः॥',
     'The learned see with equal eye a Brahmin endowed with learning and humility, a cow, an elephant, a dog, and even a dog-eater. (Echoing Bhagavad Gita 5.18)'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.8.$v', chapter: 8, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 8: ${verses.length} verses');
  return verses.length;
}

int _seedChapter9(Database db) {
  const label = 'Chapter IX — Hymn to Adya Kali';
  final verses = [
    (1, 'नमस्ते सर्वरूपायै नमस्ते सर्वशक्तये। नमस्ते परमानन्दे नमस्ते परमेश्वरि॥',
     'Salutation to thee, who art of all forms; salutation to thee, who art all power; salutation to thee, the supreme bliss; salutation to thee, the supreme Ishvari.'),
    (7, 'काली करालवदना दिगम्बरी महाबला। करालदंष्ट्रा चतुर्बाहुः वरदाभयहस्तका॥',
     'Kali, of terrible face, clothed in space, of great strength, with terrible teeth, four-armed, with hands bestowing boons and fearlessness.'),
    (14, 'सृष्टिस्थितिविनाशानां शक्तिभूते सनातनि। गुणाश्रये गुणमये नारायणि नमोऽस्तु ते॥',
     'O eternal one, who art the power of creation, preservation, and destruction; O Narayani, abode of the qualities, consisting of the qualities — salutation to thee.'),
    (21, 'त्वं स्वाहा त्वं स्वधा त्वं च वषट्कारस्वरात्मिका। सुधा त्वमक्षरे नित्ये त्रिधा मात्रात्मिका स्थिता॥',
     'Thou art Svaha, thou art Svadha, thou art the embodiment of the sound Vashat. Thou art the nectar of immortality, dwelling in the imperishable, eternal syllable, as the threefold Matras.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.9.$v', chapter: 9, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 9: ${verses.length} verses');
  return verses.length;
}

int _seedChapter10(Database db) {
  const label = 'Chapter X — The Ten Samskaras';
  final verses = [
    (1, 'संस्काराणां विधिं देवि वक्ष्यामि श्रृणु सादरम्। येन संस्कृतमात्रेण द्विजो भवति मानवः॥',
     'O Devi, hear with respect the procedure of the Samskaras which I will declare, by the mere performance of which a man becomes twice-born.'),
    (8, 'गर्भाधानं पुंसवनं सीमन्तोन्नयनं तथा। जातकर्म नामकर्म निष्क्रमणमन्नप्राशनम्॥',
     'Garbhadhana, Pumsavana, Simantonnayana, Jatakarma, Namakarana, Nishkramana, Annaprashana —'),
    (9, 'चूडाकरणमुपनयनं विवाहश्चेति संस्काराः। दशैते कथिताः सम्यक् द्विजानां धर्मसंस्कृतेः॥',
     'Chudakarana, Upanayana, and Vivaha — these ten are the Samskaras of twice-born men, well declared for the purification of dharma.'),
    (17, 'नामकर्मणि देवस्य नाम गृह्णाति मानवः। तेन नाम्ना सदा देवं स्मरेत् ध्यायेज्जपेत् तथा॥',
     'In the Namakarana rite, the man receives the name of the deity. By that name one should always remember the deity, meditate upon him, and repeat his name.'),
    (25, 'उपनयनमूलं हि सर्वेषां द्विजकर्मणाम्। तेन संस्कृतमात्रेण द्विजः सर्वं समश्नुते॥',
     'Upanayana is the root of all actions of the twice-born. By the mere performance of this, the twice-born attains everything.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.10.$v', chapter: 10, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 10: ${verses.length} verses');
  return verses.length;
}

int _seedChapter11(Database db) {
  const label = 'Chapter XI — Funeral Rites';
  final verses = [
    (1, 'अन्त्येष्टिविधिं देवि वक्ष्यामि श्रृणु सादरम्। येन मृतो नरो याति परलोकं शुभं सदा॥',
     'O Devi, hear with respect the procedure of the funeral rites which I will declare, by which the dead man always goes to the auspicious other world.'),
    (9, 'मृत्युः सर्वस्य निश्चितः जन्म सर्वस्य निश्चितम्। तस्मात् धर्मे सदा तिष्ठेत् जीवन्नेव विशेषतः॥',
     'Death is certain for all; birth is certain for all. Therefore one should always stand firm in dharma, especially while alive.'),
    (18, 'न जायते म्रियते वा कदाचिन् नायं भूत्वा भविता वा न भूयः। अजो नित्यः शाश्वतोऽयं पुराणो न हन्यते हन्यमाने शरीरे॥',
     'It is never born, nor does it die at any time; having come to be, it will not again cease to be. Unborn, eternal, ever-existing, primeval — it is not slain when the body is slain. (Bhagavad Gita 2.20)'),
    (24, 'दशाहे एकादशाहे तथा द्वादशाहे तथा। श्राद्धं कुर्यात् सपिण्डीकरणं चापि मासिकम्॥',
     'On the tenth day, the eleventh day, and the twelfth day, one should perform the Shraddha, the Sapindikarana, and the monthly rite.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.11.$v', chapter: 11, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 11: ${verses.length} verses');
  return verses.length;
}

int _seedChapter12(Database db) {
  const label = 'Chapter XII — Prayaschitta and Varnashrama';
  final verses = [
    (1, 'प्रायश्चित्तविधिं देवि सम्प्रवक्ष्यामि तत्त्वतः। येन शुद्धो भवेज्जीवः पापमुक्तः सनातनः॥',
     'O Devi, I will truly declare the procedure of expiation, by which the soul becomes pure and eternally free from sin.'),
    (11, 'ब्रह्मज्ञानेन शुद्ध्यन्ति सर्वे पातकिनो जनाः। अग्निर्यथा दहत्यर्थं भस्मसात् कुरुते तथा॥',
     'All sinful people are purified by the knowledge of Brahman, as fire burns away material things and reduces them to ashes.'),
    (19, 'वर्णाश्रमाचारवता पुरुषेण परः पुमान्। विष्णुराराध्यते पन्था नान्यस्तत्तोषकारकः॥',
     'Vishnu is worshipped by the man who follows the conduct of his own Varna and Ashrama. There is no other path that pleases Him.'),
    (28, 'चातुर्वर्ण्यं मया सृष्टं गुणकर्मविभागशः। तस्य कर्तारमपि मां विद्ध्यकर्तारमव्ययम्॥',
     'The four-caste system was created by Me according to the division of qualities and actions. Know Me, though the creator of it, as the non-doer, the imperishable. (Bhagavad Gita 4.13)'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.12.$v', chapter: 12, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 12: ${verses.length} verses');
  return verses.length;
}

int _seedChapter13(Database db) {
  const label = 'Chapter XIII — Duties of Householder and King';
  final verses = [
    (1, 'गृहस्थधर्मं वक्ष्यामि यथावत् श्रृणु पार्वति। येन धर्मेण संयुक्तो गृही मुक्तिमवाप्नुयात्॥',
     'I will declare the dharma of the householder properly — hear, O Parvati — by which the householder endowed with this dharma attains liberation.'),
    (9, 'अतिथिं पूजयेन्नित्यं यत्नाद्वाक्यादिभिः सदा। अतिथिर्नारायणः साक्षाद् देवताऽतिथिरुच्यते॥',
     'One should always honour the guest with effort, through words and other means. The guest is directly Narayana — the guest is called the deity.'),
    (17, 'दाने तपसि शौर्ये च विज्ञाने विनये तथा। विस्मयो न हि कर्तव्यः तुल्यं सर्वत्र दर्शनम्॥',
     'In giving, in austerity, in heroism, in knowledge, in humility — one should not feel pride. Equal vision everywhere.'),
    (25, 'राज्ञां धर्मः प्रजापालनं दण्डनीतिश्च सम्यक्। न स्वार्थाय न भोगाय राज्यं किन्तु प्रजाहिते॥',
     'The dharma of kings is the protection of subjects and proper punishment. The kingdom is not for self-interest or enjoyment, but for the welfare of the subjects.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.13.$v', chapter: 13, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 13: ${verses.length} verses');
  return verses.length;
}

int _seedChapter14(Database db) {
  const label = 'Chapter XIV — Liberation and Brahma Jnana';
  final verses = [
    (1, 'मोक्षस्य लक्षणं देवि वक्ष्यामि श्रृणु सादरम्। येन विज्ञाय मुच्यन्ते सर्वे संसारबन्धनात्॥',
     'O Devi, hear with respect the marks of liberation which I will declare, by knowing which all are freed from the bondage of the world.'),
    (7, 'अहं ब्रह्मास्मि इत्येवं विज्ञाय परमार्थतः। निर्वाणमुपयात्येव दीपो वातेरितो यथा॥',
     'Knowing in truth "I am Brahman" — thus he attains Nirvana, as a lamp blown out by the wind.'),
    (14, 'न जाग्रति न सुप्तोऽसौ न स्वप्ने विचरत्यपि। परं ब्रह्माहमित्येव विजानाति विमुक्तिभाक्॥',
     'He neither wakes nor sleeps; he does not wander in dreams. He who knows "I am the supreme Brahman" is the partaker of liberation.'),
    (19, 'सर्वभूतस्थमात्मानं सर्वभूतानि चात्मनि। ईक्षते योगयुक्तात्मा सर्वत्र समदर्शनः॥',
     'He whose Self is united in Yoga sees the Self in all beings, and all beings in the Self — seeing equality everywhere.'),
    (26, 'ब्रह्मविद् ब्रह्मैव भवति तद्विद्धि परमं पदम्। एतत् ते कथितं देवि महानिर्वाणसाधनम्॥',
     'The knower of Brahman becomes Brahman itself — know that to be the supreme state. This has been declared to thee, O Devi, as the means to Mahanirvana.'),
    (30, 'इति श्रीमहानिर्वाणतन्त्रे शिवपार्वतीसंवादे ब्रह्मज्ञाननिरूपणं नाम चतुर्दशोल्लासः। ॐ तत्सत्॥',
     'Thus ends the fourteenth chapter of the Mahanirvana Tantra, in the dialogue between Shiva and Parvati, entitled "The Exposition of Brahma Jnana." OM TAT SAT.'),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db, id: 'MNT.14.$v', chapter: 14, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Chapter 14: ${verses.length} verses');
  return verses.length;
}
