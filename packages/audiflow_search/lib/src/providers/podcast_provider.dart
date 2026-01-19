import 'package:audiflow_search/audiflow_search.dart'
    show
        ContentNotModifiedException,
        RateLimitException,
        SearchException,
        SearchNetworkException;

import 'package:audiflow_search/src/exceptions/search_exception.dart'
    show
        ContentNotModifiedException,
        RateLimitException,
        SearchException,
        SearchNetworkException;

import '../builders/podcast_search_entity_builder.dart';
import '../builders/search_entity_result.dart';
import '../models/charts_query.dart';
import '../models/podcast.dart';
import '../models/search_query.dart';

/// Abstract base class defining the contract for podcast search providers.
///
/// This interface establishes the common API that all podcast search provider
/// implementations must follow. It enables polymorphic behavior allowing the
/// service layer to work with different providers (iTunes, PodcastIndex, etc.)
/// through a unified interface.
abstract class PodcastProvider {
  /// Unique identifier for this provider.
  String get providerId;

  /// Human-readable provider name.
  String get providerName;

  /// Whether this provider supports top charts retrieval.
  bool get supportsCharts;

  /// Searches for podcasts matching the given query.
  ///
  /// Returns a list of matching podcasts (may be empty).
  ///
  /// Throws:
  /// - [SearchException] for validation failures
  /// - [RateLimitException] if API rate limit is exceeded
  /// - [SearchNetworkException] on network failures
  /// - [ContentNotModifiedException] if content hasn't changed (304)
  Future<List<Podcast>> search(SearchQuery query);

  /// Searches for podcasts using a builder for zero-copy construction.
  ///
  /// Returns a [SearchEntityResult] containing the constructed entities.
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  });

  /// Retrieves top podcast charts for the specified parameters.
  ///
  /// Returns a ranked list of podcasts (may be partial or empty).
  ///
  /// Throws:
  /// - [UnsupportedError] if provider doesn't support charts
  /// - [SearchException] for validation failures
  /// - [ContentNotModifiedException] if content hasn't changed (304)
  Future<List<Podcast>> getTopCharts(ChartsQuery query);

  /// Retrieves top charts using a builder for zero-copy construction.
  ///
  /// Returns a [SearchEntityResult] containing the constructed entities.
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  });
}
