// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_experience_level_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserExperienceLevelNotifier)
final userExperienceLevelProvider = UserExperienceLevelNotifierProvider._();

final class UserExperienceLevelNotifierProvider extends $NotifierProvider<
    UserExperienceLevelNotifier, UserExperienceLevel> {
  UserExperienceLevelNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userExperienceLevelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userExperienceLevelNotifierHash();

  @$internal
  @override
  UserExperienceLevelNotifier create() => UserExperienceLevelNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserExperienceLevel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserExperienceLevel>(value),
    );
  }
}

String _$userExperienceLevelNotifierHash() =>
    r'5700534f6c85d31476c0e8804d64bd86a8babcf3';

abstract class _$UserExperienceLevelNotifier
    extends $Notifier<UserExperienceLevel> {
  UserExperienceLevel build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserExperienceLevel, UserExperienceLevel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserExperienceLevel, UserExperienceLevel>,
        UserExperienceLevel,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
