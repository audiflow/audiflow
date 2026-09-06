import 'package:audiflow_app/features/player/services/audio_handler_provider.dart';
import 'package:audiflow_app/features/player/services/now_playing_artwork_preparer.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('audioServiceConfig', () {
    test('downscales Android notification artwork', () {
      // Google Play flags audio_service decoding artwork at full resolution
      // when no downscale size is configured (#451).
      check(audioServiceConfig.artDownscaleWidth).isNotNull();
      check(
        audioServiceConfig.artDownscaleHeight,
      ).equals(audioServiceConfig.artDownscaleWidth);
    });

    test('decodes the prepared artwork file whole', () {
      // The plugin halves only while half the source still covers the
      // request, so an equal size keeps the sample size at 1. A smaller
      // request would decode the 512 px file at 256 px (#455).
      check(
        audioServiceConfig.artDownscaleWidth,
      ).equals(nowPlayingArtworkMaxEdgePixels);
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
