/// Business logic and data layer for Audiflow
library;

// Re-export audiflow_podcast for convenience
export 'package:audiflow_podcast/audiflow_podcast.dart'
    show
        PodcastFeed,
        PodcastItem,
        PodcastImage,
        PodcastChapter,
        PodcastTranscript,
        PodcastException,
        CacheOptions;

// Common models
export 'src/common/models/result.dart';
export 'src/common/models/paginated_response.dart';

// Common providers
export 'src/common/providers/database_provider.dart';
export 'src/common/providers/http_client_provider.dart';
export 'src/common/providers/platform_providers.dart';

// Common datasources
export 'src/common/datasources/shared_preferences_datasource.dart';

// Feed feature
export 'src/features/feed/builders/podcast_builder.dart';
export 'src/features/feed/services/feed_parser_service.dart';

// Player feature
export 'src/features/player/models/playback_state.dart';
export 'src/features/player/services/audio_player_service.dart';
