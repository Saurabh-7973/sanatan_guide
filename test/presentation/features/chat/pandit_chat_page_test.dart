import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sanatan_guide/presentation/features/chat/pages/pandit_chat_page.dart';

Widget _harness({Brightness brightness = Brightness.light}) => ProviderScope(
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const PanditChatPage(),
      ),
    );

void main() {
  testWidgets('empty state renders the Pandit title and prompt',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.text('ASK THE PANDIT'), findsOneWidget);
    expect(find.text('What would you like to ask?'), findsOneWidget);
    // ॐ appears twice: the topbar glyph and the empty-state glyph.
    expect(find.text('ॐ'), findsNWidgets(2));
  });

  testWidgets('without an AI key, shows the unavailable copy and no chips',
      (tester) async {
    // GeminiService.isEnabled is false in tests (no GEMINI_API_KEY define),
    // so the key-gated path is what renders here.
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.textContaining('not available in this build'), findsWidgets);
    expect(find.text('TRY ASKING'), findsNothing);
  });

  testWidgets('dark theme pumps without exception', (tester) async {
    await tester.pumpWidget(_harness(brightness: Brightness.dark));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
