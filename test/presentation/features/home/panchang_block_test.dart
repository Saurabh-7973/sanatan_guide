import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:sanatan_guide/domain/entities/script_style.dart';
import 'package:sanatan_guide/presentation/features/home/widgets/panchang_block.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets('shows the Gregorian date alongside the Vikram Samvat year',
      (tester) async {
    final fixedDay = DateTime(2026, 6, 13);

    await tester.pumpWidget(wrap(PanchangBlock(now: fixedDay)));

    final gregorian = DateFormat('d MMMM yyyy').format(fixedDay);
    expect(find.text(gregorian), findsOneWidget);
    expect(find.textContaining('VIKRAM SAMVAT'), findsOneWidget);
  });

  testWidgets('still shows a date on day one', (tester) async {
    final fixedDay = DateTime(2026, 6, 13);

    await tester.pumpWidget(
      wrap(PanchangBlock(now: fixedDay, isFirstDay: true)),
    );

    expect(find.text(DateFormat('d MMMM yyyy').format(fixedDay)),
        findsOneWidget);
  });

  group('ScriptStyle', () {
    test('both shows Devanāgarī and Latin', () {
      expect(ScriptStyle.both.showsDevanagari, isTrue);
      expect(ScriptStyle.both.showsLatin, isTrue);
    });

    test('devanagari hides Latin, latin hides Devanāgarī', () {
      expect(ScriptStyle.devanagari.showsLatin, isFalse);
      expect(ScriptStyle.devanagari.showsDevanagari, isTrue);
      expect(ScriptStyle.latin.showsDevanagari, isFalse);
      expect(ScriptStyle.latin.showsLatin, isTrue);
    });

    test('round-trips through storage; unknown parses to null', () {
      for (final s in ScriptStyle.values) {
        expect(ScriptStyle.fromStorage(s.storageValue), s);
      }
      expect(ScriptStyle.fromStorage('nonsense'), isNull);
      expect(ScriptStyle.fromStorage(null), isNull);
    });
  });
}
