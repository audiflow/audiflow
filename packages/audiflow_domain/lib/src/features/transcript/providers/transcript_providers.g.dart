// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcript_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether an episode has a supported transcript format.

@ProviderFor(episodeHasTranscript)
final episodeHasTranscriptProvider = EpisodeHasTranscriptFamily._();

/// Whether an episode has a supported transcript format.

final class EpisodeHasTranscriptProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether an episode has a supported transcript format.
  EpisodeHasTranscriptProvider._({
    required EpisodeHasTranscriptFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'episodeHasTranscriptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodeHasTranscriptHash();

  @override
  String toString() {
    return r'episodeHasTranscriptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return episodeHasTranscript(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodeHasTranscriptProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodeHasTranscriptHash() =>
    r'492f0d5602ae614fa0e157f851c0da9cb536fd23';

/// Whether an episode has a supported transcript format.

final class EpisodeHasTranscriptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  EpisodeHasTranscriptFamily._()
    : super(
        retry: null,
        name: r'episodeHasTranscriptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether an episode has a supported transcript format.

  EpisodeHasTranscriptProvider call(int episodeId) =>
      EpisodeHasTranscriptProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'episodeHasTranscriptProvider';
}
