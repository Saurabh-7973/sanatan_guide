// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font_size_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FontSizeNotifier)
final fontSizeProvider = FontSizeNotifierProvider._();

final class FontSizeNotifierProvider
    extends $NotifierProvider<FontSizeNotifier, double> {
  FontSizeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'fontSizeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$fontSizeNotifierHash();

  @$internal
  @override
  FontSizeNotifier create() => FontSizeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$fontSizeNotifierHash() => r'b46d722feda4154e92ff42a3073f327a69d20cbc';

abstract class _$FontSizeNotifier extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<double, double>, double, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
