// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crashlytics_enabled_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User-facing opt-out for Firebase Crashlytics. Default ON in release
/// (so we can fix actual crashes), default OFF in debug (so dev noise
/// doesn't pollute prod). Toggling here flips the SDK-level collection
/// flag immediately; no new crash data is buffered or uploaded once off.

@ProviderFor(CrashlyticsEnabled)
final crashlyticsEnabledProvider = CrashlyticsEnabledProvider._();

/// User-facing opt-out for Firebase Crashlytics. Default ON in release
/// (so we can fix actual crashes), default OFF in debug (so dev noise
/// doesn't pollute prod). Toggling here flips the SDK-level collection
/// flag immediately; no new crash data is buffered or uploaded once off.
final class CrashlyticsEnabledProvider
    extends $NotifierProvider<CrashlyticsEnabled, bool> {
  /// User-facing opt-out for Firebase Crashlytics. Default ON in release
  /// (so we can fix actual crashes), default OFF in debug (so dev noise
  /// doesn't pollute prod). Toggling here flips the SDK-level collection
  /// flag immediately; no new crash data is buffered or uploaded once off.
  CrashlyticsEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'crashlyticsEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$crashlyticsEnabledHash();

  @$internal
  @override
  CrashlyticsEnabled create() => CrashlyticsEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$crashlyticsEnabledHash() =>
    r'4d1227647eeedd1b128279d2dfad63a10ccbe1c2';

/// User-facing opt-out for Firebase Crashlytics. Default ON in release
/// (so we can fix actual crashes), default OFF in debug (so dev noise
/// doesn't pollute prod). Toggling here flips the SDK-level collection
/// flag immediately; no new crash data is buffered or uploaded once off.

abstract class _$CrashlyticsEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
