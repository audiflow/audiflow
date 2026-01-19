/// A streaming podcast feed parser for Dart and Flutter.
///
/// This library provides efficient parsing of podcast RSS feeds using a streaming
/// architecture that minimizes memory usage and provides real-time feedback.
///
/// ## Features
///
/// - **Streaming RSS Parser**: Memory-efficient streaming of RSS content
/// - **Comprehensive Podcast Support**: Full RSS 2.0 and iTunes namespace support
/// - **Intelligent Caching**: Persistent storage with HTTP optimization
/// - **Error Resilience**: Graceful handling of malformed feeds
/// - **Cross-Platform**: Works on iOS, Android, and other Flutter platforms
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:audiflow_podcast/audiflow_podcast.dart';
///
/// final parser = PodcastRssParser();
///
/// // Parse from URL with default caching
/// await for (final entity in parser.parseFromUrl('https://example.com/feed.xml')) {
///   if (entity is PodcastFeed) {
///     print('Podcast: ${entity.title}');
///     print('Description: ${entity.description}');
///   } else if (entity is PodcastItem) {
///     print('Episode: ${entity.title}');
///     print('Duration: ${entity.duration}');
///   }
/// }
///
/// // Don't forget to dispose when done
/// parser.dispose();
/// ```
///
/// ## Advanced Usage with Custom Cache Options
///
/// ```dart
/// final parser = PodcastRssParser();
///
/// final cacheOptions = CacheOptions(
///   ttl: Duration(minutes: 30),
///   useCache: true,
///   maxCacheSize: 50 * 1024 * 1024, // 50MB
/// );
///
/// await for (final entity in parser.parseFromUrl(
///   'https://example.com/feed.xml',
///   cacheOptions: cacheOptions,
/// )) {
///   // Handle entities...
/// }
/// ```
///
/// ## Parsing from Different Sources
///
/// ```dart
/// // From URL (with caching)
/// parser.parseFromUrl('https://example.com/feed.xml');
///
/// // From byte stream (useful for custom HTTP clients)
/// parser.parseFromStream(myByteStream);
///
/// // From XML string
/// parser.parseFromString(xmlContent);
/// ```
///
/// ## Error Handling
///
/// ```dart
/// await for (final entity in parser.parseFromUrl(url)) {
///   if (entity is PodcastParseError) {
///     print('Parsing error: ${entity.message}');
///     if (entity is NetworkError) {
///       print('Network issue: ${entity.originalException}');
///     }
///   } else {
///     // Handle valid entities...
///   }
/// }
/// ```
library;

export 'src/cache/cache_manager.dart';
// Cache management (for advanced usage)
export 'src/cache/cache_metadata.dart';
export 'src/errors/podcast_exception.dart';
// Error types
export 'src/errors/podcast_parse_error.dart';
export 'src/models/podcast_chapter.dart';
// Entity models
export 'src/models/podcast_entity.dart';
export 'src/models/podcast_feed.dart';
export 'src/models/podcast_image.dart';
export 'src/models/podcast_item.dart';
export 'src/models/podcast_transcript.dart';
// Network utilities (for advanced usage)
export 'src/network/http_fetcher.dart' show CacheInfo;
// Builder interface (for domain integration)
export 'src/parser/podcast_entity_builder.dart';
// Core parser
export 'src/podcast_feed_parser.dart' show CacheOptions, PodcastRssParser;
