// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_parser_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service for parsing podcast RSS feeds.
///
/// Uses [PodcastRssParser] to fetch and parse RSS feeds, returning structured
/// podcast data. The service handles caching, error handling, and logging.
///
/// Example usage:
/// ```dart
/// final service = ref.watch(feedParserServiceProvider);
/// final result = await service.parseFromUrl('https://example.com/feed.xml');
/// print('Found ${result.episodeCount} episodes');
/// ```

@ProviderFor(feedParserService)
final feedParserServiceProvider = FeedParserServiceProvider._();

/// Service for parsing podcast RSS feeds.
///
/// Uses [PodcastRssParser] to fetch and parse RSS feeds, returning structured
/// podcast data. The service handles caching, error handling, and logging.
///
/// Example usage:
/// ```dart
/// final service = ref.watch(feedParserServiceProvider);
/// final result = await service.parseFromUrl('https://example.com/feed.xml');
/// print('Found ${result.episodeCount} episodes');
/// ```

final class FeedParserServiceProvider
    extends
        $FunctionalProvider<
          FeedParserService,
          FeedParserService,
          FeedParserService
        >
    with $Provider<FeedParserService> {
  /// Service for parsing podcast RSS feeds.
  ///
  /// Uses [PodcastRssParser] to fetch and parse RSS feeds, returning structured
  /// podcast data. The service handles caching, error handling, and logging.
  ///
  /// Example usage:
  /// ```dart
  /// final service = ref.watch(feedParserServiceProvider);
  /// final result = await service.parseFromUrl('https://example.com/feed.xml');
  /// print('Found ${result.episodeCount} episodes');
  /// ```
  FeedParserServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedParserServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedParserServiceHash();

  @$internal
  @override
  $ProviderElement<FeedParserService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeedParserService create(Ref ref) {
    return feedParserService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedParserService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedParserService>(value),
    );
  }
}

String _$feedParserServiceHash() => r'90623487f85c90ed981006e6aacc7fa49cd22b1f';
