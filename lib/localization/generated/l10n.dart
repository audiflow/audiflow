// ignore_for_file: type=lint
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en')
  ];

  /// No description provided for @locale.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get locale;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @continues.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continues;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @clearSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Clear search text'**
  String get clearSearchButton;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'My Podcasts'**
  String get subscriptions;

  /// No description provided for @popularPodcasts.
  ///
  /// In en, this message translates to:
  /// **'Popular Podcasts'**
  String get popularPodcasts;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @latestEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Latest Episodes'**
  String get latestEpisodes;

  /// No description provided for @downloadedEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadedEpisodes;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @chart.
  ///
  /// In en, this message translates to:
  /// **'Chart'**
  String get chart;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @nullSeason.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get nullSeason;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get clear;

  /// No description provided for @episode.
  ///
  /// In en, this message translates to:
  /// **'Episode'**
  String get episode;

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @seasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get seasons;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @wifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// No description provided for @mobileData.
  ///
  /// In en, this message translates to:
  /// **'Cellular Connection'**
  String get mobileData;

  /// Number of episodes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episodes} other{{count} episodes}}'**
  String nEpisodes(int count);

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get sec;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get min;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hour;

  /// Number of days ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String nDaysAgo(int count);

  /// Number of hours ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String nHoursAgo(int count);

  /// Number of minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String nMinutesAgo(int count);

  /// Number of seconds ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second ago} other{{count} seconds ago}}'**
  String nSecondsAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @episodeFilterMode.
  ///
  /// In en, this message translates to:
  /// **'Filter Episodes'**
  String get episodeFilterMode;

  /// No description provided for @episodeFilterModeAll.
  ///
  /// In en, this message translates to:
  /// **'All episodes'**
  String get episodeFilterModeAll;

  /// No description provided for @episodeFilterModePlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get episodeFilterModePlayed;

  /// No description provided for @episodeFilterModeUnplayed.
  ///
  /// In en, this message translates to:
  /// **'Unplayed'**
  String get episodeFilterModeUnplayed;

  /// No description provided for @episodeFilterModeDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get episodeFilterModeDownloaded;

  /// No description provided for @seasonFilterMode.
  ///
  /// In en, this message translates to:
  /// **'Filter Seasons'**
  String get seasonFilterMode;

  /// No description provided for @seasonFilterModeAll.
  ///
  /// In en, this message translates to:
  /// **'All seasons'**
  String get seasonFilterModeAll;

  /// No description provided for @seasonFilterModeUnplayed.
  ///
  /// In en, this message translates to:
  /// **'Unplayed'**
  String get seasonFilterModeUnplayed;

  /// No description provided for @viewSortOldestToNewest.
  ///
  /// In en, this message translates to:
  /// **'Sort Oldest to Newest'**
  String get viewSortOldestToNewest;

  /// No description provided for @jumpToLastEpisode.
  ///
  /// In en, this message translates to:
  /// **'Jump to last episode'**
  String get jumpToLastEpisode;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @playFromStart.
  ///
  /// In en, this message translates to:
  /// **'Play from start'**
  String get playFromStart;

  /// No description provided for @playLatest.
  ///
  /// In en, this message translates to:
  /// **'Play latest'**
  String get playLatest;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @tooltipPlay.
  ///
  /// In en, this message translates to:
  /// **'Play episode'**
  String get tooltipPlay;

  /// No description provided for @tooltipPause.
  ///
  /// In en, this message translates to:
  /// **'Pause episode'**
  String get tooltipPause;

  /// No description provided for @primaryQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue (manual)'**
  String get primaryQueue;

  /// No description provided for @adhocQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue (auto)'**
  String get adhocQueue;

  /// No description provided for @speedTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get speedTitle;

  /// No description provided for @sleepModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Timer'**
  String get sleepModeTitle;

  /// No description provided for @sleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepOff;

  /// No description provided for @sleepOnEpisodeEnds.
  ///
  /// In en, this message translates to:
  /// **'When episode ends'**
  String get sleepOnEpisodeEnds;

  /// No description provided for @sleepMin.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 minute} other{{n} minutes}}'**
  String sleepMin(int n);

  /// No description provided for @sleepHour.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 hour} other{{n} hours}}'**
  String sleepHour(int n);

  /// No description provided for @settingsOnDemandDownloadOnPlayback.
  ///
  /// In en, this message translates to:
  /// **'Download Audio on Playback'**
  String get settingsOnDemandDownloadOnPlayback;

  /// No description provided for @settingsOnDemandDownloadOnPlaybackDescription.
  ///
  /// In en, this message translates to:
  /// **'If not pre-downloaded, audio will be fetched at the start of playback'**
  String get settingsOnDemandDownloadOnPlaybackDescription;

  /// No description provided for @settingsManualDownload.
  ///
  /// In en, this message translates to:
  /// **'Manual Download'**
  String get settingsManualDownload;

  /// No description provided for @settingsManualDownloadDescription.
  ///
  /// In en, this message translates to:
  /// **'When manually downloading episodes'**
  String get settingsManualDownloadDescription;

  /// No description provided for @settingsAutoDownload.
  ///
  /// In en, this message translates to:
  /// **'Automatic Download'**
  String get settingsAutoDownload;

  /// No description provided for @settingsAutoDownloadDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically downloads in various situations to reduce wait times and hassle'**
  String get settingsAutoDownloadDescription;

  /// No description provided for @settingsAutoDownloadEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsAutoDownloadEnabled;

  /// No description provided for @settingsAutoDownloadRecent.
  ///
  /// In en, this message translates to:
  /// **'Number of Recently Published Episodes to Fetch'**
  String get settingsAutoDownloadRecent;

  /// No description provided for @settingsAutoDownloadSubject.
  ///
  /// In en, this message translates to:
  /// **''**
  String get settingsAutoDownloadSubject;

  /// No description provided for @settingsAutoDownloadQueuedEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes added to queue manually'**
  String get settingsAutoDownloadQueuedEpisodes;

  /// No description provided for @settingsAutoDownloadIncludesAdhoc.
  ///
  /// In en, this message translates to:
  /// **'Includes episodes automatically added to queue'**
  String get settingsAutoDownloadIncludesAdhoc;

  /// No description provided for @settingsAutoDelete.
  ///
  /// In en, this message translates to:
  /// **'Automatic Deletion'**
  String get settingsAutoDelete;

  /// No description provided for @settingsAutoDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically delete episodes after playback'**
  String get settingsAutoDeleteDescription;

  /// No description provided for @settingsAutoDeleteAfter.
  ///
  /// In en, this message translates to:
  /// **'After Playback'**
  String get settingsAutoDeleteAfter;

  /// No description provided for @settingsAutoDeleteAfterDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically delete episodes after playback'**
  String get settingsAutoDeleteAfterDescription;

  /// No description provided for @settingsAutoDeleteAfterNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get settingsAutoDeleteAfterNever;

  /// No description provided for @settingsAutoDeleteAfter1day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get settingsAutoDeleteAfter1day;

  /// No description provided for @settingsAutoDeleteAfter3days.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get settingsAutoDeleteAfter3days;

  /// No description provided for @settingsAutoDeleteAfter7days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get settingsAutoDeleteAfter7days;

  /// No description provided for @settingsAutoDeleteAfter14days.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get settingsAutoDeleteAfter14days;

  /// No description provided for @settingsAutoDeleteAfter30days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get settingsAutoDeleteAfter30days;

  /// No description provided for @settingsWarnMobileData.
  ///
  /// In en, this message translates to:
  /// **'Warn on Cellular Connection'**
  String get settingsWarnMobileData;

  /// No description provided for @settingsWarnMobileDataDescription.
  ///
  /// In en, this message translates to:
  /// **'For those concerned about data usage, such as with metered plans'**
  String get settingsWarnMobileDataDescription;

  /// No description provided for @settingsWarnWifi.
  ///
  /// In en, this message translates to:
  /// **'Warn when not connected to Wi-Fi'**
  String get settingsWarnWifi;

  /// No description provided for @settingsWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Connection Only'**
  String get settingsWifiOnly;

  /// No description provided for @settingsOpml.
  ///
  /// In en, this message translates to:
  /// **'OPML Import/Export'**
  String get settingsOpml;

  /// No description provided for @settingsOpmlDescription.
  ///
  /// In en, this message translates to:
  /// **'Import or export podcasts via OPML file, a de-facto standard file for podcast subscriptions'**
  String get settingsOpmlDescription;

  /// No description provided for @settingsOpmlImport.
  ///
  /// In en, this message translates to:
  /// **'Import Podcasts via OPML File'**
  String get settingsOpmlImport;

  /// No description provided for @settingsOpmlExport.
  ///
  /// In en, this message translates to:
  /// **'Export Podcasts to OPML File'**
  String get settingsOpmlExport;

  /// No description provided for @titleNoFiFi.
  ///
  /// In en, this message translates to:
  /// **'Not Connected to Wi-Fi'**
  String get titleNoFiFi;

  /// No description provided for @titleCellularConnection.
  ///
  /// In en, this message translates to:
  /// **'Cellular Connection'**
  String get titleCellularConnection;

  /// No description provided for @captionStreamingNoWifi.
  ///
  /// In en, this message translates to:
  /// **'Since Wi-Fi is not connected, audio data will be fetched over cellular data.'**
  String get captionStreamingNoWifi;

  /// No description provided for @captionDownloadNoWifi.
  ///
  /// In en, this message translates to:
  /// **'\'Since Wi-Fi is not connected, the episode will be downloaded over cellular data.\''**
  String get captionDownloadNoWifi;

  /// No description provided for @captionWarnSettingNavigation.
  ///
  /// In en, this message translates to:
  /// **'You can change this warning in the settings'**
  String get captionWarnSettingNavigation;

  /// No description provided for @proceedPlaying.
  ///
  /// In en, this message translates to:
  /// **'Play anyway'**
  String get proceedPlaying;

  /// No description provided for @proceedDownload.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceedDownload;

  /// No description provided for @downloadAllEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Download All Episodes'**
  String get downloadAllEpisodes;

  /// No description provided for @downloadUnplayedEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Download Unplayed Episodes'**
  String get downloadUnplayedEpisodes;

  /// No description provided for @semantics_podcast_details_header.
  ///
  /// In en, this message translates to:
  /// **'Podcast details and episodes page'**
  String get semantics_podcast_details_header;

  /// No description provided for @search_for_podcasts_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for podcasts'**
  String get search_for_podcasts_hint;

  /// No description provided for @semantic_announce_searching.
  ///
  /// In en, this message translates to:
  /// **'Searching, please wait.'**
  String get semantic_announce_searching;

  /// No description provided for @no_search_results_message.
  ///
  /// In en, this message translates to:
  /// **'No podcasts found'**
  String get no_search_results_message;

  /// No description provided for @podcast_funding_dialog_header.
  ///
  /// In en, this message translates to:
  /// **'Podcast Funding'**
  String get podcast_funding_dialog_header;

  /// No description provided for @podcast_funding_consent_message.
  ///
  /// In en, this message translates to:
  /// **'This funding link will take you to an external site where you will be able to directly support the show. Links are provided by the podcast authors and is not controlled by Anytime.'**
  String get podcast_funding_consent_message;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return L10nEn();
    case 'ja': return L10nJa();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
