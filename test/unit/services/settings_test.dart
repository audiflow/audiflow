// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_common/riverpod.dart';

/// This set of tests ensures that we can set and get each setting and, more
/// importantly, we get the correct notification in the settings stream as
/// each is updated.
void main() {
  const timeout = 500;
  final settings = <String, Object>{'dummy': 1};
  late ProviderContainer container;

  SettingsService service() =>
   container.read(settingsServiceProvider.notifier);

  AppSettings state() =>
      container.read(settingsServiceProvider);

  final mobileSettingsServiceProvider = Provider((_)=> SettingsService());

  void createRepository() {
    SharedPreferences.setMockInitialValues(settings);
    container = createContainer();
  }

  setUp(() async {
    createRepository();
    await SettingsService.setup();
  });

  test(
    'Test mark deleted episodes as played',
    () async {
      expect(state().markDeletedEpisodesAsPlayed, false);
      service().markDeletedEpisodesAsPlayed = true;
      expect(state().markDeletedEpisodesAsPlayed, true);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test SD card',
    () async {
      expect(state().storeDownloadsSDCard, false);
      service().storeDownloadsSDCard = true;
      expect(state().storeDownloadsSDCard, true);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test dark mode',
    () async {
      expect(state().theme, BrightnessMode.light);
      service().theme = BrightnessMode.dark;
      expect(state().theme, BrightnessMode.dark);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test playback speed',
    () async {
      expect(state().playbackSpeed, 1.0);
      service().playbackSpeed = 1.25;
      expect(state().playbackSpeed, 1.25);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test search provider',
    () async {
      expect(state().searchProvider, 'itunes');
      // Key not set so should still return itunes.
      service().searchProvider = 'itunes';
      expect(state().searchProvider, 'itunes');
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test external link consent',
    () async {
      expect(state().externalLinkConsent, false);
      service().externalLinkConsent = true;
      expect(state().externalLinkConsent, true);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test auto-open now playing screen',
    () async {
      expect(state().autoOpenNowPlaying, false);
      service().autoOpenNowPlaying = true;
      expect(state().autoOpenNowPlaying, true);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test show funding',
    () async {
      expect(state().showFunding, true);
      service().showFunding = false;
      expect(state().showFunding, false);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test episode refresh time',
    () async {
      expect(state().autoUpdateEpisodePeriod, 180);
      service().autoUpdateEpisodePeriod = 60;
      expect(state().autoUpdateEpisodePeriod, 60);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test trim silence',
    () async {
      expect(state().trimSilence, false);
      service().trimSilence = true;
      expect(state().trimSilence, true);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test volume boost',
    () async {
      expect(state().volumeBoost, false);
      service().volumeBoost = true;
      expect(state().volumeBoost, true);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );

  test(
    'Test layout mode',
    () async {
      expect(state().layout, 0);
      service().layoutMode = 1;
      expect(state().layout, 1);
    },
    timeout: const Timeout(Duration(milliseconds: timeout)),
  );
}
