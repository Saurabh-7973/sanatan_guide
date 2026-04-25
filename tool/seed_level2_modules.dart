// tool/seed_level2_modules.dart
//
// Run from project root AFTER seed_modules.dart:
//   dart run tool/seed_level2_modules.dart
//
// Adds Level 2 modules (mod_09–mod_17) to assets/db/sanatan_guide.db
// Does NOT touch Level 1 data.

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

Future<void> main() async {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    print('❌ DB not found at $dbPath');
    print('   Run seed_database.dart and seed_modules.dart first');
    exit(1);
  }
  final db = sqlite3.open(dbPath);
  try {
    _insertModules(db);
    _insertCards(db);
    _insertExtras(db);
    db.execute('PRAGMA user_version = 4;');
    final total = db
        .select('SELECT COUNT(*) AS c FROM learning_modules')
        .first['c'] as int;
    final cards =
        db.select('SELECT COUNT(*) AS c FROM module_cards').first['c'] as int;
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Level 2 seeding complete');
    print('   Total modules : $total');
    print('   Total cards   : $cards');
    print('   Output        : $dbPath');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } finally {
    db.dispose();
  }
}

void _insertModules(Database db) {
  const modules = [
    (
      'mod_09',
      'The 4 Vedas — Structure & Essence',
      'Four books written 3,500 years ago contain the oldest continuous record of human thought. Here is what they actually say.',
      2,
      9,
      15,
      6
    ),
    (
      'mod_10',
      'The 10 Mukhya Upanishads',
      '108 Upanishads exist. Ten of them contain everything. Adi Shankara said 12 verses of the Mandukya alone are sufficient for liberation.',
      2,
      10,
      20,
      6
    ),
    (
      'mod_11',
      'Bhagavad Gita — Full 18-Chapter Study',
      'You have read verses. Now read the argument. The Gita is not 700 disconnected aphorisms — it is one continuous philosophical answer to one impossible question.',
      2,
      11,
      20,
      6
    ),
    (
      'mod_12',
      'Ramayana — The Dharma of Rama',
      "Rama's story is not about a perfect man. It is about what it costs to be a righteous one.",
      2,
      12,
      20,
      6
    ),
    (
      'mod_13',
      'Mahabharata — The War Within',
      'The Mahabharata is not a war story. It is a complete map of the human condition — every choice, every failure, every grace.',
      2,
      13,
      20,
      6
    ),
    (
      'mod_14',
      'The 18 Mahapuranas — A Guide',
      'You know the Gita. The Puranas are where the same philosophy becomes story, image, and song.',
      2,
      14,
      15,
      6
    ),
    (
      'mod_15',
      'The 4 Paths of Yoga',
      'Yoga is not a posture. It is a complete technology of human transformation — and there are four distinct versions of it, each suited to a different type of person.',
      2,
      15,
      20,
      6
    ),
    (
      'mod_16',
      'Ayurveda — Science of Life',
      'India developed a complete system of medicine 3,000 years ago that modern research keeps validating. It begins with one question Western medicine rarely asks: what is your nature?',
      2,
      16,
      15,
      6
    ),
    (
      'mod_17',
      'Sanskrit Starter — 30 Days of Devanagari',
      'The language of the Vedas is not dead. It is the most precisely constructed language in human history, and you are already reading it — one letter at a time.',
      2,
      17,
      20,
      6
    ),
  ];

  for (final (id, title, hook, level, seq, mins, cards) in modules) {
    db.execute(
      'INSERT OR REPLACE INTO learning_modules '
      '(id, title, hook, level, sequence, estimated_minutes, card_count) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, title, hook, level, seq, mins, cards],
    );
  }
}

void _insertCards(Database db) {
  final cards = <(String, String, int, String, String)>[
    // ── mod_09: The 4 Vedas ───────────────────────────────────────────────
    (
      'mod_09_c1',
      'mod_09',
      1,
      'What are the Vedas?',
      'The four Vedas — Rigveda, Samaveda, Yajurveda, Atharvaveda — are the oldest scriptures of Sanatan Dharma. They are called Shruti: "that which was heard." The Rishis, in states of deep meditation, heard the fundamental patterns of cosmic order and recorded them. The Vedas are apaurusheya — not of human authorship. They were not composed. They were perceived.'
    ),
    (
      'mod_09_c2',
      'mod_09',
      2,
      'Rigveda — The Book of Hymns',
      '10,552 mantras in 10 Mandalas, addressed to the devas of the natural world: Agni (fire), Indra (thunder), Varuna (cosmic order), Surya (sun). The most famous passage: the Nasadiya Sukta — a creation hymn that begins "Then even nothingness was not, nor existence." It poses questions modern cosmology is still trying to answer: Was there a beginning? Who was there to witness it?'
    ),
    (
      'mod_09_c3',
      'mod_09',
      3,
      'Samaveda — The Book of Melodies',
      'The Samaveda is the Rigveda set to music — it is the foundation of Indian classical music. 75 of its 1,875 verses are original; the rest are from the Rigveda but with melodic notations. Where the Rigveda speaks to the gods, the Samaveda sings to them. The Upanishad born from it — the Chandogya — contains "Tat Tvam Asi": Thou art That.'
    ),
    (
      'mod_09_c4',
      'mod_09',
      4,
      'Yajurveda — The Book of Ritual',
      'The Yajurveda provides instructions for Vedic yajnas (fire rituals). It exists in two recensions: Krishna (Black) Yajurveda — the older, prose-heavy version; and Shukla (White) Yajurveda — more organised. The Brihadaranyaka Upanishad — the largest of all Upanishads — belongs to the Shukla Yajurveda and contains the most direct teachings on the nature of Brahman and Atman.'
    ),
    (
      'mod_09_c5',
      'mod_09',
      5,
      'Atharvaveda — The Veda of Daily Life',
      'The most misunderstood Veda. While the other three deal with cosmic ritual and philosophy, the Atharvaveda deals with the practical concerns of ordinary life: healing herbs and medicines, mantras for protection, astronomy, statecraft, and relationships. It contains early Ayurvedic formulations. The Mandukya Upanishad, which Adi Shankara called "sufficient for liberation," belongs to the Atharvaveda.'
    ),
    (
      'mod_09_c6',
      'mod_09',
      6,
      'What the Vedas are not',
      'The Vedas are not a creed to be believed. They do not contain a creation story in the Genesis sense. They do not require exclusive allegiance. The Vedas are an invitation to inquiry — the greatest questions a human mind can ask, recorded in the most precise language humans have ever developed for the purpose. You do not need to understand Sanskrit to benefit from studying them. You need only be willing to sit with the questions.'
    ),

    // ── mod_10: The 10 Mukhya Upanishads ──────────────────────────────────
    (
      'mod_10_c1',
      'mod_10',
      1,
      'What are the Upanishads?',
      'Upanishad means "sitting near" — as a student sits near a teacher. They are the final section of each Veda, called Vedanta (end of the Vedas). 108 Upanishads exist, but ten are considered Mukhya — principal. These ten were commented upon by Adi Shankara in the 8th century and are the basis of all Vedantic philosophy. Together they contain one central teaching, said ten different ways: Atman is Brahman. You are That.'
    ),
    (
      'mod_10_c2',
      'mod_10',
      2,
      'Isha and Kena — The Shortest, The Sharpest',
      'The Isha Upanishad (18 verses) opens with the most radical statement in all of Indian philosophy: "All this — whatever moves in this moving world — is enveloped by the Lord." Nothing is excluded from Brahman. The Kena asks the most fundamental epistemological question: What is it that the mind cannot grasp, but by which the mind grasps? The answer is Brahman — the knowing behind all knowing.'
    ),
    (
      'mod_10_c3',
      'mod_10',
      3,
      'Katha — Nachiketa Questions Death',
      'A young boy, Nachiketa, is accidentally given to Yama (Death) by his father. He waits at Yama\'s door for three days unfed. Yama, impressed, grants him three boons. Nachiketa asks his final boon: "What happens after death?" Yama tries to dissuade him with offers of wealth and pleasure. Nachiketa refuses. This is the teaching: only one who refuses the distractions of maya is ready to hear the truth of the Self.'
    ),
    (
      'mod_10_c4',
      'mod_10',
      4,
      'Chandogya — Tat Tvam Asi',
      'The Chandogya Upanishad contains the mahavakya most cited as the essence of Advaita Vedanta: "Tat Tvam Asi" — Thou art That. The teaching is given by Uddalaka to his son Shvetaketu through analogies: dissolve salt in water, and though you cannot see the salt, it pervades everything. Brahman is like the salt. The individual self is like the water. They are not two things.'
    ),
    (
      'mod_10_c5',
      'mod_10',
      5,
      'Brihadaranyaka — The Largest',
      'The largest of the Upanishads contains the famous dialogue between Yajnavalkya and his wife Maitreyi. She asks: "If I had all the wealth in the world, would it make me immortal?" He says no. She then says: "What use is wealth to me if it cannot give me immortality? Tell me what you know." This is considered the highest moment in the entire Upanishadic corpus — a human being refusing finite comfort in order to seek the infinite.'
    ),
    (
      'mod_10_c6',
      'mod_10',
      6,
      'Mandukya — 12 Verses, Complete Liberation',
      'The shortest major Upanishad — 12 verses. It analyses the three states of consciousness (waking, dreaming, deep sleep) and points to the fourth — Turiya — the awareness that witnesses all three without being any of them. Adi Shankara wrote a 12,000-verse commentary on these 12 verses. The teaching: your real nature is the unchanging witness. You are already free.'
    ),

    // ── mod_11: Bhagavad Gita 18-Chapter Study ────────────────────────────
    (
      'mod_11_c1',
      'mod_11',
      1,
      'The Setup — Chapters 1 and 2',
      'Arjuna sees his family on the opposing side and refuses to fight. This is not cowardice — it is the most sophisticated ethical crisis a human can face: what do you do when duty requires you to harm those you love? Krishna\'s response to this crisis — over the next 16 chapters — is the entire Gita. Chapter 2 introduces Sankhya: the body dies, the Self does not. Your grief for the body is based on a fundamental misidentification.'
    ),
    (
      'mod_11_c2',
      'mod_11',
      2,
      'The Path of Action — Chapters 3 to 5',
      'Karma Yoga: the yoga of action. The key teaching — you have a right to action, never to its fruits. Act fully, without attachment to outcome. This is not fatalism — it is the most sophisticated action philosophy ever written. The karma yogi does not renounce the world; they act in the world without being enslaved to results. Chapter 4 adds: knowledge destroys karma. Chapter 5 reconciles: both renunciation and action lead to the same end.'
    ),
    (
      'mod_11_c3',
      'mod_11',
      3,
      'Meditation and the Mind — Chapter 6',
      'Dhyana Yoga: the yoga of meditation. Krishna describes the steadied mind in precise terms: it is like a lamp in a windless place that does not flicker. Arjuna asks what happens to the person who tries to meditate but fails before reaching perfection. Krishna\'s answer is one of the most compassionate in all of scripture: no effort toward goodness is ever wasted. The sincere meditator who falls is reborn in a home where practice continues.'
    ),
    (
      'mod_11_c4',
      'mod_11',
      4,
      'Devotion — Chapters 7 to 12',
      'The middle section of the Gita is the theology of Bhakti. Chapter 9 contains the most intimate statement: "To those who worship me with devotion, I carry what they lack and preserve what they have." Chapter 11 — the Vishvarupa Darshana — Arjuna sees the entire cosmos inside Krishna\'s body. He begs Krishna to return to his gentle form. Chapter 12 defines the true devotee: equanimity in pleasure and pain, free from ego, compassionate to all.'
    ),
    (
      'mod_11_c5',
      'mod_11',
      5,
      'The Three Gunas — Chapter 14',
      'One of the most practical frameworks in all Indian philosophy. Everything in prakriti is composed of three qualities: Tamas (inertia, darkness, heaviness), Rajas (activity, passion, restlessness), Sattva (clarity, light, balance). These are not fixed — they shift with food, sleep, environment, and company. The goal is not maximum Sattva but transcendence of all three. One who has gone beyond the gunas is called Trigunatita.'
    ),
    (
      'mod_11_c6',
      'mod_11',
      6,
      'The Synthesis — Chapter 18',
      'The final chapter synthesises all 17 that preceded it. The last verse of the Gita is not spoken by Krishna — it is spoken by Sanjaya, the narrator: "Wherever there is Krishna and wherever there is Arjuna, there will be prosperity, victory, happiness, and sound ethics." The Gita does not end with a command or a creed. It ends with an observation: when knowledge meets devotion, when consciousness meets dedicated action — there is everything worth having.'
    ),

    // ── mod_12: Ramayana ──────────────────────────────────────────────────
    (
      'mod_12_c1',
      'mod_12',
      1,
      'The Text Itself',
      "Valmiki's Ramayana: 24,000 shlokas in 7 Kandas. Composed around 500 BCE — the oldest dated version. Tulsidas wrote the Ramcharitmanas in Awadhi in the 16th century — the version most widely sung in North India. They tell the same story differently: Valmiki's is literary and sometimes morally complex; Tulsidas's is devotional and theological. Both are essential."
    ),
    (
      'mod_12_c2',
      'mod_12',
      2,
      'Ayodhya Kanda — The Impossible Choice',
      'Rama is about to be crowned king when his stepmother Kaikeyi invokes an old promise: send Rama to the forest for 14 years, crown my son Bharata instead. Dasharatha is destroyed by this. Rama simply accepts. This is the central teaching of the Ramayana: dharma requires living within one\'s word even when the cost is unbearable. Rama does not rebel. He walks into the forest without complaint.'
    ),
    (
      'mod_12_c3',
      'mod_12',
      3,
      "Aranya Kanda — Sita's Abduction",
      'In the forest, Ravana abducts Sita through deception. The teaching: evil does not always attack directly. It disguises itself — as a golden deer, as a wandering ascetic. Ravana could not abduct Sita while she stood within Lakshmana\'s protective line. She was pulled outside by a kind impulse — to feed what appeared to be a hungry monk. Goodness itself becomes the door through which harm enters.'
    ),
    (
      'mod_12_c4',
      'mod_12',
      4,
      'Sundara Kanda — Hanuman Crosses the Ocean',
      'The most beloved Kanda. Hanuman, searching for Sita, leaps across the ocean to Lanka. He finds her imprisoned in the Ashoka grove — grieving, resolute, refusing Ravana\'s advances. Hanuman\'s interaction with Sita is one of the most delicate in all of Indian literature: how does a servant of Rama introduce himself to Rama\'s wife without alarming her? With the humility that only comes from complete ego-dissolution.'
    ),
    (
      'mod_12_c5',
      'mod_12',
      5,
      'Yuddha Kanda — The War',
      'The war is not between good and evil in simple terms. Ravana is a Brahmin, a Shiva devotee, a genius. His downfall is singular: he used his extraordinary gifts entirely in service of his ego. Rama wins not because he is stronger — he wins because he acts without personal interest. His actions are in alignment with dharma; Ravana\'s are in alignment with Ravana.'
    ),
    (
      'mod_12_c6',
      'mod_12',
      6,
      'Uttara Kanda — The Painful End',
      'The controversial final Kanda: Rama, bowing to public opinion, exiles the pregnant Sita. This has troubled readers and scholars for centuries. The teaching — if there is one — is that dharma sometimes demands the sacrifice of private happiness for public duty. Rama suffers. This is not presented as a triumph. It is presented as the heaviest cost that a king who places dharma above personal desire must sometimes pay.'
    ),

    // ── mod_13: Mahabharata ───────────────────────────────────────────────
    (
      'mod_13_c1',
      'mod_13',
      1,
      'The Scale of It',
      '100,000+ shlokas across 18 Parvas. The longest poem ever written. It contains the Bhagavad Gita, the Vishnu Sahasranama, the Yaksha Prashna, Vidura Niti, the Shanti Parva, and hundreds of sub-stories. The traditional description: "What is here may be found elsewhere. What is not here is nowhere." Every moral and philosophical question the human mind can generate has already been asked — and answered — somewhere in the Mahabharata.'
    ),
    (
      'mod_13_c2',
      'mod_13',
      2,
      'The Setup — Two Families, One Throne',
      'The Pandavas and the Kauravas are cousins. Their conflict over the throne of Hastinapura is the central plot. But the Mahabharata is not interested in who wins the throne. It is interested in why good people make bad choices, why righteous people suffer, and whether justice is written into the structure of the universe. The Kurukshetra War is the stress test for every ethical theory in the tradition.'
    ),
    (
      'mod_13_c3',
      'mod_13',
      3,
      'Karna — The Impossible Dharma',
      'Karna is perhaps the greatest figure in the entire epic. Born to Kunti before her marriage, raised by a charioteer, humiliated by Drona for his low birth, and befriended by Duryodhana — the man opposing his own brothers. Karna knows the truth of his birth and still fights for Duryodhana out of loyalty. The Mahabharata asks: is loyalty to a friend more binding than blood duty? There is no clean answer.'
    ),
    (
      'mod_13_c4',
      'mod_13',
      4,
      'Yaksha Prashna — The Questions of the Lake',
      'Yudhishthira arrives at a lake where a Yaksha has killed his brothers for drinking without permission. The Yaksha agrees to restore them if Yudhishthira can answer his questions. The questions are the most concentrated philosophical catechism in Indian literature: "What is heavier than the earth? What is higher than the sky? What is faster than the wind? What is more numerous than grass?" The answers are not astronomical. They are about human character.'
    ),
    (
      'mod_13_c5',
      'mod_13',
      5,
      "Bhishma's Deathbed — The Shanti Parva",
      'Bhishma lies on a bed of arrows for 58 days, kept alive by his boon to choose his time of death. During this period, he teaches Yudhishthira everything he knows about dharma, statecraft, and liberation. The Shanti Parva — the Book of Peace — is the longest single Parva and contains perhaps the most mature ethical and political philosophy in the entire tradition. A dying man, with nothing left to gain or lose, speaking without agenda.'
    ),
    (
      'mod_13_c6',
      'mod_13',
      6,
      'What the Mahabharata Actually Teaches',
      'The Mahabharata does not have a happy ending. The Pandavas win the war but lose almost everyone they love. Yudhishthira\'s final journey to heaven begins with even the loyal dog being turned away — until Yudhishthira refuses to enter without him. The great king who survived the war, who ruled justly for decades, performs his final act of dharma for a dog. The teaching: dharma is not an abstraction. It is what you do in the specific moment in front of you.'
    ),
    // ── mod_14: The 18 Mahapuranas ────────────────────────────────────────
    (
      'mod_14_c1',
      'mod_14',
      1,
      'What are the Puranas?',
      'The 18 Mahapuranas are encyclopaedias of Vedic religion — containing cosmology, genealogy, geography, mythology, philosophy, and ethics. Unlike the Vedas (direct revelation) or the Upanishads (philosophical inquiry), the Puranas communicate through story. They are addressed to ordinary people, not specialists. Their traditional instruction: they must contain five elements — cosmology, dissolution, the genealogy of gods, the ages of Manu, and the dynasties of kings.'
    ),
    (
      'mod_14_c2',
      'mod_14',
      2,
      'The Three Categories',
      'The Puranas are classified by the deity they primarily glorify. Vaishnava Puranas (Vishnu-centred): Bhagavata, Vishnu, Narada, Garuda, Padma, Varaha. Shaiva Puranas (Shiva-centred): Shiva, Linga, Skanda, Matsya, Kurma, Vayu. Brahma Puranas: Brahma, Brahmanda, Brahmavaivarta, Markandeya, Bhavishya, Agni. This is not sectarian competition — it is the same Brahman glorified through different aspects. Each tradition has its own doorway.'
    ),
    (
      'mod_14_c3',
      'mod_14',
      3,
      'Start Here — Bhagavata Purana',
      'The Bhagavata Purana (12 Books) is considered the crown of all Puranas. Book 10 — the life of Krishna — is the most widely read religious text in Indian history outside the Gita. Book 11 contains the Uddhava Gita, a deeper post-Kurukshetra teaching Krishna gives to his closest friend. Book 12 describes the deterioration of dharma in the Kali Yuga. The Bhagavata\'s central theme: Bhakti is the highest path, available to everyone regardless of birth, gender, or caste.'
    ),
    (
      'mod_14_c4',
      'mod_14',
      4,
      'Three More to Know',
      'Vishnu Purana: the ten avatars of Vishnu in their fullest form — the most systematic of the Vaishnava Puranas. Shiva Purana: the complete theology of Shaivism, including the stories of Shiva and Parvati, the meaning of the Shivalinga, the 12 Jyotirlingas. Garuda Purana: the Purana of death, the afterlife, and liberation — read at funerals, containing detailed accounts of what happens after the body dies. More a guide to conscious dying than a book of fear.'
    ),
    (
      'mod_14_c5',
      'mod_14',
      5,
      'Markandeya Purana — The Devi Mahatmyam',
      'The Markandeya Purana contains the Devi Mahatmyam (700 verses) — the primary text of Shakta worship. It describes three battles of the Goddess against three demons representing different forms of ignorance: Madhu-Kaitabha (desire-aversion), Mahishasura (ego), and Shumbha-Nishumbha (the subtlest layer — the sense of separate self). The Devi Mahatmyam is recited during Navratri. It is a complete map of the inner war against ignorance.'
    ),
    (
      'mod_14_c6',
      'mod_14',
      6,
      'How to Approach the Puranas',
      'Do not try to read them cover to cover. The Puranas were not meant to be read — they were meant to be heard, in sections, at the right time. The approach: identify which deity you feel most drawn to, find the Purana associated with that deity, and read its key stories. Use translations like C. Rajagopalachari\'s versions or Bibek Debroy\'s scholarly translations. The goal is not information — it is the shift in consciousness that comes from sustained attention to sacred narrative.'
    ),

    // ── mod_15: The 4 Paths of Yoga ───────────────────────────────────────
    (
      'mod_15_c1',
      'mod_15',
      1,
      'What is Yoga?',
      'The word Yoga comes from the Sanskrit root yuj — to yoke, to unite. Yoga is the practice of uniting the individual self (Atman) with universal consciousness (Brahman). There are four classical paths: Jnana Yoga (path of knowledge), Bhakti Yoga (path of devotion), Karma Yoga (path of action), and Raja Yoga (path of meditation). Swami Vivekananda systematised these four in his lectures at the Parliament of Religions in 1893. His four books on the Yoga paths remain unmatched.'
    ),
    (
      'mod_15_c2',
      'mod_15',
      2,
      'Jnana Yoga — For the Intellect',
      'The path of discrimination (viveka) and non-attachment (vairagya). The core practice: Neti, neti — "not this, not this." The jnani systematically asks: Am I the body? No — I observe the body. Am I the mind? No — I observe the mind. What is left when everything that can be observed is excluded? The observer itself. That observer is Atman. Jnana Yoga requires a very specific temperament: those who naturally analyse, question, and cannot accept belief without reason.'
    ),
    (
      'mod_15_c3',
      'mod_15',
      3,
      'Bhakti Yoga — For the Heart',
      'The path of love and devotion. The Bhakti yogi does not approach the divine through logic but through relationship — as child to parent, devotee to deity, lover to beloved. The nine forms of Bhakti described in the Bhagavata Purana: listening, chanting, remembering, serving, worshipping, saluting, servitude, friendship, and total surrender. Bhakti is considered the most accessible path — it requires no special scholarship, only genuine love.'
    ),
    (
      'mod_15_c4',
      'mod_15',
      4,
      'Karma Yoga — For the Active',
      'The path of selfless action. The karma yogi does not withdraw from the world — they engage it completely, but without the ego-attachment that generates new karma. The Bhagavad Gita is primarily a Karma Yoga text. The key practice: doing the work fully, offering the results to the divine, and not identifying yourself as the doer. This is not passivity — it is the most intense form of action, because it requires simultaneous full engagement and complete non-attachment.'
    ),
    (
      'mod_15_c5',
      'mod_15',
      5,
      'Raja Yoga — For the Scientific Mind',
      "The path of meditation, based on Patanjali's Yoga Sutras. Raja means royal — this is the direct path to the source. The eight limbs: Yama (ethical restraints), Niyama (personal disciplines), Asana (seat/posture), Pranayama (breath control), Pratyahara (withdrawal of senses), Dharana (concentration), Dhyana (meditation), Samadhi (absorption). Most people know only the third limb — Asana. Raja Yoga is the complete system of which modern yoga is one eighth."
    ),
    (
      'mod_15_c6',
      'mod_15',
      6,
      'Which Path is Yours?',
      "Vivekananda's answer: most people are a combination. The intellectual benefits from Jnana; the emotional from Bhakti; the active from Karma; the methodical from Raja. Most traditions recommend all four in proportion, with one as the primary doorway. The great teachers emphasise: the path matters less than the sincerity. A Bhakta with genuine love is closer to liberation than a Jnani with mere cleverness. The question to ask is not which path is superior — but which path feels like coming home."
    ),

    // ── mod_16: Ayurveda ──────────────────────────────────────────────────
    (
      'mod_16_c1',
      'mod_16',
      1,
      'What is Ayurveda?',
      'Ayurveda — Ayu (life) + Veda (knowledge) — is the traditional Indian science of health and longevity. Its foundational texts, the Charaka Samhita and Sushruta Samhita, were compiled around 600 BCE but draw on far older oral traditions. Ayurveda is not alternative medicine — it is a complete system that preceded the Germ Theory by 2,500 years and described surgical procedures, pharmacology, and preventive medicine in detail. Its central premise: health is not the absence of disease but the presence of balance.'
    ),
    (
      'mod_16_c2',
      'mod_16',
      2,
      'The Three Doshas',
      'Everything in the universe, according to Ayurveda, is composed of five elements: Akasha (space), Vayu (air), Agni (fire), Jala (water), and Prithvi (earth). These combine in the body as three doshas. Vata (Vayu + Akasha): movement, communication, creativity. Pitta (Agni + Jala): transformation, digestion, intelligence. Kapha (Jala + Prithvi): structure, stability, endurance. Everyone has all three, but one or two typically dominate.'
    ),
    (
      'mod_16_c3',
      'mod_16',
      3,
      'Prakriti — Your Constitution',
      'Your Prakriti is your fundamental nature — the proportion of doshas you were born with. It does not change through your life. Your Vikriti is your current state — where the doshas actually are today, which may be out of balance with your Prakriti. The practice of Ayurveda is simple in principle: return the Vikriti to the Prakriti. Know your nature; live in alignment with it.'
    ),
    (
      'mod_16_c4',
      'mod_16',
      4,
      'Vata, Pitta, Kapha — What They Look Like',
      'Vata-dominant: thin build, quick mind, creative, enthusiastic, prone to anxiety and irregular habits. Imbalance: insomnia, constipation, worry, dryness. Pitta-dominant: medium build, sharp intellect, organised, natural leaders, prone to anger and criticism. Imbalance: inflammation, acid, irritability. Kapha-dominant: solid build, calm, loyal, patient, prone to slowness and attachment. Imbalance: weight gain, congestion, depression.'
    ),
    (
      'mod_16_c5',
      'mod_16',
      5,
      'Dinacharya in Ayurveda',
      'Ayurveda prescribes a daily routine (Dinacharya) calibrated to your dosha. Universal practices: wake before sunrise (especially important for Kapha), scrape the tongue to remove Ama (accumulated toxins), practice oil pulling, exercise according to constitution — Vata: gentle yoga; Pitta: cooling exercise; Kapha: vigorous movement. Eat the largest meal at midday when digestive fire is strongest. The principle: the body has its own rhythms. Health is living in sync with them.'
    ),
    (
      'mod_16_c6',
      'mod_16',
      6,
      'Connection to Vedic Practice',
      'Ayurveda is considered the Upaveda (subsidiary Veda) of the Atharvaveda. The same worldview underlies both: the universe is fundamentally conscious, and the human body is a microcosm of that consciousness. The Ayurvedic concept of Prana — the vital life force — is the same Prana that Pranayama works with. The Ayurvedic understanding of Agni (digestive fire) parallels the yajna (ritual fire) of the Vedas. Health, in the Vedic worldview, is not a purely physical matter. It is a dharmic one.'
    ),

    // ── mod_17: Sanskrit Starter ──────────────────────────────────────────
    (
      'mod_17_c1',
      'mod_17',
      1,
      'Why Sanskrit?',
      'Sanskrit (Samskrit — refined, perfected) is the language in which the Vedas, Upanishads, Bhagavad Gita, and all primary Hindu scriptures were composed. Modern linguistics considers it the most grammatically precise natural language ever documented. NASA researcher Rick Briggs wrote in 1985 that Sanskrit is the only human language suitable for computer programming due to its unambiguous grammar. Learning to read Devanagari changes your relationship with every mantra, every verse, every shloka you have encountered in this app.'
    ),
    (
      'mod_17_c2',
      'mod_17',
      2,
      'Week 1 — The Vowels (Svaras)',
      'Sanskrit has 16 vowels, each with a short and long form. Short vowels: अ (a), इ (i), उ (u), ऋ (ri). Long vowels: आ (aa), ई (ii), ऊ (uu). Diphthongs: ए (e), ऐ (ai), ओ (o), औ (au). The most important vowel: अ (a) — the first sound, the sound of the open mouth, associated with Brahman. The Gita opens: Dhritarashtra uvaacha. The "a" in uvaacha is this vowel. Every Devanagari consonant contains this vowel unless marked otherwise.'
    ),
    (
      'mod_17_c3',
      'mod_17',
      3,
      'Week 2 — The Consonants (Vyanjanas)',
      'Sanskrit has 33 consonants arranged in a precise phonetic grid by place of articulation (where in the mouth the sound is made) and manner of articulation (how the airflow is modified). The five groups: Velar (ka group: क ख ग घ), Palatal (ca group: च छ ज झ), Retroflex (ta group: ट ठ ड ढ), Dental (ta group: त थ द ध), Labial (pa group: प फ ब भ). Plus semi-vowels, sibilants, and aspirate. This organisation is a complete map of human speech sound production.'
    ),
    (
      'mod_17_c4',
      'mod_17',
      4,
      'Week 3 — Conjunct Consonants',
      'Sanskrit words frequently combine two or more consonants without a vowel between them — called conjunct consonants (samyukta akshara). Common ones from mantras: क्ष (ksha) as in Lakshmi, ज्ञ (jnya) as in Jnana, त्र (tra) as in mantra, श्र (shra) as in Shri, ण्म (nma) as in Janmashtami. Most difficulty new readers encounter is in these conjuncts. Once you recognise the 20 most common ones, 80% of Gita verses become readable.'
    ),
    (
      'mod_17_c5',
      'mod_17',
      5,
      'Week 4 — Reading Real Sanskrit',
      'You are now able to read the opening of the Bhagavad Gita in Devanagari: धृतराष्ट्र उवाच — Dhritarashtra uvaacha (Dhritarashtra said). धर्मक्षेत्रे कुरुक्षेत्रे — dharma-kshetre kuru-kshetre (on the field of dharma, on the field of Kurus). समवेता युयुत्सवः — samaveta yuyutsavah (having assembled, desirous of battle). You recognise every letter. You know the meaning. The script is no longer foreign — it is the original home of everything you have studied.'
    ),
    (
      'mod_17_c6',
      'mod_17',
      6,
      'What Comes Next',
      'With the 30-day foundation: you can read any Devanagari text phonetically. To understand it — begin with the Devanagari version of Bhagavad Gita 2.47 — the most famous verse. Write it out by hand three times. Look up each word in a Sanskrit dictionary (Monier-Williams, free online). This process — writing, sounding, looking up — is how Sanskrit has been transmitted for 3,500 years. There is no shortcut. There is only the joy of direct encounter with the language of the Rishis.'
    ),
  ];

  for (final (id, moduleId, seq, title, content) in cards) {
    db.execute(
      'INSERT OR REPLACE INTO module_cards '
      '(id, module_id, sequence, card_title, content) '
      'VALUES (?, ?, ?, ?, ?)',
      [id, moduleId, seq, title, content],
    );
  }
}

void _insertExtras(Database db) {
  const extras = [
    (
      'mod_09',
      'BG.15.15',
      '"I am the knowledge of the Vedas." — Krishna\'s statement makes clear that the Vedas point to the same source as the Gita.',
      'Which of the four Vedas feels most relevant to where you are in life right now — and why?'
    ),
    (
      'mod_10',
      'BG.2.20',
      'This verse on the eternal Atman is the Gita\'s summary of the Upanishadic teaching.',
      'Of the ten Upanishads described, which teaching speaks most directly to a question you are currently living with?'
    ),
    (
      'mod_11',
      'BG.18.66',
      '"Abandon all dharmas and take refuge in me alone." After 700 verses of teaching right action, Krishna says: go beyond even that.',
      'If you had to teach one chapter of the Gita to a complete beginner, which would you choose — and what is the one thing from it you would want them to understand?'
    ),
    (
      'mod_12',
      'BG.4.7',
      '"When Dharma declines, I manifest." Rama is the avatar who demonstrates dharma through living it, at every cost.',
      'Is there a moment in the Ramayana where you believe Rama made the wrong choice? What does that discomfort reveal about your own understanding of dharma?'
    ),
    (
      'mod_13',
      'BG.3.35',
      'Better one\'s own dharma, though imperfectly performed. The Mahabharata is a 100,000-verse exploration of what this costs.',
      'Of all the characters in the Mahabharata — Arjuna, Karna, Yudhishthira, Draupadi, Bhishma — which one\'s dharmic dilemma most resembles something you have faced in your own life?'
    ),
    (
      'mod_14',
      'BG.9.26',
      '"Whoever offers me with devotion a leaf, a flower, a fruit, or water..." — the Bhakti doorway that the Puranas embody.',
      'Which of the 18 Puranas calls to you — and what does that tell you about where you are in your practice?'
    ),
    (
      'mod_15',
      'BG.12.2',
      '"Those who fix their minds on me with great faith — I consider them to be most perfect in yoga." — Krishna\'s endorsement of Bhakti, while acknowledging all paths.',
      'If you had to choose one of the four yoga paths as your primary spiritual practice for the next year — which would it be, and why?'
    ),
    (
      'mod_16',
      'BG.6.17',
      '"For one regulated in eating, sleeping, recreation, and work — yoga destroys all sorrow." This is Ayurvedic wisdom in the Gita.',
      'Based on what you have read, which dosha do you think is dominant in your Prakriti? Which tends to go out of balance most often?'
    ),
    (
      'mod_17',
      'BG.10.25',
      '"Among the great sages I am Bhrigu; among words I am the one syllable (Om)." Language as a doorway to the divine.',
      'Write the word OM in Devanagari: ॐ. Sit with it for one minute. What does it feel like to write the symbol that represents the sound of the universe?'
    ),
  ];

  for (final (moduleId, verseId, note, reflection) in extras) {
    db.execute(
      'INSERT OR REPLACE INTO module_extras '
      '(module_id, anchor_verse_id, anchor_verse_note, reflection_question) '
      'VALUES (?, ?, ?, ?)',
      [moduleId, verseId, note, reflection],
    );
  }
}
