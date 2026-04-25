// lib/presentation/features/settings/pages/credits_page.dart
//
// Translation attribution (roadmap: content credits + licensing).

import 'package:flutter/material.dart';
import 'package:sanatan_guide/core/constants/content_credits.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Credits & attributions', style: context.ts.displayMedium),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSpacing.pagePadding,
          right: AppSpacing.pagePadding,
          top: AppSpacing.md,
          bottom: AppSpacing.xxl,
        ),
        children: [
          const _DisclaimerBanner(),
          const SizedBox(height: AppSpacing.xl),
          ..._groupedCreditWidgets(context, isDark),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.saffron.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: AppColors.saffron.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About our content',
            style: context.ts.labelMedium.copyWith(
              color: AppColors.saffron,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Scripture text is compiled from established English translations, '
            'mostly in the public domain, by scholars whose work made these '
            'texts widely available.',
            style: context.ts.bodyMedium.copyWith(height: 1.55),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Mistakes in digitization or presentation are ours alone.',
            style: context.ts.bodyMediumMuted.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit, required this.isDark});

  final ScriptureCredit credit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final fill = isDark ? AppColors.surfaceDark : AppColors.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    credit.displayName,
                    style: context.ts.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _LicenseChip(label: credit.licenseLabel),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              credit.translators.join(' · '),
              style: context.ts.bodyMediumMuted,
            ),
            if (credit.licenseNote != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                credit.licenseNote!,
                style: context.ts.caption.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.link_outlined,
                    size: 16,
                    color: context.ts.caption.color,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      credit.source,
                      style: context.ts.caption.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section headers + cards in [contentCredits] order.
List<Widget> _groupedCreditWidgets(BuildContext context, bool isDark) {
  final children = <Widget>[];
  CreditCatalogSection? previous;

  for (final credit in contentCredits) {
    if (credit.section != previous) {
      if (previous != null) {
        children.add(const SizedBox(height: AppSpacing.lg));
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(
            credit.section.catalogTitle.toUpperCase(),
            style: context.ts.caption.copyWith(
              letterSpacing: 1.5,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.saffron,
            ),
          ),
        ),
      );
      previous = credit.section;
    }
    children.add(
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _CreditCard(credit: credit, isDark: isDark),
      ),
    );
  }
  return children;
}

class _LicenseChip extends StatelessWidget {
  const _LicenseChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceHighest
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        child: Text(
          label,
          style: context.ts.chipLabel.copyWith(fontSize: 11),
        ),
      ),
    );
  }
}
