import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:sanatan_guide/core/errors/failures.dart';
import 'package:sanatan_guide/core/services/streak_service.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';
import 'package:sanatan_guide/presentation/features/learning_path/pages/learning_path_page.dart';
import 'package:sanatan_guide/presentation/features/learning_path/providers/learning_provider.dart';

LearningModule _m({
  required String id,
  required String title,
  required int level,
  required int sequence,
  bool isCompleted = false,
  int cardsRead = 0,
}) =>
    LearningModule(
      id: id,
      title: title,
      hook: 'A short hook for $title.',
      level: level,
      sequence: sequence,
      estimatedMinutes: 10,
      cardCount: 5,
      isCompleted: isCompleted,
      cardsRead: cardsRead,
    );

/// 8 Foundations (level 1) + 3 Deepening (level 2). [foundationsDone] of the
/// Foundations modules are marked complete, from the top.
List<LearningModule> _modules({int foundationsDone = 1}) => [
      for (var i = 1; i <= 8; i++)
        _m(
          id: 'f$i',
          title: 'Foundations module $i',
          level: 1,
          sequence: i,
          isCompleted: i <= foundationsDone,
        ),
      for (var i = 1; i <= 3; i++)
        _m(id: 'd$i', title: 'Deepening module $i', level: 2, sequence: i),
    ];

Future<void> _pump(
  WidgetTester tester, {
  int foundationsDone = 1,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(1200, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        modulesProvider.overrideWith(
          (ref) => Right<Failure, List<LearningModule>>(
            _modules(foundationsDone: foundationsDone),
          ),
        ),
        currentStreakProvider.overrideWith((ref) => 3),
        readHistoryProvider.overrideWith((ref) => <String>{}),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const LearningPathPage(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the header and both section headers', (tester) async {
    await _pump(tester);

    expect(find.text('Your Path'), findsOneWidget);
    expect(find.text('Foundations'), findsOneWidget);
    expect(find.text('Deepening'), findsOneWidget);
    expect(find.text('III. Mastery'), findsOneWidget); // horizon teaser
  });

  testWidgets('Continue anchor points at the first incomplete module',
      (tester) async {
    await _pump(tester, foundationsDone: 1);

    expect(find.text('CONTINUE YOUR PATH'), findsOneWidget);
    // Module 1 done → module 2 is next up.
    expect(find.text('Foundations module 2'), findsWidgets);
    expect(find.textContaining('Module 2 of 8'), findsOneWidget);
  });

  testWidgets('Deepening shows LOCKED until 4 Foundations are done',
      (tester) async {
    await _pump(tester, foundationsDone: 2);
    expect(find.text('LOCKED'), findsOneWidget);
    expect(find.textContaining('Complete 2 more'), findsOneWidget);
  });

  testWidgets('Deepening unlocks once 4 Foundations are done', (tester) async {
    await _pump(tester, foundationsDone: 4);
    expect(find.text('LOCKED'), findsNothing);
  });

  testWidgets('dark theme pumps without exception', (tester) async {
    await _pump(tester, brightness: Brightness.dark);
    expect(tester.takeException(), isNull);
  });
}
