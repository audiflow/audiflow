import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/core/environment.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/settings_service_provider.dart';
import 'package:seasoning/services/settings/settings_service.dart';

part 'settings_provider.g.dart';

@riverpod
class SettingsController extends _$SettingsController {
  @override
  AppSettings build() {
    return _appSettingsFromSettings(_settings);
  }

  SettingsService get _settings => ref.read(settingsServiceProvider);

  // ignore: avoid_positional_boolean_parameters
  void darkMode(bool darkMode) {
    if (_settings.themeDarkMode != darkMode) {
      _settings.themeDarkMode = darkMode;
      state = state.copyWith(theme: darkMode ? 'dark' : 'light');
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void markDeletedAsPlayed(bool mark) {
    if (_settings.markDeletedEpisodesAsPlayed != mark) {
      _settings.markDeletedEpisodesAsPlayed = mark;
      state = state.copyWith(markDeletedEpisodesAsPlayed: mark);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void storeDownloadsOnSDCard(bool store) {
    if (_settings.storeDownloadsSDCard != store) {
      _settings.storeDownloadsSDCard = store;
      state = state.copyWith(storeDownloadsSDCard: store);
    }
  }

  void playbackSpeed(double speed) {
    if (_settings.playbackSpeed != speed) {
      _settings.playbackSpeed = speed;
      state = state.copyWith(playbackSpeed: speed);
    }
  }

  void searchProvider(String provider) {
    if (_settings.searchProvider != provider) {
      _settings.searchProvider = provider;
      state = state.copyWith(searchProvider: provider);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void externalLinkConsent(bool consent) {
    if (_settings.externalLinkConsent != consent) {
      _settings.externalLinkConsent = consent;
      state = state.copyWith(externalLinkConsent: consent);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void autoOpenNowPlaying(bool autoOpen) {
    if (_settings.autoOpenNowPlaying != autoOpen) {
      _settings.autoOpenNowPlaying = autoOpen;
      state = state.copyWith(autoOpenNowPlaying: autoOpen);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void showFunding(bool show) {
    if (_settings.showFunding != show) {
      _settings.showFunding = show;
      state = state.copyWith(showFunding: show);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void trimSilence(bool trim) {
    if (_settings.trimSilence != trim) {
      _settings.trimSilence = trim;
      state = state.copyWith(trimSilence: trim);
    }
  }

  // ignore: avoid_positional_boolean_parameters
  void volumeBoost(bool boost) {
    if (_settings.volumeBoost != boost) {
      _settings.volumeBoost = boost;
      state = state.copyWith(volumeBoost: boost);
    }
  }

  void autoUpdateEpisodePeriod(int period) {
    if (_settings.autoUpdateEpisodePeriod != period) {
      _settings.autoUpdateEpisodePeriod = period;
      state = state.copyWith(autoUpdateEpisodePeriod: period);
    }
  }

  void layoutMode(int mode) {
    if (_settings.layoutMode != mode) {
      _settings.layoutMode = mode;
      state = state.copyWith(layout: mode);
    }
  }
}

AppSettings _appSettingsFromSettings(SettingsService settings) {
  /// Load all settings
  // Add our available search providers.
  final providers = <SearchProvider>[
    const SearchProvider(key: 'itunes', name: 'iTunes'),
  ];

  if (podcastIndexKey.isNotEmpty) {
    providers
        .add(const SearchProvider(key: 'podcastindex', name: 'PodcastIndex'));
  }

  return AppSettings(
    theme: settings.themeDarkMode ? 'dark' : 'light',
    markDeletedEpisodesAsPlayed: settings.markDeletedEpisodesAsPlayed,
    storeDownloadsSDCard: settings.storeDownloadsSDCard,
    playbackSpeed: settings.playbackSpeed,
    searchProvider: settings.searchProvider,
    searchProviders: providers,
    externalLinkConsent: settings.externalLinkConsent,
    autoOpenNowPlaying: settings.autoOpenNowPlaying,
    showFunding: settings.showFunding,
    trimSilence: settings.trimSilence,
    volumeBoost: settings.volumeBoost,
    autoUpdateEpisodePeriod: settings.autoUpdateEpisodePeriod,
    layout: settings.layoutMode,
  );
}
