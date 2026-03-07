// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsAppearanceSubtitle => 'Theme, language, text size';

  @override
  String get settingsPlaybackTitle => 'Playback';

  @override
  String get settingsPlaybackSubtitle => 'Speed, skipping, auto-complete';

  @override
  String get settingsDownloadsTitle => 'Downloads';

  @override
  String get settingsDownloadsSubtitle => 'WiFi, auto-delete, concurrency';

  @override
  String get settingsFeedSyncTitle => 'Feed Sync';

  @override
  String get settingsFeedSyncSubtitle => 'Refresh interval, background sync';

  @override
  String get settingsStorageTitle => 'Storage & Data';

  @override
  String get settingsStorageSubtitle => 'Cache, OPML, data management';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutSubtitle => 'Version, licenses, support';

  @override
  String get appearanceThemeMode => 'Theme Mode';

  @override
  String get appearanceThemeLight => 'Light';

  @override
  String get appearanceThemeDark => 'Dark';

  @override
  String get appearanceThemeSystem => 'System';

  @override
  String get appearanceLanguage => 'Language';

  @override
  String get appearanceLanguageEnglish => 'English';

  @override
  String get appearanceLanguageJapanese => 'Japanese';

  @override
  String get appearanceTextSize => 'Text Size';

  @override
  String get appearanceTextSmall => 'Small';

  @override
  String get appearanceTextMedium => 'Medium';

  @override
  String get appearanceTextLarge => 'Large';

  @override
  String get appearancePreviewText => 'Preview text at current size';

  @override
  String get playbackDefaultSpeed => 'Default Playback Speed';

  @override
  String get playbackSkipForward => 'Skip Forward (seconds)';

  @override
  String get playbackSkipBackward => 'Skip Backward (seconds)';

  @override
  String get playbackAutoCompleteThreshold => 'Auto-Complete Threshold';

  @override
  String get playbackContinuousTitle => 'Continuous Playback';

  @override
  String get playbackContinuousSubtitle =>
      'Auto-play the next episode in the queue';

  @override
  String get playbackAutoPlayOrderTitle => 'Auto-Play Order';

  @override
  String get playbackAutoPlayOrderSubtitle =>
      'Episode order when auto-queuing from a podcast list';

  @override
  String get playbackAutoPlayOrderOldestFirst => 'Oldest First';

  @override
  String get playbackAutoPlayOrderAsDisplayed => 'As Displayed';

  @override
  String get downloadsWifiOnlyTitle => 'WiFi-Only Downloads';

  @override
  String get downloadsWifiOnlySubtitle => 'Only download episodes over WiFi';

  @override
  String get downloadsAutoDeleteTitle => 'Auto-Delete After Played';

  @override
  String get downloadsAutoDeleteSubtitle =>
      'Remove downloaded episodes after playback';

  @override
  String get downloadsMaxConcurrent => 'Max Concurrent Downloads';

  @override
  String get feedSyncAutoSyncTitle => 'Auto-Sync';

  @override
  String get feedSyncAutoSyncSubtitle => 'Automatically refresh podcast feeds';

  @override
  String get feedSyncInterval => 'Sync Interval';

  @override
  String get feedSyncInterval30min => '30 min';

  @override
  String get feedSyncInterval1hour => '1 hour';

  @override
  String get feedSyncInterval2hours => '2 hours';

  @override
  String get feedSyncInterval4hours => '4 hours';

  @override
  String get feedSyncWifiOnlyTitle => 'WiFi-Only Sync';

  @override
  String get feedSyncWifiOnlySubtitle => 'Only sync feeds over WiFi';

  @override
  String get storageImageCache => 'Image Cache';

  @override
  String get storageImageCacheSubtitle =>
      'Clear temporary files and cached images';

  @override
  String get storageClearCache => 'Clear Cache';

  @override
  String get storageClearCacheTitle => 'Clear Cache?';

  @override
  String get storageClearCacheContent =>
      'This will delete all temporary files and cached images. They will be re-downloaded as needed.';

  @override
  String get storageCacheCleared => 'Cache cleared';

  @override
  String get storageSearchHistory => 'Search History';

  @override
  String get storageSearchHistorySubtitle => 'Clear search suggestions';

  @override
  String get storageClearSearchHistoryTitle => 'Clear Search History?';

  @override
  String get storageClearSearchHistoryContent =>
      'This will remove all saved search suggestions.';

  @override
  String get storageSearchHistoryCleared => 'Search history cleared';

  @override
  String get storageExportTitle => 'Export Subscriptions';

  @override
  String get storageExportSubtitle => 'Save subscriptions as OPML file';

  @override
  String get storageExport => 'Export';

  @override
  String get storageExportEmpty => 'No subscriptions to export';

  @override
  String get storageExportSuccess => 'Subscriptions exported';

  @override
  String storageExportError(String message) {
    return 'Export failed: $message';
  }

  @override
  String get storageImportTitle => 'Import Subscriptions';

  @override
  String get storageImportSubtitle => 'Import from OPML file';

  @override
  String get storageImport => 'Import';

  @override
  String get storageDangerZone => 'Danger Zone';

  @override
  String get storageResetTitle => 'Reset All Data';

  @override
  String get storageResetSubtitle =>
      'Delete all data and reset app to initial state';

  @override
  String get storageResetDialogTitle => 'Reset All Data?';

  @override
  String get storageResetDialogContent =>
      'This will permanently delete all your data including subscriptions, downloads, playback history, and settings.';

  @override
  String get storageResetTypeConfirm => 'Type RESET to confirm:';

  @override
  String get storageResetButton => 'Reset';

  @override
  String get storageResetComplete => 'Data reset complete';

  @override
  String storageResetFailed(String error) {
    return 'Reset failed: $error';
  }

  @override
  String get storageImportComplete => 'Import Complete';

  @override
  String storageImportedCount(int count) {
    return 'Imported $count podcasts';
  }

  @override
  String storageAlreadySubscribedCount(int count) {
    return '$count already subscribed';
  }

  @override
  String storageFailedCount(int count) {
    return '$count failed';
  }

  @override
  String get aboutTagline => 'Your podcast companion';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Open Source Licenses';

  @override
  String get aboutSendFeedback => 'Send Feedback';

  @override
  String get aboutRateApp => 'Rate the App';

  @override
  String get libraryTitle => 'Library';

  @override
  String librarySyncResult(int successCount, int errorCount) {
    return 'Synced $successCount feeds, $errorCount failed';
  }

  @override
  String librarySyncSuccess(int count) {
    return 'Synced $count feeds';
  }

  @override
  String get libraryYourPodcasts => 'Your Podcasts';

  @override
  String get libraryEmpty => 'No subscriptions yet';

  @override
  String get libraryEmptySubtitle =>
      'Search for podcasts and subscribe to see them here';

  @override
  String get libraryLoadError => 'Failed to load subscriptions';

  @override
  String get searchTitle => 'Search Podcasts';

  @override
  String get searchHint => 'Search podcasts...';

  @override
  String get searchInitialTitle => 'Search for podcasts';

  @override
  String get searchInitialSubtitle => 'Enter a keyword to discover podcasts';

  @override
  String get searchEmpty => 'No podcasts found';

  @override
  String get searchEmptySubtitle => 'Try a different search term';

  @override
  String get searchErrorUnavailable =>
      'Unable to connect. Check your internet connection.';

  @override
  String get searchErrorTimeout => 'Search timed out. Please try again.';

  @override
  String get searchErrorRateLimit => 'Too many requests. Please wait a moment.';

  @override
  String get searchErrorInvalid => 'Please enter a valid search term.';

  @override
  String get searchErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get queueTitle => 'Queue';

  @override
  String get queueUpNext => 'UP NEXT';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String get queueEmptySubtitle =>
      'Add episodes to your queue from the library or podcast pages';

  @override
  String get queueLoadError => 'Failed to load queue';

  @override
  String get queueClearTooltip => 'Clear queue';

  @override
  String get queueClearConfirm => 'Confirm?';

  @override
  String get queueAddedToQueue => 'Added to queue';

  @override
  String get queuePlayingNext => 'Playing next';

  @override
  String get queueAddToQueueTooltip =>
      'Add to queue (long press for Play Next)';

  @override
  String get playerCloseLabel => 'Close player';

  @override
  String get playerNowPlaying => 'Now Playing';

  @override
  String get playerNoAudio => 'No audio playing';

  @override
  String get playerArtworkLabel => 'Episode artwork';

  @override
  String get playerRewindLabel => 'Rewind 30 seconds';

  @override
  String get playerForwardLabel => 'Forward 30 seconds';

  @override
  String get playerLoadingLabel => 'Loading';

  @override
  String get playerPauseLabel => 'Pause';

  @override
  String get playerPlayLabel => 'Play';

  @override
  String playerSpeedLabel(String speed) {
    return 'Playback speed ${speed}x';
  }

  @override
  String playerNowPlayingLabel(String title, String podcast) {
    return 'Now playing: $title by $podcast';
  }

  @override
  String get podcastDetailFeedUrlMissing => 'Feed URL not available';

  @override
  String get podcastDetailFeedUrlMissingSubtitle =>
      'This podcast does not have a feed URL';

  @override
  String get podcastDetailLoadError => 'Failed to load episodes';

  @override
  String get podcastDetailUngrouped => 'Ungrouped';

  @override
  String get podcastDetailSubscribed => 'Subscribed';

  @override
  String get podcastDetailSubscribe => 'Subscribe';

  @override
  String get podcastDetailNoResults => 'No results found';

  @override
  String get podcastDetailNoMatchingEpisodes => 'No matching episodes';

  @override
  String get podcastDetailTryDifferentFilter => 'Try a different filter';

  @override
  String get podcastDetailNoEpisodes => 'No episodes found';

  @override
  String get podcastDetailPlaylistEmpty => 'This playlist has no episodes';

  @override
  String podcastDetailEpisodeLoadError(String error) {
    return 'Error loading episodes: $error';
  }

  @override
  String podcastDetailEpisodeCount(int count) {
    return '$count episodes';
  }

  @override
  String podcastDetailGroupCount(int count) {
    return '$count groups';
  }

  @override
  String get podcastDetailOldestFirst => 'Oldest first';

  @override
  String get podcastDetailNewestFirst => 'Newest first';

  @override
  String podcastDetailFailedToLoad(String error) {
    return 'Failed to load: $error';
  }

  @override
  String get episodeReplaceQueueTitle => 'Replace queue?';

  @override
  String get episodeReplaceQueueContent =>
      'Starting playback will replace your current queue with episodes from this list.';

  @override
  String get episodeReplace => 'Replace';

  @override
  String get downloadCancelled => 'Download cancelled';

  @override
  String get downloadRetrying => 'Retrying download';

  @override
  String get downloadStarted => 'Download started';

  @override
  String get downloadDeleteTitle => 'Delete download?';

  @override
  String get downloadDeleteContent => 'The downloaded file will be removed.';

  @override
  String get downloadDeleted => 'Download deleted';

  @override
  String get opmlImportTitle => 'Import Podcasts';

  @override
  String get opmlAlreadySubscribed => 'Already subscribed';

  @override
  String opmlImportSelected(int count) {
    return 'Import Selected ($count)';
  }

  @override
  String get smartPlaylistDailyNews => 'Daily News';

  @override
  String get smartPlaylistPrograms => 'Programs';

  @override
  String get smartPlaylistExtras => 'Extras';

  @override
  String get smartPlaylistOthers => 'Others';

  @override
  String get smartPlaylistSectionTitle => 'Smart Playlists';

  @override
  String get episodesLabel => 'Episodes';

  @override
  String get smartPlaylistsLabel => 'Smart Playlists';

  @override
  String get episodeDetails => 'Episode details';

  @override
  String get shareEpisode => 'Share episode';

  @override
  String get markAsPlayed => 'Mark as played';

  @override
  String get markAsUnplayed => 'Mark as unplayed';

  @override
  String get addToQueue => 'Add to queue';

  @override
  String get dateToday => 'Today';

  @override
  String get dateYesterday => 'Yesterday';

  @override
  String groupEpisodeCount(int count) {
    return '$count episodes';
  }

  @override
  String groupDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h${minutes}m';
  }

  @override
  String groupDurationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get playerTabNowPlaying => 'Now Playing';

  @override
  String get playerTabTranscript => 'Transcript';

  @override
  String get playerTranscriptLoading => 'Loading transcript...';

  @override
  String get playerTranscriptEmpty => 'No transcript available';

  @override
  String get playerTranscriptJumpToCurrent => 'Jump to current';

  @override
  String get episodeTranscriptAvailable => 'Transcript available';
}
