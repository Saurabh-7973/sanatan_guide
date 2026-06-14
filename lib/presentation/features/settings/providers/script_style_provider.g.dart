// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_style_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// User preference for how panchang/calendar Sanskrit names are scripted.
/// Defaults to [ScriptStyle.both] — keeps the Devanāgarī aesthetic while
/// adding the Latin (IAST) reading requested by beta testers.

@ProviderFor(ScriptStyleNotifier)
final scriptStyleProvider = ScriptStyleNotifierProvider._();

/// User preference for how panchang/calendar Sanskrit names are scripted.
/// Defaults to [ScriptStyle.both] — keeps the Devanāgarī aesthetic while
/// adding the Latin (IAST) reading requested by beta testers.
final class ScriptStyleNotifierProvider
    extends $NotifierProvider<ScriptStyleNotifier, ScriptStyle> {
  /// User preference for how panchang/calendar Sanskrit names are scripted.
  /// Defaults to [ScriptStyle.both] — keeps the Devanāgarī aesthetic while
  /// adding the Latin (IAST) reading requested by beta testers.
  ScriptStyleNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scriptStyleProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scriptStyleNotifierHash();

  @$internal
  @override
  ScriptStyleNotifier create() => ScriptStyleNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptStyle>(value),
    );
  }
}

String _$scriptStyleNotifierHash() =>
    r'e75d0d958a02ac7e070f474ebcda235dccc81f78';

/// User preference for how panchang/calendar Sanskrit names are scripted.
/// Defaults to [ScriptStyle.both] — keeps the Devanāgarī aesthetic while
/// adding the Latin (IAST) reading requested by beta testers.

abstract class _$ScriptStyleNotifier extends $Notifier<ScriptStyle> {
  ScriptStyle build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScriptStyle, ScriptStyle>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ScriptStyle, ScriptStyle>, ScriptStyle, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
