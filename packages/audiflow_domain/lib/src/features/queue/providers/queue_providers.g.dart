// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watches the current queue state.

@ProviderFor(playbackQueue)
final playbackQueueProvider = PlaybackQueueProvider._();

/// Watches the current queue state.

final class PlaybackQueueProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaybackQueue>,
          PlaybackQueue,
          Stream<PlaybackQueue>
        >
    with $FutureModifier<PlaybackQueue>, $StreamProvider<PlaybackQueue> {
  /// Watches the current queue state.
  PlaybackQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playbackQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playbackQueueHash();

  @$internal
  @override
  $StreamProviderElement<PlaybackQueue> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PlaybackQueue> create(Ref ref) {
    return playbackQueue(ref);
  }
}

String _$playbackQueueHash() => r'e36fcc0a5577388b5797bc912071599a1b918cb8';

/// Gets the total number of items in queue.

@ProviderFor(queueItemCount)
final queueItemCountProvider = QueueItemCountProvider._();

/// Gets the total number of items in queue.

final class QueueItemCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Gets the total number of items in queue.
  QueueItemCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'queueItemCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$queueItemCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return queueItemCount(ref);
  }
}

String _$queueItemCountHash() => r'255353a301a8edd0ee407c40d246590afbf26a8d';

/// Returns true if manual queue has items (for adhoc confirmation).

@ProviderFor(hasManualQueueItems)
final hasManualQueueItemsProvider = HasManualQueueItemsProvider._();

/// Returns true if manual queue has items (for adhoc confirmation).

final class HasManualQueueItemsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Returns true if manual queue has items (for adhoc confirmation).
  HasManualQueueItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasManualQueueItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasManualQueueItemsHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasManualQueueItems(ref);
  }
}

String _$hasManualQueueItemsHash() =>
    r'eab966d0b5b41adbb94d4cc134d8636961dcd49d';
