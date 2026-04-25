import 'package:sanatan_guide/domain/entities/commentary.dart';
import 'package:sanatan_guide/l10n/generated/app_localizations.dart';

/// Human label for a tradition code. Prefers the localised label from
/// [AppLocalizations] when one is passed; otherwise falls back to the
/// English name (used in tests and non-UI contexts).
String commentaryTraditionLabel(String code, [AppLocalizations? l10n]) =>
    switch (code) {
      'advaita' => l10n?.traditionAdvaita ?? 'Advaita Vedanta',
      'vishishtadvaita' =>
        l10n?.traditionVishishtadvaita ?? 'Vishishtadvaita',
      'dvaita' => l10n?.traditionDvaita ?? 'Dvaita',
      _ => code,
    };

/// Attribution + license line shown under a commentary card.
/// Always non-empty — at minimum the license is stated.
String commentaryProvenanceLine(Commentary c, [AppLocalizations? l10n]) {
  final translatorPrefix = l10n?.commentaryTranslatorPrefix ?? 'Translation:';
  final translator = c.translator != null && c.translator!.isNotEmpty
      ? '$translatorPrefix ${c.translator}. '
      : '';
  final license = c.license == 'public_domain'
      ? (l10n?.commentaryPublicDomain ?? 'Public domain.')
      : '${l10n?.commentaryLicensePrefix ?? 'License:'} '
          '${c.license.toUpperCase().replaceAll('_', '-')}.';
  return '$translator$license';
}
