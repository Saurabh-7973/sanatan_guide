import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_module.freezed.dart';

/// A single learning module — the container.
@freezed
sealed class LearningModule with _$LearningModule {
  const factory LearningModule({
    required String id,
    required String title,
    required String hook,
    required int level,
    required int sequence,
    required int estimatedMinutes,
    required int cardCount,
    @Default(false) bool isCompleted,
    @Default(0) int cardsRead,
  }) = _LearningModule;
}

/// A single card within a module.
@freezed
sealed class ModuleCard with _$ModuleCard {
  const factory ModuleCard({
    required String id,
    required String moduleId,
    required int sequence,
    required String cardTitle,
    required String content,
  }) = _ModuleCard;
}

/// Complete module data — module + all its cards + anchor + reflection.
/// This is what the card stack reader receives.
@freezed
sealed class ModuleDetail with _$ModuleDetail {
  const factory ModuleDetail({
    required LearningModule module,
    required List<ModuleCard> cards,
    String? anchorVerseId,
    String? anchorVerseNote,
    String? reflectionQuestion,
  }) = _ModuleDetail;
}
