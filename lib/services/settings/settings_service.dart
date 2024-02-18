import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';

part 'settings_service.g.dart';

abstract class SettingsService {
  // ignore: avoid_setters_without_getters
  set settings(AppSettings settings);

  // ignore: avoid_setters_without_getters
  set theme(BrightnessMode mode);

  // ignore: avoid_setters_without_getters
  set markDeletedEpisodesAsPlayed(bool value);

  // ignore: avoid_setters_without_getters
  set storeDownloadsSDCard(bool value);

  // ignore: avoid_setters_without_getters
  set playbackSpeed(double playbackSpeed);

  // ignore: avoid_setters_without_getters
  set searchProvider(String provider);

  // ignore: avoid_setters_without_getters
  set externalLinkConsent(bool consent);

  // ignore: avoid_setters_without_getters
  set autoOpenNowPlaying(bool autoOpenNowPlaying);

  // ignore: avoid_setters_without_getters
  set showFunding(bool show);

  // ignore: avoid_setters_without_getters
  set autoUpdateEpisodePeriod(int period);

  // ignore: avoid_setters_without_getters
  set trimSilence(bool trim);

  // ignore: avoid_setters_without_getters
  set volumeBoost(bool boost);

  // ignore: avoid_setters_without_getters
  set layoutMode(int mode);
}

@riverpod
class EmptySettingsService extends _$EmptySettingsService
    implements SettingsService {
  @override
  AppSettings build() {
    return AppSettings.sensibleDefaults();
  }

  @override
  // ignore: avoid_setters_without_getters
  set markDeletedEpisodesAsPlayed(bool value) {}

  @override
  // ignore: avoid_setters_without_getters
  set storeDownloadsSDCard(bool value) {}

  @override
  // ignore: avoid_setters_without_getters
  set theme(BrightnessMode mode) {}

  @override
  // ignore: avoid_setters_without_getters
  set playbackSpeed(double playbackSpeed) {}

  @override
  // ignore: avoid_setters_without_getters
  set searchProvider(String provider) {}

  @override
  // ignore: avoid_setters_without_getters
  set externalLinkConsent(bool consent) {}

  @override
  // ignore: avoid_setters_without_getters
  set autoOpenNowPlaying(bool autoOpenNowPlaying) {}

  @override
  // ignore: avoid_setters_without_getters
  set showFunding(bool show) {}

  @override
  // ignore: avoid_setters_without_getters
  set autoUpdateEpisodePeriod(int period) {}

  @override
  // ignore: avoid_setters_without_getters
  set trimSilence(bool trim) {}

  @override
  // ignore: avoid_setters_without_getters
  set volumeBoost(bool boost) {}

  @override
  // ignore: avoid_setters_without_getters
  set layoutMode(int mode) {}

  @override
  // ignore: avoid_setters_without_getters
  set settings(AppSettings settings) {}
}
