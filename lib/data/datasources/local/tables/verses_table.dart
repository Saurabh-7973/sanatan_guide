import 'package:drift/drift.dart';

class VersesTable extends Table {
  @override
  String get tableName => 'verses';

  TextColumn get id => text()();

  IntColumn get chapterNum => integer()();

  IntColumn get verseNum => integer()();

  TextColumn get scripture => text()();

  TextColumn get sanskrit => text()();

  TextColumn get transliteration => text().nullable()();

  TextColumn get hindi => text().nullable()();

  TextColumn get english => text().nullable()();

  TextColumn get wordMeaning => text().nullable()();

  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();

  IntColumn get readCount => integer().withDefault(const Constant(0))();

  TextColumn get noteText => text().nullable()(); // User's personal note on this verse

  // Multi-scripture support (added schema v5)
  // bookNum: Parva for Mahabharata, Kanda for Ramayana,
  //          Mandala for Rigveda, Skandha for Puranas
  IntColumn get bookNum => integer().nullable()();

  // Human-readable chapter/section name
  // e.g. "Bhishma Parva", "Bala Kanda", "Mandukya Upanishad"
  TextColumn get chapterLabel => text().nullable()();

  // PD translator identifier
  // e.g. "griffith", "ganguli", "muller", "arnold", "telang",
  //      "swarupananda", "wilson", "buhler", "vivekananda"
  TextColumn get translation => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
