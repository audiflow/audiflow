// Host-side driver for `integration_test/store_screenshots_test.dart`.
//
// Runs on the Mac, not the device: writes each screenshot the test takes to
// SCREENSHOT_OUT_DIR as `<name>.png`.
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final outDir = Platform.environment['SCREENSHOT_OUT_DIR'];
  if (outDir == null || outDir.isEmpty) {
    stderr.writeln('SCREENSHOT_OUT_DIR is not set');
    exit(2);
  }
  await Directory(outDir).create(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      await File('$outDir/$name.png').writeAsBytes(bytes);
      return true;
    },
  );
}
