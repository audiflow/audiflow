/// Podcast search and discovery API client for Audiflow.
///
/// This package provides podcast search and chart discovery functionality
/// via the iTunes Search API, with support for zero-copy entity construction
/// using the builder pattern.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:audiflow_search/audiflow_search.dart';
///
/// // Create service with iTunes provider
/// final service = PodcastSearchService.create(
///   providers: [ItunesProvider()],
/// );
///
/// // Search for podcasts
/// final result = await service.search(
///   SearchQuery.validated(term: 'technology'),
/// );
///
/// // Get top charts
/// final charts = await service.getTopCharts(
///   ChartsQuery.validated(country: 'us'),
/// );
/// ```
///
/// ## Builder Pattern Usage
///
/// For zero-copy entity construction (e.g., with Drift):
///
/// ```dart
/// class DriftBuilder implements PodcastSearchEntityBuilder<PodcastsCompanion> {
///   @override
///   PodcastsCompanion buildPodcast(Map<String, dynamic> data) {
///     return PodcastsCompanion.insert(
///       itunesId: Value(data['id'] as String),
///       title: data['name'] as String,
///       // ...
///     );
///   }
///
///   @override
///   void onError(SearchException error) { /* handle */ }
///
///   @override
///   void onWarning(String message, {Map<String, dynamic>? context}) { /* handle */ }
/// }
///
/// final result = await service.searchWithBuilder(
///   query,
///   builder: DriftBuilder(),
/// );
/// ```
library;

// Builders
export 'src/builders/podcast_search_entity_builder.dart';
export 'src/builders/search_entity_result.dart';

// Exceptions
export 'src/exceptions/search_exception.dart';
export 'src/exceptions/status_code.dart';

// Models
export 'src/models/charts_query.dart';
export 'src/models/itunes_genre.dart';
export 'src/models/podcast.dart';
export 'src/models/search_query.dart';
export 'src/models/search_result.dart';

// Providers
export 'src/providers/itunes_provider.dart';
export 'src/providers/podcast_provider.dart';

// Services
export 'src/services/podcast_search_service.dart';
