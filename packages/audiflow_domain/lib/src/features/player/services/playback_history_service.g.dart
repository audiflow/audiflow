// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_history_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the PlaybackHistoryService.

@ProviderFor(playbackHistoryService)
final playbackHistoryServiceProvider = PlaybackHistoryServiceProvider._();

/// Provides the PlaybackHistoryService.

final class PlaybackHistoryServiceProvider
    extends
        $FunctionalProvider<
          PlaybackHistoryService,
          PlaybackHistoryService,
          PlaybackHistoryService
        >
    with $Provider<PlaybackHistoryService> {
  /// Provides the PlaybackHistoryService.
  PlaybackHistoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackHistoryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackHistoryServiceHash();

  @$internal
  @override
  $ProviderElement<PlaybackHistoryService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlaybackHistoryService create(Ref ref) {
    return playbackHistoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlaybackHistoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlaybackHistoryService>(value),
    );
  }
}

String _$playbackHistoryServiceHash() =>
    r'2cdd6fac3a91fdeaaa659847142058f081d87bef';
