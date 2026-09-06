import 'package:audiflow_app/features/player/services/audio_handler_provider.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('audioServiceConfig', () {
    test('downscales Android notification artwork', () {
      // Google Play flags audio_service decoding artwork at full resolution
      // when no downscale size is configured (#451).
      check(audioServiceConfig.artDownscaleWidth).equals(256);
      check(
        audioServiceConfig.artDownscaleHeight,
      ).equals(audioServiceConfig.artDownscaleWidth);
    });

    test('keeps the playback notification channel settings', () {
      check(
        audioServiceConfig.androidNotificationChannelId,
      ).equals('com.audiflow.player');
      check(audioServiceConfig.androidNotificationOngoing).isTrue();
      check(audioServiceConfig.androidStopForegroundOnPause).isTrue();
    });
  });
}
