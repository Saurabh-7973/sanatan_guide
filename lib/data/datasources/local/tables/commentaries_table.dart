import 'package:drift/drift.dart';

/// Scholarly commentary attached to a verse (e.g. Shankara's Gītābhāṣya).
///
/// One verse may have multiple rows — each row pins a single (tradition,
/// author) pair so UIs can group or tab by tradition.
///
/// Provenance columns ([sourceUrl], [translator], [license]) are mandatory
/// so every shipped row is auditable against a public-domain source.
class CommentariesTable extends Table {
  @override
  String get tableName => 'commentaries';

  TextColumn get id => text()();

  TextColumn get verseId => text()();

  /// One of: 'advaita', 'vishishtadvaita', 'dvaita', 'other'.
  /// Kept as a string (not enum) so new traditions don't need a migration.
  TextColumn get tradition => text()();

  TextColumn get author => text()();

  TextColumn get textEnglish => text().nullable()();

  TextColumn get textSanskrit => text().nullable()();

  /// Named translator of [textEnglish] (null when Sanskrit-only).
  TextColumn get translator => text().nullable()();

  TextColumn get sourceUrl => text()();

  /// One of: 'public_domain', 'cc_by', 'cc_by_sa'.
  /// Any other value is a bug — seed tool refuses to insert it.
  TextColumn get license => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
