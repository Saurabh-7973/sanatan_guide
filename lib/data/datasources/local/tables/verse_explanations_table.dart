import 'package:drift/drift.dart';

/// AI-generated plain-English explanations (e.g. Gemini), keyed by [verseId].
class VerseExplanationsTable extends Table {
  @override
  String get tableName => 'verse_explanations';

  TextColumn get verseId => text()();

  TextColumn get explanationText => text()();

  DateTimeColumn get generatedAt => dateTime()();

  TextColumn get modelVersion => text()();

  @override
  Set<Column> get primaryKey => {verseId};
}
