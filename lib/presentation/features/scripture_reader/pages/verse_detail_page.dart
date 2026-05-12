import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/core/utils/explain_question.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/app_database_provider.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart'
    as font_prefs;
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

/// Strips Vedic svara / combining marks for a cleaner reading pass.
String stripVedicAccents(String text) => text
    .replaceAll(RegExp(r'[॒॑᳐-᳿ऀ-ं]'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

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
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
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
                      ? AppText.devUI(color: text3, size: 12)
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
              child: Icon(Icons.ios_share_rounded, size: 18, color: text1),
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
              icon: Icons.translate_rounded,
              label: 'Translation',
              text: text2,
              active: translationOn,
              activeBg: saffronGlow,
              activeColor: saffron,
              onTap: enabled ? onToggleTranslation : null,
            ),
            _UtilAction(
              icon: Icons.headphones_rounded,
              label: 'Listen',
              text: text2,
              onTap: null, // audio not bundled yet
            ),
            _UtilAction(
              icon: Icons.edit_note_rounded,
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
    required this.icon,
    required this.label,
    required this.text,
    this.active = false,
    this.activeBg,
    this.activeColor,
    required this.onTap,
  });

  final IconData icon;
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
                Icon(icon, size: 16, color: c),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _NotesSheet(
        controller: _noteController,
        focusNode: _noteFocusNode,
        isDark: widget.isDark,
        onChanged: _onNoteChanged,
        onDone: () {
          _saveTimer?.cancel();
          unawaited(_persistNoteFor(verse, _noteController.text));
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
    AnalyticsService.verseShared(verse.id);
    final coord = '${verse.scripture.displayNameSafe} '
        '${verse.chapterNum}.${verse.verseNum}';
    final body = StringBuffer()
      ..writeln(coord)
      ..writeln()
      ..writeln(verse.sanskrit.trim());
    final translation = verse.english;
    if (translation != null && translation.trim().isNotEmpty) {
      body
        ..writeln()
        ..writeln(translation.trim());
    }
    Share.share(body.toString());
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
                        style: AppText.commentary(
                          color: isDark ? DColors.text2 : LColors.text2,
                          size: 14 * sanskritScale,
                        ).copyWith(height: 1.75),
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.xxxl),
                  _SectionRule(label: 'Translation', isDark: isDark),
                  const SizedBox(height: Spacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24 + 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (verse.english ?? '').trim(),
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
                                color: isDark ? DColors.text3 : LColors.text3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
    final vPad = compressed ? 20.0 : 28.0;

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
                _SanskritWords(
                  text: stripVedicAccents(verse.sanskrit),
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
          Positioned(top: 0, left: 0, right: 0, child: BindingLine(isDark: isDark)),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BindingLine(isDark: isDark),
          ),
          if (selectedWord != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 4,
              child: Center(
                child: _WordCallout(word: selectedWord!, isDark: isDark),
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
    final meanings = wordMeanings ?? const <WordMeaning>[];
    if (meanings.isEmpty) {
      // No word breakdown — render the whole verse as one block (keeps the
      // manuscript line breaks present in [text]).
      return Text(text, textAlign: TextAlign.center, style: base, locale: const Locale('sa'));
    }

    final byWord = <String, WordMeaning>{
      for (final wm in meanings) wm.word.trim(): wm,
    };

    final children = <Widget>[];
    for (final token in text.split(RegExp(r'\s+'))) {
      if (token.isEmpty) continue;
      final core = token.replaceAll(_danda, '');
      final tail = token.substring(core.length);
      final wm = byWord[core];
      if (wm == null) {
        children.add(Text(token, style: base, locale: const Locale('sa')));
        continue;
      }
      final selected = wm == selectedWord;
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

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 7,
      runSpacing: 2,
      children: children,
    );
  }
}

class _WordCallout extends StatelessWidget {
  const _WordCallout({required this.word, required this.isDark});

  final WordMeaning word;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final cream = isDark ? DColors.cream : LColors.cream;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text2 = isDark ? DColors.text2 : LColors.text2;

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
          Text(word.word,
              style: AppText.sanskritBody(color: cream, size: 18)
                  .copyWith(height: 1.3)),
          if (word.transliteration?.trim().isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(word.transliteration!.trim(),
                style: AppText.commentary(color: saffron, size: 12)),
          ],
          const SizedBox(height: 8),
          Text(word.meaning,
              style: AppText.translation(color: text2, size: 13)
                  .copyWith(height: 1.5)),
          const SizedBox(height: 10),
          Container(height: 1, color: dividerSoft),
        ],
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
                  Icon(Icons.chevron_right_rounded, size: 18, color: text3),
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
                    top: 0, left: 0, right: 0, child: BindingLine(isDark: isDark)),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BindingLine(isDark: isDark)),
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
            Icon(Icons.chevron_right_rounded, size: 18, color: text3),
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

class _NotesSheet extends StatelessWidget {
  const _NotesSheet({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onDone,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bg = isDark ? DColors.bg : LColors.bg;
    final surface = isDark ? DColors.surface : LColors.surface;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: bg,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Your reflection',
                    style: AppText.sectionName(color: text1)),
                const Spacer(),
                TextButton(
                  onPressed: onDone,
                  style: TextButton.styleFrom(foregroundColor: saffron),
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 240),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                onChanged: onChanged,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: AppText.translation(color: text1, size: 14.5),
                decoration: InputDecoration(
                  hintText: 'What does this verse mean to you?',
                  hintStyle: AppText.translation(color: text3, size: 14.5),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Radii.card),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
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
      child: Icon(
        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        size: 18,
        color: isBookmarked ? saffron : text1,
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
