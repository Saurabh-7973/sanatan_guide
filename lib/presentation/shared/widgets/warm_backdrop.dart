import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// Subtle saffron radial fade used as the common backdrop across stripped
/// screens (search, bookmarks, festivals, library, learning, module reader,
/// settings, credits, verse chat, onboarding).
///
/// Mirrors the warmth of the home screen's dawn glow at lower intensity so
/// screens feel unified without duplicating home's sun-arc identity.
///
/// Place behind page content with [Stack] and [extendBodyBehindAppBar]:
///
/// ```dart
/// Scaffold(
///   extendBodyBehindAppBar: true,
///   body: Stack(
///     fit: StackFit.expand,
///     children: [const WarmBackdrop(), content],
///   ),
/// );
/// ```
class WarmBackdrop extends StatelessWidget {
  const WarmBackdrop({super.key, this.intensity = 1.0});

  /// Multiplier for opacity stops. 1.0 = default, 0.6 = subtler.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final scaffold = isDark ? AppColors.bgDark : AppColors.cream;

    final topAlpha = (isDark ? 0.14 : 0.12) * intensity;
    final midAlpha = (isDark ? 0.04 : 0.04) * intensity;

    // A BoxDecoration with both `color` and `gradient` paints only the gradient
    // (a Paint ignores `color` when a shader is set), so the opaque scaffold
    // base must be a separate layer beneath the translucent radial wash —
    // otherwise transparent-Scaffold screens bleed through to clear-black.
    return IgnorePointer(
      child: ColoredBox(
        color: scaffold,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1.1),
              radius: 1.1,
              colors: [
                base.withValues(alpha: topAlpha),
                base.withValues(alpha: midAlpha),
                base.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
