import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_app_settings_repository.dart';
import '../../../helpers/fake_audio_playback_controller.dart';
import '../../../helpers/fake_queue_service.dart';

VoiceCommandExecutor _makeExecutor({
  FakeAppSettingsRepository? settingsRepo,
  FakeAudioPlaybackController? audioController,
  FakeQueueService? queueService,
}) {
  return VoiceCommandExecutor(
    audioController: audioController ?? FakeAudioPlaybackController(),
    queueService: queueService ?? FakeQueueService(),
    settingsRepository: settingsRepo ?? FakeAppSettingsRepository(),
  );
}

void main() {
  late FakeAppSettingsRepository fakeRepo;
  late FakeAudioPlaybackController fakeController;
  late VoiceCommandExecutor executor;

  setUp(() {
    fakeRepo = FakeAppSettingsRepository();
    fakeController = FakeAudioPlaybackController();
    executor = _makeExecutor(
      settingsRepo: fakeRepo,
      audioController: fakeController,
    );
  });

  group('VoiceCommandExecutor.applySetting', () {
    group('playback speed', () {
      test('updates repo and audio controller', () async {
        fakeRepo.playbackSpeed = 1.0;

        final result = await executor.applySetting(
          key: SettingsKeys.playbackSpeed,
          value: '1.5',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.playbackSpeed).equals(1.5);
        check(fakeController.lastSetSpeed).equals(1.5);
      });

      test('returns previousValue before update', () async {
        fakeRepo.playbackSpeed = 1.0;

        final result = await executor.applySetting(
          key: SettingsKeys.playbackSpeed,
          value: '2.0',
        );

        check(result.previousValue).equals('1.0');
      });

      test('fails gracefully on invalid double string', () async {
        final result = await executor.applySetting(
          key: SettingsKeys.playbackSpeed,
          value: 'fast',
        );

        check(result.isSuccess).isFalse();
        check(result.errorMessage).isNotNull();
      });
    });

    group('boolean settings', () {
      test('sets continuousPlayback to false', () async {
        fakeRepo.continuousPlayback = true;

        final result = await executor.applySetting(
          key: SettingsKeys.continuousPlayback,
          value: 'false',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.continuousPlayback).isFalse();
        check(result.previousValue).equals('true');
      });

      test('sets continuousPlayback to true', () async {
        fakeRepo.continuousPlayback = false;

        final result = await executor.applySetting(
          key: SettingsKeys.continuousPlayback,
          value: 'true',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.continuousPlayback).isTrue();
      });

      test('fails on invalid boolean string', () async {
        final result = await executor.applySetting(
          key: SettingsKeys.continuousPlayback,
          value: 'yes',
        );

        check(result.isSuccess).isFalse();
        check(result.errorMessage).isNotNull();
      });
    });

    group('enum settings (themeMode)', () {
      test('sets themeMode to dark', () async {
        fakeRepo.themeMode = ThemeMode.system;

        final result = await executor.applySetting(
          key: SettingsKeys.themeMode,
          value: 'dark',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.themeMode).equals(ThemeMode.dark);
        check(result.previousValue).equals('system');
      });

      test('sets themeMode to light', () async {
        fakeRepo.themeMode = ThemeMode.dark;

        final result = await executor.applySetting(
          key: SettingsKeys.themeMode,
          value: 'light',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.themeMode).equals(ThemeMode.light);
      });

      test('sets themeMode to system', () async {
        fakeRepo.themeMode = ThemeMode.dark;

        final result = await executor.applySetting(
          key: SettingsKeys.themeMode,
          value: 'system',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.themeMode).equals(ThemeMode.system);
      });

      test('fails on unknown themeMode value', () async {
        final result = await executor.applySetting(
          key: SettingsKeys.themeMode,
          value: 'sepia',
        );

        check(result.isSuccess).isFalse();
        check(result.errorMessage).isNotNull();
      });
    });

    group('enum settings (autoPlayOrder)', () {
      test('sets autoPlayOrder to asDisplayed', () async {
        fakeRepo.autoPlayOrder = AutoPlayOrder.oldestFirst;

        final result = await executor.applySetting(
          key: SettingsKeys.autoPlayOrder,
          value: 'asDisplayed',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.autoPlayOrder).equals(AutoPlayOrder.asDisplayed);
        check(result.previousValue).equals('oldestFirst');
      });
    });

    group('previousValue', () {
      test('captures previous int setting before update', () async {
        fakeRepo.skipForwardSeconds = 30;

        final result = await executor.applySetting(
          key: SettingsKeys.skipForwardSeconds,
          value: '15',
        );

        check(result.previousValue).equals('30');
        check(fakeRepo.skipForwardSeconds).equals(15);
      });

      test('captures previous double setting before update', () async {
        fakeRepo.textScale = 1.0;

        final result = await executor.applySetting(
          key: SettingsKeys.textScale,
          value: '1.2',
        );

        check(result.previousValue).equals('1.0');
        check(fakeRepo.textScale).equals(1.2);
      });

      test('captures previous nullable locale', () async {
        fakeRepo.locale = null;

        final result = await executor.applySetting(
          key: SettingsKeys.locale,
          value: 'ja',
        );

        check(result.previousValue).equals('system');
        check(fakeRepo.locale).equals('ja');
      });
    });

    group('unknown key', () {
      test('returns failure result with error message', () async {
        final result = await executor.applySetting(
          key: 'nonexistent_setting',
          value: 'any',
        );

        check(result.isSuccess).isFalse();
        check(result.previousValue).isNull();
        check(result.errorMessage).isNotNull();
      });
    });

    group('additional settings', () {
      test('sets wifiOnlyDownload', () async {
        fakeRepo.wifiOnlyDownload = true;

        final result = await executor.applySetting(
          key: SettingsKeys.wifiOnlyDownload,
          value: 'false',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.wifiOnlyDownload).isFalse();
      });

      test('sets maxConcurrentDownloads', () async {
        fakeRepo.maxConcurrentDownloads = 1;

        final result = await executor.applySetting(
          key: SettingsKeys.maxConcurrentDownloads,
          value: '3',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.maxConcurrentDownloads).equals(3);
      });

      test('sets searchCountry to null when value is system', () async {
        fakeRepo.searchCountry = 'US';

        final result = await executor.applySetting(
          key: SettingsKeys.searchCountry,
          value: 'system',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.searchCountry).isNull();
      });

      test('sets locale to null when value is system', () async {
        fakeRepo.locale = 'en';

        final result = await executor.applySetting(
          key: SettingsKeys.locale,
          value: 'system',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.locale).isNull();
      });

      test('sets skipBackwardSeconds', () async {
        fakeRepo.skipBackwardSeconds = 10;

        final result = await executor.applySetting(
          key: SettingsKeys.skipBackwardSeconds,
          value: '5',
        );

        check(result.isSuccess).isTrue();
        check(fakeRepo.skipBackwardSeconds).equals(5);
      });
    });
  });
}
