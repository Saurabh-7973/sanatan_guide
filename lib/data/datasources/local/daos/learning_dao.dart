import 'package:drift/drift.dart';
import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/data/datasources/local/tables/learning_modules_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/module_cards_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/module_extras_table.dart';
import 'package:sanatan_guide/data/datasources/local/tables/user_module_progress_table.dart';

part 'learning_dao.g.dart';

@DriftAccessor(
  tables: [
    LearningModulesTable,
    ModuleCardsTable,
    ModuleExtrasTable,
    UserModuleProgressTable,
  ],
)
class LearningDao extends DatabaseAccessor<AppDatabase> with _$LearningDaoMixin {
  LearningDao(super.db);

  Future<List<LearningModulesTableData>> getAllModulesOrdered() =>
      (select(learningModulesTable)
            ..orderBy([
              (t) => OrderingTerm(expression: t.level),
              (t) => OrderingTerm(expression: t.sequence),
            ]))
          .get();

  Future<List<UserModuleProgressTableData>> getAllProgress() =>
      select(userModuleProgressTable).get();

  Future<UserModuleProgressTableData?> getProgress(String moduleId) =>
      (select(userModuleProgressTable)
            ..where((t) => t.moduleId.equals(moduleId)))
          .getSingleOrNull();

  Future<LearningModulesTableData?> getModuleById(String id) =>
      (select(learningModulesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<ModuleCardsTableData>> getCardsForModule(String moduleId) =>
      (select(moduleCardsTable)
            ..where((t) => t.moduleId.equals(moduleId))
            ..orderBy([(t) => OrderingTerm(expression: t.sequence)]))
          .get();

  Future<ModuleExtrasTableData?> getExtrasForModule(String moduleId) =>
      (select(moduleExtrasTable)..where((t) => t.moduleId.equals(moduleId)))
          .getSingleOrNull();

  /// Emits whenever [learningModulesTable] or [userModuleProgressTable] changes.
  Stream<void> watchModulesOrProgress() {
    return (select(learningModulesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.level),
            (t) => OrderingTerm(expression: t.sequence),
          ]))
        .watch()
        .map((_) {});
  }

  /// Also listen to progress table — merge by watching both.
  Stream<void> watchProgressChanges() =>
      select(userModuleProgressTable).watch().map((_) {});

  Future<void> markCardRead({
    required String moduleId,
    required int cardSequence,
  }) async {
    final existing = await getProgress(moduleId);
    final existingRead = existing?.cardsRead ?? 0;
    final newRead = existingRead > cardSequence ? existingRead : cardSequence;
    final now = DateTime.now();
    final startedAt = existing?.startedAt ?? now;

    await into(userModuleProgressTable).insertOnConflictUpdate(
      UserModuleProgressTableCompanion.insert(
        moduleId: moduleId,
        cardsRead: Value(newRead),
        isCompleted: Value(existing?.isCompleted ?? false),
        startedAt: Value(startedAt),
        completedAt: existing?.completedAt != null
            ? Value(existing!.completedAt)
            : const Value.absent(),
      ),
    );
  }

  Future<void> completeModule(String moduleId) async {
    final existing = await getProgress(moduleId);
    final now = DateTime.now();
    if (existing == null) {
      await into(userModuleProgressTable).insert(
        UserModuleProgressTableCompanion.insert(
          moduleId: moduleId,
          cardsRead: const Value(0),
          isCompleted: const Value(true),
          startedAt: Value(now),
          completedAt: Value(now),
        ),
      );
    } else {
      await (update(userModuleProgressTable)
            ..where((t) => t.moduleId.equals(moduleId)))
          .write(
        UserModuleProgressTableCompanion(
          isCompleted: const Value(true),
          completedAt: Value(now),
        ),
      );
    }
  }
}
