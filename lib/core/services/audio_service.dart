import 'dart:async';

/// Playback state exposed to UI. Deliberately coarse so the abstraction
/// fits every backend (just_audio, audioplayers, platform TTS, etc.).
enum AudioPlaybackState { idle, loading, playing, paused, error }

/// Thin abstraction over the audio backend. The production implementation
/// (added alongside the `just_audio` dependency) satisfies this; tests and
/// preview builds use [FakeAudioService].
///
/// Kept intentionally minimal — a single source at a time, no playlist,
/// no per-verse tracking. Any richer behaviour (queues, notifications,
/// lock-screen controls) should be layered on top rather than pushed
/// into this interface.
abstract class AudioService {
  /// Broadcasts state transitions. UI layer watches this via a provider.
  Stream<AudioPlaybackState> get stateStream;

  AudioPlaybackState get currentState;

  /// Loads [url] (http/https or file://) and starts playback. Safe to call
  /// repeatedly — replaces the current source.
  Future<void> play(String url);

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  /// Releases native resources. Call from the owning provider's dispose.
  Future<void> dispose();
}

/// Deterministic in-memory implementation for tests and for the
/// "preview" build variant where no native audio backend is linked.
class FakeAudioService implements AudioService {
  FakeAudioService();

  final _controller = StreamController<AudioPlaybackState>.broadcast();
  AudioPlaybackState _state = AudioPlaybackState.idle;
  String? _lastUrl;

  @override
  Stream<AudioPlaybackState> get stateStream => _controller.stream;

  @override
  AudioPlaybackState get currentState => _state;

  String? get lastUrl => _lastUrl;

  void _emit(AudioPlaybackState s) {
    _state = s;
    _controller.add(s);
  }

  @override
  Future<void> play(String url) async {
    _lastUrl = url;
    _emit(AudioPlaybackState.loading);
    _emit(AudioPlaybackState.playing);
  }

  @override
  Future<void> pause() async {
    if (_state == AudioPlaybackState.playing) {
      _emit(AudioPlaybackState.paused);
    }
  }

  @override
  Future<void> resume() async {
    if (_state == AudioPlaybackState.paused) {
      _emit(AudioPlaybackState.playing);
    }
  }

  @override
  Future<void> stop() async => _emit(AudioPlaybackState.idle);

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
