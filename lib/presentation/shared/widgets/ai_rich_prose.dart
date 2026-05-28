// lib/presentation/shared/widgets/ai_rich_prose.dart
//
// Shared rich-text renderer for Gemini reply prose. Parses two markup forms
// the system prompts ask the model to produce:
//   - `**word**` → bold saffron span (key Sanskrit terms)
//   - `(Scripture chap.verse)` → tappable citation chip that pushes
//     `/browse/<code>/verse/<id>`
// Anything that doesn't match falls through as plain prose.
//
// Used by:
//   - Ask the Pandit (general chat)
//   - Ask about this verse (verse-anchored chat)
//   - Explain this verse (verse-detail commentary card)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sanatan_guide/core/utils/coordinate_parser.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Render Gemini reply prose with **bold** key-term spans and tappable
/// citation chips. Paragraph splits on blank lines.
class AiRichProse extends StatelessWidget {
  const AiRichProse({
    super.key,
    required this.isDark,
    required this.text,
    this.italic = true,
    this.fontSize = 14.5,
    this.height = 1.75,
    this.horizontalPadding = 4,
    this.color,
  });

  final bool isDark;
  final String text;

  /// Italic prose (general chat) vs upright (verse-anchored / explain card).
  final bool italic;
  final double fontSize;
  final double height;
  final double horizontalPadding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronGlow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final base = TextStyle(
      fontFamily: Fonts.serif,
      fontFamilyFallback: AppFontFallback.latin,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontSize: fontSize,
      height: height,
      color: color ?? text1,
    );
    final boldKeyTerm = base.copyWith(
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: saffron,
    );
    final italicEmph = base.copyWith(fontStyle: FontStyle.italic);

    final paragraphs = text
        .trim()
        .split(RegExp(r'\n\s*\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < paragraphs.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: base,
                children: _buildSpans(
                  context: context,
                  paragraph: paragraphs[i].trim(),
                  base: base,
                  boldKeyTerm: boldKeyTerm,
                  italicEmph: italicEmph,
                  saffron: saffron,
                  saffronGlow: saffronGlow,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Split a paragraph into spans alternating between plain prose, **bold**
/// key terms, *italic* emphasis, and parenthesised citation chips.
List<InlineSpan> _buildSpans({
  required BuildContext context,
  required String paragraph,
  required TextStyle base,
  required TextStyle boldKeyTerm,
  required TextStyle italicEmph,
  required Color saffron,
  required Color saffronGlow,
}) {
  final tokens = <_Token>[];

  // **bold key term** — longest match first so it doesn't overlap *italic*.
  final boldRe = RegExp(r'\*\*([^*]+)\*\*');
  for (final m in boldRe.allMatches(paragraph)) {
    tokens.add(_Token.bold(m.start, m.end, m.group(1)!));
  }
  // *italic* — must not match the inside of **bold** (handled by overlap
  // drop later).
  final italicRe = RegExp(r'(?<!\*)\*([^*\n]+)\*(?!\*)');
  for (final m in italicRe.allMatches(paragraph)) {
    tokens.add(_Token.italicEmph(m.start, m.end, m.group(1)!));
  }
  // (Scripture chap.verse) citation.
  for (final m in citationRe.allMatches(paragraph)) {
    final inner = m.group(1)!.trim();
    final coord = parseScriptureCoordinate(inner);
    if (coord != null) {
      tokens.add(_Token.citation(m.start, m.end, inner, coord));
    }
  }
  // Bare in-prose citations like "BG 2.47", "Bhagavad Gītā 11.37",
  // "Kaṭha 1.2.18" — anything parseScriptureCoordinate can resolve.
  // Restricted to 1-3 word names so we don't grab whole sentences.
  for (final m in bareCitationRe.allMatches(paragraph)) {
    final inner = m.group(1)!.trim();
    final coord = parseScriptureCoordinate(inner);
    if (coord != null) {
      tokens.add(_Token.citation(m.start, m.end, inner, coord));
    }
  }
  tokens.sort((a, b) => a.start.compareTo(b.start));

  // Drop overlapping tokens — earlier wins, so bold inside citation stays a
  // citation only if it started first.
  final dropped = <bool>[for (final _ in tokens) false];
  for (var i = 0; i < tokens.length; i++) {
    if (dropped[i]) continue;
    for (var j = i + 1; j < tokens.length; j++) {
      if (tokens[j].start < tokens[i].end) dropped[j] = true;
    }
  }

  final out = <InlineSpan>[];
  var cursor = 0;
  for (var i = 0; i < tokens.length; i++) {
    if (dropped[i]) continue;
    final t = tokens[i];
    if (t.start > cursor) {
      out.add(TextSpan(text: paragraph.substring(cursor, t.start)));
    }
    switch (t.kind) {
      case _TokenKind.bold:
        out.add(TextSpan(text: t.text, style: boldKeyTerm));
      case _TokenKind.italicEmph:
        out.add(TextSpan(text: t.text, style: italicEmph));
      case _TokenKind.citation:
        out.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: _CitationChip(
            label: t.text,
            saffron: saffron,
            glow: saffronGlow,
            onTap: () => context.push(
              '/browse/${t.coord!.scripture.code}/verse/${t.coord!.verseId}',
            ),
          ),
        ));
    }
    cursor = t.end;
  }
  if (cursor < paragraph.length) {
    out.add(TextSpan(text: paragraph.substring(cursor)));
  }
  return out;
}

/// Parenthesised citation regex. Body starts with a non-digit (so we don't
/// grab numeric parens like "(1)") and ends with a 2-or-3-segment numeric
/// coordinate. ASCII + Devanāgarī digits accepted.
final RegExp citationRe = RegExp(
  r'\(([A-Za-zĀ-žऀ-ॿ][^()]{1,80}?'
  r'[\s.](?:[0-9०-९]+[.: ]){1,2}[0-9०-९]+)\)',
);

/// Bare in-prose citation regex — alias word(s) + numeric coordinate, no
/// parentheses. Caps the alias at 3 words so a whole sentence can't be
/// swept up. parseScriptureCoordinate is the final arbiter: if the leading
/// words don't match any known alias, the token is dropped.
///
/// The Devanāgarī letter range is split around U+0966-U+096F so digits
/// (०-९) stay out of the alias class — otherwise "BG २.४७" never
/// separates into alias + numeric. The trailing boundary uses an explicit
/// negative-lookahead instead of `\b` because Dart's default `\b` treats
/// Devanāgarī digits as non-word characters.
final RegExp bareCitationRe = RegExp(
  r'\b([A-Za-zĀ-žऀ-॥॰-ॿ]'
  r'[A-Za-zĀ-žऀ-॥॰-ॿ’\-]*'
  r'(?:\s[A-Za-zĀ-žऀ-॥॰-ॿ]'
  r'[A-Za-zĀ-žऀ-॥॰-ॿ’\-]*){0,2}'
  r'\s+[0-9०-९]+\.[0-9०-९]+(?:\.[0-9०-९]+)?)'
  r'(?![0-9०-९.])',
);

enum _TokenKind { bold, italicEmph, citation }

class _Token {
  _Token._({
    required this.start,
    required this.end,
    required this.text,
    required this.kind,
    this.coord,
  });

  factory _Token.bold(int s, int e, String text) =>
      _Token._(start: s, end: e, text: text, kind: _TokenKind.bold);
  factory _Token.italicEmph(int s, int e, String text) =>
      _Token._(start: s, end: e, text: text, kind: _TokenKind.italicEmph);
  factory _Token.citation(
          int s, int e, String text, ScriptureCoordinate coord) =>
      _Token._(
          start: s,
          end: e,
          text: text,
          kind: _TokenKind.citation,
          coord: coord);

  final int start;
  final int end;
  final String text;
  final _TokenKind kind;
  final ScriptureCoordinate? coord;
}

class _CitationChip extends StatelessWidget {
  const _CitationChip({
    required this.label,
    required this.saffron,
    required this.glow,
    required this.onTap,
  });

  final String label;
  final Color saffron;
  final Color glow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: glow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: saffron.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 13,
              height: 1.0,
              color: saffron,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
