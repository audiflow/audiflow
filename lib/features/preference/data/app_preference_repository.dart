import 'package:audiflow/constants/brightness_mode.dart';
import 'package:audiflow/features/preference/model/app_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_preference_repository.g.dart';

@Riverpod(keepAlive: true)
class AppPreferenceRepository extends _$AppPreferenceRepository {
  @override
  AppPreference build() => AppPreference.sensibleDefaults();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setStreamWarnMobileData(bool value) =>
      throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setDownloadWarnMobileData(bool value) =>
      throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoDownloadOnlyOnWifi(bool value) =>
      throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoDeleteEpisodes(bool value) => throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setMarkDeletedEpisodesAsPlayed(bool value) =>
      throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setStoreDownloadsSDCard(bool value) =>
      throw UnimplementedError();

  Future<void> setTheme(BrightnessMode mode) => throw UnimplementedError();

  Future<void> setPlaybackSpeed(double playbackSpeed) =>
      throw UnimplementedError();

  Future<void> setSearchProvider(String provider) => throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setExternalLinkConsent(bool value) => throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoOpenNowPlaying(bool value) => throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setShowFunding(bool value) => throw UnimplementedError();

  Future<void> setAutoUpdateEpisodePeriod(int period) =>
      throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setTrimSilence(bool value) => throw UnimplementedError();

  // ignore: avoid_positional_boolean_parameters
  Future<void> setVolumeBoost(bool value) => throw UnimplementedError();

  Future<void> setLayoutMode(int mode) => throw UnimplementedError();

  Future<void> replace(AppPreference preference) => throw UnimplementedError();
}
