// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'festival_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the festival list with dates overridden from Remote Config
/// if available. Falls back to hardcoded 2026 dates silently.

@ProviderFor(festivals)
final festivalsProvider = FestivalsProvider._();

/// Returns the festival list with dates overridden from Remote Config
/// if available. Falls back to hardcoded 2026 dates silently.

final class FestivalsProvider extends $FunctionalProvider<
        AsyncValue<List<Festival>>, List<Festival>, FutureOr<List<Festival>>>
    with $FutureModifier<List<Festival>>, $FutureProvider<List<Festival>> {
  /// Returns the festival list with dates overridden from Remote Config
  /// if available. Falls back to hardcoded 2026 dates silently.
  FestivalsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'festivalsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$festivalsHash();

  @$internal
  @override
  $FutureProviderElement<List<Festival>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Festival>> create(Ref ref) {
    return festivals(ref);
  }
}

String _$festivalsHash() => r'16bedc0588400fe18d651493a2c2230866a2756d';
