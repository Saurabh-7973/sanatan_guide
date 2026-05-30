import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// Flat opaque page backdrop. Previously rendered a subtle saffron radial
/// fade; the radial visibly desynced behind scroll viewports on the real
/// device — content scrolled while the gradient stayed fixed — so the
/// gradient is now removed and every screen uses the plain scaffold base.
///
/// Kept as a widget (rather than collapsing every caller to a flat
/// `backgroundColor`) so a future intensity-aware backdrop can be
/// reintroduced in one place without sweeping every page again. The
/// `intensity` parameter is retained for source-compat — no-op today.
///
/// Place behind page content with [Stack]:
///
/// ```dart
/// Scaffold(
///   backgroundColor: Colors.transparent,
///   body: Stack(
///     fit: StackFit.expand,
///     children: [const WarmBackdrop(), content],
///   ),
/// );
/// ```
class WarmBackdrop extends StatelessWidget {
  const WarmBackdrop({super.key, this.intensity = 1.0});

  /// Retained for source-compat. Today the backdrop is flat regardless.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffold = isDark ? AppColors.bgDark : AppColors.cream;
    return IgnorePointer(child: ColoredBox(color: scaffold));
  }
}
