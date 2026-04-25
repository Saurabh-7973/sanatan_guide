import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/features/search/providers/search_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/shared/widgets/error_state_widget.dart';
import 'package:sanatan_guide/presentation/shared/widgets/verse_preview_tile.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(searchQueryProvider, (previous, next) {
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        titleSpacing: 0,
        title: Container(
          height: 42,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevated : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(21),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.warmGrey50.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: context.ts.bodyMedium,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Search verses, words, concepts…',
              hintStyle: context.ts.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        _controller.clear();
                        if (mounted) {
                          ref.read(searchQueryProvider.notifier).clear();
                        }
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm + 2,
              ),
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (mounted) ref.read(searchQueryProvider.notifier).update(value);
              });
            },
            textInputAction: TextInputAction.search,
          ),
        ),
        actions: const [SizedBox(width: AppSpacing.md)],
      ),
      body: Column(
        children: [
          const _FilterChips(),
          Expanded(child: _SearchBody(query: query)),
        ],
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────

class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(searchFilterProvider);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: AppSpacing.sm,
        ),
        itemCount: SearchFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = SearchFilter.values[index];
          final isSelected = selected == filter;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) =>
                ref.read(searchFilterProvider.notifier).select(filter),
            selectedColor: AppColors.saffronLight,
            checkmarkColor: AppColors.saffron,
            side: BorderSide(
              color: isSelected
                  ? AppColors.saffron
                  : isDark
                      ? AppColors.borderDark
                      : AppColors.border,
            ),
            labelStyle: context.ts.caption.copyWith(
              color: isSelected ? AppColors.saffron : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query.trim().length < 2) {
      return const _EmptyPrompt();
    }

    final resultsState = ref.watch(searchResultsProvider);

    return resultsState.when(
      loading: () => const VerseListShimmer(rowCount: 8),
      error: (e, _) => const ErrorStateWidget(),
      data: (either) => either.fold(
        (failure) => ErrorStateWidget(message: failure.message),
        (verses) {
          if (verses.isEmpty) return _NoResults(query: query);
          return _ResultsList(verses: verses, query: query);
        },
      ),
    );
  }
}

// ── Empty prompt ─────────────────────────────────────────────────────────

class _EmptyPrompt extends StatelessWidget {
  const _EmptyPrompt();

  static const List<String> _suggestions = [
    'karma',
    'dharma',
    'arjuna',
    'moksha',
    'yoga',
    'atman',
    'brahman',
    'duty',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmGrey10,
              ),
              child: const Icon(
                Icons.auto_stories_outlined,
                size: 32,
                color: AppColors.warmGrey50,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Explore the scriptures',
              style: context.ts.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Search by Sanskrit words, English phrases,\nor spiritual concepts.',
              style: context.ts.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'SUGGESTIONS',
              style: context.ts.sectionLabel,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: _suggestions.map((word) {
                return _SuggestionChip(word: word);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  const _SuggestionChip({required this.word});

  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref.read(searchQueryProvider.notifier).update(word),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.warmGrey10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderFaint),
          ),
          child: Text(
            word,
            style: context.ts.caption.copyWith(
              color: AppColors.warmGrey80,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── No results ───────────────────────────────────────────────────────────

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '·',
              style: TextStyle(
                fontFamily: 'Lora',
                fontSize: 72,
                color: AppColors.warmGrey50,
                height: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No results for "$query"',
              style: context.ts.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different word or phrase.\nBoth Sanskrit and English are supported.',
              style: context.ts.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results list ─────────────────────────────────────────────────────────

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.verses, required this.query});

  final List<Verse> verses;
  final String query;

  @override
  Widget build(BuildContext context) {
    // Group verses by scripture, preserving result order within each group
    final grouped = <Scripture, List<Verse>>{};
    for (final verse in verses) {
      (grouped[verse.scripture] ??= []).add(verse);
    }

    // Build flat item list: inter-group gap + header + verse rows
    final items = <Widget>[];
    int animIndex = 0;
    bool first = true;
    for (final entry in grouped.entries) {
      if (!first) items.add(const SizedBox(height: AppSpacing.xl));
      first = false;
      items.add(_ScriptureGroupHeader(
        scripture: entry.key,
        count: entry.value.length,
      ));
      items.add(const SizedBox(height: AppSpacing.xs));
      for (final verse in entry.value) {
        items.add(_SearchResultCard(
          verse: verse,
          index: animIndex++,
          query: query,
        ));
        items.add(const SizedBox(height: AppSpacing.sm));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.md,
            AppSpacing.pagePadding,
            AppSpacing.xs,
          ),
          child: Text(
            '${verses.length} result${verses.length == 1 ? '' : 's'} '
            'across ${grouped.length} '
            '${grouped.length == 1 ? 'scripture' : 'scriptures'}',
            style: context.ts.caption,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.sm,
              AppSpacing.pagePadding,
              AppSpacing.xxl,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: items,
          ),
        ),
      ],
    );
  }
}

// ── Scripture group header ────────────────────────────────────────────────

class _ScriptureGroupHeader extends StatelessWidget {
  const _ScriptureGroupHeader({
    required this.scripture,
    required this.count,
  });

  final Scripture scripture;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            scripture.displayName,
            style: context.ts.sectionLabel,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.borderDark : AppColors.warmGrey10,
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          ),
          child: Text(
            '$count',
            style: context.ts.labelSmall,
          ),
        ),
      ],
    );
  }
}

// ── Single result card ───────────────────────────────────────────────────

class _SearchResultCard extends ConsumerWidget {
  const _SearchResultCard({
    required this.verse,
    required this.index,
    required this.query,
  });

  final Verse verse;
  final int index;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarked = ref.watch(isBookmarkedProvider(verse.id)).value ?? false;
    final skLine = verse.sanskrit.split('\n').first.trim();
    final enLine = verse.english?.split('\n').first.trim() ?? '';

    return VersePreviewTile(
      locationLabel: compactVerseLocationLabel(verse),
      onTap: () => context.push(
        '/browse/${verse.scripture.code}/verse/${verse.id}',
      ),
      sanskritPreview: skLine.isNotEmpty ? skLine : null,
      englishPreview: enLine.isNotEmpty ? enLine : null,
      isBookmarked: bookmarked,
      query: query,
      animateIndex: index,
    );
  }
}
