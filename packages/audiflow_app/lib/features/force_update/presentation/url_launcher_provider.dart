import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

part 'url_launcher_provider.g.dart';

/// Function signature for launching a URL.
///
/// Wrapped behind a provider so widget tests can inject a recording fake
/// without touching the platform channel.
typedef UrlLauncher = Future<bool> Function(Uri uri);

/// Default URL launcher delegating to `package:url_launcher`.
///
/// Uses [url_launcher.LaunchMode.externalApplication] so the store link
/// opens the App Store / Play Store app directly.
@riverpod
UrlLauncher urlLauncher(Ref ref) {
  return _defaultLaunchUrl;
}

Future<bool> _defaultLaunchUrl(Uri uri) async {
  try {
    return await url_launcher.launchUrl(
      uri,
      mode: url_launcher.LaunchMode.externalApplication,
    );
  } catch (e) {
    debugPrint('launchUrl failed for $uri: $e');
    return false;
  }
}
