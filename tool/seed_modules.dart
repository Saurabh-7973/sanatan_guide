// tool/seed_modules.dart
//
// Run from project root AFTER seed_database.dart:
//   dart run tool/seed_modules.dart
//
// Adds learning module tables + data to assets/db/sanatan_guide.db.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

Future<void> main() async {
  final dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  if (!File(dbPath).existsSync()) {
    print('❌ DB not found at $dbPath');
    print('   Run: dart run tool/seed_database.dart first');
    exit(1);
  }

  final db = sqlite3.open(dbPath);

  try {
    _createModuleTables(db);
    _clearExistingModuleData(db);
    _insertModules(db);
    _insertCards(db);
    _insertExtras(db);
    db.execute('PRAGMA user_version = 4;');

    final count =
        db.select('SELECT COUNT(*) AS c FROM learning_modules').first['c']
            as int;
    final cardCount =
        db.select('SELECT COUNT(*) AS c FROM module_cards').first['c'] as int;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Module seeding complete');
    print('   Modules  : $count');
    print('   Cards    : $cardCount');
    print('   Output   : $dbPath');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  } finally {
    db.dispose();
  }
}

void _createModuleTables(Database db) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS learning_modules (
      id TEXT PRIMARY KEY NOT NULL,
      title TEXT NOT NULL,
      hook TEXT NOT NULL,
      level INTEGER NOT NULL,
      sequence INTEGER NOT NULL,
      estimated_minutes INTEGER NOT NULL,
      card_count INTEGER NOT NULL
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS module_cards (
      id TEXT PRIMARY KEY NOT NULL,
      module_id TEXT NOT NULL,
      sequence INTEGER NOT NULL,
      card_title TEXT NOT NULL,
      content TEXT NOT NULL
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS module_extras (
      module_id TEXT PRIMARY KEY NOT NULL,
      anchor_verse_id TEXT,
      anchor_verse_note TEXT,
      reflection_question TEXT
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS user_module_progress (
      module_id TEXT PRIMARY KEY NOT NULL,
      cards_read INTEGER NOT NULL DEFAULT 0,
      is_completed INTEGER NOT NULL DEFAULT 0
                            CHECK (is_completed IN (0, 1)),
      started_at INTEGER,
      completed_at INTEGER
    )
  ''');
  print('Module tables ready');
}

void _clearExistingModuleData(Database db) {
  db.execute('DELETE FROM module_extras');
  db.execute('DELETE FROM module_cards');
  db.execute('DELETE FROM learning_modules');
  print('Cleared existing module data');
}

void _insertModules(Database db) {
  final stmt = db.prepare('''
    INSERT INTO learning_modules
      (id, title, hook, level, sequence, estimated_minutes, card_count)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  ''');

  for (final m in _modules) {
    stmt.execute([
      m['id'],
      m['title'],
      m['hook'],
      m['level'],
      m['sequence'],
      m['estimated_minutes'],
      m['card_count'],
    ]);
    print('  ✓ ${m['id']}: ${m['title']}');
  }
  stmt.dispose();
}

void _insertCards(Database db) {
  final stmt = db.prepare('''
    INSERT INTO module_cards
      (id, module_id, sequence, card_title, content)
    VALUES (?, ?, ?, ?, ?)
  ''');

  for (final card in _cards) {
    stmt.execute([
      card['id'],
      card['module_id'],
      card['sequence'],
      card['card_title'],
      card['content'],
    ]);
  }
  stmt.dispose();
  print('  Cards inserted: ${_cards.length}');
}

void _insertExtras(Database db) {
  final stmt = db.prepare('''
    INSERT INTO module_extras
      (module_id, anchor_verse_id, anchor_verse_note, reflection_question)
    VALUES (?, ?, ?, ?)
  ''');

  for (final e in _extras) {
    stmt.execute([
      e['module_id'],
      e['anchor_verse_id'],
      e['anchor_verse_note'],
      e['reflection_question'],
    ]);
  }
  stmt.dispose();
}

// ── Module metadata ──────────────────────────────────────────────────────────

const _modules = [
  {
    'id': 'mod_01',
    'title': 'What is Sanatan Dharma?',
    'hook':
        'Every major religion has a founder, a fixed book, and one path. Sanatan Dharma has none of these — and that is precisely its strength.',
    'level': 1,
    'sequence': 1,
    'estimated_minutes': 8,
    'card_count': 6,
  },
  {
    'id': 'mod_02',
    'title': 'The Five Core Concepts',
    'hook':
        'Five words. Understand these and you hold the operating system of all Hindu philosophy.',
    'level': 1,
    'sequence': 2,
    'estimated_minutes': 10,
    'card_count': 6,
  },
  {
    'id': 'mod_03',
    'title': 'The Trimurti and Major Deities',
    'hook':
        'Hinduism appears to have 33 crore gods. The actual number is one — and the 33 crore are its infinite faces.',
    'level': 1,
    'sequence': 3,
    'estimated_minutes': 12,
    'card_count': 6,
  },
  {
    'id': 'mod_04',
    'title': 'Sacred Symbols and Their Meanings',
    'hook':
        'Every symbol in Sanatan Dharma is a teaching compressed into an image. Once you know the code, you see philosophy everywhere.',
    'level': 1,
    'sequence': 4,
    'estimated_minutes': 8,
    'card_count': 6,
  },
  {
    'id': 'mod_05',
    'title': 'Festivals and Their Dharmic Logic',
    'hook':
        'Hindu festivals are not celebrations of historical events. They are annual reminders of eternal truths — philosophy encoded in fire, colour, and light.',
    'level': 1,
    'sequence': 5,
    'estimated_minutes': 12,
    'card_count': 6,
  },
  {
    'id': 'mod_06',
    'title': 'Daily Practice: Dinacharya',
    'hook':
        'Ancient India figured out 3,000 years ago what modern neuroscience is only now confirming: how you start each day is how you live each day.',
    'level': 1,
    'sequence': 6,
    'estimated_minutes': 10,
    'card_count': 6,
  },
  {
    'id': 'mod_07',
    'title': 'The Four Ashramas',
    'hook':
        'Most philosophies give one answer to the question: what is the meaning of life? Sanatan Dharma gives four answers — one for each stage of life.',
    'level': 1,
    'sequence': 7,
    'estimated_minutes': 10,
    'card_count': 6,
  },
  {
    'id': 'mod_08',
    'title': 'The Four Purusharthas',
    'hook':
        'Every major philosophy warns you that worldly desires are obstacles to spiritual growth. Sanatan Dharma is the only tradition that says: no — they are part of it.',
    'level': 1,
    'sequence': 8,
    'estimated_minutes': 10,
    'card_count': 6,
  },
];

// ── Card content (6 cards × 8 modules = 48) ─────────────────────────────────

Map<String, Object?> _cardRow(
  String id,
  String moduleId,
  int sequence,
  String cardTitle,
  String content,
) =>
    {
      'id': id,
      'module_id': moduleId,
      'sequence': sequence,
      'card_title': cardTitle,
      'content': content,
    };

final _cards = [
  // Module 1
  _cardRow('mod_01_card_01', 'mod_01', 1, 'The meaning of the words',
      r'"Sanatan" means eternal — without beginning and without end. "Dharma" means the law that upholds existence — closer to "righteous order" than to "religion." Put together: the eternal way of living in alignment with the order of the cosmos. This tradition does not call itself a religion. It calls itself a way of life.'),
  _cardRow('mod_01_card_02', 'mod_01', 2, 'No single founder',
      r'Every major world religion can be traced to one person — a prophet, a teacher, an awakened being. Sanatan Dharma has no such founder. It claims to have been discovered, not invented — the Rishis heard cosmic truths in deep meditation and recorded them as the Vedas. This is why it is called Apaurusheya: not of human origin.'),
  _cardRow('mod_01_card_03', 'mod_01', 3, 'No single book',
      r'The Bible is one book. The Quran is one book. Sanatan Dharma has the four Vedas, 108 Upanishads, the Bhagavad Gita, the Ramayana, the Mahabharata, 18 Mahapuranas, and hundreds of other texts. No single text is supreme above all others. Different traditions within Hinduism emphasise different texts — and all are considered valid.'),
  _cardRow('mod_01_card_04', 'mod_01', 4, 'No excommunication',
      r'In many traditions, departing from official doctrine means being expelled from the community. Sanatan Dharma has no equivalent. A Hindu can be a theist, atheist, monotheist, polytheist, or non-dualist — all are recognised paths within the tradition. Swami Vivekananda called this "the religion of tolerance."'),
  _cardRow('mod_01_card_05', 'mod_01', 5, 'Pluralism as a foundation',
      r'The oldest recorded statement of religious pluralism in human history comes from the Rigveda: "Ekam sat vipra bahudha vadanti" — Truth is one; the wise call it by many names. This single line is the philosophical foundation of the entire tradition. Multiple paths to the same summit is not a compromise — it is the original design.'),
  _cardRow('mod_01_card_06', 'mod_01', 6, 'The oldest living tradition',
      r'The Vedas are being recited today using the same oral transmission techniques used 3,500 years ago. The same festivals, the same mantras, the same philosophical questions. No other civilisational tradition on earth has this continuity. This is not just history — it is a living inheritance.'),
  // Module 2
  _cardRow('mod_02_card_01', 'mod_02', 1, 'Why five concepts?',
      r'Every complex system has a small set of foundational principles that everything else builds on. For Sanatan Dharma, those principles are Dharma, Karma, Moksha, Atman, and Brahman. Master these five and no scripture, no ritual, no philosophy within this tradition will be completely alien to you.'),
  _cardRow('mod_02_card_02', 'mod_02', 2, 'Dharma: your sacred duty',
      r"Dharma is not a universal set of rules — it is a personalised code aligned with your nature, your stage of life, and your circumstances. A warrior's Dharma is to protect. A teacher's Dharma is to transmit knowledge. A parent's Dharma is to nurture. The Bhagavad Gita's central question is: what is Arjuna's Dharma right now, in this situation? The answer runs for 18 chapters."),
  _cardRow('mod_02_card_03', 'mod_02', 3, 'Karma: the law of cause and effect',
      r'Karma is not fate and it is not punishment. It is the precise, impersonal law that every action generates a corresponding consequence. You are not a victim of karma — you are continuously creating it through your actions, words, and intentions. The teaching is empowering: your current situation was shaped by past choices, and your future is being shaped by the choices you are making right now.'),
  _cardRow('mod_02_card_04', 'mod_02', 4, 'Moksha: liberation',
      r'The highest goal in Sanatan Dharma is not heaven — heaven is a temporary state before returning to the cycle of birth and death. Moksha is permanent liberation from that cycle entirely. It is the recognition that you were never truly bound — that the self which seeks liberation is already free. Vivekananda described it as "the lion waking up to find the cage was never real."'),
  _cardRow('mod_02_card_05', 'mod_02', 5, 'Atman: the witness within',
      r'You have a body, a mind, and emotions — but you are not any of them. Watch your thoughts for a moment. Who is watching? That awareness which observes the mind without being the mind — that is the Atman. It is the unchanging witness behind every experience. It was not born when your body was born and it will not die when your body dies.'),
  _cardRow('mod_02_card_06', 'mod_02', 6, 'Brahman: the ground of all existence',
      "If Atman is the individual soul, Brahman is the universal soul — the consciousness that underlies all of existence. The ocean to the Atman's wave. The Upanishads contain the most important line in all of Indian philosophy: \"Tat Tvam Asi\" — Thou art That. The individual soul and the universal consciousness are ultimately the same. The wave is not separate from the ocean."),
  // Module 3
  _cardRow('mod_03_card_01', 'mod_03', 1, 'The one and the many',
      r'The formless absolute (Brahman) is infinite and impossible for the human mind to directly grasp. So Brahman takes form — and those forms are what we call deities. This is not polytheism in the Western sense. It is one reality expressing itself through infinite aspects, each aspect emphasising a different quality of the whole. Choosing a deity is choosing a face of truth that resonates with your nature.'),
  _cardRow('mod_03_card_02', 'mod_03', 2, 'The Trimurti: three functions',
      r'The cosmos has three fundamental functions: creation, preservation, and transformation. Sanatan Dharma expresses these as Brahma (the creator), Vishnu (the preserver), and Shiva (the transformer). These are not three separate gods competing for authority — they are three roles of one reality, just as the same water can be ice, liquid, and steam.'),
  _cardRow('mod_03_card_03', 'mod_03', 3, 'The Devi: the activating power',
      r'Shakti is the dynamic creative energy of the cosmos — the feminine divine principle. In the Shaiva tradition, it is said that without Shakti, Shiva is Shava (a corpse). The feminine divine is not secondary to the masculine — she is the activating power that makes all manifestation possible. Durga, Kali, Lakshmi, Saraswati — these are aspects of one Shakti.'),
  _cardRow('mod_03_card_04', 'mod_03', 4, 'Ganesha: the remover of obstacles',
      r'Ganesha is invoked at the beginning of every undertaking. His elephant head represents vast wisdom; his small mouth, the value of speaking little; his large ears, the importance of listening deeply; his one broken tusk, sacrifice in service of purpose. He removes obstacles because he IS the obstacle — he decides when you are ready to proceed.'),
  _cardRow('mod_03_card_05', 'mod_03', 5, 'Hanuman: the ideal devotee',
      r'In the Ramayana, when Hanuman is asked who he is, he answers: "When I think I am the body, I am your servant. When I think I am a soul, I am part of you. When I know myself as I truly am, I am you." This single statement contains the entire philosophy of Advaita Vedanta — three stages of spiritual understanding compressed into one sentence.'),
  _cardRow('mod_03_card_06', 'mod_03', 6, 'Krishna and Rama: dharmic ideals',
      r'Rama is the maryada purushottama — the ideal person who upholds Dharma even when it costs him everything. Every choice Rama makes is a meditation on what duty requires when duty is impossible. Krishna is the opposite archetype — the one who dances, teaches philosophy on a battlefield, and loves infinitely. Together they represent the two great questions: What must I do? And: Who am I?'),
  // Module 4
  _cardRow('mod_04_card_01', 'mod_04', 1, 'AUM: the sound of the universe',
      r'AUM is not a word — it is the primordial sound from which all creation emerges. The three letters represent three states: A = waking (creation), U = dream (preservation), M = deep sleep (dissolution). The silence after AUM represents Turiya, pure consciousness beyond all states. When you chant AUM, you are mapping the entire cosmos in one breath.'),
  _cardRow('mod_04_card_02', 'mod_04', 2, 'The Swastika: 5,000 years of auspiciousness',
      "The Swastika is found in Indus Valley sites dated to 3,000 BCE — it predates its 20th century misappropriation by 5,000 years. The Sanskrit etymology: Su (good) + Asti (to be) = \"May good prevail.\" The four arms represent the four Vedas, four directions, four stages of life. Its meaning in Sanatan Dharma has never changed — only the world's awareness of it was briefly obscured."),
  _cardRow('mod_04_card_03', 'mod_04', 3, 'The Lotus: the teaching of non-attachment',
      r'The lotus grows in mud, rises through water, and blooms in sunlight — unstained by the mud it emerged from. This is the central teaching of the Bhagavad Gita in one image: to live fully in the world, engaged in action, without being contaminated by it. The lotus enacts the principle of Karma Yoga in its every moment of existence.'),
  _cardRow('mod_04_card_04', 'mod_04', 4, 'Namaste: the deepest greeting',
      r'Namaste means "I bow to the divine in you." The hands pressed together (Anjali Mudra) represent the unification of the two hemispheres — the greeting is itself a meditation. When you say Namaste to someone, you are acknowledging Brahman in them. Every person you meet is the divine in disguise. This is not sentiment — it is a philosophical statement about the nature of reality.'),
  _cardRow('mod_04_card_05', 'mod_04', 5, 'The Tilak: the third eye marked',
      r'The mark on the forehead at the Ajna chakra (the space between the eyebrows) is a reminder to see with inner vision. Different shapes indicate different traditions: the vertical lines of the Vaishnavas, the horizontal ash-marks of the Shaivites, the dot of many practitioners. All point to the same teaching: you have a faculty of perception deeper than your physical eyes — cultivate it.'),
  _cardRow('mod_04_card_06', 'mod_04', 6, 'The Trishul: beyond all three',
      r"Shiva's trident. The three prongs represent the three Gunas: Tamas (inertia), Rajas (activity), Sattva (clarity). Shiva holds the trishul because he transcends all three. Liberation is not achieving the highest Guna — it is transcending the entire system of Gunas. The weapon represents mastery over all states of nature."),
  // Module 5
  _cardRow('mod_05_card_01', 'mod_05', 1, 'The architecture of a festival',
      r'Every major Hindu festival has three layers: the story (what happened), the ritual (what to do), and the teaching (why it matters eternally). Most people engage with the first two. This module is about the third — because once you know the teaching, the festival stops being an annual obligation and becomes an annual reminder of something you actually need to hear.'),
  _cardRow('mod_05_card_02', 'mod_05', 2, 'Diwali: the victory of knowledge',
      r'The common understanding: Rama returned to Ayodhya and people lit diyas to welcome him. The deeper teaching: every diya lit on Diwali represents the light of knowledge (Jnana) dispelling the darkness of ignorance (Avidya). The festival asks: where is there still darkness in your inner life that needs a diya lit?'),
  _cardRow('mod_05_card_03', 'mod_05', 3, 'Navratri: a map of spiritual progress',
      r'Nine nights, three phases. Day 1-3: Durga is worshipped — she destroys ego and negative patterns (through Tamas). Day 4-6: Lakshmi is worshipped — she cultivates noble qualities (through Rajas). Day 7-9: Saraswati is worshipped — she grants knowledge and wisdom (arriving at Sattva). The festival is a three-step map of inner transformation, repeated annually as a reminder of the work.'),
  _cardRow('mod_05_card_04', 'mod_05', 4, 'Holi: devotion that cannot be burned',
      r'Prahlada, a boy devoted to Vishnu, survived every attempt by his father to kill him — including sitting in fire with his aunt Holika, who was supposedly immune to flames. Holika burned. Prahlada was unharmed. The teaching: pure devotion (Bhakti) is the one thing in the universe that no force can destroy. The bonfire of Holi commemorates this annually.'),
  _cardRow('mod_05_card_05', 'mod_05', 5, 'Janmashtami: consciousness born at midnight',
      r'Krishna is born at midnight, in a prison, during a storm, to parents in chains. The teaching: divine consciousness is not born when conditions are perfect. It is born precisely in the darkest, most confined, most turbulent moment. Which means it can be born anywhere. Including now.'),
  _cardRow('mod_05_card_06', 'mod_05', 6, 'Dussehra: the ten heads of the inner Ravana',
      r"Ravana's ten heads represent ten internal enemies: Kama (lust), Krodha (anger), Lobha (greed), Moha (attachment), Mada (arrogance), Matsarya (jealousy), Manas (instinctive mind), Buddhi (corrupted intellect), Chitta (scattered consciousness), Ahamkara (ego). Rama's victory is the external story. The teaching is internal: every Dussehra is an invitation to identify which of your ten heads is currently in charge."),
  // Module 6
  _cardRow('mod_06_card_01', 'mod_06', 1, 'The principle behind all practice',
      r'Every daily practice in Sanatan Dharma is designed to move consciousness from Tamas (inertia, darkness) through Rajas (activity, heat) to Sattva (clarity, balance). The Gunas are not fixed — they shift with your environment, your sleep, your food, and crucially, with your first conscious acts of the day. Dinacharya is the science of choosing those first acts deliberately.'),
  _cardRow('mod_06_card_02', 'mod_06', 2, 'Brahma Muhurta: the sacred hour',
      "The period roughly 90 minutes before sunrise is called Brahma Muhurta — the hour of Brahman. The mind has not yet been filled with the day's concerns. External stimulation is at its lowest. The ancient prescription: wake in this window for meditation, mantra, or study. Modern sleep research confirms: cortisol is naturally lowest pre-dawn and the brain cycles through alpha-theta states ideal for deep learning."),
  _cardRow('mod_06_card_03', 'mod_06', 3, 'Sandhya Vandanam: prayers at the junctions',
      r'Sandhya means "junction" — the moments when day meets night. The tradition prescribes prayer at three Sandhyas: dawn, noon, and dusk. The Gayatri Mantra — "May the divine light of the Sun illuminate our intellect" — is the heart of Sandhya Vandanam. This is not sun worship. The sun is the most visible symbol of consciousness in the natural world. The prayer asks for that quality of illumination within.'),
  _cardRow('mod_06_card_04', 'mod_06', 4, 'Home Puja: intention before action',
      "The home altar is not a transaction point. The flame of the diya represents your own consciousness. The incense represents the dissipation of mental impurities. The flowers represent the best of what you have to offer. The act of performing puja before beginning the day's work trains the mind: begin each day with intention, not with reaction."),
  _cardRow('mod_06_card_05', 'mod_06', 5, 'Pranayama: the breath controls the mind',
      r'Prana is the life force that moves through the breath. The insight arrived at 3,000 years before neuroscience: the breath and the mind are directly linked. A disturbed breath disturbs the mind. A regulated breath regulates the mind. Nadi Shodhana (alternate nostril breathing) balances the two hemispheres of the brain. The Hatha Yoga Pradipika states: "When the breath wanders, the mind is unsteady. When the breath is still, the mind is still."'),
  _cardRow('mod_06_card_06', 'mod_06', 6, 'The evening: completing the circuit',
      "Daily practice is not only a morning discipline. The evening Sandhya closes the day's circuit. Lighting the diya at dusk marks the transition from the outward-facing day to the inward-facing night. The practice of reviewing the day's actions — what was done in alignment with Dharma, what was not — is the original form of what modern psychology calls reflective journaling. The day does not just end. It is consciously completed."),
  // Module 7
  _cardRow('mod_07_card_01', 'mod_07', 1, 'The problem this solves',
      r'What is the right way to live? Most traditions give a single universal answer. Sanatan Dharma says: the right answer changes depending on where you are in life. What constitutes right living at 22 is not what constitutes right living at 55. The Ashrama system is the most sophisticated life-stage philosophy ever formulated — it maps a complete human arc from birth to liberation.'),
  _cardRow('mod_07_card_02', 'mod_07', 2, 'Brahmacharya (0–25): the student stage',
      "Brahmacharya literally means \"walking with Brahman.\" This is the phase of formation — not only academic learning but the cultivation of character, discipline, and self-knowledge. The tradition's emphasis: the habits, values, and understanding developed in this stage form the foundation for everything that follows. What you plant in Brahmacharya, you harvest for the rest of your life."),
  _cardRow('mod_07_card_03', 'mod_07', 3, 'Grihastha (25–50): the householder stage',
      r'The householder stage — marriage, family, earning, and full participation in society — is considered by most Hindu thinkers to be the most important Ashrama. Because it is the only stage that sustains all the others. The Grihastha feeds the student, the forest-dweller, and the renunciant. Vivekananda wrote: "The householder who does his duty is equal to any yogi."'),
  _cardRow('mod_07_card_04', 'mod_07', 4, 'Vanaprastha (50–75): mentorship stage',
      r'Vanaprastha means "going towards the forest" — not physically but mentally. This is the stage of gradual withdrawal from daily responsibilities and the transition from active participation to active guidance. The Grihastha stops being the one who runs things and becomes the one who helps others learn to run things. The great wealth of this stage is perspective — the view from here has been earned.'),
  _cardRow('mod_07_card_05', 'mod_07', 5, 'Sannyasa (75+): complete renunciation',
      r"In the Sannyasa stage, all remaining identity — family role, community standing, even one's personal name — is released. The Sannyasi has one goal: Moksha. This stage is not about abandoning life. It is about recognising that you were never truly the role you were playing. The actor does not lose himself when the play ends — he returns to himself. Sannyasa is that return."),
  _cardRow('mod_07_card_06', 'mod_07', 6, 'The radical teaching',
      r'The Ashrama system validates all phases of life. The desire for knowledge in youth is dharmic. The desire for worldly success and love in the householder stage is dharmic. The desire for a peaceful retirement is dharmic. The desire for liberation in old age is dharmic. The tradition does not ask you to renounce the world at 25. It gives you permission to live fully — and a map for when and how to let go.'),
  // Module 8
  _cardRow('mod_08_card_01', 'mod_08', 1, 'The four goals',
      r'Purusha = the human being. Artha = goal/purpose. The Purusharthas are the four legitimate goals of a human life: Dharma (ethical living), Artha (prosperity and achievement), Kama (love, pleasure, and beauty), and Moksha (liberation). All four are real. All four matter. The tradition does not rank them in order of holiness — it integrates them into one complete life.'),
  _cardRow('mod_08_card_02', 'mod_08', 2, 'Dharma: the first and last principle',
      r'Dharma is the framework within which all other pursuits become valid. Without Dharma, Artha becomes exploitation, Kama becomes addiction, and Moksha becomes spiritual bypassing. With Dharma, all three are transformed. Dharma is not a list of rules — it is alignment between your actions and your deepest nature. When you act from your true nature, the action itself has the quality of Dharma.'),
  _cardRow('mod_08_card_03', 'mod_08', 3, 'Artha: the honour of prosperity',
      "Sanatan Dharma has never been anti-wealth. Lakshmi, the goddess of prosperity, is among the most beloved in the tradition. Kautilya's Arthashastra — one of the world's oldest treatises on economics — was written in India in the 4th century BCE. The condition is not poverty — it is that wealth be earned through Dharma and used in service of Dharma."),
  _cardRow('mod_08_card_04', 'mod_08', 4, 'Kama: the honour of desire',
      r'The Kama Sutra is the most misunderstood text associated with any tradition — it is not a sex manual but a treatise on all the arts of refined living. Desire, pleasure, love, beauty, and the arts are honoured dimensions of a complete human life. The condition: Kama pursued in alignment with Dharma is sacred. Kama pursued in violation of Dharma generates bondage.'),
  _cardRow('mod_08_card_05', 'mod_08', 5, 'Moksha: liberation as the horizon',
      "Moksha is not the enemy of the first three Purusharthas — it is their culmination. The tradition does not ask you to abandon prosperity and love in pursuit of liberation. It asks you to live them fully, discover their limits, and allow that discovery to point you naturally toward what is limitless. The Gita's teaching is not \"abandon the world.\" It is \"act fully in the world, without clinging to the results.\""),
  _cardRow('mod_08_card_06', 'mod_08', 6, 'The integration',
      r'The genius of the Purusharthas is that they do not ask you to choose. A householder pursuing righteous prosperity is living Dharma. A devotee in deep Bhakti is experiencing Kama of the highest kind. A Karma Yogi acting without attachment is already practicing Moksha in motion. The four are not four separate goals to be pursued sequentially — they are four dimensions of one complete human life, interpenetrating and mutually supporting.'),
];

// ── Extras (anchor verse + reflection) ───────────────────────────────────────

const _extras = [
  {
    'module_id': 'mod_01',
    'anchor_verse_id': 'BG.4.7',
    'anchor_verse_note':
        'Whenever Dharma declines and Adharma rises, I manifest myself. This verse captures the self-renewing nature of Sanatan Dharma — truth reasserts itself in every age.',
    'reflection_question':
        'What does it mean to you that this tradition has no single founder to follow and no single book to obey — only an endless search for truth?',
  },
  {
    'module_id': 'mod_02',
    'anchor_verse_id': 'BG.2.20',
    'anchor_verse_note':
        'The soul is never born nor dies at any time. It has not come into being, does not come into being, and will not come into being. It is unborn, eternal, ever-existing, and primeval.',
    'reflection_question':
        'Of these five concepts, which one feels most true to your own direct experience right now — not as a belief, but as something you have actually noticed?',
  },
  {
    'module_id': 'mod_03',
    'anchor_verse_id': 'BG.4.11',
    'anchor_verse_note':
        'As people surrender to me, I reward them accordingly. Everyone follows my path in all respects. This verse reveals the pluralism at the heart of devotion — every approach to the divine is received according to the sincerity behind it.',
    'reflection_question':
        'Which aspect of the divine — creator, preserver, or transformer — feels most present in your life right now? And which one do you find hardest to trust?',
  },
  {
    'module_id': 'mod_04',
    'anchor_verse_id': 'BG.10.41',
    'anchor_verse_note':
        'Know that all beautiful, glorious, and mighty creations spring from but a spark of my splendour. Wherever you encounter beauty, power, or excellence — you are encountering the divine.',
    'reflection_question':
        'Which symbol have you encountered your whole life without knowing its meaning? How does knowing it now change how you see it?',
  },
  {
    'module_id': 'mod_05',
    'anchor_verse_id': 'BG.9.26',
    'anchor_verse_note':
        'Whoever offers me with devotion a leaf, a flower, a fruit, or water — that offering of devotion from the pure-hearted I accept. The festivals teach that devotion expressed through action, even small action, is received.',
    'reflection_question':
        'Which festival did you celebrate as a child without knowing its deeper teaching? Does knowing it now change how you will experience it next time?',
  },
  {
    'module_id': 'mod_06',
    'anchor_verse_id': 'BG.6.17',
    'anchor_verse_note':
        'For one who is regulated in eating, sleeping, recreation, and work — for such a person, yoga destroys all sorrow. The Gita asks for regulation, not asceticism. The practice works when it is consistent, not when it is extreme.',
    'reflection_question':
        'What is the very first thing you do each morning — before looking at your phone, before speaking to anyone? What does that first act say about what you believe matters most?',
  },
  {
    'module_id': 'mod_07',
    'anchor_verse_id': 'BG.3.35',
    'anchor_verse_note':
        "Better is one's own dharma, though imperfectly performed, than the dharma of another perfectly performed. The dharma appropriate to your stage of life is better than the dharma of another stage, even if theirs appears more spiritually elevated.",
    'reflection_question':
        'Which Ashrama are you in right now? Are you living in alignment with what that stage actually requires — or are you trying to skip ahead or holding back from what this stage demands?',
  },
  {
    'module_id': 'mod_08',
    'anchor_verse_id': 'BG.2.47',
    'anchor_verse_note':
        'You have a right to perform your prescribed duties, but you are not entitled to the fruits of your actions. This is the Karma Yoga teaching that integrates all four Purusharthas: act fully, act for rightful ends, and release attachment to outcomes.',
    'reflection_question':
        'Of the four Purusharthas, which do you feel most free to pursue? Which do you feel most guilty about — and where did that guilt come from?',
  },
];
