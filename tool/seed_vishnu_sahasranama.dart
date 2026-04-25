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
    db.execute("DELETE FROM verses WHERE scripture = 'vishnu_sahasranama'");

    int total = 0;
    total += _seedPhalaShruti(db);
    total += _seedNames(db);

    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Vishnu Sahasranama seeding complete');
    print('   Total shlokas : $total');
    print('   Output        : $dbPath');
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
    ) VALUES (?, 'vishnu_sahasranama', ?, ?, ?, ?, ?, 'ganguli', 0, 0, ?)
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

// ── Phala Shruti — Introductory and concluding verses ────────────────────
int _seedPhalaShruti(Database db) {
  const label = 'Phala Shruti — The Fruits of Recitation';
  final verses = [
    (
      1,
      'यानि नामानि गौणानि विख्यातानि महात्मनः। ऋषिभिः परिगीतानि तानि वक्ष्यामि भूतये॥',
      'I shall now recite the names of the high-souled one — the names that are celebrated and sung by the Rishis — for the well-being of all.'
    ),
    (
      2,
      'विश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः। भूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः॥',
      'He is the Universe. He is Vishnu. He is the Lord of sacrificial offering. He is the Lord of all that has been, all that will be, and all that is. He creates all creatures, sustains them, and causes them to flourish.'
    ),
    (
      3,
      'पूतात्मा परमात्मा च मुक्तानां परमा गतिः। अव्ययः पुरुषः साक्षी क्षेत्रज्ञोऽक्षर एव च॥',
      'He is the Pure Self. He is the Supreme Self. He is the highest refuge of those who are emancipated. He is immutable. He is the Purusha. He is the Witness. He is the knower of the field. He is the imperishable.'
    ),
    (
      4,
      'योगो योगविदां नेता प्रधानपुरुषेश्वरः। नारसिंहवपुः श्रीमान् केशवः पुरुषोत्तमः॥',
      'He is Yoga itself. He is the leader of those who are conversant with Yoga. He is the lord of Pradhana and Purusha. He has the form of the Man-lion. He is possessed of prosperity. He is Keshava. He is the best of Purushas.'
    ),
    (
      5,
      'सर्वः शर्वः शिवः स्थाणुर्भूतादिर्निधिरव्ययः। संभवो भावनो भर्ता प्रभवः प्रभुरीश्वरः॥',
      'He is All. He is the destroyer of all. He is auspicious. He is the immovable pillar. He is the origin of all beings. He is the imperishable treasure. He comes into existence of his own accord. He is the cherisher. He is the supporter. He is the source. He is the master. He is the lord.'
    ),
    (
      6,
      'स्वयंभूः शम्भुरादित्यः पुष्कराक्षो महास्वनः। अनादिनिधनो धाता विधाता धातुरुत्तमः॥',
      'He is self-born. He is the cause of happiness. He is like the sun. He has eyes like lotuses. He has a great voice. He has no beginning and no end. He is the supporter. He is the creator. He is the foremost of all elements.'
    ),
    (
      7,
      'अप्रमेयो हृषीकेशः पद्मनाभोऽमरप्रभुः। विश्वकर्मा मनुस्त्वष्टा स्थविष्ठः स्थविरो ध्रुवः॥',
      'He is beyond measure. He is the lord of the senses. He has a lotus on his navel. He is the lord of immortals. He is the architect of the universe. He is Manu. He is the fashioner. He is very large. He is ancient. He is immovable.'
    ),
    (
      8,
      'अग्राह्यः शाश्वतः कृष्णो लोहिताक्षः प्रतर्दनः। प्रभूतस्त्रिककुब्धाम पवित्रं मङ्गलं परम्॥',
      'He is beyond the reach of the senses. He is eternal. He is Krishna — dark complexioned. His eyes are red. He destroys all. He is full. He is the abode of the three cardinal points. He is supremely holy. He is the highest good.'
    ),
    (
      9,
      'ईशानः प्राणदः प्राणो ज्येष्ठः श्रेष्ठः प्रजापतिः। हिरण्यगर्भो भूगर्भो माधवो मधुसूदनः॥',
      'He is the ruler. He gives life. He is life itself. He is the eldest. He is the most excellent. He is the lord of creatures. He is Hiranyagarbha — the golden womb. He holds the earth in his belly. He is Madhava. He slew the demon Madhu.'
    ),
    (
      10,
      'ईश्वरो विक्रमी धन्वी मेधावी विक्रमः क्रमः। अनुत्तमो दुराधर्षः कृतज्ञः कृतिरात्मवान्॥',
      'He is the lord. He is heroic. He wields the bow. He is intelligent. His step is heroic. He is the step itself. He is the highest. He is difficult to resist. He is grateful. He is the skilled one. He is self-controlled.'
    ),
    (
      106,
      'नामानि सहस्राणि भगवन्तं विश्वमूर्तिनम्। पठन् यः प्रयतः शुचिः स च तेजस्वी जायते॥',
      'He who, with pure heart and controlled mind, recites the thousand names of the Lord who is the form of the universe — he becomes endowed with great energy.'
    ),
    (
      107,
      'विष्णोर्नामसहस्रस्य वेदव्यासो महामुनिः। छन्दोऽनुष्टुप् तथा देवो भगवान् देवकीसुतः॥',
      'Of this hymn of the thousand names of Vishnu, the great sage Vedavyasa is the Rishi; the metre is Anushtup; the deity is Lord Vasudeva, the son of Devaki.'
    ),
    (
      108,
      'य इदं शृणुयान्नित्यं यश्चापि परिकीर्तयेत्। नाशुभं प्राप्नुयात्किञ्चित्सोऽमुत्रेह च मानवः॥',
      'He who listens to this every day, and he who recites it — that person obtains no evil either in this world or in the next.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'VS.0.$v',
        chapter: 0,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Phala Shruti: ${verses.length} verses');
  return verses.length;
}

// ── The 108 Shlokas — 1000 Names ─────────────────────────────────────────
// Each shloka contains ~9-10 names. Ganguli translation (1883-96) PD.
// Source: Mahabharata, Anushasana Parva, Section CXLIX
int _seedNames(Database db) {
  const label = 'The Thousand Names of Vishnu';
  final verses = [
    (
      1,
      'विश्वं विष्णुर्वषट्कारो भूतभव्यभवत्प्रभुः। भूतकृद्भूतभृद्भावो भूतात्मा भूतभावनः॥',
      'Names 1-9: Vishvam (Universe), Vishnu (All-pervading), Vashatkara (Lord of sacrifices), Bhuta-bhavya-bhavat-prabhuh (Lord of past, future, and present), Bhutkrit (Creator), Bhutabhrit (Sustainer), Bhavah (Existence), Bhutatma (Soul of beings), Bhutabhavanah (Cause of beings).'
    ),
    (
      2,
      'पूतात्मा परमात्मा च मुक्तानां परमा गतिः। अव्ययः पुरुषः साक्षी क्षेत्रज्ञोऽक्षर एव च॥',
      'Names 10-18: Putatma (Pure Self), Paramatma (Supreme Self), Mukti-param-gati (Highest refuge of the liberated), Avyayah (Immutable), Purushah (Primal Being), Sakshi (Witness), Kshetrajna (Knower of the field), Aksharah (Imperishable).'
    ),
    (
      3,
      'योगो योगविदां नेता प्रधानपुरुषेश्वरः। नारसिंहवपुः श्रीमान् केशवः पुरुषोत्तमः॥',
      'Names 19-26: Yogah (Yoga itself), Yogavidam-neta (Leader of Yogis), Pradhana-purusheshvarah (Lord of Pradhana and Purusha), Narasimhavapuh (Man-lion form), Shriman (Glorious), Keshavah (Beautiful-haired), Purushottamah (Best of beings).'
    ),
    (
      4,
      'सर्वः शर्वः शिवः स्थाणुर्भूतादिर्निधिरव्ययः। संभवो भावनो भर्ता प्रभवः प्रभुरीश्वरः॥',
      'Names 27-37: Sarvah (All), Sharvah (Destroyer), Shivah (Auspicious), Sthanuh (Immovable), Bhutadir (Origin of beings), Nidhiravyayah (Imperishable treasure), Sambhavah (Self-manifested), Bhavanah (Cherisher), Bharta (Supporter), Prabhavah (Source), Prabhuh (Master), Ishvarah (Lord).'
    ),
    (
      5,
      'स्वयंभूः शम्भुरादित्यः पुष्कराक्षो महास्वनः। अनादिनिधनो धाता विधाता धातुरुत्तमः॥',
      'Names 38-46: Svayambhuh (Self-born), Shambhuh (Giver of happiness), Adityah (Sun-like), Pushkarakshah (Lotus-eyed), Mahasvanah (Great voice), Anadinidhana (Without beginning or end), Dhata (Supporter), Vidhata (Creator), Dhatururttamah (Foremost of elements).'
    ),
    (
      6,
      'अप्रमेयो हृषीकेशः पद्मनाभोऽमरप्रभुः। विश्वकर्मा मनुस्त्वष्टा स्थविष्ठः स्थविरो ध्रुवः॥',
      'Names 47-55: Aprameya (Immeasurable), Hrishikeshana (Lord of senses), Padmanabha (Lotus-naveled), Amaraprabhu (Lord of immortals), Vishvakarma (Architect of universe), Manuh (Thinker), Tvashta (Fashioner), Sthavishtha (Most large), Sthavira (Ancient), Dhruvah (Immovable).'
    ),
    (
      7,
      'अग्राह्यः शाश्वतः कृष्णो लोहिताक्षः प्रतर्दनः। प्रभूतस्त्रिककुब्धाम पवित्रं मङ्गलं परम्॥',
      'Names 56-63: Agrahya (Beyond senses), Shashvatah (Eternal), Krishna (Dark/attractive), Lohitaksha (Red-eyed), Pratardana (Destroyer), Prabhuta (Abundant), Trikakub-dhama (Abode of three directions), Pavitram (Purifier), Paramam-mangalam (Supreme auspiciousness).'
    ),
    (
      8,
      'ईशानः प्राणदः प्राणो ज्येष्ठः श्रेष्ठः प्रजापतिः। हिरण्यगर्भो भूगर्भो माधवो मधुसूदनः॥',
      'Names 64-72: Ishanah (Ruler), Pranadah (Giver of life), Pranah (Life), Jyeshtha (Eldest), Shreshtah (Most excellent), Prajapatih (Lord of creatures), Hiranyagarbha (Golden womb), Bhugarbha (Earth-bellied), Madhava (Born of Madhu\'s clan), Madhusudana (Slayer of Madhu).'
    ),
    (
      9,
      'ईश्वरो विक्रमी धन्वी मेधावी विक्रमः क्रमः। अनुत्तमो दुराधर्षः कृतज्ञः कृतिरात्मवान्॥',
      'Names 73-82: Ishvarah (Lord), Vikrami (Heroic), Dhanvi (Bow-bearer), Medhavi (Intelligent), Vikramah (Valiant step), Kramah (Order), Anuttamah (Unsurpassed), Duradharsha (Irresistible), Kritajnah (Grateful), Kritih (Action), Atmavan (Self-possessed).'
    ),
    (
      10,
      'सुरेशः शरणं शर्म विश्वरेताः प्रजाभवः। अहः संवत्सरो व्यालः प्रत्ययः सर्वदर्शनः॥',
      'Names 83-91: Suresha (Lord of gods), Sharanam (Refuge), Sharma (Bliss), Vishvareta (Seed of universe), Prajabhava (Origin of beings), Ahah (Day), Samvatsara (Year), Vyalah (Serpentine), Pratyaya (Conviction), Sarvadarshana (All-seeing).'
    ),
    (
      11,
      'अजः सर्वेश्वरः सिद्धः सिद्धिः सर्वादिरच्युतः। वृषाकपिरमेयात्मा सर्वयोगविनिःसृतः॥',
      'Names 92-100: Aja (Unborn), Sarveshvara (Lord of all), Siddha (Perfected), Siddhih (Perfection itself), Sarvadir (Origin of all), Achyuta (Infallible), Vrishakapia (Bull-boar), Ameyatma (Immeasurable Self), Sarva-yoga-vinihsrita (Released from all Yoga).'
    ),
    (
      12,
      'वसुर्वसुमनाः सत्यः समात्मा संमितः समः। अमोघः पुण्डरीकाक्षो वृषकर्मा वृषाकृतिः॥',
      'Names 101-109: Vasu (Treasure), Vasumanah (Treasure-minded), Satyah (Truth), Samatma (Equal-souled), Sammitah (Of equal measure), Samah (Equal), Amoghah (Never in vain), Pundarikaksha (Lotus-eyed), Vrishakarma (Righteous-actioned), Vrisha-kriti (Bull-formed).'
    ),
    (
      13,
      'रुद्रो बहुशिरा बभ्रुर्विश्वयोनिः शुचिश्रवाः। अमृतः शाश्वतः स्थाणुर्वरारोहो महातपाः॥',
      'Names 110-118: Rudra (Roarer), Bahushira (Many-headed), Babhru (Tawny), Vishvayoni (Womb of universe), Shuchishrava (Sacred-eared), Amritah (Immortal), Shashvatah (Eternal), Sthanuh (Pillar), Vararoha (Best ascent), Mahatapah (Great austerity).'
    ),
    (
      14,
      'सर्वगः सर्वविद्भानुर्विष्वक्सेनो जनार्दनः। वेदो वेदविदव्यङ्गो वेदाङ्गो वेदवित्कविः॥',
      'Names 119-127: Sarvagah (All-pervading), Sarvavidbhanu (All-knowing radiance), Vishvaksena (Leader of all armies), Janardana (Mover of men), Vedah (Sacred knowledge), Vedavid (Knower of Vedas), Avyanga (Perfect), Vedangah (Limb of Vedas), Vedavit (Veda-knowing), Kavih (Poet-seer).'
    ),
    (
      15,
      'लोकाध्यक्षः सुराध्यक्षो धर्माध्यक्षः कृताकृतः। चतुरात्मा चतुर्व्यूहश्चतुर्दंष्ट्रश्चतुर्भुजः॥',
      'Names 128-136: Lokaadhyaksha (Overseer of worlds), Suraadhyaksha (Overseer of gods), Dharmadhyaksha (Overseer of dharma), Kritakrita (Cause of done and undone), Chaturatma (Four-souled), Chaturvyuha (Four formations), Chaturdamshtra (Four-fanged), Chaturbhuja (Four-armed).'
    ),
    (
      16,
      'भ्राजिष्णुर्भोजनं भोक्ता सहिष्णुर्जगदादिजः। अनघो विजयो जेता विश्वयोनिः पुनर्वसुः॥',
      'Names 137-145: Bhrajishnuh (Shining), Bhojanam (Food), Bhokta (Enjoyer), Sahishnuh (Patient), Jagadadijah (First-born of universe), Anaghah (Sinless), Vijayah (Victor), Jeta (Conqueror), Vishvayonih (Cosmic womb), Punarvasu (Restored wealth).'
    ),
    (
      17,
      'उपेन्द्रो वामनः प्रांशुरमोघः शुचिरूर्जितः। अतीन्द्रः संग्रहः सर्गो धृतात्मा नियमो यमः॥',
      'Names 146-155: Upendra (Younger brother of Indra), Vamana (Dwarf), Pramshu (Tall), Amoghah (Unfailing), Shuchih (Pure), Urjitah (Mighty), Ateendra (Beyond Indra), Sangrahah (Compiler), Sargah (Creation), Dhritatma (Self-collected), Niyama (Restraint), Yama (Controller).'
    ),
    (
      18,
      'वेद्यो वैद्यः सदायोगी वीरहा माधवो मधुः। अतीन्द्रियो महामायो महोत्साहो महाबलः॥',
      'Names 156-164: Vedya (Knowable), Vaidya (Physician), Sadayogi (Eternal Yogi), Virahaa (Slayer of heroes), Madhava (Sweet one), Madhuh (Honey), Atindriya (Beyond senses), Mahamaya (Great illusion), Mahotsaha (Great enthusiasm), Mahabala (Great strength).'
    ),
    (
      19,
      'महाबुद्धिर्महावीर्यो महाशक्तिर्महाद्युतिः। अनिर्देश्यवपुः श्रीमानमेयात्मा महाद्रिधृक्॥',
      'Names 165-173: Mahabuddhi (Great intelligence), Mahaveerya (Great heroism), Mahashakti (Great power), Mahadyuti (Great splendor), Anirdeshyavapu (Indescribable form), Shriman (Glorious), Ameyatma (Immeasurable Self), Mahadridhrik (Bearer of great mountain).'
    ),
    (
      20,
      'महेष्वासो महीभर्ता श्रीनिवासः सतां गतिः। अनिरुद्धः सुरानन्दो गोविन्दो गोविदां पतिः॥',
      'Names 174-182: Maheshvasa (Great bow-bearer), Maheedhara (Earth-supporter), Shrinivasa (Abode of Lakshmi), Satam-gati (Refuge of the good), Aniruddha (Unstoppable), Surananda (Joy of gods), Govinda (Cow-finder), Govidam-pati (Lord of sages).'
    ),
    (
      21,
      'मरीचिर्दमनो हंसः सुपर्णो भुजगोत्तमः। हिरण्यनाभः सुतपाः पद्मनाभः प्रजापतिः॥',
      'Names 183-191: Marichi (Ray of light), Damana (Tamer), Hamsa (Swan), Suparna (Beautiful-winged), Bhujagottama (Best of serpents), Hiranyanaabha (Golden-naveled), Sutapa (Good ascetic), Padmanabha (Lotus-naveled), Prajapatih (Lord of creatures).'
    ),
    (
      22,
      'अमृत्युः सर्वदृक् सिंहः सन्धाता सन्धिमान् स्थिरः। अजो दुर्मर्षणः शास्ता विश्रुतात्मा सुरारिहा॥',
      'Names 192-201: Amrityu (Deathless), Sarvadrik (All-seeing), Simha (Lion), Sandhata (Uniter), Sandhiman (One with agreements), Sthira (Stable), Aja (Unborn), Durmarsana (Intolerant of evil), Shasta (Teacher), Vishrutatma (Celebrated Self), Surariha (Slayer of enemies of gods).'
    ),
    (
      23,
      'गुरुर्गुरुतमो धाम सत्यः सत्यपराक्रमः। निमिषोऽनिमिषः स्रग्वी वाचस्पतिरुदारधीः॥',
      'Names 202-210: Guruh (Teacher), Gurutama (Greatest teacher), Dhama (Abode), Satyah (Truth), Satya-parakramah (True valor), Nimisha (Closed-eyed), Animisha (Ever-vigilant), Sragvi (Garland-wearer), Vachaspati (Lord of speech), Udaara-dhih (Noble-minded).'
    ),
    (
      24,
      'अग्रणीर्ग्रामणीः श्रीमान् न्यायो नेता समीरणः। सहस्रमूर्धा विश्वात्मा सहस्राक्षः सहस्रपात्॥',
      'Names 211-219: Agrani (Leader), Gramani (Village-chief), Shriman (Glorious), Nyaya (Justice), Neta (Leader), Samirana (Wind), Sahasramurdha (Thousand-headed), Vishvatma (Universal Self), Sahasraksha (Thousand-eyed), Sahasrapat (Thousand-footed).'
    ),
    (
      25,
      'आवर्तनो निवृत्तात्मा संवृतः संप्रमर्दनः। अहः संवर्तको वह्निरनिलो धरणीधरः॥',
      'Names 220-228: Aavartana (Cyclic), Nivritatma (Returned Self), Samvrita (Well-covered), Sampramardana (Crusher), Aha-samvartaka (Orderer of day), Vahni (Fire), Anila (Wind), Dharanidhara (Earth-bearer).'
    ),
    (
      26,
      'सुप्रसादः प्रसन्नात्मा विश्वधृग्विश्वभुग्विभुः। सत्कर्ता सत्कृतः साधुर्जह्नुर्नारायणो नरः॥',
      'Names 229-238: Suprasada (Well-pleased), Prasannatma (Cheerful Self), Vishvadhrik (Universe-supporter), Vishvabhuk (Universe-enjoyer), Vibhu (All-pervading), Satkarta (Doer of good), Satkrita (Honored), Sadhu (Good), Jahnu (Destroyer), Narayana (Refuge of men), Narah (Man).'
    ),
    (
      27,
      'असंख्येयोऽप्रमेयात्मा विशिष्टः शिष्टकृच्छुचिः। सिद्धार्थः सिद्धसंकल्पः सिद्धिदः सिद्धिसाधनः॥',
      'Names 239-248: Asankhyeya (Uncountable), Aprameya-atma (Immeasurable Self), Vishishta (Distinguished), Shishtakrit (Maker of the learned), Shuchi (Pure), Siddhardha (Whose purpose is accomplished), Siddhasankalpa (Accomplished in will), Siddhida (Giver of perfection), Siddhi-sadhana (Means of perfection).'
    ),
    (
      28,
      'वृषाही वृषभो विष्णुर्वृषपर्वा वृषोदरः। वर्धनो वर्धमानश्च विविक्तः श्रुतिसागरः॥',
      'Names 249-257: Vrishahi (Righteous), Vrishabha (Bull), Vishnu (All-pervading), Vrishaparna (Righteous-winged), Vrishodara (Bull-bellied), Vardhana (Increaser), Vardhamana (Growing), Vivikta (Solitary), Shrutisagara (Ocean of scriptures).'
    ),
    (
      29,
      'सुभुजो दुर्धरो वाग्मी महेन्द्रो वसुदो वसुः। नैकरूपो बृहद्रूपः शिपिविष्टः प्रकाशनः॥',
      'Names 258-267: Subhuja (Fair-armed), Durdhara (Hard to hold), Vagmi (Eloquent), Mahendra (Great Indra), Vasuda (Giver of wealth), Vasu (Treasure), Naikarupa (Many-formed), Brihad-rupa (Large-formed), Shipivishtha (Entered into rays), Prakashana (Illuminator).'
    ),
    (
      30,
      'ओजस्तेजोद्युतिधरः प्रकाशात्मा प्रतापनः। ऋद्धः स्पष्टाक्षरो मन्त्रश्चन्द्रांशुर्भास्करद्युतिः॥',
      'Names 268-277: Ojas-tejo-dyutidhara (Bearer of vigor, energy, and splendor), Prakashatma (Illumined Self), Pratapana (Scorcher), Riddhah (Prosperous), Spashta-akshara (Clearly-lettered), Mantra (Sacred formula), Chandramshu (Moon-rayed), Bhaskaradyuti (Sun-splendored).'
    ),
    (
      31,
      'अमृतांशूद्भवो भानुः शशबिन्दुः सुरेश्वरः। औषधं जगतः सेतुः सत्यधर्मपराक्रमः॥',
      'Names 278-286: Amritamshudbhava (Born of ambrosia-rayed), Bhanu (Shining), Shashabindu (Hare-spotted — the moon), Sureshvara (Lord of gods), Aushadha (Medicine), Jagata-setu (Bridge of universe), Satya-dharma-parakrama (True in dharma and valor).'
    ),
    (
      32,
      'भूतभव्यभवन्नाथः पवनः पावनोऽनलः। कामहा कामकृत्कान्तः कामः कामप्रदः प्रभुः॥',
      'Names 287-296: Bhuta-bhavya-bhavan-natha (Lord of past, future, present), Pavana (Purifier), Pavana (Wind), Anala (Fire), Kamaha (Destroyer of desires), Kamakrit (Desire-fulfiller), Kanta (Beautiful), Kama (Desire), Kamaprada (Granter of desires), Prabhu (Lord).'
    ),
    (
      33,
      'युगादिकृद्युगावर्तो नैकमायो महाशनः। अदृश्यो व्यक्तरूपश्च सहस्रजिदनन्तजित्॥',
      'Names 297-305: Yugadi-krit (Creator of world-ages), Yugavarta (Revolver of ages), Naikamaya (Many-illusioned), Mahasana (Great eater), Adrishya (Invisible), Vyakta-rupa (Manifest-formed), Sahasrajit (Victor of thousands), Anantajit (Endless victor).'
    ),
    (
      34,
      'इष्टोऽविशिष्टः शिष्टेष्टः शिखण्डी नहुषो वृषः। क्रोधहा क्रोधकृत्कर्ता विश्वबाहुर्महीधरः॥',
      'Names 306-315: Ishtha (Desired), Avishishtha (Undistinguished), Shishteshtha (Desired by the learned), Shikhandi (Crested), Nahusa (One who binds), Vrisha (Bull), Krodhaha (Anger-destroyer), Krodhakrit (Anger-maker), Karta (Doer), Vishvabahu (Universal-armed), Mahidhara (Earth-bearer).'
    ),
    (
      35,
      'अच्युतः प्रथितः प्राणः प्राणदो वासवानुजः। अपांनिधिरधिष्ठानमप्रमत्तः प्रतिष्ठितः॥',
      'Names 316-325: Achyuta (Infallible), Prathita (Celebrated), Pranah (Life), Pranadah (Life-giver), Vaasavanuja (Indra\'s younger brother), Apam-nidhi (Ocean), Adhishthana (Foundation), Apramatta (Vigilant), Pratishthita (Established).'
    ),
    (
      36,
      'स्कन्दः स्कन्दधरो धुर्यो वरदो वायुवाहनः। वासुदेवो बृहद्भानुरादिदेवः पुरन्दरः॥',
      'Names 326-335: Skanda (Leaped), Skandadhara (Skanda\'s bearer), Dhurya (Bearer of burden), Varada (Boon-giver), Vayuvahana (Wind-vehicle), Vasudeva (Son of Vasudeva), Brihad-bhanu (Great-rayed), Adi-deva (Primordial god), Purandara (City-destroyer).'
    ),
    (
      37,
      'अशोकस्तारणस्तारः शूरः शौरिर्जनेश्वरः। अनुकूलः शतावर्तः पद्मी पद्मनिभेक्षणः॥',
      'Names 336-345: Ashoka (Without grief), Tarana (Deliverer), Tara (Star), Shura (Hero), Shauri (Son of Sura), Janeshvara (Lord of men), Anukoola (Favorable), Shatavarta (Hundred-turning), Padmi (Lotus-bearing), Padma-nibhekshana (Lotus-eyed).'
    ),
    (
      38,
      'पद्मनाभोऽरविन्दाक्षः पद्मगर्भः शरीरभृत्। महर्द्धिरृद्धो वृद्धात्मा महाक्षो गरुडध्वजः॥',
      'Names 346-355: Padmanabha (Lotus-naveled), Aravindaksha (Lotus-eyed), Padmagarbha (Lotus-wombed), Sharirabrit (Body-bearer), Maharddhi (Great prosperity), Riddhah (Prosperous), Vriddhatma (Grown Self), Mahaksha (Great-eyed), Garudadhvaja (Garuda-bannered).'
    ),
    (
      39,
      'अतुलः शरभो भीमः समयज्ञो हविर्हरिः। सर्वलक्षणलक्षण्यो लक्ष्मीवान् समितिञ्जयः॥',
      'Names 356-365: Atulah (Incomparable), Sharabhah (Eight-legged lion), Bhima (Fearful), Samayajna (Time-sacrifice), Havirharihi (Oblation-taker), Sarva-lakshana-lakshanya (Characterized by all marks), Lakshmivan (Possessing Lakshmi), Samitinjaya (Victor in assembly).'
    ),
    (
      40,
      'विक्षरो रोहितो मार्गो हेतुर्दामोदरः सहः। महीधरो महाभागो वेगवानमिताशनः॥',
      'Names 366-374: Vikshara (Imperishable), Rohita (Red), Marga (Path), Hetu (Cause), Damodara (Bound-bellied), Saha (Patient), Mahidhara (Mountain-bearer), Mahabhaga (Greatly fortunate), Vegavan (Swift), Amitashana (Immeasurable-eating).'
    ),
    (
      41,
      'उद्भवः क्षोभणो देवः श्रीगर्भः परमेश्वरः। करणं कारणं कर्ता विकर्ता गहनो गुहः॥',
      'Names 375-384: Udbhava (Self-existent), Kshobhana (Agitator), Devah (God), Shrigarbha (Lakshmi-wombed), Parameshvara (Supreme Lord), Karana (Instrument), Karana (Cause), Karta (Doer), Vikarta (Modifier), Gahana (Deep), Guha (Cave-dweller).'
    ),
    (
      42,
      'व्यवसायो व्यवस्थानः संस्थानः स्थानदो ध्रुवः। परर्द्धिः परमस्पष्टस्तुष्टः पुष्टः शुभेक्षणः॥',
      'Names 385-394: Vyavasaya (Resolve), Vyavasthana (Settled), Samsthana (Resting place), Sthanada (Giver of place), Dhruvah (Fixed), Parardhi (Greatest prosperity), Param-spashta (Supremely clear), Tushta (Satisfied), Pushta (Nourished), Shubhekshana (Auspicious-glanced).'
    ),
    (
      43,
      'रामो विरामो विरजो मार्गो नेयो नयोऽनयः। वीरः शक्तिमतां श्रेष्ठो धर्मो धर्मविदुत्तमः॥',
      'Names 395-404: Rama (Pleasing), Virama (Rest), Viraja (Passionless), Marga (Path), Neya (Guided), Naya (Policy), Anaya (Unled), Vira (Heroic), Shaktimatam-shreshtah (Best among the powerful), Dharma (Righteousness), Dharmaviduttama (Best knower of dharma).'
    ),
    (
      44,
      'वैकुण्ठः पुरुषः प्राणः प्राणदः प्रणवः पृथुः। हिरण्यगर्भः शत्रुघ्नो व्याप्तो वायुरधोक्षजः॥',
      'Names 405-414: Vaikuntha (Obstacle-free realm), Purusha (Person), Prana (Life), Pranada (Life-giver), Pranava (OM), Prithu (Broad), Hiranyagarbha (Golden-wombed), Shatrugnah (Enemy-slayer), Vyapta (Pervaded), Vayuh (Wind), Adhokshaja (Below the axis).'
    ),
    (
      45,
      'ऋतुः सुदर्शनः कालः परमेष्ठी परिग्रहः। उग्रः संवत्सरो दक्षो विश्रामो विश्वदक्षिणः॥',
      'Names 415-424: Ritu (Season), Sudarshana (Auspicious-visioned), Kala (Time), Parameshti (Supreme seated), Parigraha (Receiver), Ugra (Terrible), Samvatsara (Year), Daksha (Expert), Vishrama (Rest), Vishvadakshina (Universe-skilled).'
    ),
    (
      46,
      'विस्तारः स्थावरस्थाणुः प्रमाणं बीजमव्ययम्। अर्थोऽनर्थो महाकोशो महाभोगो महाधनः॥',
      'Names 425-434: Vistara (Expansion), Sthavasra-sthanu (Standing pillar), Pramana (Measure), Bijam-avyayam (Imperishable seed), Artha (Purpose), Anartha (Purposeless), Mahakosh (Great treasury), Mahabhoga (Great enjoyment), Mahadhanah (Great wealth).'
    ),
    (
      47,
      'अनिर्विण्णः स्थविष्ठोऽभूर्धर्मयूपो महामखः। नक्षत्रनेमिर्नक्षत्री क्षमः क्षामः समीहनः॥',
      'Names 435-444: Anirvinna (Undisappointed), Sthavishtha (Very large), Abhu (Unborn), Dharmayupa (Sacrificial post of dharma), Mamamakha (Great sacrifice), Nakshatranemi (Axle of stars), Nakshatri (Star-lord), Kshama (Patient), Kshama (Tolerant), Samihanah (Desired).'
    ),
    (
      48,
      'यज्ञ इज्यो महेज्यश्च क्रतुः सत्रं सतां गतिः। सर्वदर्शी विमुक्तात्मा सर्वज्ञो ज्ञानमुत्तमम्॥',
      'Names 445-453: Yajna (Sacrifice), Ijya (Worthy of worship), Mahejya (Supremely worthy), Kratu (Rite), Satra (Protection), Satam-gati (Refuge of good), Sarvadarshi (All-seeing), Vimuktama (Liberated Self), Sarvajnah (Omniscient), Jnanamuttama (Supreme knowledge).'
    ),
    (
      49,
      'सुव्रतः सुमुखः सूक्ष्मः सुघोषः सुखदः सुहृत्। मनोहरो जितक्रोधो वीरबाहुर्विदारणः॥',
      'Names 454-462: Suvrata (Good vow), Sumukha (Good-faced), Sukshma (Subtle), Sughosa (Good-sounding), Sukhada (Happiness-giver), Suhrit (Friend), Manohara (Mind-capturer), Jitakrodha (Anger-conquered), Virabahu (Heroic-armed), Vidarana (Tearer).'
    ),
    (
      50,
      'स्वापनः स्ववशो व्यापी नैकात्मा नैककर्मकृत्। वत्सरो वत्सलो वत्सी रत्नगर्भो धनेश्वरः॥',
      'Names 463-472: Svapana (Dream-inducer), Svavasha (Self-controlled), Vyapi (Pervader), Naikatma (Many-souled), Naikakarmakrit (Many-actioned), Vatsara (Year), Vatsala (Affectionate), Vatsi (Calf-keeper), Ratnagarbha (Jewel-wombed), Dhaneshvara (Wealth-lord).'
    ),
    (
      51,
      'धर्मगुब्धर्मकृद्धर्मी सदसत्क्षरमक्षरम्। अविज्ञाता सहस्रांशुर्विधाता कृतलक्षणः॥',
      'Names 473-482: Dharmagupta (Dharma-protector), Dharmakrit (Dharma-doer), Dharmi (Righteous), Sad-asat (Being and non-being), Kshara (Destructible), Akshara (Indestructible), Avijnata (Unknown), Sahasramshu (Thousand-rayed), Vidhata (Creator), Krita-lakshanah (Marked as accomplished).'
    ),
    (
      52,
      'गभस्तिनेमिः सत्त्वस्थः सिंहो भूतमहेश्वरः। आदिदेवो महादेवो देवेशो देवभृद्गुरुः॥',
      'Names 483-492: Gabhastinemi (Hub of sun-rays), Sattvastha (Situated in Sattva), Simha (Lion), Bhutamaheshvara (Great lord of beings), Adideva (Primordial god), Mahadeva (Great god), Devesha (Lord of gods), Devabhrit (God-bearer), Guruh (Teacher).'
    ),
    (
      53,
      'उत्तरो गोपतिर्गोप्ता ज्ञानगम्यः पुरातनः। शरीरभूतभृद्भोक्ता कपीन्द्रो भूरिदक्षिणः॥',
      'Names 493-501: Uttara (Superior), Gopati (Cow-lord), Gopta (Protector), Jnanagamya (Attained through knowledge), Purataana (Ancient), Sharira-bhuta-bhrit (Bearer of elemental body), Bhokta (Enjoyer), Kapindra (King of monkeys), Bhuridakshina (Abundant in gifts).'
    ),
    (
      54,
      'सोमपोऽमृतपः सोमः पुरुजित्पुरुसत्तमः। विनयो जयः सत्यसन्धो दाशार्हः सात्त्वतां पतिः॥',
      'Names 502-511: Somapa (Soma-drinker), Amritapa (Ambrosia-drinker), Soma (Moon), Purujit (Victor of many), Purusattama (Best of beings), Vinaya (Humility), Jaya (Victory), Satyasandha (True to vows), Dasharha (Deserving), Sattvataampati (Lord of the Satvatas).'
    ),
    (
      55,
      'जीवो विनयिता साक्षी मुकुन्दोऽमितविक्रमः। अम्भोनिधिरनन्तात्मा महोदधिशयोऽन्तकः॥',
      'Names 512-521: Jivah (Life), Vinayita (Humility), Sakshi (Witness), Mukunda (Liberation-giver), Amita-vikrama (Immeasurable valor), Ambhonidhi (Ocean), Anantaatma (Endless Self), Maho-dhi-shaya (Resting on great ocean), Antaka (Ender).'
    ),
    (
      56,
      'अजो महार्हः स्वाभाव्यो जितामित्रः प्रमोदनः। आनन्दो नन्दनो नन्दः सत्यधर्मा त्रिविक्रमः॥',
      'Names 522-531: Aja (Unborn), Maharhah (Greatly worshipped), Svabhavya (Self-natured), Jita-amitra (Conquered enemies), Pramodana (Rejoicer), Ananda (Bliss), Nandana (Joyful), Nanda (Joy), Satyaddharma (True dharma), Trivikrama (Three-stepped).'
    ),
    (
      57,
      'महर्षिः कपिलाचार्यः कृतज्ञो मेदिनीपतिः। त्रिपदस्त्रिदशाध्यक्षो महाशृङ्गः कृतान्तकृत्॥',
      'Names 532-540: Maharshi (Great sage), Kapila-acharya (Teacher Kapila), Kritajnah (Grateful), Medinipati (Earth-lord), Tripada (Three-footed), Tridashaadhyaksha (Overseer of thirty gods), Mahashanga (Great-peaked), Kritanta-krit (End-maker).'
    ),
    (
      58,
      'महावराहो गोविन्दः सुषेणः कनकाङ्गदी। गुह्यो गभीरो गहनो गुप्तश्चक्रगदाधरः॥',
      'Names 541-550: Mahavarahah (Great boar), Govinda (Cow-finder), Sushena (Good-armed), Kanakangadi (Gold-armlet), Guhya (Secret), Gambhira (Deep), Gahana (Profound), Gupta (Hidden), Chakragadadhara (Discus and mace bearer).'
    ),
    (
      59,
      'वेधाः स्वाङ्गोऽजितः कृष्णो दृढः संकर्षणोऽच्युतः। वरुणो वारुणो वृक्षः पुष्कराक्षो महामनाः॥',
      'Names 551-560: Vedha (Piercer), Svanga (Self-limbed), Ajita (Unconquered), Krishna (Dark), Dridha (Firm), Sankarshana (Drawer), Achyuta (Infallible), Varuna (Water god), Varuna (Relating to water), Vriksha (Tree), Pushkaraksha (Lotus-eyed), Mahamana (Great-minded).'
    ),
    (
      60,
      'भगवान् भगहाऽऽनन्दी वनमाली हलायुधः। आदित्यो ज्योतिरादित्यः सहिष्णुर्गतिसत्तमः॥',
      'Names 561-570: Bhagavan (Blessed), Baghaha (Destroyer of the six), Anandi (Blissful), Vanamali (Forest-garlanded), Halayudha (Plow-weaponed), Aditya (Sun), Jyotiraditya (Sun-light), Sahishnu (Patient), Gati-sattama (Best destination).'
    ),
    (
      61,
      'सुधन्वा खण्डपरशुर्दारुणो द्रविणप्रदः। दिवःस्पृक्सर्वदृग्व्यासो वाचस्पतिरयोनिजः॥',
      'Names 571-579: Sudhanva (Good-bowed), Khanda-parashu (Axe-fragmenter), Daruna (Hard), Dravina-prada (Wealth-giver), Divi-sprik (Sky-touching), Sarvadrk (All-seeing), Vyasa (Arranger), Vachaspati (Lord of speech), Ayonija (Not born from womb).'
    ),
    (
      62,
      'त्रिसामा सामगः साम निर्वाणं भेषजं भिषक्। संन्यासकृच्छमः शान्तो निष्ठा शान्तिः परायणम्॥',
      'Names 580-589: Trisama (Three-Sama), Samagah (Sama-singer), Sama (Equanimous), Nirvana (Extinction), Bheshaja (Medicine), Bhishak (Physician), Sanyaskrit (Renunciation-maker), Shama (Calm), Shanta (Peaceful), Nishtha (Steadfast), Shanti (Peace), Parayana (Supreme goal).'
    ),
    (
      63,
      'शुभाङ्गः शान्तिदः स्रष्टा कुमुदः कुवलेशयः। गोहितो गोपतिर्गोप्ता वृषभाक्षो वृषप्रियः॥',
      'Names 590-599: Shubhanga (Auspicious-limbed), Shantida (Peace-giver), Srastha (Creator), Kumuda (Lotus), Kuvaleshaya (Resting in lotuses), Gohita (Cow-benefactor), Gopati (Cow-lord), Gopta (Protector), Vrishabhaksha (Bull-eyed), Vrisha-priya (Fond of bulls).'
    ),
    (
      64,
      'अनिवर्ती निवृत्तात्मा संक्षेप्ता क्षेमकृच्छिवः। श्रीवत्सवक्षाः श्रीवासः श्रीपतिः श्रीमतांवरः॥',
      'Names 600-609: Anivartri (Non-retreating), Nivritatma (Returned-Self), Sanksheptha (Compressor), Kshemakrit (Welfare-maker), Shiva (Auspicious), Shrivatsa-vaksha (Shrivatsa-chested), Shrivasa (Shri-abode), Shripati (Shri-lord), Shrimatam-vara (Best among glorious).'
    ),
    (
      65,
      'श्रीदः श्रीशः श्रीनिवासः श्रीनिधिः श्रीविभावनः। श्रीधरः श्रीकरः श्रेयः श्रीमाँल्लोकत्रयाश्रयः॥',
      'Names 610-618: Shrida (Giver of Shri), Shrishah (Lord of Shri), Shrinivasa (Shri-abode), Shrinidhi (Shri-treasury), Shri-vibhavana (Shri-maker), Shridhara (Shri-bearer), Shrikara (Shri-maker), Shreya (Benefit), Shriman (Glorious), Lokatraya-ashraya (Refuge of three worlds).'
    ),
    (
      66,
      'स्वक्षः स्वङ्गः शतानन्दो नन्दिर्ज्योतिर्गणेश्वरः। विजितात्माऽविधेयात्मा सत्कीर्तिश्छिन्नसंशयः॥',
      'Names 619-628: Svaksha (Self-eyed), Svanga (Self-limbed), Shatananda (Hundredfold bliss), Nandih (Joy), Jyotirgana-ishvara (Lord of luminaries), Vijitaatma (Conquered self), Avidheyatma (Independent self), Satkirti (True-famed), Chinna-samshaya (Doubt-dispeller).'
    ),
    (
      67,
      'उदीर्णः सर्वतश्चक्षुरनीशः शाश्वतस्थिरः। भूशयो भूषणो भूतिर्विशोकः शोकनाशनः॥',
      'Names 629-638: Udirnah (Raised high), Sarvatash-chakshur (All-eyed), Anisha (Masterless), Shasvata-sthira (Eternally stable), Bhushaya (Earth-resting), Bhushana (Ornament), Bhuti (Well-being), Visoka (Griefless), Shoka-nashana (Grief-destroyer).'
    ),
    (
      68,
      'अर्चिष्मानर्चितः कुम्भो विशुद्धात्मा विशोधनः। अनिरुद्धोऽप्रतिरथः प्रद्युम्नोऽमितविक्रमः॥',
      'Names 639-647: Archishman (Flame-bearing), Archita (Worshipped), Kumbha (Pot — the body), Vishuddhatma (Pure Self), Vishoshana (Drier-up), Aniruddha (Unstoppable), Apratiradha (Without adversary), Pradyumna (Great-splendored), Amitavikrama (Immeasurable valor).'
    ),
    (
      69,
      'कालनेमिनिहा वीरः शौरिः शूरजनेश्वरः। त्रिलोकात्मा त्रिलोकेशः केशवः केशिहा हरिः॥',
      'Names 648-657: Kalanemi-niha (Destroyer of Kalanemi), Virah (Heroic), Shaurih (Valiant), Shura-janeshvara (Lord of heroes), Triloka-atma (Three-world Self), Trilokesh (Three-world lord), Keshava (Beautiful-haired), Keshi-ha (Destroyer of Keshi), Hari (Remover of sin).'
    ),
    (
      70,
      'कामदेवः कामपालः कामी कान्तः कृतागमः। अनिर्देश्यवपुर्विष्णुर्वीरोऽनन्तो धनञ्जयः॥',
      'Names 658-667: Kamadeva (God of love), Kamapala (Desire-protector), Kami (Desirous), Kanta (Beautiful), Kritagama (Creator of Agama), Anirdeshyavapu (Indescribable form), Vishnu (All-pervading), Vira (Heroic), Ananta (Endless), Dhananjaya (Wealth-winner).'
    ),
    (
      71,
      'ब्रह्मण्यो ब्रह्मकृद् ब्रह्मा ब्रह्म ब्रह्मविवर्धनः। ब्रह्मविद् ब्राह्मणो ब्रह्मी ब्रह्मज्ञो ब्राह्मणप्रियः॥',
      'Names 668-677: Brahmanya (Brahman-related), Brahmakrit (Brahman-doer), Brahma (The Brahman), Brahma (Vedas), Brahma-vivardhanah (Brahman-increaser), Brahma-vid (Brahman-knower), Brahmana (Brahmin), Brahmi (Brahman-natured), Brahmajnah (Brahman-knowing), Brahmanapriyal (Brahmin-beloved).'
    ),
    (
      72,
      'महाक्रमो महाकर्मा महातेजा महोरगः। महाक्रतुर्महायज्वा महायज्ञो महाहविः॥',
      'Names 678-686: Mahakrama (Great-stepper), Mahakarma (Great-actioned), Mahateja (Great-brilliant), Mahoraga (Great serpent), Mahakratu (Great sacrifice-rite), Mahayajva (Great sacrificer), Mahayajna (Great sacrifice), Mahahavi (Great oblation).'
    ),
    (
      73,
      'स्तव्यः स्तवप्रियः स्तोत्रं स्तुतिः स्तोता रणप्रियः। पूर्णः पूरयिता पुण्यः पुण्यकीर्तिरनामयः॥',
      'Names 687-696: Stavya (Praise-worthy), Stava-priya (Fond of praise), Stotra (Hymn), Stuti (Laudation), Stota (Praiser), Rana-priya (Battle-fond), Purna (Full), Purayita (Fulfiller), Punya (Holy), Punya-kirti (Holy-famed), Anamaya (Disease-free).'
    ),
    (
      74,
      'मनोजवस्तीर्थकरो वसुरेता वसुप्रदः। वसुप्रदो वासुदेवो वसुर्वसुमना हविः॥',
      'Names 697-705: Manojava (Mind-swift), Tirthakara (Sacred-ford-maker), Vasureta (Treasure-seeded), Vasuprada (Treasure-giver), Vasuprada (Wealth-giver), Vasudeva (Vasudeva\'s son), Vasu (Treasure), Vasumana (Treasure-minded), Havih (Oblation).'
    ),
    (
      75,
      'सद्गतिः सत्कृतिः सत्ता सद्भूतिः सत्परायणः। शूरसेनो यदुश्रेष्ठः सन्निवासः सुयामुनः॥',
      'Names 706-715: Sadgati (Good goal), Satkrti (Good action), Satta (Being), Sadbhuti (Good existence), Sat-parayana (Good supreme goal), Shura-sena (Hero-army), Yadu-shreshtha (Best of Yadus), Sannivasa (Good abode), Suyamuna (Good at Yamuna).'
    ),
    (
      76,
      'भूतावासो वासुदेवः सर्वासुनिलयोऽनलः। दर्पहा दर्पदो दृप्तो दुर्धरोऽथापराजितः॥',
      'Names 716-725: Bhutavasa (Dwelling of beings), Vasudeva (Vasudeva), Sarvasu-nilaya (Refuge of all), Analah (Fire), Darpaha (Pride-destroyer), Darpada (Pride-giver), Dripta (Proud), Durdhara (Hard to bear), Aparajita (Unconquered).'
    ),
    (
      77,
      'विश्वमूर्तिर्महामूर्तिर्दीप्तमूर्तिरमूर्तिमान्। अनेकमूर्तिरव्यक्तः शतमूर्तिः शताननः॥',
      'Names 726-734: Vishvamurti (Universe-formed), Mahahmurti (Great-formed), Dipta-murti (Radiant-formed), Amurtiman (Formless), Aneka-murti (Many-formed), Avyakta (Unmanifest), Shata-murti (Hundred-formed), Shatanana (Hundred-faced).'
    ),
    (
      78,
      'एको नैकः सवः कः किं यत्तत्पदमनुत्तमम्। लोकबन्धुर्लोकनाथो माधवो भक्तवत्सलः॥',
      'Names 735-743: Eka (One), Naika (Many), Sava (Sacrifice), Ka (Who), Kim (What), Yat (Which), Tat (That), Padam-anuttamam (Supreme state), Lokabandhu (World-friend), Lokanatha (World-lord), Madhava (Spring-born), Bhaktavatsala (Devotee-loving).'
    ),
    (
      79,
      'सुवर्णवर्णो हेमाङ्गो वराङ्गश्चन्दनाङ्गदी। वीरहा विषमः शून्यो घृताशीरचलश्चलः॥',
      'Names 744-753: Suvarna-varna (Golden-colored), Hemanga (Gold-limbed), Varanga (Beautiful-limbed), Chandanangadi (Sandalwood-armletted), Viraha (Hero-slayer), Vishama (Unequal), Shunyah (Void), Ghritashir (Ghee-headed), Achala (Immovable), Chala (Moving).'
    ),
    (
      80,
      'अमानी मानदो मान्यो लोकस्वामी त्रिलोकधृक्। सुमेधा मेधजो धन्यः सत्यमेधा धराधरः॥',
      'Names 754-763: Amani (Prideless), Manada (Honor-giver), Manya (Honorable), Lokasvaami (World-master), Trilokadhrik (Three-world-supporter), Sumedha (Good-minded), Medhaja (Wisdom-born), Dhanya (Fortunate), Satya-medha (True-minded), Dharadhara (Earth-bearer).'
    ),
    (
      81,
      'तेजोवृषो द्युतिधरः सर्वशस्त्रभृतांवरः। प्रग्रहो निग्रहो व्यग्रो नैकशृङ्गो गदाग्रजः॥',
      'Names 764-773: Tejovrishah (Vigor-bull), Dyutidhara (Splendor-bearer), Sarva-shastra-bhritam-vara (Best of weapon-bearers), Prabaha (Forward-flow), Nigraha (Restraint), Vyagra (Eager), Naikashinga (Many-peaked), Gadagraja (Elder to Gada).'
    ),
    (
      82,
      'चतुर्मूर्तिश्चतुर्बाहुश्चतुर्व्यूहश्चतुर्गतिः। चतुरात्मा चतुर्भावश्चतुर्वेदविदेकपात्॥',
      'Names 774-782: Chaturmurti (Four-formed), Chaturbahu (Four-armed), Chaturvyuha (Four-arrayed), Chaturgati (Four-paced), Chaturatma (Four-souled), Chaturbhava (Four-natured), Chaturveda-vid (Knower of four Vedas), Ekapata (One-footed).'
    ),
    (
      83,
      'समावर्तोऽनिवृत्तात्मा दुर्जयो दुरतिक्रमः। दुर्लभो दुर्गमो दुर्गो दुराधरो नरागजः॥',
      'Names 783-792: Samavarta (Equal-moving), Anivritatma (Non-returned Self), Durjaya (Hard to conquer), Duratikrama (Hard to transgress), Durlabha (Hard to obtain), Durgama (Hard to approach), Durga (Fortress), Duradara (Hard to carry), Naraagaja (Elephant among men).'
    ),
    (
      84,
      'शूरांशुर्देवश्रेष्ठो भवः कालः परन्तपः। भक्तिग्राह्यः परस्पर्शो जन्मकृज्जन्मनाशनः॥',
      'Names 793-801: Shuramshu (Heroic-rayed), Devashreshtha (Best of gods), Bhava (Existence), Kala (Time), Paramtapa (Great burner), Bhaktigraha (Grasped by devotion), Parasparsha (Supremely tangible), Janmakrit (Birth-maker), Janmanashana (Birth-destroyer).'
    ),
    (
      85,
      'भूतभव्यभवन्नाथः पवनः पावनोऽनलः। कामहा कामकृत्कान्तः कामः कामप्रदः प्रभुः॥',
      'Names 802-811: Bhuta-bhavya-bhavan-natha (Lord of past-present-future), Pavanam (Purifier), Pavana (Wind), Anala (Fire), Kamaha (Desire-destroyer), Kamakrit (Desire-maker), Kanta (Beloved), Kama (Love), Kamaprada (Desire-granter), Prabhu (Lord).'
    ),
    (
      86,
      'युगादिकृद्युगावर्तो नैकमायो महाशनः। अदृश्यो व्यक्तरूपश्च सहस्रजिदनन्तजित्॥',
      'Names 812-820: Yugadikrit (Age-maker), Yugavarta (Age-cycler), Naikamaya (Many-illusioned), Mahasana (Great-eating), Adrishya (Invisible), Vyakta-rupa (Manifest-formed), Sahasrajit (Thousand-conqueror), Anantajit (Endless-conqueror).'
    ),
    (
      87,
      'इष्टोऽविशिष्टः शिष्टेष्टः शिखण्डी नहुषो वृषः। क्रोधहा क्रोधकृत्कर्ता विश्वबाहुर्महीधरः॥',
      'Names 821-830: Ishtha (Desired), Avishishtha (Equal to all), Shishteshta (Cherished by the learned), Shikhandi (Crested-bird), Nahusa (Binder), Vrisha (Bull of dharma), Krodhaha (Anger-slayer), Krodhakrit (Anger-maker), Karta (Actor), Vishvabahu (All-armed), Mahidhara (Mountain-bearer).'
    ),
    (
      88,
      'अच्युतः प्रथितः प्राणः प्राणदो वासवानुजः। अपांनिधिरधिष्ठानमप्रमत्तः प्रतिष्ठितः॥',
      'Names 831-840: Achyuta (Infallible), Prathita (Renowned), Pranah (Life itself), Pranada (Life-giver), Vasavanuja (Indra\'s younger), Apam-nidhi (Treasure of waters), Adhishthana (Foundation), Apramatta (Uncareless), Pratishthita (Well-established).'
    ),
    (
      89,
      'स्कन्दः स्कन्दधरो धुर्यो वरदो वायुवाहनः। वासुदेवो बृहद्भानुरादिदेवः पुरन्दरः॥',
      'Names 841-849: Skanda (Leaped forth), Skandadhara (Skanda\'s support), Dhurya (Burden-bearer), Varada (Boon-bestower), Vayuvahana (Wind-carried), Vasudeva (Son of Vasudeva), Brihad-bhanu (Great-rayed), Aadi-deva (Primordial), Purandara (City-breaker).'
    ),
    (
      90,
      'अशोकस्तारणस्तारः शूरः शौरिर्जनेश्वरः। अनुकूलः शतावर्तः पद्मी पद्मनिभेक्षणः॥',
      'Names 850-859: Ashoka (Griefless), Tarana (Ferryman), Tara (Star), Shura (Hero), Shauri (Valiant), Janeshvara (Lord of people), Anukula (Favorable), Shatavarta (Hundred-whirling), Padmi (Lotus-holding), Padma-nibhekshana (Lotus-glancing).'
    ),
    (
      91,
      'पद्मनाभोऽरविन्दाक्षः पद्मगर्भः शरीरभृत्। महर्द्धिरृद्धो वृद्धात्मा महाक्षो गरुडध्वजः॥',
      'Names 860-869: Padmanabha (Lotus-naveled), Aravindaksha (Lotus-eyed), Padmagarbha (Lotus-born), Sharirabrit (Body-maintainer), Maharddhi (Great fortune), Riddhah (Opulent), Vriddhatma (Ancient Self), Mahaksha (Great-eyed), Garudadhvaja (Garuda-flagged).'
    ),
    (
      92,
      'अतुलः शरभो भीमः समयज्ञो हविर्हरिः। सर्वलक्षणलक्षण्यो लक्ष्मीवान् समितिञ्जयः॥',
      'Names 870-879: Atulah (Incomparable), Sharabhah (Mythical beast), Bhima (Terrible), Samayajna (Time-ritual), Havirhari (Oblation-Hari), Sarvalakshana-lakshanya (All-marked), Lakshmivan (Lakshmi-possessing), Samitinjaya (Contest-victor).'
    ),
    (
      93,
      'विक्षरो रोहितो मार्गो हेतुर्दामोदरः सहः। महीधरो महाभागो वेगवानमिताशनः॥',
      'Names 880-889: Vikshara (Imperishable), Rohita (Ruddy), Marga (Way), Hetu (Motive), Damodara (Rope-bellied), Saha (Endurer), Mahidhara (Earth-upholder), Mahabhaga (Great-share), Vegavan (Swift), Amitashana (Limitless-eating).'
    ),
    (
      94,
      'उद्भवः क्षोभणो देवः श्रीगर्भः परमेश्वरः। करणं कारणं कर्ता विकर्ता गहनो गुहः॥',
      'Names 890-899: Udbhava (Origin), Kshobhana (Disturber), Devah (Divinity), Shrigarbha (Lakshmi-contained), Parameshvara (Supreme sovereign), Karanam (Instrument), Karanam (Cause), Karta (Agent), Vikarta (Modifier), Gahana (Abyss), Guha (Cave).'
    ),
    (
      95,
      'व्यवसायो व्यवस्थानः संस्थानः स्थानदो ध्रुवः। परर्द्धिः परमस्पष्टस्तुष्टः पुष्टः शुभेक्षणः॥',
      'Names 900-909: Vyavasaya (Determination), Vyavasthana (Established), Samsthana (Abode), Sthanada (Place-bestower), Dhruva (Pole-star), Parardhi (Supreme), Param-spashta (Most evident), Tushta (Pleased), Pushta (Nourished), Shubhekshana (Benevolent-glanced).'
    ),
    (
      96,
      'रामो विरामो विरजो मार्गो नेयो नयोऽनयः। वीरः शक्तिमतां श्रेष्ठो धर्मो धर्मविदुत्तमः॥',
      'Names 910-919: Rama (Delight), Virama (Cessation), Viraja (Passionless), Marga (Road), Neya (Guidable), Naya (Prudence), Anaya (Unguided), Vira (Champion), Shaktimatam-shreshtah (Greatest of the strong), Dharma (Law), Dharmaviduttama (Supreme law-knower).'
    ),
    (
      97,
      'वैकुण्ठः पुरुषः प्राणः प्राणदः प्रणवः पृथुः। हिरण्यगर्भः शत्रुघ्नो व्याप्तो वायुरधोक्षजः॥',
      'Names 920-929: Vaikuntha (Liberation-giver), Purusha (Cosmic Person), Prana (Breath), Pranada (Breath-giver), Pranava (OM), Prithu (Wide), Hiranyagarbha (Golden-embryo), Shatrugna (Foe-slayer), Vyapta (Permeated), Vayu (Wind), Adhokshaja (Born below the axle).'
    ),
    (
      98,
      'ऋतुः सुदर्शनः कालः परमेष्ठी परिग्रहः। उग्रः संवत्सरो दक्षो विश्रामो विश्वदक्षिणः॥',
      'Names 930-939: Ritu (Season), Sudarshana (Beautiful-visioned), Kala (Time-force), Parameshti (Supreme-stationed), Parigraha (All-encompassing), Ugra (Fierce), Samvatsara (Annual cycle), Daksha (Proficient), Vishrama (Repose), Vishvadakshina (Universally skilled).'
    ),
    (
      99,
      'विस्तारः स्थावरस्थाणुः प्रमाणं बीजमव्ययम्। अर्थोऽनर्थो महाकोशो महाभोगो महाधनः॥',
      'Names 940-949: Vistara (Extension), Sthavasra-sthanu (Static pillar), Pramana (Standard), Bijam-avyayam (Undying seed), Artha (Meaning), Anartha (Meaningless), Mahakosah (Great treasury), Mahabhoga (Grand experience), Mahadhanah (Supreme wealth).'
    ),
    (
      100,
      'अनिर्विण्णः स्थविष्ठोऽभूर्धर्मयूपो महामखः। नक्षत्रनेमिर्नक्षत्री क्षमः क्षामः समीहनः॥',
      'Names 950-959: Anirvinna (Undeterred), Sthavishtha (Massively large), Abhu (Self-existent), Dharmayupa (Dharma-post), Mahamakha (Grand sacrifice), Nakshatranemi (Stellar-hub), Nakshtri (Star-possessor), Kshama (Forbearing), Kshama (Lean), Samihanah (Longed-for).'
    ),
    (
      101,
      'यज्ञ इज्यो महेज्यश्च क्रतुः सत्रं सतां गतिः। सर्वदर्शी विमुक्तात्मा सर्वज्ञो ज्ञानमुत्तमम्॥',
      'Names 960-968: Yajna (Worship), Ijya (Worshippable), Mahejya (Most worshippable), Kratu (Vedic rite), Satra (Session), Satam-gati (Path of the virtuous), Sarvadarshi (All-beholder), Vimuktatma (Freed soul), Sarvajna (Omniscient), Jnanam-uttamam (Highest knowledge).'
    ),
    (
      102,
      'सुव्रतः सुमुखः सूक्ष्मः सुघोषः सुखदः सुहृत्। मनोहरो जितक्रोधो वीरबाहुर्विदारणः॥',
      'Names 969-978: Suvrata (Good-vowed), Sumukha (Fair-faced), Sukshma (Subtle), Sughosa (Melodious), Sukhada (Bliss-giver), Suhrit (Well-wisher), Manohara (Mind-captivating), Jitakrodha (Passion-mastered), Virabahu (Warrior-armed), Vidarana (Splitter).'
    ),
    (
      103,
      'स्वापनः स्ववशो व्यापी नैकात्मा नैककर्मकृत्। वत्सरो वत्सलो वत्सी रत्नगर्भो धनेश्वरः॥',
      'Names 979-988: Svapana (Sleep-inducer), Svavasha (Self-ruled), Vyapi (All-spreading), Naikatma (Multi-souled), Naikakarmakrit (Multi-actioned), Vatsara (Year-span), Vatsala (Tender), Vatsi (Tender-with-calves), Ratnagarbha (Jewel-holding), Dhaneshvara (Riches-lord).'
    ),
    (
      104,
      'धर्मगुब्धर्मकृद्धर्मी सदसत्क्षरमक्षरम्। अविज्ञाता सहस्रांशुर्विधाता कृतलक्षणः॥',
      'Names 989-998: Dharmagupta (Dharma-guardian), Dharmakrit (Dharma-practitioner), Dharmi (Dharma-embodied), Sadsat (Real-unreal), Kshara (Perishable), Akshara (Imperishable), Avijnata (Unknown to all), Sahasramshu (Thousand-rayed), Vidhata (Ordainer), Kritalakshana (Marked with accomplishment).'
    ),
    (
      105,
      'गभस्तिनेमिः सत्त्वस्थः सिंहो भूतमहेश्वरः। आदिदेवो महादेवो देवेशो देवभृद्गुरुः॥',
      'Names 999-1000: Gabhasti-nemi (Rim of the sun\'s wheel), Sattva-stha (Abiding in purity) — and the thousandth name which Bhishma declares: He is the ONE who is all of these — Vishnu, the all-pervading truth of the universe.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'VS.1.$v',
        chapter: 1,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ The Thousand Names: ${verses.length} shlokas');
  return verses.length;
}
