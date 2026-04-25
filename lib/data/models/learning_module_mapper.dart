import 'package:sanatan_guide/data/datasources/local/app_database.dart';
import 'package:sanatan_guide/domain/entities/learning_module.dart';

/// Maps Drift learning rows to domain entities.
abstract final class LearningModuleMapper {
  static LearningModule moduleWithProgress(
    LearningModulesTableData row, {
    required int cardsRead,
    required bool isCompleted,
  }) {
    return LearningModule(
      id: row.id,
      title: row.title,
      hook: row.hook,
      level: row.level,
      sequence: row.sequence,
      estimatedMinutes: row.estimatedMinutes,
      cardCount: row.cardCount,
      isCompleted: isCompleted,
      cardsRead: cardsRead,
    );
  }

  static ModuleCard fromCardRow(ModuleCardsTableData row) {
    return ModuleCard(
      id: row.id,
      moduleId: row.moduleId,
      sequence: row.sequence,
      cardTitle: row.cardTitle,
      content: row.content,
    );
  }
}
