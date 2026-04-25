import 'package:drift/drift.dart';

class UserModuleProgressTable extends Table {
  @override
  String get tableName => 'user_module_progress';

  TextColumn get moduleId => text()(); // FK to learning_modules.id
  IntColumn get cardsRead => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {moduleId};
}
