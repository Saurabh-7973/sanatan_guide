import 'package:drift/drift.dart';

// Stores anchor verse and reflection question per module.
// One row per module. Using a single table for both to keep queries simple.

class ModuleExtrasTable extends Table {
  @override
  String get tableName => 'module_extras';

  TextColumn get moduleId => text()(); // FK to learning_modules.id
  TextColumn get anchorVerseId => text().nullable()(); // e.g. 'BG.4.7'
  TextColumn get anchorVerseNote => text().nullable()();
  TextColumn get reflectionQuestion => text().nullable()();

  @override
  Set<Column> get primaryKey => {moduleId};
}
