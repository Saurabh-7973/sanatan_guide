import 'package:flutter_test/flutter_test.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/pages/verse_chat_page.dart';

void main() {
  group('mergeAiReplyIntoNote', () {
    test('empty prior → reply alone (no separator)', () {
      final merged = mergeAiReplyIntoNote(
        prior: '',
        reply: 'Krishna teaches detachment.',
        stamp: '2026-05-28',
      );
      expect(merged, 'Krishna teaches detachment.');
    });

    test('whitespace-only prior → reply alone', () {
      final merged = mergeAiReplyIntoNote(
        prior: '   \n\n  ',
        reply: 'Reply.',
        stamp: '2026-05-28',
      );
      expect(merged, 'Reply.');
    });

    test('non-empty prior gets a dated separator', () {
      final merged = mergeAiReplyIntoNote(
        prior: 'My note.',
        reply: 'New reply.',
        stamp: '2026-05-28',
      );
      expect(merged, 'My note.\n\n— 2026-05-28 —\nNew reply.');
    });

    test('trailing whitespace on prior is trimmed', () {
      final merged = mergeAiReplyIntoNote(
        prior: 'Old note.   \n\n',
        reply: 'New reply.',
        stamp: '2026-05-28',
      );
      expect(merged, 'Old note.\n\n— 2026-05-28 —\nNew reply.');
    });

    test('reply leading/trailing whitespace is trimmed', () {
      final merged = mergeAiReplyIntoNote(
        prior: '',
        reply: '  Reply.  ',
        stamp: '2026-05-28',
      );
      expect(merged, 'Reply.');
    });

    test('two successive saves do not leak blank lines', () {
      final first = mergeAiReplyIntoNote(
        prior: '',
        reply: 'Reply 1.',
        stamp: '2026-05-28',
      );
      final second = mergeAiReplyIntoNote(
        prior: first,
        reply: 'Reply 2.',
        stamp: '2026-05-29',
      );
      expect(second, 'Reply 1.\n\n— 2026-05-29 —\nReply 2.');
    });
  });
}
