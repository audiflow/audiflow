// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_availability_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What transcript fetches this session found out, by episode id: true when
/// a transcript loaded, false when none of the declared files yielded one.
///
/// Lets every surface that offers a transcript (the episode row's badge,
/// the player's page) agree once a fetch has settled the question, without
/// each one fetching. Unusable files are also recorded on disk; this map
/// additionally covers failures that are kept retryable (offline, HTTP
/// errors) for the rest of the session.

@ProviderFor(TranscriptFetchOutcomes)
final transcriptFetchOutcomesProvider = TranscriptFetchOutcomesProvider._();

/// What transcript fetches this session found out, by episode id: true when
/// a transcript loaded, false when none of the declared files yielded one.
///
/// Lets every surface that offers a transcript (the episode row's badge,
/// the player's page) agree once a fetch has settled the question, without
/// each one fetching. Unusable files are also recorded on disk; this map
/// additionally covers failures that are kept retryable (offline, HTTP
/// errors) for the rest of the session.
final class TranscriptFetchOutcomesProvider
    extends $NotifierProvider<TranscriptFetchOutcomes, Map<int, bool>> {
  /// What transcript fetches this session found out, by episode id: true when
  /// a transcript loaded, false when none of the declared files yielded one.
  ///
  /// Lets every surface that offers a transcript (the episode row's badge,
  /// the player's page) agree once a fetch has settled the question, without
  /// each one fetching. Unusable files are also recorded on disk; this map
  /// additionally covers failures that are kept retryable (offline, HTTP
  /// errors) for the rest of the session.
  TranscriptFetchOutcomesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transcriptFetchOutcomesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transcriptFetchOutcomesHash();

  @$internal
  @override
  TranscriptFetchOutcomes create() => TranscriptFetchOutcomes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, bool>>(value),
    );
  }
}

String _$transcriptFetchOutcomesHash() =>
    r'b7b17e1e64baff4312a07794f6dff53a3f8758d9';

/// What transcript fetches this session found out, by episode id: true when
/// a transcript loaded, false when none of the declared files yielded one.
///
/// Lets every surface that offers a transcript (the episode row's badge,
/// the player's page) agree once a fetch has settled the question, without
/// each one fetching. Unusable files are also recorded on disk; this map
/// additionally covers failures that are kept retryable (offline, HTTP
/// errors) for the rest of the session.

abstract class _$TranscriptFetchOutcomes extends $Notifier<Map<int, bool>> {
  Map<int, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<int, bool>, Map<int, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, bool>, Map<int, bool>>,
              Map<int, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// The id of the episode's transcript once its content is stored, fetching
/// it if needed; null when the episode has no transcript that loads.
///
/// Watching this costs a download the first time, so it is meant for the
/// now-playing episode, not for every row of a list.

@ProviderFor(usableTranscriptId)
final usableTranscriptIdProvider = UsableTranscriptIdFamily._();

/// The id of the episode's transcript once its content is stored, fetching
/// it if needed; null when the episode has no transcript that loads.
///
/// Watching this costs a download the first time, so it is meant for the
/// now-playing episode, not for every row of a list.

final class UsableTranscriptIdProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// The id of the episode's transcript once its content is stored, fetching
  /// it if needed; null when the episode has no transcript that loads.
  ///
  /// Watching this costs a download the first time, so it is meant for the
  /// now-playing episode, not for every row of a list.
  UsableTranscriptIdProvider._({
    required UsableTranscriptIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'usableTranscriptIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$usableTranscriptIdHash();

  @override
  String toString() {
    return r'usableTranscriptIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as int;
    return usableTranscriptId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UsableTranscriptIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$usableTranscriptIdHash() =>
    r'9807c55e93b59702d72a979b27ff8054cf798fde';

/// The id of the episode's transcript once its content is stored, fetching
/// it if needed; null when the episode has no transcript that loads.
///
/// Watching this costs a download the first time, so it is meant for the
/// now-playing episode, not for every row of a list.

final class UsableTranscriptIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, int> {
  UsableTranscriptIdFamily._()
    : super(
        retry: null,
        name: r'usableTranscriptIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The id of the episode's transcript once its content is stored, fetching
  /// it if needed; null when the episode has no transcript that loads.
  ///
  /// Watching this costs a download the first time, so it is meant for the
  /// now-playing episode, not for every row of a list.

  UsableTranscriptIdProvider call(int episodeId) =>
      UsableTranscriptIdProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'usableTranscriptIdProvider';
}
