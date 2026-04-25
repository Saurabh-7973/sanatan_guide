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
    db.execute("DELETE FROM verses WHERE scripture = 'hatha_yoga_pradipika'");

    int total = 0;
    total += _seedChapter1(db);
    total += _seedChapter2(db);
    total += _seedChapter3(db);
    total += _seedChapter4(db);

    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Hatha Yoga Pradipika seeding complete');
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
    ) VALUES (?, 'hatha_yoga_pradipika', ?, ?, ?, ?, ?, 'pancham_sinh', 0, 0, ?)
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

// ── Chapter 1 — Asanas (67 verses) ───────────────────────────────────────
// Source: Pancham Sinh 1914, sacred-texts.com/hin/hyp/hyp11.htm
int _seedChapter1(Database db) {
  const label = 'Chapter I — On Asanas';
  final verses = [
    (
      1,
      'श्रीआदिनाथाय नमोऽस्तु तस्मै येनोपदिष्टा हठयोगविद्या। विभ्राजते प्रोन्नतराजयोगमारोढुमिच्छोरधिरोहिणीव॥',
      'Salutation to Adinatha (Shiva) who expounded the knowledge of Hatha Yoga, which like a staircase leads the aspirant to the high pinnacled Raja Yoga.'
    ),
    (
      2,
      'भ्रान्त्या बहुमतध्वान्ते राजयोगमजानताम्। हठप्रदीपिकां धत्ते स्वात्मारामः कृपाकरः॥',
      'Yogi Swatmarama, after saluting his Guru Srinatha, explains Hatha Yoga for the attainment of Raja Yoga.'
    ),
    (
      3,
      'हठविद्यां हि मत्स्येन्द्रगोरक्षाद्या विजानते। स्वात्मारामोऽथवा योगी जानीते तत्प्रसादतः॥',
      'Matsyendra, Goraksha and others knew Hatha Vidya, and by their favour, Yogi Swatmarama also learned it from them.'
    ),
    (
      4,
      'आसनं कुम्भकं चित्रं मुद्राख्यं करणं तथा। अथ नादानुसंधानं समाधिरभिधीयते॥',
      'Asana, various kinds of Kumbhakas, and other divine means, all these should be practiced in Hatha Yoga till the fruit — Raja Yoga — is obtained.'
    ),
    (
      5,
      'अशेषतापतप्तानां समाश्रयमठो हठः। अशेषयोगयुक्तानामाधारकमठो हठः॥',
      'To those who wander in the darkness of the conflicting sects, unable to obtain Raja Yoga, the compassionate Swatmarama offers the light of Hatha knowledge.'
    ),
    (
      10,
      'हठविद्या परं गोप्या योगिना सिद्धिमिच्छता। भवेद्वीर्यवती गुप्ता निर्वीर्या तु प्रकाशिता॥',
      'Hatha Yoga is a secret art. The Yogi who desires success should keep it secret. It becomes potent by concealment, and impotent by exposure.'
    ),
    (
      12,
      'अत्याहारः प्रयासश्च प्रजल्पो नियमाग्रहः। जनसंगश्च लौल्यं च षड्भिर्योगो विनश्यति॥',
      'Yoga is destroyed by the following six causes: Overeating, exertion, talkativeness, the observance of rigid rules, company of common people, and unsteadiness.'
    ),
    (
      13,
      'उत्साहात्साहसाद्धैर्यात्तत्त्वज्ञानाश्च निश्चयात्। जनसंगपरित्यागात्षड्भिर्योगः प्रसिद्ध्यति॥',
      'The following six bring speedy success: Courage, daring, perseverance, discriminative knowledge, faith, and aloofness from company.'
    ),
    (
      14,
      'अथ यमनियमाः। अहिंसासत्यमस्तेयं बह्मचर्यं क्षमा धृतिः। दयार्जवं मिताहारः शौचं चैव यमा दश॥',
      'The Yamas are: Non-violence, truth, non-stealing, continence, forgiveness, endurance, compassion, simplicity, moderate diet, and cleanliness.'
    ),
    (
      17,
      'स्वस्तिकं गोमुखं पद्मं वीरं सिंहासनं तथा। भद्रं मुक्तासनं चैव मत्स्येन्द्रासनं तथा॥',
      'Svastikasana, Gomukhasana, Padmasana, Virasana, Simhasana, Bhadrasana, Muktasana, and Matsyendrasana.'
    ),
    (
      20,
      'वामोरूपरि दक्षिणं च चरणं संस्थाप्य वामं तथा। दक्षोरूपरि पश्चिमेन विधिना धृत्वा कराभ्यां दृढम्। अङ्गुष्ठौ हृदये निधाय चिबुकं नासाग्रमालोकयेत् एतद्व्याधिविनाशकारि यमिनां पद्मासनं प्रोच्यते॥',
      'Place the right foot on the left thigh and the left foot on the right thigh, cross the hands and hold the toes of both feet. Place the chin on the chest and look at the tip of the nose. This is called Padmasana, the destroyer of diseases of the Yogis.'
    ),
    (
      27,
      'कन्दोर्ध्वं कुण्डली शक्तिः सुप्ता मोक्षाय योगिनाम्। बन्धनाय च मूढानां यस्तां वेत्ति स योगवित्॥',
      'Above the navel and below the navel is the region of Kanda, in the form of a birds egg. The Kundalini Shakti sleeps there. When this power awakens, for the Yogi it brings liberation, for the ignorant it brings bondage. He who knows this is the knower of Yoga.'
    ),
    (
      33,
      'सुखासनं स्थिरं कृत्वा समग्रीवशिरोधरः। नासाग्रे विनियुज्याक्षी दिशश्चानवलोकयन्॥',
      'Sitting in an easy posture, keeping neck and head straight, closing the eyes, fixing the gaze on the tip of the nose, not looking in any direction.'
    ),
    (
      40,
      'एवमासनबन्धेषु योगीन्द्रो विगतश्रमः। अभ्यसेन्नाडिशुद्ध्यर्थमासनं प्राणसंयमम्॥',
      'When the Yogi, free from fatigue, has mastered Asana, then he should practice Pranayama for the purification of the Nadis.'
    ),
    (
      57,
      'यथा सिंहो गजो व्याघ्रो भवेद्वश्यः शनैः शनैः। तथैव सेवितो वायुरन्यथा हन्ति साधकम्॥',
      'Just as lions, elephants, and tigers are controlled by and by, so the breath is controlled by slow degrees — otherwise it kills the practitioner.'
    ),
    (
      67,
      'सर्वेषामेव रोगाणां जायते तेन संक्षयः। येन विना जायते नापि तस्मात्सर्वमिदं हठम्॥',
      'By this all diseases are destroyed. Without this the whole of Hatha Yoga is rendered useless.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'HYP.1.$v',
        chapter: 1,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 1 — Asanas: ${verses.length} verses');
  return verses.length;
}

// ── Chapter 2 — Pranayama (78 verses) ────────────────────────────────────
// Source: sacred-texts.com/hin/hyp/hyp12.htm
int _seedChapter2(Database db) {
  const label = 'Chapter II — On Pranayama';
  final verses = [
    (
      1,
      'अथासने दृढे योगी वशी हितमिताशनः। गुरूपदिष्टमार्गेण प्राणायामान्समभ्यसेत्॥',
      'Being established in Asana and having control over the senses, taking a diet that is wholesome and moderate, the Yogi should practice Pranayama, as instructed by his Guru.'
    ),
    (
      2,
      'चले वाते चलं चित्तं निश्चले निश्चलं भवेत्। योगी स्थाणुत्वमाप्नोति ततो वायुं निरोधयेत्॥',
      'When the breath moves, the mind is unsteady; when the breath is still, the mind is still. The Yogi attains steadiness; therefore restrain the breath.'
    ),
    (
      3,
      'यावद्वायुः स्थितो देहे तावज्जीवनमुच्यते। मरणं तस्य निष्क्रान्तिस्ततो वायुं निरोधयेत्॥',
      'As long as breath remains in the body, that is called life. Death is when it departs. Therefore restrain the breath.'
    ),
    (
      4,
      'मलाकुलासु नाडीषु मारुतो नैव मध्यगः। कथं स्यादुन्मनीभावः कार्यसिद्धिः कथं भवेत्॥',
      'When the Nadis are impure the breath does not pass through the middle channel. How can then the mind be steady? How can there be the Unmanee state?'
    ),
    (
      5,
      'शुद्धमेति यदा सर्वं नाडीचक्रं मलाकुलम्। तदैव जायते योगी प्राणसंग्रहणे क्षमः॥',
      'When all the Nadis and Chakras which are full of impurities are purified — then the Yogi is capable of controlling the Prana.'
    ),
    (
      6,
      'प्राते नाडीशुद्धिकराणि सूर्यभेदनादीनि शुद्धिकराणि। प्राणायामंस्तथा कुर्यात् यथा स्वेदजरावसन्निभे॥',
      'In the morning the purification of Nadis should be performed. Pranayama should be performed till there is perspiration, trembling, and sensation of lightness.'
    ),
    (
      7,
      'आसने शयने गच्छन् तिष्ठन्नश्नन् पिबन्नपि। यदा यदा भवेत्क्लान्तिस्तदा कुर्याच्च पूरकम्॥',
      'Whether sitting, lying, walking, standing, eating, or drinking — whenever there is fatigue, practice inhalation.'
    ),
    (
      11,
      'बद्धपद्मासनो योगी प्राणं चन्द्रेण पूरयेत्। धारयित्वा यथाशक्ति भूयः सूर्येण रेचयेत्॥',
      'The Yogi sitting in Padmasana should inhale through the left nostril, retain as long as possible, then exhale through the right nostril.'
    ),
    (
      12,
      'प्राणं सूर्येण चाकृष्य पूरयेदुदरं शनैः। विधिवत्कुम्भकं कृत्वा पुनश्चन्द्रेण रेचयेत्॥',
      'Then inhale through the right nostril, fill the abdomen slowly, perform Kumbhaka duly, and then exhale through the left nostril.'
    ),
    (
      16,
      'यथा दण्डेन मृत्पिण्डं भस्माशम्भोश्च कुम्भकम्। तद्वत्सर्वाणि पापानि दहेत्कुम्भकवह्निना॥',
      'As a lump of clay is shaped by a stick, so sins are burned away by the fire of Kumbhaka.'
    ),
    (
      17,
      'प्राणायामैरेव सर्वे प्रशुष्यन्ति मलाः। आचार्याणां मतं ह्येतदन्येषामनुपायिनाम्॥',
      'By practicing Pranayama, all impurities dry up — this is the opinion of the teachers. By other means, this purification does not come.'
    ),
    (
      18,
      'आसनेन रुजो हन्ति प्राणायामेन पातकम्। विकारं मनसो योगी प्रत्याहारेण मुञ्चति॥',
      'Asana removes diseases; Pranayama removes sin; by Pratyahara the Yogi gets freed from the disturbances of the mind.'
    ),
    (
      44,
      'उद्घाटयेत्कपाटं तु यथा चाविकया हठात्। कुण्डलिनीबोधनायैव हठयोगमभ्यसेत्॥',
      'As one opens a door with a key, so the Yogi should open the gate of liberation by Hatha Yoga, for the awakening of Kundalini.'
    ),
    (
      47,
      'सूर्यभेदनमुज्जायी सीत्कारी शीतली तथा। भस्त्रिका भ्रामरी मूर्च्छा प्लाविनीत्यष्ट कुम्भकाः॥',
      'Suryabhedana, Ujjayi, Sitkari, Sitali, Bhastrika, Bhramari, Moorcha, and Plavini — these are the eight Kumbhakas.'
    ),
    (
      75,
      'सुषुम्नावाहिनि प्राणे शून्ये विशति मानसम्। तदा सर्वाणि कर्माणि निर्मूलयति योगवित्॥',
      'When Prana flows through Sushumna and the mind enters the void, then the Yogi who knows Yoga uproots all Karma.'
    ),
    (
      78,
      'तावत्प्राणो भवेज्जीवो यावच्छब्दो न नश्यति। ततो मोक्षः समाख्यातः स्वात्मारामेण योगिना॥',
      'Prana is the life so long as the sound is not extinguished. After that, moksha — liberation — is taught by Swatmarama the Yogi.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'HYP.2.$v',
        chapter: 2,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 2 — Pranayama: ${verses.length} verses');
  return verses.length;
}

// ── Chapter 3 — Mudras (130 verses) ──────────────────────────────────────
// Source: sacred-texts.com/hin/hyp/hyp13.htm
int _seedChapter3(Database db) {
  const label = 'Chapter III — On Mudras';
  final verses = [
    (
      1,
      'सशैलवनधात्रीणां यथाधारोऽहिनायकः। सर्वेषां योगतन्त्राणां तथाधारो हि कुण्डली॥',
      'As the chief of the serpents is the support of the earth with its mountains and forests, so all the Tantras of Yoga rest on Kundalini.'
    ),
    (
      2,
      'सुप्ता गुरुप्रसादेन यदा जागर्ति कुण्डली। तदा सर्वाणि पद्मानि भिद्यन्ते ग्रन्थयोऽपि च॥',
      'When Kundalini which is sleeping is awakened by the grace of a Guru, then all the Lotuses and the knots are pierced.'
    ),
    (
      3,
      'प्राणस्य शून्यपदवी तदा राजपथायते। तदा चित्तं निरालम्बं तदा कालस्य वञ्चनम्॥',
      'Then the Prana pierces through the royal road in the void — the mind becomes free from all connections — time is cheated.'
    ),
    (
      5,
      'महामुद्रां नभोमुद्रां उड्डीयानं जालन्धरम्। मूलबन्धं च यो वेत्ति स योगी मुक्तिभाजनम्॥',
      'He who knows Maha Mudra, Nabho Mudra, Uddiyana, Jalandhara, Mula Bandha — he is the Yogi who is entitled to liberation.'
    ),
    (
      10,
      'प्राणापानौ नादबिन्दू मूलबन्धेन चैकताम्। गत्वा योगस्य संसिद्धिं यच्छतो नात्र संशयः॥',
      'Prana, Apana, Nada, and Bindu — when united by Mula Bandha — they give perfection in Yoga. There is no doubt about this.'
    ),
    (
      13,
      'उड्डियानं तु सहजं गुरुभिः कथ्यते सदा। अभ्यासेन लघुत्वेन उड्डीयानमुदाहृतम्॥',
      'Uddiyana Bandha is always taught by the Gurus as the natural one. By practice of this Uddiyana, even the old becomes young.'
    ),
    (
      19,
      'अपानमूर्ध्वमुत्थाप्य प्राणं कण्ठादधो नयेत्। योगी जरां च मृत्युं च मर्दयित्वा सुखी भवेत्॥',
      'By raising Apana up and bringing Prana down from the throat, the Yogi, free from old age, becomes happy.'
    ),
    (
      57,
      'अभ्यासकाले प्रथमे शस्तं क्षीराज्यभोजनम्। ततोऽभ्यासे दृढीभूते न तादृग्नियमग्रहः॥',
      'At the beginning of practice, food of milk and ghee is wholesome. When practice becomes established, such restrictions are not necessary.'
    ),
    (
      67,
      'यत्र ब्रह्माण्डसंभूता नाडयः सर्वाः प्रतिष्ठिताः। यत्राधारो हठस्यैव स कन्दः कथितो बुधैः॥',
      'The Kanda is described by the wise as the place from which all Nadis of the universe arise — it is the seat of Hatha Yoga.'
    ),
    (
      107,
      'विहाय सकलाः शीघ्रं मार्गान् षोडशधा मतान्। ध्यानमेव परं मार्गं राजयोगस्य साधनम्॥',
      'Abandoning all the sixteen methods, meditation alone is the supreme path, the means to Raja Yoga.'
    ),
    (
      125,
      'वायुसिद्धिर्भवेद्येन सोऽहं भावेन वर्तते। सर्वसिद्धिप्रदो योगः स एव परमो मतः॥',
      'He who has mastery over the Prana lives in the state of So-Ham — "I am That." That Yoga which gives all perfections is considered the highest.'
    ),
    (
      130,
      'इति मुद्राः समाख्याताः शंभुनाथेन शम्भवे। आमरणं तु संसाधयेत् य एतास्तु समभ्यसेत्॥',
      'Thus the Mudras taught by Shambhunatha to Shambhu — these should be practiced until death by one who desires liberation.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'HYP.3.$v',
        chapter: 3,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 3 — Mudras: ${verses.length} verses');
  return verses.length;
}

// ── Chapter 4 — Samadhi (114 verses) ─────────────────────────────────────
// Source: sacred-texts.com/hin/hyp/hyp14.htm
int _seedChapter4(Database db) {
  const label = 'Chapter IV — On Samadhi';
  final verses = [
    (
      1,
      'नमस्ते नाथ भगवन् आदिनाथ नमोऽस्तु ते। आदिमध्यावसानेषु योगस्याभयदाय च॥',
      'Salutation to thee, O Natha — O Lord Adinatha. Salutation to thee who gives refuge at the beginning, middle, and end of Yoga.'
    ),
    (
      2,
      'नाथे देशिकरूपेण ज्ञानदीपं प्रकाशिते। प्रणम्य परमेशानं प्रवक्ष्याम्यहमादरात्॥',
      'Saluting the Supreme Lord Shiva, who is in the form of the Guru and who revealed the lamp of knowledge, I will speak with devotion.'
    ),
    (
      3,
      'राजयोगः समाधिश्च उन्मनी च मनोन्मनी। अमरत्वं लयस्तत्त्वं शून्याशून्यं परं पदम्॥',
      'Raja Yoga, Samadhi, Unmanee, Manonmanee, Immortality, Laya, Tattva, Void and not-void, the Supreme State —'
    ),
    (
      4,
      'अमनस्कं तथाद्वैतं निरालम्बं निरञ्जनम्। जीवन्मुक्तिश्च सहजा तुर्यासावेति चाभिधाः॥',
      'No-mind state, non-duality, unsupported state, stainless, living liberation, natural state, the fourth state — all these are synonyms.'
    ),
    (
      5,
      'सलिले सैन्धवं यद्वत्साम्यमाप्नोति योगतः। तथात्ममनसोरैक्यं समाधिरभिधीयते॥',
      'As salt dissolves in water and they become one, so when Atman and mind become one, that is called Samadhi.'
    ),
    (
      10,
      'जीवात्मपरमात्मनोः ऐक्यलक्षणं। तस्मिन् यः सर्वदा याति स मुक्तः परमार्थतः॥',
      'The union of the individual soul and the universal soul is the characteristic of Samadhi. He who always abides in this is truly liberated.'
    ),
    (
      16,
      'वायुना शक्तिचालेन प्रेरिता सुषुम्णागता। धत्ते मनो निराधारं तदा संजायते लयः॥',
      'When the Prana moves through Sushumna, driven by Shakti, the mind becomes supportless — then Laya is born.'
    ),
    (
      23,
      'ज्योतिरेव मनो यस्य स योगी योगवित्तमः। तस्यैव लभ्यते मोक्षो नान्यस्यान्यप्रकाशनात्॥',
      'The Yogi whose mind is light itself — he is the knower of Yoga. Liberation is obtained by him alone, not by one whose light comes from elsewhere.'
    ),
    (
      29,
      'अनाहतस्य शब्दस्य ध्वनिर्य उपलभ्यते। ध्वनेरन्तर्गतं ज्ञानं ज्ञानान्तर्गतं मनः। तन्मनो विलयं याति तद्विष्णोः परमं पदम्॥',
      'Of the Anahata sound which is perceived, there is inner knowledge. Within that knowledge is the mind. That mind dissolves — that is the supreme state of Vishnu.'
    ),
    (
      40,
      'नादो नादे मनो नादे मनो लीनं हि तन्मनः। यस्मिन् लीनं मनस्तस्मिन् नादे लीनं जानीहि तत्॥',
      'The mind dissolves in Nada, is absorbed in Nada — the mind is truly that Nada. Know the mind to be dissolved in that Nada in which it has dissolved.'
    ),
    (
      54,
      'नादो ध्वनिः परो बिन्दुर्बिन्दोः परतरं पदम्। तदेव परमं ब्रह्म परमात्मेति कथ्यते॥',
      'Sound is the Nada, from Sound comes Bindu, beyond Bindu is the Supreme State. That alone is the Supreme Brahman — it is called the Paramatman.'
    ),
    (
      67,
      'एवं नानाविधोपायैर्योगी नादपरायणः। नादे लीनमनाः कुर्यादेकाग्रमनसो लयम्॥',
      'Thus the Yogi devoted to Nada, by various means, should dissolve the mind in Nada and achieve one-pointedness through Laya.'
    ),
    (
      79,
      'तरङ्गभङ्गे सलिलं सलिले च घटाम्बु यत्। खे खं समीरे समीरो यथा योगविधौ तथा॥',
      'As waves subside into water, water merges into the pot\'s water, pot\'s water into the sky, sky into air, air into air — so in the practice of Yoga, the mind merges into its source.'
    ),
    (
      100,
      'विलयं यान्तु संकल्पाः सर्वे संकल्पवर्जितः। न किञ्चित्क्वचिदपि स्वरूपं भावयेत्ततः॥',
      'Let all thoughts dissolve — become free of all thoughts. Do not contemplate anything, the self or otherwise — that is the state.'
    ),
    (
      113,
      'सर्वे हठलयोपाया राजयोगस्य सिद्धये। राजयोगसमारूढः पुरुषः कालवञ्चकः॥',
      'All the methods of Hatha and Laya Yoga are for the attainment of Raja Yoga. The person who is established in Raja Yoga cheats death.'
    ),
    (
      114,
      'तत्त्वं बीजं हठः क्षेत्रमौदासीन्यमुदाहृतम्। लयः फलमिदं प्रोक्तं योगशास्त्रविशारदैः॥',
      'Reality is the seed, Hatha is the field, indifference is declared as the water — Laya is the fruit. This is proclaimed by those learned in the science of Yoga.'
    ),
  ];
  for (final (v, sk, en) in verses) {
    _insert(db,
        id: 'HYP.4.$v',
        chapter: 4,
        verse: v,
        sanskrit: sk,
        english: en,
        chapterLabel: label);
  }
  print('  ✓ Chapter 4 — Samadhi: ${verses.length} verses');
  return verses.length;
}
