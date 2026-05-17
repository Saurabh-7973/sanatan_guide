import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sanatan_guide/presentation/shared/widgets/overflow_menu.dart';
import 'package:sanatan_guide/presentation/shared/widgets/topbar_icons.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.glyph,
    required this.onTap,
    required this.color,
  });
  final TopBarGlyph glyph;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(child: TopBarIcon(glyph: glyph, color: color)),
        ),
      );
}

/// Home topbar: सनातन brand + Search / Bookmark / ⋯  (spec 13 A.1).
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final ink = isDark ? DColors.text2 : LColors.text2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 16, 14),
      child: Row(
        children: [
          Text(
            'सनातन',
            style: TextStyle(
              fontFamily: Fonts.deva,
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
class LibraryTopBarActions extends StatelessWidget {
  const LibraryTopBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? DColors.text2 : LColors.text2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconBtn(
          glyph: TopBarGlyph.bookmark,
          color: ink,
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
