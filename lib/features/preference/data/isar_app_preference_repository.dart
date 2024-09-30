import 'package:audiflow/common/data/isar_repository.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/features/preference/model/app_preference.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_app_preference_repository.g.dart';

@Riverpod(keepAlive: true)
class IsarAppPreferenceRepository extends _$IsarAppPreferenceRepository
    implements AppPreferenceRepository {
  Isar get isar => ref.read(isarRepositoryProvider);

  @override
  AppPreference build() {
    isar.appPreferences.get(1).then((record) {
      if (record != null) {
        state = record;
      }
    });

    return AppPreference.sensibleDefaults();
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setStreamWarnMobileData(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(streamWarnMobileData: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setDownloadWarnMobileData(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(streamWarnMobileData: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setAutoDownloadOnlyOnWifi(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(autoDownloadOnlyOnWifi: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setAutoDeleteEpisodes(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(autoDeleteEpisodes: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setMarkDeletedEpisodesAsPlayed(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(markDeletedEpisodesAsPlayed: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setStoreDownloadsSDCard(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(storeDownloadsSDCard: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  @override
  Future<void> setTheme(ThemeMode mode) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(theme: mode);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  @override
  Future<void> setPlaybackSpeed(double playbackSpeed) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(playbackSpeed: playbackSpeed);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  @override
  Future<void> setSearchProvider(String provider) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(searchProvider: provider);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setExternalLinkConsent(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(externalLinkConsent: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setAutoOpenNowPlaying(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(autoOpenNowPlaying: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setShowFunding(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(showFunding: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setAutoUpdateEpisodePeriod(int period) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(autoUpdateEpisodePeriod: period);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setTrimSilence(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(trimSilence: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  // ignore: avoid_positional_boolean_parameters
  @override
  Future<void> setVolumeBoost(bool value) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(volumeBoost: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  @override
  Future<void> setLayoutMode(int mode) async {
    final record =
        (await isar.appPreferences.get(1) ?? AppPreference.sensibleDefaults())
            .copyWith(layout: mode);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }

  @override
  Future<void> replace(AppPreference preference) async {
    await isar.writeTxn(() => isar.appPreferences.put(preference));
  }
}
