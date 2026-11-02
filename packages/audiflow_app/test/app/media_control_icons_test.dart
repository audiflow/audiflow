import 'dart:io';

import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

// audio_service resolves its media control icons by name with getIdentifier(),
// which AGP 9's optimized resource shrinking cannot see. Without a keep rule
// the release build drops them, and building the media session's custom
// actions throws "You must specify an icon resource id to build a
// CustomAction" on every playback state update.
void main() {
  test(
    'keeps audio_service media control icons through resource shrinking',
    () {
      final keep = File(
        'android/app/src/main/res/raw/keep.xml',
      ).readAsStringSync();
      check(keep).contains('@drawable/audio_service_*');
    },
  );

  test('keeps the in-car control icons through resource shrinking', () {
    final keep = File(
      'android/app/src/main/res/raw/keep.xml',
    ).readAsStringSync();
    check(keep).contains('@drawable/ic_car_*');
  });

  // An unlistened provider pauses its subscriptions, so with only a read the
  // speed and skip icons would stop updating when Android Auto launches the
  // app in the background (the same bug as d731044d for CarPlay).
  test('main listens to the audio handler rather than only reading it', () {
    check(
      File('lib/main.dart').readAsStringSync(),
    ).contains('container.listen(audioHandlerProvider');
  });
}
