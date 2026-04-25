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
    r'b3d11066ce56ccb62ef738d1f42ee052e6922c27';

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
