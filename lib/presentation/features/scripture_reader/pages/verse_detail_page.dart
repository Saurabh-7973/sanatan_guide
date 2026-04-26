import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/analytics_service.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/services/review_service.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/data/datasources/local/daos/bookmarks_dao.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_browser_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/chapter_progress_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/reading_mode_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/commentaries_block.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/gutter_rail.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/sanctum_card.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/share_card_generator.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/share_card_widget.dart';
import 'package:sanatan_guide/presentation/features/settings/providers/font_size_provider.dart'
    as font_prefs;
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

/// Strips Vedic svara / combining marks for a cleaner reading pass.
String stripVedicAccents(String text) {
  return text
      .replaceAll(RegExp(r'[\u0951\u0952\u1CD0-\u1CFF\u0900-\u0902]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class VerseDetailPage extends ConsumerStatefulWidget {
  const VerseDetailPage({super.key, required this.verseId});

  final String verseId;

  @override
  ConsumerState<VerseDetailPage> createState() => _VerseDetailPageState();
}

class _VerseDetailPageState extends ConsumerState<VerseDetailPage> {
  late String _currentVerseId;
  String? _lastKnownLabel;
  final GlobalKey _shareCardKey = GlobalKey();

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/browse');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentVerseId = widget.verseId;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VerseDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verseId != widget.verseId) {
      setState(() => _currentVerseId = widget.verseId);
    }
  }

  void _goToVerse(String verseId) {
    setState(() => _currentVerseId = verseId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verseDetailProvider(_currentVerseId));

    return state.when(
      loading: () => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => _handleBack(context),
              ),
              title: Text(_lastKnownLabel ?? ''),
              centerTitle: true,
            ),
            const SliverFillRemaining(
              child: VerseDetailShimmer(),
            ),
          ],
        ),
      ),
      error: (_, __) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () => _handleBack(context),
              ),
            ),
            const SliverFillRemaining(child: ErrorStateWidget()),
          ],
        ),
      ),
      data: (either) => either.fold(
        (failure) => Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                  onPressed: () => _handleBack(context),
                ),
              ),
              SliverFillRemaining(
                child: ErrorStateWidget(message: failure.message),
              ),
            ],
          ),
        ),
        (verse) {
          _lastKnownLabel = getVerseLabel(verse);
          return _VerseScaffold(
          verse: verse,
          currentVerseId: _currentVerseId,
          onGoToVerse: _goToVerse,
          onBack: () => _handleBack(context),
          shareCardKey: _shareCardKey,
        );
        },
      ),
    );
  }
}

// ── Verse scaffold with collapsing app bar ────────────────────────────────

class _VerseScaffold extends ConsumerStatefulWidget {
  const _VerseScaffold({
    required this.verse,
    required this.currentVerseId,
    required this.onGoToVerse,
    required this.onBack,
    required this.shareCardKey,
  });

  final Verse verse;
  final String currentVerseId;
  final void Function(String verseId) onGoToVerse;
  final VoidCallback onBack;
  final GlobalKey shareCardKey;

  @override
  ConsumerState<_VerseScaffold> createState() => _VerseScaffoldState();
}

class _VerseScaffoldState extends ConsumerState<_VerseScaffold> {
  late final TextEditingController _noteController;
  Timer? _saveTimer;
  late final FocusNode _noteFocusNode;
  bool _plainSanskritReading = false;
  bool _wordMeaningsExpanded = false;
  bool _chapterJustCompleted = false;
  bool _showTranslit = false;

  // Temple mode — double-tap to hide chrome
  bool _templeMode = false;
  bool _showTempleHint = false;
  Timer? _hintTimer;
  static bool _hintShownThisSession = false;

  void _toggleTempleMode() {
    setState(() => _templeMode = !_templeMode);
    if (_templeMode) {
      try { Haptics.vibrate(HapticsType.light); } catch (_) {}
    }
  }

  bool _canStripVedicAccents(Verse v) =>
      v.id.startsWith('RV.') || v.id.startsWith('YV.');

  bool _isTirukkuralVerse(Verse v) => v.id.toUpperCase().startsWith('TK.');

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.verse.noteText ?? '');
    _noteFocusNode = FocusNode();
    _noteFocusNode.addListener(() {
      if (!_noteFocusNode.hasFocus) {
        _saveTimer?.cancel();
        unawaited(_persistNote(_noteController.text));
      }
    });
    _recordReading(widget.verse);

    if (!_hintShownThisSession) {
      _hintShownThisSession = true;
      _showTempleHint = true;
      _hintTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showTempleHint = false);
      });
    }
  }

  @override
  void didUpdateWidget(covariant _VerseScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verse.id != widget.verse.id) {
      _saveTimer?.cancel();
      unawaited(_persistNoteForVerse(oldWidget.verse, _noteController.text));
      _noteController.text = widget.verse.noteText ?? '';
      _plainSanskritReading = false;
      _wordMeaningsExpanded = false;
      _showTranslit = false;
      _templeMode = false;
      _recordReading(widget.verse);
    }
  }

  void _recordReading(Verse verse) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await StreakService.recordReadingToday();
      await StreakService.saveLastReadVerse(
        verse.id,
        verse.scripture.code,
      );
      AnalyticsService.verseRead(
        verseId: verse.id,
        scripture: verse.scripture.code,
        chapter: verse.chapterNum,
        verse: verse.verseNum,
      );
      if (mounted) {
        Future.microtask(() {
          if (mounted) {
            ref.invalidate(currentStreakProvider);
            ref.invalidate(readHistoryProvider);
            ref.invalidate(lastReadVerseProvider);
          }
        });
      }
      try {
        final repo = await ref.read(scriptureRepositoryProvider.future);
        final wasUnread = verse.readCount == 0;
        await repo.markVerseRead(verse.id);
        if (mounted) {
          ref.invalidate(
            chapterReadCountProvider(
              verse.scripture.code,
              verse.chapterNum,
              verse.bookNum,
            ),
          );
        }
        // Check chapter completion only when this was a previously unread verse.
        if (wasUnread && !_chapterJustCompleted) {
          final total = await repo.getChapterVerseCount(
            scriptureCode: verse.scripture.code,
            chapterNum: verse.chapterNum,
            bookNum: verse.bookNum,
          );
          final readCount = await repo.getChapterReadCount(
            scriptureCode: verse.scripture.code,
            chapterNum: verse.chapterNum,
            bookNum: verse.bookNum,
          );
          if (total > 0 && readCount >= total) {
            _chapterJustCompleted = true;
          }
        }
      } catch (e, st) {
        AppLogger.instance.w('markVerseRead failed for ${verse.id}', e, st);
      }
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _hintTimer?.cancel();
    _noteFocusNode.dispose();
    _noteController.dispose();
    // Fire review prompt after leaving the reader — never during active reading.
    if (_chapterJustCompleted) {
      unawaited(
        ReviewService.maybeRequestReview(ReviewTrigger.chapterCompleted),
      );
    }
    super.dispose();
  }

  void _onNoteChanged(String value) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      unawaited(_persistNote(value));
    });
  }

  Future<void> _persistNoteForVerse(Verse v, String value) async {
    try {
      final repo = await ref.read(scriptureRepositoryProvider.future);
      final trimmed = value.trim().isEmpty ? null : value.trim();
      await repo.updateVerseNote(v.id, trimmed);
      if (mounted) {
        ref.invalidate(verseDetailProvider(v.id));
        ref.invalidate(
          chapterVersesProvider(
            v.scripture.code,
            v.chapterNum,
            v.bookNum,
          ),
        );
      }
    } catch (e, st) {
      AppLogger.instance.w('persistNote failed for ${v.id}', e, st);
    }
  }

  Future<void> _persistNote(String value) async {
    await _persistNoteForVerse(widget.verse, value);
  }

  void _showNotesSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _NotesBottomSheet(
        controller: _noteController,
        focusNode: _noteFocusNode,
        onChanged: _onNoteChanged,
        onDone: () {
          _saveTimer?.cancel();
          unawaited(_persistNote(_noteController.text));
          _noteFocusNode.unfocus();
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verse = widget.verse;
    final adjacent = ref.watch(adjacentVerseIdsProvider(verse.id));
    final prevId = adjacent.asData?.value.prevId;
    final nextId = adjacent.asData?.value.nextId;
    final hasNote = _noteController.text.trim().isNotEmpty ||
        (verse.noteText != null && verse.noteText!.isNotEmpty);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saff = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final muted = isDark
        ? AppColors.textSecondaryOnDark
        : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: widget.onBack,
        ),
        actions: [
          _BookmarkAction(verseId: verse.id),
          if (GeminiService.isEnabled)
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'Ask about this verse',
              color: AppColors.warmGrey50,
              onPressed: () => context.push(
                '/browse/${verse.scripture.code}/verse/${verse.id}/chat',
              ),
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share verse',
            onPressed: () {
              AnalyticsService.verseShared(verse.id);
              ShareCardGenerator.captureAndShare(
                repaintKey: widget.shareCardKey,
                verse: verse,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Transform.translate(
            offset: const Offset(-10000, 0),
            child: RepaintBoundary(
              key: widget.shareCardKey,
              child: ShareCardWidget(verse: verse),
            ),
          ),

          if (_showTempleHint)
            Positioned(
              bottom: 96,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showTempleHint ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusChip),
                      ),
                      child: const Text(
                        'Double-tap to enter Temple mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          GestureDetector(
            onDoubleTap: _toggleTempleMode,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -300 &&
                  nextId != null) {
                try {
                  Haptics.vibrate(HapticsType.light);
                } catch (_) {}
                widget.onGoToVerse(nextId);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GutterRail(verse: verse),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    child: _SanctumContent(
                      verse: verse,
                      isDark: isDark,
                      saff: saff,
                      muted: muted,
                      plainSanskritReading: _plainSanskritReading,
                      canStripAccents: _canStripVedicAccents(verse),
                      isTirukkural: _isTirukkuralVerse(verse),
                      onToggleAccents: () => setState(() {
                        _plainSanskritReading = !_plainSanskritReading;
                      }),
                      wordMeaningsExpanded: _wordMeaningsExpanded,
                      onToggleWordMeanings: () => setState(() {
                        _wordMeaningsExpanded = !_wordMeaningsExpanded;
                      }),
                      showTranslitOverride: _showTranslit,
                      onToggleTranslit: () => setState(() {
                        _showTranslit = !_showTranslit;
                      }),
                      noteController: _noteController,
                      onNoteChanged: _onNoteChanged,
                      onOpenNotes: _showNotesSheet,
                      hasNote: hasNote,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedOpacity(
        opacity: _templeMode ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        child: IgnorePointer(
          ignoring: _templeMode,
          child: _VerseNavBar(
            verse: verse,
            prevId: prevId,
            nextId: nextId,
            onGoToVerse: widget.onGoToVerse,
            onOpenNotes: _showNotesSheet,
            hasNote: hasNote,
          ),
        ),
      ),
    );
  }
}

// ── Sanctum right-column content ─────────────────────────────────────────

class _SanctumContent extends ConsumerWidget {
  const _SanctumContent({
    required this.verse,
    required this.isDark,
    required this.saff,
    required this.muted,
    required this.plainSanskritReading,
    required this.canStripAccents,
    required this.isTirukkural,
    required this.onToggleAccents,
    required this.wordMeaningsExpanded,
    required this.onToggleWordMeanings,
    required this.showTranslitOverride,
    required this.onToggleTranslit,
    required this.noteController,
    required this.onNoteChanged,
    required this.onOpenNotes,
    required this.hasNote,
  });

  final Verse verse;
  final bool isDark;
  final Color saff;
  final Color muted;
  final bool plainSanskritReading;
  final bool canStripAccents;
  final bool isTirukkural;
  final VoidCallback onToggleAccents;
  final bool wordMeaningsExpanded;
  final VoidCallback onToggleWordMeanings;
  final bool showTranslitOverride;
  final VoidCallback onToggleTranslit;
  final TextEditingController noteController;
  final ValueChanged<String> onNoteChanged;
  final VoidCallback onOpenNotes;
  final bool hasNote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(readingModeProvider);
    final fontSize = ref.watch(font_prefs.fontSizeProvider);
    final showSanskrit =
        mode == ReadingMode.all || mode == ReadingMode.sanskrit;
    final showTranslit = mode == ReadingMode.all || showTranslitOverride;
    final showTranslation =
        mode == ReadingMode.all || mode == ReadingMode.translationOnly;
    const saffFaint = AppColors.saffronFaint;
    final borderC = isDark ? AppColors.borderDark : AppColors.border;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TranslationToggle(),
          const SizedBox(height: AppSpacing.md),

          // Scripture chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: saffFaint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: saff,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  verse.scripture.displayName,
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: saff,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Sanskrit / Tamil
          if (showSanskrit && verse.sanskrit.isNotEmpty) ...[
            if (isTirukkural)
              _TamilInline(verse: verse, isDark: isDark)
            else
              _SanskritInline(
                verse: verse,
                plain: plainSanskritReading,
                canStrip: canStripAccents,
                onToggleAccents: onToggleAccents,
                fontSize: fontSize,
                isDark: isDark,
              ),
            const SizedBox(height: AppSpacing.sm),
          ],

          if (showSanskrit &&
              verse.sanskrit.isNotEmpty &&
              canStripAccents)
            Text(
              plainSanskritReading
                  ? 'Tap Sanskrit to show Vedic accents'
                  : 'Tap Sanskrit for plain reading',
              style: TextStyle(
                fontSize: 11,
                color: muted.withValues(alpha: 0.6),
              ),
            ),

          if (!showTranslit &&
              mode != ReadingMode.all &&
              verse.transliteration != null &&
              verse.transliteration!.isNotEmpty &&
              showSanskrit) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: onToggleTranslit,
              child: Text(
                showTranslitOverride
                    ? 'Hide pronunciation'
                    : 'Show pronunciation',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 13,
                  color: saff,
                  decoration: TextDecoration.underline,
                  decorationColor: saff,
                ),
              ),
            ),
          ],

          if (showTranslit &&
              verse.transliteration != null &&
              verse.transliteration!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(width: 20, height: 1, color: borderC),
                const SizedBox(width: 8),
                Text(
                  'TRANSLITERATION',
                  style: TextStyle(
                    fontFamily: 'Lora',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              verse.transliteration!,
              style: TextStyle(
                fontFamily: 'Lora',
                fontStyle: FontStyle.italic,
                fontSize: fontSize,
                height: 1.7,
                color: isDark
                    ? const Color(0xFFB8A88E)
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
          ],

          // Translation card
          if (showTranslation &&
              ((verse.english != null && verse.english!.isNotEmpty) ||
                  (verse.hindi != null && verse.hindi!.isNotEmpty)))
            SanctumCard(
              title: 'Translation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (verse.english != null && verse.english!.isNotEmpty)
                    Text(
                      verse.english!,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: fontSize,
                        height: 1.65,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.textPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  if (verse.hindi != null && verse.hindi!.isNotEmpty) ...[
                    if (verse.english != null &&
                        verse.english!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Divider(height: 1, color: borderC),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(
                      'HINDI',
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      verse.hindi!,
                      style: TextStyle(
                        fontFamily: 'NotoSansDevanagari',
                        fontSize: math.max(15.0, fontSize),
                        height: 1.7,
                        color: isDark
                            ? AppColors.textOnDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

          if (!showTranslation &&
              (verse.english != null && verse.english!.isNotEmpty)) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => ref
                  .read(readingModeProvider.notifier)
                  .setMode(ReadingMode.all),
              child: Text(
                'Translation hidden · tap to show',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 12,
                  color: saff.withValues(alpha: 0.7),
                  decoration: TextDecoration.underline,
                  decorationColor: saff.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],

          // Word-by-word card
          if (verse.wordMeanings != null && verse.wordMeanings!.isNotEmpty)
            SanctumCard(
              title: 'Word by Word',
              collapsible: true,
              initiallyExpanded: wordMeaningsExpanded,
              child: Column(
                children: verse.wordMeanings!.map((wm) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        SizedBox(
                          width: 86,
                          child: Text(
                            wm.word,
                            style: TextStyle(
                              fontFamily: 'TiroDevanagari',
                              fontSize: 17,
                              color: isDark
                                  ? AppColors.sanskritTextOnDark
                                  : AppColors.sanskritText,
                            ),
                          ),
                        ),
                        Text('·',
                            style: TextStyle(color: muted, fontSize: 13)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            wm.meaning,
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: fontSize,
                              color: isDark
                                  ? AppColors.textOnDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Your Reflection card
          SanctumCard(
            title: 'Your Reflection',
            headerAction: GestureDetector(
              onTap: onOpenNotes,
              child: Text(
                'Edit',
                style: TextStyle(
                  fontFamily: 'Lora',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: saff,
                ),
              ),
            ),
            child: noteController.text.trim().isEmpty
                ? Text(
                    'Tap Edit to add your reflection on this verse.',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      height: 1.7,
                      color: muted,
                    ),
                  )
                : Text(
                    noteController.text.trim(),
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      height: 1.7,
                      color: isDark
                          ? AppColors.textOnDark
                          : AppColors.textPrimary,
                    ),
                  ),
          ),

          // Ask the Guide row
          if (GeminiService.isEnabled) ...[
            GestureDetector(
              onTap: () => context.push(
                '/browse/${verse.scripture.code}/verse/${verse.id}/chat',
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: saffFaint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: saff.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_outlined, color: saff, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask the Guide',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textOnDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Context, meaning, Sanskrit terms',
                            style: TextStyle(
                              fontFamily: 'Lora',
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: saff, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          CommentariesBlock(verseId: verse.id),

          const SizedBox(height: AppSpacing.xl),
          Text(
            'Swipe left or right to navigate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: muted.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _SanskritInline extends StatelessWidget {
  const _SanskritInline({
    required this.verse,
    required this.plain,
    required this.canStrip,
    required this.onToggleAccents,
    required this.fontSize,
    required this.isDark,
  });

  final Verse verse;
  final bool plain;
  final bool canStrip;
  final VoidCallback onToggleAccents;
  final double fontSize;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text =
        plain && canStrip ? stripVedicAccents(verse.sanskrit) : verse.sanskrit;
    final color =
        isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText;
    final scale = fontSize / font_prefs.kDefaultFontSize;

    return GestureDetector(
      onTap: canStrip ? onToggleAccents : null,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'TiroDevanagari',
          fontSize: 24 * scale,
          height: 2.0,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _TamilInline extends StatelessWidget {
  const _TamilInline({required this.verse, required this.isDark});

  final Verse verse;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      verse.sanskrit,
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 24,
        height: 2.0,
        color: isDark ? AppColors.sanskritTextOnDark : AppColors.sanskritText,
      ),
    );
  }
}

// ── Bottom verse navigation bar ───────────────────────────────────────────

class _VerseNavBar extends StatelessWidget {
  const _VerseNavBar({
    required this.verse,
    required this.prevId,
    required this.nextId,
    required this.onGoToVerse,
    required this.onOpenNotes,
    required this.hasNote,
  });

  final Verse verse;
  final String? prevId;
  final String? nextId;
  final void Function(String) onGoToVerse;
  final VoidCallback onOpenNotes;
  final bool hasNote;

  @override
  Widget build(BuildContext context) {
    final hasPrev = prevId != null;
    final hasNext = nextId != null;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: (isDark ? AppColors.dividerDark : AppColors.divider)
                .withValues(alpha: 0.5),
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.xs,
        bottom: bottomPad > 0 ? bottomPad : AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Prev button
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            tooltip: 'Previous verse',
            color: hasPrev ? AppColors.saffron : AppColors.textSecondary.withValues(alpha: 0.3),
            onPressed: hasPrev
                ? () {
                    try {
                      Haptics.vibrate(HapticsType.light);
                    } catch (_) {}
                    onGoToVerse(prevId!);
                  }
                : null,
          ),

          // Center: verse position label
          Expanded(
            child: Text(
              'Verse ${verse.verseNum}',
              textAlign: TextAlign.center,
              style: context.ts.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Notes button
          IconButton(
            icon: Badge(
              isLabelVisible: hasNote,
              smallSize: 8,
              backgroundColor: AppColors.saffron,
              child: const Icon(Icons.edit_outlined, size: 20),
            ),
            tooltip: 'Your reflection',
            color: AppColors.textSecondary,
            onPressed: onOpenNotes,
          ),

          // Next button
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            tooltip: 'Next verse',
            color: hasNext ? AppColors.saffron : AppColors.textSecondary.withValues(alpha: 0.3),
            onPressed: hasNext
                ? () {
                    try {
                      Haptics.vibrate(HapticsType.light);
                    } catch (_) {}
                    onGoToVerse(nextId!);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Translation toggle pill (replaces SegmentedButton) ───────────────────

class _TranslationToggle extends ConsumerWidget {
  const _TranslationToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(readingModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showTranslation =
        mode == ReadingMode.all || mode == ReadingMode.translationOnly;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              final next =
                  showTranslation ? ReadingMode.sanskrit : ReadingMode.all;
              ref.read(readingModeProvider.notifier).setMode(next);
              AnalyticsService.readingModeChanged(next.key);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevated : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showTranslation
                        ? Icons.translate_rounded
                        : Icons.translate_rounded,
                    size: 14,
                    color: showTranslation
                        ? AppColors.saffron
                        : AppColors.warmGrey50,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    showTranslation ? 'Translation on' : 'Translation off',
                    style: context.ts.labelSmall.copyWith(
                      color: showTranslation
                          ? AppColors.saffron
                          : AppColors.warmGrey50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notes bottom sheet ────────────────────────────────────────────────────

class _NotesBottomSheet extends StatelessWidget {
  const _NotesBottomSheet({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onDone,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.md,
          AppSpacing.pagePadding,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.dividerDark
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text(
                  'Your reflection',
                  style: context.ts.labelLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: onDone,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.saffron,
                  ),
                  child: const Text('Done'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 120,
                maxHeight: 240,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                onChanged: onChanged,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: context.ts.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'What does this verse mean to you?',
                  hintStyle: context.ts.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.surfaceElevated
                      : AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bookmark action ───────────────────────────────────────────────────────

class _BookmarkAction extends ConsumerWidget {
  const _BookmarkAction({required this.verseId});

  final String verseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(verseId));

    return isBookmarkedAsync.when(
      loading: () => const IconButton(
        icon: Icon(Icons.bookmark_border_rounded),
        tooltip: 'Bookmark verse',
        onPressed: null,
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (isBookmarked) => _BookmarkButton(
        verseId: verseId,
        isBookmarked: isBookmarked,
      ),
    );
  }
}

class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({
    required this.verseId,
    required this.isBookmarked,
  });

  final String verseId;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: isBookmarked ? AppColors.saffron : AppColors.warmGrey50,
      ).animate(key: ValueKey(isBookmarked)).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
      tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark verse',
      onPressed: () async {
        try {
          await Haptics.vibrate(HapticsType.light);
        } catch (_) {}
        final BookmarksDao dao = await ref.read(bookmarksDaoProvider.future);
        await dao.toggleBookmark(verseId);
        if (!isBookmarked) AnalyticsService.verseBookmarked(verseId);
      },
    );
  }
}
