import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsKeys', () {
    test('all keys are unique', () {
      final keys = <String>{
        // Appearance
        SettingsKeys.themeMode,
        SettingsKeys.locale,
        SettingsKeys.textScale,
        // Playback
        SettingsKeys.playbackSpeed,
        SettingsKeys.skipForwardSeconds,
        SettingsKeys.skipBackwardSeconds,
        SettingsKeys.autoCompleteThreshold,
        SettingsKeys.continuousPlayback,
        SettingsKeys.autoPlayOrder,
        // Downloads
        SettingsKeys.wifiOnlyDownload,
        SettingsKeys.autoDeletePlayed,
        SettingsKeys.maxConcurrentDownloads,
        // Feed Sync
        SettingsKeys.autoSync,
        SettingsKeys.syncIntervalMinutes,
        SettingsKeys.wifiOnlySync,
      };

      expect(keys.length, equals(15));
    });

    group('Appearance keys', () {
      test('themeMode has correct value', () {
        expect(SettingsKeys.themeMode, equals('settings_theme_mode'));
      });

      test('locale has correct value', () {
        expect(SettingsKeys.locale, equals('settings_locale'));
      });

      test('textScale has correct value', () {
        expect(SettingsKeys.textScale, equals('settings_text_scale'));
      });
    });

    group('Playback keys', () {
      test('playbackSpeed has correct value', () {
        expect(SettingsKeys.playbackSpeed, equals('settings_playback_speed'));
      });

      test('skipForwardSeconds has correct value', () {
        expect(
          SettingsKeys.skipForwardSeconds,
          equals('settings_skip_forward_seconds'),
        );
      });

      test('skipBackwardSeconds has correct value', () {
        expect(
          SettingsKeys.skipBackwardSeconds,
          equals('settings_skip_backward_seconds'),
        );
      });

      test('autoCompleteThreshold has correct value', () {
        expect(
          SettingsKeys.autoCompleteThreshold,
          equals('settings_auto_complete_threshold'),
        );
      });

      test('continuousPlayback has correct value', () {
        expect(
          SettingsKeys.continuousPlayback,
          equals('settings_continuous_playback'),
        );
      });

      test('autoPlayOrder has correct value', () {
        expect(SettingsKeys.autoPlayOrder, equals('settings_auto_play_order'));
      });
    });

    group('Downloads keys', () {
      test('wifiOnlyDownload has correct value', () {
        expect(
          SettingsKeys.wifiOnlyDownload,
          equals('settings_wifi_only_download'),
        );
      });

      test('autoDeletePlayed has correct value', () {
        expect(
          SettingsKeys.autoDeletePlayed,
          equals('settings_auto_delete_played'),
        );
      });

      test('maxConcurrentDownloads has correct value', () {
        expect(
          SettingsKeys.maxConcurrentDownloads,
          equals('settings_max_concurrent_downloads'),
        );
      });
    });

    group('Feed Sync keys', () {
      test('autoSync has correct value', () {
        expect(SettingsKeys.autoSync, equals('settings_auto_sync'));
      });

      test('syncIntervalMinutes has correct value', () {
        expect(
          SettingsKeys.syncIntervalMinutes,
          equals('settings_sync_interval_minutes'),
        );
      });

      test('wifiOnlySync has correct value', () {
        expect(SettingsKeys.wifiOnlySync, equals('settings_wifi_only_sync'));
      });
    });
  });

  group('SettingsDefaults', () {
    test('textScale defaults to 1.0', () {
      expect(SettingsDefaults.textScale, equals(1.0));
    });

    test('playbackSpeed defaults to 1.0', () {
      expect(SettingsDefaults.playbackSpeed, equals(1.0));
    });

    test('skipForwardSeconds defaults to 30', () {
      expect(SettingsDefaults.skipForwardSeconds, equals(30));
    });

    test('skipBackwardSeconds defaults to 10', () {
      expect(SettingsDefaults.skipBackwardSeconds, equals(10));
    });

    test('autoCompleteThreshold defaults to 0.95', () {
      expect(SettingsDefaults.autoCompleteThreshold, equals(0.95));
    });

    test('continuousPlayback defaults to true', () {
      expect(SettingsDefaults.continuousPlayback, isTrue);
    });

    test('autoPlayOrder defaults to oldestFirst', () {
      expect(SettingsDefaults.autoPlayOrder, AutoPlayOrder.oldestFirst);
    });

    test('wifiOnlyDownload defaults to true', () {
      expect(SettingsDefaults.wifiOnlyDownload, isTrue);
    });

    test('autoDeletePlayed defaults to false', () {
      expect(SettingsDefaults.autoDeletePlayed, isFalse);
    });

    test('maxConcurrentDownloads defaults to 1', () {
      expect(SettingsDefaults.maxConcurrentDownloads, equals(1));
    });

    test('autoSync defaults to true', () {
      expect(SettingsDefaults.autoSync, isTrue);
    });

    test('syncIntervalMinutes defaults to 60', () {
      expect(SettingsDefaults.syncIntervalMinutes, equals(60));
    });

    test('wifiOnlySync defaults to false', () {
      expect(SettingsDefaults.wifiOnlySync, isFalse);
    });
  });
}
