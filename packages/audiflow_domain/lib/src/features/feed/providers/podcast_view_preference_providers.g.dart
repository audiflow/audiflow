// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_view_preference_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches podcast view preference for a given podcast ID.
///
/// Returns defaults if no preference is stored.

@ProviderFor(podcastViewPreference)
final podcastViewPreferenceProvider = PodcastViewPreferenceFamily._();

/// Watches podcast view preference for a given podcast ID.
///
/// Returns defaults if no preference is stored.

final class PodcastViewPreferenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<PodcastViewPreferenceData>,
          PodcastViewPreferenceData,
          Stream<PodcastViewPreferenceData>
        >
    with
        $FutureModifier<PodcastViewPreferenceData>,
        $StreamProvider<PodcastViewPreferenceData> {
  /// Watches podcast view preference for a given podcast ID.
  ///
  /// Returns defaults if no preference is stored.
  PodcastViewPreferenceProvider._({
    required PodcastViewPreferenceFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'podcastViewPreferenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastViewPreferenceHash();

  @override
  String toString() {
    return r'podcastViewPreferenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PodcastViewPreferenceData> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PodcastViewPreferenceData> create(Ref ref) {
    final argument = this.argument as int;
    return podcastViewPreference(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastViewPreferenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastViewPreferenceHash() =>
    r'd4ed7bca2261f49b4182c526ae0f8d45173ac726';

/// Watches podcast view preference for a given podcast ID.
///
/// Returns defaults if no preference is stored.

final class PodcastViewPreferenceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PodcastViewPreferenceData>, int> {
  PodcastViewPreferenceFamily._()
    : super(
        retry: null,
        name: r'podcastViewPreferenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watches podcast view preference for a given podcast ID.
  ///
  /// Returns defaults if no preference is stored.

  PodcastViewPreferenceProvider call(int podcastId) =>
      PodcastViewPreferenceProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'podcastViewPreferenceProvider';
}

/// Controller for updating podcast view preferences.
///
/// Persists changes to Drift database immediately.

@ProviderFor(PodcastViewPreferenceController)
final podcastViewPreferenceControllerProvider =
    PodcastViewPreferenceControllerFamily._();

/// Controller for updating podcast view preferences.
///
/// Persists changes to Drift database immediately.
final class PodcastViewPreferenceControllerProvider
    extends
        $AsyncNotifierProvider<
          PodcastViewPreferenceController,
          PodcastViewPreferenceData
        > {
  /// Controller for updating podcast view preferences.
  ///
  /// Persists changes to Drift database immediately.
  PodcastViewPreferenceControllerProvider._({
    required PodcastViewPreferenceControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'podcastViewPreferenceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastViewPreferenceControllerHash();

  @override
  String toString() {
    return r'podcastViewPreferenceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PodcastViewPreferenceController create() => PodcastViewPreferenceController();

  @override
  bool operator ==(Object other) {
    return other is PodcastViewPreferenceControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastViewPreferenceControllerHash() =>
    r'd565ca57fa4098895db0354313546defc43e6a1f';

/// Controller for updating podcast view preferences.
///
/// Persists changes to Drift database immediately.

final class PodcastViewPreferenceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PodcastViewPreferenceController,
          AsyncValue<PodcastViewPreferenceData>,
          PodcastViewPreferenceData,
          FutureOr<PodcastViewPreferenceData>,
          int
        > {
  PodcastViewPreferenceControllerFamily._()
    : super(
        retry: null,
        name: r'podcastViewPreferenceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for updating podcast view preferences.
  ///
  /// Persists changes to Drift database immediately.

  PodcastViewPreferenceControllerProvider call(int podcastId) =>
      PodcastViewPreferenceControllerProvider._(
        argument: podcastId,
        from: this,
      );

  @override
  String toString() => r'podcastViewPreferenceControllerProvider';
}

/// Controller for updating podcast view preferences.
///
/// Persists changes to Drift database immediately.

abstract class _$PodcastViewPreferenceController
    extends $AsyncNotifier<PodcastViewPreferenceData> {
  late final _$args = ref.$arg as int;
  int get podcastId => _$args;

  FutureOr<PodcastViewPreferenceData> build(int podcastId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PodcastViewPreferenceData>,
              PodcastViewPreferenceData
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PodcastViewPreferenceData>,
                PodcastViewPreferenceData
              >,
              AsyncValue<PodcastViewPreferenceData>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
