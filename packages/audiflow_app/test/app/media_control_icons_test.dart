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
}
