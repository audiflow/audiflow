// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a Dio client for RSS feed fetching.

@ProviderFor(feedHttpClient)
final feedHttpClientProvider = FeedHttpClientProvider._();

/// Provides a Dio client for RSS feed fetching.

final class FeedHttpClientProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provides a Dio client for RSS feed fetching.
  FeedHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHttpClientHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return feedHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$feedHttpClientHash() => r'1f78c2cb06966ea95e535a2df41522826f3e0f46';

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

@ProviderFor(podcastDetail)
final podcastDetailProvider = PodcastDetailFamily._();

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

final class PodcastDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ParsedFeed>,
          ParsedFeed,
          FutureOr<ParsedFeed>
        >
    with $FutureModifier<ParsedFeed>, $FutureProvider<ParsedFeed> {
  /// Fetches and provides parsed podcast feed data for a given feed URL.
  ///
  /// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
  /// Returns [ParsedFeed] containing podcast metadata and episodes.
  /// Throws [PodcastException] if the feed cannot be fetched or parsed.
  PodcastDetailProvider._({
    required PodcastDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'podcastDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$podcastDetailHash();

  @override
  String toString() {
    return r'podcastDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ParsedFeed> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ParsedFeed> create(Ref ref) {
    final argument = this.argument as String;
    return podcastDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PodcastDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$podcastDetailHash() => r'cfa8005e138d3fd78fd3bc78e0740fc964fa1957';

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

final class PodcastDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ParsedFeed>, String> {
  PodcastDetailFamily._()
    : super(
        retry: null,
        name: r'podcastDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches and provides parsed podcast feed data for a given feed URL.
  ///
  /// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
  /// Returns [ParsedFeed] containing podcast metadata and episodes.
  /// Throws [PodcastException] if the feed cannot be fetched or parsed.

  PodcastDetailProvider call(String feedUrl) =>
      PodcastDetailProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastDetailProvider';
}
