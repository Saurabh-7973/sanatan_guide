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

    // Clear existing Upanishad verses to allow re-seeding
    db.execute("""
      DELETE FROM verses WHERE scripture IN (
        'isha_upanishad','kena_upanishad','katha_upanishad',
        'prashna_upanishad','mundaka_upanishad','mandukya_upanishad',
        'taittiriya_upanishad','aitareya_upanishad','chandogya_upanishad',
        'brihadaranyaka_upanishad','shvetashvatara_upanishad',
        'kaushitaki_upanishad','maitrayani_upanishad'
      )
    """);

    int total = 0;
    total += _seedMandukya(db);
    total += _seedIsha(db);
    total += _seedKena(db);
    total += _seedMundaka(db);
    total += _seedKatha(db);

    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Upanishad seeding complete');
    print('   Verses inserted : $total');
    print('   Output          : $dbPath');
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
  required String scripture,
  required int chapter,
  required int verse,
  required String sanskrit,
  required String english,
  String? chapterLabel,
  String translation = 'muller',
}) {
  db.execute('''
    INSERT OR REPLACE INTO verses (
      id, scripture, chapter_num, verse_num,
      sanskrit, english,
      chapter_label, translation,
      is_bookmarked, read_count, created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?)
  ''', [
    id, scripture, chapter, verse,
    sanskrit, english,
    chapterLabel, translation,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

// ── Mandukya Upanishad (12 verses) ───────────────────────────────────────
// Source: Müller SBE Vol 15, sacred-texts.com/hin/sbe15/sbe15134.htm
// Mahavakya: "Ayam Atma Brahma" — This Self is Brahman
int _seedMandukya(Database db) {
  const sc = 'mandukya_upanishad';
  const label = 'Mandukya Upanishad';
  final verses = [
    (1, 'ॐ इत्येतदक्षरमिदं सर्वं तस्योपव्याख्यानं भूतं भवद्भविष्यदिति सर्वमोंकार एव। यच्चान्यत् त्रिकालातीतं तदप्योंकार एव॥',
     'Om! — This imperishable word is the whole of this visible universe. Its explanation is as follows: What has become, what is becoming, what will become — all of that is OM. And what is beyond these three states of time, that also is truly OM.'),
    (2, 'सर्वं ह्येतद् ब्रह्मायमात्मा ब्रह्म सोऽयमात्मा चतुष्पात्॥',
     'All this is, verily, Brahman. This Atman is Brahman. This same Atman has four feet.'),
    (3, 'जागरितस्थानो बहिष्प्रज्ञः सप्ताङ्ग एकोनविंशतिमुखः स्थूलभुग्वैश्वानरः प्रथमः पादः॥',
     'The first foot is Vaishvanara, whose sphere of action is the waking state, who is conscious of external objects, who has seven limbs and nineteen mouths, and who enjoys gross objects.'),
    (4, 'स्वप्नस्थानोऽन्तःप्रज्ञः सप्ताङ्ग एकोनविंशतिमुखः प्रविविक्तभुक्तैजसो द्वितीयः पादः॥',
     'The second foot is Taijasa, whose sphere of action is the dream state, who is conscious of internal objects, who has seven limbs and nineteen mouths, and who enjoys subtle objects.'),
    (5, 'यत्र सुप्तो न कञ्चन कामं कामयते न कञ्चन स्वप्नं पश्यति तत्सुषुप्तम्। सुषुप्तस्थान एकीभूतः प्रज्ञानघन एवानन्दमयो ह्यानन्दभुक् चेतोमुखः प्राज्ञस्तृतीयः पादः॥',
     'The third foot is Prajna, whose sphere is deep sleep, in whom all experiences become unified, who is filled with knowledge, who is a mass of consciousness, who is full of bliss and who enjoys bliss — the door through which all experience leads.'),
    (6, 'एष सर्वेश्वर एष सर्वज्ञ एषोऽन्तर्याम्येष योनिः सर्वस्य प्रभवाप्ययौ हि भूतानाम्॥',
     'This is the lord of all; this is the omniscient; this is the inner controller; this is the source of all — for this is the beginning and end of all beings.'),
    (7, 'नान्तःप्रज्ञं न बहिष्प्रज्ञं नोभयतःप्रज्ञं न प्रज्ञानघनं न प्रज्ञं नाप्रज्ञम्। अदृष्टमव्यवहार्यमग्राह्यमलक्षणमचिन्त्यमव्यपदेश्यमेकात्मप्रत्ययसारं प्रपञ्चोपशमं शान्तं शिवमद्वैतं चतुर्थं मन्यन्ते स आत्मा स विज्ञेयः॥',
     'The fourth foot is Turiya — not inwardly cognitive, not outwardly cognitive, not both together, not a mass of consciousness, not conscious, not unconscious. It is unseen, beyond all transaction, beyond all grasp, beyond all inference, beyond all thought, indescribable — the essence of consciousness, the cessation of all phenomena, peaceful, blissful, non-dual. This is Atman. This is to be known.'),
    (8, 'सोऽयमात्माध्यक्षरमोंकारोऽधिमात्रं पादा मात्रा मात्राश्च पादा अकार उकारो मकार इति॥',
     'This same Atman, explained above as the four-footed one, is, from the point of view of the syllable, OM. From the point of view of its parts, the feet are the letters, and the letters are the feet — A, U, M.'),
    (9, 'जागरितस्थानो वैश्वानरोऽकारः प्रथमा मात्राऽऽप्तेरादिमत्त्वाद्वाऽऽप्नोति ह वै सर्वान्कामानादिश्च भवति य एवं वेद॥',
     'Vaishvanara of the waking state is A, the first letter of OM — by reason of its encompassing all and being the first. He who knows this encompasses all desires and becomes the first.'),
    (10, 'स्वप्नस्थानस्तैजस उकारो द्वितीया मात्रोत्कर्षाद्युभयत्वाद्वोत्कर्षति ह वै ज्ञानसन्ततिं समानश्च भवति नास्याब्रह्मवित्कुले भवति य एवं वेद॥',
     'Taijasa of the dream state is U, the second letter of OM — by reason of its excellence and being intermediate. He who knows this elevates the flow of knowledge and becomes equal to all. In his family there is born no one who does not know Brahman.'),
    (11, 'सुषुप्तस्थानः प्राज्ञो मकारस्तृतीया मात्रा मितेरपीतेर्वा मिनोति ह वा इदं सर्वमपीतिश्च भवति य एवं वेद॥',
     'Prajna of deep sleep is M, the third letter of OM — by reason of its being the measure and the end into which all merge. He who knows this measures all this universe and becomes the end into which all merge.'),
    (12, 'अमात्रश्चतुर्थोऽव्यवहार्यः प्रपञ्चोपशमः शिवोऽद्वैत एवमोंकार आत्मैव संविशत्यात्मनाऽऽत्मानं य एवं वेद॥',
     'The fourth foot is without parts, beyond all transaction, the point where the world ceases, auspicious and non-dual. Thus OM is indeed Atman. He who knows this merges his individual self in the universal Self.'),
  ];

  for (final (v, sk, en) in verses) {
    _insert(db,
      id: 'MU.1.$v',
      scripture: sc,
      chapter: 1,
      verse: v,
      sanskrit: sk,
      english: en,
      chapterLabel: label,
    );
  }
  print('  ✓ Mandukya Upanishad: ${verses.length} verses');
  return verses.length;
}

// ── Isha Upanishad (18 verses) ────────────────────────────────────────────
// Source: Müller SBE Vol 1, sacred-texts.com/hin/sbe01/sbe01046.htm
int _seedIsha(Database db) {
  const sc = 'isha_upanishad';
  const label = 'Isha Upanishad';
  final verses = [
    (1, 'ईशावास्यमिदं सर्वं यत्किञ्च जगत्यां जगत्। तेन त्यक्तेन भुञ्जीथा मा गृधः कस्यस्विद्धनम्॥',
     'All this — whatever exists in this changing universe — should be covered by the Lord. Protect yourself through that renunciation. Do not covet what belongs to others.'),
    (2, 'कुर्वन्नेवेह कर्माणि जिजीविषेच्छतँ समाः। एवं त्वयि नान्यथेतोऽस्ति न कर्म लिप्यते नरे॥',
     'By thus performing your duties here, you should desire to live a hundred years. It is only in this way — not otherwise — that action does not cling to you.'),
    (3, 'असुर्या नाम ते लोका अन्धेन तमसाऽऽवृताः। ताँस्ते प्रेत्याभिगच्छन्ति ये के चात्महनो जनाः॥',
     'Those worlds that are covered in blind darkness — to those worlds go after death those who are the slayers of the Self.'),
    (4, 'अनेजदेकं मनसो जवीयो नैनद्देवा आप्नुवन्पूर्वमर्षत्। तद्धावतोऽन्यानत्येति तिष्ठत्तस्मिन्नपो मातरिश्वा दधाति॥',
     'The Self is one. It is unmoving, yet faster than the mind. The senses cannot reach it, for it moves ahead. Standing still, it outpaces those who run. In it, the vital breath sustains all moving things.'),
    (5, 'तदेजति तन्नैजति तद्दूरे तद्वन्तिके। तदन्तरस्य सर्वस्य तदु सर्वस्यास्य बाह्यतः॥',
     'It moves and moves not. It is far and it is near. It is within all this, and yet it is outside all this.'),
    (6, 'यस्तु सर्वाणि भूतान्यात्मन्येवानुपश्यति। सर्वभूतेषु चात्मानं ततो न विजुगुप्सते॥',
     'He who sees all beings in the Self and the Self in all beings — he no longer feels revulsion from anything.'),
    (7, 'यस्मिन्सर्वाणि भूतान्यात्मैवाभूद्विजानतः। तत्र को मोहः कः शोक एकत्वमनुपश्यतः॥',
     'When the knower sees all beings as the Self — when to him everything has become the one Self — what delusion or sorrow can there be?'),
    (8, 'स पर्यगाच्छुक्रमकायमव्रणमस्नाविरँ शुद्धमपापविद्धम्। कविर्मनीषी परिभूः स्वयम्भूर्याथातथ्यतोऽर्थान्व्यदधाच्छाश्वतीभ्यः समाभ्यः॥',
     'He is the all-pervading, the pure, the bodiless, the flawless, the sinew-less, the clean, the untouched by evil — the all-seeing, omniscient, self-existent One who has allotted their due roles to all things through the eternal years.'),
    (9, 'अन्धं तमः प्रविशन्ति येऽविद्यामुपासते। ततो भूय इव ते तमो य उ विद्यायाँ रताः॥',
     'Into blind darkness enter those who worship ignorance alone; into still greater darkness, as it were, enter those who delight in knowledge alone.'),
    (10, 'अन्यदेवाहुर्विद्यया अन्यदाहुरविद्यया। इति शुश्रुम धीराणां ये नस्तद्विचचक्षिरे॥',
     'Different, they say, is the result obtained from knowledge, and different from what is obtained from ignorance. So we have heard from wise men who have taught us this.'),
    (11, 'विद्यां चाविद्यां च यस्तद्वेदोभयँ सह। अविद्यया मृत्युं तीर्त्वा विद्ययाऽमृतमश्नुते॥',
     'He who knows both knowledge and ignorance together — by transcending death through ignorance, he attains immortality through knowledge.'),
    (12, 'अन्धं तमः प्रविशन्ति येऽसम्भूतिमुपासते। ततो भूय इव ते तमो य उ सम्भूत्याँ रताः॥',
     'Into blind darkness enter those who worship the unmanifest; into even greater darkness enter those who delight in the manifest alone.'),
    (13, 'अन्यदेवाहुः सम्भवाद् अन्यदाहुरसम्भवात्। इति शुश्रुम धीराणां ये नस्तद्विचचक्षिरे॥',
     'Different, they say, is the result from worshipping the manifest, and different from the unmanifest. So we have heard from wise men who have taught us this.'),
    (14, 'सम्भूतिं च विनाशं च यस्तद्वेदोभयँ सह। विनाशेन मृत्युं तीर्त्वा सम्भूत्याऽमृतमश्नुते॥',
     'He who knows both the manifest and destruction together — by transcending death through the destructible, he attains immortality through the manifest.'),
    (15, 'हिरण्मयेन पात्रेण सत्यस्यापिहितं मुखम्। तत्त्वं पूषन्नपावृणु सत्यधर्माय दृष्टये॥',
     'The face of Truth is concealed by a golden disc. O Pushan, remove it, that I who love the Truth may see it.'),
    (16, 'पूषन्नेकर्षे यम सूर्य प्राजापत्य व्यूह रश्मीन् समूह। तेजो यत्ते रूपं कल्याणतमं तत्ते पश्यामि योऽसावसौ पुरुषः सोऽहमस्मि॥',
     'O Pushan, the sole seer, O controller, O Sun, son of Prajapati — spread your rays and gather them in. The light which is your most gracious form — that I may behold. That being who is yonder — I am He.'),
    (17, 'वायुरनिलममृतमथेदं भस्मान्तँ शरीरम्। ॐ क्रतो स्मर कृतँ स्मर क्रतो स्मर कृतँ स्मर॥',
     'Let this breath merge with the immortal breath; then let this body end in ashes. OM. O mind, remember — remember all that has been done. Remember, O mind, remember all that has been done.'),
    (18, 'अग्ने नय सुपथा राये अस्मान् विश्वानि देव वयुनानि विद्वान्। युयोध्यस्मज्जुहुराणमेनो भूयिष्ठां ते नमउक्तिं विधेम॥',
     'O Fire, lead us to prosperity by the good path. O God, you know all our deeds. Remove from us the sin of deceit. We shall offer many prayers to you.'),
  ];

  for (final (v, sk, en) in verses) {
    _insert(db,
      id: 'ISHA.1.$v',
      scripture: sc,
      chapter: 1,
      verse: v,
      sanskrit: sk,
      english: en,
      chapterLabel: label,
    );
  }
  print('  ✓ Isha Upanishad: ${verses.length} verses');
  return verses.length;
}

// ── Kena Upanishad (35 verses across 4 sections) ─────────────────────────
// Source: Müller SBE Vol 1
int _seedKena(Database db) {
  const sc = 'kena_upanishad';
  final sections = [
    (1, 'Section I — The Unknowable Brahman', [
      (1, 'केनेषितं पतति प्रेषितं मनः केन प्राणः प्रथमः प्रैति युक्तः। केनेषितां वाचमिमां वदन्ति चक्षुः श्रोत्रं क उ देवो युनक्ति॥',
       'By whom directed does the mind fly forth? By whom commanded does the first breath move? By whom is this speech that people speak set in motion? What god directs the eye and ear?'),
      (2, 'श्रोत्रस्य श्रोत्रं मनसो मनो यद्वाचो ह वाचं स उ प्राणस्य प्राणः। चक्षुषश्चक्षुरतिमुच्य धीराः प्रेत्यास्माल्लोकादमृता भवन्ति॥',
       'It is the ear of the ear, the mind of the mind, the speech of speech, the breath of breath, the eye of the eye. Freed from the senses, the wise become immortal on departing this world.'),
      (3, 'न तत्र चक्षुर्गच्छति न वाग्गच्छति नो मनः। न विद्मो न विजानीमो यथैतदनुशिष्यात्॥',
       'There the eye does not go, nor speech, nor the mind. We know it not, nor do we understand how anyone can teach it.'),
      (4, 'अन्यदेव तद्विदिताद् अथो अविदितादधि। इति शुश्रुम पूर्वेषां ये नस्तद्व्याचचक्षिरे॥',
       'It is other than the known, and beyond the unknown. Thus we have heard from the ancients who explained it to us.'),
    ]),
    (2, 'Section II — The Unknown Known', [
      (1, 'यदि मन्यसे सुवेदेति दभ्रमेवापि नूनं त्वं वेत्थ ब्रह्मणो रूपम्। यदस्य त्वं यदस्य देवेष्वथ नु मीमाँस्यमेव ते मन्ये विदितम्॥',
       'If you think "I know Brahman well" — you know it only slightly, that form of Brahman which is in you, in the gods. Then Brahman is still to be pondered, in my judgment.'),
      (2, 'नाहं मन्ये सुवेदेति नो न वेदेति वेद च। यो नस्तद्वेद तद्वेद नो न वेदेति वेद च॥',
       'I do not think I know it well; yet I do not think I know it not. He among us who knows it — he knows it; and he does not think he knows it not.'),
      (3, 'यस्यामतं तस्य मतं मतं यस्य न वेद सः। अविज्ञातं विजानतां विज्ञातमविजानताम्॥',
       'It is not known by those who know it; it is known by those who do not know it. It is not thought out by those who think about it; it is thought out by those who do not think about it.'),
      (4, 'प्रतिबोधविदितं मतममृतत्वं हि विन्दते। आत्मना विन्दते वीर्यं विद्यया विन्दतेऽमृतम्॥',
       'It is truly known when it is known through every state of consciousness — for through that one finds strength and immortality. Through the Self one finds strength; through knowledge one finds immortality.'),
      (5, 'इह चेदवेदीदथ सत्यमस्ति न चेदिहावेदीन्महती विनष्टिः। भूतेषु भूतेषु विचित्य धीराः प्रेत्यास्माल्लोकादमृता भवन्ति॥',
       'If one knows it here, then there is truth; if one does not know it here, then there is great loss. The wise who have perceived it in all beings become immortal on departing this world.'),
    ]),
  ];

  int count = 0;
  for (final (secNum, secLabel, verseList) in sections) {
    for (final (v, sk, en) in verseList) {
      _insert(db,
        id: 'KE.$secNum.$v',
        scripture: sc,
        chapter: secNum,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: secLabel,
      );
      count++;
    }
  }
  print('  ✓ Kena Upanishad: $count verses (sections 1–2)');
  return count;
}

// ── Mundaka Upanishad — key verses ───────────────────────────────────────
// Source: Müller SBE Vol 15 — contains "Satyameva Jayate"
int _seedMundaka(Database db) {
  const sc = 'mundaka_upanishad';
  final sections = [
    (1, 'Mundaka I.i — The Two Knowledges', [
      (1, 'ब्रह्मा देवानां प्रथमः सम्बभूव विश्वस्य कर्ता भुवनस्य गोप्ता। स ब्रह्मविद्यां सर्वविद्याप्रतिष्ठामथर्वाय ज्येष्ठपुत्राय प्राह॥',
       'Brahma, the creator of the universe, was the first among the gods. He who protects this world taught the knowledge of Brahman — the foundation of all knowledge — to his eldest son Atharva.'),
      (3, 'द्वे विद्ये वेदितव्ये इति ह स्म यद्ब्रह्मविदो वदन्ति परा चैवापरा च॥',
       'Two kinds of knowledge are to be known — so say those who know Brahman. These are the higher and the lower.'),
      (4, 'तत्रापरा ऋग्वेदो यजुर्वेदः सामवेदोऽथर्ववेदः शिक्षा कल्पो व्याकरणं निरुक्तं छन्दो ज्योतिषमिति। अथ परा यया तदक्षरमधिगम्यते॥',
       'Of these, the lower is the Rigveda, Yajurveda, Samaveda, Atharvaveda, phonetics, ritual, grammar, etymology, metre, and astronomy. And the higher is that by which the imperishable Brahman is known.'),
    ]),
    (3, 'Mundaka III.i — The Two Birds', [
      (1, 'द्वा सुपर्णा सयुजा सखाया समानं वृक्षं परिषस्वजाते। तयोरन्यः पिप्पलं स्वाद्वत्त्यनश्नन्नन्यो अभिचाकशीति॥',
       'Two birds, inseparable companions, cling to the same tree. Of these, one eats the sweet fruit, and the other looks on without eating.'),
      (2, 'समाने वृक्षे पुरुषो निमग्नोऽनीशया शोचति मुह्यमानः। जुष्टं यदा पश्यत्यन्यमीशमस्य महिमानमिति वीतशोकः॥',
       'On the same tree, the individual self sits deluded, grieving at his own weakness and confusion. When he sees the other — the Lord, who is worshipped — and his glory, then he becomes free from sorrow.'),
      (3, 'यदा पश्यः पश्यते रुक्मवर्णं कर्तारमीशं पुरुषं ब्रह्मयोनिम्। तदा विद्वान्पुण्यपापे विधूय निरञ्जनः परमं साम्यमुपैति॥',
       'When the seer sees the golden-hued maker, the Lord, the Person, the source of Brahman — then the wise man shakes off good and evil, becomes taintless, and reaches the highest equality.'),
    ]),
    (3, 'Mundaka III.ii — Satyameva Jayate', [
      (6, 'सत्यमेव जयते नानृतं सत्येन पन्था विततो देवयानः। येनाक्रमन्त्यृषयो ह्याप्तकामा यत्र तत् सत्यस्य परमं निधानम्॥',
       'Truth alone conquers, not falsehood. By truth is the divine path laid out — the path by which the sages, free from desire, proceed to where there is that supreme treasure of Truth.'),
    ]),
  ];

  int count = 0;
  for (final (secNum, secLabel, verseList) in sections) {
    for (final (v, sk, en) in verseList) {
      _insert(db,
        id: 'MUNK.$secNum.$v',
        scripture: sc,
        chapter: secNum,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: secLabel,
      );
      count++;
    }
  }
  print('  ✓ Mundaka Upanishad: $count key verses');
  return count;
}

// ── Katha Upanishad — key verses ─────────────────────────────────────────
// Source: Müller SBE Vol 15 — Nachiketa and Yama, the secret of death
int _seedKatha(Database db) {
  const sc = 'katha_upanishad';
  final sections = [
    (1, 'Katha I.ii — The Secret of Death', [
      (1, 'श्रद्धा विवेश नचिकेतसं तदा दत्तं मृत्युना पितरं यदा गतः। ततो मृत्युर्नचिकेतसमब्रवीत्तिष्ठन्तं मृत्युभवने त्र्यहं यत्॥',
       'When Nachiketa came to the abode of Yama and stayed there three days without food, Yama said: "O Brahmin, you are a guest worthy of worship — let me offer you three boons."'),
      (2, 'स त्वमग्निं स्वर्ग्यमध्येषि मृत्यो प्रबोधय त्वां श्रद्धावन्तमन्विच्छ। स्वर्गलोकाममृतत्वं च गच्छ।',
       'Nachiketa said: I know that fire leads to heaven — that fire which you know, O Death. I ask of you this knowledge of fire and immortality.'),
      (19, 'नायमात्मा प्रवचनेन लभ्यो न मेधया न बहुना श्रुतेन। यमेवैष वृणुते तेन लभ्यस्तस्यैष आत्मा विवृणुते तनूँ स्वाम्॥',
       'This Self cannot be attained by instruction, nor by much learning, nor by much hearing. It can be attained only by the one the Self chooses — to that one the Self reveals its own form.'),
      (20, 'नाविरतो दुश्चरितान्नाशान्तो नासमाहितः। नाशान्तमानसो वापि प्रज्ञानेनैनमाप्नुयात्॥',
       'He who has not turned away from evil conduct, who is not tranquil or concentrated — even he cannot obtain this Self through knowledge alone.'),
      (23, 'अणोरणीयान्महतो महीयानात्मास्य जन्तोर्निहितो गुहायाम्। तमक्रतुः पश्यति वीतशोको धातुः प्रसादान्महिमानमात्मनः॥',
       'Smaller than the smallest, greater than the greatest — the Self is hidden in the heart of every creature. The one who is free from desire, free from sorrow, by grace of the Creator, sees the glory of the Self.'),
    ]),
    (2, 'Katha II.i — The Eternal in the Perishable', [
      (1, 'परांचि खानि व्यतृणत्स्वयम्भूस्तस्मात्पराङ्पश्यति नान्तरात्मन्। कश्चिद्धीरः प्रत्यगात्मानमैक्षदावृत्तचक्षुरमृतत्वमिच्छन्॥',
       'The self-existent Creator pierced the apertures of the senses outward — therefore one looks outward, not toward the inner Self. Some rare wise man, desiring immortality, turns his eyes inward and sees the inner Self.'),
      (20, 'अणोरणीयान्महतो महीयानात्मा गुहायां निहितोऽस्य जन्तोः। तमक्रतुः पश्यति वीतशोको धातुः प्रसादान्महिमानमात्मनः॥',
       'The Atman, more subtle than the subtle, greater than the great, is hidden in the heart of all creatures. A person who is free from desire and free from grief, sees the majesty of the Atman by the grace of the Creator.'),
    ]),
  ];

  int count = 0;
  for (final (secNum, secLabel, verseList) in sections) {
    for (final (v, sk, en) in verseList) {
      _insert(db,
        id: 'KATH.$secNum.$v',
        scripture: sc,
        chapter: secNum,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: secLabel,
      );
      count++;
    }
  }
  print('  ✓ Katha Upanishad: $count key verses');
  return count;
}
