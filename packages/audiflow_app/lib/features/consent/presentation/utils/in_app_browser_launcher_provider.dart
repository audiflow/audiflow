import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

part 'in_app_browser_launcher_provider.g.dart';

/// Signature for an in-app browser launcher.
///
/// Returns true when the URL was opened, false on failure.
typedef InAppBrowserLauncher = Future<bool> Function(Uri uri);

/// Launches URLs in an in-app browser surface
/// ([url_launcher.LaunchMode.inAppBrowserView] → SFSafariViewController on
/// iOS / Chrome Custom Tabs on Android), keeping the consent flow on top of
/// the calling activity.
@riverpod
InAppBrowserLauncher inAppBrowserLauncher(Ref ref) {
  return _defaultLaunchInAppBrowser;
}

Future<bool> _defaultLaunchInAppBrowser(Uri uri) async {
  try {
    return await url_launcher.launchUrl(
      uri,
      mode: url_launcher.LaunchMode.inAppBrowserView,
    );
  } catch (e) {
    debugPrint('launchUrl (in-app browser) failed for $uri: $e');
    return false;
  }
}
