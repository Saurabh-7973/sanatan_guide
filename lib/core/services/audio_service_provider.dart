import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanatan_guide/core/services/audio_service.dart';

part 'audio_service_provider.g.dart';

/// Single shared [AudioService] for the app.
///
/// Defaults to [FakeAudioService] until the native backend
/// (e.g. `just_audio`) is wired in. Tests override this provider with
/// their own fake via `ProviderScope(overrides: ...)`.
@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  final svc = FakeAudioService();
  ref.onDispose(svc.dispose);
  return svc;
}

/// Current playback state (reactive). UI listens to this.
@riverpod
Stream<AudioPlaybackState> audioPlaybackState(Ref ref) {
  final svc = ref.watch(audioServiceProvider);
  return svc.stateStream;
}
