// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_sort_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for season sort preferences.

@ProviderFor(SeasonSortController)
final seasonSortControllerProvider = SeasonSortControllerFamily._();

/// Controller for season sort preferences.
final class SeasonSortControllerProvider
    extends $NotifierProvider<SeasonSortController, SeasonSortConfig> {
  /// Controller for season sort preferences.
  SeasonSortControllerProvider._({
    required SeasonSortControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'seasonSortControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seasonSortControllerHash();

  @override
  String toString() {
    return r'seasonSortControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeasonSortController create() => SeasonSortController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeasonSortConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeasonSortConfig>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeasonSortControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seasonSortControllerHash() =>
    r'aa0a8634a837a09f8b91322bf7f0fbd38e9f121c';

/// Controller for season sort preferences.

final class SeasonSortControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SeasonSortController,
          SeasonSortConfig,
          SeasonSortConfig,
          SeasonSortConfig,
          int
        > {
  SeasonSortControllerFamily._()
    : super(
        retry: null,
        name: r'seasonSortControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for season sort preferences.

  SeasonSortControllerProvider call(int podcastId) =>
      SeasonSortControllerProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'seasonSortControllerProvider';
}

/// Controller for season sort preferences.

abstract class _$SeasonSortController extends $Notifier<SeasonSortConfig> {
  late final _$args = ref.$arg as int;
  int get podcastId => _$args;

  SeasonSortConfig build(int podcastId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SeasonSortConfig, SeasonSortConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SeasonSortConfig, SeasonSortConfig>,
              SeasonSortConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
