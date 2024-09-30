import 'package:audiflow/constants/locale.dart';
import 'package:audiflow/constants/search_providers.dart';
import 'package:audiflow/core/environment.dart';
import 'package:audiflow/features/player/model/sleep.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'preference.g.dart';

@collection
class Preference {
  const Preference({
    required this.streamWarnMobileData,
    required this.downloadWarnMobileData,
    required this.autoDownloadOnlyOnWifi,
    required this.autoDeleteEpisodes,
    required this.theme,
    required this.markDeletedEpisodesAsPlayed,
    required this.storeDownloadsSDCard,
    required this.playbackSpeed,
    required this.playbackSleepType,
    required this.playbackSleepMinutes,
    required this.searchProvider,
    required this.searchProviders,
    required this.externalLinkConsent,
    required this.autoOpenNowPlaying,
    required this.showFunding,
    required this.autoUpdateEpisodePeriod,
    required this.trimSilence,
    required this.volumeBoost,
    required this.layout,
    required this.locale,
  });

  factory Preference.sensibleDefaults() {
    return Preference(
      streamWarnMobileData: true,
      downloadWarnMobileData: true,
      autoDownloadOnlyOnWifi: true,
      autoDeleteEpisodes: true,
      // --------
      theme: ThemeMode.system,
      markDeletedEpisodesAsPlayed: false,
      storeDownloadsSDCard: false,
      playbackSpeed: 1,
      playbackSleepType: SleepType.none,
      playbackSleepMinutes: 0,
      searchProvider: 'itunes',
      searchProviders: <SearchProvider>[
        SearchProvider.itunes,
        if (podcastIndexKey.isNotEmpty) SearchProvider.podcastIndex,
      ],
      externalLinkConsent: false,
      autoOpenNowPlaying: false,
      showFunding: true,
      autoUpdateEpisodePeriod: -1,
      trimSilence: false,
      volumeBoost: false,
      layout: 0,
      locale: undefinedLocale.toString(),
    );
  }

  final bool streamWarnMobileData;
  final bool downloadWarnMobileData;
  final bool autoDownloadOnlyOnWifi;
  final bool autoDeleteEpisodes;

  //----------------

  Id get id => 1;

  /// The current theme name.
  @enumerated
  final ThemeMode theme;

  /// True if episodes are marked as played when deleted.
  final bool markDeletedEpisodesAsPlayed;

  /// True if downloads should be saved to the SD card.
  final bool storeDownloadsSDCard;

  /// The default playback speed.
  final double playbackSpeed;

  /// The sleep type.
  @enumerated
  final SleepType playbackSleepType;

  /// The sleep type.
  final int playbackSleepMinutes;

  /// The search provider: itunes or podcastindex.
  final String searchProvider;

  /// List of search providers: currently itunes or podcastindex.
  @enumerated
  final List<SearchProvider> searchProviders;

  /// True if the user has confirmed dialog accepting funding links.
  final bool externalLinkConsent;

  /// If true the main player window will open as soon as an episode starts.
  final bool autoOpenNowPlaying;

  /// If true the funding link icon will appear (if the podcast supports it).
  final bool showFunding;

  /// If -1 never; 0 always; otherwise time in minutes.
  final int autoUpdateEpisodePeriod;

  /// If true; silence in audio playback is trimmed. Currently Android only.
  final bool trimSilence;

  /// If true; volume is boosted. Currently Android only.
  final bool volumeBoost;

  /// If 0; list view; else grid view
  final int layout;

  /// App locale
  final String locale;

  Preference copyWith({
    bool? streamWarnMobileData,
    bool? downloadWarnMobileData,
    bool? autoDownloadOnlyOnWifi,
    bool? autoDeleteEpisodes,
    ThemeMode? theme,
    bool? markDeletedEpisodesAsPlayed,
    bool? storeDownloadsSDCard,
    double? playbackSpeed,
    SleepType? playbackSleepType,
    int? playbackSleepMinutes,
    String? searchProvider,
    List<SearchProvider>? searchProviders,
    bool? externalLinkConsent,
    bool? autoOpenNowPlaying,
    bool? showFunding,
    int? autoUpdateEpisodePeriod,
    bool? trimSilence,
    bool? volumeBoost,
    int? layout,
    String? locale,
  }) {
    return Preference(
      streamWarnMobileData: streamWarnMobileData ?? this.streamWarnMobileData,
      downloadWarnMobileData:
          downloadWarnMobileData ?? this.downloadWarnMobileData,
      autoDownloadOnlyOnWifi:
          autoDownloadOnlyOnWifi ?? this.autoDownloadOnlyOnWifi,
      autoDeleteEpisodes: autoDeleteEpisodes ?? this.autoDeleteEpisodes,
      theme: theme ?? this.theme,
      markDeletedEpisodesAsPlayed:
          markDeletedEpisodesAsPlayed ?? this.markDeletedEpisodesAsPlayed,
      storeDownloadsSDCard: storeDownloadsSDCard ?? this.storeDownloadsSDCard,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      playbackSleepType: playbackSleepType ?? this.playbackSleepType,
      playbackSleepMinutes: playbackSleepMinutes ?? this.playbackSleepMinutes,
      searchProvider: searchProvider ?? this.searchProvider,
      searchProviders: searchProviders ?? this.searchProviders,
      externalLinkConsent: externalLinkConsent ?? this.externalLinkConsent,
      autoOpenNowPlaying: autoOpenNowPlaying ?? this.autoOpenNowPlaying,
      showFunding: showFunding ?? this.showFunding,
      autoUpdateEpisodePeriod:
          autoUpdateEpisodePeriod ?? this.autoUpdateEpisodePeriod,
      trimSilence: trimSilence ?? this.trimSilence,
      volumeBoost: volumeBoost ?? this.volumeBoost,
      layout: layout ?? this.layout,
      locale: locale ?? this.locale,
    );
  }
}

extension PreferenceExt on Preference {
  Sleep get playbackSleep => Sleep(
        type: playbackSleepType,
        duration: Duration(minutes: playbackSleepMinutes),
      );
}

class PreferenceUpdateParam {
  const PreferenceUpdateParam({
    this.streamWarnMobileData,
    this.downloadWarnMobileData,
    this.autoDownloadOnlyOnWifi,
    this.autoDeleteEpisodes,
    this.theme,
    this.markDeletedEpisodesAsPlayed,
    this.storeDownloadsSDCard,
    this.playbackSpeed,
    this.playbackSleep,
    this.searchProvider,
    this.searchProviders,
    this.externalLinkConsent,
    this.autoOpenNowPlaying,
    this.showFunding,
    this.autoUpdateEpisodePeriod,
    this.trimSilence,
    this.volumeBoost,
    this.layout,
    this.locale,
  });

  final bool? streamWarnMobileData;
  final bool? downloadWarnMobileData;
  final bool? autoDownloadOnlyOnWifi;
  final bool? autoDeleteEpisodes;
  final ThemeMode? theme;
  final bool? markDeletedEpisodesAsPlayed;
  final bool? storeDownloadsSDCard;
  final double? playbackSpeed;
  final Sleep? playbackSleep;
  final String? searchProvider;
  final List<SearchProvider>? searchProviders;
  final bool? externalLinkConsent;
  final bool? autoOpenNowPlaying;
  final bool? showFunding;
  final int? autoUpdateEpisodePeriod;
  final bool? trimSilence;
  final bool? volumeBoost;
  final int? layout;
  final String? locale;
}
