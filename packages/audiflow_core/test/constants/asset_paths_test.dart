import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetPaths', () {
    test('splashLogo points to splash_logo.png', () {
      expect(AssetPaths.splashLogo, 'assets/images/splash_logo.png');
    });

    test('appIcon points to app_icon.png', () {
      expect(AssetPaths.appIcon, 'assets/images/app_icon.png');
    });

    test('fontsDir points to assets/fonts/', () {
      expect(AssetPaths.fontsDir, 'assets/fonts/');
    });

    test('iconsDir points to assets/icons/', () {
      expect(AssetPaths.iconsDir, 'assets/icons/');
    });

    test('splashLogo has png extension', () {
      expect(AssetPaths.splashLogo, endsWith('.png'));
    });

    test('appIcon has png extension', () {
      expect(AssetPaths.appIcon, endsWith('.png'));
    });

    test('fontsDir ends with trailing slash', () {
      expect(AssetPaths.fontsDir, endsWith('/'));
    });

    test('iconsDir ends with trailing slash', () {
      expect(AssetPaths.iconsDir, endsWith('/'));
    });

    test('all image paths start with assets/', () {
      expect(AssetPaths.splashLogo, startsWith('assets/'));
      expect(AssetPaths.appIcon, startsWith('assets/'));
    });

    test('constants are compile-time const', () {
      const splash = AssetPaths.splashLogo;
      const icon = AssetPaths.appIcon;
      const fonts = AssetPaths.fontsDir;
      const icons = AssetPaths.iconsDir;
      expect(splash, isNotEmpty);
      expect(icon, isNotEmpty);
      expect(fonts, isNotEmpty);
      expect(icons, isNotEmpty);
    });
  });
}
