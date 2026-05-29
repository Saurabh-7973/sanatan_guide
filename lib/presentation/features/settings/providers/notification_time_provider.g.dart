// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_time_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationTimeNotifier)
final notificationTimeProvider = NotificationTimeNotifierProvider._();

final class NotificationTimeNotifierProvider
    extends $NotifierProvider<NotificationTimeNotifier, TimeOfDay> {
  NotificationTimeNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationTimeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationTimeNotifierHash();

  @$internal
  @override
  NotificationTimeNotifier create() => NotificationTimeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeOfDay value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeOfDay>(value),
    );
  }
}

String _$notificationTimeNotifierHash() =>
    r'7a13e5475d4155b5ba82ee67dbdc8cf8e326545c';

abstract class _$NotificationTimeNotifier extends $Notifier<TimeOfDay> {
  TimeOfDay build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TimeOfDay, TimeOfDay>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TimeOfDay, TimeOfDay>, TimeOfDay, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Whether the Daily verse reminder is enabled. Defaults to true to honour
/// the onboarding "Enable reminder" tap; user can toggle off in Settings.

@ProviderFor(NotificationEnabled)
final notificationEnabledProvider = NotificationEnabledProvider._();

/// Whether the Daily verse reminder is enabled. Defaults to true to honour
/// the onboarding "Enable reminder" tap; user can toggle off in Settings.
final class NotificationEnabledProvider
    extends $NotifierProvider<NotificationEnabled, bool> {
  /// Whether the Daily verse reminder is enabled. Defaults to true to honour
  /// the onboarding "Enable reminder" tap; user can toggle off in Settings.
  NotificationEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationEnabledHash();

  @$internal
  @override
  NotificationEnabled create() => NotificationEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$notificationEnabledHash() =>
    r'5c6cf605313b46daebf1450b4ba4e198eaf8b469';

/// Whether the Daily verse reminder is enabled. Defaults to true to honour
/// the onboarding "Enable reminder" tap; user can toggle off in Settings.

abstract class _$NotificationEnabled extends $Notifier<bool> {
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

/// Whether festival-day alerts are enabled. Default off — the scheduler
/// gated on this won't post anything until the user opts in. The actual
/// scheduling job is wired separately; this preference is the on/off pin
/// that any future festival-notification path reads before firing.

@ProviderFor(FestivalAlertsEnabled)
final festivalAlertsEnabledProvider = FestivalAlertsEnabledProvider._();

/// Whether festival-day alerts are enabled. Default off — the scheduler
/// gated on this won't post anything until the user opts in. The actual
/// scheduling job is wired separately; this preference is the on/off pin
/// that any future festival-notification path reads before firing.
final class FestivalAlertsEnabledProvider
    extends $NotifierProvider<FestivalAlertsEnabled, bool> {
  /// Whether festival-day alerts are enabled. Default off — the scheduler
  /// gated on this won't post anything until the user opts in. The actual
  /// scheduling job is wired separately; this preference is the on/off pin
  /// that any future festival-notification path reads before firing.
  FestivalAlertsEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'festivalAlertsEnabledProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$festivalAlertsEnabledHash();

  @$internal
  @override
  FestivalAlertsEnabled create() => FestivalAlertsEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$festivalAlertsEnabledHash() =>
    r'1d3b777f481bca12f9f1cac9348c38b574d05aaa';

/// Whether festival-day alerts are enabled. Default off — the scheduler
/// gated on this won't post anything until the user opts in. The actual
/// scheduling job is wired separately; this preference is the on/off pin
/// that any future festival-notification path reads before firing.

abstract class _$FestivalAlertsEnabled extends $Notifier<bool> {
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
