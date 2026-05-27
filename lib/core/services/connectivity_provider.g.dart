// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Streams the current online/offline state. true = at least one transport
/// reports a usable connection (wifi/mobile/ethernet); false = airplane mode,
/// no signal, or every transport reports `none`.
///
/// Riverpod 3 keepAlive so all screens watching it share the same upstream
/// subscription — we never want to spawn multiple PlatformChannel watchers.

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// Streams the current online/offline state. true = at least one transport
/// reports a usable connection (wifi/mobile/ethernet); false = airplane mode,
/// no signal, or every transport reports `none`.
///
/// Riverpod 3 keepAlive so all screens watching it share the same upstream
/// subscription — we never want to spawn multiple PlatformChannel watchers.

final class IsOnlineProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Streams the current online/offline state. true = at least one transport
  /// reports a usable connection (wifi/mobile/ethernet); false = airplane mode,
  /// no signal, or every transport reports `none`.
  ///
  /// Riverpod 3 keepAlive so all screens watching it share the same upstream
  /// subscription — we never want to spawn multiple PlatformChannel watchers.
  IsOnlineProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isOnlineProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return isOnline(ref);
  }
}

String _$isOnlineHash() => r'c68a9490137b833a8b60b9be1237f0561a4522ea';
