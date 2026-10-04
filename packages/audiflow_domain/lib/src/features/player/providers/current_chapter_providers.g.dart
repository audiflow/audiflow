// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_chapter_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Chapters of the now-playing episode, ordered by start time.
///
/// Empty when nothing is playing, the episode is not stored locally, or it
/// has no chapters.

@ProviderFor(currentEpisodeChapters)
final currentEpisodeChaptersProvider = CurrentEpisodeChaptersProvider._();

/// Chapters of the now-playing episode, ordered by start time.
///
/// Empty when nothing is playing, the episode is not stored locally, or it
/// has no chapters.

final class CurrentEpisodeChaptersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EpisodeChapter>>,
          List<EpisodeChapter>,
          FutureOr<List<EpisodeChapter>>
        >
    with
        $FutureModifier<List<EpisodeChapter>>,
        $FutureProvider<List<EpisodeChapter>> {
  /// Chapters of the now-playing episode, ordered by start time.
  ///
  /// Empty when nothing is playing, the episode is not stored locally, or it
  /// has no chapters.
  CurrentEpisodeChaptersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentEpisodeChaptersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentEpisodeChaptersHash();

  @$internal
  @override
  $FutureProviderElement<List<EpisodeChapter>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EpisodeChapter>> create(Ref ref) {
    return currentEpisodeChapters(ref);
  }
}

String _$currentEpisodeChaptersHash() =>
    r'a9fa5ff1b5d0690ebf686ca42d61d59ca8a040a6';

/// The chapter containing the current playback position.
///
/// Null when the episode has no chapters or the position is before the
/// first chapter. Only notifies listeners when the chapter changes, not on
/// every progress tick.

@ProviderFor(currentChapter)
final currentChapterProvider = CurrentChapterProvider._();

/// The chapter containing the current playback position.
///
/// Null when the episode has no chapters or the position is before the
/// first chapter. Only notifies listeners when the chapter changes, not on
/// every progress tick.

final class CurrentChapterProvider
    extends
        $FunctionalProvider<CurrentChapter?, CurrentChapter?, CurrentChapter?>
    with $Provider<CurrentChapter?> {
  /// The chapter containing the current playback position.
  ///
  /// Null when the episode has no chapters or the position is before the
  /// first chapter. Only notifies listeners when the chapter changes, not on
  /// every progress tick.
  CurrentChapterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentChapterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentChapterHash();

  @$internal
  @override
  $ProviderElement<CurrentChapter?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CurrentChapter? create(Ref ref) {
    return currentChapter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CurrentChapter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CurrentChapter?>(value),
    );
  }
}

String _$currentChapterHash() => r'50ed7cafcb035e41097415840c25fad4b8ee2574';
