import 'package:drift/drift.dart';

class LearningModulesTable extends Table {
  @override
  String get tableName => 'learning_modules';

  TextColumn get id => text()(); // 'mod_01' through 'mod_08'
  TextColumn get title => text()(); // Module title
  TextColumn get hook => text()(); // Opening hook question/statement
  IntColumn get level =>
      integer()(); // 1 = Beginner, 2 = Intermediate, 3 = Advanced
  IntColumn get sequence =>
      integer()(); // Order within level (1-8 for beginner)
  IntColumn get estimatedMinutes => integer()();
  IntColumn get cardCount => integer()(); // Total cards in this module

  @override
  Set<Column> get primaryKey => {id};
}
