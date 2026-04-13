/// Pure-Dart pattern exports for CLI tools.
///
/// This library exports only pattern-related classes that have no Flutter
/// dependencies, making them safe to use with `dart run`.
library;

// Re-export core types
export 'package:audiflow_core/audiflow_core.dart'
    show EpisodeData, SimpleEpisodeData;

// Pattern models (pure Dart)
export 'src/features/feed/models/grouping_config.dart';
export 'src/features/feed/models/selector_config.dart';
export 'src/features/feed/models/smart_playlist_definition.dart';
export 'src/features/feed/models/smart_playlist_group_def.dart';
export 'src/features/feed/models/smart_playlist_pattern.dart';
export 'src/features/feed/models/smart_playlist_pattern_config.dart';
export 'src/features/feed/models/smart_playlist_sort.dart';
export 'src/features/feed/models/smart_playlist_title_extractor.dart';
export 'src/features/feed/models/numbering_extractor.dart';
export 'src/features/feed/services/smart_playlist_pattern_loader.dart';
