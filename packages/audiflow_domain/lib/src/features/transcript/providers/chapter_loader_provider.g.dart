// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_loader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads on-demand chapters for the now-playing episode.
///
/// Chapters that are not stored during feed sync are fetched when an episode
/// becomes the now-playing one, which covers both starting playback and
/// opening the player. Chapter providers are refreshed once new chapters
/// are stored, so the player picks them up without reopening.
///
/// Read once at startup to activate; kept alive for the app's lifetime.

@ProviderFor(nowPlayingChapterLoader)
final nowPlayingChapterLoaderProvider = NowPlayingChapterLoaderProvider._();

/// Loads on-demand chapters for the now-playing episode.
///
/// Chapters that are not stored during feed sync are fetched when an episode
/// becomes the now-playing one, which covers both starting playback and
/// opening the player. Chapter providers are refreshed once new chapters
/// are stored, so the player picks them up without reopening.
///
/// Read once at startup to activate; kept alive for the app's lifetime.

final class NowPlayingChapterLoaderProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Loads on-demand chapters for the now-playing episode.
  ///
  /// Chapters that are not stored during feed sync are fetched when an episode
  /// becomes the now-playing one, which covers both starting playback and
  /// opening the player. Chapter providers are refreshed once new chapters
  /// are stored, so the player picks them up without reopening.
  ///
  /// Read once at startup to activate; kept alive for the app's lifetime.
  NowPlayingChapterLoaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingChapterLoaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingChapterLoaderHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return nowPlayingChapterLoader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$nowPlayingChapterLoaderHash() =>
    r'b9a571c5a6e33c5e3c25ae6ca6331f54bec4c972';
