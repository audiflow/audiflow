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
export 'src/features/feed/models/pattern_meta.dart';
export 'src/features/feed/models/pattern_summary.dart';
export 'src/features/feed/models/root_meta.dart';
export 'src/features/feed/models/podcast_view_mode.dart';
export 'src/features/feed/models/podcast_sort_order.dart';
export 'src/features/feed/models/smart_playlist.dart';
export 'src/features/feed/models/episode_filter_entry.dart';
export 'src/features/feed/models/episode_filters.dart';
export 'src/features/feed/models/episode_list_config.dart';
export 'src/features/feed/models/episode_sort_rule.dart';
export 'src/features/feed/models/group_display_config.dart';
export 'src/features/feed/models/group_list_config.dart';
export 'src/features/feed/models/smart_playlist_definition.dart';
export 'src/features/feed/models/smart_playlist_group_def.dart';
export 'src/features/feed/models/smart_playlist_pattern.dart';
export 'src/features/feed/models/smart_playlist_pattern_config.dart';
export 'src/features/feed/models/smart_playlist_sort.dart';
export 'src/features/feed/models/smart_playlist_title_extractor.dart';
export 'src/features/feed/models/smart_playlists.dart';
export 'src/features/feed/models/smart_playlist_episode_extractor.dart';
export 'src/features/feed/services/smart_playlist_pattern_loader.dart';
export 'src/features/feed/resolvers/category_resolver.dart';
export 'src/features/feed/resolvers/rss_metadata_resolver.dart';
export 'src/features/feed/resolvers/smart_playlist_resolver.dart';
export 'src/features/feed/resolvers/title_appearance_order_resolver.dart';
export 'src/features/feed/resolvers/year_resolver.dart';
export 'src/features/feed/repositories/smart_playlist_config_repository.dart';
export 'src/features/feed/repositories/smart_playlist_config_repository_impl.dart';
export 'src/features/feed/services/config_assembler.dart';
export 'src/features/feed/services/feed_parser_service.dart';
export 'src/features/feed/services/background_notification_service.dart';
export 'src/features/feed/services/background_refresh_service.dart';
export 'src/features/feed/services/feed_sync_executor.dart';
export 'src/features/feed/services/feed_sync_service.dart';
export 'src/features/feed/models/feed_sync_result.dart';
export 'src/features/feed/models/new_episode_notification.dart';
export 'src/features/feed/services/smart_playlist_resolver_service.dart';

// Feed feature - Podcast View Preference
export 'src/features/feed/models/podcast_view_preference.dart';
export 'src/features/feed/providers/podcast_view_preference_providers.dart';
export 'src/features/feed/repositories/podcast_view_preference_repository.dart';

// Feed feature - Smart Playlist Providers
export 'src/features/feed/providers/smart_playlist_providers.dart';

// Feed feature - Smart Playlists
export 'src/features/feed/datasources/local/smart_playlist_local_datasource.dart';

// Feed feature - Episodes
export 'src/features/feed/models/episode.dart';
export 'src/features/feed/models/episode_ext.dart';
export 'src/features/feed/datasources/local/episode_local_datasource.dart';
export 'src/features/feed/repositories/episode_repository.dart';
export 'src/features/feed/repositories/episode_repository_impl.dart';
export 'src/features/feed/repositories/episode_favorite_repository.dart';
export 'src/features/feed/repositories/episode_favorite_repository_impl.dart';

// Player feature
export 'src/features/player/models/now_playing_info.dart';
export 'src/features/player/models/playback_progress.dart';
export 'src/features/player/models/playback_state.dart';
export 'src/features/player/services/audio_playback_controller.dart';
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
export 'src/features/voice/models/settings_metadata.dart';
export 'src/features/voice/models/voice_recognition_state.dart';
export 'src/features/voice/repositories/speech_recognition_repository.dart';
export 'src/features/voice/repositories/speech_recognition_repository_impl.dart';
export 'src/features/voice/services/play_podcast_by_name_service.dart';
export 'src/features/voice/services/settings_intent_resolver.dart';
export 'src/features/voice/services/settings_metadata_registry.dart';
export 'src/features/voice/services/settings_snapshot_service.dart';
export 'src/features/voice/services/voice_command_executor.dart';
export 'src/features/voice/services/voice_command_orchestrator.dart';
export 'src/features/voice/models/voice_debug_info.dart';
export 'src/features/voice/services/voice_debug_info_notifier.dart';

// Download feature
export 'src/features/download/models/download_status.dart';
export 'src/features/download/datasources/local/download_local_datasource.dart';
export 'src/features/download/providers/download_providers.dart';
export 'src/features/download/repositories/download_repository.dart';
export 'src/features/download/repositories/download_repository_impl.dart';
export 'src/features/download/services/download_file_service.dart';
export 'src/features/download/services/download_queue_service.dart';
export 'src/features/download/services/background_download_service.dart';
export 'src/features/download/services/download_service.dart';

// Isar collection models (schemas for Isar.open)
export 'src/features/download/models/download_task.dart';
export 'src/features/feed/models/smart_playlist_groups.dart';
export 'src/features/queue/models/queue_item.dart';
export 'src/features/subscription/models/subscriptions.dart';
export 'src/features/transcript/models/episode_chapter.dart';
export 'src/features/transcript/models/episode_transcript.dart';
export 'src/features/transcript/models/transcript_segment_table.dart';

// Subscription feature
export 'src/features/subscription/datasources/local/subscription_local_datasource.dart';
export 'src/features/subscription/extensions/subscription_extensions.dart';
export 'src/features/subscription/providers/subscription_providers.dart';
export 'src/features/subscription/repositories/subscription_repository.dart';
export 'src/features/subscription/repositories/subscription_repository_impl.dart';

// Subscription feature - Cache Eviction
export 'src/features/subscription/services/podcast_cache_eviction_service.dart';

// Subscription feature - OPML
export 'src/features/subscription/models/opml_entry.dart';
export 'src/features/subscription/models/opml_import_result.dart';
export 'src/features/subscription/services/opml_import_service.dart';
export 'src/features/subscription/services/opml_parser_service.dart';

// Re-export audiflow_ai types for voice feature
export 'package:audiflow_ai/audiflow_ai.dart'
    show VoiceCommand, VoiceIntent, AudiflowAi, AudiflowAiException;

// Re-export audiflow_search types for subscription extension
export 'package:audiflow_search/audiflow_search.dart' show Podcast;

// Queue feature
export 'src/features/queue/datasources/local/queue_local_datasource.dart';
export 'src/features/queue/models/playback_queue.dart';
export 'src/features/queue/providers/queue_providers.dart';
export 'src/features/queue/repositories/queue_repository.dart';
export 'src/features/queue/repositories/queue_repository_impl.dart';
export 'src/features/queue/services/queue_service.dart';

// Settings feature
export 'src/features/settings/repositories/app_settings_repository.dart';
export 'src/features/settings/repositories/app_settings_repository_impl.dart';
export 'src/features/settings/providers/settings_providers.dart';
export 'src/features/settings/providers/developer_settings_provider.dart';

// Transcript feature
export 'src/features/transcript/datasources/local/chapter_local_datasource.dart';
export 'src/features/transcript/datasources/local/transcript_local_datasource.dart';
export 'src/features/transcript/models/transcript_search_result.dart';
export 'src/features/transcript/providers/transcript_providers.dart';
export 'src/features/transcript/repositories/chapter_repository.dart';
export 'src/features/transcript/repositories/chapter_repository_impl.dart';
export 'src/features/transcript/repositories/transcript_repository.dart';
export 'src/features/transcript/repositories/transcript_repository_impl.dart';
export 'src/features/transcript/services/transcript_service.dart';

// Station feature - models
export 'src/features/station/models/station.dart';
export 'src/features/station/models/station_duration_filter.dart';
export 'src/features/station/models/station_episode.dart';
export 'src/features/station/models/station_episode_sort.dart';
export 'src/features/station/models/station_podcast.dart';
export 'src/features/station/models/station_podcast_sort.dart';

// Station feature - datasources
export 'src/features/station/datasources/local/station_local_datasource.dart';
export 'src/features/station/datasources/local/station_episode_local_datasource.dart';
export 'src/features/station/datasources/local/station_podcast_local_datasource.dart';

// Station feature - repositories
export 'src/features/station/repositories/station_repository.dart';
export 'src/features/station/repositories/station_repository_impl.dart';
export 'src/features/station/repositories/station_podcast_repository.dart';
export 'src/features/station/repositories/station_podcast_repository_impl.dart';
export 'src/features/station/repositories/station_episode_repository.dart';
export 'src/features/station/repositories/station_episode_repository_impl.dart';

// Station feature - services
export 'src/features/station/services/station_reconciler.dart';
export 'src/features/station/services/station_reconciler_service.dart';

// Share feature
export 'src/features/share/models/deep_link_target.dart';
export 'src/features/share/services/share_link_builder.dart';
export 'src/features/share/services/deep_link_resolver.dart';
export 'src/features/share/providers/share_providers.dart';
