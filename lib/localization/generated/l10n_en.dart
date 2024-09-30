// ignore_for_file: type=lint

import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get locale => 'en';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get goBack => 'Go Back';

  @override
  String get continues => 'Continue';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get clearSearchButton => 'Clear search text';

  @override
  String get subscriptions => 'My Podcasts';

  @override
  String get popularPodcasts => 'Popular Podcasts';

  @override
  String get recentlyPlayed => 'Recently Played';

  @override
  String get latestEpisodes => 'Latest Episodes';

  @override
  String get home => 'Home';

  @override
  String get chart => 'Chart';

  @override
  String get search => 'Search';

  @override
  String get library => 'Library';

  @override
  String get queue => 'Queue';

  @override
  String get nullSeason => 'Extras';

  @override
  String get clear => 'clear';

  @override
  String get episode => 'Episode';

  @override
  String get episodes => 'Episodes';

  @override
  String get season => 'Season';

  @override
  String get seasons => 'Seasons';

  @override
  String get settings => 'Settings';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get mobileData => 'Cellular Connection';

  @override
  String nEpisodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episodes',
    );
    return '$_temp0';
  }

  @override
  String get sec => 's';

  @override
  String get min => 'm';

  @override
  String get hour => 'h';

  @override
  String nDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String nHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String nMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String nSecondsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds ago',
      one: '1 second ago',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get episodeFilterMode => 'Filter Episodes';

  @override
  String get episodeFilterModeAll => 'All episodes';

  @override
  String get episodeFilterModePlayed => 'Played';

  @override
  String get episodeFilterModeUnplayed => 'Unplayed';

  @override
  String get episodeFilterModeDownloaded => 'Downloaded';

  @override
  String get seasonFilterMode => 'Filter Seasons';

  @override
  String get seasonFilterModeAll => 'All seasons';

  @override
  String get seasonFilterModeUnplayed => 'Unplayed';

  @override
  String get viewSortOldestToNewest => 'Sort Oldest to Newest';

  @override
  String get jumpToLastEpisode => 'Jump to last episode';

  @override
  String get resume => 'Resume';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get playFromStart => 'Play from start';

  @override
  String get playLatest => 'Play latest';

  @override
  String get playAgain => 'Play again';

  @override
  String get tooltipPlay => 'Play episode';

  @override
  String get tooltipPause => 'Pause episode';

  @override
  String get primaryQueue => 'Queue (manual)';

  @override
  String get adhocQueue => 'Queue (auto)';

  @override
  String get sleepOff => 'Off';

  @override
  String get sleepOnEpisodeEnds => 'When episode ends';

  @override
  String sleepMin(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String sleepHour(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get settingsOnDemandDownloadOnPlayback => 'Download Audio on Playback';

  @override
  String get settingsOnDemandDownloadOnPlaybackDescription => 'If not pre-downloaded, audio will be fetched at the start of playback';

  @override
  String get settingsManualDownload => 'Manual Download';

  @override
  String get settingsManualDownloadDescription => 'When manually downloading episodes';

  @override
  String get settingsAutoDownload => 'Automatic Download';

  @override
  String get settingsAutoDownloadDescription => 'Automatically downloads in various situations to reduce wait times and hassle';

  @override
  String get settingsAutoDownloadEnabled => 'Enabled';

  @override
  String get settingsAutoDownloadRecent => 'Number of Recently Published Episodes to Fetch';

  @override
  String get settingsAutoDownloadSubject => '';

  @override
  String get settingsAutoDownloadQueuedEpisodes => 'Episodes added to queue manually';

  @override
  String get settingsAutoDownloadIncludesAdhoc => 'Includes episodes automatically added to queue';

  @override
  String get settingsAutoDelete => 'Automatic Deletion';

  @override
  String get settingsAutoDeleteDescription => 'Automatically delete episodes after playback';

  @override
  String get settingsAutoDeleteAfter => 'After Playback';

  @override
  String get settingsAutoDeleteAfterDescription => 'Automatically delete episodes after playback';

  @override
  String get settingsAutoDeleteAfterNever => 'Never';

  @override
  String get settingsAutoDeleteAfter1day => '1 day';

  @override
  String get settingsAutoDeleteAfter3days => '3 days';

  @override
  String get settingsAutoDeleteAfter7days => '7 days';

  @override
  String get settingsAutoDeleteAfter14days => '14 days';

  @override
  String get settingsAutoDeleteAfter30days => '30 days';

  @override
  String get settingsWarnMobileData => 'Warn on Cellular Connection';

  @override
  String get settingsWarnMobileDataDescription => 'For those concerned about data usage, such as with metered plans';

  @override
  String get settingsWarnWifi => 'Warn when not connected to Wi-Fi';

  @override
  String get settingsWifiOnly => 'Wi-Fi Connection Only';

  @override
  String get settingsOpml => 'OPML Import/Export';

  @override
  String get settingsOpmlDescription => 'Import or export podcasts via OPML file, a de-facto standard file for podcast subscriptions';

  @override
  String get settingsOpmlImport => 'Import Podcasts via OPML File';

  @override
  String get settingsOpmlExport => 'Export Podcasts to OPML File';

  @override
  String get titleNoFiFi => 'Not Connected to Wi-Fi';

  @override
  String get titleCellularConnection => 'Cellular Connection';

  @override
  String get captionStreamingNoWifi => 'Since Wi-Fi is not connected, audio data will be fetched over cellular data.';

  @override
  String get captionDownloadNoWifi => '\'Since Wi-Fi is not connected, the episode will be downloaded over cellular data.\'';

  @override
  String get captionWarnSettingNavigation => 'You can change this warning in the settings';

  @override
  String get proceedPlaying => 'Play anyway';

  @override
  String get proceedDownload => 'Proceed';

  @override
  String get downloadAllEpisodes => 'Download All Episodes';

  @override
  String get downloadUnplayedEpisodes => 'Download Unplayed Episodes';

  @override
  String get semantics_podcast_details_header => 'Podcast details and episodes page';

  @override
  String get search_for_podcasts_hint => 'Search for podcasts';

  @override
  String get semantic_announce_searching => 'Searching, please wait.';

  @override
  String get no_search_results_message => 'No podcasts found';

  @override
  String get podcast_funding_dialog_header => 'Podcast Funding';

  @override
  String get podcast_funding_consent_message => 'This funding link will take you to an external site where you will be able to directly support the show. Links are provided by the podcast authors and is not controlled by Anytime.';
}
