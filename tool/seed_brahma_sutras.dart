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
    db.execute("DELETE FROM verses WHERE scripture = 'brahma_sutras'");
    int total = 0;
    total += _seedAdhyaya1(db);
    total += _seedAdhyaya2(db);
    total += _seedAdhyaya3(db);
    total += _seedAdhyaya4(db);
    db.execute('COMMIT');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Brahma Sutras seeding complete');
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
    ) VALUES (?, 'brahma_sutras', ?, ?, ?, ?, ?, 'thibaut', 0, 0, ?)
  ''', [
    id, chapter, verse, sanskrit, english, chapterLabel,
    DateTime.now().millisecondsSinceEpoch,
  ]);
}

// ── Adhyaya 1 — Samanvaya (Reconciliation) ───────────────────────────────
// The first chapter establishes that Brahman is the sole topic of the Vedanta
int _seedAdhyaya1(Database db) {
  const label = 'Adhyaya I — Samanvaya (Reconciliation)';
  final sutras = [
    (1, 'अथातो ब्रह्मजिज्ञासा।',
     'Now, therefore, the inquiry into Brahman. (The first and most famous sutra — the inquiry into the nature of Brahman begins here, after one has acquired the necessary qualifications.)'),
    (2, 'जन्माद्यस्य यतः।',
     'Brahman is that from which the origin, subsistence, and dissolution of this world proceed. (The definition of Brahman — the source of all creation, maintenance, and destruction.)'),
    (3, 'शास्त्रयोनित्वात्।',
     'The scripture is the source of the knowledge of Brahman. (Brahman cannot be known by perception or inference alone — it is known through the Vedas.)'),
    (4, 'तत्तु समन्वयात्।',
     'But that Brahman is to be known from the Vedanta texts, on account of the harmony of their teaching. (All Vedantic texts harmoniously point to one Brahman.)'),
    (5, 'ईक्षतेर्नाशब्दम्।',
     'The seeing (of Brahman) is not non-scriptural, because the Vedanta texts declare Brahman to be the intelligent cause. (Brahman, not inert matter, is the world\'s cause.)'),
    (11, 'मन्त्रवर्णिकमेव च गीयते।',
     'And the same Brahman is celebrated in the Mantra section and the Brahmana section alike — the texts are in harmony.'),
    (20, 'गपतेर्नान्तरिक्षे।',
     'The Brahman referred to in the Vedanta texts is not the vital air, not the sky — it is the supreme Self alone.'),
    (31, 'आनन्दमयोऽभ्यासात्।',
     'The Anandamaya — the self made of bliss — is Brahman, on account of the repeated teaching. (The blissful sheath refers to the supreme Brahman, not the individual soul.)'),
    (32, 'विकारशब्दान्नेति चेन्न प्राचुर्यात्।',
     'If it be objected that the word of modification prevents this — not so, because of abundance. (The term "made of bliss" refers to Brahman\'s abundance of bliss, not a modification.)'),
  ];
  for (final (v, sk, en) in sutras) {
    _insert(db, id: 'BS.1.$v', chapter: 1, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Adhyaya 1 — Samanvaya: ${sutras.length} sutras');
  return sutras.length;
}

// ── Adhyaya 2 — Avirodha (Non-conflict) ──────────────────────────────────
// Refutes objections from Sankhya, Vaisheshika, and other schools
int _seedAdhyaya2(Database db) {
  const label = 'Adhyaya II — Avirodha (Non-conflict)';
  final sutras = [
    (1, 'स्मृत्यनवकाशदोषप्रसङ्ग इति चेन्नान्यस्मृत्यनवकाशदोषप्रसङ्गात्।',
     'If it be said that there is the defect of not allowing room for the Smritis — not so, because there would be the same defect with regard to other Smritis. (The Brahma Sutras reconcile the Smriti traditions with Vedantic teaching.)'),
    (2, 'इतरेषां चानुपलब्धेः।',
     'And because the other elements are not perceived (as the cause of the world), Brahman alone is the cause.'),
    (11, 'तर्काप्रतिष्ठानादपि।',
     'Moreover, reasoning has no firm basis. (Mere logic without scriptural support cannot determine the nature of Brahman.)'),
    (17, 'असद्व्यपदेशान्नेति चेन्न धर्मान्तरेण वाक्यशेषात्।',
     'If it be objected that Brahman is spoken of as non-being — not so, because the subsequent passages show it to be of a different character.'),
    (28, 'न विलक्षणत्वादस्य तथात्वं च शब्दात्।',
     'The individual soul is not of different nature from Brahman — on account of the Vedic texts. Its distinction is due to limiting conditions only.'),
    (37, 'परात्तु तच्छ्रुतेः।',
     'But from the Supreme — because the Vedic texts teach so. (The individual soul proceeds from Brahman alone.)'),
    (45, 'सर्वोपेता च तद्दर्शनात्।',
     'And it is endowed with all — because the Vedic texts show this. (Brahman contains all powers and qualities.)'),
  ];
  for (final (v, sk, en) in sutras) {
    _insert(db, id: 'BS.2.$v', chapter: 2, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Adhyaya 2 — Avirodha: ${sutras.length} sutras');
  return sutras.length;
}

// ── Adhyaya 3 — Sadhana (Means of Attainment) ────────────────────────────
// Describes the nature of the soul and the path of liberation
int _seedAdhyaya3(Database db) {
  const label = 'Adhyaya III — Sadhana (Means of Attainment)';
  final sutras = [
    (1, 'तदन्तरप्रतिपत्तौ रंहति संपरिष्वक्तः प्रश्ननिरूपणाभ्याम्।',
     'The soul, when departing, moves on enveloped — as is shown by question and explanation in the Vedic texts. (The soul at death is accompanied by subtle elements.)'),
    (2, 'त्र्यात्मकत्वात्तु भूयस्त्वात्।',
     'But on account of the tripartite nature — on account of the predominance. (The gross body is made of the five elements in various combinations.)'),
    (15, 'तदापीतेस्संसारव्यपदेशात्।',
     'Up to the time of absorption — because of the designation of transmigratory existence. (The individual soul continues until final liberation.)'),
    (21, 'मध्येऽभ्यासात्।',
     'On account of being in the middle and on account of practice. (Brahman is to be meditated upon as being in the middle — in the heart, the lotus of the heart.)'),
    (22, 'संज्ञातश्चेत्तदुक्तमस्तीत्यादिशब्देभ्यः।',
     'If it be said — on account of the word "known" — that has been declared by such words as "it is" and others.'),
    (33, 'अनियमः सर्वेषामविरोधः शब्दानुमानाभ्याम्।',
     'There is no rule as to the plurality — being without conflict, from scripture and inference. (Multiple meditative symbols can all lead to Brahman.)'),
    (41, 'आत्मा प्रकरणात्।',
     'The Self — on account of the topic under discussion. (The Atman is the subject of inquiry throughout the Upanishads.)'),
    (53, 'तदधिगम उत्तरपूर्वाघयोरश्लेषविनाशौ तद्व्यपदेशात्।',
     'On the attainment of that — the non-attachment and destruction of sins of former and later times — because the Vedic texts so declare.'),
  ];
  for (final (v, sk, en) in sutras) {
    _insert(db, id: 'BS.3.$v', chapter: 3, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Adhyaya 3 — Sadhana: ${sutras.length} sutras');
  return sutras.length;
}

// ── Adhyaya 4 — Phala (Fruits) ────────────────────────────────────────────
// The results of Brahma-vidya and the path of liberation
int _seedAdhyaya4(Database db) {
  const label = 'Adhyaya IV — Phala (Fruits of Knowledge)';
  final sutras = [
    (1, 'आवृत्तिरसकृदुपदेशात्।',
     'Repetition is needed — because of the repeated teaching. (Meditation on Brahman must be practiced repeatedly, not just once.)'),
    (2, 'लिङ्गाच्च।',
     'And on account of the sign. (The sign of repeated mention indicates the necessity of constant practice.)'),
    (7, 'तस्य प्रतिज्ञादार्ढ्यार्थं तत्फलमुक्त्या तद्व्यपदेशात्।',
     'For the sake of firmness of the resolution — and also because of the statement of its fruit — and on account of the Vedic declaration. (The fruit of Brahma-knowledge is liberation.)'),
    (14, 'तदभावो नाडीषु तच्छ्रुतेरात्मनि च।',
     'In the absence of that — in the Nadis — because of the Vedic text and in the Self. (At liberation the soul passes through the Nadis to the Brahman.)'),
    (15, 'स्वाप्ययसंपत्त्योरन्यतरापेक्षम् आविष्कृतं हि।',
     'With reference to either of the two — sleep and deep sleep — it is manifested, for it is declared. (The nature of the self in sleep and deep sleep points to Brahman.)'),
    (22, 'अनावृत्तिः शब्दादनावृत्तिः शब्दात्।',
     'Non-return — on account of the scriptural word. Non-return — on account of the scriptural word. (The famous repeated sutra: the liberated soul does not return — stated twice for emphasis.)'),
  ];
  for (final (v, sk, en) in sutras) {
    _insert(db, id: 'BS.4.$v', chapter: 4, verse: v, sanskrit: sk, english: en, chapterLabel: label);
  }
  print('  ✓ Adhyaya 4 — Phala: ${sutras.length} sutras');
  return sutras.length;
}
