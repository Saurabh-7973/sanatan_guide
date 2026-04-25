import 'package:drift/drift.dart';

class ModuleCardsTable extends Table {
  @override
  String get tableName => 'module_cards';

  TextColumn get id => text()(); // 'mod_01_card_01'
  TextColumn get moduleId => text()(); // FK to learning_modules.id
  IntColumn get sequence => integer()(); // Card order within module (1-based)
  TextColumn get cardTitle => text()(); // Card heading
  TextColumn get content => text()(); // Card body text

  @override
  Set<Column> get primaryKey => {id};
}
