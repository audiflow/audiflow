import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/core/environment.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_service.g.dart';

@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  @override
  AppSettings build() {
    return AppSettings(
      markDeletedEpisodesAsPlayed:
          _sharedPreferences.getBool('markPlayedAsDeleted') ?? false,
      storeDownloadsSDCard:
          _sharedPreferences.getBool('storeDownloadsSDCard') ?? false,
      theme: BrightnessMode.values
          .byName(_sharedPreferences.getString('theme') ?? 'system'),
      playbackSpeed: _sharedPreferences.getDouble('speed') ?? 1.0,
      searchProvider: podcastIndexKey.isEmpty
          ? 'itunes'
          : (_sharedPreferences.getString('search') ?? 'itunes'),
      searchProviders: [
        SearchProvider.itunes(),
        if (podcastIndexKey.isNotEmpty) SearchProvider.podcastindex(),
      ],
      externalLinkConsent:
          _sharedPreferences.getBool('externalLinkConsent') ?? false,
      autoOpenNowPlaying:
          _sharedPreferences.getBool('autoOpenNowPlaying') ?? false,
      showFunding: _sharedPreferences.getBool('showFunding') ?? true,
      autoUpdateEpisodePeriod:
          _sharedPreferences.getInt('autoUpdateEpisodePeriod') ?? 180,
      trimSilence: _sharedPreferences.getBool('trimSilence') ?? false,
      volumeBoost: _sharedPreferences.getBool('volumeBoost') ?? false,
      layout: _sharedPreferences.getInt('layout') ?? 0,
    );
  }

  static late SharedPreferences _sharedPreferences;

  static Future<void> setup() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // ignore: avoid_setters_without_getters
  set markDeletedEpisodesAsPlayed(bool value) {
    _sharedPreferences.setBool('markPlayedAsDeleted', value);
    state = state.copyWith(markDeletedEpisodesAsPlayed: value);
  }

  // ignore: avoid_setters_without_getters
  set storeDownloadsSDCard(bool value) {
    _sharedPreferences.setBool('storeDownloadsSDCard', value);
    state = state.copyWith(storeDownloadsSDCard: value);
  }

  // ignore: avoid_setters_without_getters
  set theme(BrightnessMode mode) {
    _sharedPreferences.setString('theme', mode.name);
    state = state.copyWith(theme: mode);
  }

  // ignore: avoid_setters_without_getters
  set playbackSpeed(double playbackSpeed) {
    _sharedPreferences.setDouble('speed', playbackSpeed);
  }

  // ignore: avoid_setters_without_getters
  set searchProvider(String provider) {
    _sharedPreferences.setString('search', provider);
  }

  // ignore: avoid_setters_without_getters
  set externalLinkConsent(bool consent) {
    _sharedPreferences.setBool('externalLinkConsent', consent);
  }

  // ignore: avoid_setters_without_getters
  set autoOpenNowPlaying(bool autoOpenNowPlaying) {
    _sharedPreferences.setBool('autoOpenNowPlaying', autoOpenNowPlaying);
  }

  // ignore: avoid_setters_without_getters
  set showFunding(bool show) {
    _sharedPreferences.setBool('showFunding', show);
  }

  // ignore: avoid_setters_without_getters
  set autoUpdateEpisodePeriod(int period) {
    _sharedPreferences.setInt('autoUpdateEpisodePeriod', period);
  }

  // ignore: avoid_setters_without_getters
  set trimSilence(bool trim) {
    _sharedPreferences.setBool('trimSilence', trim);
  }

  // ignore: avoid_setters_without_getters
  set volumeBoost(bool boost) {
    _sharedPreferences.setBool('volumeBoost', boost);
  }

  // ignore: avoid_setters_without_getters
  set layoutMode(int mode) {
    _sharedPreferences.setInt('layout', mode);
  }

  // ignore: avoid_setters_without_getters
  set settings(AppSettings settings) {
    state = settings;
  }
}
