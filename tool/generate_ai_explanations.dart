// Batch-generate AI explanations for Bhagavad Gita verses via Gemini REST API,
// writing into `verse_explanations` (same schema as app Drift v8).
//
// Prerequisites:
//   - `GEMINI_API_KEY` in the environment (Google AI Studio key).
//   - Network access.
//
// Usage:
//   GEMINI_API_KEY=... dart run tool/generate_ai_explanations.dart
//   GEMINI_API_KEY=... dart run tool/generate_ai_explanations.dart --db assets/db/sanatan_guide.db --limit 3
//
// After generation, ship the updated DB under `assets/db/` or merge rows into your bundle.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sqlite3/sqlite3.dart';

const _model = 'gemini-2.5-flash';
const _minDelay = Duration(seconds: 4);

Future<void> main(List<String> args) async {
  final key = Platform.environment['GEMINI_API_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('Set GEMINI_API_KEY (Google AI Studio).');
    exit(1);
  }

  var dbPath = p.join('assets', 'db', 'sanatan_guide.db');
  var limit = 0;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--db' && i + 1 < args.length) {
      dbPath = args[++i];
    } else if (args[i] == '--limit' && i + 1 < args.length) {
      limit = int.tryParse(args[++i]) ?? 0;
    }
  }

  if (!File(dbPath).existsSync()) {
    stderr.writeln('DB not found: $dbPath');
    exit(1);
  }

  final db = sqlite3.open(dbPath);
  try {
    db.execute('''
      CREATE TABLE IF NOT EXISTS verse_explanations (
        verse_id TEXT NOT NULL PRIMARY KEY,
        explanation_text TEXT NOT NULL,
        generated_at INTEGER NOT NULL,
        model_version TEXT NOT NULL
      )
    ''');

    final ids = <String>[];
    for (final ch in BhagavadGitaChapters.all) {
      for (var v = 1; v <= ch.verseCount; v++) {
        ids.add('BG.${ch.number}.$v');
      }
    }

    var done = 0;
    var skipped = 0;
    for (final id in ids) {
      if (limit > 0 && done >= limit) {
        break;
      }

      final exists = db.select(
        'SELECT 1 FROM verse_explanations WHERE verse_id = ?',
        [id],
      );
      if (exists.isNotEmpty) {
        skipped++;
        continue;
      }

      final verseRow = db.select(
        'SELECT sanskrit, english FROM verses WHERE id = ?',
        [id],
      );
      if (verseRow.isEmpty) {
        stderr.writeln('⚠️  Missing verse row: $id');
        continue;
      }

      final sanskrit = verseRow.first['sanskrit'] as String? ?? '';
      final english = verseRow.first['english'] as String? ?? '';
      final parts = id.split('.');
      final ch = int.parse(parts[1]);
      final vn = int.parse(parts[2]);

      final prompt = '''
Explain Bhagavad Gita Chapter $ch Verse $vn in simple English for a general reader.
Include: brief context, key Sanskrit terms in italics where helpful, practical relevance today.
Keep under 200 words. Do not prepend "Chapter" labels; start directly with the explanation.

Verse text (Sanskrit):
$sanskrit

Translation (English):
$english
''';

      stdout.writeln('→ $id …');
      final text = await _callGemini(key, prompt);
      final now = DateTime.now().millisecondsSinceEpoch;
      db.execute(
        '''INSERT OR REPLACE INTO verse_explanations
           (verse_id, explanation_text, generated_at, model_version)
           VALUES (?, ?, ?, ?)''',
        [id, text, now, _model],
      );
      done++;
      await Future<void>.delayed(_minDelay);
    }

    stdout.writeln('Done. Generated: $done, skipped (already had row): $skipped');
  } finally {
    db.dispose();
  }
}

Future<String> _callGemini(String apiKey, String prompt) async {
  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '$_model:generateContent?key=${Uri.encodeQueryComponent(apiKey)}',
  );
  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': prompt},
        ],
      },
    ],
  });
  final client = HttpClient();
  try {
    final req = await client.postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(body);
    final res = await req.close();
    final responseBody = await utf8.decoder.bind(res).join();
    if (res.statusCode != 200) {
      throw HttpException(
        'Gemini ${res.statusCode}: $responseBody',
        uri: uri,
      );
    }
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<Object?>?;
    if (candidates == null || candidates.isEmpty) {
      throw StateError('No candidates in response');
    }
    final firstCand = candidates.first as Map<String, Object?>?;
    final content = firstCand?['content'] as Map<String, Object?>?;
    final parts = content?['parts'] as List<Object?>?;
    if (parts == null || parts.isEmpty) {
      throw StateError('No content parts');
    }
    final firstPart = parts.first as Map<String, Object?>?;
    final text = firstPart?['text'];
    if (text is! String || text.isEmpty) {
      throw StateError('Empty explanation text');
    }
    return text.trim();
  } finally {
    client.close(force: true);
  }
}
