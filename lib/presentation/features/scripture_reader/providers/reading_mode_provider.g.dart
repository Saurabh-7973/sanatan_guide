// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReadingModeNotifier)
final readingModeProvider = ReadingModeNotifierProvider._();

final class ReadingModeNotifierProvider
    extends $NotifierProvider<ReadingModeNotifier, ReadingMode> {
  ReadingModeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'readingModeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$readingModeNotifierHash();

  @$internal
  @override
  ReadingModeNotifier create() => ReadingModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingMode>(value),
    );
  }
}

String _$readingModeNotifierHash() =>
    r'f40a64d6ed594fd451f98bd8e5c891815e719523';

abstract class _$ReadingModeNotifier extends $Notifier<ReadingMode> {
  ReadingMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReadingMode, ReadingMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ReadingMode, ReadingMode>, ReadingMode, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
