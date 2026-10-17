// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_playback_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live playback history of one episode, or null before its first play.
///
/// Emits after every history write (progress saves included), so
/// watchers that display it should `select` what they show to avoid
/// rebuilding on writes that change nothing visible.

@ProviderFor(episodePlaybackHistory)
final episodePlaybackHistoryProvider = EpisodePlaybackHistoryFamily._();

/// Live playback history of one episode, or null before its first play.
///
/// Emits after every history write (progress saves included), so
/// watchers that display it should `select` what they show to avoid
/// rebuilding on writes that change nothing visible.

final class EpisodePlaybackHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaybackHistory?>,
          PlaybackHistory?,
          Stream<PlaybackHistory?>
        >
    with $FutureModifier<PlaybackHistory?>, $StreamProvider<PlaybackHistory?> {
  /// Live playback history of one episode, or null before its first play.
  ///
  /// Emits after every history write (progress saves included), so
  /// watchers that display it should `select` what they show to avoid
  /// rebuilding on writes that change nothing visible.
  EpisodePlaybackHistoryProvider._({
    required EpisodePlaybackHistoryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'episodePlaybackHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$episodePlaybackHistoryHash();

  @override
  String toString() {
    return r'episodePlaybackHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PlaybackHistory?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlaybackHistory?> create(Ref ref) {
    final argument = this.argument as int;
    return episodePlaybackHistory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EpisodePlaybackHistoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$episodePlaybackHistoryHash() =>
    r'b0acb1cdb0d351bd2ade54676ced6106a3ad368b';

/// Live playback history of one episode, or null before its first play.
///
/// Emits after every history write (progress saves included), so
/// watchers that display it should `select` what they show to avoid
/// rebuilding on writes that change nothing visible.

final class EpisodePlaybackHistoryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PlaybackHistory?>, int> {
  EpisodePlaybackHistoryFamily._()
    : super(
        retry: null,
        name: r'episodePlaybackHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live playback history of one episode, or null before its first play.
  ///
  /// Emits after every history write (progress saves included), so
  /// watchers that display it should `select` what they show to avoid
  /// rebuilding on writes that change nothing visible.

  EpisodePlaybackHistoryProvider call(int episodeId) =>
      EpisodePlaybackHistoryProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'episodePlaybackHistoryProvider';
}
