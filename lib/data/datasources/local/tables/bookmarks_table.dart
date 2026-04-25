import 'package:drift/drift.dart';

class BookmarksTable extends Table {
  @override
  String get tableName => 'bookmarks';

  TextColumn get verseId => text()(); // e.g. 'BG.2.47'
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {verseId};
}
