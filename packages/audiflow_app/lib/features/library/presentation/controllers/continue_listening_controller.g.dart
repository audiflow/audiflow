// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continue_listening_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the list of episodes in progress with their details.
///
/// Combines PlaybackHistory with Episode data for display.

@ProviderFor(continueListeningEpisodes)
final continueListeningEpisodesProvider = ContinueListeningEpisodesProvider._();

/// Provides the list of episodes in progress with their details.
///
/// Combines PlaybackHistory with Episode data for display.

final class ContinueListeningEpisodesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EpisodeWithProgress>>,
          List<EpisodeWithProgress>,
          Stream<List<EpisodeWithProgress>>
        >
    with
        $FutureModifier<List<EpisodeWithProgress>>,
        $StreamProvider<List<EpisodeWithProgress>> {
  /// Provides the list of episodes in progress with their details.
  ///
  /// Combines PlaybackHistory with Episode data for display.
  ContinueListeningEpisodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'continueListeningEpisodesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$continueListeningEpisodesHash();

  @$internal
  @override
  $StreamProviderElement<List<EpisodeWithProgress>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EpisodeWithProgress>> create(Ref ref) {
    return continueListeningEpisodes(ref);
  }
}

String _$continueListeningEpisodesHash() =>
    r'8d6e32686481844970d87fd0b5b79ce79c2e3323';
