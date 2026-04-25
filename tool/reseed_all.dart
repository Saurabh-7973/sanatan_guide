// ═══════════════════════════════════════════════════════════════════════════
// SANATAN GUIDE — MASTER RESEED SCRIPT
// Run from project root: dart run tool/reseed_all.dart
//
// ── PREREQUISITES (one-time setup after each machine/reboot) ────────────────
//
//   # 1. DharmicData — Sanskrit for Rigveda, Yajurveda, Atharvaveda
//   cd /tmp && git clone https://github.com/bhavykhatri/DharmicData.git
//
//   # 2. Rigveda English — Griffith 1896 PDF
//   curl -L http://www.sanskritweb.net/rigveda/griffith.pdf -o /tmp/griffith_rigveda.pdf
//   pdftotext /tmp/griffith_rigveda.pdf /tmp/griffith_rigveda.txt
//
//   # 3. Atharvaveda English — Griffith 1895 plain text
//   curl -L "https://www.sacred-texts.com/hin/av/av.txt.gz" -o /tmp/av.txt.gz
//   gunzip -c /tmp/av.txt.gz > /tmp/av.txt
//
//   # 4. Python dependency
//   pip3 install beautifulsoup4
//
// ── SOURCE FILES COMMITTED IN REPO ──────────────────────────────────────────
//
//   tool/sources/samaveda.html          <- Griffith 1895 (sacred-texts.com)
//   tool/sources/wyv/                   <- 40 book files (sacred-texts.com)
//   tool/parse_samaveda_html.py         <- parser
//   tool/parse_yajurveda_html.py        <- parser
//   tool/parse_atharvaveda_txt.py       <- parser
//
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:io';

Future<void> main() async {
  final tools = <String>[
    'tool/fix_db_version.dart',
    'tool/seed_modules.dart',
    'tool/seed_level2_modules.dart',
    'tool/seed_upanishads.dart',
    'tool/seed_yoga_sutras.dart',
    'tool/seed_hatha_yoga.dart',
    'tool/seed_vishnu_sahasranama.dart',
    'tool/seed_manusmriti.dart',
    'tool/seed_mahanirvana.dart',
    'tool/seed_brahma_sutras.dart',
    'tool/seed_prashna_upanishad.dart',
    'tool/seed_taittiriya_upanishad.dart',
    'tool/seed_aitareya_upanishad.dart',
    'tool/seed_shvetashvatara_upanishad.dart',
    'tool/seed_kaushitaki_upanishad.dart',
    'tool/seed_maitrayani_upanishad.dart',
    'tool/seed_vishnu_purana.dart',
    'tool/seed_devi_bhagavata.dart',
    'tool/seed_markandeya_purana.dart',
    'tool/fix_db_version.dart',
  ];

  for (final tool in tools) {
    stdout.writeln('\n▶ Running $tool...');
    final result = await Process.run('dart', ['run', tool]);
    stdout.write(result.stdout);
    if (result.exitCode != 0) {
      stderr.write(result.stderr);
      stdout.writeln('❌ Failed: $tool');
      exit(1);
    }
  }

  stdout.writeln('\n✅ Core seeders complete.');
  stdout.writeln('');
  stdout.writeln('Next — Veda content (requires /tmp setup above):');
  stdout.writeln('  dart run tool/parse_rigveda.dart');
  stdout.writeln('  dart run tool/parse_yajurveda.dart');
  stdout.writeln('  python3 tool/parse_yajurveda_html.py tool/sources/wyv/');
  stdout.writeln('  dart run tool/parse_atharvaveda.dart');
  stdout.writeln('  python3 tool/parse_atharvaveda_txt.py /tmp/av.txt');
  stdout.writeln('  python3 tool/parse_samaveda_html.py tool/sources/samaveda.html');
}
