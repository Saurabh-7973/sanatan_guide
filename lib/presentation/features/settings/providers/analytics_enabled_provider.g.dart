// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_enabled_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User-facing opt-out for Firebase Analytics. Default ON. Writing to the
/// notifier persists to SharedPreferences and immediately flips the SDK-level
/// collection flag so no further events are buffered or sent.

@ProviderFor(AnalyticsEnabled)
final analyticsEnabledProvider = AnalyticsEnabledProvider._();

/// User-facing opt-out for Firebase Analytics. Default ON. Writing to the
/// notifier persists to SharedPreferences and immediately flips the SDK-level
/// collection flag so no further events are buffered or sent.
final class AnalyticsEnabledProvider
    extends $NotifierProvider<AnalyticsEnabled, bool> {
  /// User-facing opt-out for Firebase Analytics. Default ON. Writing to the
  /// notifier persists to SharedPreferences and immediately flips the SDK-level
  /// collection flag so no further events are buffered or sent.
  AnalyticsEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsEnabledHash();

  @$internal
  @override
  AnalyticsEnabled create() => AnalyticsEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$analyticsEnabledHash() => r'1b65f7fdd5f23ab0025a56bc75571438cb9c039d';

/// User-facing opt-out for Firebase Analytics. Default ON. Writing to the
/// notifier persists to SharedPreferences and immediately flips the SDK-level
/// collection flag so no further events are buffered or sent.

abstract class _$AnalyticsEnabled extends $Notifier<bool> {
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
