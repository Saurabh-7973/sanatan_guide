// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_module.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LearningModule {
  String get id;
  String get title;
  String get hook;
  int get level;
  int get sequence;
  int get estimatedMinutes;
  int get cardCount;
  bool get isCompleted;
  int get cardsRead;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LearningModuleCopyWith<LearningModule> get copyWith =>
      _$LearningModuleCopyWithImpl<LearningModule>(
          this as LearningModule, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LearningModule &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.hook, hook) || other.hook == hook) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.cardCount, cardCount) ||
                other.cardCount == cardCount) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.cardsRead, cardsRead) ||
                other.cardsRead == cardsRead));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, hook, level, sequence,
      estimatedMinutes, cardCount, isCompleted, cardsRead);

  @override
  String toString() {
    return 'LearningModule(id: $id, title: $title, hook: $hook, level: $level, sequence: $sequence, estimatedMinutes: $estimatedMinutes, cardCount: $cardCount, isCompleted: $isCompleted, cardsRead: $cardsRead)';
  }
}

/// @nodoc
abstract mixin class $LearningModuleCopyWith<$Res> {
  factory $LearningModuleCopyWith(
          LearningModule value, $Res Function(LearningModule) _then) =
      _$LearningModuleCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String hook,
      int level,
      int sequence,
      int estimatedMinutes,
      int cardCount,
      bool isCompleted,
      int cardsRead});
}

/// @nodoc
class _$LearningModuleCopyWithImpl<$Res>
    implements $LearningModuleCopyWith<$Res> {
  _$LearningModuleCopyWithImpl(this._self, this._then);

  final LearningModule _self;
  final $Res Function(LearningModule) _then;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? hook = null,
    Object? level = null,
    Object? sequence = null,
    Object? estimatedMinutes = null,
    Object? cardCount = null,
    Object? isCompleted = null,
    Object? cardsRead = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      hook: null == hook
          ? _self.hook
          : hook // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      sequence: null == sequence
          ? _self.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      cardCount: null == cardCount
          ? _self.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      cardsRead: null == cardsRead
          ? _self.cardsRead
          : cardsRead // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [LearningModule].
extension LearningModulePatterns on LearningModule {
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
    TResult Function(_LearningModule value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LearningModule() when $default != null:
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
    TResult Function(_LearningModule value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LearningModule():
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
    TResult? Function(_LearningModule value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LearningModule() when $default != null:
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
            String title,
            String hook,
            int level,
            int sequence,
            int estimatedMinutes,
            int cardCount,
            bool isCompleted,
            int cardsRead)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LearningModule() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.hook,
            _that.level,
            _that.sequence,
            _that.estimatedMinutes,
            _that.cardCount,
            _that.isCompleted,
            _that.cardsRead);
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
            String title,
            String hook,
            int level,
            int sequence,
            int estimatedMinutes,
            int cardCount,
            bool isCompleted,
            int cardsRead)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LearningModule():
        return $default(
            _that.id,
            _that.title,
            _that.hook,
            _that.level,
            _that.sequence,
            _that.estimatedMinutes,
            _that.cardCount,
            _that.isCompleted,
            _that.cardsRead);
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
            String title,
            String hook,
            int level,
            int sequence,
            int estimatedMinutes,
            int cardCount,
            bool isCompleted,
            int cardsRead)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LearningModule() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.hook,
            _that.level,
            _that.sequence,
            _that.estimatedMinutes,
            _that.cardCount,
            _that.isCompleted,
            _that.cardsRead);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _LearningModule implements LearningModule {
  const _LearningModule(
      {required this.id,
      required this.title,
      required this.hook,
      required this.level,
      required this.sequence,
      required this.estimatedMinutes,
      required this.cardCount,
      this.isCompleted = false,
      this.cardsRead = 0});

  @override
  final String id;
  @override
  final String title;
  @override
  final String hook;
  @override
  final int level;
  @override
  final int sequence;
  @override
  final int estimatedMinutes;
  @override
  final int cardCount;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final int cardsRead;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LearningModuleCopyWith<_LearningModule> get copyWith =>
      __$LearningModuleCopyWithImpl<_LearningModule>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LearningModule &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.hook, hook) || other.hook == hook) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            (identical(other.cardCount, cardCount) ||
                other.cardCount == cardCount) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.cardsRead, cardsRead) ||
                other.cardsRead == cardsRead));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, hook, level, sequence,
      estimatedMinutes, cardCount, isCompleted, cardsRead);

  @override
  String toString() {
    return 'LearningModule(id: $id, title: $title, hook: $hook, level: $level, sequence: $sequence, estimatedMinutes: $estimatedMinutes, cardCount: $cardCount, isCompleted: $isCompleted, cardsRead: $cardsRead)';
  }
}

/// @nodoc
abstract mixin class _$LearningModuleCopyWith<$Res>
    implements $LearningModuleCopyWith<$Res> {
  factory _$LearningModuleCopyWith(
          _LearningModule value, $Res Function(_LearningModule) _then) =
      __$LearningModuleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String hook,
      int level,
      int sequence,
      int estimatedMinutes,
      int cardCount,
      bool isCompleted,
      int cardsRead});
}

/// @nodoc
class __$LearningModuleCopyWithImpl<$Res>
    implements _$LearningModuleCopyWith<$Res> {
  __$LearningModuleCopyWithImpl(this._self, this._then);

  final _LearningModule _self;
  final $Res Function(_LearningModule) _then;

  /// Create a copy of LearningModule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? hook = null,
    Object? level = null,
    Object? sequence = null,
    Object? estimatedMinutes = null,
    Object? cardCount = null,
    Object? isCompleted = null,
    Object? cardsRead = null,
  }) {
    return _then(_LearningModule(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      hook: null == hook
          ? _self.hook
          : hook // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      sequence: null == sequence
          ? _self.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedMinutes: null == estimatedMinutes
          ? _self.estimatedMinutes
          : estimatedMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      cardCount: null == cardCount
          ? _self.cardCount
          : cardCount // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _self.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      cardsRead: null == cardsRead
          ? _self.cardsRead
          : cardsRead // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$ModuleCard {
  String get id;
  String get moduleId;
  int get sequence;
  String get cardTitle;
  String get content;

  /// Create a copy of ModuleCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ModuleCardCopyWith<ModuleCard> get copyWith =>
      _$ModuleCardCopyWithImpl<ModuleCard>(this as ModuleCard, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ModuleCard &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.cardTitle, cardTitle) ||
                other.cardTitle == cardTitle) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, moduleId, sequence, cardTitle, content);

  @override
  String toString() {
    return 'ModuleCard(id: $id, moduleId: $moduleId, sequence: $sequence, cardTitle: $cardTitle, content: $content)';
  }
}

/// @nodoc
abstract mixin class $ModuleCardCopyWith<$Res> {
  factory $ModuleCardCopyWith(
          ModuleCard value, $Res Function(ModuleCard) _then) =
      _$ModuleCardCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String moduleId,
      int sequence,
      String cardTitle,
      String content});
}

/// @nodoc
class _$ModuleCardCopyWithImpl<$Res> implements $ModuleCardCopyWith<$Res> {
  _$ModuleCardCopyWithImpl(this._self, this._then);

  final ModuleCard _self;
  final $Res Function(ModuleCard) _then;

  /// Create a copy of ModuleCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? sequence = null,
    Object? cardTitle = null,
    Object? content = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: null == moduleId
          ? _self.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _self.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      cardTitle: null == cardTitle
          ? _self.cardTitle
          : cardTitle // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ModuleCard].
extension ModuleCardPatterns on ModuleCard {
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
    TResult Function(_ModuleCard value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ModuleCard() when $default != null:
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
    TResult Function(_ModuleCard value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleCard():
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
    TResult? Function(_ModuleCard value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleCard() when $default != null:
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
    TResult Function(String id, String moduleId, int sequence, String cardTitle,
            String content)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ModuleCard() when $default != null:
        return $default(_that.id, _that.moduleId, _that.sequence,
            _that.cardTitle, _that.content);
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
    TResult Function(String id, String moduleId, int sequence, String cardTitle,
            String content)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleCard():
        return $default(_that.id, _that.moduleId, _that.sequence,
            _that.cardTitle, _that.content);
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
    TResult? Function(String id, String moduleId, int sequence,
            String cardTitle, String content)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleCard() when $default != null:
        return $default(_that.id, _that.moduleId, _that.sequence,
            _that.cardTitle, _that.content);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ModuleCard implements ModuleCard {
  const _ModuleCard(
      {required this.id,
      required this.moduleId,
      required this.sequence,
      required this.cardTitle,
      required this.content});

  @override
  final String id;
  @override
  final String moduleId;
  @override
  final int sequence;
  @override
  final String cardTitle;
  @override
  final String content;

  /// Create a copy of ModuleCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ModuleCardCopyWith<_ModuleCard> get copyWith =>
      __$ModuleCardCopyWithImpl<_ModuleCard>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ModuleCard &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.cardTitle, cardTitle) ||
                other.cardTitle == cardTitle) &&
            (identical(other.content, content) || other.content == content));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, moduleId, sequence, cardTitle, content);

  @override
  String toString() {
    return 'ModuleCard(id: $id, moduleId: $moduleId, sequence: $sequence, cardTitle: $cardTitle, content: $content)';
  }
}

/// @nodoc
abstract mixin class _$ModuleCardCopyWith<$Res>
    implements $ModuleCardCopyWith<$Res> {
  factory _$ModuleCardCopyWith(
          _ModuleCard value, $Res Function(_ModuleCard) _then) =
      __$ModuleCardCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String moduleId,
      int sequence,
      String cardTitle,
      String content});
}

/// @nodoc
class __$ModuleCardCopyWithImpl<$Res> implements _$ModuleCardCopyWith<$Res> {
  __$ModuleCardCopyWithImpl(this._self, this._then);

  final _ModuleCard _self;
  final $Res Function(_ModuleCard) _then;

  /// Create a copy of ModuleCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? moduleId = null,
    Object? sequence = null,
    Object? cardTitle = null,
    Object? content = null,
  }) {
    return _then(_ModuleCard(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      moduleId: null == moduleId
          ? _self.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      sequence: null == sequence
          ? _self.sequence
          : sequence // ignore: cast_nullable_to_non_nullable
              as int,
      cardTitle: null == cardTitle
          ? _self.cardTitle
          : cardTitle // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ModuleDetail {
  LearningModule get module;
  List<ModuleCard> get cards;
  String? get anchorVerseId;
  String? get anchorVerseNote;
  String? get reflectionQuestion;

  /// Create a copy of ModuleDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ModuleDetailCopyWith<ModuleDetail> get copyWith =>
      _$ModuleDetailCopyWithImpl<ModuleDetail>(
          this as ModuleDetail, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ModuleDetail &&
            (identical(other.module, module) || other.module == module) &&
            const DeepCollectionEquality().equals(other.cards, cards) &&
            (identical(other.anchorVerseId, anchorVerseId) ||
                other.anchorVerseId == anchorVerseId) &&
            (identical(other.anchorVerseNote, anchorVerseNote) ||
                other.anchorVerseNote == anchorVerseNote) &&
            (identical(other.reflectionQuestion, reflectionQuestion) ||
                other.reflectionQuestion == reflectionQuestion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      module,
      const DeepCollectionEquality().hash(cards),
      anchorVerseId,
      anchorVerseNote,
      reflectionQuestion);

  @override
  String toString() {
    return 'ModuleDetail(module: $module, cards: $cards, anchorVerseId: $anchorVerseId, anchorVerseNote: $anchorVerseNote, reflectionQuestion: $reflectionQuestion)';
  }
}

/// @nodoc
abstract mixin class $ModuleDetailCopyWith<$Res> {
  factory $ModuleDetailCopyWith(
          ModuleDetail value, $Res Function(ModuleDetail) _then) =
      _$ModuleDetailCopyWithImpl;
  @useResult
  $Res call(
      {LearningModule module,
      List<ModuleCard> cards,
      String? anchorVerseId,
      String? anchorVerseNote,
      String? reflectionQuestion});

  $LearningModuleCopyWith<$Res> get module;
}

/// @nodoc
class _$ModuleDetailCopyWithImpl<$Res> implements $ModuleDetailCopyWith<$Res> {
  _$ModuleDetailCopyWithImpl(this._self, this._then);

  final ModuleDetail _self;
  final $Res Function(ModuleDetail) _then;

  /// Create a copy of ModuleDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? module = null,
    Object? cards = null,
    Object? anchorVerseId = freezed,
    Object? anchorVerseNote = freezed,
    Object? reflectionQuestion = freezed,
  }) {
    return _then(_self.copyWith(
      module: null == module
          ? _self.module
          : module // ignore: cast_nullable_to_non_nullable
              as LearningModule,
      cards: null == cards
          ? _self.cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<ModuleCard>,
      anchorVerseId: freezed == anchorVerseId
          ? _self.anchorVerseId
          : anchorVerseId // ignore: cast_nullable_to_non_nullable
              as String?,
      anchorVerseNote: freezed == anchorVerseNote
          ? _self.anchorVerseNote
          : anchorVerseNote // ignore: cast_nullable_to_non_nullable
              as String?,
      reflectionQuestion: freezed == reflectionQuestion
          ? _self.reflectionQuestion
          : reflectionQuestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ModuleDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LearningModuleCopyWith<$Res> get module {
    return $LearningModuleCopyWith<$Res>(_self.module, (value) {
      return _then(_self.copyWith(module: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ModuleDetail].
extension ModuleDetailPatterns on ModuleDetail {
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
    TResult Function(_ModuleDetail value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ModuleDetail() when $default != null:
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
    TResult Function(_ModuleDetail value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleDetail():
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
    TResult? Function(_ModuleDetail value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleDetail() when $default != null:
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
            LearningModule module,
            List<ModuleCard> cards,
            String? anchorVerseId,
            String? anchorVerseNote,
            String? reflectionQuestion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ModuleDetail() when $default != null:
        return $default(_that.module, _that.cards, _that.anchorVerseId,
            _that.anchorVerseNote, _that.reflectionQuestion);
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
            LearningModule module,
            List<ModuleCard> cards,
            String? anchorVerseId,
            String? anchorVerseNote,
            String? reflectionQuestion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleDetail():
        return $default(_that.module, _that.cards, _that.anchorVerseId,
            _that.anchorVerseNote, _that.reflectionQuestion);
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
            LearningModule module,
            List<ModuleCard> cards,
            String? anchorVerseId,
            String? anchorVerseNote,
            String? reflectionQuestion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ModuleDetail() when $default != null:
        return $default(_that.module, _that.cards, _that.anchorVerseId,
            _that.anchorVerseNote, _that.reflectionQuestion);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ModuleDetail implements ModuleDetail {
  const _ModuleDetail(
      {required this.module,
      required final List<ModuleCard> cards,
      this.anchorVerseId,
      this.anchorVerseNote,
      this.reflectionQuestion})
      : _cards = cards;

  @override
  final LearningModule module;
  final List<ModuleCard> _cards;
  @override
  List<ModuleCard> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  @override
  final String? anchorVerseId;
  @override
  final String? anchorVerseNote;
  @override
  final String? reflectionQuestion;

  /// Create a copy of ModuleDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ModuleDetailCopyWith<_ModuleDetail> get copyWith =>
      __$ModuleDetailCopyWithImpl<_ModuleDetail>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ModuleDetail &&
            (identical(other.module, module) || other.module == module) &&
            const DeepCollectionEquality().equals(other._cards, _cards) &&
            (identical(other.anchorVerseId, anchorVerseId) ||
                other.anchorVerseId == anchorVerseId) &&
            (identical(other.anchorVerseNote, anchorVerseNote) ||
                other.anchorVerseNote == anchorVerseNote) &&
            (identical(other.reflectionQuestion, reflectionQuestion) ||
                other.reflectionQuestion == reflectionQuestion));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      module,
      const DeepCollectionEquality().hash(_cards),
      anchorVerseId,
      anchorVerseNote,
      reflectionQuestion);

  @override
  String toString() {
    return 'ModuleDetail(module: $module, cards: $cards, anchorVerseId: $anchorVerseId, anchorVerseNote: $anchorVerseNote, reflectionQuestion: $reflectionQuestion)';
  }
}

/// @nodoc
abstract mixin class _$ModuleDetailCopyWith<$Res>
    implements $ModuleDetailCopyWith<$Res> {
  factory _$ModuleDetailCopyWith(
          _ModuleDetail value, $Res Function(_ModuleDetail) _then) =
      __$ModuleDetailCopyWithImpl;
  @override
  @useResult
  $Res call(
      {LearningModule module,
      List<ModuleCard> cards,
      String? anchorVerseId,
      String? anchorVerseNote,
      String? reflectionQuestion});

  @override
  $LearningModuleCopyWith<$Res> get module;
}

/// @nodoc
class __$ModuleDetailCopyWithImpl<$Res>
    implements _$ModuleDetailCopyWith<$Res> {
  __$ModuleDetailCopyWithImpl(this._self, this._then);

  final _ModuleDetail _self;
  final $Res Function(_ModuleDetail) _then;

  /// Create a copy of ModuleDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? module = null,
    Object? cards = null,
    Object? anchorVerseId = freezed,
    Object? anchorVerseNote = freezed,
    Object? reflectionQuestion = freezed,
  }) {
    return _then(_ModuleDetail(
      module: null == module
          ? _self.module
          : module // ignore: cast_nullable_to_non_nullable
              as LearningModule,
      cards: null == cards
          ? _self._cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<ModuleCard>,
      anchorVerseId: freezed == anchorVerseId
          ? _self.anchorVerseId
          : anchorVerseId // ignore: cast_nullable_to_non_nullable
              as String?,
      anchorVerseNote: freezed == anchorVerseNote
          ? _self.anchorVerseNote
          : anchorVerseNote // ignore: cast_nullable_to_non_nullable
              as String?,
      reflectionQuestion: freezed == reflectionQuestion
          ? _self.reflectionQuestion
          : reflectionQuestion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ModuleDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LearningModuleCopyWith<$Res> get module {
    return $LearningModuleCopyWith<$Res>(_self.module, (value) {
      return _then(_self.copyWith(module: value));
    });
  }
}

// dart format on
