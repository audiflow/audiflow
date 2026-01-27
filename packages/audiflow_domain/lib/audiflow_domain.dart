/// Business logic and data layer for Audiflow
library;

// Re-export audiflow_core types
export 'package:audiflow_core/audiflow_core.dart' show SimpleEpisodeData;

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
export 'src/common/providers/logger_provider.dart';
export 'src/common/providers/platform_providers.dart';

// Common datasources
export 'src/common/datasources/shared_preferences_datasource.dart';

// Feed feature
export 'src/features/feed/builders/podcast_builder.dart';
export 'src/features/feed/models/episode_filter.dart';
export 'src/features/feed/models/feed_parse_progress.dart';
export 'src/features/feed/models/podcast_view_mode.dart';
export 'src/features/feed/models/season.dart';
export 'src/features/feed/models/season_pattern.dart';
export 'src/features/feed/models/season_sort.dart';
export 'src/features/feed/models/season_title_extractor.dart';
export 'src/features/feed/models/seasons.dart';
export 'src/features/feed/models/episode_number_extractor.dart';
export 'src/features/feed/models/season_episode_extractor.dart';
export 'src/features/feed/resolvers/rss_metadata_resolver.dart';
export 'src/features/feed/resolvers/season_resolver.dart';
export 'src/features/feed/resolvers/title_appearance_order_resolver.dart';
export 'src/features/feed/resolvers/year_resolver.dart';
export 'src/features/feed/services/feed_parser_service.dart';
export 'src/features/feed/services/season_resolver_service.dart';

// Feed feature - Podcast View Preference
export 'src/features/feed/models/podcast_view_preference.dart';
export 'src/features/feed/providers/podcast_view_preference_providers.dart';
export 'src/features/feed/repositories/podcast_view_preference_repository.dart';

// Feed feature - Season Providers
export 'src/features/feed/providers/season_providers.dart';

// Feed feature - Seasons
export 'src/features/feed/datasources/local/season_local_datasource.dart';

// Feed feature - Episodes
export 'src/features/feed/models/episode.dart';
export 'src/features/feed/datasources/local/episode_local_datasource.dart';
export 'src/features/feed/repositories/episode_repository.dart';
export 'src/features/feed/repositories/episode_repository_impl.dart';

// Player feature
export 'src/features/player/models/now_playing_info.dart';
export 'src/features/player/models/playback_progress.dart';
export 'src/features/player/models/playback_state.dart';
export 'src/features/player/services/audio_player_service.dart';
export 'src/features/player/services/now_playing_controller.dart';

// Player feature - Playback History
export 'src/features/player/models/episode_with_progress.dart';
export 'src/features/player/models/playback_history.dart';
export 'src/features/player/datasources/local/playback_history_local_datasource.dart';
export 'src/features/player/repositories/playback_history_repository.dart';
export 'src/features/player/repositories/playback_history_repository_impl.dart';
export 'src/features/player/services/playback_history_service.dart';

// Voice feature
export 'src/features/voice/models/voice_recognition_state.dart';
export 'src/features/voice/repositories/speech_recognition_repository.dart';
export 'src/features/voice/repositories/speech_recognition_repository_impl.dart';
export 'src/features/voice/services/play_podcast_by_name_service.dart';
export 'src/features/voice/services/voice_command_orchestrator.dart';

// Download feature
export 'src/features/download/models/download_status.dart';
export 'src/features/download/datasources/local/download_local_datasource.dart';
export 'src/features/download/repositories/download_repository.dart';
export 'src/features/download/repositories/download_repository_impl.dart';
export 'src/features/download/services/download_file_service.dart';
export 'src/features/download/services/download_queue_service.dart';
export 'src/features/download/services/download_service.dart';

// Database
export 'src/common/database/app_database.dart'
    show
        AppDatabase,
        DownloadTask,
        DownloadTasksCompanion,
        DownloadTaskStatusX,
        Subscription,
        SubscriptionsCompanion,
        Episode,
        EpisodesCompanion,
        PlaybackHistory,
        PlaybackHistoriesCompanion,
        SeasonEntity,
        SeasonsCompanion;

// Subscription feature
export 'src/features/subscription/extensions/subscription_extensions.dart';
export 'src/features/subscription/providers/subscription_providers.dart';
export 'src/features/subscription/repositories/subscription_repository.dart';
export 'src/features/subscription/repositories/subscription_repository_impl.dart';

// Re-export audiflow_ai types for voice feature
export 'package:audiflow_ai/audiflow_ai.dart'
    show VoiceCommand, VoiceIntent, AudiflowAi, AudiflowAiException;

// Re-export audiflow_search types for subscription extension
export 'package:audiflow_search/audiflow_search.dart' show Podcast;
