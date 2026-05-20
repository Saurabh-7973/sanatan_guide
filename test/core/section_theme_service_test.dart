import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/services/section_theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('disabled + no cache throws GeminiException', () async {
    expect(
      () => SectionThemeService.themeFor(
        scriptureLabel: 'Bhagavad Gita',
        chapterNum: 2,
        start: 11,
        end: 20,
        contextText: 'aśocyān anvaśocas tvaṃ',
        enabledOverride: false,
        ask: ({required systemContext, required history, required userMessage}) async =>
            fail('ask must not run when disabled'),
      ),
      throwsA(isA<GeminiException>()),
    );
  });

  test('enabled: uppercases, trims quotes, caches (one ask call)', () async {
    var calls = 0;
    Future<String> fakeAsk({
      required String systemContext,
      required List<ChatMessage> history,
      required String userMessage,
    }) async {
      calls++;
      return '"Sāṅkhya begins"\n';
    }

    final first = await SectionThemeService.themeFor(
      scriptureLabel: 'Bhagavad Gita',
      chapterNum: 2,
      start: 11,
      end: 20,
      contextText: 'aśocyān anvaśocas tvaṃ',
      enabledOverride: true,
      ask: fakeAsk,
    );
    expect(first, 'SĀṄKHYA BEGINS');

    final second = await SectionThemeService.themeFor(
      scriptureLabel: 'Bhagavad Gita',
      chapterNum: 2,
      start: 11,
      end: 20,
      contextText: 'aśocyān anvaśocas tvaṃ',
      enabledOverride: true,
      ask: fakeAsk,
    );
    expect(second, 'SĀṄKHYA BEGINS');
    expect(calls, 1, reason: 'cached after first call');
  });

  test('blank model reply caches null (no repeat calls, no suffix)',
      () async {
    var calls = 0;
    Future<String> ask({
      required String systemContext,
      required List<ChatMessage> history,
      required String userMessage,
    }) async {
      calls++;
      return '   ';
    }

    final t1 = await SectionThemeService.themeFor(
      scriptureLabel: 'Rigveda',
      chapterNum: 1,
      start: 1,
      end: 25,
      contextText: 'agnim īḷe',
      enabledOverride: true,
      ask: ask,
    );
    final t2 = await SectionThemeService.themeFor(
      scriptureLabel: 'Rigveda',
      chapterNum: 1,
      start: 1,
      end: 25,
      contextText: 'agnim īḷe',
      enabledOverride: true,
      ask: ask,
    );
    expect(t1, isNull);
    expect(t2, isNull);
    expect(calls, 1, reason: 'empty result is cached so we never re-ask');
  });
}
