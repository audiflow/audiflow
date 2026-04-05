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
  String get feedSyncNotifyNewEpisodesTitle => 'New episode notifications';

  @override
  String get feedSyncNotifyNewEpisodesSubtitle =>
      'Show a notification when new episodes are found during background refresh';

  @override
  String get feedSyncInterval15min => 'Every 15 minutes';

  @override
  String get feedSyncInterval3hours => 'Every 3 hours';

  @override
  String get feedSyncInterval6hours => 'Every 6 hours';

  @override
  String get feedSyncInterval12hours => 'Every 12 hours';

  @override
  String get notificationPermissionRequiredTitle => 'Permission required';

  @override
  String get notificationPermissionRequiredMessage =>
      'Notification permission was denied. Please enable it in system settings.';

  @override
  String get notificationPermissionOpenSettings => 'Open Settings';

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
  String get librarySortByLatestEpisode => 'Latest episode';

  @override
  String get librarySortBySubscribedAt => 'Subscription date';

  @override
  String get librarySortByAlphabetical => 'Alphabetical';

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
  String get searchErrorBanner => 'Search failed. Showing previous results.';

  @override
  String get searchRefreshingLabel => 'Loading new results';

  @override
  String get searchRegionLabel => 'Search Region';

  @override
  String searchRegionCurrent(String country) {
    return 'Searching in $country';
  }

  @override
  String get searchRegionPickerTitle => 'Select Region';

  @override
  String get searchRegionPickerSubtitle =>
      'iTunes store to search for podcasts';

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
  String playerRewindLabel(int seconds) {
    return 'Rewind $seconds seconds';
  }

  @override
  String playerForwardLabel(int seconds) {
    return 'Forward $seconds seconds';
  }

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
  String get episodeMoreActions => 'More actions';

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

  @override
  String get podcastAutoDownloadTitle => 'Auto-download new episodes';

  @override
  String get podcastAutoDownloadSubtitle =>
      'Download new episodes automatically during background refresh';

  @override
  String get stationSectionTitle => 'Stations';

  @override
  String get stationNew => 'New Station';

  @override
  String get stationName => 'Station Name';

  @override
  String get stationNameHint => 'e.g., News, Tech, Comedy';

  @override
  String get stationPodcasts => 'Podcasts';

  @override
  String get stationFilters => 'Filters';

  @override
  String get stationPlaybackOrder => 'Playback Order';

  @override
  String get stationNewest => 'Newest First';

  @override
  String get stationOldest => 'Oldest First';

  @override
  String get stationFilterAll => 'All Episodes';

  @override
  String get stationFilterUnplayed => 'Unplayed';

  @override
  String get stationFilterInProgress => 'In Progress';

  @override
  String get stationFilterDownloaded => 'Downloaded Only';

  @override
  String get stationFilterFavorited => 'Favorites Only';

  @override
  String get stationFilterDuration => 'Duration';

  @override
  String stationFilterShorterThan(int minutes) {
    return 'Shorter than $minutes min';
  }

  @override
  String stationFilterLongerThan(int minutes) {
    return 'Longer than $minutes min';
  }

  @override
  String stationFilterPublishedWithin(int days) {
    return 'Published within $days days';
  }

  @override
  String stationLimitReached(int max) {
    return 'Station limit reached ($max)';
  }

  @override
  String get stationDeleteConfirm => 'Delete this station?';

  @override
  String stationEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
      zero: 'No episodes',
    );
    return '$_temp0';
  }

  @override
  String stationPodcastCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podcasts',
      one: '1 podcast',
    );
    return '$_temp0';
  }

  @override
  String get stationEmpty => 'You\'re all caught up!';

  @override
  String get stationPlayAll => 'Play All';

  @override
  String get stationNoStationsYet => 'No stations yet. Tap + to create one.';

  @override
  String get stationNoSubscriptionsYet => 'No subscriptions yet.';

  @override
  String get stationEmptySubtitle =>
      'New episodes will appear here automatically.';

  @override
  String get stationEditTitle => 'Edit Station';

  @override
  String get stationSave => 'Save';

  @override
  String get stationDelete => 'Delete Station';

  @override
  String get stationDeleteTitle => 'Delete Station';

  @override
  String get stationDeleteBody =>
      'Are you sure you want to delete this station? This cannot be undone.';

  @override
  String get stationFilterHideCompletedLabel => 'Hide completed episodes';

  @override
  String get stationFilterDownloadedLabel => 'Downloaded only';

  @override
  String get stationFilterFavoritedLabel => 'Favorited only';

  @override
  String get stationDurationFilter => 'Duration Filter';

  @override
  String get stationShorterThan => 'Shorter than';

  @override
  String get stationLongerThan => 'Longer than';

  @override
  String get stationPublishedWithin => 'Published Within';

  @override
  String get stationNoLimit => 'No limit';

  @override
  String stationLastDays(int days) {
    return 'Last $days days';
  }

  @override
  String get stationEpisodeOrder => 'Episode Order';

  @override
  String get stationNewestFirst => 'Newest first';

  @override
  String get stationOldestFirst => 'Oldest first';

  @override
  String get stationEditTooltip => 'Edit station';

  @override
  String get stationNotFoundTitle => 'Station Not Found';

  @override
  String get stationNotFoundMessage => 'Station data not available';

  @override
  String get stationNameRequired => 'Station name is required';

  @override
  String get stationPodcastRequired => 'Select at least one podcast';

  @override
  String get commonGoBack => 'Go Back';

  @override
  String get deepLinkPodcastNotFound => 'Podcast not found';

  @override
  String get deepLinkEpisodeNotFound => 'Episode not found';

  @override
  String get deepLinkNetworkError => 'Could not load, check your connection';

  @override
  String get deepLinkLoading => 'Opening link...';

  @override
  String get sharePodcast => 'Share podcast';

  @override
  String get voiceCommandButton => 'Voice command';

  @override
  String get voiceListening => 'Listening...';

  @override
  String get voiceProcessing => 'Processing...';

  @override
  String voiceExecuting(String intent) {
    return 'Executing: $intent';
  }

  @override
  String voiceCouldNotUnderstand(String transcription) {
    return 'Could not understand: \"$transcription\"';
  }

  @override
  String get voiceSettingsWhichSetting => 'Which setting do you mean?';

  @override
  String get voiceSettingsChanged => 'Setting changed';

  @override
  String get undo => 'Undo';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get voiceTapMicToRetry => 'Tap mic to try again';

  @override
  String get navSearch => 'Search';

  @override
  String get navLibrary => 'Library';

  @override
  String get navQueue => 'Queue';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsVoiceTitle => 'Voice';

  @override
  String get settingsVoiceSubtitle => 'Voice commands and recognition';

  @override
  String get voiceExperimentalLabel => 'Experimental';

  @override
  String get voiceExperimentalDescription =>
      'Voice commands are an experimental feature and may not work reliably on most devices. Accuracy and availability will improve as on-device AI capabilities evolve.';

  @override
  String get voiceEnabledTitle => 'Voice Commands';

  @override
  String get voiceEnabledSubtitle => 'Enable voice control for the app';

  @override
  String get voiceAvailableCommands => 'Available Commands';

  @override
  String get voiceCommandPlay => 'Play / Resume playback';

  @override
  String get voiceCommandPause => 'Pause playback';

  @override
  String get voiceCommandStop => 'Stop playback';

  @override
  String get voiceCommandSkipForward => 'Skip forward';

  @override
  String get voiceCommandSkipBackward => 'Skip backward';

  @override
  String get voiceCommandSearch => 'Search for podcasts';

  @override
  String get voiceCommandGoToLibrary => 'Go to Library';

  @override
  String get voiceCommandGoToQueue => 'Go to Queue';

  @override
  String get voiceCommandOpenSettings => 'Open Settings';

  @override
  String get voiceCommandChangeSettings => 'Change a setting';

  @override
  String get voiceIntentPlay => 'Play';

  @override
  String get voiceIntentPause => 'Pause';

  @override
  String get voiceIntentStop => 'Stop';

  @override
  String get voiceIntentSkipForward => 'Skip forward';

  @override
  String get voiceIntentSkipBackward => 'Skip backward';

  @override
  String get voiceIntentSeek => 'Seek';

  @override
  String get voiceIntentSearch => 'Search';

  @override
  String get voiceIntentGoToLibrary => 'Library';

  @override
  String get voiceIntentGoToQueue => 'Queue';

  @override
  String get voiceIntentOpenSettings => 'Settings';

  @override
  String get voiceIntentAddToQueue => 'Add to queue';

  @override
  String get voiceIntentRemoveFromQueue => 'Remove from queue';

  @override
  String get voiceIntentClearQueue => 'Clear queue';

  @override
  String get voiceIntentChangeSettings => 'Change setting';

  @override
  String get voiceIntentUnknown => 'Unknown';

  @override
  String get playNext => 'Play next';

  @override
  String get downloadEpisode => 'Download episode';

  @override
  String get goToEpisode => 'Go to episode';

  @override
  String get removeDownload => 'Remove download';

  @override
  String get statsTitle => 'Title';

  @override
  String get statsPodcast => 'Podcast';

  @override
  String get statsDuration => 'Duration';

  @override
  String get statsPublished => 'Published';

  @override
  String get statsTimesCompleted => 'Times completed';

  @override
  String get statsTimesStarted => 'Times started';

  @override
  String get statsTotalListened => 'Total listened';

  @override
  String get statsRealtime => 'Realtime';

  @override
  String get statsFirstPlayed => 'First played';

  @override
  String get statsLastPlayed => 'Last played';

  @override
  String get statsNever => 'Never';

  @override
  String get statsSection => 'Statistics';
}
