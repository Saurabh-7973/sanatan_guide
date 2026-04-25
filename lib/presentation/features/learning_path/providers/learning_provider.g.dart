// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(learningDao)
final learningDaoProvider = LearningDaoProvider._();

final class LearningDaoProvider extends $FunctionalProvider<
        AsyncValue<LearningDao>, LearningDao, FutureOr<LearningDao>>
    with $FutureModifier<LearningDao>, $FutureProvider<LearningDao> {
  LearningDaoProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'learningDaoProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$learningDaoHash();

  @$internal
  @override
  $FutureProviderElement<LearningDao> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LearningDao> create(Ref ref) {
    return learningDao(ref);
  }
}

String _$learningDaoHash() => r'642c3e915da0b964f58430392e8c010f9a072252';

@ProviderFor(learningRepository)
final learningRepositoryProvider = LearningRepositoryProvider._();

final class LearningRepositoryProvider extends $FunctionalProvider<
        AsyncValue<ILearningRepository>,
        ILearningRepository,
        FutureOr<ILearningRepository>>
    with
        $FutureModifier<ILearningRepository>,
        $FutureProvider<ILearningRepository> {
  LearningRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'learningRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$learningRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ILearningRepository> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ILearningRepository> create(Ref ref) {
    return learningRepository(ref);
  }
}

String _$learningRepositoryHash() =>
    r'422500fefa0beced2fbf58b4101c59331b9d372d';

@ProviderFor(getModulesUseCase)
final getModulesUseCaseProvider = GetModulesUseCaseProvider._();

final class GetModulesUseCaseProvider extends $FunctionalProvider<
        AsyncValue<GetModulesUseCase>,
        GetModulesUseCase,
        FutureOr<GetModulesUseCase>>
    with
        $FutureModifier<GetModulesUseCase>,
        $FutureProvider<GetModulesUseCase> {
  GetModulesUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getModulesUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getModulesUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetModulesUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GetModulesUseCase> create(Ref ref) {
    return getModulesUseCase(ref);
  }
}

String _$getModulesUseCaseHash() => r'd8efc0a645d5546a027e5800c195a938f6275525';

@ProviderFor(getModuleDetailUseCase)
final getModuleDetailUseCaseProvider = GetModuleDetailUseCaseProvider._();

final class GetModuleDetailUseCaseProvider extends $FunctionalProvider<
        AsyncValue<GetModuleDetailUseCase>,
        GetModuleDetailUseCase,
        FutureOr<GetModuleDetailUseCase>>
    with
        $FutureModifier<GetModuleDetailUseCase>,
        $FutureProvider<GetModuleDetailUseCase> {
  GetModuleDetailUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'getModuleDetailUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$getModuleDetailUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<GetModuleDetailUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<GetModuleDetailUseCase> create(Ref ref) {
    return getModuleDetailUseCase(ref);
  }
}

String _$getModuleDetailUseCaseHash() =>
    r'e4b9d05c1b77978975f11be9b95016c29ba87405';

@ProviderFor(completeModuleUseCase)
final completeModuleUseCaseProvider = CompleteModuleUseCaseProvider._();

final class CompleteModuleUseCaseProvider extends $FunctionalProvider<
        AsyncValue<CompleteModuleUseCase>,
        CompleteModuleUseCase,
        FutureOr<CompleteModuleUseCase>>
    with
        $FutureModifier<CompleteModuleUseCase>,
        $FutureProvider<CompleteModuleUseCase> {
  CompleteModuleUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'completeModuleUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$completeModuleUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<CompleteModuleUseCase> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CompleteModuleUseCase> create(Ref ref) {
    return completeModuleUseCase(ref);
  }
}

String _$completeModuleUseCaseHash() =>
    r'ed883e334ad113a3a49868acb248677d0f691e89';

/// All modules with user progress — used by the learning path screen.

@ProviderFor(modules)
final modulesProvider = ModulesProvider._();

/// All modules with user progress — used by the learning path screen.

final class ModulesProvider extends $FunctionalProvider<
        AsyncValue<Either<Failure, List<LearningModule>>>,
        Either<Failure, List<LearningModule>>,
        FutureOr<Either<Failure, List<LearningModule>>>>
    with
        $FutureModifier<Either<Failure, List<LearningModule>>>,
        $FutureProvider<Either<Failure, List<LearningModule>>> {
  /// All modules with user progress — used by the learning path screen.
  ModulesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'modulesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$modulesHash();

  @$internal
  @override
  $FutureProviderElement<Either<Failure, List<LearningModule>>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, List<LearningModule>>> create(Ref ref) {
    return modules(ref);
  }
}

String _$modulesHash() => r'231e028527d0ba427555a825fcb721b7b6e6e28f';

/// Full detail for one module — used by the card stack reader.
/// Family keyed by moduleId.

@ProviderFor(moduleDetail)
final moduleDetailProvider = ModuleDetailFamily._();

/// Full detail for one module — used by the card stack reader.
/// Family keyed by moduleId.

final class ModuleDetailProvider extends $FunctionalProvider<
        AsyncValue<Either<Failure, ModuleDetail>>,
        Either<Failure, ModuleDetail>,
        FutureOr<Either<Failure, ModuleDetail>>>
    with
        $FutureModifier<Either<Failure, ModuleDetail>>,
        $FutureProvider<Either<Failure, ModuleDetail>> {
  /// Full detail for one module — used by the card stack reader.
  /// Family keyed by moduleId.
  ModuleDetailProvider._(
      {required ModuleDetailFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'moduleDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$moduleDetailHash();

  @override
  String toString() {
    return r'moduleDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Either<Failure, ModuleDetail>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, ModuleDetail>> create(Ref ref) {
    final argument = this.argument as String;
    return moduleDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ModuleDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moduleDetailHash() => r'3e81fc8a4f3d4d87b0481425603837eac025813d';

/// Full detail for one module — used by the card stack reader.
/// Family keyed by moduleId.

final class ModuleDetailFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<Either<Failure, ModuleDetail>>,
            String> {
  ModuleDetailFamily._()
      : super(
          retry: null,
          name: r'moduleDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// Full detail for one module — used by the card stack reader.
  /// Family keyed by moduleId.

  ModuleDetailProvider call(
    String moduleId,
  ) =>
      ModuleDetailProvider._(argument: moduleId, from: this);

  @override
  String toString() => r'moduleDetailProvider';
}
