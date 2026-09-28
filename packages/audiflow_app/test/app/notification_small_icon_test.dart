import 'dart:io';

import 'package:audiflow_app/features/player/services/audio_handler_provider.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

// Android draws notification small icons from the alpha channel only, so the
// full-colour launcher icon renders as a blank circle (#473).
const _resDir = 'android/app/src/main/res';
const _densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

void main() {
  test('ships the notification small icon for every density', () {
    for (final density in _densities) {
      final file = File(
        '$_resDir/drawable-$density/$androidNotificationSmallIcon.png',
      );
      check(because: density, file.existsSync()).isTrue();
    }
  });

  test('keeps the icon through release resource shrinking', () {
    final keep = File('$_resDir/raw/keep.xml').readAsStringSync();
    check(keep).contains('@drawable/$androidNotificationSmallIcon');
  });

  test('uses the icon for the playback notification', () {
    check(
      audioServiceConfig.androidNotificationIcon,
    ).equals('drawable/$androidNotificationSmallIcon');
  });

  test('tints the playback notification like new-episode ones', () {
    check(
      audioServiceConfig.notificationColor,
    ).equals(androidNotificationColor);
  });
}
