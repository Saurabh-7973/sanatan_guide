// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WordMeaning {
  String get word;
  String get meaning;
  String? get transliteration;

  /// Create a copy of WordMeaning
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WordMeaningCopyWith<WordMeaning> get copyWith =>
      _$WordMeaningCopyWithImpl<WordMeaning>(this as WordMeaning, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WordMeaning &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.transliteration, transliteration) ||
                other.transliteration == transliteration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, word, meaning, transliteration);

  @override
  String toString() {
    return 'WordMeaning(word: $word, meaning: $meaning, transliteration: $transliteration)';
  }
}

/// @nodoc
abstract mixin class $WordMeaningCopyWith<$Res> {
  factory $WordMeaningCopyWith(
          WordMeaning value, $Res Function(WordMeaning) _then) =
      _$WordMeaningCopyWithImpl;
  @useResult
  $Res call({String word, String meaning, String? transliteration});
}

/// @nodoc
class _$WordMeaningCopyWithImpl<$Res> implements $WordMeaningCopyWith<$Res> {
  _$WordMeaningCopyWithImpl(this._self, this._then);

  final WordMeaning _self;
  final $Res Function(WordMeaning) _then;

  /// Create a copy of WordMeaning
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? word = null,
    Object? meaning = null,
    Object? transliteration = freezed,
  }) {
    return _then(_self.copyWith(
      word: null == word
          ? _self.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: null == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      transliteration: freezed == transliteration
          ? _self.transliteration
          : transliteration // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [WordMeaning].
extension WordMeaningPatterns on WordMeaning {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WordMeaning value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WordMeaning() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WordMeaning value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WordMeaning():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WordMeaning value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WordMeaning() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String word, String meaning, String? transliteration)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WordMeaning() when $default != null:
        return $default(_that.word, _that.meaning, _that.transliteration);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String word, String meaning, String? transliteration)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WordMeaning():
        return $default(_that.word, _that.meaning, _that.transliteration);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String word, String meaning, String? transliteration)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WordMeaning() when $default != null:
        return $default(_that.word, _that.meaning, _that.transliteration);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _WordMeaning implements WordMeaning {
  const _WordMeaning(
      {required this.word, required this.meaning, this.transliteration});

  @override
  final String word;
  @override
  final String meaning;
  @override
  final String? transliteration;

  /// Create a copy of WordMeaning
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WordMeaningCopyWith<_WordMeaning> get copyWith =>
      __$WordMeaningCopyWithImpl<_WordMeaning>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WordMeaning &&
            (identical(other.word, word) || other.word == word) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.transliteration, transliteration) ||
                other.transliteration == transliteration));
  }

  @override
  int get hashCode => Object.hash(runtimeType, word, meaning, transliteration);

  @override
  String toString() {
    return 'WordMeaning(word: $word, meaning: $meaning, transliteration: $transliteration)';
  }
}

/// @nodoc
abstract mixin class _$WordMeaningCopyWith<$Res>
    implements $WordMeaningCopyWith<$Res> {
  factory _$WordMeaningCopyWith(
          _WordMeaning value, $Res Function(_WordMeaning) _then) =
      __$WordMeaningCopyWithImpl;
  @override
  @useResult
  $Res call({String word, String meaning, String? transliteration});
}

/// @nodoc
class __$WordMeaningCopyWithImpl<$Res> implements _$WordMeaningCopyWith<$Res> {
  __$WordMeaningCopyWithImpl(this._self, this._then);

  final _WordMeaning _self;
  final $Res Function(_WordMeaning) _then;

  /// Create a copy of WordMeaning
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? word = null,
    Object? meaning = null,
    Object? transliteration = freezed,
  }) {
    return _then(_WordMeaning(
      word: null == word
          ? _self.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
      meaning: null == meaning
          ? _self.meaning
          : meaning // ignore: cast_nullable_to_non_nullable
              as String,
      transliteration: freezed == transliteration
          ? _self.transliteration
          : transliteration // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Verse {
  /// Unique ID. Format: '{ScriptureCode}.{chapter}.{verse}' e.g. 'BG.1.1'
  String get id;
  int get chapterNum;
  int get verseNum;
  Scripture get scripture;

  /// Original Devanagari Sanskrit text. Never empty.
  String get sanskrit;

  /// IAST Roman transliteration. Null until loaded.
  String? get transliteration;

  /// Hindi translation. Null if not yet populated.
  String? get hindi;

  /// English translation. Null if not yet populated.
  String? get english;

  /// Word-by-word meanings as a list. Null if not loaded.
  List<WordMeaning>? get wordMeanings;

  /// User's personal note on this verse. Null if no note written.
  String? get noteText;
  int? get bookNum;
  String? get chapterLabel;
  String? get translation;
  bool get isBookmarked;
  int get readCount;
  DateTime get createdAt;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VerseCopyWith<Verse> get copyWith =>
      _$VerseCopyWithImpl<Verse>(this as Verse, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Verse &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chapterNum, chapterNum) ||
                other.chapterNum == chapterNum) &&
            (identical(other.verseNum, verseNum) ||
                other.verseNum == verseNum) &&
            (identical(other.scripture, scripture) ||
                other.scripture == scripture) &&
            (identical(other.sanskrit, sanskrit) ||
                other.sanskrit == sanskrit) &&
            (identical(other.transliteration, transliteration) ||
                other.transliteration == transliteration) &&
            (identical(other.hindi, hindi) || other.hindi == hindi) &&
            (identical(other.english, english) || other.english == english) &&
            const DeepCollectionEquality()
                .equals(other.wordMeanings, wordMeanings) &&
            (identical(other.noteText, noteText) ||
                other.noteText == noteText) &&
            (identical(other.bookNum, bookNum) || other.bookNum == bookNum) &&
            (identical(other.chapterLabel, chapterLabel) ||
                other.chapterLabel == chapterLabel) &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.readCount, readCount) ||
                other.readCount == readCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      chapterNum,
      verseNum,
      scripture,
      sanskrit,
      transliteration,
      hindi,
      english,
      const DeepCollectionEquality().hash(wordMeanings),
      noteText,
      bookNum,
      chapterLabel,
      translation,
      isBookmarked,
      readCount,
      createdAt);

  @override
  String toString() {
    return 'Verse(id: $id, chapterNum: $chapterNum, verseNum: $verseNum, scripture: $scripture, sanskrit: $sanskrit, transliteration: $transliteration, hindi: $hindi, english: $english, wordMeanings: $wordMeanings, noteText: $noteText, bookNum: $bookNum, chapterLabel: $chapterLabel, translation: $translation, isBookmarked: $isBookmarked, readCount: $readCount, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $VerseCopyWith<$Res> {
  factory $VerseCopyWith(Verse value, $Res Function(Verse) _then) =
      _$VerseCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      int chapterNum,
      int verseNum,
      Scripture scripture,
      String sanskrit,
      String? transliteration,
      String? hindi,
      String? english,
      List<WordMeaning>? wordMeanings,
      String? noteText,
      int? bookNum,
      String? chapterLabel,
      String? translation,
      bool isBookmarked,
      int readCount,
      DateTime createdAt});
}

/// @nodoc
class _$VerseCopyWithImpl<$Res> implements $VerseCopyWith<$Res> {
  _$VerseCopyWithImpl(this._self, this._then);

  final Verse _self;
  final $Res Function(Verse) _then;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chapterNum = null,
    Object? verseNum = null,
    Object? scripture = null,
    Object? sanskrit = null,
    Object? transliteration = freezed,
    Object? hindi = freezed,
    Object? english = freezed,
    Object? wordMeanings = freezed,
    Object? noteText = freezed,
    Object? bookNum = freezed,
    Object? chapterLabel = freezed,
    Object? translation = freezed,
    Object? isBookmarked = null,
    Object? readCount = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chapterNum: null == chapterNum
          ? _self.chapterNum
          : chapterNum // ignore: cast_nullable_to_non_nullable
              as int,
      verseNum: null == verseNum
          ? _self.verseNum
          : verseNum // ignore: cast_nullable_to_non_nullable
              as int,
      scripture: null == scripture
          ? _self.scripture
          : scripture // ignore: cast_nullable_to_non_nullable
              as Scripture,
      sanskrit: null == sanskrit
          ? _self.sanskrit
          : sanskrit // ignore: cast_nullable_to_non_nullable
              as String,
      transliteration: freezed == transliteration
          ? _self.transliteration
          : transliteration // ignore: cast_nullable_to_non_nullable
              as String?,
      hindi: freezed == hindi
          ? _self.hindi
          : hindi // ignore: cast_nullable_to_non_nullable
              as String?,
      english: freezed == english
          ? _self.english
          : english // ignore: cast_nullable_to_non_nullable
              as String?,
      wordMeanings: freezed == wordMeanings
          ? _self.wordMeanings
          : wordMeanings // ignore: cast_nullable_to_non_nullable
              as List<WordMeaning>?,
      noteText: freezed == noteText
          ? _self.noteText
          : noteText // ignore: cast_nullable_to_non_nullable
              as String?,
      bookNum: freezed == bookNum
          ? _self.bookNum
          : bookNum // ignore: cast_nullable_to_non_nullable
              as int?,
      chapterLabel: freezed == chapterLabel
          ? _self.chapterLabel
          : chapterLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      translation: freezed == translation
          ? _self.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String?,
      isBookmarked: null == isBookmarked
          ? _self.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      readCount: null == readCount
          ? _self.readCount
          : readCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Verse].
extension VersePatterns on Verse {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Verse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Verse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse():
        return $default(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Verse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            int chapterNum,
            int verseNum,
            Scripture scripture,
            String sanskrit,
            String? transliteration,
            String? hindi,
            String? english,
            List<WordMeaning>? wordMeanings,
            String? noteText,
            int? bookNum,
            String? chapterLabel,
            String? translation,
            bool isBookmarked,
            int readCount,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
        return $default(
            _that.id,
            _that.chapterNum,
            _that.verseNum,
            _that.scripture,
            _that.sanskrit,
            _that.transliteration,
            _that.hindi,
            _that.english,
            _that.wordMeanings,
            _that.noteText,
            _that.bookNum,
            _that.chapterLabel,
            _that.translation,
            _that.isBookmarked,
            _that.readCount,
            _that.createdAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            int chapterNum,
            int verseNum,
            Scripture scripture,
            String sanskrit,
            String? transliteration,
            String? hindi,
            String? english,
            List<WordMeaning>? wordMeanings,
            String? noteText,
            int? bookNum,
            String? chapterLabel,
            String? translation,
            bool isBookmarked,
            int readCount,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse():
        return $default(
            _that.id,
            _that.chapterNum,
            _that.verseNum,
            _that.scripture,
            _that.sanskrit,
            _that.transliteration,
            _that.hindi,
            _that.english,
            _that.wordMeanings,
            _that.noteText,
            _that.bookNum,
            _that.chapterLabel,
            _that.translation,
            _that.isBookmarked,
            _that.readCount,
            _that.createdAt);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            int chapterNum,
            int verseNum,
            Scripture scripture,
            String sanskrit,
            String? transliteration,
            String? hindi,
            String? english,
            List<WordMeaning>? wordMeanings,
            String? noteText,
            int? bookNum,
            String? chapterLabel,
            String? translation,
            bool isBookmarked,
            int readCount,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
        return $default(
            _that.id,
            _that.chapterNum,
            _that.verseNum,
            _that.scripture,
            _that.sanskrit,
            _that.transliteration,
            _that.hindi,
            _that.english,
            _that.wordMeanings,
            _that.noteText,
            _that.bookNum,
            _that.chapterLabel,
            _that.translation,
            _that.isBookmarked,
            _that.readCount,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Verse implements Verse {
  const _Verse(
      {required this.id,
      required this.chapterNum,
      required this.verseNum,
      required this.scripture,
      required this.sanskrit,
      this.transliteration,
      this.hindi,
      this.english,
      final List<WordMeaning>? wordMeanings,
      this.noteText,
      this.bookNum,
      this.chapterLabel,
      this.translation,
      this.isBookmarked = false,
      this.readCount = 0,
      required this.createdAt})
      : _wordMeanings = wordMeanings;

  /// Unique ID. Format: '{ScriptureCode}.{chapter}.{verse}' e.g. 'BG.1.1'
  @override
  final String id;
  @override
  final int chapterNum;
  @override
  final int verseNum;
  @override
  final Scripture scripture;

  /// Original Devanagari Sanskrit text. Never empty.
  @override
  final String sanskrit;

  /// IAST Roman transliteration. Null until loaded.
  @override
  final String? transliteration;

  /// Hindi translation. Null if not yet populated.
  @override
  final String? hindi;

  /// English translation. Null if not yet populated.
  @override
  final String? english;

  /// Word-by-word meanings as a list. Null if not loaded.
  final List<WordMeaning>? _wordMeanings;

  /// Word-by-word meanings as a list. Null if not loaded.
  @override
  List<WordMeaning>? get wordMeanings {
    final value = _wordMeanings;
    if (value == null) return null;
    if (_wordMeanings is EqualUnmodifiableListView) return _wordMeanings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// User's personal note on this verse. Null if no note written.
  @override
  final String? noteText;
  @override
  final int? bookNum;
  @override
  final String? chapterLabel;
  @override
  final String? translation;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  @JsonKey()
  final int readCount;
  @override
  final DateTime createdAt;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VerseCopyWith<_Verse> get copyWith =>
      __$VerseCopyWithImpl<_Verse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Verse &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chapterNum, chapterNum) ||
                other.chapterNum == chapterNum) &&
            (identical(other.verseNum, verseNum) ||
                other.verseNum == verseNum) &&
            (identical(other.scripture, scripture) ||
                other.scripture == scripture) &&
            (identical(other.sanskrit, sanskrit) ||
                other.sanskrit == sanskrit) &&
            (identical(other.transliteration, transliteration) ||
                other.transliteration == transliteration) &&
            (identical(other.hindi, hindi) || other.hindi == hindi) &&
            (identical(other.english, english) || other.english == english) &&
            const DeepCollectionEquality()
                .equals(other._wordMeanings, _wordMeanings) &&
            (identical(other.noteText, noteText) ||
                other.noteText == noteText) &&
            (identical(other.bookNum, bookNum) || other.bookNum == bookNum) &&
            (identical(other.chapterLabel, chapterLabel) ||
                other.chapterLabel == chapterLabel) &&
            (identical(other.translation, translation) ||
                other.translation == translation) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.readCount, readCount) ||
                other.readCount == readCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      chapterNum,
      verseNum,
      scripture,
      sanskrit,
      transliteration,
      hindi,
      english,
      const DeepCollectionEquality().hash(_wordMeanings),
      noteText,
      bookNum,
      chapterLabel,
      translation,
      isBookmarked,
      readCount,
      createdAt);

  @override
  String toString() {
    return 'Verse(id: $id, chapterNum: $chapterNum, verseNum: $verseNum, scripture: $scripture, sanskrit: $sanskrit, transliteration: $transliteration, hindi: $hindi, english: $english, wordMeanings: $wordMeanings, noteText: $noteText, bookNum: $bookNum, chapterLabel: $chapterLabel, translation: $translation, isBookmarked: $isBookmarked, readCount: $readCount, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$VerseCopyWith<$Res> implements $VerseCopyWith<$Res> {
  factory _$VerseCopyWith(_Verse value, $Res Function(_Verse) _then) =
      __$VerseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      int chapterNum,
      int verseNum,
      Scripture scripture,
      String sanskrit,
      String? transliteration,
      String? hindi,
      String? english,
      List<WordMeaning>? wordMeanings,
      String? noteText,
      int? bookNum,
      String? chapterLabel,
      String? translation,
      bool isBookmarked,
      int readCount,
      DateTime createdAt});
}

/// @nodoc
class __$VerseCopyWithImpl<$Res> implements _$VerseCopyWith<$Res> {
  __$VerseCopyWithImpl(this._self, this._then);

  final _Verse _self;
  final $Res Function(_Verse) _then;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? chapterNum = null,
    Object? verseNum = null,
    Object? scripture = null,
    Object? sanskrit = null,
    Object? transliteration = freezed,
    Object? hindi = freezed,
    Object? english = freezed,
    Object? wordMeanings = freezed,
    Object? noteText = freezed,
    Object? bookNum = freezed,
    Object? chapterLabel = freezed,
    Object? translation = freezed,
    Object? isBookmarked = null,
    Object? readCount = null,
    Object? createdAt = null,
  }) {
    return _then(_Verse(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chapterNum: null == chapterNum
          ? _self.chapterNum
          : chapterNum // ignore: cast_nullable_to_non_nullable
              as int,
      verseNum: null == verseNum
          ? _self.verseNum
          : verseNum // ignore: cast_nullable_to_non_nullable
              as int,
      scripture: null == scripture
          ? _self.scripture
          : scripture // ignore: cast_nullable_to_non_nullable
              as Scripture,
      sanskrit: null == sanskrit
          ? _self.sanskrit
          : sanskrit // ignore: cast_nullable_to_non_nullable
              as String,
      transliteration: freezed == transliteration
          ? _self.transliteration
          : transliteration // ignore: cast_nullable_to_non_nullable
              as String?,
      hindi: freezed == hindi
          ? _self.hindi
          : hindi // ignore: cast_nullable_to_non_nullable
              as String?,
      english: freezed == english
          ? _self.english
          : english // ignore: cast_nullable_to_non_nullable
              as String?,
      wordMeanings: freezed == wordMeanings
          ? _self._wordMeanings
          : wordMeanings // ignore: cast_nullable_to_non_nullable
              as List<WordMeaning>?,
      noteText: freezed == noteText
          ? _self.noteText
          : noteText // ignore: cast_nullable_to_non_nullable
              as String?,
      bookNum: freezed == bookNum
          ? _self.bookNum
          : bookNum // ignore: cast_nullable_to_non_nullable
              as int?,
      chapterLabel: freezed == chapterLabel
          ? _self.chapterLabel
          : chapterLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      translation: freezed == translation
          ? _self.translation
          : translation // ignore: cast_nullable_to_non_nullable
              as String?,
      isBookmarked: null == isBookmarked
          ? _self.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      readCount: null == readCount
          ? _self.readCount
          : readCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
