/// Pure-Dart podcast RSS parser without Flutter dependencies.
///
/// This library exports only the core parsing functionality that doesn't
/// require Flutter plugins (path_provider, shared_preferences).
///
/// Use this for CLI tools and other pure-Dart environments.
///
/// Example:
/// ```dart
/// import 'package:audiflow_podcast/parser.dart';
///
/// final parser = PureRssParser();
/// await for (final entity in parser.parseFromString(xmlContent)) {
///   if (entity is PodcastItem) {
///     print('Episode: ${entity.title}');
///   }
/// }
/// ```
library;

// Error types
export 'src/errors/podcast_exception.dart';
export 'src/errors/podcast_parse_error.dart';

// Entity models
export 'src/models/podcast_chapter.dart';
export 'src/models/podcast_entity.dart';
export 'src/models/podcast_feed.dart';
export 'src/models/podcast_image.dart';
export 'src/models/podcast_item.dart';
export 'src/models/podcast_transcript.dart';

// Core parser (pure Dart)
export 'src/parser/pure_rss_parser.dart';
