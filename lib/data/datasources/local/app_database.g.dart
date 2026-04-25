// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VersesTableTable extends VersesTable
    with TableInfo<$VersesTableTable, VersesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumMeta =
      const VerificationMeta('chapterNum');
  @override
  late final GeneratedColumn<int> chapterNum = GeneratedColumn<int>(
      'chapter_num', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verseNumMeta =
      const VerificationMeta('verseNum');
  @override
  late final GeneratedColumn<int> verseNum = GeneratedColumn<int>(
      'verse_num', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scriptureMeta =
      const VerificationMeta('scripture');
  @override
  late final GeneratedColumn<String> scripture = GeneratedColumn<String>(
      'scripture', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sanskritMeta =
      const VerificationMeta('sanskrit');
  @override
  late final GeneratedColumn<String> sanskrit = GeneratedColumn<String>(
      'sanskrit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _transliterationMeta =
      const VerificationMeta('transliteration');
  @override
  late final GeneratedColumn<String> transliteration = GeneratedColumn<String>(
      'transliteration', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hindiMeta = const VerificationMeta('hindi');
  @override
  late final GeneratedColumn<String> hindi = GeneratedColumn<String>(
      'hindi', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _englishMeta =
      const VerificationMeta('english');
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
      'english', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wordMeaningMeta =
      const VerificationMeta('wordMeaning');
  @override
  late final GeneratedColumn<String> wordMeaning = GeneratedColumn<String>(
      'word_meaning', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBookmarkedMeta =
      const VerificationMeta('isBookmarked');
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
      'is_bookmarked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_bookmarked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _readCountMeta =
      const VerificationMeta('readCount');
  @override
  late final GeneratedColumn<int> readCount = GeneratedColumn<int>(
      'read_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noteTextMeta =
      const VerificationMeta('noteText');
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
      'note_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bookNumMeta =
      const VerificationMeta('bookNum');
  @override
  late final GeneratedColumn<int> bookNum = GeneratedColumn<int>(
      'book_num', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _chapterLabelMeta =
      const VerificationMeta('chapterLabel');
  @override
  late final GeneratedColumn<String> chapterLabel = GeneratedColumn<String>(
      'chapter_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _translationMeta =
      const VerificationMeta('translation');
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
      'translation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        chapterNum,
        verseNum,
        scripture,
        sanskrit,
        transliteration,
        hindi,
        english,
        wordMeaning,
        isBookmarked,
        readCount,
        noteText,
        bookNum,
        chapterLabel,
        translation,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verses';
  @override
  VerificationContext validateIntegrity(Insertable<VersesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('chapter_num')) {
      context.handle(
          _chapterNumMeta,
          chapterNum.isAcceptableOrUnknown(
              data['chapter_num']!, _chapterNumMeta));
    } else if (isInserting) {
      context.missing(_chapterNumMeta);
    }
    if (data.containsKey('verse_num')) {
      context.handle(_verseNumMeta,
          verseNum.isAcceptableOrUnknown(data['verse_num']!, _verseNumMeta));
    } else if (isInserting) {
      context.missing(_verseNumMeta);
    }
    if (data.containsKey('scripture')) {
      context.handle(_scriptureMeta,
          scripture.isAcceptableOrUnknown(data['scripture']!, _scriptureMeta));
    } else if (isInserting) {
      context.missing(_scriptureMeta);
    }
    if (data.containsKey('sanskrit')) {
      context.handle(_sanskritMeta,
          sanskrit.isAcceptableOrUnknown(data['sanskrit']!, _sanskritMeta));
    } else if (isInserting) {
      context.missing(_sanskritMeta);
    }
    if (data.containsKey('transliteration')) {
      context.handle(
          _transliterationMeta,
          transliteration.isAcceptableOrUnknown(
              data['transliteration']!, _transliterationMeta));
    }
    if (data.containsKey('hindi')) {
      context.handle(
          _hindiMeta, hindi.isAcceptableOrUnknown(data['hindi']!, _hindiMeta));
    }
    if (data.containsKey('english')) {
      context.handle(_englishMeta,
          english.isAcceptableOrUnknown(data['english']!, _englishMeta));
    }
    if (data.containsKey('word_meaning')) {
      context.handle(
          _wordMeaningMeta,
          wordMeaning.isAcceptableOrUnknown(
              data['word_meaning']!, _wordMeaningMeta));
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
          _isBookmarkedMeta,
          isBookmarked.isAcceptableOrUnknown(
              data['is_bookmarked']!, _isBookmarkedMeta));
    }
    if (data.containsKey('read_count')) {
      context.handle(_readCountMeta,
          readCount.isAcceptableOrUnknown(data['read_count']!, _readCountMeta));
    }
    if (data.containsKey('note_text')) {
      context.handle(_noteTextMeta,
          noteText.isAcceptableOrUnknown(data['note_text']!, _noteTextMeta));
    }
    if (data.containsKey('book_num')) {
      context.handle(_bookNumMeta,
          bookNum.isAcceptableOrUnknown(data['book_num']!, _bookNumMeta));
    }
    if (data.containsKey('chapter_label')) {
      context.handle(
          _chapterLabelMeta,
          chapterLabel.isAcceptableOrUnknown(
              data['chapter_label']!, _chapterLabelMeta));
    }
    if (data.containsKey('translation')) {
      context.handle(
          _translationMeta,
          translation.isAcceptableOrUnknown(
              data['translation']!, _translationMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VersesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VersesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      chapterNum: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_num'])!,
      verseNum: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verse_num'])!,
      scripture: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scripture'])!,
      sanskrit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sanskrit'])!,
      transliteration: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transliteration']),
      hindi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hindi']),
      english: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}english']),
      wordMeaning: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}word_meaning']),
      isBookmarked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_bookmarked'])!,
      readCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}read_count'])!,
      noteText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_text']),
      bookNum: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_num']),
      chapterLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_label']),
      translation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translation']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $VersesTableTable createAlias(String alias) {
    return $VersesTableTable(attachedDatabase, alias);
  }
}

class VersesTableData extends DataClass implements Insertable<VersesTableData> {
  final String id;
  final int chapterNum;
  final int verseNum;
  final String scripture;
  final String sanskrit;
  final String? transliteration;
  final String? hindi;
  final String? english;
  final String? wordMeaning;
  final bool isBookmarked;
  final int readCount;
  final String? noteText;
  final int? bookNum;
  final String? chapterLabel;
  final String? translation;
  final DateTime createdAt;
  const VersesTableData(
      {required this.id,
      required this.chapterNum,
      required this.verseNum,
      required this.scripture,
      required this.sanskrit,
      this.transliteration,
      this.hindi,
      this.english,
      this.wordMeaning,
      required this.isBookmarked,
      required this.readCount,
      this.noteText,
      this.bookNum,
      this.chapterLabel,
      this.translation,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['chapter_num'] = Variable<int>(chapterNum);
    map['verse_num'] = Variable<int>(verseNum);
    map['scripture'] = Variable<String>(scripture);
    map['sanskrit'] = Variable<String>(sanskrit);
    if (!nullToAbsent || transliteration != null) {
      map['transliteration'] = Variable<String>(transliteration);
    }
    if (!nullToAbsent || hindi != null) {
      map['hindi'] = Variable<String>(hindi);
    }
    if (!nullToAbsent || english != null) {
      map['english'] = Variable<String>(english);
    }
    if (!nullToAbsent || wordMeaning != null) {
      map['word_meaning'] = Variable<String>(wordMeaning);
    }
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    map['read_count'] = Variable<int>(readCount);
    if (!nullToAbsent || noteText != null) {
      map['note_text'] = Variable<String>(noteText);
    }
    if (!nullToAbsent || bookNum != null) {
      map['book_num'] = Variable<int>(bookNum);
    }
    if (!nullToAbsent || chapterLabel != null) {
      map['chapter_label'] = Variable<String>(chapterLabel);
    }
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VersesTableCompanion toCompanion(bool nullToAbsent) {
    return VersesTableCompanion(
      id: Value(id),
      chapterNum: Value(chapterNum),
      verseNum: Value(verseNum),
      scripture: Value(scripture),
      sanskrit: Value(sanskrit),
      transliteration: transliteration == null && nullToAbsent
          ? const Value.absent()
          : Value(transliteration),
      hindi:
          hindi == null && nullToAbsent ? const Value.absent() : Value(hindi),
      english: english == null && nullToAbsent
          ? const Value.absent()
          : Value(english),
      wordMeaning: wordMeaning == null && nullToAbsent
          ? const Value.absent()
          : Value(wordMeaning),
      isBookmarked: Value(isBookmarked),
      readCount: Value(readCount),
      noteText: noteText == null && nullToAbsent
          ? const Value.absent()
          : Value(noteText),
      bookNum: bookNum == null && nullToAbsent
          ? const Value.absent()
          : Value(bookNum),
      chapterLabel: chapterLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterLabel),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      createdAt: Value(createdAt),
    );
  }

  factory VersesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VersesTableData(
      id: serializer.fromJson<String>(json['id']),
      chapterNum: serializer.fromJson<int>(json['chapterNum']),
      verseNum: serializer.fromJson<int>(json['verseNum']),
      scripture: serializer.fromJson<String>(json['scripture']),
      sanskrit: serializer.fromJson<String>(json['sanskrit']),
      transliteration: serializer.fromJson<String?>(json['transliteration']),
      hindi: serializer.fromJson<String?>(json['hindi']),
      english: serializer.fromJson<String?>(json['english']),
      wordMeaning: serializer.fromJson<String?>(json['wordMeaning']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      readCount: serializer.fromJson<int>(json['readCount']),
      noteText: serializer.fromJson<String?>(json['noteText']),
      bookNum: serializer.fromJson<int?>(json['bookNum']),
      chapterLabel: serializer.fromJson<String?>(json['chapterLabel']),
      translation: serializer.fromJson<String?>(json['translation']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'chapterNum': serializer.toJson<int>(chapterNum),
      'verseNum': serializer.toJson<int>(verseNum),
      'scripture': serializer.toJson<String>(scripture),
      'sanskrit': serializer.toJson<String>(sanskrit),
      'transliteration': serializer.toJson<String?>(transliteration),
      'hindi': serializer.toJson<String?>(hindi),
      'english': serializer.toJson<String?>(english),
      'wordMeaning': serializer.toJson<String?>(wordMeaning),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'readCount': serializer.toJson<int>(readCount),
      'noteText': serializer.toJson<String?>(noteText),
      'bookNum': serializer.toJson<int?>(bookNum),
      'chapterLabel': serializer.toJson<String?>(chapterLabel),
      'translation': serializer.toJson<String?>(translation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VersesTableData copyWith(
          {String? id,
          int? chapterNum,
          int? verseNum,
          String? scripture,
          String? sanskrit,
          Value<String?> transliteration = const Value.absent(),
          Value<String?> hindi = const Value.absent(),
          Value<String?> english = const Value.absent(),
          Value<String?> wordMeaning = const Value.absent(),
          bool? isBookmarked,
          int? readCount,
          Value<String?> noteText = const Value.absent(),
          Value<int?> bookNum = const Value.absent(),
          Value<String?> chapterLabel = const Value.absent(),
          Value<String?> translation = const Value.absent(),
          DateTime? createdAt}) =>
      VersesTableData(
        id: id ?? this.id,
        chapterNum: chapterNum ?? this.chapterNum,
        verseNum: verseNum ?? this.verseNum,
        scripture: scripture ?? this.scripture,
        sanskrit: sanskrit ?? this.sanskrit,
        transliteration: transliteration.present
            ? transliteration.value
            : this.transliteration,
        hindi: hindi.present ? hindi.value : this.hindi,
        english: english.present ? english.value : this.english,
        wordMeaning: wordMeaning.present ? wordMeaning.value : this.wordMeaning,
        isBookmarked: isBookmarked ?? this.isBookmarked,
        readCount: readCount ?? this.readCount,
        noteText: noteText.present ? noteText.value : this.noteText,
        bookNum: bookNum.present ? bookNum.value : this.bookNum,
        chapterLabel:
            chapterLabel.present ? chapterLabel.value : this.chapterLabel,
        translation: translation.present ? translation.value : this.translation,
        createdAt: createdAt ?? this.createdAt,
      );
  VersesTableData copyWithCompanion(VersesTableCompanion data) {
    return VersesTableData(
      id: data.id.present ? data.id.value : this.id,
      chapterNum:
          data.chapterNum.present ? data.chapterNum.value : this.chapterNum,
      verseNum: data.verseNum.present ? data.verseNum.value : this.verseNum,
      scripture: data.scripture.present ? data.scripture.value : this.scripture,
      sanskrit: data.sanskrit.present ? data.sanskrit.value : this.sanskrit,
      transliteration: data.transliteration.present
          ? data.transliteration.value
          : this.transliteration,
      hindi: data.hindi.present ? data.hindi.value : this.hindi,
      english: data.english.present ? data.english.value : this.english,
      wordMeaning:
          data.wordMeaning.present ? data.wordMeaning.value : this.wordMeaning,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      readCount: data.readCount.present ? data.readCount.value : this.readCount,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      bookNum: data.bookNum.present ? data.bookNum.value : this.bookNum,
      chapterLabel: data.chapterLabel.present
          ? data.chapterLabel.value
          : this.chapterLabel,
      translation:
          data.translation.present ? data.translation.value : this.translation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VersesTableData(')
          ..write('id: $id, ')
          ..write('chapterNum: $chapterNum, ')
          ..write('verseNum: $verseNum, ')
          ..write('scripture: $scripture, ')
          ..write('sanskrit: $sanskrit, ')
          ..write('transliteration: $transliteration, ')
          ..write('hindi: $hindi, ')
          ..write('english: $english, ')
          ..write('wordMeaning: $wordMeaning, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('readCount: $readCount, ')
          ..write('noteText: $noteText, ')
          ..write('bookNum: $bookNum, ')
          ..write('chapterLabel: $chapterLabel, ')
          ..write('translation: $translation, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      chapterNum,
      verseNum,
      scripture,
      sanskrit,
      transliteration,
      hindi,
      english,
      wordMeaning,
      isBookmarked,
      readCount,
      noteText,
      bookNum,
      chapterLabel,
      translation,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VersesTableData &&
          other.id == this.id &&
          other.chapterNum == this.chapterNum &&
          other.verseNum == this.verseNum &&
          other.scripture == this.scripture &&
          other.sanskrit == this.sanskrit &&
          other.transliteration == this.transliteration &&
          other.hindi == this.hindi &&
          other.english == this.english &&
          other.wordMeaning == this.wordMeaning &&
          other.isBookmarked == this.isBookmarked &&
          other.readCount == this.readCount &&
          other.noteText == this.noteText &&
          other.bookNum == this.bookNum &&
          other.chapterLabel == this.chapterLabel &&
          other.translation == this.translation &&
          other.createdAt == this.createdAt);
}

class VersesTableCompanion extends UpdateCompanion<VersesTableData> {
  final Value<String> id;
  final Value<int> chapterNum;
  final Value<int> verseNum;
  final Value<String> scripture;
  final Value<String> sanskrit;
  final Value<String?> transliteration;
  final Value<String?> hindi;
  final Value<String?> english;
  final Value<String?> wordMeaning;
  final Value<bool> isBookmarked;
  final Value<int> readCount;
  final Value<String?> noteText;
  final Value<int?> bookNum;
  final Value<String?> chapterLabel;
  final Value<String?> translation;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VersesTableCompanion({
    this.id = const Value.absent(),
    this.chapterNum = const Value.absent(),
    this.verseNum = const Value.absent(),
    this.scripture = const Value.absent(),
    this.sanskrit = const Value.absent(),
    this.transliteration = const Value.absent(),
    this.hindi = const Value.absent(),
    this.english = const Value.absent(),
    this.wordMeaning = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.readCount = const Value.absent(),
    this.noteText = const Value.absent(),
    this.bookNum = const Value.absent(),
    this.chapterLabel = const Value.absent(),
    this.translation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VersesTableCompanion.insert({
    required String id,
    required int chapterNum,
    required int verseNum,
    required String scripture,
    required String sanskrit,
    this.transliteration = const Value.absent(),
    this.hindi = const Value.absent(),
    this.english = const Value.absent(),
    this.wordMeaning = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.readCount = const Value.absent(),
    this.noteText = const Value.absent(),
    this.bookNum = const Value.absent(),
    this.chapterLabel = const Value.absent(),
    this.translation = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        chapterNum = Value(chapterNum),
        verseNum = Value(verseNum),
        scripture = Value(scripture),
        sanskrit = Value(sanskrit),
        createdAt = Value(createdAt);
  static Insertable<VersesTableData> custom({
    Expression<String>? id,
    Expression<int>? chapterNum,
    Expression<int>? verseNum,
    Expression<String>? scripture,
    Expression<String>? sanskrit,
    Expression<String>? transliteration,
    Expression<String>? hindi,
    Expression<String>? english,
    Expression<String>? wordMeaning,
    Expression<bool>? isBookmarked,
    Expression<int>? readCount,
    Expression<String>? noteText,
    Expression<int>? bookNum,
    Expression<String>? chapterLabel,
    Expression<String>? translation,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterNum != null) 'chapter_num': chapterNum,
      if (verseNum != null) 'verse_num': verseNum,
      if (scripture != null) 'scripture': scripture,
      if (sanskrit != null) 'sanskrit': sanskrit,
      if (transliteration != null) 'transliteration': transliteration,
      if (hindi != null) 'hindi': hindi,
      if (english != null) 'english': english,
      if (wordMeaning != null) 'word_meaning': wordMeaning,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (readCount != null) 'read_count': readCount,
      if (noteText != null) 'note_text': noteText,
      if (bookNum != null) 'book_num': bookNum,
      if (chapterLabel != null) 'chapter_label': chapterLabel,
      if (translation != null) 'translation': translation,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VersesTableCompanion copyWith(
      {Value<String>? id,
      Value<int>? chapterNum,
      Value<int>? verseNum,
      Value<String>? scripture,
      Value<String>? sanskrit,
      Value<String?>? transliteration,
      Value<String?>? hindi,
      Value<String?>? english,
      Value<String?>? wordMeaning,
      Value<bool>? isBookmarked,
      Value<int>? readCount,
      Value<String?>? noteText,
      Value<int?>? bookNum,
      Value<String?>? chapterLabel,
      Value<String?>? translation,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return VersesTableCompanion(
      id: id ?? this.id,
      chapterNum: chapterNum ?? this.chapterNum,
      verseNum: verseNum ?? this.verseNum,
      scripture: scripture ?? this.scripture,
      sanskrit: sanskrit ?? this.sanskrit,
      transliteration: transliteration ?? this.transliteration,
      hindi: hindi ?? this.hindi,
      english: english ?? this.english,
      wordMeaning: wordMeaning ?? this.wordMeaning,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      readCount: readCount ?? this.readCount,
      noteText: noteText ?? this.noteText,
      bookNum: bookNum ?? this.bookNum,
      chapterLabel: chapterLabel ?? this.chapterLabel,
      translation: translation ?? this.translation,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (chapterNum.present) {
      map['chapter_num'] = Variable<int>(chapterNum.value);
    }
    if (verseNum.present) {
      map['verse_num'] = Variable<int>(verseNum.value);
    }
    if (scripture.present) {
      map['scripture'] = Variable<String>(scripture.value);
    }
    if (sanskrit.present) {
      map['sanskrit'] = Variable<String>(sanskrit.value);
    }
    if (transliteration.present) {
      map['transliteration'] = Variable<String>(transliteration.value);
    }
    if (hindi.present) {
      map['hindi'] = Variable<String>(hindi.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (wordMeaning.present) {
      map['word_meaning'] = Variable<String>(wordMeaning.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (readCount.present) {
      map['read_count'] = Variable<int>(readCount.value);
    }
    if (noteText.present) {
      map['note_text'] = Variable<String>(noteText.value);
    }
    if (bookNum.present) {
      map['book_num'] = Variable<int>(bookNum.value);
    }
    if (chapterLabel.present) {
      map['chapter_label'] = Variable<String>(chapterLabel.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersesTableCompanion(')
          ..write('id: $id, ')
          ..write('chapterNum: $chapterNum, ')
          ..write('verseNum: $verseNum, ')
          ..write('scripture: $scripture, ')
          ..write('sanskrit: $sanskrit, ')
          ..write('transliteration: $transliteration, ')
          ..write('hindi: $hindi, ')
          ..write('english: $english, ')
          ..write('wordMeaning: $wordMeaning, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('readCount: $readCount, ')
          ..write('noteText: $noteText, ')
          ..write('bookNum: $bookNum, ')
          ..write('chapterLabel: $chapterLabel, ')
          ..write('translation: $translation, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningModulesTableTable extends LearningModulesTable
    with TableInfo<$LearningModulesTableTable, LearningModulesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningModulesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hookMeta = const VerificationMeta('hook');
  @override
  late final GeneratedColumn<String> hook = GeneratedColumn<String>(
      'hook', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _estimatedMinutesMeta =
      const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
      'estimated_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardCountMeta =
      const VerificationMeta('cardCount');
  @override
  late final GeneratedColumn<int> cardCount = GeneratedColumn<int>(
      'card_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, hook, level, sequence, estimatedMinutes, cardCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_modules';
  @override
  VerificationContext validateIntegrity(
      Insertable<LearningModulesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('hook')) {
      context.handle(
          _hookMeta, hook.isAcceptableOrUnknown(data['hook']!, _hookMeta));
    } else if (isInserting) {
      context.missing(_hookMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
          _estimatedMinutesMeta,
          estimatedMinutes.isAcceptableOrUnknown(
              data['estimated_minutes']!, _estimatedMinutesMeta));
    } else if (isInserting) {
      context.missing(_estimatedMinutesMeta);
    }
    if (data.containsKey('card_count')) {
      context.handle(_cardCountMeta,
          cardCount.isAcceptableOrUnknown(data['card_count']!, _cardCountMeta));
    } else if (isInserting) {
      context.missing(_cardCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LearningModulesTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningModulesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      hook: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hook'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      estimatedMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_minutes'])!,
      cardCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_count'])!,
    );
  }

  @override
  $LearningModulesTableTable createAlias(String alias) {
    return $LearningModulesTableTable(attachedDatabase, alias);
  }
}

class LearningModulesTableData extends DataClass
    implements Insertable<LearningModulesTableData> {
  final String id;
  final String title;
  final String hook;
  final int level;
  final int sequence;
  final int estimatedMinutes;
  final int cardCount;
  const LearningModulesTableData(
      {required this.id,
      required this.title,
      required this.hook,
      required this.level,
      required this.sequence,
      required this.estimatedMinutes,
      required this.cardCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['hook'] = Variable<String>(hook);
    map['level'] = Variable<int>(level);
    map['sequence'] = Variable<int>(sequence);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['card_count'] = Variable<int>(cardCount);
    return map;
  }

  LearningModulesTableCompanion toCompanion(bool nullToAbsent) {
    return LearningModulesTableCompanion(
      id: Value(id),
      title: Value(title),
      hook: Value(hook),
      level: Value(level),
      sequence: Value(sequence),
      estimatedMinutes: Value(estimatedMinutes),
      cardCount: Value(cardCount),
    );
  }

  factory LearningModulesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningModulesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      hook: serializer.fromJson<String>(json['hook']),
      level: serializer.fromJson<int>(json['level']),
      sequence: serializer.fromJson<int>(json['sequence']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      cardCount: serializer.fromJson<int>(json['cardCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'hook': serializer.toJson<String>(hook),
      'level': serializer.toJson<int>(level),
      'sequence': serializer.toJson<int>(sequence),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'cardCount': serializer.toJson<int>(cardCount),
    };
  }

  LearningModulesTableData copyWith(
          {String? id,
          String? title,
          String? hook,
          int? level,
          int? sequence,
          int? estimatedMinutes,
          int? cardCount}) =>
      LearningModulesTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        hook: hook ?? this.hook,
        level: level ?? this.level,
        sequence: sequence ?? this.sequence,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        cardCount: cardCount ?? this.cardCount,
      );
  LearningModulesTableData copyWithCompanion(
      LearningModulesTableCompanion data) {
    return LearningModulesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      hook: data.hook.present ? data.hook.value : this.hook,
      level: data.level.present ? data.level.value : this.level,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      cardCount: data.cardCount.present ? data.cardCount.value : this.cardCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningModulesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('hook: $hook, ')
          ..write('level: $level, ')
          ..write('sequence: $sequence, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('cardCount: $cardCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, title, hook, level, sequence, estimatedMinutes, cardCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningModulesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.hook == this.hook &&
          other.level == this.level &&
          other.sequence == this.sequence &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.cardCount == this.cardCount);
}

class LearningModulesTableCompanion
    extends UpdateCompanion<LearningModulesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> hook;
  final Value<int> level;
  final Value<int> sequence;
  final Value<int> estimatedMinutes;
  final Value<int> cardCount;
  final Value<int> rowid;
  const LearningModulesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.hook = const Value.absent(),
    this.level = const Value.absent(),
    this.sequence = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningModulesTableCompanion.insert({
    required String id,
    required String title,
    required String hook,
    required int level,
    required int sequence,
    required int estimatedMinutes,
    required int cardCount,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        hook = Value(hook),
        level = Value(level),
        sequence = Value(sequence),
        estimatedMinutes = Value(estimatedMinutes),
        cardCount = Value(cardCount);
  static Insertable<LearningModulesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? hook,
    Expression<int>? level,
    Expression<int>? sequence,
    Expression<int>? estimatedMinutes,
    Expression<int>? cardCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (hook != null) 'hook': hook,
      if (level != null) 'level': level,
      if (sequence != null) 'sequence': sequence,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (cardCount != null) 'card_count': cardCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningModulesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? hook,
      Value<int>? level,
      Value<int>? sequence,
      Value<int>? estimatedMinutes,
      Value<int>? cardCount,
      Value<int>? rowid}) {
    return LearningModulesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      hook: hook ?? this.hook,
      level: level ?? this.level,
      sequence: sequence ?? this.sequence,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      cardCount: cardCount ?? this.cardCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (hook.present) {
      map['hook'] = Variable<String>(hook.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (cardCount.present) {
      map['card_count'] = Variable<int>(cardCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningModulesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('hook: $hook, ')
          ..write('level: $level, ')
          ..write('sequence: $sequence, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('cardCount: $cardCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModuleCardsTableTable extends ModuleCardsTable
    with TableInfo<$ModuleCardsTableTable, ModuleCardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleCardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
      'module_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sequenceMeta =
      const VerificationMeta('sequence');
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
      'sequence', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardTitleMeta =
      const VerificationMeta('cardTitle');
  @override
  late final GeneratedColumn<String> cardTitle = GeneratedColumn<String>(
      'card_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, moduleId, sequence, cardTitle, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_cards';
  @override
  VerificationContext validateIntegrity(
      Insertable<ModuleCardsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(_sequenceMeta,
          sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta));
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('card_title')) {
      context.handle(_cardTitleMeta,
          cardTitle.isAcceptableOrUnknown(data['card_title']!, _cardTitleMeta));
    } else if (isInserting) {
      context.missing(_cardTitleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModuleCardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleCardsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module_id'])!,
      sequence: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence'])!,
      cardTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $ModuleCardsTableTable createAlias(String alias) {
    return $ModuleCardsTableTable(attachedDatabase, alias);
  }
}

class ModuleCardsTableData extends DataClass
    implements Insertable<ModuleCardsTableData> {
  final String id;
  final String moduleId;
  final int sequence;
  final String cardTitle;
  final String content;
  const ModuleCardsTableData(
      {required this.id,
      required this.moduleId,
      required this.sequence,
      required this.cardTitle,
      required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['module_id'] = Variable<String>(moduleId);
    map['sequence'] = Variable<int>(sequence);
    map['card_title'] = Variable<String>(cardTitle);
    map['content'] = Variable<String>(content);
    return map;
  }

  ModuleCardsTableCompanion toCompanion(bool nullToAbsent) {
    return ModuleCardsTableCompanion(
      id: Value(id),
      moduleId: Value(moduleId),
      sequence: Value(sequence),
      cardTitle: Value(cardTitle),
      content: Value(content),
    );
  }

  factory ModuleCardsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleCardsTableData(
      id: serializer.fromJson<String>(json['id']),
      moduleId: serializer.fromJson<String>(json['moduleId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      cardTitle: serializer.fromJson<String>(json['cardTitle']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'moduleId': serializer.toJson<String>(moduleId),
      'sequence': serializer.toJson<int>(sequence),
      'cardTitle': serializer.toJson<String>(cardTitle),
      'content': serializer.toJson<String>(content),
    };
  }

  ModuleCardsTableData copyWith(
          {String? id,
          String? moduleId,
          int? sequence,
          String? cardTitle,
          String? content}) =>
      ModuleCardsTableData(
        id: id ?? this.id,
        moduleId: moduleId ?? this.moduleId,
        sequence: sequence ?? this.sequence,
        cardTitle: cardTitle ?? this.cardTitle,
        content: content ?? this.content,
      );
  ModuleCardsTableData copyWithCompanion(ModuleCardsTableCompanion data) {
    return ModuleCardsTableData(
      id: data.id.present ? data.id.value : this.id,
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      cardTitle: data.cardTitle.present ? data.cardTitle.value : this.cardTitle,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleCardsTableData(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('sequence: $sequence, ')
          ..write('cardTitle: $cardTitle, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, moduleId, sequence, cardTitle, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleCardsTableData &&
          other.id == this.id &&
          other.moduleId == this.moduleId &&
          other.sequence == this.sequence &&
          other.cardTitle == this.cardTitle &&
          other.content == this.content);
}

class ModuleCardsTableCompanion extends UpdateCompanion<ModuleCardsTableData> {
  final Value<String> id;
  final Value<String> moduleId;
  final Value<int> sequence;
  final Value<String> cardTitle;
  final Value<String> content;
  final Value<int> rowid;
  const ModuleCardsTableCompanion({
    this.id = const Value.absent(),
    this.moduleId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.cardTitle = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModuleCardsTableCompanion.insert({
    required String id,
    required String moduleId,
    required int sequence,
    required String cardTitle,
    required String content,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        moduleId = Value(moduleId),
        sequence = Value(sequence),
        cardTitle = Value(cardTitle),
        content = Value(content);
  static Insertable<ModuleCardsTableData> custom({
    Expression<String>? id,
    Expression<String>? moduleId,
    Expression<int>? sequence,
    Expression<String>? cardTitle,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (moduleId != null) 'module_id': moduleId,
      if (sequence != null) 'sequence': sequence,
      if (cardTitle != null) 'card_title': cardTitle,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModuleCardsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? moduleId,
      Value<int>? sequence,
      Value<String>? cardTitle,
      Value<String>? content,
      Value<int>? rowid}) {
    return ModuleCardsTableCompanion(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      sequence: sequence ?? this.sequence,
      cardTitle: cardTitle ?? this.cardTitle,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (cardTitle.present) {
      map['card_title'] = Variable<String>(cardTitle.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleCardsTableCompanion(')
          ..write('id: $id, ')
          ..write('moduleId: $moduleId, ')
          ..write('sequence: $sequence, ')
          ..write('cardTitle: $cardTitle, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModuleExtrasTableTable extends ModuleExtrasTable
    with TableInfo<$ModuleExtrasTableTable, ModuleExtrasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModuleExtrasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
      'module_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _anchorVerseIdMeta =
      const VerificationMeta('anchorVerseId');
  @override
  late final GeneratedColumn<String> anchorVerseId = GeneratedColumn<String>(
      'anchor_verse_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _anchorVerseNoteMeta =
      const VerificationMeta('anchorVerseNote');
  @override
  late final GeneratedColumn<String> anchorVerseNote = GeneratedColumn<String>(
      'anchor_verse_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reflectionQuestionMeta =
      const VerificationMeta('reflectionQuestion');
  @override
  late final GeneratedColumn<String> reflectionQuestion =
      GeneratedColumn<String>('reflection_question', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [moduleId, anchorVerseId, anchorVerseNote, reflectionQuestion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'module_extras';
  @override
  VerificationContext validateIntegrity(
      Insertable<ModuleExtrasTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('anchor_verse_id')) {
      context.handle(
          _anchorVerseIdMeta,
          anchorVerseId.isAcceptableOrUnknown(
              data['anchor_verse_id']!, _anchorVerseIdMeta));
    }
    if (data.containsKey('anchor_verse_note')) {
      context.handle(
          _anchorVerseNoteMeta,
          anchorVerseNote.isAcceptableOrUnknown(
              data['anchor_verse_note']!, _anchorVerseNoteMeta));
    }
    if (data.containsKey('reflection_question')) {
      context.handle(
          _reflectionQuestionMeta,
          reflectionQuestion.isAcceptableOrUnknown(
              data['reflection_question']!, _reflectionQuestionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId};
  @override
  ModuleExtrasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleExtrasTableData(
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module_id'])!,
      anchorVerseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}anchor_verse_id']),
      anchorVerseNote: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}anchor_verse_note']),
      reflectionQuestion: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reflection_question']),
    );
  }

  @override
  $ModuleExtrasTableTable createAlias(String alias) {
    return $ModuleExtrasTableTable(attachedDatabase, alias);
  }
}

class ModuleExtrasTableData extends DataClass
    implements Insertable<ModuleExtrasTableData> {
  final String moduleId;
  final String? anchorVerseId;
  final String? anchorVerseNote;
  final String? reflectionQuestion;
  const ModuleExtrasTableData(
      {required this.moduleId,
      this.anchorVerseId,
      this.anchorVerseNote,
      this.reflectionQuestion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    if (!nullToAbsent || anchorVerseId != null) {
      map['anchor_verse_id'] = Variable<String>(anchorVerseId);
    }
    if (!nullToAbsent || anchorVerseNote != null) {
      map['anchor_verse_note'] = Variable<String>(anchorVerseNote);
    }
    if (!nullToAbsent || reflectionQuestion != null) {
      map['reflection_question'] = Variable<String>(reflectionQuestion);
    }
    return map;
  }

  ModuleExtrasTableCompanion toCompanion(bool nullToAbsent) {
    return ModuleExtrasTableCompanion(
      moduleId: Value(moduleId),
      anchorVerseId: anchorVerseId == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorVerseId),
      anchorVerseNote: anchorVerseNote == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorVerseNote),
      reflectionQuestion: reflectionQuestion == null && nullToAbsent
          ? const Value.absent()
          : Value(reflectionQuestion),
    );
  }

  factory ModuleExtrasTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleExtrasTableData(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      anchorVerseId: serializer.fromJson<String?>(json['anchorVerseId']),
      anchorVerseNote: serializer.fromJson<String?>(json['anchorVerseNote']),
      reflectionQuestion:
          serializer.fromJson<String?>(json['reflectionQuestion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'anchorVerseId': serializer.toJson<String?>(anchorVerseId),
      'anchorVerseNote': serializer.toJson<String?>(anchorVerseNote),
      'reflectionQuestion': serializer.toJson<String?>(reflectionQuestion),
    };
  }

  ModuleExtrasTableData copyWith(
          {String? moduleId,
          Value<String?> anchorVerseId = const Value.absent(),
          Value<String?> anchorVerseNote = const Value.absent(),
          Value<String?> reflectionQuestion = const Value.absent()}) =>
      ModuleExtrasTableData(
        moduleId: moduleId ?? this.moduleId,
        anchorVerseId:
            anchorVerseId.present ? anchorVerseId.value : this.anchorVerseId,
        anchorVerseNote: anchorVerseNote.present
            ? anchorVerseNote.value
            : this.anchorVerseNote,
        reflectionQuestion: reflectionQuestion.present
            ? reflectionQuestion.value
            : this.reflectionQuestion,
      );
  ModuleExtrasTableData copyWithCompanion(ModuleExtrasTableCompanion data) {
    return ModuleExtrasTableData(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      anchorVerseId: data.anchorVerseId.present
          ? data.anchorVerseId.value
          : this.anchorVerseId,
      anchorVerseNote: data.anchorVerseNote.present
          ? data.anchorVerseNote.value
          : this.anchorVerseNote,
      reflectionQuestion: data.reflectionQuestion.present
          ? data.reflectionQuestion.value
          : this.reflectionQuestion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleExtrasTableData(')
          ..write('moduleId: $moduleId, ')
          ..write('anchorVerseId: $anchorVerseId, ')
          ..write('anchorVerseNote: $anchorVerseNote, ')
          ..write('reflectionQuestion: $reflectionQuestion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(moduleId, anchorVerseId, anchorVerseNote, reflectionQuestion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleExtrasTableData &&
          other.moduleId == this.moduleId &&
          other.anchorVerseId == this.anchorVerseId &&
          other.anchorVerseNote == this.anchorVerseNote &&
          other.reflectionQuestion == this.reflectionQuestion);
}

class ModuleExtrasTableCompanion
    extends UpdateCompanion<ModuleExtrasTableData> {
  final Value<String> moduleId;
  final Value<String?> anchorVerseId;
  final Value<String?> anchorVerseNote;
  final Value<String?> reflectionQuestion;
  final Value<int> rowid;
  const ModuleExtrasTableCompanion({
    this.moduleId = const Value.absent(),
    this.anchorVerseId = const Value.absent(),
    this.anchorVerseNote = const Value.absent(),
    this.reflectionQuestion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModuleExtrasTableCompanion.insert({
    required String moduleId,
    this.anchorVerseId = const Value.absent(),
    this.anchorVerseNote = const Value.absent(),
    this.reflectionQuestion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : moduleId = Value(moduleId);
  static Insertable<ModuleExtrasTableData> custom({
    Expression<String>? moduleId,
    Expression<String>? anchorVerseId,
    Expression<String>? anchorVerseNote,
    Expression<String>? reflectionQuestion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (anchorVerseId != null) 'anchor_verse_id': anchorVerseId,
      if (anchorVerseNote != null) 'anchor_verse_note': anchorVerseNote,
      if (reflectionQuestion != null) 'reflection_question': reflectionQuestion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModuleExtrasTableCompanion copyWith(
      {Value<String>? moduleId,
      Value<String?>? anchorVerseId,
      Value<String?>? anchorVerseNote,
      Value<String?>? reflectionQuestion,
      Value<int>? rowid}) {
    return ModuleExtrasTableCompanion(
      moduleId: moduleId ?? this.moduleId,
      anchorVerseId: anchorVerseId ?? this.anchorVerseId,
      anchorVerseNote: anchorVerseNote ?? this.anchorVerseNote,
      reflectionQuestion: reflectionQuestion ?? this.reflectionQuestion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (anchorVerseId.present) {
      map['anchor_verse_id'] = Variable<String>(anchorVerseId.value);
    }
    if (anchorVerseNote.present) {
      map['anchor_verse_note'] = Variable<String>(anchorVerseNote.value);
    }
    if (reflectionQuestion.present) {
      map['reflection_question'] = Variable<String>(reflectionQuestion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModuleExtrasTableCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('anchorVerseId: $anchorVerseId, ')
          ..write('anchorVerseNote: $anchorVerseNote, ')
          ..write('reflectionQuestion: $reflectionQuestion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserModuleProgressTableTable extends UserModuleProgressTable
    with TableInfo<$UserModuleProgressTableTable, UserModuleProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserModuleProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _moduleIdMeta =
      const VerificationMeta('moduleId');
  @override
  late final GeneratedColumn<String> moduleId = GeneratedColumn<String>(
      'module_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardsReadMeta =
      const VerificationMeta('cardsRead');
  @override
  late final GeneratedColumn<int> cardsRead = GeneratedColumn<int>(
      'cards_read', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [moduleId, cardsRead, isCompleted, startedAt, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_module_progress';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserModuleProgressTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('module_id')) {
      context.handle(_moduleIdMeta,
          moduleId.isAcceptableOrUnknown(data['module_id']!, _moduleIdMeta));
    } else if (isInserting) {
      context.missing(_moduleIdMeta);
    }
    if (data.containsKey('cards_read')) {
      context.handle(_cardsReadMeta,
          cardsRead.isAcceptableOrUnknown(data['cards_read']!, _cardsReadMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {moduleId};
  @override
  UserModuleProgressTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserModuleProgressTableData(
      moduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module_id'])!,
      cardsRead: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cards_read'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $UserModuleProgressTableTable createAlias(String alias) {
    return $UserModuleProgressTableTable(attachedDatabase, alias);
  }
}

class UserModuleProgressTableData extends DataClass
    implements Insertable<UserModuleProgressTableData> {
  final String moduleId;
  final int cardsRead;
  final bool isCompleted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  const UserModuleProgressTableData(
      {required this.moduleId,
      required this.cardsRead,
      required this.isCompleted,
      this.startedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['module_id'] = Variable<String>(moduleId);
    map['cards_read'] = Variable<int>(cardsRead);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  UserModuleProgressTableCompanion toCompanion(bool nullToAbsent) {
    return UserModuleProgressTableCompanion(
      moduleId: Value(moduleId),
      cardsRead: Value(cardsRead),
      isCompleted: Value(isCompleted),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory UserModuleProgressTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserModuleProgressTableData(
      moduleId: serializer.fromJson<String>(json['moduleId']),
      cardsRead: serializer.fromJson<int>(json['cardsRead']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'moduleId': serializer.toJson<String>(moduleId),
      'cardsRead': serializer.toJson<int>(cardsRead),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  UserModuleProgressTableData copyWith(
          {String? moduleId,
          int? cardsRead,
          bool? isCompleted,
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent()}) =>
      UserModuleProgressTableData(
        moduleId: moduleId ?? this.moduleId,
        cardsRead: cardsRead ?? this.cardsRead,
        isCompleted: isCompleted ?? this.isCompleted,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  UserModuleProgressTableData copyWithCompanion(
      UserModuleProgressTableCompanion data) {
    return UserModuleProgressTableData(
      moduleId: data.moduleId.present ? data.moduleId.value : this.moduleId,
      cardsRead: data.cardsRead.present ? data.cardsRead.value : this.cardsRead,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserModuleProgressTableData(')
          ..write('moduleId: $moduleId, ')
          ..write('cardsRead: $cardsRead, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(moduleId, cardsRead, isCompleted, startedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModuleProgressTableData &&
          other.moduleId == this.moduleId &&
          other.cardsRead == this.cardsRead &&
          other.isCompleted == this.isCompleted &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class UserModuleProgressTableCompanion
    extends UpdateCompanion<UserModuleProgressTableData> {
  final Value<String> moduleId;
  final Value<int> cardsRead;
  final Value<bool> isCompleted;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const UserModuleProgressTableCompanion({
    this.moduleId = const Value.absent(),
    this.cardsRead = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserModuleProgressTableCompanion.insert({
    required String moduleId,
    this.cardsRead = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : moduleId = Value(moduleId);
  static Insertable<UserModuleProgressTableData> custom({
    Expression<String>? moduleId,
    Expression<int>? cardsRead,
    Expression<bool>? isCompleted,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (moduleId != null) 'module_id': moduleId,
      if (cardsRead != null) 'cards_read': cardsRead,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserModuleProgressTableCompanion copyWith(
      {Value<String>? moduleId,
      Value<int>? cardsRead,
      Value<bool>? isCompleted,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return UserModuleProgressTableCompanion(
      moduleId: moduleId ?? this.moduleId,
      cardsRead: cardsRead ?? this.cardsRead,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (moduleId.present) {
      map['module_id'] = Variable<String>(moduleId.value);
    }
    if (cardsRead.present) {
      map['cards_read'] = Variable<int>(cardsRead.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserModuleProgressTableCompanion(')
          ..write('moduleId: $moduleId, ')
          ..write('cardsRead: $cardsRead, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTableTable extends BookmarksTable
    with TableInfo<$BookmarksTableTable, BookmarksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseIdMeta =
      const VerificationMeta('verseId');
  @override
  late final GeneratedColumn<String> verseId = GeneratedColumn<String>(
      'verse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _savedAtMeta =
      const VerificationMeta('savedAt');
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
      'saved_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [verseId, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarksTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse_id')) {
      context.handle(_verseIdMeta,
          verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta));
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(_savedAtMeta,
          savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta));
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verseId};
  @override
  BookmarksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarksTableData(
      verseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse_id'])!,
      savedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}saved_at'])!,
    );
  }

  @override
  $BookmarksTableTable createAlias(String alias) {
    return $BookmarksTableTable(attachedDatabase, alias);
  }
}

class BookmarksTableData extends DataClass
    implements Insertable<BookmarksTableData> {
  final String verseId;
  final DateTime savedAt;
  const BookmarksTableData({required this.verseId, required this.savedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse_id'] = Variable<String>(verseId);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  BookmarksTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarksTableCompanion(
      verseId: Value(verseId),
      savedAt: Value(savedAt),
    );
  }

  factory BookmarksTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarksTableData(
      verseId: serializer.fromJson<String>(json['verseId']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verseId': serializer.toJson<String>(verseId),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  BookmarksTableData copyWith({String? verseId, DateTime? savedAt}) =>
      BookmarksTableData(
        verseId: verseId ?? this.verseId,
        savedAt: savedAt ?? this.savedAt,
      );
  BookmarksTableData copyWithCompanion(BookmarksTableCompanion data) {
    return BookmarksTableData(
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableData(')
          ..write('verseId: $verseId, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(verseId, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarksTableData &&
          other.verseId == this.verseId &&
          other.savedAt == this.savedAt);
}

class BookmarksTableCompanion extends UpdateCompanion<BookmarksTableData> {
  final Value<String> verseId;
  final Value<DateTime> savedAt;
  final Value<int> rowid;
  const BookmarksTableCompanion({
    this.verseId = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksTableCompanion.insert({
    required String verseId,
    required DateTime savedAt,
    this.rowid = const Value.absent(),
  })  : verseId = Value(verseId),
        savedAt = Value(savedAt);
  static Insertable<BookmarksTableData> custom({
    Expression<String>? verseId,
    Expression<DateTime>? savedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verseId != null) 'verse_id': verseId,
      if (savedAt != null) 'saved_at': savedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksTableCompanion copyWith(
      {Value<String>? verseId, Value<DateTime>? savedAt, Value<int>? rowid}) {
    return BookmarksTableCompanion(
      verseId: verseId ?? this.verseId,
      savedAt: savedAt ?? this.savedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verseId.present) {
      map['verse_id'] = Variable<String>(verseId.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableCompanion(')
          ..write('verseId: $verseId, ')
          ..write('savedAt: $savedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseExplanationsTableTable extends VerseExplanationsTable
    with TableInfo<$VerseExplanationsTableTable, VerseExplanationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseExplanationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseIdMeta =
      const VerificationMeta('verseId');
  @override
  late final GeneratedColumn<String> verseId = GeneratedColumn<String>(
      'verse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationTextMeta =
      const VerificationMeta('explanationText');
  @override
  late final GeneratedColumn<String> explanationText = GeneratedColumn<String>(
      'explanation_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _modelVersionMeta =
      const VerificationMeta('modelVersion');
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
      'model_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [verseId, explanationText, generatedAt, modelVersion];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_explanations';
  @override
  VerificationContext validateIntegrity(
      Insertable<VerseExplanationsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse_id')) {
      context.handle(_verseIdMeta,
          verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta));
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('explanation_text')) {
      context.handle(
          _explanationTextMeta,
          explanationText.isAcceptableOrUnknown(
              data['explanation_text']!, _explanationTextMeta));
    } else if (isInserting) {
      context.missing(_explanationTextMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
          _modelVersionMeta,
          modelVersion.isAcceptableOrUnknown(
              data['model_version']!, _modelVersionMeta));
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verseId};
  @override
  VerseExplanationsTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseExplanationsTableData(
      verseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse_id'])!,
      explanationText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}explanation_text'])!,
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
      modelVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_version'])!,
    );
  }

  @override
  $VerseExplanationsTableTable createAlias(String alias) {
    return $VerseExplanationsTableTable(attachedDatabase, alias);
  }
}

class VerseExplanationsTableData extends DataClass
    implements Insertable<VerseExplanationsTableData> {
  final String verseId;
  final String explanationText;
  final DateTime generatedAt;
  final String modelVersion;
  const VerseExplanationsTableData(
      {required this.verseId,
      required this.explanationText,
      required this.generatedAt,
      required this.modelVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse_id'] = Variable<String>(verseId);
    map['explanation_text'] = Variable<String>(explanationText);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['model_version'] = Variable<String>(modelVersion);
    return map;
  }

  VerseExplanationsTableCompanion toCompanion(bool nullToAbsent) {
    return VerseExplanationsTableCompanion(
      verseId: Value(verseId),
      explanationText: Value(explanationText),
      generatedAt: Value(generatedAt),
      modelVersion: Value(modelVersion),
    );
  }

  factory VerseExplanationsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseExplanationsTableData(
      verseId: serializer.fromJson<String>(json['verseId']),
      explanationText: serializer.fromJson<String>(json['explanationText']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verseId': serializer.toJson<String>(verseId),
      'explanationText': serializer.toJson<String>(explanationText),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'modelVersion': serializer.toJson<String>(modelVersion),
    };
  }

  VerseExplanationsTableData copyWith(
          {String? verseId,
          String? explanationText,
          DateTime? generatedAt,
          String? modelVersion}) =>
      VerseExplanationsTableData(
        verseId: verseId ?? this.verseId,
        explanationText: explanationText ?? this.explanationText,
        generatedAt: generatedAt ?? this.generatedAt,
        modelVersion: modelVersion ?? this.modelVersion,
      );
  VerseExplanationsTableData copyWithCompanion(
      VerseExplanationsTableCompanion data) {
    return VerseExplanationsTableData(
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      explanationText: data.explanationText.present
          ? data.explanationText.value
          : this.explanationText,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseExplanationsTableData(')
          ..write('verseId: $verseId, ')
          ..write('explanationText: $explanationText, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('modelVersion: $modelVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(verseId, explanationText, generatedAt, modelVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseExplanationsTableData &&
          other.verseId == this.verseId &&
          other.explanationText == this.explanationText &&
          other.generatedAt == this.generatedAt &&
          other.modelVersion == this.modelVersion);
}

class VerseExplanationsTableCompanion
    extends UpdateCompanion<VerseExplanationsTableData> {
  final Value<String> verseId;
  final Value<String> explanationText;
  final Value<DateTime> generatedAt;
  final Value<String> modelVersion;
  final Value<int> rowid;
  const VerseExplanationsTableCompanion({
    this.verseId = const Value.absent(),
    this.explanationText = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerseExplanationsTableCompanion.insert({
    required String verseId,
    required String explanationText,
    required DateTime generatedAt,
    required String modelVersion,
    this.rowid = const Value.absent(),
  })  : verseId = Value(verseId),
        explanationText = Value(explanationText),
        generatedAt = Value(generatedAt),
        modelVersion = Value(modelVersion);
  static Insertable<VerseExplanationsTableData> custom({
    Expression<String>? verseId,
    Expression<String>? explanationText,
    Expression<DateTime>? generatedAt,
    Expression<String>? modelVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verseId != null) 'verse_id': verseId,
      if (explanationText != null) 'explanation_text': explanationText,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (modelVersion != null) 'model_version': modelVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerseExplanationsTableCompanion copyWith(
      {Value<String>? verseId,
      Value<String>? explanationText,
      Value<DateTime>? generatedAt,
      Value<String>? modelVersion,
      Value<int>? rowid}) {
    return VerseExplanationsTableCompanion(
      verseId: verseId ?? this.verseId,
      explanationText: explanationText ?? this.explanationText,
      generatedAt: generatedAt ?? this.generatedAt,
      modelVersion: modelVersion ?? this.modelVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verseId.present) {
      map['verse_id'] = Variable<String>(verseId.value);
    }
    if (explanationText.present) {
      map['explanation_text'] = Variable<String>(explanationText.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseExplanationsTableCompanion(')
          ..write('verseId: $verseId, ')
          ..write('explanationText: $explanationText, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentariesTableTable extends CommentariesTable
    with TableInfo<$CommentariesTableTable, CommentariesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentariesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _verseIdMeta =
      const VerificationMeta('verseId');
  @override
  late final GeneratedColumn<String> verseId = GeneratedColumn<String>(
      'verse_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _traditionMeta =
      const VerificationMeta('tradition');
  @override
  late final GeneratedColumn<String> tradition = GeneratedColumn<String>(
      'tradition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textEnglishMeta =
      const VerificationMeta('textEnglish');
  @override
  late final GeneratedColumn<String> textEnglish = GeneratedColumn<String>(
      'text_english', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _textSanskritMeta =
      const VerificationMeta('textSanskrit');
  @override
  late final GeneratedColumn<String> textSanskrit = GeneratedColumn<String>(
      'text_sanskrit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _translatorMeta =
      const VerificationMeta('translator');
  @override
  late final GeneratedColumn<String> translator = GeneratedColumn<String>(
      'translator', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceUrlMeta =
      const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
      'source_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _licenseMeta =
      const VerificationMeta('license');
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
      'license', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        verseId,
        tradition,
        author,
        textEnglish,
        textSanskrit,
        translator,
        sourceUrl,
        license,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commentaries';
  @override
  VerificationContext validateIntegrity(
      Insertable<CommentariesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('verse_id')) {
      context.handle(_verseIdMeta,
          verseId.isAcceptableOrUnknown(data['verse_id']!, _verseIdMeta));
    } else if (isInserting) {
      context.missing(_verseIdMeta);
    }
    if (data.containsKey('tradition')) {
      context.handle(_traditionMeta,
          tradition.isAcceptableOrUnknown(data['tradition']!, _traditionMeta));
    } else if (isInserting) {
      context.missing(_traditionMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('text_english')) {
      context.handle(
          _textEnglishMeta,
          textEnglish.isAcceptableOrUnknown(
              data['text_english']!, _textEnglishMeta));
    }
    if (data.containsKey('text_sanskrit')) {
      context.handle(
          _textSanskritMeta,
          textSanskrit.isAcceptableOrUnknown(
              data['text_sanskrit']!, _textSanskritMeta));
    }
    if (data.containsKey('translator')) {
      context.handle(
          _translatorMeta,
          translator.isAcceptableOrUnknown(
              data['translator']!, _translatorMeta));
    }
    if (data.containsKey('source_url')) {
      context.handle(_sourceUrlMeta,
          sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta));
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('license')) {
      context.handle(_licenseMeta,
          license.isAcceptableOrUnknown(data['license']!, _licenseMeta));
    } else if (isInserting) {
      context.missing(_licenseMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CommentariesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentariesTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      verseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}verse_id'])!,
      tradition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tradition'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      textEnglish: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_english']),
      textSanskrit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_sanskrit']),
      translator: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translator']),
      sourceUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_url'])!,
      license: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}license'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CommentariesTableTable createAlias(String alias) {
    return $CommentariesTableTable(attachedDatabase, alias);
  }
}

class CommentariesTableData extends DataClass
    implements Insertable<CommentariesTableData> {
  final String id;
  final String verseId;

  /// One of: 'advaita', 'vishishtadvaita', 'dvaita', 'other'.
  /// Kept as a string (not enum) so new traditions don't need a migration.
  final String tradition;
  final String author;
  final String? textEnglish;
  final String? textSanskrit;

  /// Named translator of [textEnglish] (null when Sanskrit-only).
  final String? translator;
  final String sourceUrl;

  /// One of: 'public_domain', 'cc_by', 'cc_by_sa'.
  /// Any other value is a bug — seed tool refuses to insert it.
  final String license;
  final DateTime createdAt;
  const CommentariesTableData(
      {required this.id,
      required this.verseId,
      required this.tradition,
      required this.author,
      this.textEnglish,
      this.textSanskrit,
      this.translator,
      required this.sourceUrl,
      required this.license,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['verse_id'] = Variable<String>(verseId);
    map['tradition'] = Variable<String>(tradition);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || textEnglish != null) {
      map['text_english'] = Variable<String>(textEnglish);
    }
    if (!nullToAbsent || textSanskrit != null) {
      map['text_sanskrit'] = Variable<String>(textSanskrit);
    }
    if (!nullToAbsent || translator != null) {
      map['translator'] = Variable<String>(translator);
    }
    map['source_url'] = Variable<String>(sourceUrl);
    map['license'] = Variable<String>(license);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommentariesTableCompanion toCompanion(bool nullToAbsent) {
    return CommentariesTableCompanion(
      id: Value(id),
      verseId: Value(verseId),
      tradition: Value(tradition),
      author: Value(author),
      textEnglish: textEnglish == null && nullToAbsent
          ? const Value.absent()
          : Value(textEnglish),
      textSanskrit: textSanskrit == null && nullToAbsent
          ? const Value.absent()
          : Value(textSanskrit),
      translator: translator == null && nullToAbsent
          ? const Value.absent()
          : Value(translator),
      sourceUrl: Value(sourceUrl),
      license: Value(license),
      createdAt: Value(createdAt),
    );
  }

  factory CommentariesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentariesTableData(
      id: serializer.fromJson<String>(json['id']),
      verseId: serializer.fromJson<String>(json['verseId']),
      tradition: serializer.fromJson<String>(json['tradition']),
      author: serializer.fromJson<String>(json['author']),
      textEnglish: serializer.fromJson<String?>(json['textEnglish']),
      textSanskrit: serializer.fromJson<String?>(json['textSanskrit']),
      translator: serializer.fromJson<String?>(json['translator']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      license: serializer.fromJson<String>(json['license']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'verseId': serializer.toJson<String>(verseId),
      'tradition': serializer.toJson<String>(tradition),
      'author': serializer.toJson<String>(author),
      'textEnglish': serializer.toJson<String?>(textEnglish),
      'textSanskrit': serializer.toJson<String?>(textSanskrit),
      'translator': serializer.toJson<String?>(translator),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'license': serializer.toJson<String>(license),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CommentariesTableData copyWith(
          {String? id,
          String? verseId,
          String? tradition,
          String? author,
          Value<String?> textEnglish = const Value.absent(),
          Value<String?> textSanskrit = const Value.absent(),
          Value<String?> translator = const Value.absent(),
          String? sourceUrl,
          String? license,
          DateTime? createdAt}) =>
      CommentariesTableData(
        id: id ?? this.id,
        verseId: verseId ?? this.verseId,
        tradition: tradition ?? this.tradition,
        author: author ?? this.author,
        textEnglish: textEnglish.present ? textEnglish.value : this.textEnglish,
        textSanskrit:
            textSanskrit.present ? textSanskrit.value : this.textSanskrit,
        translator: translator.present ? translator.value : this.translator,
        sourceUrl: sourceUrl ?? this.sourceUrl,
        license: license ?? this.license,
        createdAt: createdAt ?? this.createdAt,
      );
  CommentariesTableData copyWithCompanion(CommentariesTableCompanion data) {
    return CommentariesTableData(
      id: data.id.present ? data.id.value : this.id,
      verseId: data.verseId.present ? data.verseId.value : this.verseId,
      tradition: data.tradition.present ? data.tradition.value : this.tradition,
      author: data.author.present ? data.author.value : this.author,
      textEnglish:
          data.textEnglish.present ? data.textEnglish.value : this.textEnglish,
      textSanskrit: data.textSanskrit.present
          ? data.textSanskrit.value
          : this.textSanskrit,
      translator:
          data.translator.present ? data.translator.value : this.translator,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      license: data.license.present ? data.license.value : this.license,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentariesTableData(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('tradition: $tradition, ')
          ..write('author: $author, ')
          ..write('textEnglish: $textEnglish, ')
          ..write('textSanskrit: $textSanskrit, ')
          ..write('translator: $translator, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('license: $license, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, verseId, tradition, author, textEnglish,
      textSanskrit, translator, sourceUrl, license, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentariesTableData &&
          other.id == this.id &&
          other.verseId == this.verseId &&
          other.tradition == this.tradition &&
          other.author == this.author &&
          other.textEnglish == this.textEnglish &&
          other.textSanskrit == this.textSanskrit &&
          other.translator == this.translator &&
          other.sourceUrl == this.sourceUrl &&
          other.license == this.license &&
          other.createdAt == this.createdAt);
}

class CommentariesTableCompanion
    extends UpdateCompanion<CommentariesTableData> {
  final Value<String> id;
  final Value<String> verseId;
  final Value<String> tradition;
  final Value<String> author;
  final Value<String?> textEnglish;
  final Value<String?> textSanskrit;
  final Value<String?> translator;
  final Value<String> sourceUrl;
  final Value<String> license;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CommentariesTableCompanion({
    this.id = const Value.absent(),
    this.verseId = const Value.absent(),
    this.tradition = const Value.absent(),
    this.author = const Value.absent(),
    this.textEnglish = const Value.absent(),
    this.textSanskrit = const Value.absent(),
    this.translator = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.license = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentariesTableCompanion.insert({
    required String id,
    required String verseId,
    required String tradition,
    required String author,
    this.textEnglish = const Value.absent(),
    this.textSanskrit = const Value.absent(),
    this.translator = const Value.absent(),
    required String sourceUrl,
    required String license,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        verseId = Value(verseId),
        tradition = Value(tradition),
        author = Value(author),
        sourceUrl = Value(sourceUrl),
        license = Value(license),
        createdAt = Value(createdAt);
  static Insertable<CommentariesTableData> custom({
    Expression<String>? id,
    Expression<String>? verseId,
    Expression<String>? tradition,
    Expression<String>? author,
    Expression<String>? textEnglish,
    Expression<String>? textSanskrit,
    Expression<String>? translator,
    Expression<String>? sourceUrl,
    Expression<String>? license,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (verseId != null) 'verse_id': verseId,
      if (tradition != null) 'tradition': tradition,
      if (author != null) 'author': author,
      if (textEnglish != null) 'text_english': textEnglish,
      if (textSanskrit != null) 'text_sanskrit': textSanskrit,
      if (translator != null) 'translator': translator,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (license != null) 'license': license,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentariesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? verseId,
      Value<String>? tradition,
      Value<String>? author,
      Value<String?>? textEnglish,
      Value<String?>? textSanskrit,
      Value<String?>? translator,
      Value<String>? sourceUrl,
      Value<String>? license,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CommentariesTableCompanion(
      id: id ?? this.id,
      verseId: verseId ?? this.verseId,
      tradition: tradition ?? this.tradition,
      author: author ?? this.author,
      textEnglish: textEnglish ?? this.textEnglish,
      textSanskrit: textSanskrit ?? this.textSanskrit,
      translator: translator ?? this.translator,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      license: license ?? this.license,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (verseId.present) {
      map['verse_id'] = Variable<String>(verseId.value);
    }
    if (tradition.present) {
      map['tradition'] = Variable<String>(tradition.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (textEnglish.present) {
      map['text_english'] = Variable<String>(textEnglish.value);
    }
    if (textSanskrit.present) {
      map['text_sanskrit'] = Variable<String>(textSanskrit.value);
    }
    if (translator.present) {
      map['translator'] = Variable<String>(translator.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentariesTableCompanion(')
          ..write('id: $id, ')
          ..write('verseId: $verseId, ')
          ..write('tradition: $tradition, ')
          ..write('author: $author, ')
          ..write('textEnglish: $textEnglish, ')
          ..write('textSanskrit: $textSanskrit, ')
          ..write('translator: $translator, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('license: $license, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VersesTableTable versesTable = $VersesTableTable(this);
  late final $LearningModulesTableTable learningModulesTable =
      $LearningModulesTableTable(this);
  late final $ModuleCardsTableTable moduleCardsTable =
      $ModuleCardsTableTable(this);
  late final $ModuleExtrasTableTable moduleExtrasTable =
      $ModuleExtrasTableTable(this);
  late final $UserModuleProgressTableTable userModuleProgressTable =
      $UserModuleProgressTableTable(this);
  late final $BookmarksTableTable bookmarksTable = $BookmarksTableTable(this);
  late final $VerseExplanationsTableTable verseExplanationsTable =
      $VerseExplanationsTableTable(this);
  late final $CommentariesTableTable commentariesTable =
      $CommentariesTableTable(this);
  late final ScriptureDao scriptureDao = ScriptureDao(this as AppDatabase);
  late final LearningDao learningDao = LearningDao(this as AppDatabase);
  late final BookmarksDao bookmarksDao = BookmarksDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        versesTable,
        learningModulesTable,
        moduleCardsTable,
        moduleExtrasTable,
        userModuleProgressTable,
        bookmarksTable,
        verseExplanationsTable,
        commentariesTable
      ];
}

typedef $$VersesTableTableCreateCompanionBuilder = VersesTableCompanion
    Function({
  required String id,
  required int chapterNum,
  required int verseNum,
  required String scripture,
  required String sanskrit,
  Value<String?> transliteration,
  Value<String?> hindi,
  Value<String?> english,
  Value<String?> wordMeaning,
  Value<bool> isBookmarked,
  Value<int> readCount,
  Value<String?> noteText,
  Value<int?> bookNum,
  Value<String?> chapterLabel,
  Value<String?> translation,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$VersesTableTableUpdateCompanionBuilder = VersesTableCompanion
    Function({
  Value<String> id,
  Value<int> chapterNum,
  Value<int> verseNum,
  Value<String> scripture,
  Value<String> sanskrit,
  Value<String?> transliteration,
  Value<String?> hindi,
  Value<String?> english,
  Value<String?> wordMeaning,
  Value<bool> isBookmarked,
  Value<int> readCount,
  Value<String?> noteText,
  Value<int?> bookNum,
  Value<String?> chapterLabel,
  Value<String?> translation,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$VersesTableTableFilterComposer
    extends Composer<_$AppDatabase, $VersesTableTable> {
  $$VersesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNum => $composableBuilder(
      column: $table.chapterNum, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get verseNum => $composableBuilder(
      column: $table.verseNum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scripture => $composableBuilder(
      column: $table.scripture, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sanskrit => $composableBuilder(
      column: $table.sanskrit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transliteration => $composableBuilder(
      column: $table.transliteration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hindi => $composableBuilder(
      column: $table.hindi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get english => $composableBuilder(
      column: $table.english, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wordMeaning => $composableBuilder(
      column: $table.wordMeaning, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readCount => $composableBuilder(
      column: $table.readCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noteText => $composableBuilder(
      column: $table.noteText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookNum => $composableBuilder(
      column: $table.bookNum, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterLabel => $composableBuilder(
      column: $table.chapterLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translation => $composableBuilder(
      column: $table.translation, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$VersesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VersesTableTable> {
  $$VersesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNum => $composableBuilder(
      column: $table.chapterNum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get verseNum => $composableBuilder(
      column: $table.verseNum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scripture => $composableBuilder(
      column: $table.scripture, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sanskrit => $composableBuilder(
      column: $table.sanskrit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transliteration => $composableBuilder(
      column: $table.transliteration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hindi => $composableBuilder(
      column: $table.hindi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get english => $composableBuilder(
      column: $table.english, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wordMeaning => $composableBuilder(
      column: $table.wordMeaning, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readCount => $composableBuilder(
      column: $table.readCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noteText => $composableBuilder(
      column: $table.noteText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookNum => $composableBuilder(
      column: $table.bookNum, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterLabel => $composableBuilder(
      column: $table.chapterLabel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translation => $composableBuilder(
      column: $table.translation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VersesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VersesTableTable> {
  $$VersesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chapterNum => $composableBuilder(
      column: $table.chapterNum, builder: (column) => column);

  GeneratedColumn<int> get verseNum =>
      $composableBuilder(column: $table.verseNum, builder: (column) => column);

  GeneratedColumn<String> get scripture =>
      $composableBuilder(column: $table.scripture, builder: (column) => column);

  GeneratedColumn<String> get sanskrit =>
      $composableBuilder(column: $table.sanskrit, builder: (column) => column);

  GeneratedColumn<String> get transliteration => $composableBuilder(
      column: $table.transliteration, builder: (column) => column);

  GeneratedColumn<String> get hindi =>
      $composableBuilder(column: $table.hindi, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<String> get wordMeaning => $composableBuilder(
      column: $table.wordMeaning, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
      column: $table.isBookmarked, builder: (column) => column);

  GeneratedColumn<int> get readCount =>
      $composableBuilder(column: $table.readCount, builder: (column) => column);

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<int> get bookNum =>
      $composableBuilder(column: $table.bookNum, builder: (column) => column);

  GeneratedColumn<String> get chapterLabel => $composableBuilder(
      column: $table.chapterLabel, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
      column: $table.translation, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VersesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VersesTableTable,
    VersesTableData,
    $$VersesTableTableFilterComposer,
    $$VersesTableTableOrderingComposer,
    $$VersesTableTableAnnotationComposer,
    $$VersesTableTableCreateCompanionBuilder,
    $$VersesTableTableUpdateCompanionBuilder,
    (
      VersesTableData,
      BaseReferences<_$AppDatabase, $VersesTableTable, VersesTableData>
    ),
    VersesTableData,
    PrefetchHooks Function()> {
  $$VersesTableTableTableManager(_$AppDatabase db, $VersesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VersesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VersesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VersesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> chapterNum = const Value.absent(),
            Value<int> verseNum = const Value.absent(),
            Value<String> scripture = const Value.absent(),
            Value<String> sanskrit = const Value.absent(),
            Value<String?> transliteration = const Value.absent(),
            Value<String?> hindi = const Value.absent(),
            Value<String?> english = const Value.absent(),
            Value<String?> wordMeaning = const Value.absent(),
            Value<bool> isBookmarked = const Value.absent(),
            Value<int> readCount = const Value.absent(),
            Value<String?> noteText = const Value.absent(),
            Value<int?> bookNum = const Value.absent(),
            Value<String?> chapterLabel = const Value.absent(),
            Value<String?> translation = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VersesTableCompanion(
            id: id,
            chapterNum: chapterNum,
            verseNum: verseNum,
            scripture: scripture,
            sanskrit: sanskrit,
            transliteration: transliteration,
            hindi: hindi,
            english: english,
            wordMeaning: wordMeaning,
            isBookmarked: isBookmarked,
            readCount: readCount,
            noteText: noteText,
            bookNum: bookNum,
            chapterLabel: chapterLabel,
            translation: translation,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int chapterNum,
            required int verseNum,
            required String scripture,
            required String sanskrit,
            Value<String?> transliteration = const Value.absent(),
            Value<String?> hindi = const Value.absent(),
            Value<String?> english = const Value.absent(),
            Value<String?> wordMeaning = const Value.absent(),
            Value<bool> isBookmarked = const Value.absent(),
            Value<int> readCount = const Value.absent(),
            Value<String?> noteText = const Value.absent(),
            Value<int?> bookNum = const Value.absent(),
            Value<String?> chapterLabel = const Value.absent(),
            Value<String?> translation = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              VersesTableCompanion.insert(
            id: id,
            chapterNum: chapterNum,
            verseNum: verseNum,
            scripture: scripture,
            sanskrit: sanskrit,
            transliteration: transliteration,
            hindi: hindi,
            english: english,
            wordMeaning: wordMeaning,
            isBookmarked: isBookmarked,
            readCount: readCount,
            noteText: noteText,
            bookNum: bookNum,
            chapterLabel: chapterLabel,
            translation: translation,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VersesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VersesTableTable,
    VersesTableData,
    $$VersesTableTableFilterComposer,
    $$VersesTableTableOrderingComposer,
    $$VersesTableTableAnnotationComposer,
    $$VersesTableTableCreateCompanionBuilder,
    $$VersesTableTableUpdateCompanionBuilder,
    (
      VersesTableData,
      BaseReferences<_$AppDatabase, $VersesTableTable, VersesTableData>
    ),
    VersesTableData,
    PrefetchHooks Function()>;
typedef $$LearningModulesTableTableCreateCompanionBuilder
    = LearningModulesTableCompanion Function({
  required String id,
  required String title,
  required String hook,
  required int level,
  required int sequence,
  required int estimatedMinutes,
  required int cardCount,
  Value<int> rowid,
});
typedef $$LearningModulesTableTableUpdateCompanionBuilder
    = LearningModulesTableCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> hook,
  Value<int> level,
  Value<int> sequence,
  Value<int> estimatedMinutes,
  Value<int> cardCount,
  Value<int> rowid,
});

class $$LearningModulesTableTableFilterComposer
    extends Composer<_$AppDatabase, $LearningModulesTableTable> {
  $$LearningModulesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hook => $composableBuilder(
      column: $table.hook, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardCount => $composableBuilder(
      column: $table.cardCount, builder: (column) => ColumnFilters(column));
}

class $$LearningModulesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningModulesTableTable> {
  $$LearningModulesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hook => $composableBuilder(
      column: $table.hook, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardCount => $composableBuilder(
      column: $table.cardCount, builder: (column) => ColumnOrderings(column));
}

class $$LearningModulesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningModulesTableTable> {
  $$LearningModulesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get hook =>
      $composableBuilder(column: $table.hook, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<int> get cardCount =>
      $composableBuilder(column: $table.cardCount, builder: (column) => column);
}

class $$LearningModulesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LearningModulesTableTable,
    LearningModulesTableData,
    $$LearningModulesTableTableFilterComposer,
    $$LearningModulesTableTableOrderingComposer,
    $$LearningModulesTableTableAnnotationComposer,
    $$LearningModulesTableTableCreateCompanionBuilder,
    $$LearningModulesTableTableUpdateCompanionBuilder,
    (
      LearningModulesTableData,
      BaseReferences<_$AppDatabase, $LearningModulesTableTable,
          LearningModulesTableData>
    ),
    LearningModulesTableData,
    PrefetchHooks Function()> {
  $$LearningModulesTableTableTableManager(
      _$AppDatabase db, $LearningModulesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningModulesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningModulesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningModulesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> hook = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> sequence = const Value.absent(),
            Value<int> estimatedMinutes = const Value.absent(),
            Value<int> cardCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningModulesTableCompanion(
            id: id,
            title: title,
            hook: hook,
            level: level,
            sequence: sequence,
            estimatedMinutes: estimatedMinutes,
            cardCount: cardCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String hook,
            required int level,
            required int sequence,
            required int estimatedMinutes,
            required int cardCount,
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningModulesTableCompanion.insert(
            id: id,
            title: title,
            hook: hook,
            level: level,
            sequence: sequence,
            estimatedMinutes: estimatedMinutes,
            cardCount: cardCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LearningModulesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LearningModulesTableTable,
        LearningModulesTableData,
        $$LearningModulesTableTableFilterComposer,
        $$LearningModulesTableTableOrderingComposer,
        $$LearningModulesTableTableAnnotationComposer,
        $$LearningModulesTableTableCreateCompanionBuilder,
        $$LearningModulesTableTableUpdateCompanionBuilder,
        (
          LearningModulesTableData,
          BaseReferences<_$AppDatabase, $LearningModulesTableTable,
              LearningModulesTableData>
        ),
        LearningModulesTableData,
        PrefetchHooks Function()>;
typedef $$ModuleCardsTableTableCreateCompanionBuilder
    = ModuleCardsTableCompanion Function({
  required String id,
  required String moduleId,
  required int sequence,
  required String cardTitle,
  required String content,
  Value<int> rowid,
});
typedef $$ModuleCardsTableTableUpdateCompanionBuilder
    = ModuleCardsTableCompanion Function({
  Value<String> id,
  Value<String> moduleId,
  Value<int> sequence,
  Value<String> cardTitle,
  Value<String> content,
  Value<int> rowid,
});

class $$ModuleCardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ModuleCardsTableTable> {
  $$ModuleCardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardTitle => $composableBuilder(
      column: $table.cardTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));
}

class $$ModuleCardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ModuleCardsTableTable> {
  $$ModuleCardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequence => $composableBuilder(
      column: $table.sequence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardTitle => $composableBuilder(
      column: $table.cardTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));
}

class $$ModuleCardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModuleCardsTableTable> {
  $$ModuleCardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get cardTitle =>
      $composableBuilder(column: $table.cardTitle, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$ModuleCardsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModuleCardsTableTable,
    ModuleCardsTableData,
    $$ModuleCardsTableTableFilterComposer,
    $$ModuleCardsTableTableOrderingComposer,
    $$ModuleCardsTableTableAnnotationComposer,
    $$ModuleCardsTableTableCreateCompanionBuilder,
    $$ModuleCardsTableTableUpdateCompanionBuilder,
    (
      ModuleCardsTableData,
      BaseReferences<_$AppDatabase, $ModuleCardsTableTable,
          ModuleCardsTableData>
    ),
    ModuleCardsTableData,
    PrefetchHooks Function()> {
  $$ModuleCardsTableTableTableManager(
      _$AppDatabase db, $ModuleCardsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleCardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModuleCardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModuleCardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> moduleId = const Value.absent(),
            Value<int> sequence = const Value.absent(),
            Value<String> cardTitle = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModuleCardsTableCompanion(
            id: id,
            moduleId: moduleId,
            sequence: sequence,
            cardTitle: cardTitle,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String moduleId,
            required int sequence,
            required String cardTitle,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              ModuleCardsTableCompanion.insert(
            id: id,
            moduleId: moduleId,
            sequence: sequence,
            cardTitle: cardTitle,
            content: content,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModuleCardsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ModuleCardsTableTable,
    ModuleCardsTableData,
    $$ModuleCardsTableTableFilterComposer,
    $$ModuleCardsTableTableOrderingComposer,
    $$ModuleCardsTableTableAnnotationComposer,
    $$ModuleCardsTableTableCreateCompanionBuilder,
    $$ModuleCardsTableTableUpdateCompanionBuilder,
    (
      ModuleCardsTableData,
      BaseReferences<_$AppDatabase, $ModuleCardsTableTable,
          ModuleCardsTableData>
    ),
    ModuleCardsTableData,
    PrefetchHooks Function()>;
typedef $$ModuleExtrasTableTableCreateCompanionBuilder
    = ModuleExtrasTableCompanion Function({
  required String moduleId,
  Value<String?> anchorVerseId,
  Value<String?> anchorVerseNote,
  Value<String?> reflectionQuestion,
  Value<int> rowid,
});
typedef $$ModuleExtrasTableTableUpdateCompanionBuilder
    = ModuleExtrasTableCompanion Function({
  Value<String> moduleId,
  Value<String?> anchorVerseId,
  Value<String?> anchorVerseNote,
  Value<String?> reflectionQuestion,
  Value<int> rowid,
});

class $$ModuleExtrasTableTableFilterComposer
    extends Composer<_$AppDatabase, $ModuleExtrasTableTable> {
  $$ModuleExtrasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anchorVerseId => $composableBuilder(
      column: $table.anchorVerseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get anchorVerseNote => $composableBuilder(
      column: $table.anchorVerseNote,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reflectionQuestion => $composableBuilder(
      column: $table.reflectionQuestion,
      builder: (column) => ColumnFilters(column));
}

class $$ModuleExtrasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ModuleExtrasTableTable> {
  $$ModuleExtrasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchorVerseId => $composableBuilder(
      column: $table.anchorVerseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchorVerseNote => $composableBuilder(
      column: $table.anchorVerseNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reflectionQuestion => $composableBuilder(
      column: $table.reflectionQuestion,
      builder: (column) => ColumnOrderings(column));
}

class $$ModuleExtrasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ModuleExtrasTableTable> {
  $$ModuleExtrasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<String> get anchorVerseId => $composableBuilder(
      column: $table.anchorVerseId, builder: (column) => column);

  GeneratedColumn<String> get anchorVerseNote => $composableBuilder(
      column: $table.anchorVerseNote, builder: (column) => column);

  GeneratedColumn<String> get reflectionQuestion => $composableBuilder(
      column: $table.reflectionQuestion, builder: (column) => column);
}

class $$ModuleExtrasTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ModuleExtrasTableTable,
    ModuleExtrasTableData,
    $$ModuleExtrasTableTableFilterComposer,
    $$ModuleExtrasTableTableOrderingComposer,
    $$ModuleExtrasTableTableAnnotationComposer,
    $$ModuleExtrasTableTableCreateCompanionBuilder,
    $$ModuleExtrasTableTableUpdateCompanionBuilder,
    (
      ModuleExtrasTableData,
      BaseReferences<_$AppDatabase, $ModuleExtrasTableTable,
          ModuleExtrasTableData>
    ),
    ModuleExtrasTableData,
    PrefetchHooks Function()> {
  $$ModuleExtrasTableTableTableManager(
      _$AppDatabase db, $ModuleExtrasTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModuleExtrasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModuleExtrasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModuleExtrasTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> moduleId = const Value.absent(),
            Value<String?> anchorVerseId = const Value.absent(),
            Value<String?> anchorVerseNote = const Value.absent(),
            Value<String?> reflectionQuestion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModuleExtrasTableCompanion(
            moduleId: moduleId,
            anchorVerseId: anchorVerseId,
            anchorVerseNote: anchorVerseNote,
            reflectionQuestion: reflectionQuestion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String moduleId,
            Value<String?> anchorVerseId = const Value.absent(),
            Value<String?> anchorVerseNote = const Value.absent(),
            Value<String?> reflectionQuestion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ModuleExtrasTableCompanion.insert(
            moduleId: moduleId,
            anchorVerseId: anchorVerseId,
            anchorVerseNote: anchorVerseNote,
            reflectionQuestion: reflectionQuestion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ModuleExtrasTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ModuleExtrasTableTable,
    ModuleExtrasTableData,
    $$ModuleExtrasTableTableFilterComposer,
    $$ModuleExtrasTableTableOrderingComposer,
    $$ModuleExtrasTableTableAnnotationComposer,
    $$ModuleExtrasTableTableCreateCompanionBuilder,
    $$ModuleExtrasTableTableUpdateCompanionBuilder,
    (
      ModuleExtrasTableData,
      BaseReferences<_$AppDatabase, $ModuleExtrasTableTable,
          ModuleExtrasTableData>
    ),
    ModuleExtrasTableData,
    PrefetchHooks Function()>;
typedef $$UserModuleProgressTableTableCreateCompanionBuilder
    = UserModuleProgressTableCompanion Function({
  required String moduleId,
  Value<int> cardsRead,
  Value<bool> isCompleted,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$UserModuleProgressTableTableUpdateCompanionBuilder
    = UserModuleProgressTableCompanion Function({
  Value<String> moduleId,
  Value<int> cardsRead,
  Value<bool> isCompleted,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$UserModuleProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserModuleProgressTableTable> {
  $$UserModuleProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardsRead => $composableBuilder(
      column: $table.cardsRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$UserModuleProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserModuleProgressTableTable> {
  $$UserModuleProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get moduleId => $composableBuilder(
      column: $table.moduleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardsRead => $composableBuilder(
      column: $table.cardsRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserModuleProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserModuleProgressTableTable> {
  $$UserModuleProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get moduleId =>
      $composableBuilder(column: $table.moduleId, builder: (column) => column);

  GeneratedColumn<int> get cardsRead =>
      $composableBuilder(column: $table.cardsRead, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$UserModuleProgressTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserModuleProgressTableTable,
    UserModuleProgressTableData,
    $$UserModuleProgressTableTableFilterComposer,
    $$UserModuleProgressTableTableOrderingComposer,
    $$UserModuleProgressTableTableAnnotationComposer,
    $$UserModuleProgressTableTableCreateCompanionBuilder,
    $$UserModuleProgressTableTableUpdateCompanionBuilder,
    (
      UserModuleProgressTableData,
      BaseReferences<_$AppDatabase, $UserModuleProgressTableTable,
          UserModuleProgressTableData>
    ),
    UserModuleProgressTableData,
    PrefetchHooks Function()> {
  $$UserModuleProgressTableTableTableManager(
      _$AppDatabase db, $UserModuleProgressTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserModuleProgressTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$UserModuleProgressTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserModuleProgressTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> moduleId = const Value.absent(),
            Value<int> cardsRead = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserModuleProgressTableCompanion(
            moduleId: moduleId,
            cardsRead: cardsRead,
            isCompleted: isCompleted,
            startedAt: startedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String moduleId,
            Value<int> cardsRead = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserModuleProgressTableCompanion.insert(
            moduleId: moduleId,
            cardsRead: cardsRead,
            isCompleted: isCompleted,
            startedAt: startedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserModuleProgressTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $UserModuleProgressTableTable,
        UserModuleProgressTableData,
        $$UserModuleProgressTableTableFilterComposer,
        $$UserModuleProgressTableTableOrderingComposer,
        $$UserModuleProgressTableTableAnnotationComposer,
        $$UserModuleProgressTableTableCreateCompanionBuilder,
        $$UserModuleProgressTableTableUpdateCompanionBuilder,
        (
          UserModuleProgressTableData,
          BaseReferences<_$AppDatabase, $UserModuleProgressTableTable,
              UserModuleProgressTableData>
        ),
        UserModuleProgressTableData,
        PrefetchHooks Function()>;
typedef $$BookmarksTableTableCreateCompanionBuilder = BookmarksTableCompanion
    Function({
  required String verseId,
  required DateTime savedAt,
  Value<int> rowid,
});
typedef $$BookmarksTableTableUpdateCompanionBuilder = BookmarksTableCompanion
    Function({
  Value<String> verseId,
  Value<DateTime> savedAt,
  Value<int> rowid,
});

class $$BookmarksTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
      column: $table.savedAt, builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);
}

class $$BookmarksTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTableTable,
    BookmarksTableData,
    $$BookmarksTableTableFilterComposer,
    $$BookmarksTableTableOrderingComposer,
    $$BookmarksTableTableAnnotationComposer,
    $$BookmarksTableTableCreateCompanionBuilder,
    $$BookmarksTableTableUpdateCompanionBuilder,
    (
      BookmarksTableData,
      BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarksTableData>
    ),
    BookmarksTableData,
    PrefetchHooks Function()> {
  $$BookmarksTableTableTableManager(
      _$AppDatabase db, $BookmarksTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> verseId = const Value.absent(),
            Value<DateTime> savedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksTableCompanion(
            verseId: verseId,
            savedAt: savedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String verseId,
            required DateTime savedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksTableCompanion.insert(
            verseId: verseId,
            savedAt: savedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTableTable,
    BookmarksTableData,
    $$BookmarksTableTableFilterComposer,
    $$BookmarksTableTableOrderingComposer,
    $$BookmarksTableTableAnnotationComposer,
    $$BookmarksTableTableCreateCompanionBuilder,
    $$BookmarksTableTableUpdateCompanionBuilder,
    (
      BookmarksTableData,
      BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarksTableData>
    ),
    BookmarksTableData,
    PrefetchHooks Function()>;
typedef $$VerseExplanationsTableTableCreateCompanionBuilder
    = VerseExplanationsTableCompanion Function({
  required String verseId,
  required String explanationText,
  required DateTime generatedAt,
  required String modelVersion,
  Value<int> rowid,
});
typedef $$VerseExplanationsTableTableUpdateCompanionBuilder
    = VerseExplanationsTableCompanion Function({
  Value<String> verseId,
  Value<String> explanationText,
  Value<DateTime> generatedAt,
  Value<String> modelVersion,
  Value<int> rowid,
});

class $$VerseExplanationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $VerseExplanationsTableTable> {
  $$VerseExplanationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanationText => $composableBuilder(
      column: $table.explanationText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => ColumnFilters(column));
}

class $$VerseExplanationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseExplanationsTableTable> {
  $$VerseExplanationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanationText => $composableBuilder(
      column: $table.explanationText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion,
      builder: (column) => ColumnOrderings(column));
}

class $$VerseExplanationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseExplanationsTableTable> {
  $$VerseExplanationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<String> get explanationText => $composableBuilder(
      column: $table.explanationText, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
      column: $table.modelVersion, builder: (column) => column);
}

class $$VerseExplanationsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VerseExplanationsTableTable,
    VerseExplanationsTableData,
    $$VerseExplanationsTableTableFilterComposer,
    $$VerseExplanationsTableTableOrderingComposer,
    $$VerseExplanationsTableTableAnnotationComposer,
    $$VerseExplanationsTableTableCreateCompanionBuilder,
    $$VerseExplanationsTableTableUpdateCompanionBuilder,
    (
      VerseExplanationsTableData,
      BaseReferences<_$AppDatabase, $VerseExplanationsTableTable,
          VerseExplanationsTableData>
    ),
    VerseExplanationsTableData,
    PrefetchHooks Function()> {
  $$VerseExplanationsTableTableTableManager(
      _$AppDatabase db, $VerseExplanationsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerseExplanationsTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$VerseExplanationsTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerseExplanationsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> verseId = const Value.absent(),
            Value<String> explanationText = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
            Value<String> modelVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VerseExplanationsTableCompanion(
            verseId: verseId,
            explanationText: explanationText,
            generatedAt: generatedAt,
            modelVersion: modelVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String verseId,
            required String explanationText,
            required DateTime generatedAt,
            required String modelVersion,
            Value<int> rowid = const Value.absent(),
          }) =>
              VerseExplanationsTableCompanion.insert(
            verseId: verseId,
            explanationText: explanationText,
            generatedAt: generatedAt,
            modelVersion: modelVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VerseExplanationsTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $VerseExplanationsTableTable,
        VerseExplanationsTableData,
        $$VerseExplanationsTableTableFilterComposer,
        $$VerseExplanationsTableTableOrderingComposer,
        $$VerseExplanationsTableTableAnnotationComposer,
        $$VerseExplanationsTableTableCreateCompanionBuilder,
        $$VerseExplanationsTableTableUpdateCompanionBuilder,
        (
          VerseExplanationsTableData,
          BaseReferences<_$AppDatabase, $VerseExplanationsTableTable,
              VerseExplanationsTableData>
        ),
        VerseExplanationsTableData,
        PrefetchHooks Function()>;
typedef $$CommentariesTableTableCreateCompanionBuilder
    = CommentariesTableCompanion Function({
  required String id,
  required String verseId,
  required String tradition,
  required String author,
  Value<String?> textEnglish,
  Value<String?> textSanskrit,
  Value<String?> translator,
  required String sourceUrl,
  required String license,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CommentariesTableTableUpdateCompanionBuilder
    = CommentariesTableCompanion Function({
  Value<String> id,
  Value<String> verseId,
  Value<String> tradition,
  Value<String> author,
  Value<String?> textEnglish,
  Value<String?> textSanskrit,
  Value<String?> translator,
  Value<String> sourceUrl,
  Value<String> license,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CommentariesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CommentariesTableTable> {
  $$CommentariesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tradition => $composableBuilder(
      column: $table.tradition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textEnglish => $composableBuilder(
      column: $table.textEnglish, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textSanskrit => $composableBuilder(
      column: $table.textSanskrit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translator => $composableBuilder(
      column: $table.translator, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get license => $composableBuilder(
      column: $table.license, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CommentariesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentariesTableTable> {
  $$CommentariesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get verseId => $composableBuilder(
      column: $table.verseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tradition => $composableBuilder(
      column: $table.tradition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textEnglish => $composableBuilder(
      column: $table.textEnglish, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textSanskrit => $composableBuilder(
      column: $table.textSanskrit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translator => $composableBuilder(
      column: $table.translator, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
      column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get license => $composableBuilder(
      column: $table.license, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CommentariesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentariesTableTable> {
  $$CommentariesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get verseId =>
      $composableBuilder(column: $table.verseId, builder: (column) => column);

  GeneratedColumn<String> get tradition =>
      $composableBuilder(column: $table.tradition, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get textEnglish => $composableBuilder(
      column: $table.textEnglish, builder: (column) => column);

  GeneratedColumn<String> get textSanskrit => $composableBuilder(
      column: $table.textSanskrit, builder: (column) => column);

  GeneratedColumn<String> get translator => $composableBuilder(
      column: $table.translator, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CommentariesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CommentariesTableTable,
    CommentariesTableData,
    $$CommentariesTableTableFilterComposer,
    $$CommentariesTableTableOrderingComposer,
    $$CommentariesTableTableAnnotationComposer,
    $$CommentariesTableTableCreateCompanionBuilder,
    $$CommentariesTableTableUpdateCompanionBuilder,
    (
      CommentariesTableData,
      BaseReferences<_$AppDatabase, $CommentariesTableTable,
          CommentariesTableData>
    ),
    CommentariesTableData,
    PrefetchHooks Function()> {
  $$CommentariesTableTableTableManager(
      _$AppDatabase db, $CommentariesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentariesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentariesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentariesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> verseId = const Value.absent(),
            Value<String> tradition = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String?> textEnglish = const Value.absent(),
            Value<String?> textSanskrit = const Value.absent(),
            Value<String?> translator = const Value.absent(),
            Value<String> sourceUrl = const Value.absent(),
            Value<String> license = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentariesTableCompanion(
            id: id,
            verseId: verseId,
            tradition: tradition,
            author: author,
            textEnglish: textEnglish,
            textSanskrit: textSanskrit,
            translator: translator,
            sourceUrl: sourceUrl,
            license: license,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String verseId,
            required String tradition,
            required String author,
            Value<String?> textEnglish = const Value.absent(),
            Value<String?> textSanskrit = const Value.absent(),
            Value<String?> translator = const Value.absent(),
            required String sourceUrl,
            required String license,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CommentariesTableCompanion.insert(
            id: id,
            verseId: verseId,
            tradition: tradition,
            author: author,
            textEnglish: textEnglish,
            textSanskrit: textSanskrit,
            translator: translator,
            sourceUrl: sourceUrl,
            license: license,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CommentariesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CommentariesTableTable,
    CommentariesTableData,
    $$CommentariesTableTableFilterComposer,
    $$CommentariesTableTableOrderingComposer,
    $$CommentariesTableTableAnnotationComposer,
    $$CommentariesTableTableCreateCompanionBuilder,
    $$CommentariesTableTableUpdateCompanionBuilder,
    (
      CommentariesTableData,
      BaseReferences<_$AppDatabase, $CommentariesTableTable,
          CommentariesTableData>
    ),
    CommentariesTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VersesTableTableTableManager get versesTable =>
      $$VersesTableTableTableManager(_db, _db.versesTable);
  $$LearningModulesTableTableTableManager get learningModulesTable =>
      $$LearningModulesTableTableTableManager(_db, _db.learningModulesTable);
  $$ModuleCardsTableTableTableManager get moduleCardsTable =>
      $$ModuleCardsTableTableTableManager(_db, _db.moduleCardsTable);
  $$ModuleExtrasTableTableTableManager get moduleExtrasTable =>
      $$ModuleExtrasTableTableTableManager(_db, _db.moduleExtrasTable);
  $$UserModuleProgressTableTableTableManager get userModuleProgressTable =>
      $$UserModuleProgressTableTableTableManager(
          _db, _db.userModuleProgressTable);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(_db, _db.bookmarksTable);
  $$VerseExplanationsTableTableTableManager get verseExplanationsTable =>
      $$VerseExplanationsTableTableTableManager(
          _db, _db.verseExplanationsTable);
  $$CommentariesTableTableTableManager get commentariesTable =>
      $$CommentariesTableTableTableManager(_db, _db.commentariesTable);
}
