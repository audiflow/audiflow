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

  /// Common done action
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

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

  /// Sort podcasts by latest episode date
  ///
  /// In en, this message translates to:
  /// **'Latest episode'**
  String get librarySortByLatestEpisode;

  /// Sort podcasts by subscription date
  ///
  /// In en, this message translates to:
  /// **'Subscription date'**
  String get librarySortBySubscribedAt;

  /// Sort podcasts alphabetically
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get librarySortByAlphabetical;

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

  /// Inline error banner when refresh fails but previous results exist
  ///
  /// In en, this message translates to:
  /// **'Search failed. Showing previous results.'**
  String get searchErrorBanner;

  /// Accessibility label for search refresh progress indicator
  ///
  /// In en, this message translates to:
  /// **'Loading new results'**
  String get searchRefreshingLabel;

  /// Label for search region picker
  ///
  /// In en, this message translates to:
  /// **'Search Region'**
  String get searchRegionLabel;

  /// Current search region indicator
  ///
  /// In en, this message translates to:
  /// **'Searching in {country}'**
  String searchRegionCurrent(String country);

  /// Title for region picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get searchRegionPickerTitle;

  /// Subtitle for region picker
  ///
  /// In en, this message translates to:
  /// **'iTunes store to search for podcasts'**
  String get searchRegionPickerSubtitle;

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
  /// **'Rewind {seconds} seconds'**
  String playerRewindLabel(int seconds);

  /// Forward accessibility label
  ///
  /// In en, this message translates to:
  /// **'Forward {seconds} seconds'**
  String playerForwardLabel(int seconds);

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

  /// Navigate to download management
  ///
  /// In en, this message translates to:
  /// **'Manage Downloads'**
  String get downloadManageTitle;

  /// Download management screen title
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadScreenTitle;

  /// Error loading downloads
  ///
  /// In en, this message translates to:
  /// **'Failed to load downloads'**
  String get downloadLoadError;

  /// Tooltip for delete all completed button
  ///
  /// In en, this message translates to:
  /// **'Delete all completed'**
  String get downloadDeleteAllCompleted;

  /// Snackbar after deleting all completed
  ///
  /// In en, this message translates to:
  /// **'Completed downloads deleted'**
  String get downloadCompletedDeleted;

  /// Download status group header
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadStatusDownloading;

  /// Download status group header
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get downloadStatusPending;

  /// Download status group header
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get downloadStatusPaused;

  /// Download status group header
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get downloadStatusCompleted;

  /// Download status group header
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get downloadStatusFailed;

  /// Download status group header
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get downloadStatusCancelled;

  /// Empty state for download management
  ///
  /// In en, this message translates to:
  /// **'No downloads'**
  String get downloadEmptyTitle;

  /// Section header with count
  ///
  /// In en, this message translates to:
  /// **'{status} ({count})'**
  String downloadSectionCount(String status, int count);

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

  /// Tooltip for more actions button on episode detail
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get episodeMoreActions;

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
  /// **'Download new episodes automatically during background refresh'**
  String get podcastAutoDownloadSubtitle;

  /// Section title for Stations
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get stationSectionTitle;

  /// Button label for creating a new station
  ///
  /// In en, this message translates to:
  /// **'New Station'**
  String get stationNew;

  /// Label for station name input field
  ///
  /// In en, this message translates to:
  /// **'Station Name'**
  String get stationName;

  /// Placeholder hint for station name input
  ///
  /// In en, this message translates to:
  /// **'e.g., News, Tech, Comedy'**
  String get stationNameHint;

  /// Label for podcasts in a station
  ///
  /// In en, this message translates to:
  /// **'Podcasts'**
  String get stationPodcasts;

  /// Label for station filters section
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get stationFilters;

  /// Label for playback order setting
  ///
  /// In en, this message translates to:
  /// **'Playback Order'**
  String get stationPlaybackOrder;

  /// Option to sort episodes newest first
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get stationNewest;

  /// Option to sort episodes oldest first
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get stationOldest;

  /// Filter option for all episodes
  ///
  /// In en, this message translates to:
  /// **'All Episodes'**
  String get stationFilterAll;

  /// Filter option for unplayed episodes
  ///
  /// In en, this message translates to:
  /// **'Unplayed'**
  String get stationFilterUnplayed;

  /// Filter option for episodes in progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get stationFilterInProgress;

  /// Filter option for downloaded episodes only
  ///
  /// In en, this message translates to:
  /// **'Downloaded Only'**
  String get stationFilterDownloaded;

  /// Filter option for favorited episodes only
  ///
  /// In en, this message translates to:
  /// **'Favorites Only'**
  String get stationFilterFavorited;

  /// Label for duration filter section
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get stationFilterDuration;

  /// Filter for episodes shorter than specified minutes
  ///
  /// In en, this message translates to:
  /// **'Shorter than {minutes} min'**
  String stationFilterShorterThan(int minutes);

  /// Filter for episodes longer than specified minutes
  ///
  /// In en, this message translates to:
  /// **'Longer than {minutes} min'**
  String stationFilterLongerThan(int minutes);

  /// Filter for recently published episodes
  ///
  /// In en, this message translates to:
  /// **'Published within {days} days'**
  String stationFilterPublishedWithin(int days);

  /// Error message when station limit is reached
  ///
  /// In en, this message translates to:
  /// **'Station limit reached ({max})'**
  String stationLimitReached(int max);

  /// Confirmation message for deleting a station
  ///
  /// In en, this message translates to:
  /// **'Delete this station?'**
  String get stationDeleteConfirm;

  /// Episode count display with plural forms
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No episodes} =1{1 episode} other{{count} episodes}}'**
  String stationEpisodeCount(int count);

  /// Podcast count display with plural forms
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 podcast} other{{count} podcasts}}'**
  String stationPodcastCount(int count);

  /// Message displayed when station has no matching episodes
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get stationEmpty;

  /// Button label to play all episodes in station
  ///
  /// In en, this message translates to:
  /// **'Play All'**
  String get stationPlayAll;

  /// Hint shown when user has no stations
  ///
  /// In en, this message translates to:
  /// **'No stations yet. Tap + to create one.'**
  String get stationNoStationsYet;

  /// Hint shown when user has no subscriptions
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet.'**
  String get stationNoSubscriptionsYet;

  /// Subtitle for empty station state
  ///
  /// In en, this message translates to:
  /// **'New episodes will appear here automatically.'**
  String get stationEmptySubtitle;

  /// App bar title for editing a station
  ///
  /// In en, this message translates to:
  /// **'Edit Station'**
  String get stationEditTitle;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get stationSave;

  /// Delete station button label
  ///
  /// In en, this message translates to:
  /// **'Delete Station'**
  String get stationDelete;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Station'**
  String get stationDeleteTitle;

  /// Delete confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this station? This cannot be undone.'**
  String get stationDeleteBody;

  /// Toggle label for hiding playback-completed episodes
  ///
  /// In en, this message translates to:
  /// **'Hide completed episodes'**
  String get stationFilterHideCompletedLabel;

  /// Label for downloaded filter toggle
  ///
  /// In en, this message translates to:
  /// **'Downloaded only'**
  String get stationFilterDownloadedLabel;

  /// Label for favorited filter toggle
  ///
  /// In en, this message translates to:
  /// **'Favorited only'**
  String get stationFilterFavoritedLabel;

  /// Section title for duration filter
  ///
  /// In en, this message translates to:
  /// **'Duration Filter'**
  String get stationDurationFilter;

  /// Duration filter operator label
  ///
  /// In en, this message translates to:
  /// **'Shorter than'**
  String get stationShorterThan;

  /// Duration filter operator label
  ///
  /// In en, this message translates to:
  /// **'Longer than'**
  String get stationLongerThan;

  /// Suffix label for duration minutes input
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get stationDurationMinutesSuffix;

  /// Section title for sort order
  ///
  /// In en, this message translates to:
  /// **'Episode Order'**
  String get stationEpisodeOrder;

  /// Sort option label
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get stationNewestFirst;

  /// Sort option label
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get stationOldestFirst;

  /// Tooltip for edit button
  ///
  /// In en, this message translates to:
  /// **'Edit station'**
  String get stationEditTooltip;

  /// App bar title for station not found screen
  ///
  /// In en, this message translates to:
  /// **'Station Not Found'**
  String get stationNotFoundTitle;

  /// Body text for station not found screen
  ///
  /// In en, this message translates to:
  /// **'Station data not available'**
  String get stationNotFoundMessage;

  /// Validation error when station name is empty
  ///
  /// In en, this message translates to:
  /// **'Station name is required'**
  String get stationNameRequired;

  /// Validation error when no podcast is selected
  ///
  /// In en, this message translates to:
  /// **'Select at least one podcast'**
  String get stationPodcastRequired;

  /// Label for episodes in station
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get stationEpisodes;

  /// Show only the latest episode
  ///
  /// In en, this message translates to:
  /// **'Latest only'**
  String get stationLatestOnly;

  /// Show latest N episodes (2+)
  ///
  /// In en, this message translates to:
  /// **'Latest {count}'**
  String stationLatestN(int count);

  /// Option to show all episodes
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get stationAllEpisodes;

  /// Option to group episodes by podcast
  ///
  /// In en, this message translates to:
  /// **'Group by podcast'**
  String get stationGroupByPodcast;

  /// Label for podcast ordering selector when grouping is enabled
  ///
  /// In en, this message translates to:
  /// **'Podcast order'**
  String get stationPodcastOrder;

  /// Sort podcasts by subscription date, oldest first
  ///
  /// In en, this message translates to:
  /// **'Subscribe (old)'**
  String get stationPodcastSortSubscribeOld;

  /// Sort podcasts by subscription date, newest first
  ///
  /// In en, this message translates to:
  /// **'Subscribe (new)'**
  String get stationPodcastSortSubscribeNew;

  /// Sort podcasts by name ascending
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get stationPodcastSortNameAz;

  /// Sort podcasts by name descending
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get stationPodcastSortNameZa;

  /// Manual podcast ordering
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get stationPodcastSortManual;

  /// Button to enter reorder mode
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get stationReorder;

  /// Button to finish reordering
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stationReorderDone;

  /// Prompt to select podcasts
  ///
  /// In en, this message translates to:
  /// **'Select podcasts...'**
  String get stationSelectPodcasts;

  /// Show selected/total podcasts count
  ///
  /// In en, this message translates to:
  /// **'{selected} / {total}'**
  String stationSelectPodcastsCount(int selected, int total);

  /// Title for podcast picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select Podcasts'**
  String get stationPickerTitle;

  /// Placeholder for podcast search input
  ///
  /// In en, this message translates to:
  /// **'Search podcasts...'**
  String get stationPickerSearch;

  /// Show count of subscribed podcasts
  ///
  /// In en, this message translates to:
  /// **'{count} subscribed'**
  String stationPickerSubscribed(int count);

  /// Show count of search results
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String stationPickerResults(int count);

  /// Sort search results by name ascending
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get stationPickerSortNameAz;

  /// Sort search results by name descending
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get stationPickerSortNameZa;

  /// Sort by subscription date, newest first
  ///
  /// In en, this message translates to:
  /// **'Recently subscribed'**
  String get stationPickerSortRecentlySubscribed;

  /// Sort by update date, newest first
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get stationPickerSortRecentlyUpdated;

  /// Default station with episode limit label
  ///
  /// In en, this message translates to:
  /// **'Default ({label})'**
  String stationDefault(String label);

  /// Default station showing all episodes
  ///
  /// In en, this message translates to:
  /// **'Default (All)'**
  String get stationDefaultAll;

  /// Go back button label
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get commonGoBack;

  /// Snackbar when deep link podcast resolution fails
  ///
  /// In en, this message translates to:
  /// **'Podcast not found'**
  String get deepLinkPodcastNotFound;

  /// Snackbar when episode resolution fails
  ///
  /// In en, this message translates to:
  /// **'Episode not found'**
  String get deepLinkEpisodeNotFound;

  /// Snackbar on network failure during deep link resolution
  ///
  /// In en, this message translates to:
  /// **'Could not load, check your connection'**
  String get deepLinkNetworkError;

  /// Loading screen text during deep link resolution
  ///
  /// In en, this message translates to:
  /// **'Opening link...'**
  String get deepLinkLoading;

  /// Tooltip for podcast share button
  ///
  /// In en, this message translates to:
  /// **'Share podcast'**
  String get sharePodcast;

  /// Semantic label and tooltip for the center voice command button
  ///
  /// In en, this message translates to:
  /// **'Voice command'**
  String get voiceCommandButton;

  /// Status text while voice recognition is active
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get voiceListening;

  /// Status text while voice command is being parsed
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get voiceProcessing;

  /// Status text while voice command is being executed
  ///
  /// In en, this message translates to:
  /// **'Executing: {intent}'**
  String voiceExecuting(String intent);

  /// Error when voice command cannot be parsed
  ///
  /// In en, this message translates to:
  /// **'Could not understand: \"{transcription}\"'**
  String voiceCouldNotUnderstand(String transcription);

  /// Title shown when voice command is ambiguous between multiple settings
  ///
  /// In en, this message translates to:
  /// **'Which setting do you mean?'**
  String get voiceSettingsWhichSetting;

  /// Confirmation message when a setting is auto-applied via voice
  ///
  /// In en, this message translates to:
  /// **'Setting changed'**
  String get voiceSettingsChanged;

  /// Undo action label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Confirm action label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Cancel action label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Hint text shown on voice error state
  ///
  /// In en, this message translates to:
  /// **'Tap mic to try again'**
  String get voiceTapMicToRetry;

  /// Navigation bar label for search tab
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Navigation bar label for library tab
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Navigation bar label for queue tab
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get navQueue;

  /// Navigation bar label for settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Voice settings category title
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get settingsVoiceTitle;

  /// Voice settings category subtitle
  ///
  /// In en, this message translates to:
  /// **'Voice commands and recognition'**
  String get settingsVoiceSubtitle;

  /// Badge label for experimental voice feature
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get voiceExperimentalLabel;

  /// Warning description for experimental voice feature
  ///
  /// In en, this message translates to:
  /// **'Voice commands are an experimental feature and may not work reliably on most devices. Accuracy and availability will improve as on-device AI capabilities evolve.'**
  String get voiceExperimentalDescription;

  /// Toggle label for enabling voice commands
  ///
  /// In en, this message translates to:
  /// **'Voice Commands'**
  String get voiceEnabledTitle;

  /// Toggle subtitle for enabling voice commands
  ///
  /// In en, this message translates to:
  /// **'Enable voice control for the app'**
  String get voiceEnabledSubtitle;

  /// Section header listing available voice commands
  ///
  /// In en, this message translates to:
  /// **'Available Commands'**
  String get voiceAvailableCommands;

  /// Description of the play/resume voice command
  ///
  /// In en, this message translates to:
  /// **'Play / Resume playback'**
  String get voiceCommandPlay;

  /// Description of the pause voice command
  ///
  /// In en, this message translates to:
  /// **'Pause playback'**
  String get voiceCommandPause;

  /// Description of the stop voice command
  ///
  /// In en, this message translates to:
  /// **'Stop playback'**
  String get voiceCommandStop;

  /// Description of the skip forward voice command
  ///
  /// In en, this message translates to:
  /// **'Skip forward'**
  String get voiceCommandSkipForward;

  /// Description of the skip backward voice command
  ///
  /// In en, this message translates to:
  /// **'Skip backward'**
  String get voiceCommandSkipBackward;

  /// Description of the search voice command
  ///
  /// In en, this message translates to:
  /// **'Search for podcasts'**
  String get voiceCommandSearch;

  /// Description of the go to library voice command
  ///
  /// In en, this message translates to:
  /// **'Go to Library'**
  String get voiceCommandGoToLibrary;

  /// Description of the go to queue voice command
  ///
  /// In en, this message translates to:
  /// **'Go to Queue'**
  String get voiceCommandGoToQueue;

  /// Description of the open settings voice command
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get voiceCommandOpenSettings;

  /// Description of the change setting voice command
  ///
  /// In en, this message translates to:
  /// **'Change a setting'**
  String get voiceCommandChangeSettings;

  /// Voice intent label: play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get voiceIntentPlay;

  /// Voice intent label: pause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get voiceIntentPause;

  /// Voice intent label: stop
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceIntentStop;

  /// Voice intent label: skip forward
  ///
  /// In en, this message translates to:
  /// **'Skip forward'**
  String get voiceIntentSkipForward;

  /// Voice intent label: skip backward
  ///
  /// In en, this message translates to:
  /// **'Skip backward'**
  String get voiceIntentSkipBackward;

  /// Voice intent label: seek
  ///
  /// In en, this message translates to:
  /// **'Seek'**
  String get voiceIntentSeek;

  /// Voice intent label: search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get voiceIntentSearch;

  /// Voice intent label: go to library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get voiceIntentGoToLibrary;

  /// Voice intent label: go to queue
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get voiceIntentGoToQueue;

  /// Voice intent label: open settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get voiceIntentOpenSettings;

  /// Voice intent label: add to queue
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get voiceIntentAddToQueue;

  /// Voice intent label: remove from queue
  ///
  /// In en, this message translates to:
  /// **'Remove from queue'**
  String get voiceIntentRemoveFromQueue;

  /// Voice intent label: clear queue
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get voiceIntentClearQueue;

  /// Voice intent label: change setting
  ///
  /// In en, this message translates to:
  /// **'Change setting'**
  String get voiceIntentChangeSettings;

  /// Voice intent label: unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get voiceIntentUnknown;

  /// Action to add episode to play next in queue
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get playNext;

  /// Action to download an episode
  ///
  /// In en, this message translates to:
  /// **'Download episode'**
  String get downloadEpisode;

  /// Action to navigate to episode detail
  ///
  /// In en, this message translates to:
  /// **'Go to episode'**
  String get goToEpisode;

  /// Action to remove a downloaded episode
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownload;

  /// Label for episode title in statistics table
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get statsTitle;

  /// Label for podcast name in statistics table
  ///
  /// In en, this message translates to:
  /// **'Podcast'**
  String get statsPodcast;

  /// Label for episode duration in statistics table
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get statsDuration;

  /// Label for publish date in statistics table
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get statsPublished;

  /// Label for completion count in statistics table
  ///
  /// In en, this message translates to:
  /// **'Times completed'**
  String get statsTimesCompleted;

  /// Label for play count in statistics table
  ///
  /// In en, this message translates to:
  /// **'Times started'**
  String get statsTimesStarted;

  /// Label for total content duration listened
  ///
  /// In en, this message translates to:
  /// **'Total listened'**
  String get statsTotalListened;

  /// Label for total wall-clock listening time
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get statsRealtime;

  /// Label for first playback date
  ///
  /// In en, this message translates to:
  /// **'First played'**
  String get statsFirstPlayed;

  /// Label for most recent playback date
  ///
  /// In en, this message translates to:
  /// **'Last played'**
  String get statsLastPlayed;

  /// Shown when episode has never been played
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get statsNever;

  /// Section header for episode statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsSection;

  /// Snackbar shown after copying text to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get commonCopiedToClipboard;

  /// Settings grid card title for developer preferences
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDeveloperTitle;

  /// Settings grid card subtitle for developer preferences
  ///
  /// In en, this message translates to:
  /// **'Smart playlist patterns and debug info'**
  String get settingsDeveloperSubtitle;

  /// Tappable row label linking to the smartplaylist repo
  ///
  /// In en, this message translates to:
  /// **'Contribute smart playlist patterns'**
  String get developerContributeLabel;

  /// Short repo name shown below the contribute link
  ///
  /// In en, this message translates to:
  /// **'audiflow/audiflow-smartplaylist'**
  String get developerContributeRepo;

  /// Toggle title for developer info in episode detail
  ///
  /// In en, this message translates to:
  /// **'Show developer info'**
  String get developerShowInfoTitle;

  /// Toggle subtitle explaining what developer info shows
  ///
  /// In en, this message translates to:
  /// **'Display RSS feed URL and pattern links in episode details'**
  String get developerShowInfoSubtitle;

  /// Section header for the pattern list
  ///
  /// In en, this message translates to:
  /// **'Smart Playlist Patterns'**
  String get developerPatternsHeader;

  /// Section label in episode detail for developer info
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerSectionLabel;

  /// Label for the RSS feed URL field
  ///
  /// In en, this message translates to:
  /// **'RSS Feed URL'**
  String get developerRssFeedUrl;

  /// Copy button label
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get developerCopyLabel;

  /// Snackbar message after copying RSS URL
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get developerCopied;

  /// Label for the pattern link field
  ///
  /// In en, this message translates to:
  /// **'Smart Playlist Pattern'**
  String get developerPatternLabel;

  /// Shown when no smart playlist pattern matches the podcast
  ///
  /// In en, this message translates to:
  /// **'Not defined — add one?'**
  String get developerPatternNotDefined;
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
