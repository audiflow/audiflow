// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_order_preference_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for [PlayOrderPreferenceLocalDatasource].

@ProviderFor(playOrderPreferenceLocalDatasource)
final playOrderPreferenceLocalDatasourceProvider =
    PlayOrderPreferenceLocalDatasourceProvider._();

/// Provider for [PlayOrderPreferenceLocalDatasource].

final class PlayOrderPreferenceLocalDatasourceProvider
    extends
        $FunctionalProvider<
          PlayOrderPreferenceLocalDatasource,
          PlayOrderPreferenceLocalDatasource,
          PlayOrderPreferenceLocalDatasource
        >
    with $Provider<PlayOrderPreferenceLocalDatasource> {
  /// Provider for [PlayOrderPreferenceLocalDatasource].
  PlayOrderPreferenceLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playOrderPreferenceLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$playOrderPreferenceLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<PlayOrderPreferenceLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayOrderPreferenceLocalDatasource create(Ref ref) {
    return playOrderPreferenceLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayOrderPreferenceLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayOrderPreferenceLocalDatasource>(
        value,
      ),
    );
  }
}

String _$playOrderPreferenceLocalDatasourceHash() =>
    r'359e22641d19d33b1d9d9b9fc95e88153c472f1e';

/// Provider for [PlayOrderPreferenceRepository].

@ProviderFor(playOrderPreferenceRepository)
final playOrderPreferenceRepositoryProvider =
    PlayOrderPreferenceRepositoryProvider._();

/// Provider for [PlayOrderPreferenceRepository].

final class PlayOrderPreferenceRepositoryProvider
    extends
        $FunctionalProvider<
          PlayOrderPreferenceRepository,
          PlayOrderPreferenceRepository,
          PlayOrderPreferenceRepository
        >
    with $Provider<PlayOrderPreferenceRepository> {
  /// Provider for [PlayOrderPreferenceRepository].
  PlayOrderPreferenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playOrderPreferenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playOrderPreferenceRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlayOrderPreferenceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlayOrderPreferenceRepository create(Ref ref) {
    return playOrderPreferenceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlayOrderPreferenceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlayOrderPreferenceRepository>(
        value,
      ),
    );
  }
}

String _$playOrderPreferenceRepositoryHash() =>
    r'04def7efe0b8f076fe7002cfc541d65ea7ac525d';
