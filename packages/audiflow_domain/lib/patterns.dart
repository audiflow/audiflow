/// Pure-Dart pattern exports for CLI tools.
///
/// This library exports only pattern-related classes that have no Flutter
/// dependencies, making them safe to use with `dart run`.
library;

// Re-export core types
export 'package:audiflow_core/audiflow_core.dart'
    show EpisodeData, SimpleEpisodeData;

// Pattern models (pure Dart)
export 'src/features/feed/models/season_pattern.dart';
export 'src/features/feed/models/season_sort.dart';
export 'src/features/feed/models/season_title_extractor.dart';
export 'src/features/feed/models/episode_number_extractor.dart';
export 'src/features/feed/models/season_episode_extractor.dart';
