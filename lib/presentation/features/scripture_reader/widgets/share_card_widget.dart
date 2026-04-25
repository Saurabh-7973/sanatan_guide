import 'package:flutter/material.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_typography.dart';

/// Share card — 4:5 ratio (360×450 logical = 1080×1350px at pixelRatio 3.0).
///
/// Design principles:
///   • The verse IS the design — no chrome, no wordmark.
///   • Sanskrit at full size dominates; translation whispers below.
///   • Devanagari numerals in the reference (२.४७ not 2.47).
///   • Saffron appears exactly 3 times: scripture name, dots, reference.
class ShareCardWidget extends StatelessWidget {
  final Verse verse;
  const ShareCardWidget({super.key, required this.verse});

  // 360×450 logical = 1080×1350px physical (4:5 aspect ratio)
  static const double _w = 360;
  static const double _h = 450;

  static const Color _bg         = AppColors.shareCardBg;       // #0F0B07
  static const Color _ivory      = Color(0xFFEFE4D0);           // Sanskrit
  static const Color _cream      = Color(0xE5F0EBE5);           // translation 90%
  static const Color _saffron    = AppColors.saffron;
  static const Color _frameBorder = Color(0x26E8820C);          // 15% opacity frame
  static const Color _cornerMark  = Color(0x40E8820C);          // 25% opacity corners

  @override
  Widget build(BuildContext context) {
    final sanskritFontSize = _pickSanskritSize(verse.sanskrit.length);

    return SizedBox(
      width: _w,
      height: _h,
      child: Stack(
        children: [
          // Background
          _Background(),

          // Inner frame — 16px inset on all sides
          Positioned(
            left: 16, top: 16, right: 16, bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: _frameBorder),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Corner marks at inner-frame corners
          ..._buildCornerMarks(),

          // Main content — vertically centered, auto-scales if long verse
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 36),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: _w - 88, // content width = card - 2×horizontal padding
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scripture name (Devanagari)
                  Text(
                    _devanagariFullName(verse),
                    style: AppTypography.caption.copyWith(
                      color: _saffron,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  _Dots(color: _saffron.withValues(alpha: 0.45)),
                  const SizedBox(height: 26),

                  // Sanskrit — the hero
                  if (verse.sanskrit.isNotEmpty)
                    Text(
                      verse.sanskrit,
                      style: AppTypography.sanskritLarge.copyWith(
                        color: _ivory,
                        fontSize: sanskritFontSize,
                        height: 2.1,
                        letterSpacing: 0.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 26),
                  _Dots(color: _saffron.withValues(alpha: 0.65)),
                  const SizedBox(height: 18),

                  // English translation
                  if (verse.english != null && verse.english!.isNotEmpty)
                    Text(
                      verse.english!,
                      style: AppTypography.bodyMedium.copyWith(
                        fontStyle: FontStyle.italic,
                        color: _cream,
                        fontSize: 17,
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 22),

                  // Verse reference — Devanagari numerals
                  Text(
                    _devanagariRef(verse),
                    style: AppTypography.sanskritSmall.copyWith(
                      color: _saffron,
                      fontSize: 14,
                      height: 1.4,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                  ),
                ),
              ),
            ),
          ),

          // Watermark — a single saffron dot (not a wordmark)
          const Positioned(
            right: 9,
            bottom: 9,
            child: _SaffronDot(),
          ),
        ],
      ),
    );
  }

  // Scale Sanskrit down for longer verses to avoid overflow
  static double _pickSanskritSize(int charCount) {
    if (charCount > 100) return 30.0;
    if (charCount > 60)  return 36.0;
    return 42.0;
  }

  // Full scripture name in Devanagari for the top label
  static String _devanagariFullName(Verse verse) {
    final code = verse.id.split('.').first;
    return switch (code) {
      'BG'   => 'भगवद्गीता',
      'RV'   => 'ऋग्वेद',
      'SV'   => 'सामवेद',
      'YV'   => 'यजुर्वेद',
      'AV'   => 'अथर्ववेद',
      'MBH'  => 'महाभारत',
      'RAM'  => 'रामायण',
      'BP'   => 'भागवतपुराण',
      'CU'   => 'छान्दोग्योपनिषद्',
      'BAU'  => 'बृहदारण्यकोपनिषद्',
      'TK'   => 'तिरुक्कुरल',
      'YS'   => 'योगसूत्राणि',
      'BS'   => 'ब्रह्मसूत्र',
      'MS'   => 'मनुस्मृति',
      'KAS'  => 'अर्थशास्त्र',
      'ISHA' => 'ईशोपनिषद्',
      'KE'   => 'केनोपनिषद्',
      'MUNK' => 'मुण्डकोपनिषद्',
      'KATH' => 'कठोपनिषद्',
      'PU'   => 'प्रश्नोपनिषद्',
      'TU'   => 'तैत्तिरीयोपनिषद्',
      'AU'   => 'ऐतरेयोपनिषद्',
      'MU'   => 'माण्डूक्योपनिषद्',
      'HYP'  => 'हठयोगप्रदीपिका',
      'VS'   => 'विष्णुसहस्रनाम',
      _      => verse.scripture.displayName,
    };
  }

  // Short name + Devanagari numeral reference (e.g. "गीता · २.४७")
  static String _devanagariRef(Verse verse) {
    final code = verse.id.split('.').first;
    final shortName = switch (code) {
      'BG'   => 'गीता',
      'RV'   => 'ऋग्वेद',
      'SV'   => 'सामवेद',
      'YV'   => 'यजुर्वेद',
      'AV'   => 'अथर्ववेद',
      'MBH'  => 'महाभारत',
      'RAM'  => 'रामायण',
      'BP'   => 'भागवत',
      'CU'   => 'छान्दोग्य',
      'BAU'  => 'बृहदारण्यक',
      'TK'   => 'तिरुक्कुरल',
      'YS'   => 'योगसूत्र',
      'BS'   => 'ब्रह्मसूत्र',
      'MS'   => 'मनुस्मृति',
      'KAS'  => 'अर्थशास्त्र',
      _      => verse.scripture.displayName,
    };
    final parts = verse.id.split('.');
    final nums = switch (parts.length) {
      >= 3  => '${parts[1]}.${parts[2]}',
      2     => parts[1],
      _     => '${verse.verseNum}',
    };
    return '$shortName · ${_toDevanagariNumerals(nums)}';
  }

  // Converts ASCII digits to Devanagari (e.g. "2.47" → "२.४७")
  static String _toDevanagariNumerals(String input) {
    const digits = {
      '0': '०', '1': '१', '2': '२', '3': '३', '4': '४',
      '5': '५', '6': '६', '7': '७', '8': '८', '9': '९',
    };
    return input.split('').map((c) => digits[c] ?? c).join();
  }

  List<Widget> _buildCornerMarks() {
    const inset = 20.0; // slightly inside the inner frame
    const arm   = 8.0;
    const stroke = 2.0;
    return const [
      Positioned(left: inset, top: inset,
        child: _CornerMark(arm: arm, stroke: stroke, color: _cornerMark, flipH: false, flipV: false)),
      Positioned(right: inset, top: inset,
        child: _CornerMark(arm: arm, stroke: stroke, color: _cornerMark, flipH: true,  flipV: false)),
      Positioned(left: inset, bottom: inset,
        child: _CornerMark(arm: arm, stroke: stroke, color: _cornerMark, flipH: false, flipV: true)),
      Positioned(right: inset, bottom: inset,
        child: _CornerMark(arm: arm, stroke: stroke, color: _cornerMark, flipH: true,  flipV: true)),
    ];
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: ShareCardWidget._w,
        height: ShareCardWidget._h,
        decoration: BoxDecoration(
          color: ShareCardWidget._bg,
          borderRadius: BorderRadius.circular(20),
        ),
      );
}

class _Dots extends StatelessWidget {
  final Color color;
  const _Dots({required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(color),
          const SizedBox(width: 10),
          _dot(color),
          const SizedBox(width: 10),
          _dot(color),
        ],
      );

  static Widget _dot(Color c) => Container(
        width: 4, height: 4,
        decoration: BoxDecoration(shape: BoxShape.circle, color: c),
      );
}

class _SaffronDot extends StatelessWidget {
  const _SaffronDot();

  @override
  Widget build(BuildContext context) => Container(
        width: 5, height: 5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.saffron,
        ),
      );
}

class _CornerMark extends StatelessWidget {
  final double arm;
  final double stroke;
  final Color color;
  final bool flipH;
  final bool flipV;

  const _CornerMark({
    required this.arm,
    required this.stroke,
    required this.color,
    required this.flipH,
    required this.flipV,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(arm, arm),
        painter: _CornerPainter(color: color, stroke: stroke, flipH: flipH, flipV: flipV),
      );
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double stroke;
  final bool flipH;
  final bool flipV;
  const _CornerPainter({required this.color, required this.stroke, required this.flipH, required this.flipV});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final ox = flipH ? size.width  : 0.0;
    final oy = flipV ? size.height : 0.0;
    final dx = flipH ? -1.0 : 1.0;
    final dy = flipV ? -1.0 : 1.0;

    canvas.drawLine(Offset(ox, oy), Offset(ox + dx * size.width,  oy), paint);
    canvas.drawLine(Offset(ox, oy), Offset(ox, oy + dy * size.height), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.stroke != stroke;
}
