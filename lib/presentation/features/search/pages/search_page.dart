import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/utils/coordinate_parser.dart';
import 'package:sanatan_guide/core/utils/devanagari.dart';
import 'package:sanatan_guide/core/utils/nav_logger.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/search/providers/recent_searches_provider.dart';
import 'package:sanatan_guide/presentation/features/search/providers/search_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with NavLoggerMixin<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final Set<String> _expandedGroups = <String>{};

  @override
  String get screenName => 'SearchPage';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    if (_controller.text != value) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    ref.read(searchQueryProvider.notifier).update(value);
  }

  Future<void> _commitRecent(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    await ref.read(recentSearchesProvider.notifier).add(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(intensity: 0.6),
          SafeArea(
            child: Column(
              children: [
                _SearchTopBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  isDark: isDark,
                  onChanged: _setQuery,
                  onSubmitted: _commitRecent,
                  onClear: () => _setQuery(''),
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                Expanded(
                  child: _SearchBody(
                    query: query,
                    isDark: isDark,
                    expandedGroups: _expandedGroups,
                    onToggleGroup: (key) => setState(() {
                      if (!_expandedGroups.add(key)) {
                        _expandedGroups.remove(key);
                      }
                    }),
                    onPickRecent: (q) {
                      _setQuery(q);
                      _commitRecent(q);
                    },
                    onPandit: () => context.push(AppRoutes.chatGeneral),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({
    required this.controller,
    required this.focusNode,
    required this.isDark,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isDark;
  final void Function(String) onChanged;
  final void Function(String) onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final activeBorder = saffron.withValues(alpha: 0.45);
    final activeFill = saffron.withValues(alpha: isDark ? 0.06 : 0.04);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Row(
        children: [
          IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            color: text1,
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: AnimatedBuilder(
              animation: focusNode,
              builder: (context, _) {
                final hasFocus = focusNode.hasFocus;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: hasFocus ? activeFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: hasFocus ? activeBorder : divider,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: hasFocus ? saffron : text3,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          textInputAction: TextInputAction.search,
                          // Mobile's default onTapOutside keeps focus; force
                          // unfocus so the focus-driven border resets when
                          // the user taps a result or empty space.
                          onTapOutside: (_) => focusNode.unfocus(),
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontSize: 14,
                            letterSpacing: 0.005 * 14,
                            color: text1,
                          ),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            // The app's inputDecorationTheme supplies a
                            // filled OutlineInputBorder; every border state
                            // must be overridden or the focused/enabled
                            // border leaks a second box inside the pill.
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            hintText:
                                'Search verse, phrase, or coordinate…',
                            hintStyle: TextStyle(
                              fontFamily: Fonts.sans,
                              fontSize: 14,
                              color: text3,
                            ),
                          ),
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onClear,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.cancel_rounded,
                              size: 16,
                              color: text3,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Body — empty / coord / searching / results / error
// ─────────────────────────────────────────────────────────────────────────

class _SearchBody extends ConsumerWidget {
  const _SearchBody({
    required this.query,
    required this.isDark,
    required this.expandedGroups,
    required this.onToggleGroup,
    required this.onPickRecent,
    required this.onPandit,
  });

  final String query;
  final bool isDark;
  final Set<String> expandedGroups;
  final void Function(String key) onToggleGroup;
  final void Function(String) onPickRecent;
  final VoidCallback onPandit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return _EmptyBody(
        isDark: isDark,
        onPickRecent: onPickRecent,
        onPandit: onPandit,
      );
    }

    final coord = parseScriptureCoordinate(trimmed);
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => _SearchingBody(
        coord: coord,
        isDark: isDark,
      ),
      error: (e, _) => ErrorStateWidget(
        onRetry: () => ref.invalidate(searchResultsProvider),
      ),
      data: (either) => either.fold(
        (failure) => _ErrorMessage(
          message: failure.message,
          isDark: isDark,
        ),
        (verses) => _ResultsBody(
          coord: coord,
          verses: verses,
          query: trimmed,
          isDark: isDark,
          expandedGroups: expandedGroups,
          onToggleGroup: onToggleGroup,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────

class _EmptyBody extends ConsumerWidget {
  const _EmptyBody({
    required this.isDark,
    required this.onPickRecent,
    required this.onPandit,
  });

  final bool isDark;
  final void Function(String) onPickRecent;
  final VoidCallback onPandit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentSearchesProvider);
    final recents = recentAsync.value ?? const <String>[];

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (recents.isNotEmpty) ...[
          _SectionLabel(text: 'RECENT', isDark: isDark),
          for (final q in recents.take(5))
            _SuggestRow(
              icon: Icons.history_rounded,
              title: q,
              titleIsDeva: _isMostlyDevanagari(q),
              meta: 'Tap to search again',
              isDark: isDark,
              onTap: () => onPickRecent(q),
              showArrow: true,
            ),
        ],
        _SectionLabel(text: 'SEARCH ANY WAY', isDark: isDark),
        _SuggestRow(
          icon: Icons.notes_rounded,
          title: 'By phrase',
          meta: '"you have a right to action…"',
          isDark: isDark,
          onTap: null,
        ),
        _SuggestRow(
          icon: Icons.translate_rounded,
          title: 'कर्म',
          titleIsDeva: true,
          meta: 'By Sanskrit word — Devanāgarī or IAST',
          isDark: isDark,
          onTap: null,
        ),
        _SuggestRow(
          icon: Icons.bookmark_outline_rounded,
          title: 'By coordinate',
          meta: '"BG 2.47" · "Gita 11.37" · "Katha 1.2.18"',
          isDark: isDark,
          onTap: null,
        ),
        _SuggestRow(
          icon: Icons.help_outline_rounded,
          title: 'By question',
          meta: '"What is dharma?" · "How to find peace?"',
          isDark: isDark,
          onTap: null,
          isLast: true,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
          child: _PanditCta(isDark: isDark, onTap: onPandit),
        ),
      ],
    );
  }

  bool _isMostlyDevanagari(String s) {
    var deva = 0;
    for (final r in s.runes) {
      if (r >= 0x0900 && r <= 0x097F) deva++;
    }
    return deva > s.length / 2;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.28 * 9.5,
              color: text3,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: divider)),
        ],
      ),
    );
  }
}

class _SuggestRow extends StatelessWidget {
  const _SuggestRow({
    required this.icon,
    required this.title,
    required this.meta,
    required this.isDark,
    required this.onTap,
    this.titleIsDeva = false,
    this.showArrow = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final bool titleIsDeva;
  final String meta;
  final bool isDark;
  final VoidCallback? onTap;
  final bool showArrow;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;

    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: divider, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 22,
              height: 22,
              child: Icon(icon, size: 18, color: text3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: titleIsDeva ? Fonts.deva : Fonts.serif,
                    fontSize: titleIsDeva ? 15 : 14.5,
                    height: 1.35,
                    color: text1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  meta,
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.04 * 10.5,
                    color: text3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showArrow)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: text3.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: onTap,
        child: body,
      ),
    );
  }
}

class _PanditCta extends StatelessWidget {
  const _PanditCta({required this.isDark, required this.onTap});
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // AI feature — hidden until a GEMINI_API_KEY is provided, same gate as
    // the verse-detail "Explain this verse" CTA.
    if (!GeminiService.isEnabled) return const SizedBox.shrink();

    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final divider = isDark ? DColors.divider : LColors.divider;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: divider, width: 1),
          ),
          child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: saffron.withValues(alpha: 0.12),
            ),
            child: Text(
              'ॐ',
              style: TextStyle(
                fontFamily: Fonts.deva,
                fontSize: 16,
                color: saffron,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ASK THE PANDIT',
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.24 * 9,
                    color: saffron,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Pose a question. Receive guidance with verse citations.',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontStyle: FontStyle.italic,
                    fontSize: 13.5,
                    height: 1.4,
                    color: text1,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            size: 14,
            color: saffron.withValues(alpha: 0.7),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Searching state
// ─────────────────────────────────────────────────────────────────────────

class _SearchingBody extends StatelessWidget {
  const _SearchingBody({required this.coord, required this.isDark});

  final ScriptureCoordinate? coord;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final divider = isDark ? DColors.divider : LColors.divider;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final shimmer = saffron.withValues(alpha: 0.08);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (coord != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: _CoordResolvedCard(coord: coord!, isDark: isDark),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
            child: Text(
              'OR RELATED VERSES',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.24 * 9.5,
                color: text3,
              ),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
            child: Row(
              children: [
                Text(
                  'SEARCHING ACROSS 31 SCRIPTURES',
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.24 * 9.5,
                    color: text3,
                  ),
                ),
                const SizedBox(width: 8),
                _TypingDots(saffron: saffron),
              ],
            ),
          ),
        ],
        for (var g = 0; g < 2; g++) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: divider, width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ShimmerBar(width: 140, height: 12, color: shimmer),
                    _ShimmerBar(width: 60, height: 9, color: shimmer),
                  ],
                ),
              ),
            ),
          ),
          for (var r = 0; r < 2; r++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: dividerSoft, width: 1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBar(width: 44, height: 14, color: shimmer),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ShimmerBar(
                              widthFraction: 0.9,
                              height: 14,
                              color: shimmer,
                            ),
                            const SizedBox(height: 5),
                            _ShimmerBar(
                              widthFraction: 0.75,
                              height: 11,
                              color: shimmer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots({required this.saffron});
  final Color saffron;

  @override
  Widget build(BuildContext context) {
    Widget dot(int i) => Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: saffron,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(duration: 200.ms, delay: Duration(milliseconds: 200 * i))
            .then()
            .fadeOut(duration: 400.ms);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < 3; i++) dot(i)],
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({
    this.width,
    this.widthFraction,
    required this.height,
    required this.color,
  });
  final double? width;
  final double? widthFraction;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 800.ms, begin: 0.5);
    if (widthFraction == null) return bar;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFraction,
      child: bar,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Results state
// ─────────────────────────────────────────────────────────────────────────

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({
    required this.coord,
    required this.verses,
    required this.query,
    required this.isDark,
    required this.expandedGroups,
    required this.onToggleGroup,
  });

  final ScriptureCoordinate? coord;
  final List<Verse> verses;
  final String query;
  final bool isDark;
  final Set<String> expandedGroups;
  final void Function(String) onToggleGroup;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    if (coord == null && verses.isEmpty) {
      return _NoMatches(query: query, isDark: isDark);
    }

    final groups = _groupByScripture(verses);
    final scriptureCount = groups.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (coord != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: _CoordResolvedCard(coord: coord!, isDark: isDark),
          ),
          if (verses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
              child: Text(
                'OR RELATED VERSES',
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.24 * 9.5,
                  color: text3,
                ),
              ),
            ),
        ] else
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: Fonts.sans,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.24 * 9.5,
                  color: text3,
                ),
                children: [
                  _italicNum('${verses.length}', saffron),
                  const TextSpan(text: ' MATCHES ACROSS '),
                  _italicNum('$scriptureCount', saffron),
                  const TextSpan(text: ' SCRIPTURES'),
                ],
              ),
            ),
          ),
        for (final entry in groups.entries)
          _ResultGroup(
            scripture: entry.key,
            verses: entry.value,
            query: query,
            isDark: isDark,
            expanded: expandedGroups.contains(entry.key.code),
            onToggleViewAll: entry.value.length > 3
                ? () => onToggleGroup(entry.key.code)
                : null,
          ),
      ],
    );
  }

  TextSpan _italicNum(String text, Color color) => TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: Fonts.serif,
          fontStyle: FontStyle.italic,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: color,
        ),
      );

  Map<Scripture, List<Verse>> _groupByScripture(List<Verse> verses) {
    final out = <Scripture, List<Verse>>{};
    for (final v in verses) {
      out.putIfAbsent(v.scripture, () => []).add(v);
    }
    return out;
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.query, required this.isDark});
  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      child: Column(
        children: [
          Text(
            'No matches for "$query"',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: text2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a Sanskrit word, a phrase, or a coordinate like "BG 2.47".',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontStyle: FontStyle.italic,
              fontSize: 12.5,
              height: 1.5,
              color: text3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.isDark});
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontSize: 13,
            color: text2,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Coord-resolved card
// ─────────────────────────────────────────────────────────────────────────

class _CoordResolvedCard extends StatelessWidget {
  const _CoordResolvedCard({required this.coord, required this.isDark});

  final ScriptureCoordinate coord;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final divider = isDark ? DColors.divider : LColors.divider;
    final gradStart = saffron.withValues(alpha: isDark ? 0.07 : 0.06);
    final gradMid = saffron.withValues(alpha: isDark ? 0.02 : 0.015);

    final unit = switch (coord.scripture.unitLabel) {
      'cantos' => 'Canto',
      'maṇḍalas' => 'Maṇḍala',
      'kāṇḍas' => 'Kāṇḍa',
      'pādas' => 'Pāda',
      'upadeśas' => 'Upadeśa',
      'adhyāyas' => 'Adhyāya',
      'parvas' => 'Parva',
      _ => 'Chapter',
    };
    final coordGlyph = coord.bookNum != null
        ? '${arabicToDevanagari(coord.bookNum!)}.${arabicToDevanagari(coord.chapterNum)}.${arabicToDevanagari(coord.verseNum)}'
        : '${arabicToDevanagari(coord.chapterNum)}.${arabicToDevanagari(coord.verseNum)}';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: () => context.push(
          browseVersePath(
            scriptureCode: coord.scripture.code,
            verseId: coord.verseId,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: divider, width: 1),
            gradient: LinearGradient(
              colors: [gradStart, gradMid, Colors.transparent],
              stops: const [0, 0.6, 1],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -18,
                top: 8,
                bottom: 8,
                child: LeafThread(isDark: isDark),
              ),
              Row(
                children: [
                  Text(
                    coordGlyph,
                    style: TextStyle(
                      fontFamily: Fonts.deva,
                      fontSize: 18,
                      height: 1,
                      color: cream,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DIRECT MATCH',
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.24 * 9,
                            color: saffron,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${coord.scripture.displayName} · $unit ${coord.chapterNum} · Verse ${coord.verseNum}',
                          style: TextStyle(
                            fontFamily: Fonts.serif,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            color: text1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: saffron,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Result group + row
// ─────────────────────────────────────────────────────────────────────────

class _ResultGroup extends StatelessWidget {
  const _ResultGroup({
    required this.scripture,
    required this.verses,
    required this.query,
    required this.isDark,
    required this.expanded,
    required this.onToggleViewAll,
  });

  final Scripture scripture;
  final List<Verse> verses;
  final String query;
  final bool isDark;
  final bool expanded;
  final VoidCallback? onToggleViewAll;

  @override
  Widget build(BuildContext context) {
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final divider = isDark ? DColors.divider : LColors.divider;

    final shown = expanded ? verses : verses.take(3).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: divider, width: 1),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: scripture.devaName,
                            style: TextStyle(
                              fontFamily: Fonts.deva,
                              fontSize: 14,
                              height: 1,
                              color: cream,
                            ),
                          ),
                          const TextSpan(text: '   '),
                          TextSpan(
                            text: scripture.displayName,
                            style: TextStyle(
                              fontFamily: Fonts.serif,
                              fontStyle: FontStyle.italic,
                              fontSize: 11.5,
                              color: text2,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    if (onToggleViewAll != null)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onToggleViewAll,
                        child: Text(
                          expanded
                              ? 'COLLAPSE'
                              : '${verses.length} · VIEW ALL',
                          style: TextStyle(
                            fontFamily: Fonts.sans,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.18 * 9,
                            color: saffron,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${verses.length}',
                        style: TextStyle(
                          fontFamily: Fonts.sans,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.18 * 9,
                          color: text3,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          for (final v in shown)
            _ResultRow(verse: v, query: query, isDark: isDark),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.verse,
    required this.query,
    required this.isDark,
  });

  final Verse verse;
  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final cream = isDark ? DColors.cream : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    final coordParts = <int>[
      if (verse.bookNum != null) verse.bookNum!,
      verse.chapterNum,
      verse.verseNum,
    ];
    final coordText = '‖${coordParts.map(arabicToDevanagari).join('·')}‖';

    final skLine = verse.sanskrit.split('\n').first.trim();
    final enLine = verse.english?.split('\n').first.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: saffron.withValues(alpha: 0.04),
        onTap: () => context.push(
          browseVersePath(
            scriptureCode: verse.scripture.code,
            verseId: verse.id,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerSoft, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    coordText,
                    style: TextStyle(
                      fontFamily: Fonts.deva,
                      fontSize: 12,
                      height: 1.4,
                      color: saffron,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      _highlight(
                        skLine,
                        query,
                        TextStyle(
                          fontFamily: Fonts.deva,
                          fontSize: 14,
                          height: 1.5,
                          color: cream,
                        ),
                        saffron,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (enLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text.rich(
                        _highlight(
                          enLine,
                          query,
                          TextStyle(
                            fontFamily: Fonts.serif,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            height: 1.45,
                            color: text2,
                          ),
                          saffron,
                          highlightDropsItalic: true,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: text3.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TextSpan _highlight(
  String body,
  String query,
  TextStyle base,
  Color saffron, {
  bool highlightDropsItalic = false,
}) {
  if (query.isEmpty) {
    return TextSpan(text: body, style: base);
  }
  final lc = body.toLowerCase();
  final qlc = query.toLowerCase();
  final idx = lc.indexOf(qlc);
  if (idx < 0) {
    return TextSpan(text: body, style: base);
  }
  final spans = <InlineSpan>[];
  if (idx > 0) {
    spans.add(TextSpan(text: body.substring(0, idx), style: base));
  }
  spans.add(
    TextSpan(
      text: body.substring(idx, idx + query.length),
      style: base.copyWith(
        fontWeight: FontWeight.w500,
        fontStyle: highlightDropsItalic ? FontStyle.normal : null,
        backgroundColor: saffron.withValues(alpha: 0.18),
        color: saffron,
      ),
    ),
  );
  if (idx + query.length < body.length) {
    spans.add(
      TextSpan(
        text: body.substring(idx + query.length),
        style: base,
      ),
    );
  }
  return TextSpan(children: spans);
}
