import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/overflow_menu.dart';
import 'package:sanatan_guide/presentation/shared/widgets/topbar_icons.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.glyph,
    required this.onTap,
    required this.color,
    this.showDot = false,
    this.dotColor,
  });
  final TopBarGlyph glyph;
  final VoidCallback onTap;
  final Color color;
  final bool showDot;
  final Color? dotColor;

  String get _semanticLabel => switch (glyph) {
        TopBarGlyph.search => 'Search verses',
        TopBarGlyph.bookmark => 'Open bookmarks',
        TopBarGlyph.overflow => 'More options',
      };

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: _semanticLabel,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                Center(
                  child: ExcludeSemantics(
                    child: TopBarIcon(glyph: glyph, color: color),
                  ),
                ),
                if (showDot)
                  Positioned(
                    // mockup .dot-indicator: 6×6 saffron, top-right.
                    right: 10,
                    top: 10,
                    child: ExcludeSemantics(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

/// Home topbar: सनातन brand + Search / Bookmark / ⋯  (spec 13 A.1).
class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final ink = isDark ? DColors.text2 : LColors.text2;
    // v1 semantic: dot = "you have at least one saved verse". v2 will
    // promote it to "new/unread bookmarks" once last-seen tracking lands.
    final hasBookmarks =
        ref.watch(bookmarkedIdsProvider).value?.isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 16, 14),
      child: Row(
        children: [
          Text(
            'सनातन',
            style: TextStyle(
              fontFamily: Fonts.deva,
              fontFamilyFallback: AppFontFallback.deva,
              fontSize: 22,
              color: saffron,
            ),
          ),
          const Spacer(),
          _IconBtn(
            glyph: TopBarGlyph.search,
            color: ink,
            onTap: () => context.push('/search'),
          ),
          _IconBtn(
            glyph: TopBarGlyph.bookmark,
            color: ink,
            showDot: hasBookmarks,
            dotColor: saffron,
            onTap: () => context.push('/bookmarks'),
          ),
          _IconBtn(
            glyph: TopBarGlyph.overflow,
            color: ink,
            onTap: () => showOverflowMenu(context),
          ),
        ],
      ),
    );
  }
}

/// Library trailing actions: Bookmark + ⋯ (search is the inline field). A.2.
class LibraryTopBarActions extends ConsumerWidget {
  const LibraryTopBarActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final ink = isDark ? DColors.text2 : LColors.text2;
    final hasBookmarks =
        ref.watch(bookmarkedIdsProvider).value?.isNotEmpty ?? false;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          glyph: TopBarGlyph.bookmark,
          color: ink,
          showDot: hasBookmarks,
          dotColor: saffron,
          onTap: () => context.push('/bookmarks'),
        ),
        _IconBtn(
          glyph: TopBarGlyph.overflow,
          color: ink,
          onTap: () => showOverflowMenu(context),
        ),
      ],
    );
  }
}
