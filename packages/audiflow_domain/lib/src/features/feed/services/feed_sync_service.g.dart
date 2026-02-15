// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a singleton [FeedSyncService] for syncing podcast feeds.

@ProviderFor(feedSyncService)
final feedSyncServiceProvider = FeedSyncServiceProvider._();

/// Provides a singleton [FeedSyncService] for syncing podcast feeds.

final class FeedSyncServiceProvider
    extends
        $FunctionalProvider<FeedSyncService, FeedSyncService, FeedSyncService>
    with $Provider<FeedSyncService> {
  /// Provides a singleton [FeedSyncService] for syncing podcast feeds.
  FeedSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedSyncServiceHash();

  @$internal
  @override
  $ProviderElement<FeedSyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedSyncService create(Ref ref) {
    return feedSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedSyncService>(value),
    );
  }
}

String _$feedSyncServiceHash() => r'f5ac16dd61e75ed66d6c2816ce0a8500030ea188';
