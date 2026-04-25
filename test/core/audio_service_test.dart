import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/core/services/audio_service.dart';

void main() {
  group('FakeAudioService', () {
    test('initial state is idle', () {
      final svc = FakeAudioService();
      addTearDown(svc.dispose);
      expect(svc.currentState, AudioPlaybackState.idle);
    });

    test('play emits loading → playing and records last url', () async {
      final svc = FakeAudioService();
      addTearDown(svc.dispose);

      final seen = <AudioPlaybackState>[];
      final sub = svc.stateStream.listen(seen.add);
      addTearDown(sub.cancel);

      await svc.play('https://example.com/verse.mp3');
      await Future<void>.delayed(Duration.zero);

      expect(seen, [AudioPlaybackState.loading, AudioPlaybackState.playing]);
      expect(svc.lastUrl, 'https://example.com/verse.mp3');
      expect(svc.currentState, AudioPlaybackState.playing);
    });

    test('pause only transitions from playing', () async {
      final svc = FakeAudioService();
      addTearDown(svc.dispose);

      await svc.pause(); // no-op from idle
      expect(svc.currentState, AudioPlaybackState.idle);

      await svc.play('x');
      await svc.pause();
      expect(svc.currentState, AudioPlaybackState.paused);
    });

    test('resume only transitions from paused', () async {
      final svc = FakeAudioService();
      addTearDown(svc.dispose);

      await svc.resume(); // no-op from idle
      expect(svc.currentState, AudioPlaybackState.idle);

      await svc.play('x');
      await svc.pause();
      await svc.resume();
      expect(svc.currentState, AudioPlaybackState.playing);
    });

    test('stop returns to idle from any state', () async {
      final svc = FakeAudioService();
      addTearDown(svc.dispose);

      await svc.play('x');
      await svc.stop();
      expect(svc.currentState, AudioPlaybackState.idle);
    });

    test('play replaces the current source', () async {
      final svc = FakeAudioService();
      addTearDown(svc.dispose);

      await svc.play('a');
      await svc.play('b');
      expect(svc.lastUrl, 'b');
    });
  });
}
