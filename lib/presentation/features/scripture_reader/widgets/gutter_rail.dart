import 'package:flutter/material.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';

/// 48 px left gutter for the Sanctum verse-detail layout.
class GutterRail extends StatelessWidget {
  const GutterRail({super.key, required this.verse});

  final Verse verse;

  static String _abbrev(String code) => switch (code) {
        'bhagavad_gita' => 'BG',
        'rigveda' => 'RV',
        'samaveda' => 'SV',
        'yajurveda' => 'YV',
        'atharvaveda' => 'AV',
        'yoga_sutras' => 'YS',
        'bhagavata_purana' => 'BP',
        'vishnu_sahasranama' => 'VS',
        'tirukkural' => 'TK',
        'ramayana' => 'RM',
        'mahabharata' => 'MB',
        _ => code
            .split('_')
            .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
            .take(2)
            .join(),
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saff = isDark ? AppColors.saffronOnDark : AppColors.saffron;
    final muted = isDark
        ? AppColors.textSecondaryOnDark
        : AppColors.textSecondary;
    final textC = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final abbrev = _abbrev(verse.scripture.code);

    return SizedBox(
      width: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // Vertical saffron gradient rule
              Positioned(
                top: 12,
                bottom: 12,
                left: 23,
                child: Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        saff.withValues(alpha: 0),
                        saff.withValues(alpha: 0.5),
                        saff.withValues(alpha: 0.5),
                        saff.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.2, 0.8, 1],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 16),

                  // Scripture code stamp
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.saffronFaint,
                      border: Border.all(color: saff),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      abbrev,
                      style: TextStyle(
                        fontFamily: 'Lora',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: saff,
                        height: 1,
                      ),
                    ),
                  ),

                  // Rotated scripture name
                  Expanded(
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          verse.scripture.displayName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Lora',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            color: muted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),

                  // CH / V stamp
                  Column(
                    children: [
                      Text(
                        'CH',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 10,
                          letterSpacing: 1,
                          color: muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${verse.chapterNum}',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textC,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'V',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 10,
                          letterSpacing: 1,
                          color: muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${verse.verseNum}',
                        style: TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: saff,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
