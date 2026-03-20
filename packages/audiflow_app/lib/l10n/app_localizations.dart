import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// Common cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Common retry action
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Common clear action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// Common OK action
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Common delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Common loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Feature not yet available
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance category title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// Appearance category subtitle
  ///
  /// In en, this message translates to:
  /// **'Theme, language, text size'**
  String get settingsAppearanceSubtitle;

  /// Playback category title
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get settingsPlaybackTitle;

  /// Playback category subtitle
  ///
  /// In en, this message translates to:
  /// **'Speed, skipping, auto-complete'**
  String get settingsPlaybackSubtitle;

  /// Downloads category title
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get settingsDownloadsTitle;

  /// Downloads category subtitle
  ///
  /// In en, this message translates to:
  /// **'WiFi, auto-delete, concurrency'**
  String get settingsDownloadsSubtitle;

  /// Feed sync category title
  ///
  /// In en, this message translates to:
  /// **'Feed Sync'**
  String get settingsFeedSyncTitle;

  /// Feed sync category subtitle
  ///
  /// In en, this message translates to:
  /// **'Refresh interval, background sync'**
  String get settingsFeedSyncSubtitle;

  /// Storage category title
  ///
  /// In en, this message translates to:
  /// **'Storage & Data'**
  String get settingsStorageTitle;

  /// Storage category subtitle
  ///
  /// In en, this message translates to:
  /// **'Cache, OPML, data management'**
  String get settingsStorageSubtitle;

  /// About category title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// About category subtitle
  ///
  /// In en, this message translates to:
  /// **'Version, licenses, support'**
  String get settingsAboutSubtitle;

  /// Theme mode section label
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get appearanceThemeMode;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceThemeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceThemeSystem;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appearanceLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get appearanceLanguageEnglish;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get appearanceLanguageJapanese;

  /// Text size section label
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get appearanceTextSize;

  /// Small text size option
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get appearanceTextSmall;

  /// Medium text size option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get appearanceTextMedium;

  /// Large text size option
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get appearanceTextLarge;

  /// Text size preview label
  ///
  /// In en, this message translates to:
  /// **'Preview text at current size'**
  String get appearancePreviewText;

  /// Playback speed setting label
  ///
  /// In en, this message translates to:
  /// **'Default Playback Speed'**
  String get playbackDefaultSpeed;

  /// Skip forward setting label
  ///
  /// In en, this message translates to:
  /// **'Skip Forward (seconds)'**
  String get playbackSkipForward;

  /// Skip backward setting label
  ///
  /// In en, this message translates to:
  /// **'Skip Backward (seconds)'**
  String get playbackSkipBackward;

  /// Auto-complete threshold label
  ///
  /// In en, this message translates to:
  /// **'Auto-Complete Threshold'**
  String get playbackAutoCompleteThreshold;

  /// Continuous playback setting title
  ///
  /// In en, this message translates to:
  /// **'Continuous Playback'**
  String get playbackContinuousTitle;

  /// Continuous playback setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Auto-play the next episode in the queue'**
  String get playbackContinuousSubtitle;

  /// Auto-play order setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-Play Order'**
  String get playbackAutoPlayOrderTitle;

  /// Auto-play order setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Episode order when auto-queuing from a podcast list'**
  String get playbackAutoPlayOrderSubtitle;

  /// Auto-play order: chronological
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get playbackAutoPlayOrderOldestFirst;

  /// Auto-play order: screen order
  ///
  /// In en, this message translates to:
  /// **'As Displayed'**
  String get playbackAutoPlayOrderAsDisplayed;

  /// WiFi-only downloads setting title
  ///
  /// In en, this message translates to:
  /// **'WiFi-Only Downloads'**
  String get downloadsWifiOnlyTitle;

  /// WiFi-only downloads subtitle
  ///
  /// In en, this message translates to:
  /// **'Only download episodes over WiFi'**
  String get downloadsWifiOnlySubtitle;

  /// Auto-delete setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-Delete After Played'**
  String get downloadsAutoDeleteTitle;

  /// Auto-delete subtitle
  ///
  /// In en, this message translates to:
  /// **'Remove downloaded episodes after playback'**
  String get downloadsAutoDeleteSubtitle;

  /// Max concurrent downloads label
  ///
  /// In en, this message translates to:
  /// **'Max Concurrent Downloads'**
  String get downloadsMaxConcurrent;

  /// Auto-sync setting title
  ///
  /// In en, this message translates to:
  /// **'Auto-Sync'**
  String get feedSyncAutoSyncTitle;

  /// Auto-sync subtitle
  ///
  /// In en, this message translates to:
  /// **'Automatically refresh podcast feeds'**
  String get feedSyncAutoSyncSubtitle;

  /// Sync interval setting label
  ///
  /// In en, this message translates to:
  /// **'Sync Interval'**
  String get feedSyncInterval;

  /// 30 minute sync interval
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get feedSyncInterval30min;

  /// 1 hour sync interval
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get feedSyncInterval1hour;

  /// 2 hours sync interval
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get feedSyncInterval2hours;

  /// 4 hours sync interval
  ///
  /// In en, this message translates to:
  /// **'4 hours'**
  String get feedSyncInterval4hours;

  /// WiFi-only sync setting title
  ///
  /// In en, this message translates to:
  /// **'WiFi-Only Sync'**
  String get feedSyncWifiOnlyTitle;

  /// WiFi-only sync subtitle
  ///
  /// In en, this message translates to:
  /// **'Only sync feeds over WiFi'**
  String get feedSyncWifiOnlySubtitle;

  /// Notify new episodes setting title
  ///
  /// In en, this message translates to:
  /// **'New episode notifications'**
  String get feedSyncNotifyNewEpisodesTitle;

  /// Notify new episodes setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Show a notification when new episodes are found during background refresh'**
  String get feedSyncNotifyNewEpisodesSubtitle;

  /// 15 minute sync interval
  ///
  /// In en, this message translates to:
  /// **'Every 15 minutes'**
  String get feedSyncInterval15min;

  /// 3 hours sync interval
  ///
  /// In en, this message translates to:
  /// **'Every 3 hours'**
  String get feedSyncInterval3hours;

  /// 6 hours sync interval
  ///
  /// In en, this message translates to:
  /// **'Every 6 hours'**
  String get feedSyncInterval6hours;

  /// 12 hours sync interval
  ///
  /// In en, this message translates to:
  /// **'Every 12 hours'**
  String get feedSyncInterval12hours;

  /// Title for notification permission dialog
  ///
  /// In en, this message translates to:
  /// **'Permission required'**
  String get notificationPermissionRequiredTitle;

  /// Body for notification permission dialog
  ///
  /// In en, this message translates to:
  /// **'Notification permission was denied. Please enable it in system settings.'**
  String get notificationPermissionRequiredMessage;

  /// Button to open system settings for permissions
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get notificationPermissionOpenSettings;

  /// Image cache setting title
  ///
  /// In en, this message translates to:
  /// **'Image Cache'**
  String get storageImageCache;

  /// Image cache subtitle
  ///
  /// In en, this message translates to:
  /// **'Clear temporary files and cached images'**
  String get storageImageCacheSubtitle;

  /// Clear cache button label
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get storageClearCache;

  /// Clear cache dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Cache?'**
  String get storageClearCacheTitle;

  /// Clear cache dialog content
  ///
  /// In en, this message translates to:
  /// **'This will delete all temporary files and cached images. They will be re-downloaded as needed.'**
  String get storageClearCacheContent;

  /// Cache cleared snackbar
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get storageCacheCleared;

  /// Search history setting title
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get storageSearchHistory;

  /// Search history subtitle
  ///
  /// In en, this message translates to:
  /// **'Clear search suggestions'**
  String get storageSearchHistorySubtitle;

  /// Clear search history dialog title
  ///
  /// In en, this message translates to:
  /// **'Clear Search History?'**
  String get storageClearSearchHistoryTitle;

  /// Clear search history dialog content
  ///
  /// In en, this message translates to:
  /// **'This will remove all saved search suggestions.'**
  String get storageClearSearchHistoryContent;

  /// Search history cleared snackbar
  ///
  /// In en, this message translates to:
  /// **'Search history cleared'**
  String get storageSearchHistoryCleared;

  /// Export subscriptions setting title
  ///
  /// In en, this message translates to:
  /// **'Export Subscriptions'**
  String get storageExportTitle;

  /// Export subscriptions subtitle
  ///
  /// In en, this message translates to:
  /// **'Save subscriptions as OPML file'**
  String get storageExportSubtitle;

  /// Export button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get storageExport;

  /// Empty export snackbar
  ///
  /// In en, this message translates to:
  /// **'No subscriptions to export'**
  String get storageExportEmpty;

  /// Export success snackbar
  ///
  /// In en, this message translates to:
  /// **'Subscriptions exported'**
  String get storageExportSuccess;

  /// Export error snackbar
  ///
  /// In en, this message translates to:
  /// **'Export failed: {message}'**
  String storageExportError(String message);

  /// Import subscriptions setting title
  ///
  /// In en, this message translates to:
  /// **'Import Subscriptions'**
  String get storageImportTitle;

  /// Import subscriptions subtitle
  ///
  /// In en, this message translates to:
  /// **'Import from OPML file'**
  String get storageImportSubtitle;

  /// Import button label
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get storageImport;

  /// Danger zone section title
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get storageDangerZone;

  /// Reset data setting title
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get storageResetTitle;

  /// Reset data subtitle
  ///
  /// In en, this message translates to:
  /// **'Delete all data and reset app to initial state'**
  String get storageResetSubtitle;

  /// Reset dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset All Data?'**
  String get storageResetDialogTitle;

  /// Reset dialog content
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your data including subscriptions, downloads, playback history, and settings.'**
  String get storageResetDialogContent;

  /// Reset confirmation prompt
  ///
  /// In en, this message translates to:
  /// **'Type RESET to confirm:'**
  String get storageResetTypeConfirm;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get storageResetButton;

  /// Reset complete snackbar
  ///
  /// In en, this message translates to:
  /// **'Data reset complete'**
  String get storageResetComplete;

  /// Reset failed snackbar
  ///
  /// In en, this message translates to:
  /// **'Reset failed: {error}'**
  String storageResetFailed(String error);

  /// Import complete dialog title
  ///
  /// In en, this message translates to:
  /// **'Import Complete'**
  String get storageImportComplete;

  /// Import success count
  ///
  /// In en, this message translates to:
  /// **'Imported {count} podcasts'**
  String storageImportedCount(int count);

  /// Already subscribed count
  ///
  /// In en, this message translates to:
  /// **'{count} already subscribed'**
  String storageAlreadySubscribedCount(int count);

  /// Import failure count
  ///
  /// In en, this message translates to:
  /// **'{count} failed'**
  String storageFailedCount(int count);

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Your podcast companion'**
  String get aboutTagline;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// Licenses label
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get aboutLicenses;

  /// Send feedback label
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get aboutSendFeedback;

  /// Rate app label
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get aboutRateApp;

  /// Library screen title
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Sync result with errors
  ///
  /// In en, this message translates to:
  /// **'Synced {successCount} feeds, {errorCount} failed'**
  String librarySyncResult(int successCount, int errorCount);

  /// Sync success message
  ///
  /// In en, this message translates to:
  /// **'Synced {count} feeds'**
  String librarySyncSuccess(int count);

  /// Your podcasts section header
  ///
  /// In en, this message translates to:
  /// **'Your Podcasts'**
  String get libraryYourPodcasts;

  /// Empty library title
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get libraryEmpty;

  /// Empty library subtitle
  ///
  /// In en, this message translates to:
  /// **'Search for podcasts and subscribe to see them here'**
  String get libraryEmptySubtitle;

  /// Library load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscriptions'**
  String get libraryLoadError;

  /// Search screen title
  ///
  /// In en, this message translates to:
  /// **'Search Podcasts'**
  String get searchTitle;

  /// Search input hint
  ///
  /// In en, this message translates to:
  /// **'Search podcasts...'**
  String get searchHint;

  /// Search initial state title
  ///
  /// In en, this message translates to:
  /// **'Search for podcasts'**
  String get searchInitialTitle;

  /// Search initial state subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter a keyword to discover podcasts'**
  String get searchInitialSubtitle;

  /// Search empty state title
  ///
  /// In en, this message translates to:
  /// **'No podcasts found'**
  String get searchEmpty;

  /// Search empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get searchEmptySubtitle;

  /// Network unavailable error
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Check your internet connection.'**
  String get searchErrorUnavailable;

  /// Search timeout error
  ///
  /// In en, this message translates to:
  /// **'Search timed out. Please try again.'**
  String get searchErrorTimeout;

  /// Rate limit error
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment.'**
  String get searchErrorRateLimit;

  /// Invalid search term error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid search term.'**
  String get searchErrorInvalid;

  /// Generic search error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get searchErrorGeneric;

  /// Queue screen title
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueTitle;

  /// Up next section header
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get queueUpNext;

  /// Empty queue title
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// Empty queue subtitle
  ///
  /// In en, this message translates to:
  /// **'Add episodes to your queue from the library or podcast pages'**
  String get queueEmptySubtitle;

  /// Queue load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load queue'**
  String get queueLoadError;

  /// Clear queue tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get queueClearTooltip;

  /// Clear queue confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm?'**
  String get queueClearConfirm;

  /// Added to queue snackbar
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get queueAddedToQueue;

  /// Playing next snackbar
  ///
  /// In en, this message translates to:
  /// **'Playing next'**
  String get queuePlayingNext;

  /// Add to queue button tooltip
  ///
  /// In en, this message translates to:
  /// **'Add to queue (long press for Play Next)'**
  String get queueAddToQueueTooltip;

  /// Close player accessibility label
  ///
  /// In en, this message translates to:
  /// **'Close player'**
  String get playerCloseLabel;

  /// Now playing title
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get playerNowPlaying;

  /// No audio playing message
  ///
  /// In en, this message translates to:
  /// **'No audio playing'**
  String get playerNoAudio;

  /// Episode artwork accessibility label
  ///
  /// In en, this message translates to:
  /// **'Episode artwork'**
  String get playerArtworkLabel;

  /// Rewind accessibility label
  ///
  /// In en, this message translates to:
  /// **'Rewind 30 seconds'**
  String get playerRewindLabel;

  /// Forward accessibility label
  ///
  /// In en, this message translates to:
  /// **'Forward 30 seconds'**
  String get playerForwardLabel;

  /// Loading accessibility label
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get playerLoadingLabel;

  /// Pause accessibility label
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playerPauseLabel;

  /// Play accessibility label
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playerPlayLabel;

  /// Playback speed accessibility label
  ///
  /// In en, this message translates to:
  /// **'Playback speed {speed}x'**
  String playerSpeedLabel(String speed);

  /// Mini player accessibility label
  ///
  /// In en, this message translates to:
  /// **'Now playing: {title} by {podcast}'**
  String playerNowPlayingLabel(String title, String podcast);

  /// Feed URL missing title
  ///
  /// In en, this message translates to:
  /// **'Feed URL not available'**
  String get podcastDetailFeedUrlMissing;

  /// Feed URL missing subtitle
  ///
  /// In en, this message translates to:
  /// **'This podcast does not have a feed URL'**
  String get podcastDetailFeedUrlMissingSubtitle;

  /// Episode load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load episodes'**
  String get podcastDetailLoadError;

  /// Ungrouped playlist label
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get podcastDetailUngrouped;

  /// Subscribed button label
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get podcastDetailSubscribed;

  /// Subscribe button label
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get podcastDetailSubscribe;

  /// Search no results
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get podcastDetailNoResults;

  /// Filter no results title
  ///
  /// In en, this message translates to:
  /// **'No matching episodes'**
  String get podcastDetailNoMatchingEpisodes;

  /// Filter no results subtitle
  ///
  /// In en, this message translates to:
  /// **'Try a different filter'**
  String get podcastDetailTryDifferentFilter;

  /// Empty episode list title
  ///
  /// In en, this message translates to:
  /// **'No episodes found'**
  String get podcastDetailNoEpisodes;

  /// Empty playlist subtitle
  ///
  /// In en, this message translates to:
  /// **'This playlist has no episodes'**
  String get podcastDetailPlaylistEmpty;

  /// Episode load error with detail
  ///
  /// In en, this message translates to:
  /// **'Error loading episodes: {error}'**
  String podcastDetailEpisodeLoadError(String error);

  /// Episode count label
  ///
  /// In en, this message translates to:
  /// **'{count} episodes'**
  String podcastDetailEpisodeCount(int count);

  /// Group count label
  ///
  /// In en, this message translates to:
  /// **'{count} groups'**
  String podcastDetailGroupCount(int count);

  /// Sort order oldest first
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get podcastDetailOldestFirst;

  /// Sort order newest first
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get podcastDetailNewestFirst;

  /// Generic load failure
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String podcastDetailFailedToLoad(String error);

  /// Replace queue dialog title
  ///
  /// In en, this message translates to:
  /// **'Replace queue?'**
  String get episodeReplaceQueueTitle;

  /// Replace queue dialog content
  ///
  /// In en, this message translates to:
  /// **'Starting playback will replace your current queue with episodes from this list.'**
  String get episodeReplaceQueueContent;

  /// Replace button label
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get episodeReplace;

  /// Download cancelled snackbar
  ///
  /// In en, this message translates to:
  /// **'Download cancelled'**
  String get downloadCancelled;

  /// Download retrying snackbar
  ///
  /// In en, this message translates to:
  /// **'Retrying download'**
  String get downloadRetrying;

  /// Download started snackbar
  ///
  /// In en, this message translates to:
  /// **'Download started'**
  String get downloadStarted;

  /// Delete download dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete download?'**
  String get downloadDeleteTitle;

  /// Delete download dialog content
  ///
  /// In en, this message translates to:
  /// **'The downloaded file will be removed.'**
  String get downloadDeleteContent;

  /// Download deleted snackbar
  ///
  /// In en, this message translates to:
  /// **'Download deleted'**
  String get downloadDeleted;

  /// OPML import screen title
  ///
  /// In en, this message translates to:
  /// **'Import Podcasts'**
  String get opmlImportTitle;

  /// Already subscribed label in OPML import
  ///
  /// In en, this message translates to:
  /// **'Already subscribed'**
  String get opmlAlreadySubscribed;

  /// Import selected button with count
  ///
  /// In en, this message translates to:
  /// **'Import Selected ({count})'**
  String opmlImportSelected(int count);

  /// NewsConnect weekday episodes playlist name
  ///
  /// In en, this message translates to:
  /// **'Daily News'**
  String get smartPlaylistDailyNews;

  /// NewsConnect non-weekday episodes playlist name
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get smartPlaylistPrograms;

  /// COTEN Radio extras playlist name
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get smartPlaylistExtras;

  /// Catch-all playlist name for uncategorized episodes
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get smartPlaylistOthers;

  /// Section header for smart playlists in podcast detail
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get smartPlaylistSectionTitle;

  /// Label for episodes view tab
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodesLabel;

  /// Label for smart playlists view tab
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get smartPlaylistsLabel;

  /// Title for episode detail screen
  ///
  /// In en, this message translates to:
  /// **'Episode details'**
  String get episodeDetails;

  /// Tooltip for share episode button
  ///
  /// In en, this message translates to:
  /// **'Share episode'**
  String get shareEpisode;

  /// Action to mark episode as played
  ///
  /// In en, this message translates to:
  /// **'Mark as played'**
  String get markAsPlayed;

  /// Action to mark episode as unplayed
  ///
  /// In en, this message translates to:
  /// **'Mark as unplayed'**
  String get markAsUnplayed;

  /// Action to add episode to playback queue
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// Relative date label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// Relative date label for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Episode count for smart playlist group card
  ///
  /// In en, this message translates to:
  /// **'{count} episodes'**
  String groupEpisodeCount(int count);

  /// Duration with hours and minutes for group card
  ///
  /// In en, this message translates to:
  /// **'{hours}h{minutes}m'**
  String groupDurationHoursMinutes(int hours, int minutes);

  /// Duration in minutes for group card
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String groupDurationMinutes(int minutes);

  /// Now Playing tab label in player
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get playerTabNowPlaying;

  /// Transcript tab label in player
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get playerTabTranscript;

  /// Transcript loading message
  ///
  /// In en, this message translates to:
  /// **'Loading transcript...'**
  String get playerTranscriptLoading;

  /// No transcript available message
  ///
  /// In en, this message translates to:
  /// **'No transcript available'**
  String get playerTranscriptEmpty;

  /// Jump to current position button label
  ///
  /// In en, this message translates to:
  /// **'Jump to current'**
  String get playerTranscriptJumpToCurrent;

  /// Accessibility label for transcript indicator icon
  ///
  /// In en, this message translates to:
  /// **'Transcript available'**
  String get episodeTranscriptAvailable;

  /// Per-podcast auto-download toggle title
  ///
  /// In en, this message translates to:
  /// **'Auto-download new episodes'**
  String get podcastAutoDownloadTitle;

  /// Per-podcast auto-download toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Download new episodes automatically during background refresh (WiFi only)'**
  String get podcastAutoDownloadSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
