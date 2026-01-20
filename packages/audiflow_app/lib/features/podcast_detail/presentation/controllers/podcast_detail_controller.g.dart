// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.

@ProviderFor(podcastDetail)
final podcastDetailProvider = PodcastDetailFamily._();

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
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

String _$podcastDetailHash() => r'1aa0055f6979a77668b227271e8644d6f4c41989';

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
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
  /// Returns [ParsedFeed] containing podcast metadata and episodes.
  /// Throws [PodcastException] if the feed cannot be fetched or parsed.

  PodcastDetailProvider call(String feedUrl) =>
      PodcastDetailProvider._(argument: feedUrl, from: this);

  @override
  String toString() => r'podcastDetailProvider';
}
