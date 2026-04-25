// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single shared [AudioService] for the app.
///
/// Defaults to [FakeAudioService] until the native backend
/// (e.g. `just_audio`) is wired in. Tests override this provider with
/// their own fake via `ProviderScope(overrides: ...)`.

@ProviderFor(audioService)
final audioServiceProvider = AudioServiceProvider._();

/// Single shared [AudioService] for the app.
///
/// Defaults to [FakeAudioService] until the native backend
/// (e.g. `just_audio`) is wired in. Tests override this provider with
/// their own fake via `ProviderScope(overrides: ...)`.

final class AudioServiceProvider
    extends $FunctionalProvider<AudioService, AudioService, AudioService>
    with $Provider<AudioService> {
  /// Single shared [AudioService] for the app.
  ///
  /// Defaults to [FakeAudioService] until the native backend
  /// (e.g. `just_audio`) is wired in. Tests override this provider with
  /// their own fake via `ProviderScope(overrides: ...)`.
  AudioServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'audioServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $ProviderElement<AudioService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioService create(Ref ref) {
    return audioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioService>(value),
    );
  }
}

String _$audioServiceHash() => r'804cbd91c653eca2da2dfd70ba401c9b734084b5';

/// Current playback state (reactive). UI listens to this.

@ProviderFor(audioPlaybackState)
final audioPlaybackStateProvider = AudioPlaybackStateProvider._();

/// Current playback state (reactive). UI listens to this.

final class AudioPlaybackStateProvider extends $FunctionalProvider<
        AsyncValue<AudioPlaybackState>,
        AudioPlaybackState,
        Stream<AudioPlaybackState>>
    with
        $FutureModifier<AudioPlaybackState>,
        $StreamProvider<AudioPlaybackState> {
  /// Current playback state (reactive). UI listens to this.
  AudioPlaybackStateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'audioPlaybackStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$audioPlaybackStateHash();

  @$internal
  @override
  $StreamProviderElement<AudioPlaybackState> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AudioPlaybackState> create(Ref ref) {
    return audioPlaybackState(ref);
  }
}

String _$audioPlaybackStateHash() =>
    r'6516a1074d0c7448ab9357cc103af3daac204861';
