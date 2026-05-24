import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sanatan_guide/core/constants/bhagavad_gita_chapters.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/services/review_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/core/services/word_gloss_service.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/core/utils/explain_question.dart';
import 'package:sanatan_guide/core/utils/verse_text.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/verse_detail_glyphs.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart'
    as font_prefs;
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';

/// Cleans `verse.sanskrit` for the reading pass while keeping the manuscript's
/// metrical line breaks: drops Vedic svara marks (via [stripVedicAccents]),
/// normalises ASCII pipes to Devanāgarī daṇḍas (`|` → `।`, `||` → `॥`),
/// collapses runs of spaces inside a line, and preserves the `\n` between pādas.
String readingSanskrit(String raw) => raw
    .replaceAll('||', '॥')
    .replaceAll('|', '।')
    .split('\n')
    .map(stripVedicAccents)
    .where((line) => line.isNotEmpty)
    .join('\n');

/// Splits cleaned Sanskrit into display lines: honours the source's `\n`
/// breaks; if the verse is a single line, breaks it after each daṇḍa
/// (`।` / `॥`) so a śloka still reads as separate pādas.
List<String> sanskritDisplayLines(String cleaned) {
  final byNewline =
      cleaned.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
  if (byNewline.length > 1) return byNewline.toList(growable: false);

  final single = byNewline.isEmpty ? '' : byNewline.first;
  if (single.isEmpty) return const [];
  final out = <String>[];
  final buf = StringBuffer();
  for (final rune in single.runes) {
    final ch = String.fromCharCode(rune);
    buf.write(ch);
    if (ch == '।' || ch == '॥') {
      out.add(buf.toString().trim());
      buf.clear();
    }
  }
  final tail = buf.toString().trim();
  if (tail.isNotEmpty) out.add(tail);
  return out.isEmpty ? [single] : out;
}

/// Roman numeral for small chapter numbers (1–3999); plain Arabic otherwise.
String _roman(int n) {
  if (n < 1 || n > 3999) return '$n';
  const vals = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
  const syms = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
  final out = StringBuffer();
  var x = n;
  for (var i = 0; i < vals.length; i++) {
    while (x >= vals[i]) {
      out.write(syms[i]);
      x -= vals[i];
    }
  }
  return out.toString();
}

/// `CHAPTER I · VERSE 1` style coordinate shown inside the leaf.
String _verseCoordLabel(Verse verse) {
  if (verse.id.split('.').length >= 4) {
    return getVerseLabel(verse).toUpperCase();
  }
  return 'CHAPTER ${_roman(verse.chapterNum)} · VERSE ${verse.verseNum}';
}

/// Devanāgarī chapter name for the top-bar context line, when known.
String? _chapterDevaName(Verse verse) {
  if (verse.id.split('.').first.toUpperCase() == 'BG' &&
      verse.chapterNum >= 1 &&
      verse.chapterNum <= 18) {
    return BhagavadGitaChapters.byNumber(verse.chapterNum).sanskritName;
  }
  return verse.chapterLabel;
}

// ════════════════════════════════════════════════════════════════════════
// PAGE
// ════════════════════════════════════════════════════════════════════════

class VerseDetailPage extends ConsumerStatefulWidget {
  const VerseDetailPage({super.key, required this.verseId});

  final String verseId;

  @override
  ConsumerState<VerseDetailPage> createState() => _VerseDetailPageState();
}

class _VerseDetailPageState extends ConsumerState<VerseDetailPage> {
  late String _currentVerseId;
  String? _lastKnownTitle;

  @override
  void initState() {
    super.initState();
    _currentVerseId = widget.verseId;
  }

  @override
  void didUpdateWidget(covariant VerseDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verseId != widget.verseId) {
      setState(() => _currentVerseId = widget.verseId);
    }
  }

  void _goToVerse(String verseId) {
    if (verseId == _currentVerseId) return;
    setState(() => _currentVerseId = verseId);
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/browse');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(verseDetailProvider(_currentVerseId));
    final adjacent =
        ref.watch(adjacentVerseIdsProvider(_currentVerseId)).asData?.value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(intensity: 0.6),
          SafeArea(
            child: state.when(
              loading: () => _ChromeFrame(
                title: _lastKnownTitle ?? 'Bhagavad Gītā',
                coord: 'LOADING VERSE',
                isDark: isDark,
                onBack: _back,
                prevId: adjacent?.prevId,
                nextId: adjacent?.nextId,
                onGoToVerse: _goToVerse,
                actionsEnabled: false,
                bookmarkId: _currentVerseId,
                child: _LoadingBody(isDark: isDark),
              ),
              error: (_, __) => _ChromeFrame(
                title: _lastKnownTitle ?? 'Scripture',
                coord: 'COULD NOT LOAD',
                isDark: isDark,
                onBack: _back,
                prevId: adjacent?.prevId,
                nextId: adjacent?.nextId,
                onGoToVerse: _goToVerse,
                actionsEnabled: false,
                bookmarkId: _currentVerseId,
                child: _ErrorBody(
                  isDark: isDark,
                  nextId: adjacent?.nextId,
                  onGoToVerse: _goToVerse,
                  onBack: _back,
                  onRetry: () =>
                      ref.invalidate(verseDetailProvider(_currentVerseId)),
                ),
              ),
              data: (either) => either.fold(
                (failure) => _ChromeFrame(
                  title: _lastKnownTitle ?? 'Scripture',
                  coord: 'COULD NOT LOAD',
                  isDark: isDark,
                  onBack: _back,
                  prevId: adjacent?.prevId,
                  nextId: adjacent?.nextId,
                  onGoToVerse: _goToVerse,
                  actionsEnabled: false,
                  bookmarkId: _currentVerseId,
                  child: _ErrorBody(
                    isDark: isDark,
                    nextId: adjacent?.nextId,
                    onGoToVerse: _goToVerse,
                    onBack: _back,
                    onRetry: () =>
                        ref.invalidate(verseDetailProvider(_currentVerseId)),
                  ),
                ),
                (verse) {
                  _lastKnownTitle = verse.scripture.displayNameSafe;
                  return _VerseBody(
                    verse: verse,
                    prevId: adjacent?.prevId,
                    nextId: adjacent?.nextId,
                    isDark: isDark,
                    onBack: _back,
                    onGoToVerse: _goToVerse,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Display name guarded against the legacy "Bhagavad Gita" spelling.
extension on Scripture {
  String get displayNameSafe =>
      this == Scripture.bhagavadGita ? 'Bhagavad Gītā' : displayName;
}

// ════════════════════════════════════════════════════════════════════════
// CHROME FRAME — top bar + progress rail + util bar around any body
// ════════════════════════════════════════════════════════════════════════

class _ChromeFrame extends StatelessWidget {
  const _ChromeFrame({
    required this.title,
    required this.coord,
    required this.isDark,
    required this.onBack,
    required this.prevId,
    required this.nextId,
    required this.onGoToVerse,
    required this.bookmarkId,
    required this.child,
    this.actionsEnabled = true,
    this.position,
    this.onShare,
    this.translationOn = false,
    this.onToggleTranslation,
    this.onOpenNotes,
    this.hasNote = false,
  });

  final String title;
  final String coord;
  final bool isDark;
  final VoidCallback onBack;
  final String? prevId;
  final String? nextId;
  final void Function(String) onGoToVerse;
  final String bookmarkId;
  final Widget child;
  final bool actionsEnabled;
  final ({int index, int total})? position;
  final VoidCallback? onShare;
  final bool translationOn;
  final VoidCallback? onToggleTranslation;
  final VoidCallback? onOpenNotes;
  final bool hasNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(
          title: title,
          coord: coord,
          isDark: isDark,
          onBack: onBack,
          actionsEnabled: actionsEnabled,
          bookmarkId: bookmarkId,
          onShare: onShare,
        ),
        if (position != null)
          _ProgressRail(
            index: position!.index,
            total: position!.total,
            isDark: isDark,
          ),
        Expanded(child: child),
        _UtilBar(
          isDark: isDark,
          prevId: prevId,
          nextId: nextId,
          onGoToVerse: onGoToVerse,
          enabled: actionsEnabled,
          translationOn: translationOn,
          onToggleTranslation: onToggleTranslation,
          onOpenNotes: onOpenNotes,
          hasNote: hasNote,
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.coord,
    required this.isDark,
    required this.onBack,
    required this.actionsEnabled,
    required this.bookmarkId,
    this.onShare,
  });

  final String title;
  final String coord;
  final bool isDark;
  final VoidCallback onBack;
  final bool actionsEnabled;
  final String bookmarkId;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final devaCoord = coord.contains(RegExp(r'[ऀ-ॿ]'));

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CircleButton(
            isDark: isDark,
            onTap: onBack,
            child: Icon(Icons.chevron_left_rounded, size: 24, color: text1),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    // 1.0 clipped the Devanāgarī/macron mātrā on the title.
                    height: 1.2,
                    color: text1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coord,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: devaCoord
                      // devUI is height:1.0 — Devanāgarī top mātrā clips at
                      // that tight box; give the chapter-name line air.
                      ? AppText.devUI(color: text3, size: 12)
                          .copyWith(height: 1.45)
                      : AppText.meta(color: text3, size: 9.5)
                          .copyWith(letterSpacing: 2.0),
                ),
              ],
            ),
          ),
          if (actionsEnabled) ...[
            _BookmarkAction(verseId: bookmarkId, isDark: isDark),
            _CircleButton(
              isDark: isDark,
              onTap: onShare ?? () {},
              child: ShareNetworkGlyph(color: text1, size: 18),
            ),
          ] else
            const SizedBox(width: 72),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.isDark,
    required this.onTap,
    required this.child,
  });

  final bool isDark;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      highlightColor: (isDark ? DColors.saffron : LColors.saffron)
          .withValues(alpha: 0.04),
      splashColor: Colors.transparent,
      child: SizedBox(width: 36, height: 36, child: Center(child: child)),
    );
  }
}

class _ProgressRail extends StatelessWidget {
  const _ProgressRail({
    required this.index,
    required this.total,
    required this.isDark,
  });

  final int index;
  final int total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final pct = total <= 0 ? 0.0 : (index / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          Text('$index / $total',
              style: AppText.meta(color: text3, size: 9.5)
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Container(height: 1, color: dividerSoft),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(height: 1, color: saffron),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${(pct * 100).round()}%',
              style: AppText.meta(color: text3, size: 9.5)
                  .copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _UtilBar extends StatelessWidget {
  const _UtilBar({
    required this.isDark,
    required this.prevId,
    required this.nextId,
    required this.onGoToVerse,
    required this.enabled,
    this.translationOn = false,
    this.onToggleTranslation,
    this.onOpenNotes,
    this.hasNote = false,
  });

  final bool isDark;
  final String? prevId;
  final String? nextId;
  final void Function(String) onGoToVerse;
  final bool enabled;
  final bool translationOn;
  final VoidCallback? onToggleTranslation;
  final VoidCallback? onOpenNotes;
  final bool hasNote;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final surface = isDark ? DColors.surface : LColors.surface;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronGlow = isDark ? DColors.saffronGlow : LColors.saffronGlow;

    Future<void> nav(String id) async {
      try {
        await Haptics.vibrate(HapticsType.light);
      } catch (_) {}
      onGoToVerse(id);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad > 0 ? bottomPad : 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.button),
        ),
        child: Row(
          children: [
            _UtilNav(
              icon: Icons.chevron_left_rounded,
              enabled: prevId != null,
              color: text3,
              activeColor: saffron,
              onTap: prevId == null ? null : () => nav(prevId!),
            ),
            _UtilAction(
              glyphBuilder: (c) => TranslationEyeGlyph(color: c, size: 16),
              label: 'Translation',
              text: text2,
              active: translationOn,
              activeBg: saffronGlow,
              activeColor: saffron,
              onTap: enabled ? onToggleTranslation : null,
            ),
            _UtilAction(
              glyphBuilder: (c) => ListenClockGlyph(color: c, size: 16),
              label: 'Listen',
              text: text2,
              onTap: null, // audio not bundled yet
            ),
            _UtilAction(
              glyphBuilder: (c) => NotesCaretGlyph(color: c, size: 16),
              label: 'Notes',
              text: hasNote ? saffron : text2,
              onTap: enabled ? onOpenNotes : null,
            ),
            _UtilNav(
              icon: Icons.chevron_right_rounded,
              enabled: nextId != null,
              color: text3,
              activeColor: saffron,
              onTap: nextId == null ? null : () => nav(nextId!),
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilNav extends StatelessWidget {
  const _UtilNav({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color color;
  final Color activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        splashColor: Colors.transparent,
        highlightColor: activeColor.withValues(alpha: 0.04),
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: enabled ? activeColor : color.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _UtilAction extends StatelessWidget {
  const _UtilAction({
    required this.glyphBuilder,
    required this.label,
    required this.text,
    this.active = false,
    this.activeBg,
    this.activeColor,
    required this.onTap,
  });

  final Widget Function(Color color) glyphBuilder;
  final String label;
  final Color text;
  final bool active;
  final Color? activeBg;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final c = active ? (activeColor ?? text) : text;
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: InkResponse(
          onTap: onTap,
          radius: 28,
          splashColor: Colors.transparent,
          highlightColor: (activeColor ?? text).withValues(alpha: 0.04),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: active ? activeBg : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                glyphBuilder(c),
                const SizedBox(width: 6),
                Text(label, style: AppText.pill(color: c).copyWith(fontSize: 11)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// LOADED BODY
// ════════════════════════════════════════════════════════════════════════

class _VerseBody extends ConsumerStatefulWidget {
  const _VerseBody({
    required this.verse,
    required this.prevId,
    required this.nextId,
    required this.isDark,
    required this.onBack,
    required this.onGoToVerse,
  });

  final Verse verse;
  final String? prevId;
  final String? nextId;
  final bool isDark;
  final VoidCallback onBack;
  final void Function(String) onGoToVerse;

  @override
  ConsumerState<_VerseBody> createState() => _VerseBodyState();
}

class _VerseBodyState extends ConsumerState<_VerseBody> {
  late final TextEditingController _noteController;
  late final FocusNode _noteFocusNode;
  Timer? _saveTimer;

  WordMeaning? _selectedWord;

  bool _explaining = false;
  String? _explainError;
  bool _chapterJustCompleted = false;

  Verse get verse => widget.verse;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: verse.noteText ?? '');
    _noteFocusNode = FocusNode()
      ..addListener(() {
        if (!_noteFocusNode.hasFocus) {
          _saveTimer?.cancel();
          unawaited(_persistNoteFor(verse, _noteController.text));
        }
      });
    _recordReading(verse);
  }

  @override
  void didUpdateWidget(covariant _VerseBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verse.id != widget.verse.id) {
      _saveTimer?.cancel();
      unawaited(_persistNoteFor(oldWidget.verse, _noteController.text));
      _noteController.text = widget.verse.noteText ?? '';
      _selectedWord = null;
      _explaining = false;
      _explainError = null;
      _recordReading(widget.verse);
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _noteFocusNode.dispose();
    _noteController.dispose();
    if (_chapterJustCompleted) {
      unawaited(
        ReviewService.maybeRequestReview(ReviewTrigger.chapterCompleted),
      );
    }
    super.dispose();
  }

  // ── Read tracking (streak + analytics + chapter completion) ─────────────

  void _recordReading(Verse v) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StreakService.recordReadingToday();
      await StreakService.saveLastReadVerse(v.id, v.scripture.code);
      AnalyticsService.verseRead(
        verseId: v.id,
        scripture: v.scripture.code,
        chapter: v.chapterNum,
        verse: v.verseNum,
      );
      if (mounted) {
        ref
          ..invalidate(currentStreakProvider)
          ..invalidate(readHistoryProvider)
          ..invalidate(lastReadVerseProvider);
      }
      try {
        final repo = await ref.read(scriptureRepositoryProvider.future);
        final wasUnread = v.readCount == 0;
        await repo.markVerseRead(v.id);
        if (mounted) {
          ref.invalidate(
            chapterReadCountProvider(v.scripture.code, v.chapterNum, v.bookNum),
          );
        }
        if (wasUnread && !_chapterJustCompleted) {
          final total = await repo.getChapterVerseCount(
            scriptureCode: v.scripture.code,
            chapterNum: v.chapterNum,
            bookNum: v.bookNum,
          );
          final read = await repo.getChapterReadCount(
            scriptureCode: v.scripture.code,
            chapterNum: v.chapterNum,
            bookNum: v.bookNum,
          );
          if (total > 0 && read >= total) _chapterJustCompleted = true;
        }
      } catch (e, st) {
        AppLogger.instance.w('markVerseRead failed for ${v.id}', e, st);
      }
    });
  }

  // ── Notes ───────────────────────────────────────────────────────────────

  void _onNoteChanged(String value) {
    _saveTimer?.cancel();
    final v = verse;
    _saveTimer =
        Timer(const Duration(milliseconds: 600), () => _persistNoteFor(v, value));
    setState(() {});
  }

  Future<void> _persistNoteFor(Verse v, String value) async {
    try {
      final repo = await ref.read(scriptureRepositoryProvider.future);
      final trimmed = value.trim().isEmpty ? null : value.trim();
      await repo.updateVerseNote(v.id, trimmed);
      if (mounted) ref.invalidate(verseDetailProvider(v.id));
    } catch (e, st) {
      AppLogger.instance.w('persistNote failed for ${v.id}', e, st);
    }
  }

  void _openNotes() {
    // Snapshot the saved value when the sheet opens so Cancel can roll back
    // any unsaved edits the user made inside the sheet.
    final original = _noteController.text;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _NotesSheet(
        verse: verse,
        controller: _noteController,
        focusNode: _noteFocusNode,
        isDark: widget.isDark,
        onChanged: _onNoteChanged,
        onSave: () {
          _saveTimer?.cancel();
          unawaited(_persistNoteFor(verse, _noteController.text));
          _noteFocusNode.unfocus();
          Navigator.of(sheetCtx).pop();
        },
        onCancel: () {
          // Revert the controller to what we snapshotted; don't persist.
          _saveTimer?.cancel();
          _noteController.text = original;
          _noteFocusNode.unfocus();
          Navigator.of(sheetCtx).pop();
        },
        onDelete: () {
          _saveTimer?.cancel();
          _noteController.clear();
          unawaited(_persistNoteFor(verse, ''));
          _noteFocusNode.unfocus();
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }

  // ── Word callout ────────────────────────────────────────────────────────

  void _selectWord(WordMeaning? wm) {
    if (_selectedWord == wm) return;
    setState(() => _selectedWord = wm);
  }

  // ── Share ───────────────────────────────────────────────────────────────

  void _share() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _ShareSheet(
        verse: verse,
        isDark: widget.isDark,
        onCopy: (text) {
          Clipboard.setData(ClipboardData(text: text));
          Navigator.of(sheetCtx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onShare: (text) {
          AnalyticsService.verseShared(verse.id);
          Navigator.of(sheetCtx).pop();
          Share.share(text);
        },
      ),
    );
  }

  // ── AI explanation ──────────────────────────────────────────────────────

  Future<void> _startExplain() async {
    if (_explaining) return;
    setState(() {
      _explaining = true;
      _explainError = null;
    });
    try {
      final ok = await GeminiRateLimit.consume();
      if (!ok) {
        if (mounted) {
          setState(() {
            _explaining = false;
            _explainError = 'Daily question limit reached. Try again tomorrow.';
          });
        }
        return;
      }
      final translation = verse.english ?? '';
      final reply = await GeminiService.ask(
        systemContext:
            'You are a careful scripture commentator. The verse is from '
            '${verse.scripture.displayNameSafe} (${getVerseLabel(verse)}).\n'
            'Sanskrit:\n${verse.sanskrit}\nTranslation:\n$translation',
        history: const [],
        userMessage:
            'Explain this verse in two or three short paragraphs for a '
            'thoughtful reader. Use flowing prose. You may wrap transliterated '
            'Sanskrit terms in *single asterisks*. Do not add headings or lists.',
      );
      final db = await ref.read(appDatabaseProvider.future);
      await db.scriptureDao.upsertVerseExplanation(
        verseId: verse.id,
        explanationText: reply.trim(),
        modelVersion: 'gemini-2.5-flash',
      );
      if (mounted) {
        ref.invalidate(verseExplanationProvider(verse.id));
        setState(() => _explaining = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _explaining = false;
          _explainError = e is GeminiException
              ? e.message
              : 'Couldn\'t generate an explanation. Please try again.';
        });
      }
    }
  }

  void _openChat({String? seed}) {
    context.push(
      '/browse/${verse.scripture.code}/verse/${verse.id}/chat',
      extra: seed == null ? null : {'seed': seed},
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final position = ref.watch(verseChapterPositionProvider(verse.id)).asData?.value;
    final translitOn =
        ref.watch(transliterationEnabledProvider).asData?.value ?? false;
    final cachedExp = ref.watch(verseExplanationProvider(verse.id)).asData?.value;
    final fontSize = ref.watch(font_prefs.fontSizeProvider);
    final hasNote = _noteController.text.trim().isNotEmpty ||
        (verse.noteText?.trim().isNotEmpty ?? false);

    final dim = _selectedWord != null;
    final sanskritScale = fontSize / font_prefs.kDefaultFontSize;
    final compressed = cachedExp != null || _explaining;

    final content = SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Leaf(
            verse: verse,
            isDark: isDark,
            sanskritSize:
                compressed ? 18.0 : (24.0 * sanskritScale),
            compressed: compressed,
            selectedWord: _selectedWord,
            onSelectWord: _selectWord,
          ).animate(target: 1).fadeIn(duration: 700.ms, delay: 100.ms).slideY(
                begin: 0.02,
                end: 0,
                duration: 700.ms,
                delay: 100.ms,
                curve: Curves.easeOut,
              ),
          AnimatedOpacity(
            opacity: dim ? 0.45 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: dim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (translitOn &&
                      (verse.transliteration?.trim().isNotEmpty ?? false)) ...[
                    const SizedBox(height: Spacing.xxxl),
                    _SectionRule(label: 'Transliteration', isDark: isDark),
                    const SizedBox(height: Spacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24 + 8),
                      child: Text(
                        verse.transliteration!.trim(),
                        textAlign: TextAlign.center,
                        // IAST dot-diacritics (ṛ ṣ ṭ ṇ) tofu in Lora — only
                        // TiroDevanagari covers them (see commit f6647d6).
                        style: AppText.commentary(
                          color: isDark ? DColors.text2 : LColors.text2,
                          size: 14 * sanskritScale,
                        ).copyWith(
                          fontFamily: Fonts.deva,
                          fontFamilyFallback: AppFontFallback.deva,
                          fontStyle: FontStyle.normal,
                          height: 1.75,
                        ),
                      ),
                    ),
                  ],
                  // Skip the separate "Translation" section when the leaf
                  // is already showing the translation in place of the
                  // empty Sanskrit body.
                  if ((verse.english?.trim().isNotEmpty ?? false) &&
                      readingSanskrit(verse.sanskrit).trim().isNotEmpty) ...[
                    const SizedBox(height: Spacing.xxxl),
                    _SectionRule(label: 'Translation', isDark: isDark),
                    const SizedBox(height: Spacing.md),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24 + 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verse.english!.trim(),
                            style: AppText.translation(
                              color: isDark ? DColors.text1 : LColors.text1,
                              size: 16 * sanskritScale,
                            ),
                          )
                              .animate(target: 1)
                              .fadeIn(duration: 700.ms, delay: 380.ms)
                              .slideY(
                                begin: 0.02,
                                end: 0,
                                duration: 700.ms,
                                delay: 380.ms,
                                curve: Curves.easeOut,
                              ),
                          if (_translatorName(verse) != null) ...[
                            const SizedBox(height: Spacing.md),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '— ${_translatorName(verse)}',
                                style: AppText.metaLabel(
                                  color:
                                      isDark ? DColors.text3 : LColors.text3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.xxl),
                  _explainSection(isDark, cachedExp?.explanationText),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: dim ? () => _selectWord(null) : null,
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v < -300 && widget.nextId != null) {
          widget.onGoToVerse(widget.nextId!);
        } else if (v > 300 && widget.prevId != null) {
          widget.onGoToVerse(widget.prevId!);
        }
      },
      child: _ChromeFrame(
        title: verse.scripture.displayNameSafe,
        coord: _chapterDevaName(verse) ?? _verseCoordLabel(verse),
        isDark: isDark,
        onBack: widget.onBack,
        prevId: widget.prevId,
        nextId: widget.nextId,
        onGoToVerse: widget.onGoToVerse,
        bookmarkId: verse.id,
        position: position,
        onShare: _share,
        translationOn: translitOn,
        onToggleTranslation: () => ref
            .read(transliterationEnabledProvider.notifier)
            .toggle(),
        onOpenNotes: _openNotes,
        hasNote: hasNote,
        child: Stack(
          children: [
            content,
            _SwipeHints(
              isDark: isDark,
              showLeft: widget.prevId != null,
              showRight: widget.nextId != null,
            ),
          ],
        ),
      ),
    );
  }

  String? _translatorName(Verse v) {
    final id = v.translation;
    if (id == null || id.trim().isEmpty) return null;
    return _translatorDisplay[id.toLowerCase()] ??
        id.replaceAll('_', ' ').replaceAllMapped(
              RegExp(r'\b\w'),
              (m) => m.group(0)!.toUpperCase(),
            );
  }

  Widget _explainSection(bool isDark, String? cachedProse) {
    if (cachedProse != null) {
      return _ExplainCard(
        isDark: isDark,
        prose: cachedProse,
        thinking: false,
        followups: explainFollowups(verse),
        onFollowup: (q) => _openChat(seed: q),
      );
    }
    if (_explaining) {
      return _ExplainCard(
        isDark: isDark,
        prose: '',
        thinking: true,
        followups: const [],
        onFollowup: (_) {},
      );
    }
    if (!GeminiService.isEnabled) return const SizedBox.shrink();
    return _ExplainTrigger(
      isDark: isDark,
      question: explainQuestion(verse),
      errorText: _explainError,
      onTap: _startExplain,
    );
  }
}

const _translatorDisplay = <String, String>{
  'griffith': 'Ralph T. H. Griffith',
  'ganguli': 'Kisari Mohan Ganguli',
  'muller': 'Max Müller',
  'arnold': 'Sir Edwin Arnold',
  'telang': 'Kāshināth Trimbak Telang',
  'swarupananda': 'Swami Swarupananda',
  'sivananda': 'Swami Sivananda',
  'wilson': 'H. H. Wilson',
  'buhler': 'Georg Bühler',
  'vivekananda': 'Swami Vivekananda',
};

// ════════════════════════════════════════════════════════════════════════
// THE LEAF
// ════════════════════════════════════════════════════════════════════════

class _Leaf extends StatelessWidget {
  const _Leaf({
    required this.verse,
    required this.isDark,
    required this.sanskritSize,
    required this.compressed,
    required this.selectedWord,
    required this.onSelectWord,
  });

  final Verse verse;
  final bool isDark;
  final double sanskritSize;
  final bool compressed;
  final WordMeaning? selectedWord;
  final ValueChanged<WordMeaning?> onSelectWord;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.cream;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final vPad = compressed ? 20.0 : 28.0;

    // When a verse has no Sanskrit body (still being digitized), surface the
    // translation inside the binding card itself instead of leaving the leaf
    // empty and showing the translation in a separate section below.
    final sanskritBody = readingSanskrit(verse.sanskrit).trim();
    final translationOnly = sanskritBody.isEmpty &&
        (verse.english?.trim().isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4, vPad, 4, vPad - 4),
            child: Column(
              children: [
                Text(
                  _verseCoordLabel(verse),
                  textAlign: TextAlign.center,
                  style: AppText.meta(color: saffron, size: 10)
                      .copyWith(fontWeight: FontWeight.w600, letterSpacing: 2.8),
                ),
                const SizedBox(height: Spacing.sectionV),
                if (translationOnly)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      verse.english!.trim(),
                      textAlign: TextAlign.center,
                      style: AppText.translation(
                        color: text1,
                        size: 17 * (sanskritSize / 24.0),
                      ).copyWith(height: 1.6),
                    ),
                  )
                else
                  _SanskritWords(
                    text: readingSanskrit(verse.sanskrit),
                    wordMeanings: verse.wordMeanings,
                    size: sanskritSize,
                    baseColor: cream,
                    saffron: saffron,
                    selectedWord: selectedWord,
                    onSelectWord: onSelectWord,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BindingLine(
                isDark: isDark, faded: true, diamondSize: 6, sideGap: 12),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BindingLine(
                isDark: isDark, faded: true, diamondSize: 6, sideGap: 12),
          ),
          if (selectedWord != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: Center(
                child: _WordCallout(
                    word: selectedWord!, isDark: isDark, verse: verse),
              ),
            ),
        ],
      ),
    );
  }
}

class _SanskritWords extends StatelessWidget {
  const _SanskritWords({
    required this.text,
    required this.wordMeanings,
    required this.size,
    required this.baseColor,
    required this.saffron,
    required this.selectedWord,
    required this.onSelectWord,
  });

  final String text;
  final List<WordMeaning>? wordMeanings;
  final double size;
  final Color baseColor;
  final Color saffron;
  final WordMeaning? selectedWord;
  final ValueChanged<WordMeaning?> onSelectWord;

  static final _danda = RegExp(r'[।॥]+$');

  @override
  Widget build(BuildContext context) {
    final base = AppText.sanskritBody(color: baseColor, size: size)
        .copyWith(height: 1.95, letterSpacing: 0.1);
    final lines = sanskritDisplayLines(text);
    final meanings = wordMeanings ?? const <WordMeaning>[];
    // Every word is tappable (highlight + callout) even when the DB has no
    // per-word gloss for this verse — the callout degrades gracefully.
    final byWord = <String, WordMeaning>{
      for (final wm in meanings) wm.word.trim(): wm,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [for (final line in lines) _wordLine(line, base, byWord)],
    );
  }

  Widget _wordLine(
      String line, TextStyle base, Map<String, WordMeaning> byWord) {
    final children = <Widget>[];
    for (final token in line.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      final core = token.replaceAll(_danda, '');
      final tail = token.substring(core.length);
      if (core.isEmpty) {
        children.add(Text(token, style: base, locale: const Locale('sa')));
        continue;
      }
      // Use the stored gloss if present; otherwise a bare entry so the tap
      // still highlights the word and opens the callout.
      final wm = byWord[core] ?? WordMeaning(word: core, meaning: '');
      final selected = selectedWord?.word == core;
      children.add(
        GestureDetector(
          onTap: () => onSelectWord(selected ? null : wm),
          child: Text(
            core,
            locale: const Locale('sa'),
            style: selected
                ? base.copyWith(
                    color: saffron,
                    decoration: TextDecoration.underline,
                    decorationColor: saffron,
                    decorationThickness: 1.5,
                  )
                : base,
          ),
        ),
      );
      if (tail.isNotEmpty) {
        children.add(Text(tail, style: base, locale: const Locale('sa')));
      }
    }
    // Full width so WrapAlignment.center actually centres the run instead
    // of shrink-wrapping to content (which left-aligned BG 1.1 once the AI
    // commentary expanded and changed the available width).
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 7,
        runSpacing: 2,
        children: children,
      ),
    );
  }
}

/// Lazily resolves a per-word gloss when the bundled DB has none.
/// autoDispose keeps memory tight; the prefs cache makes re-taps instant.
final _wordGlossProvider = FutureProvider.autoDispose.family<WordMeaning,
    ({String verseId, String word, String sanskrit, String label})>(
  (ref, k) => WordGlossService.glossFor(
    verseId: k.verseId,
    word: k.word,
    verseSanskrit: k.sanskrit,
    scriptureLabel: k.label,
  ),
);

class _WordCallout extends ConsumerWidget {
  const _WordCallout({
    required this.word,
    required this.isDark,
    required this.verse,
  });

  final WordMeaning word;
  final bool isDark;
  final Verse verse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final cream = isDark ? DColors.cream : LColors.cream;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;

    final bodyStyle =
        AppText.translation(color: text2, size: 13).copyWith(height: 1.5);
    final italic = bodyStyle.copyWith(fontStyle: FontStyle.italic);

    Widget shell({
      required String? translit,
      required Widget body,
      String? grammar,
    }) {
      return Container(
        width: 240,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Devanāgarī word (cream, 18)
            Text(word.word,
                style: AppText.sanskritBody(color: cream, size: 18)
                    .copyWith(height: 1.3)),
            // 2. IAST transliteration (italic saffron 12)
            if (translit?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(translit!.trim(),
                  // IAST glyphs render only in TiroDevanagari (commit f6647d6).
                  style: AppText.commentary(color: saffron, size: 12).copyWith(
                    fontFamily: Fonts.deva,
                    fontFamilyFallback: AppFontFallback.deva,
                    fontStyle: FontStyle.normal,
                  )),
            ],
            const SizedBox(height: 8),
            // 3. Meaning prose
            body,
            // 4. Grammar tag (NOUN · LOCATIVE · NEUTER) above a dashed divider.
            if (grammar != null && grammar.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _DashedRule(color: dividerSoft),
              const SizedBox(height: 10),
              Text(
                grammar.trim().toUpperCase(),
                style: AppText.meta(color: text2, size: 9).copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Container(height: 1, color: dividerSoft),
            ],
          ],
        ),
      );
    }

    // 1. DB already had a gloss (DB ships none today, but honour it).
    if (word.meaning.trim().isNotEmpty) {
      return shell(
        translit: word.transliteration,
        grammar: word.grammar,
        body: Text(word.meaning, style: bodyStyle),
      );
    }

    // 2. No API key → calm, honest copy (no false "yet": data isn't coming).
    if (!GeminiService.isEnabled) {
      return shell(
        translit: word.transliteration,
        body: Text(
          'Per-word meaning isn’t bundled. Enable the AI guide '
          '(GEMINI_API_KEY) for live word lookups.',
          style: italic,
        ),
      );
    }

    // 3. Key present → fetch once, cache forever, label as AI-suggested.
    final gloss = ref.watch(_wordGlossProvider((
      verseId: verse.id,
      word: word.word,
      sanskrit: verse.sanskrit,
      label: verse.scripture.displayNameSafe,
    )));
    return gloss.when(
      loading: () => shell(
        translit: word.transliteration,
        body: Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 12,
            height: 12,
            child:
                CircularProgressIndicator(strokeWidth: 1.5, color: saffron),
          ),
          const SizedBox(width: 8),
          Text('Looking up…', style: italic),
        ]),
      ),
      error: (e, _) => shell(
        translit: word.transliteration,
        body: Text(
          e is GeminiException
              ? e.message
              : 'Couldn’t look up this word. Try again.',
          style: italic,
        ),
      ),
      data: (wm) => shell(
        translit: wm.transliteration ?? word.transliteration,
        grammar: wm.grammar,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(wm.meaning, style: bodyStyle),
            const SizedBox(height: 6),
            Text('AI-suggested gloss · verify before relying on it',
                style: AppText.meta(color: text2, size: 10)),
          ],
        ),
      ),
    );
  }
}

class _SectionRule extends StatelessWidget {
  const _SectionRule({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? DColors.divider : LColors.divider;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: divider)),
          const SizedBox(width: 12),
          Text(label.toUpperCase(),
              style: AppText.sectionLabel(color: saffron)),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: divider)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// AI EXPLAIN
// ════════════════════════════════════════════════════════════════════════

class _ExplainTrigger extends StatelessWidget {
  const _ExplainTrigger({
    required this.isDark,
    required this.question,
    required this.onTap,
    this.errorText,
  });

  final bool isDark;
  final String question;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? DColors.divider : LColors.divider;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronGlow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final ironRedBright = isDark ? DColors.ironRedBright : LColors.ironRedBright;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Radii.card),
            splashColor: Colors.transparent,
            highlightColor: saffron.withValues(alpha: 0.04),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(color: divider),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [saffronGlow, Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: saffronGlow,
                    ),
                    child: Center(
                      child: Text('ॐ',
                          style: AppText.sanskritBody(color: saffron, size: 16)
                              .copyWith(height: 1.0)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPLAIN THIS VERSE',
                            style: AppText.meta(color: saffron, size: 9).copyWith(
                                fontWeight: FontWeight.w600, letterSpacing: 2.2)),
                        const SizedBox(height: 2),
                        Text(question,
                            style: AppText.commentary(color: text1, size: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MockupRowChevron(color: text3),
                ],
              ),
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(errorText!,
                style: AppText.rowSub(color: ironRedBright)),
          ],
        ],
      ),
    );
  }
}

class _ExplainCard extends StatelessWidget {
  const _ExplainCard({
    required this.isDark,
    required this.prose,
    required this.thinking,
    required this.followups,
    required this.onFollowup,
  });

  final bool isDark;
  final String prose;
  final bool thinking;
  final List<String> followups;
  final ValueChanged<String> onFollowup;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronGlow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: saffronGlow),
                  child: Center(
                    child: Text('ॐ',
                        style: AppText.sanskritBody(color: saffron, size: 13)
                            .copyWith(height: 1.0)),
                  ),
                ),
                const SizedBox(width: 10),
                Text('COMMENTARY',
                    style: AppText.meta(color: saffron, size: 10).copyWith(
                        fontWeight: FontWeight.w600, letterSpacing: 2.2)),
                const Spacer(),
                Text('AI · GEMINI',
                    style: AppText.meta(color: text3, size: 9)
                        .copyWith(letterSpacing: 1.6)),
              ],
            ),
            const SizedBox(height: 14),
            ..._prose(prose, text1),
            if (thinking) ...[
              if (prose.trim().isNotEmpty) const SizedBox(height: 12),
              Row(
                children: [
                  Text('Reflecting on this verse',
                      style: AppText.translation(
                              color: text2, size: 14.5)
                          .copyWith(height: 1.72)),
                  const SizedBox(width: 8),
                  AIThinkingDots(isDark: isDark),
                ],
              ),
            ],
            if (!thinking && followups.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(height: 1, color: dividerSoft),
              const SizedBox(height: 12),
              Text('ASK FURTHER',
                  style: AppText.meta(color: text3, size: 9).copyWith(
                      fontWeight: FontWeight.w600, letterSpacing: 2.2)),
              const SizedBox(height: 8),
              for (final q in followups) ...[
                InkWell(
                  onTap: () => onFollowup(q),
                  borderRadius: BorderRadius.circular(Radii.card),
                  splashColor: Colors.transparent,
                  highlightColor: saffron.withValues(alpha: 0.04),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.card),
                      border: Border.all(color: dividerSoft),
                    ),
                    child: Text(q,
                        style: AppText.commentary(color: text2, size: 13)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // Renders paragraphs (blank-line separated) with *italic* spans.
  List<Widget> _prose(String text, Color color) {
    if (text.trim().isEmpty) return const [];
    final base = AppText.translation(color: color, size: 14.5)
        .copyWith(height: 1.72);
    final italic = base.copyWith(fontStyle: FontStyle.italic);
    final paras = text.trim().split(RegExp(r'\n{2,}'));
    final out = <Widget>[];
    for (var i = 0; i < paras.length; i++) {
      if (i > 0) out.add(const SizedBox(height: 12));
      final spans = <TextSpan>[];
      final parts = paras[i].replaceAll('\n', ' ').split('*');
      for (var j = 0; j < parts.length; j++) {
        if (parts[j].isEmpty) continue;
        spans.add(TextSpan(text: parts[j], style: j.isOdd ? italic : base));
      }
      out.add(Text.rich(TextSpan(children: spans)));
    }
    return out;
  }
}

// ════════════════════════════════════════════════════════════════════════
// LOADING / ERROR / SWIPE HINTS / NOTES / BOOKMARK
// ════════════════════════════════════════════════════════════════════════

class _LoadingBody extends StatelessWidget {
  const _LoadingBody({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 28, 4, 24),
                  child: Column(
                    children: [
                      _Shimmer(width: 140, height: 10, isDark: isDark),
                      const SizedBox(height: 30),
                      _Shimmer(widthFactor: 0.8, height: 18, isDark: isDark),
                      const SizedBox(height: 18),
                      _Shimmer(widthFactor: 0.9, height: 18, isDark: isDark),
                      const SizedBox(height: 18),
                      _Shimmer(widthFactor: 0.75, height: 18, isDark: isDark),
                      const SizedBox(height: 18),
                      _Shimmer(widthFactor: 0.85, height: 18, isDark: isDark),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: BindingLine(
                      isDark: isDark, faded: true, diamondSize: 6, sideGap: 12),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: BindingLine(
                      isDark: isDark, faded: true, diamondSize: 6, sideGap: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxxl),
          _SectionRule(label: 'Transliteration', isDark: isDark),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                _Shimmer(widthFactor: 0.8, height: 10, isDark: isDark),
                const SizedBox(height: 8),
                _Shimmer(widthFactor: 0.7, height: 10, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxxl),
          _SectionRule(label: 'Translation', isDark: isDark),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Shimmer(widthFactor: 1.0, height: 12, isDark: isDark),
                const SizedBox(height: 10),
                _Shimmer(widthFactor: 0.95, height: 12, isDark: isDark),
                const SizedBox(height: 10),
                _Shimmer(widthFactor: 0.6, height: 12, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
    required this.height,
    required this.isDark,
    this.width,
    this.widthFactor,
  });

  final double height;
  final bool isDark;
  final double? width;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final color = (isDark ? DColors.saffron : LColors.saffron)
        .withValues(alpha: 0.08);
    Widget bar = Container(
      width: width,
      height: height,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms, begin: 0.5);
    if (widthFactor != null) {
      bar = Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(widthFactor: widthFactor, child: bar),
      );
    }
    return bar;
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.isDark,
    required this.nextId,
    required this.onGoToVerse,
    required this.onBack,
    required this.onRetry,
  });

  final bool isDark;
  final String? nextId;
  final void Function(String) onGoToVerse;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ironRed = isDark ? DColors.ironRed : LColors.ironRed;
    final ironRedBright = isDark ? DColors.ironRedBright : LColors.ironRedBright;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: ironRed.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(
              color: ironRed,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ironRed.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Text('!',
                      style: AppText.sanskritBody(color: ironRedBright, size: 18)
                          .copyWith(height: 1.0)),
                ),
              ),
              const SizedBox(height: 14),
              Text('This verse couldn\'t be loaded',
                  textAlign: TextAlign.center,
                  style: AppText.commentary(color: text1, size: 15)),
              const SizedBox(height: 6),
              Text(
                'The text might be missing from your offline library. '
                'You can retry, or return to the chapter.',
                textAlign: TextAlign.center,
                style: AppText.rowSub(color: text2).copyWith(height: 1.5),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: onRetry,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Text('↻  TRY AGAIN',
                      style: AppText.primaryButton(color: saffron)
                          .copyWith(fontSize: 11, letterSpacing: 2.0)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text('OR READ INSTEAD',
              style: AppText.meta(color: text3, size: 11)
                  .copyWith(letterSpacing: 1.8)),
        ),
        const SizedBox(height: 14),
        if (nextId != null)
          _FallbackRow(
            title: 'Next verse',
            subtitle: 'Continue reading the chapter',
            isDark: isDark,
            onTap: () => onGoToVerse(nextId!),
          ),
        if (nextId != null) const SizedBox(height: 10),
        _FallbackRow(
          title: 'Return to chapter',
          subtitle: 'Back to the verse list',
          isDark: isDark,
          onTap: onBack,
        ),
      ],
    );
  }
}

class _FallbackRow extends StatelessWidget {
  const _FallbackRow({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.card),
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.card),
          border: Border.all(color: dividerSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppText.translation(color: text1, size: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.rowSub(color: text3)),
                ],
              ),
            ),
            MockupRowChevron(color: text3),
          ],
        ),
      ),
    );
  }
}

class _SwipeHints extends StatelessWidget {
  const _SwipeHints({
    required this.isDark,
    required this.showLeft,
    required this.showRight,
  });

  final bool isDark;
  final bool showLeft;
  final bool showRight;

  @override
  Widget build(BuildContext context) {
    final c = (isDark ? DColors.divider : LColors.divider);
    Widget pill() => Container(
          width: 3,
          height: 36,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        );
    return Positioned.fill(
      child: IgnorePointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showLeft ? pill() : const SizedBox(width: 3),
            showRight ? pill() : const SizedBox(width: 3),
          ],
        ),
      ),
    );
  }
}

/// Notes bottom sheet — matches `New Design/screen-14-missing-flows.html`
/// §2 ("Your note"). Two states share one widget: NEW (textarea empty,
/// Save disabled, no Delete) and EDITING (Save enabled, Delete in the
/// lower-left). 1–200 char cap enforced by the textarea.
class _NotesSheet extends StatefulWidget {
  const _NotesSheet({
    required this.verse,
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onSave,
    required this.onCancel,
    required this.onDelete,
  });

  final Verse verse;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  State<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<_NotesSheet> {
  static const int _maxLen = 200;
  late String _initial;

  @override
  void initState() {
    super.initState();
    _initial = widget.controller.text;
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bg = widget.isDark ? DColors.bg : LColors.bg;
    final dividerSoft =
        widget.isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = widget.isDark ? DColors.saffron : LColors.saffron;
    final text1 = widget.isDark ? DColors.text1 : LColors.text1;
    final text2 = widget.isDark ? DColors.text2 : LColors.text2;
    final text3 = widget.isDark ? DColors.text3 : LColors.text3;
    final onSaffron = widget.isDark ? const Color(0xFF1A1208) : Colors.white;

    final hasText = widget.controller.text.trim().isNotEmpty;
    final isEditing = _initial.trim().isNotEmpty;
    final length = widget.controller.text.characters.length;
    final coordDeva = DandaCoord.toDevanagari(widget.verse.verseNum);
    final chapterDeva = DandaCoord.toDevanagari(widget.verse.chapterNum);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: dividerSoft,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header with bottom border. Title left, saffron Devanāgarī
              // coord (₹chapter·verse₹) right.
              Container(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: dividerSoft)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Your note',
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.17,
                        color: text1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '‖$chapterDeva·$coordDeva‖',
                      style: TextStyle(
                        fontFamily: Fonts.deva,
                        fontFamilyFallback: AppFontFallback.deva,
                        fontSize: 13,
                        height: 1.0,
                        color: saffron,
                      ),
                    ),
                  ],
                ),
              ),
              // Body — transparent textarea, italic serif. Counter right.
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minHeight: 130, maxHeight: 220),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: widget.focusNode,
                        autofocus: true,
                        onChanged: widget.onChanged,
                        maxLines: null,
                        maxLength: _maxLen,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        cursorColor: saffron,
                        style: TextStyle(
                          fontFamily: Fonts.serif,
                          fontFamilyFallback: AppFontFallback.latin,
                          fontStyle: FontStyle.italic,
                          fontSize: 14.5,
                          height: 1.65,
                          color: text1,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          filled: false,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          counterText: '',
                          hintText:
                              'What does this verse mean to you? A reflection, a memory, a question to revisit...',
                          hintStyle: TextStyle(
                            fontFamily: Fonts.serif,
                            fontFamilyFallback: AppFontFallback.latin,
                            fontStyle: FontStyle.italic,
                            fontSize: 14.5,
                            height: 1.65,
                            color: text3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$length / $_maxLen',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.12 * 10,
                        color: text3,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions footer with top border. Delete (only when editing)
              // lives in the lower-left; Cancel + Save on the right.
              Container(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dividerSoft)),
                ),
                child: Row(
                  children: [
                    if (isEditing)
                      InkWell(
                        onTap: widget.onDelete,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          child: Text(
                            'DELETE',
                            style: TextStyle(
                              fontFamily: Fonts.sans,
                              fontFamilyFallback: AppFontFallback.latin,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.12 * 11.5,
                              color: text3,
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    _SheetGhostBtn(
                      label: 'CANCEL',
                      color: text2,
                      onTap: widget.onCancel,
                    ),
                    const SizedBox(width: 8),
                    _SheetFilledBtn(
                      label: 'SAVE',
                      bg: saffron,
                      fg: onSaffron,
                      enabled: hasText,
                      onTap: widget.onSave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetGhostBtn extends StatelessWidget {
  const _SheetGhostBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14 * 12,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _SheetFilledBtn extends StatelessWidget {
  const _SheetFilledBtn({
    required this.label,
    required this.bg,
    required this.fg,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final Color bg;
  final Color fg;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled ? onTap : null,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.14 * 12,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookmarkAction extends ConsumerWidget {
  const _BookmarkAction({required this.verseId, required this.isDark});

  final String verseId;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final isBookmarked =
        ref.watch(isBookmarkedProvider(verseId)).asData?.value ?? false;

    return _CircleButton(
      isDark: isDark,
      onTap: () async {
        try {
          await Haptics.vibrate(HapticsType.light);
        } catch (_) {}
        final BookmarksDao dao = await ref.read(bookmarksDaoProvider.future);
        await dao.toggleBookmark(verseId);
        if (!isBookmarked) AnalyticsService.verseBookmarked(verseId);
      },
      child: RibbonBookmarkGlyph(
        color: isBookmarked ? saffron : text1,
        filled: isBookmarked,
        size: 18,
      )
          .animate(key: ValueKey(isBookmarked))
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

/// 1-px dashed horizontal rule. Matches mockup `.word-pos` top border:
/// `border-top: 1px dashed var(--d-divider-soft);`.
class _DashedRule extends StatelessWidget {
  const _DashedRule({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter(color: color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 3.0;
    const gap = 3.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

/// Share bottom sheet — matches `New Design/screen-14-missing-flows.html`
/// §3. Three "What to include" formats (Sanskrit / +Translation / Full
/// citation), a leaf-style preview card, and Copy/Share footer actions.
enum _ShareFormat { sanskritOnly, withTranslation, fullCitation }

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.verse,
    required this.isDark,
    required this.onCopy,
    required this.onShare,
  });

  final Verse verse;
  final bool isDark;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onShare;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  _ShareFormat _format = _ShareFormat.withTranslation;

  String _buildShareText() {
    final v = widget.verse;
    final coord = '${v.scripture.displayNameSafe} '
        '${v.chapterNum}.${v.verseNum}';
    final sanskrit = v.sanskrit.trim();
    final english = v.english?.trim() ?? '';
    const link = 'https://sanatanguide.app';
    final buf = StringBuffer();
    switch (_format) {
      case _ShareFormat.sanskritOnly:
        buf
          ..writeln(coord)
          ..writeln()
          ..writeln(sanskrit);
      case _ShareFormat.withTranslation:
        buf
          ..writeln(coord)
          ..writeln()
          ..writeln(sanskrit);
        if (english.isNotEmpty) {
          buf
            ..writeln()
            ..writeln('"$english"');
        }
      case _ShareFormat.fullCitation:
        buf
          ..writeln(coord)
          ..writeln()
          ..writeln(sanskrit);
        if (english.isNotEmpty) {
          buf
            ..writeln()
            ..writeln('"$english"');
        }
        buf
          ..writeln()
          ..writeln('— Sanatan Guide · $link');
    }
    return buf.toString().trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = widget.isDark;
    final bg = isDark ? DColors.bg : LColors.bg;
    final surface = isDark ? DColors.surface : LColors.surface;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final saffronGlow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final onSaffron = isDark ? const Color(0xFF1A1208) : Colors.white;

    final v = widget.verse;
    final coordDeva = DandaCoord.toDevanagari(v.verseNum);
    final chapterDeva = DandaCoord.toDevanagari(v.chapterNum);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: dividerSoft,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: dividerSoft)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Share this verse',
                      style: TextStyle(
                        fontFamily: Fonts.serif,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.17,
                        color: text1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '‖$chapterDeva·$coordDeva‖',
                      style: TextStyle(
                        fontFamily: Fonts.deva,
                        fontFamilyFallback: AppFontFallback.deva,
                        fontSize: 13,
                        height: 1.0,
                        color: saffron,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'WHAT TO INCLUDE',
                      style: TextStyle(
                        fontFamily: Fonts.sans,
                        fontFamilyFallback: AppFontFallback.latin,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.28 * 9.5,
                        color: text3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _FormatChip(
                            label: 'Sanskrit only',
                            active: _format == _ShareFormat.sanskritOnly,
                            saffron: saffron,
                            saffronGlow: saffronGlow,
                            text2: text2,
                            dividerSoft: dividerSoft,
                            onTap: () => setState(
                                () => _format = _ShareFormat.sanskritOnly),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FormatChip(
                            label: '+ Translation',
                            active: _format == _ShareFormat.withTranslation,
                            saffron: saffron,
                            saffronGlow: saffronGlow,
                            text2: text2,
                            dividerSoft: dividerSoft,
                            onTap: () => setState(
                                () => _format = _ShareFormat.withTranslation),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FormatChip(
                            label: 'Full citation',
                            active: _format == _ShareFormat.fullCitation,
                            saffron: saffron,
                            saffronGlow: saffronGlow,
                            text2: text2,
                            dividerSoft: dividerSoft,
                            onTap: () => setState(
                                () => _format = _ShareFormat.fullCitation),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Preview card.
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: divider),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: -16,
                            child: _SharePreviewBinding(
                              divider: divider,
                              saffron: saffron,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '‖ ${v.scripture.displayNameSafe} · '
                                '$chapterDeva·$coordDeva ‖',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: Fonts.deva,
                                  fontFamilyFallback: AppFontFallback.deva,
                                  fontSize: 12,
                                  color: saffron,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                v.sanskrit.trim(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: Fonts.deva,
                                  fontFamilyFallback: AppFontFallback.deva,
                                  fontSize: 16,
                                  height: 1.6,
                                  color: cream,
                                ),
                              ),
                              if (_format !=
                                      _ShareFormat.sanskritOnly &&
                                  (v.english?.trim().isNotEmpty ?? false)) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '"${v.english!.trim()}"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: Fonts.serif,
                                    fontFamilyFallback: AppFontFallback.latin,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: text2,
                                  ),
                                ),
                              ],
                              if (_format == _ShareFormat.fullCitation) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'sanatanguide.app/'
                                  '${v.scripture.shortCode}/'
                                  '${v.chapterNum}/${v.verseNum}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: Fonts.sans,
                                    fontFamilyFallback: AppFontFallback.latin,
                                    fontSize: 10,
                                    letterSpacing: 0.06 * 10,
                                    color: text3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dividerSoft)),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    _SheetGhostBtn(
                      label: 'COPY TEXT',
                      color: text2,
                      onTap: () => widget.onCopy(_buildShareText()),
                    ),
                    const SizedBox(width: 8),
                    _SheetFilledBtn(
                      label: 'SHARE',
                      bg: saffron,
                      fg: onSaffron,
                      enabled: true,
                      onTap: () => widget.onShare(_buildShareText()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.active,
    required this.saffron,
    required this.saffronGlow,
    required this.text2,
    required this.dividerSoft,
    required this.onTap,
  });
  final String label;
  final bool active;
  final Color saffron;
  final Color saffronGlow;
  final Color text2;
  final Color dividerSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: active ? saffronGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? saffron : dividerSoft),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: Fonts.sans,
            fontFamilyFallback: AppFontFallback.latin,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.04 * 10.5,
            color: active ? saffron : text2,
          ),
        ),
      ),
    );
  }
}

/// `.share-binding` — line · saffron diamond · line. Sits at the top of
/// the share preview card.
class _SharePreviewBinding extends StatelessWidget {
  const _SharePreviewBinding({required this.divider, required this.saffron});
  final Color divider;
  final Color saffron;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: divider)),
          const SizedBox(width: 10),
          Transform.rotate(
            angle: 0.785,
            child: Container(width: 5, height: 5, color: saffron),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: divider)),
        ],
      ),
    );
  }
}
