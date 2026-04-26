import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/router/app_routes.dart';
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class ScriptureLibraryPage extends StatelessWidget {
  const ScriptureLibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library', style: context.ts.displayMedium),
        centerTitle: false,
        flexibleSpace: const IgnorePointer(
          child: NalandaArchBackdrop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_rounded),
            color: AppColors.warmGrey50,
            tooltip: 'Saved verses',
            onPressed: () => context.go(AppRoutes.bookmarks),
          ),
        ],
      ),
      body: const _LibraryBody(),
    );
  }
}

const _singleChapterBrowse = {
  'mandukya_upanishad',
  'isha_upanishad',
  'kena_upanishad',
  'mundaka_upanishad',
  'katha_upanishad',
  'vishnu_sahasranama',
  'prashna_upanishad',
  'taittiriya_upanishad',
  'aitareya_upanishad',
  'shvetashvatara_upanishad',
  'kaushitaki_upanishad',
  'maitrayani_upanishad',
};

void _openBrowseScripture(BuildContext context, String id) {
  if (_singleChapterBrowse.contains(id)) {
    context.push('/browse/$id/chapter/1');
  } else {
    context.push('/browse/$id');
  }
}

// ── Data ─────────────────────────────────────────────────────────────────

const _samplerIds = {
  // Puranas — highlights only (full Bhagavata / epics / Vedas ship without this badge)
  'vishnu_purana',
  'devi_bhagavata_purana',
  'markandeya_purana',
  // Upanishads — famous verses only (full texts pending)
  'katha_upanishad',
  'mundaka_upanishad',
  'kena_upanishad',
  'prashna_upanishad',
  'shvetashvatara_upanishad',
  // Darshana & Yoga — selected sutras
  'brahma_sutras',
  'hatha_yoga_pradipika',
  // Dharmashastra & Tantra — selected verses
  'manusmriti',
  'mahanirvana_tantra',
};

class _BrowseSpec {
  const _BrowseSpec({
    required this.id,
    required this.title,
    required this.sanskrit,
    required this.description,
    required this.verses,
    required this.emoji,
  });

  final String id;
  final String title;
  final String sanskrit;
  final String description;
  final int verses;
  final String emoji;

  bool get isSampler => _samplerIds.contains(id);
}

class _BrowseSection {
  const _BrowseSection({required this.title, required this.specs});
  final String title;
  final List<_BrowseSpec> specs;

  /// Short label for category chip + accent color (task 57).
  String get chipLabel => switch (title) {
        'Itihasa & Purana' => 'Itihasa',
        'Veda' => 'Veda',
        'Upanishad' => 'Upanishad',
        'Darshana & Yoga' => 'Darshana',
        'Stotra' => 'Stotra',
        'Dharmashastra & Niti' => 'Shastra',
        'Tantra' => 'Tantra',
        'Tamil Classic' => 'Tamil',
        _ => 'Library',
      };
}

// ── Featured ─────────────────────────────────────────────────────────────

const _featured = [
  _BrowseSpec(
    id: 'bhagavad_gita',
    title: 'Bhagavad Gita',
    sanskrit: 'भगवद्गीता',
    description: 'The Song of God — 700 verses',
    verses: 700,
    emoji: '🕉️',
  ),
  _BrowseSpec(
    id: 'yoga_sutras',
    title: 'Yoga Sutras',
    sanskrit: 'योगसूत्र',
    description: 'Eight limbs of Yoga — 195 sutras',
    verses: 195,
    emoji: '🧘',
  ),
  _BrowseSpec(
    id: 'rigveda',
    title: 'Rigveda',
    sanskrit: 'ऋग्वेद',
    description: 'The oldest hymns — 10 Mandalas',
    verses: 9508,
    emoji: '🔥',
  ),
  _BrowseSpec(
    id: 'bhagavata_purana',
    title: 'Bhagavata Purana',
    sanskrit: 'भागवतपुराण',
    description: 'Krishna-lila & bhakti',
    verses: 14031,
    emoji: '🦚',
  ),
];

// ── Sections (canonical order: Itihasa-Purana → Veda → Upanishad → Darshana → Stotra → Dharmashastra & Niti → Tantra → Tamil Classic) ──

const _sections = <_BrowseSection>[
  _BrowseSection(title: 'Itihasa & Purana', specs: [
    _BrowseSpec(
        id: 'ramayana',
        title: 'Ramayana',
        sanskrit: 'रामायण',
        description: 'The journey of Shri Rama — dharma, devotion, and exile',
        verses: 18761,
        emoji: '🏹'),
    _BrowseSpec(
        id: 'mahabharata',
        title: 'Mahabharata',
        sanskrit: 'महाभारत',
        description: 'The great epic of the Kuru dynasty and cosmic dharma',
        verses: 72770,
        emoji: '⚔️'),
    _BrowseSpec(
        id: 'bhagavata_purana',
        title: 'Bhagavata Purana',
        sanskrit: 'भागवतपुराण',
        description: 'Krishna-lila, bhakti yoga, and the path of devotion',
        verses: 14031,
        emoji: '🦚'),
    _BrowseSpec(
        id: 'vishnu_purana',
        title: 'Vishnu Purana',
        sanskrit: 'विष्णुपुराण',
        description: 'Cosmology, avatars, and the cycles of creation',
        verses: 28,
        emoji: '🪷'),
    _BrowseSpec(
        id: 'devi_bhagavata_purana',
        title: 'Devi Bhagavata Purana',
        sanskrit: 'देवीभागवतपुराण',
        description: 'The supremacy and grace of the Divine Mother',
        verses: 20,
        emoji: '🌺'),
    _BrowseSpec(
        id: 'markandeya_purana',
        title: 'Markandeya Purana',
        sanskrit: 'मार्कण्डेयपुराण',
        description: 'Contains the Devi Mahatmya — glory of the Goddess',
        verses: 16,
        emoji: '🔱'),
  ]),
  _BrowseSection(title: 'Veda', specs: [
    _BrowseSpec(
        id: 'rigveda',
        title: 'Rigveda',
        sanskrit: 'ऋग्वेद',
        description: 'The oldest scripture — hymns to the cosmic powers',
        verses: 9508,
        emoji: '🔥'),
    _BrowseSpec(
        id: 'samaveda',
        title: 'Samaveda',
        sanskrit: 'सामवेद',
        description: 'The Veda of melodies and sacred chants',
        verses: 1719,
        emoji: '🎵'),
    _BrowseSpec(
        id: 'yajurveda',
        title: 'Yajurveda',
        sanskrit: 'यजुर्वेद',
        description: 'Sacrificial formulas and ritual knowledge',
        verses: 1978,
        emoji: '🕯️'),
    _BrowseSpec(
        id: 'atharvaveda',
        title: 'Atharvaveda',
        sanskrit: 'अथर्ववेद',
        description: 'Hymns for healing, protection, and daily life',
        verses: 5627,
        emoji: '🌿'),
  ]),
  _BrowseSection(title: 'Upanishad', specs: [
    _BrowseSpec(
        id: 'isha_upanishad',
        title: 'Isha',
        sanskrit: 'ईशोपनिषद्',
        description: 'The Self pervades all — renunciation and action',
        verses: 18,
        emoji: '☀️'),
    _BrowseSpec(
        id: 'kena_upanishad',
        title: 'Kena',
        sanskrit: 'केनोपनिषद्',
        description: 'By whose power does the mind think? The unknowable Brahman',
        verses: 9,
        emoji: '🌿'),
    _BrowseSpec(
        id: 'katha_upanishad',
        title: 'Katha',
        sanskrit: 'कठोपनिषद्',
        description: 'Nachiketa\'s dialogue with Death on the nature of the Self',
        verses: 7,
        emoji: '💀'),
    _BrowseSpec(
        id: 'prashna_upanishad',
        title: 'Prashna',
        sanskrit: 'प्रश्नोपनिषद्',
        description: 'Six questions on Prana, creation, and the Absolute',
        verses: 28,
        emoji: '❓'),
    _BrowseSpec(
        id: 'mundaka_upanishad',
        title: 'Mundaka',
        sanskrit: 'मुण्डकोपनिषद्',
        description: 'Satyameva Jayate — the higher and lower knowledge',
        verses: 7,
        emoji: '🦅'),
    _BrowseSpec(
        id: 'mandukya_upanishad',
        title: 'Mandukya',
        sanskrit: 'माण्डूक्योपनिषद्',
        description: 'OM and the four states of consciousness',
        verses: 12,
        emoji: '🕉️'),
    _BrowseSpec(
        id: 'taittiriya_upanishad',
        title: 'Taittiriya',
        sanskrit: 'तैत्तिरीयोपनिषद्',
        description: 'The five sheaths of the Self — from matter to bliss',
        verses: 20,
        emoji: '🌿'),
    _BrowseSpec(
        id: 'aitareya_upanishad',
        title: 'Aitareya',
        sanskrit: 'ऐतरेयोपनिषद्',
        description: 'Prajnanam Brahma — consciousness is Brahman',
        verses: 15,
        emoji: '🌊'),
    _BrowseSpec(
        id: 'chandogya_upanishad',
        title: 'Chandogya',
        sanskrit: 'छान्दोग्योपनिषद्',
        description: 'Tat Tvam Asi — the great dialogue on the Self',
        verses: 623,
        emoji: '🎵'),
    _BrowseSpec(
        id: 'brihadaranyaka_upanishad',
        title: 'Brihadaranyaka',
        sanskrit: 'बृहदारण्यकोपनिषद्',
        description: 'Aham Brahmasmi — the largest and most profound Upanishad',
        verses: 432,
        emoji: '🌲'),
    _BrowseSpec(
        id: 'shvetashvatara_upanishad',
        title: 'Shvetashvatara',
        sanskrit: 'श्वेताश्वतरोपनिषद्',
        description: 'Rudra as the Supreme Brahman — devotion and knowledge',
        verses: 28,
        emoji: '🌙'),
    _BrowseSpec(
        id: 'kaushitaki_upanishad',
        title: 'Kaushitaki',
        sanskrit: 'कौषीतकि उपनिषद्',
        description: 'Prana as Brahman and the path after death',
        verses: 18,
        emoji: '⚡'),
    _BrowseSpec(
        id: 'maitrayani_upanishad',
        title: 'Maitrayani',
        sanskrit: 'मैत्रायणी उपनिषद्',
        description: 'OM as Brahman and the unity of Atman',
        verses: 24,
        emoji: '🌸'),
  ]),
  _BrowseSection(title: 'Darshana & Yoga', specs: [
    _BrowseSpec(
        id: 'yoga_sutras',
        title: 'Yoga Sutras',
        sanskrit: 'योगसूत्र',
        description: 'Patanjali\'s eight limbs — the science of stilling the mind',
        verses: 195,
        emoji: '🧘'),
    _BrowseSpec(
        id: 'hatha_yoga_pradipika',
        title: 'Hatha Yoga Pradipika',
        sanskrit: 'हठयोगप्रदीपिका',
        description: 'The lamp of Hatha — asana, pranayama, and kundalini',
        verses: 60,
        emoji: '🔥'),
    _BrowseSpec(
        id: 'brahma_sutras',
        title: 'Brahma Sutras',
        sanskrit: 'ब्रह्मसूत्र',
        description: 'Systematic inquiry into the nature of Brahman',
        verses: 30,
        emoji: '📿'),
  ]),
  _BrowseSection(title: 'Stotra', specs: [
    _BrowseSpec(
        id: 'vishnu_sahasranama',
        title: 'Vishnu Sahasranama',
        sanskrit: 'विष्णुसहस्रनाम',
        description: 'The thousand names of Lord Vishnu — for daily recitation',
        verses: 118,
        emoji: '🪷'),
  ]),
  _BrowseSection(title: 'Dharmashastra & Niti', specs: [
    _BrowseSpec(
        id: 'manusmriti',
        title: 'Manusmriti',
        sanskrit: 'मनुस्मृति',
        description: 'Ancient codification of dharma and social order',
        verses: 54,
        emoji: '⚖️'),
    _BrowseSpec(
        id: 'arthashastra',
        title: 'Arthashastra',
        sanskrit: 'अर्थशास्त्र',
        description: 'Kautilya\'s treatise on statecraft, economics, and strategy',
        verses: 5371,
        emoji: '📜'),
  ]),
  _BrowseSection(title: 'Tantra', specs: [
    _BrowseSpec(
        id: 'mahanirvana_tantra',
        title: 'Mahanirvana Tantra',
        sanskrit: 'महानिर्वाणतन्त्र',
        description: 'The Great Liberation — Shiva and Shakti dialogue',
        verses: 60,
        emoji: '🔱'),
  ]),
  _BrowseSection(title: 'Tamil Classic', specs: [
    _BrowseSpec(
        id: 'tirukkural',
        title: 'Tirukkural',
        sanskrit: 'திருக்குறள்',
        description: 'Thiruvalluvar\'s timeless couplets on virtue, wealth, and love',
        verses: 1326,
        emoji: '🪷'),
  ]),
];

const _featuredCategoryChips = {
  'bhagavad_gita': 'Darshana',
  'yoga_sutras': 'Darshana',
  'rigveda': 'Veda',
  'bhagavata_purana': 'Itihasa',
};

String _firstSentenceBlurb(String description) {
  final dot = description.indexOf('.');
  if (dot <= 0 || dot >= description.length - 1) return description.trim();
  return description.substring(0, dot + 1).trim();
}

String _formatVerseCountLabel(int verses) =>
    '${NumberFormat.decimalPattern('en_US').format(verses)} verses';

Color _libraryCategoryAccent(String chip) => switch (chip) {
      'Itihasa' => AppColors.catItihasa,
      'Veda' => AppColors.catVeda,
      'Upanishad' => AppColors.catUpanishad,
      'Darshana' => AppColors.catDarshana,
      'Stotra' => AppColors.catStotra,
      'Shastra' => AppColors.catShastra,
      'Tantra' => AppColors.catTantra,
      'Tamil' => AppColors.catTamil,
      _ => AppColors.warmGrey50,
    };

// ── Devanagari monogram map ───────────────────────────────────────────────

const Map<String, String> _scriptureMonogram = {
  'bhagavad_gita': 'गी',
  'yoga_sutras': 'यो',
  'rigveda': 'ऋ',
  'samaveda': 'सा',
  'yajurveda': 'य',
  'atharvaveda': 'अ',
  'upanishads': 'उ',
  'mandukya_upanishad': 'मा',
  'isha_upanishad': 'ई',
  'kena_upanishad': 'के',
  'mundaka_upanishad': 'मु',
  'katha_upanishad': 'क',
  'prashna_upanishad': 'प्र',
  'taittiriya_upanishad': 'तै',
  'aitareya_upanishad': 'ऐ',
  'shvetashvatara_upanishad': 'श्वे',
  'kaushitaki_upanishad': 'कौ',
  'maitrayani_upanishad': 'मै',
  'chandogya_upanishad': 'छा',
  'brihadaranyaka_upanishad': 'बृ',
  'vishnu_sahasranama': 'वि',
  'brahma_sutras': 'ब्र',
  'hatha_yoga_pradipika': 'ह',
  'manusmriti': 'म',
  'arthashastra': 'अर्',
  'mahanirvana_tantra': 'म',
  'mahabharata': 'म',
  'ramayana': 'रा',
  'bhagavata_purana': 'भा',
  'vishnu_purana': 'वि',
  'devi_bhagavata_purana': 'दे',
  'markandeya_purana': 'मा',
  'tirukkural': 'தி',
};

String _monogramFor(String id) => _scriptureMonogram[id] ?? id[0].toUpperCase();

// ── Scripture monogram disc ───────────────────────────────────────────────

class _ScriptureMonogram extends StatelessWidget {
  const _ScriptureMonogram({required this.id, this.size = 40});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glyph = _monogramFor(id);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceElevated : AppColors.warmGrey10,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderFaint,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        glyph,
        style: TextStyle(
          fontFamily: 'TiroDevanagari',
          fontSize: size * 0.52,
          height: 1,
          color: AppColors.saffron,
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────

class _LibraryBody extends StatelessWidget {
  const _LibraryBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        const SizedBox(height: AppSpacing.md),
        const _FeaturedCarousel(),
        const SizedBox(height: AppSpacing.xl),
        for (final section in _sections) ...[
          _SectionHeader(title: section.title),
          for (final spec in section.specs)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                0,
                AppSpacing.pagePadding,
                AppSpacing.sm,
              ),
              child: _ScriptureLibraryCard(
                spec: spec,
                categoryLabel: section.chipLabel,
              ),
            ),
        ],
      ],
    );
  }
}

// ── Featured carousel ────────────────────────────────────────────────────

class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel();

  static const double _kCarouselHeight = 188;
  static const double _kCardWidth = 216;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kCarouselHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        physics: const BouncingScrollPhysics(),
        itemCount: _featured.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final spec = _featured[index];
          return _FeaturedCard(spec: spec);
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.spec});
  final _BrowseSpec spec;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chip = _featuredCategoryChips[spec.id] ?? 'Library';
    final accent = _libraryCategoryAccent(chip);
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final blurb = _firstSentenceBlurb(spec.description);

    return SizedBox(
      width: _FeaturedCarousel._kCardWidth,
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openBrowseScripture(context, spec.id),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(
                color: accent.withValues(alpha: isDark ? 0.92 : 0.78),
                child: const SizedBox(width: 4),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ScriptureMonogram(id: spec.id, size: 36),
                          const SizedBox(width: AppSpacing.sm),
                          _CategoryChip(label: chip, accent: accent),
                          const Spacer(),
                          Text(
                            _formatVerseCountLabel(spec.verses),
                            style: context.ts.caption.copyWith(
                              color: AppColors.warmGrey50,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        spec.sanskrit,
                        style: context.ts.sanskritSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        spec.title,
                        style: context.ts.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        blurb,
                        style: context.ts.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryOnDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: context.ts.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.warmGrey50,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Divider(
            height: 1,
            thickness: 1,
            color: (isDark ? AppColors.dividerDark : AppColors.divider)
                .withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ── Category chip (library cards) ───────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: context.ts.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: accent,
          ),
        ),
      ),
    );
  }
}

// ── Scripture card (task 57) ─────────────────────────────────────────────

class _ScriptureLibraryCard extends StatelessWidget {
  const _ScriptureLibraryCard({
    required this.spec,
    required this.categoryLabel,
  });

  final _BrowseSpec spec;
  final String categoryLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = _libraryCategoryAccent(categoryLabel);
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final blurb = _firstSentenceBlurb(spec.description);

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openBrowseScripture(context, spec.id),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColoredBox(
              color: accent.withValues(alpha: isDark ? 0.92 : 0.78),
              child: const SizedBox(width: 4),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ScriptureMonogram(id: spec.id),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _CategoryChip(
                            label: categoryLabel,
                            accent: accent,
                          ),
                        ),
                        Text(
                          _formatVerseCountLabel(spec.verses),
                          style: context.ts.caption.copyWith(
                            color: AppColors.warmGrey50,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      spec.sanskrit,
                      style: context.ts.sanskritSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      spec.title,
                      style: context.ts.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (blurb.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        blurb,
                        style: context.ts.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryOnDark
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (spec.isSampler) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warmGrey10,
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          border: Border.all(color: AppColors.borderFaint),
                        ),
                        child: Text(
                          'Selected highlights',
                          style: context.ts.cardLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md, right: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textSecondaryOnDark
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
