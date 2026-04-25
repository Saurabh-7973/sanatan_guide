// Seed Shankara's Gītābhāṣya into the `commentaries` table (schema v9).
//
// This tool is deliberately restrictive: it will only insert rows whose
// (source_url, license) pair matches the hardcoded PD allowlist below.
// Any row that fails the allowlist check is rejected and logged, never
// written. This is the last line of defence against accidentally shipping
// copyrighted translations.
//
// Usage:
//   dart run tool/seed_shankara_commentary.dart \
//       --db assets/db/sanatan_guide.db \
//       --input tool/sources/shankara_gita.json
//
// Input JSON shape (array of objects):
//   [
//     {
//       "id":            "shankara_gita_2.47",
//       "verse_id":      "BG.2.47",
//       "tradition":     "advaita",
//       "author":        "Adi Shankaracharya",
//       "text_sanskrit": "...",        // optional
//       "text_english":  "...",        // optional; must come from a PD translator
//       "translator":    "A. Mahadeva Sastri",  // optional (null when Sanskrit-only)
//       "source_url":    "https://archive.org/details/bhagavadgitawith00shan",
//       "license":       "public_domain"
//     }
//   ]

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Hostnames that are confirmed acceptable for PD/permissively-licensed
/// scripture commentary. Anything outside this list is rejected.
///
/// Rationale:
/// - **gretil.sub.uni-goettingen.de** — academic TEI/XML archive of
///   Sanskrit originals; Shankara d. c.820 CE, text is PD globally.
/// - **archive.org** — PD only when the uploaded scan is demonstrably
///   pre-1930 (US) AND translator died >60 years ago (India). Operator
///   is responsible for pointing at a qualifying scan (Mahadeva Sastri
///   1897 qualifies; Gambhirananda 1984 does NOT).
/// - **sacred-texts.com** — John B. Hare's archive; its own Sacred Texts
///   Archive Open Access license permits reuse of transcriptions of PD works.
/// - **wikisource.org** — hosts only PD or CC-licensed texts by policy.
const _allowedSourceHosts = {
  'gretil.sub.uni-goettingen.de',
  'archive.org',
  'www.sacred-texts.com',
  'sacred-texts.com',
  'en.wikisource.org',
  'sa.wikisource.org',
};

/// License strings we will accept. `public_domain` is the only guaranteed
/// safe one; the CC variants are accepted because they compose with
/// attribution already carried in [sourceUrl]/[translator].
const _allowedLicenses = {
  'public_domain',
  'cc_by',
  'cc_by_sa',
};

const _allowedTraditions = {
  'advaita',
  'vishishtadvaita',
  'dvaita',
  'other',
};

class Rejection {
  Rejection(this.id, this.reason);
  final String id;
  final String reason;
}

Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);
  if (opts == null) exit(64);

  final dbFile = File(opts.dbPath);
  if (!dbFile.existsSync()) {
    stderr.writeln('DB not found: ${opts.dbPath}');
    exit(1);
  }
  final inputFile = File(opts.inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input not found: ${opts.inputPath}');
    exit(1);
  }

  final raw = await inputFile.readAsString();
  final decoded = jsonDecode(raw);
  if (decoded is! List) {
    stderr.writeln('Input JSON must be an array of commentary objects.');
    exit(1);
  }

  final db = sqlite3.open(opts.dbPath);
  final result = runSeed(
    db: db,
    entries: decoded.cast<Map<String, dynamic>>(),
    dryRun: opts.dryRun,
  );
  db.dispose();

  stdout.writeln('Inserted:     ${result.inserted}');
  stdout.writeln('Skipped (existing id): ${result.skipped}');
  stdout.writeln('Rejected:     ${result.rejected.length}');
  for (final r in result.rejected) {
    stderr.writeln('  x ${r.id}: ${r.reason}');
  }
  if (result.rejected.isNotEmpty) exit(2);
}

/// Pure, testable seed function. Creates the `commentaries` table if the
/// DB predates schema v9 (safe no-op on upgraded DBs).
///
/// Returns (inserted, skippedAlreadyPresent, rejectedRows).
({int inserted, int skipped, List<Rejection> rejected}) runSeed({
  required Database db,
  required List<Map<String, dynamic>> entries,
  bool dryRun = false,
}) {
  db.execute('''
    CREATE TABLE IF NOT EXISTS commentaries (
      id             TEXT NOT NULL PRIMARY KEY,
      verse_id       TEXT NOT NULL,
      tradition      TEXT NOT NULL,
      author         TEXT NOT NULL,
      text_english   TEXT,
      text_sanskrit  TEXT,
      translator     TEXT,
      source_url     TEXT NOT NULL,
      license        TEXT NOT NULL,
      created_at     INTEGER NOT NULL
    )
  ''');
  db.execute(
    'CREATE INDEX IF NOT EXISTS idx_commentaries_verse_id '
    'ON commentaries (verse_id)',
  );

  final rejected = <Rejection>[];
  var insertedCount = 0;
  var skippedCount = 0;

  for (final e in entries) {
    final id = e['id']?.toString() ?? '';
    final reason = _validate(e);
    if (reason != null) {
      rejected.add(Rejection(id.isEmpty ? '<no-id>' : id, reason));
      continue;
    }

    final exists = db.select(
      'SELECT 1 FROM commentaries WHERE id = ?',
      [id],
    );
    if (exists.isNotEmpty) {
      skippedCount++;
      continue;
    }

    if (!dryRun) {
      db.execute(
        '''INSERT INTO commentaries
           (id, verse_id, tradition, author, text_english, text_sanskrit,
            translator, source_url, license, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          id,
          e['verse_id'],
          e['tradition'],
          e['author'],
          e['text_english'],
          e['text_sanskrit'],
          e['translator'],
          e['source_url'],
          e['license'],
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
    }
    insertedCount++;
  }

  return (
    inserted: insertedCount,
    skipped: skippedCount,
    rejected: rejected,
  );
}

/// Returns null if the entry is acceptable, else a short reason string.
/// Exposed for testing; do not call from outside the tool.
String? _validate(Map<String, dynamic> e) {
  for (final k in const ['id', 'verse_id', 'tradition', 'author',
    'source_url', 'license']) {
    final v = e[k];
    if (v is! String || v.isEmpty) {
      return 'missing required field "$k"';
    }
  }
  if (!_allowedTraditions.contains(e['tradition'])) {
    return 'tradition "${e['tradition']}" is not in the allowlist';
  }
  if (!_allowedLicenses.contains(e['license'])) {
    return 'license "${e['license']}" is not PD/CC-permitted';
  }
  final uri = Uri.tryParse(e['source_url'] as String);
  if (uri == null || !_allowedSourceHosts.contains(uri.host)) {
    return 'source_url host "${uri?.host}" not on PD allowlist';
  }
  final sa = e['text_sanskrit'];
  final en = e['text_english'];
  if ((sa is! String || sa.isEmpty) && (en is! String || en.isEmpty)) {
    return 'both text_sanskrit and text_english are empty';
  }
  return null;
}

class _Opts {
  _Opts({
    required this.dbPath,
    required this.inputPath,
    required this.dryRun,
  });
  final String dbPath;
  final String inputPath;
  final bool dryRun;
}

_Opts? _parseArgs(List<String> args) {
  var dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  String? inputPath;
  var dryRun = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--db':
        if (i + 1 < args.length) dbPath = args[++i];
      case '--input':
        if (i + 1 < args.length) inputPath = args[++i];
      case '--dry-run':
        dryRun = true;
      case '-h' || '--help':
        _printUsage();
        return null;
    }
  }
  if (inputPath == null) {
    _printUsage();
    return null;
  }
  return _Opts(dbPath: dbPath, inputPath: inputPath, dryRun: dryRun);
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tool/seed_shankara_commentary.dart '
    '--input <path.json> [--db <path.db>] [--dry-run]',
  );
}
