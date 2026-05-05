// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_reminder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DailyReminderNotifier)
final dailyReminderProvider = DailyReminderNotifierProvider._();

final class DailyReminderNotifierProvider
    extends $NotifierProvider<DailyReminderNotifier, DailyReminderPrefs> {
  DailyReminderNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dailyReminderProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dailyReminderNotifierHash();

  @$internal
  @override
  DailyReminderNotifier create() => DailyReminderNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailyReminderPrefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailyReminderPrefs>(value),
    );
  }
}

String _$dailyReminderNotifierHash() =>
    r'052c0b95f296ad1800fb08fa9ef7d08b9f74428d';

abstract class _$DailyReminderNotifier extends $Notifier<DailyReminderPrefs> {
  DailyReminderPrefs build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DailyReminderPrefs, DailyReminderPrefs>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DailyReminderPrefs, DailyReminderPrefs>,
        DailyReminderPrefs,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
