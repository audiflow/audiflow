// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_history_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [PlaybackHistoryRepository] instance.

@ProviderFor(playbackHistoryRepository)
final playbackHistoryRepositoryProvider = PlaybackHistoryRepositoryProvider._();

/// Provides a singleton [PlaybackHistoryRepository] instance.

final class PlaybackHistoryRepositoryProvider
    extends
        $FunctionalProvider<
          PlaybackHistoryRepository,
          PlaybackHistoryRepository,
          PlaybackHistoryRepository
        >
    with $Provider<PlaybackHistoryRepository> {
  /// Provides a singleton [PlaybackHistoryRepository] instance.
  PlaybackHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackHistoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlaybackHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaybackHistoryRepository create(Ref ref) {
    return playbackHistoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackHistoryRepository>(value),
    );
  }
}

String _$playbackHistoryRepositoryHash() =>
    r'b9c9972d47b54b88f6c526af6e061fc45a778c75';
