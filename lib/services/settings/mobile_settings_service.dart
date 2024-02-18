// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/core/environment.dart';
import 'package:seasoning/entities/app_settings.dart';
import 'package:seasoning/entities/search_providers.dart';
import 'package:seasoning/services/settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'mobile_settings_service.g.dart';

/// An implementation [SettingsService] for mobile devices backed by
/// shared preferences.
@Riverpod(keepAlive: true)
class MobileSettingsService extends _$MobileSettingsService
    implements SettingsService {
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

  @override
  // ignore: avoid_setters_without_getters
  set markDeletedEpisodesAsPlayed(bool value) {
    _sharedPreferences.setBool('markPlayedAsDeleted', value);
    state = state.copyWith(markDeletedEpisodesAsPlayed: value);
  }

  @override
  // ignore: avoid_setters_without_getters
  set storeDownloadsSDCard(bool value) {
    _sharedPreferences.setBool('storeDownloadsSDCard', value);
    state = state.copyWith(storeDownloadsSDCard: value);
  }

  @override
  // ignore: avoid_setters_without_getters
  set theme(BrightnessMode mode) {
    _sharedPreferences.setString('theme', mode.name);
    state = state.copyWith(theme: mode);
  }

  @override
  // ignore: avoid_setters_without_getters
  set playbackSpeed(double playbackSpeed) {
    _sharedPreferences.setDouble('speed', playbackSpeed);
  }

  @override
  // ignore: avoid_setters_without_getters
  set searchProvider(String provider) {
    _sharedPreferences.setString('search', provider);
  }

  @override
  // ignore: avoid_setters_without_getters
  set externalLinkConsent(bool consent) {
    _sharedPreferences.setBool('externalLinkConsent', consent);
  }

  @override
  // ignore: avoid_setters_without_getters
  set autoOpenNowPlaying(bool autoOpenNowPlaying) {
    _sharedPreferences.setBool('autoOpenNowPlaying', autoOpenNowPlaying);
  }

  @override
  // ignore: avoid_setters_without_getters
  set showFunding(bool show) {
    _sharedPreferences.setBool('showFunding', show);
  }

  @override
  // ignore: avoid_setters_without_getters
  set autoUpdateEpisodePeriod(int period) {
    _sharedPreferences.setInt('autoUpdateEpisodePeriod', period);
  }

  @override
  // ignore: avoid_setters_without_getters
  set trimSilence(bool trim) {
    _sharedPreferences.setBool('trimSilence', trim);
  }

  @override
  // ignore: avoid_setters_without_getters
  set volumeBoost(bool boost) {
    _sharedPreferences.setBool('volumeBoost', boost);
  }

  @override
  // ignore: avoid_setters_without_getters
  set layoutMode(int mode) {
    _sharedPreferences.setInt('layout', mode);
  }

  @override
  // ignore: avoid_setters_without_getters
  set settings(AppSettings settings) {
    state = settings;
  }
}
