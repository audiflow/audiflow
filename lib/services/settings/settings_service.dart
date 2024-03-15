// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/environment.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_service.g.dart';

@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  @override
  AppSettings build() {
    final defaults = AppSettings.sensibleDefaults();
    return AppSettings(
      streamWarnMobileData: _sharedPreferences.getBool('markPlayedAsDeleted') ??
          defaults.streamWarnMobileData,
      downloadWarnMobileData:
          _sharedPreferences.getBool('markPlayedAsDeleted') ??
              defaults.streamWarnMobileData,
      autoDownloadOnlyOnWifi:
          _sharedPreferences.getBool('markPlayedAsDeleted') ??
              defaults.autoDownloadOnlyOnWifi,
      autoDeleteEpisodes: _sharedPreferences.getBool('markPlayedAsDeleted') ??
          defaults.autoDeleteEpisodes,
      // ---------
      markDeletedEpisodesAsPlayed:
          _sharedPreferences.getBool('markPlayedAsDeleted') ??
              defaults.markDeletedEpisodesAsPlayed,
      storeDownloadsSDCard:
          _sharedPreferences.getBool('storeDownloadsSDCard') ??
              defaults.storeDownloadsSDCard,
      theme: BrightnessMode.values
          .byName(_sharedPreferences.getString('theme') ?? defaults.theme.name),
      playbackSpeed: _sharedPreferences.getDouble('speed') ?? 1.0,
      searchProvider: podcastIndexKey.isEmpty
          ? 'itunes'
          : (_sharedPreferences.getString('search') ?? defaults.searchProvider),
      searchProviders: [
        SearchProvider.itunes(),
        if (podcastIndexKey.isNotEmpty) SearchProvider.podcastindex(),
      ],
      externalLinkConsent: _sharedPreferences.getBool('externalLinkConsent') ??
          defaults.externalLinkConsent,
      autoOpenNowPlaying: _sharedPreferences.getBool('autoOpenNowPlaying') ??
          defaults.autoOpenNowPlaying,
      showFunding:
          _sharedPreferences.getBool('showFunding') ?? defaults.showFunding,
      autoUpdateEpisodePeriod:
          _sharedPreferences.getInt('autoUpdateEpisodePeriod') ??
              defaults.autoUpdateEpisodePeriod,
      trimSilence:
          _sharedPreferences.getBool('trimSilence') ?? defaults.trimSilence,
      volumeBoost:
          _sharedPreferences.getBool('volumeBoost') ?? defaults.volumeBoost,
      layout: _sharedPreferences.getInt('layout') ?? defaults.layout,
    );
  }

  static late SharedPreferences _sharedPreferences;

  static Future<void> setup() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // ignore: avoid_setters_without_getters
  set streamWarnMobileData(bool value) {
    _sharedPreferences.setBool('streamWarnMobileData', value);
    state = state.copyWith(streamWarnMobileData: value);
  }

  // ignore: avoid_setters_without_getters
  set downloadWarnMobileData(bool value) {
    _sharedPreferences.setBool('downloadWarnMobileData', value);
    state = state.copyWith(downloadWarnMobileData: value);
  }

  // ignore: avoid_setters_without_getters
  set autoDownloadOnlyOnWifi(bool value) {
    _sharedPreferences.setBool('autoDownloadOnlyOnWifi', value);
    state = state.copyWith(autoDownloadOnlyOnWifi: value);
  }

  // ignore: avoid_setters_without_getters
  set autoDeleteEpisodes(bool value) {
    _sharedPreferences.setBool('autoDeleteEpisodes', value);
    state = state.copyWith(autoDeleteEpisodes: value);
  }

  // ignore: avoid_setters_without_getters
  set markDeletedEpisodesAsPlayed(bool value) {
    _sharedPreferences.setBool('markDeletedEpisodesAsPlayed', value);
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
